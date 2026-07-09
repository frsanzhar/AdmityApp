// Admity — "Chances" Supabase Edge Function (Deno).
//
// Evaluates a student's admission chances for a specific KZ university.
// The LLM key lives ONLY here (server-side). Deploy with:
//   supabase functions deploy chances
//   supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
//
// Request body (POST):
//   {
//     "university": { "id": "nu", "name_ru": "Назарбаев Университет" },
//     "programs":   [{ "name": "Информационные технологии", "minScore": 120 }],
//     "student":    {
//       "gpaBand": "4.5–5.0",   // GPA as a band, never a raw number (PII guard)
//       "ent": 115,              // ENT score (integer or null)
//       "ielts": "7.0",         // string or null
//       "sat": null,
//       "majors": ["IT"]        // target academic directions
//     }
//   }
//
// Response: { "result": "<structured markdown in Russian>" }
//
// PII policy: client MUST NOT send name, email, city, or exact GPA.
//   This function enforces the honesty rule: it never inflates chances.

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";

// Use the same model family as Eraly for consistent cost/quality.
const DEFAULT_MODEL = "claude-sonnet-5";

// Hard limit on body size — protects the LLM bill.
const MAX_BODY_BYTES = 8 * 1024;

// ── CORS ──────────────────────────────────────────────────────────────────────

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ── System prompt ─────────────────────────────────────────────────────────────

const SYSTEM_PROMPT = `
Ты — честный консультант по поступлению в университеты Казахстана.
Твоя задача: оценить реальные шансы абитуриента поступить в конкретный вуз,
опираясь на конкурсные данные ЕНТ (НЦТ).

ПРАВИЛА ЧЕСТНОСТИ (железные):
1. Никогда не завышай шансы. Лучше предупредить, чем обнадёжить зря.
2. Конкурсный минимум ≠ проходной балл — чётко разграничивай эти понятия.
3. Если данных не хватает — честно скажи об этом.
4. Никогда не пиши эссе и не делай работу за студента.
5. Всегда советуй подавать в несколько вузов.

СТРУКТУРА ОТВЕТА (строгий markdown, на русском языке):
## Оценка шансов
[1–2 предложения: высокие / на грани / низкие и почему]

## Ключевые факторы
[Маркированный список: что работает в пользу, что против]

## Конкретные шаги
[Нумерованный список: что сделать прямо сейчас]

## Запасной план
[1–2 предложения про альтернативные вузы / программы]

Ответ должен быть кратким (не более 350 слов), конкретным и честным.
Не используй восклицательные знаки для мотивации — студент ценит факты.
`.trim();

// ── Handler ───────────────────────────────────────────────────────────────────

Deno.serve(async (req: Request): Promise<Response> => {
  // Handle CORS preflight.
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Only POST is supported.
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  // Guard body size.
  const contentLength = parseInt(req.headers.get("content-length") ?? "0", 10);
  if (contentLength > MAX_BODY_BYTES) {
    return new Response(
      JSON.stringify({ error: "Request body too large" }),
      { status: 413, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  let body: {
    university: { id: string; name_ru: string };
    programs: Array<{ name: string; minScore: number | null }>;
    student: {
      gpaBand?: string;
      ent?: number | null;
      ielts?: string | null;
      sat?: string | null;
      majors?: string[];
    };
  };

  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ error: "Invalid JSON body" }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const { university, programs, student } = body;

  if (!university?.name_ru || !Array.isArray(programs) || !student) {
    return new Response(
      JSON.stringify({ error: "Missing required fields: university, programs, student" }),
      { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  // ── Build user message ─────────────────────────────────────────────────────

  const programLines = programs
    .map((p) =>
      p.minScore != null
        ? `- ${p.name} (конкурсный минимум: ${p.minScore} б.)`
        : `- ${p.name} (данных по баллу нет)`,
    )
    .join("\n");

  const studentLines = [
    student.gpaBand ? `ГПА: ${student.gpaBand}` : null,
    student.ent != null ? `ЕНТ: ${student.ent} б.` : null,
    student.ielts ? `IELTS: ${student.ielts}` : null,
    student.sat ? `SAT: ${student.sat}` : null,
    student.majors?.length
      ? `Целевые направления: ${student.majors.join(", ")}`
      : null,
  ]
    .filter(Boolean)
    .join("\n");

  const userMessage = `
Вуз: ${university.name_ru}

Программы и их конкурсные минимумы:
${programLines || "Нет данных по программам"}

Данные студента (без персональной информации):
${studentLines || "Нет данных"}

Пожалуйста, оцени шансы поступления на грант и дай конкретные рекомендации.
`.trim();

  // ── Call Anthropic ─────────────────────────────────────────────────────────

  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "ANTHROPIC_API_KEY not configured" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const model = Deno.env.get("CHANCES_MODEL") ?? DEFAULT_MODEL;

  let anthropicResponse: Response;
  try {
    anthropicResponse = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model,
        max_tokens: 800,
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: userMessage }],
      }),
    });
  } catch (err) {
    console.error("Anthropic fetch error:", err);
    return new Response(
      JSON.stringify({ error: "Failed to reach Anthropic API" }),
      { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  if (!anthropicResponse.ok) {
    const errText = await anthropicResponse.text();
    console.error("Anthropic API error:", anthropicResponse.status, errText);
    return new Response(
      JSON.stringify({ error: "Anthropic API error", status: anthropicResponse.status }),
      {
        status: 502,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const anthropicData = await anthropicResponse.json() as {
    content: Array<{ type: string; text: string }>;
  };

  const resultText =
    anthropicData.content
      ?.filter((c) => c.type === "text")
      ?.map((c) => c.text)
      ?.join("") ?? "";

  return new Response(
    JSON.stringify({ result: resultText }),
    {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
});

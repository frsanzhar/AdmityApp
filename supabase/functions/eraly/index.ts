// Admity — Ералы Edge Function
//
// Server-side LLM calls via Anthropic Claude.
// The ANTHROPIC_API_KEY is stored as a Supabase Edge Function secret
// and is NEVER shipped in the client.
//
// TODO(deploy): Before deploying, run:
//   supabase secrets set ANTHROPIC_API_KEY=<your-key>
//
// Payload shape (from the Flutter client):
//   { mode: 'chat' | 'propose_events' | 'generate_plan', ...mode-specific fields }
//
// PII minimisation: client sends no name/email/region.
// GPA is an optional band string (e.g. "3.5–4.0"), never a raw number.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

// ── Types ────────────────────────────────────────────────────────────────────

interface ChatPayload {
  mode: "chat";
  messages: Array<{ role: string; text: string }>;
  gpa_band?: string;
}

interface ProposeEventsPayload {
  mode: "propose_events";
  topic: string;
}

interface GeneratePlanPayload {
  mode: "generate_plan";
  topic: string;
  resources: string;
  available_time: string;
  internet_access: boolean;
}

type Payload = ChatPayload | ProposeEventsPayload | GeneratePlanPayload;

// ── System prompt ─────────────────────────────────────────────────────────────

const SYSTEM_PROMPT = `Ты Ералы — дружелюбный AI-наставник для школьников Казахстана (14–18 лет).
Ты помогаешь планировать учёбу, готовиться к экзаменам (ЕНТ, IELTS, SAT) и находить стипендии.

ОБЯЗАТЕЛЬНЫЕ ПРАВИЛА:
1. Ты НИКОГДА не пишешь и не составляешь эссе за ученика. Ты помогаешь улучшить идеи и структуру.
2. Ты ведёшь диалог — короткие, дружелюбные сообщения. НЕ выдавай стену текста.
3. Минимизируй личные данные: не запрашивай имя, email, регион.
4. Отвечай на языке пользователя (KZ / RU / EN).
5. Будь честным: не завышай шансы поступления.`;

// ── Anthropic API call ────────────────────────────────────────────────────────

const ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages";
// Model: claude-opus-4-8 — verified via claude-api skill (latest Opus, $5/$25 per MTok)
const MODEL = "claude-opus-4-8";

async function callClaude(
  messages: Array<{ role: string; content: string }>,
  maxTokens = 1024,
): Promise<string> {
  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) throw new Error("ANTHROPIC_API_KEY not set");

  const response = await fetch(ANTHROPIC_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: MODEL,
      max_tokens: maxTokens,
      thinking: { type: "adaptive" },
      system: SYSTEM_PROMPT,
      messages,
    }),
  });

  if (!response.ok) {
    const err = await response.text();
    throw new Error(`Anthropic API error ${response.status}: ${err}`);
  }

  const data = await response.json();
  // Extract text from the first text content block.
  for (const block of data.content ?? []) {
    if (block.type === "text") return block.text as string;
  }
  throw new Error("No text content in Claude response");
}

// ── Mode handlers ─────────────────────────────────────────────────────────────

async function handleChat(payload: ChatPayload): Promise<Response> {
  const messages = payload.messages.map((m) => ({
    role: m.role === "user" ? "user" : "assistant",
    content: m.text,
  }));

  const reply = await callClaude(messages, 512);
  return jsonOk({ reply });
}

async function handleProposeEvents(
  payload: ProposeEventsPayload,
): Promise<Response> {
  const prompt =
    `Пользователь хочет запланировать мероприятия по теме: "${payload.topic}".
Предложи 3 конкретных события в JSON-массиве. Каждое событие:
{ "id": "evt_1", "title": "...", "description": "...", "scheduled_at": "ISO 8601 datetime" }
Даты: первое через 1 день, второе через 3 дня, третье через 7 дней от сегодня (${new Date().toISOString()}).
Ответь ТОЛЬКО валидным JSON: { "events": [...] }`;

  const raw = await callClaude(
    [{ role: "user", content: prompt }],
    512,
  );

  // Parse the JSON from the response.
  try {
    const jsonMatch = raw.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("No JSON found");
    const parsed = JSON.parse(jsonMatch[0]);
    return jsonOk(parsed);
  } catch {
    // Fallback: return safe offline events if parsing fails.
    const base = new Date();
    return jsonOk({
      events: [1, 3, 7].map((days, i) => ({
        id: `evt_${i + 1}`,
        title: `Подготовка к ${payload.topic} — этап ${i + 1}`,
        description: "",
        scheduled_at: new Date(
          base.getTime() + days * 86400000,
        ).toISOString(),
      })),
    });
  }
}

async function handleGeneratePlan(
  payload: GeneratePlanPayload,
): Promise<Response> {
  const prompt =
    `Составь подробный поурочный план подготовки по теме: "${payload.topic}".
Информация от ученика:
- Доступные ресурсы: ${payload.resources}
- Доступное время: ${payload.available_time}
- Доступ к интернету: ${payload.internet_access ? "есть" : "нет"}

Верни ТОЛЬКО валидный JSON:
{
  "notes": "краткие предварительные замечания (1–2 предложения)",
  "lessons": [
    { "title": "...", "duration_minutes": 60, "resource": "URL или null" },
    ...
  ]
}
Уроков должно быть от 4 до 10. Ресурсы — только если доступ к интернету есть.`;

  const raw = await callClaude(
    [{ role: "user", content: prompt }],
    1024,
  );

  try {
    const jsonMatch = raw.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error("No JSON found");
    const parsed = JSON.parse(jsonMatch[0]);
    return jsonOk(parsed);
  } catch {
    // Offline fallback plan
    return jsonOk({
      notes: "Базовый план подготовки.",
      lessons: [
        { title: `Введение в ${payload.topic}`, duration_minutes: 60, resource: null },
        { title: "Основные концепции", duration_minutes: 90, resource: null },
        { title: "Практика и упражнения", duration_minutes: 60, resource: null },
        { title: "Итоговое повторение", duration_minutes: 45, resource: null },
      ],
    });
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function jsonOk(data: unknown): Response {
  return new Response(JSON.stringify(data), {
    status: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

function jsonError(message: string, status = 400): Response {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}

// ── Entry point ───────────────────────────────────────────────────────────────

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  }

  if (req.method !== "POST") {
    return jsonError("Only POST is supported", 405);
  }

  let payload: Payload;
  try {
    payload = (await req.json()) as Payload;
  } catch {
    return jsonError("Invalid JSON body");
  }

  try {
    switch (payload.mode) {
      case "chat":
        return await handleChat(payload as ChatPayload);
      case "propose_events":
        return await handleProposeEvents(payload as ProposeEventsPayload);
      case "generate_plan":
        return await handleGeneratePlan(payload as GeneratePlanPayload);
      default:
        return jsonError(`Unknown mode: ${(payload as Payload).mode}`);
    }
  } catch (err) {
    console.error("[eraly] handler error:", err);
    return jsonError("Internal server error", 500);
  }
});

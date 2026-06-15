// Admity — "Eraly" admissions-mentor Edge Function (Deno).
//
// The LLM key lives ONLY here (server-side). The Flutter client calls this
// function via supabase.functions.invoke('eraly'). Set secrets with:
//   supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
//   supabase secrets set ERALY_MODEL=claude-sonnet-4-6   # optional override
//   supabase secrets set ALLOWED_ORIGINS=https://app.example.com  # optional
// then deploy:
//   supabase functions deploy eraly
//
// Hardening (U5):
//  - Requires a valid Supabase Auth JWT (Authorization: Bearer <jwt>); the
//    request is bound to the authenticated user's id.
//  - Per-user rate limiting (~20/min, ~200/day) via the `rate_limits` table,
//    enforced server-side with the service-role key (see migration 0002).
//  - Request body capped at 16 KB.
//  - CORS locked to an ALLOWED_ORIGINS allowlist (browser origins denied by
//    default; the native mobile app sends no Origin header and stays allowed).
//
// Request body: { message: string, history: {role,content}[], profile: object }
// Response:     { reply: string }

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";

// Sonnet 4.6 is the cost/quality default for a high-volume student chat.
// For maximum capability set ERALY_MODEL=claude-opus-4-8.
const DEFAULT_MODEL = "claude-sonnet-4-6";

// Reject oversized payloads early (defends the LLM bill + the DB).
const MAX_BODY_BYTES = 16 * 1024;

// Per-user request budgets. Tune via the constants here.
const LIMIT_PER_MINUTE = 20;
const LIMIT_PER_DAY = 200;

const ERALY_SYSTEM_PROMPT = `
Ты — «Ералы», главный ИИ-наставник по поступлению в приложении Admity. Admity
помогает школьникам из регионов Казахстана поступать в университеты Казахстана,
Европы, США и Азии. Твоя миссия — дать подростку из любого аула или райцентра
тот же уровень навигации по поступлению, что есть у детей из дорогих частных
школ больших городов.

ИДЕНТИЧНОСТЬ
- Ты тёплый, конкретный, честный старший наставник — не сухой бот и не льстивый
  «коуч». Говоришь с подростком как умный, заботливый ментор.
- Ты координируешь суб-агентов: Профориентатор (RIASEC+Big Five), Чансинг-КЗ
  (ЕНТ-пороги), Чансинг-Мир (Common Data Set), Скаут-стипендий, Тренер-интенсивов,
  Редактор эссе. Решаешь, кого подключить, и собираешь единый ответ.

ГЛАВНЫЙ ПРИНЦИП: «НАПРАВЛЯЮ, НЕ ДЕЛАЮ ЗА УЧЕНИКА»
- Ты ПОМОГАЕШЬ и КОРРЕКТИРУЕШЬ, но НИКОГДА не выполняешь работу за ученика.
- Ты НИКОГДА не пишешь эссе/мотивационное письмо/personal statement целиком и не
  выдаёшь готовый текст под копирование. Вместо этого: задаёшь наводящие вопросы,
  помогаешь найти личную историю, даёшь фидбэк по рубрике, предлагаешь улучшить
  конкретную фразу, показываешь пример ЧУЖОГО обучающего текста и объясняешь,
  почему он работает. Автором всегда остаётся ученик.
- Если просят «напиши за меня эссе» — мягко откажись и объясни: вузы (UCAS,
  Common App, Chevening) считают сгенерированный текст списыванием, а главная цель
  — помочь ученику вырасти. Предложи: «Давай я задам тебе 3 вопроса, и ты увидишь,
  что история уже у тебя есть».

ЧЕСТНОСТЬ ДАННЫХ
- Никогда не выдумывай проценты шансов. Для мира — ДИАПАЗОНЫ (логика Common Data
  Set) и категория reach/target/likely. Для Казахстана — пороги и реальные
  проходные баллы прошлых лет с пометкой, что грантовый балл определяется
  конкурсом года, а вузы могут ставить свои, более высокие пороги.
- Отделяй факт от оценки и от «проверь у первоисточника». Если данные могли
  устареть (баллы, дедлайны, суммы) — прямо говори об этом.

ОПОРНЫЕ ФАКТЫ (помечай годом, «проверь у первоисточника»)
- ЕНТ 2025–2026: максимум 140 баллов. Пороги для гранта: нацвузы 65, медицина 70,
  право/педагогика 75, с/х и ветеринария 60, прочие 50; по каждому предмету ≥5.
  Реальные проходные 2024 (ориентир): КазНМУ Общая медицина 124, Стоматология 136,
  Педиатрия 111; КБТУ IT 110. Грантов на бакалавриат 2025–26 ≈ 77 084.
- CDS: используй acceptance rate, факторы C7 (very important/important/considered/
  not considered), SAT/ACT 25–75. Пример Harvard: SAT 1500–1580, приём ~4%.
- Need-blind+full-need для иностранцев: MIT, Harvard, Yale, Princeton, Amherst.
- Стипендии: Болашак (маг/PhD, бакалавриат пока не возвращён), Chevening
  (магистратура, ~2 года опыта, эссе по 300 слов), Erasmus Mundus, Stipendium
  Hungaricum (15 января), Türkiye Bursları (10 янв–20 фев), GKS (бакалавриат,
  возраст <25), CSC, Fulbright (маг/PhD).

ТОН И БЕЗОПАСНОСТЬ
- Просто, уважительно, без снобизма и канцелярита. Учитывай ограниченный бюджет
  семьи, возможно слабый английский, мало доступа к консультантам. Развенчивай
  мифы фактами. Хвали усилие и прогресс, а не только результат.
- Отвечай на языке обращения ученика (казахский / русский / английский).
- Пользователи несовершеннолетние: не давай медицинских/юридических/
  психотерапевтических диагнозов; при признаках кризиса мягко направь к
  доверенному взрослому. Не поощряй обман вузов (фейковые активности, чужие эссе).

ФОРМАТ
- Короткое тёплое вступление → суть (списки/шаги) → один конкретный следующий шаг.
- Любой чансинг — с категорией и честной оговоркой. Числа — с годом и «проверь у
  первоисточника». Никогда не выдавай готовый текст эссе под копирование.

УПРАВЛЕНИЕ КАЛЕНДАРЁМ
- У ученика есть личный календарь поступления (дедлайны, экзамены, этапы). Если
  ученик ПРЯМО просит добавить, поставить, перенести или убрать дату/событие —
  в САМОМ КОНЦЕ ответа добавь машинный блок РОВНО такого формата и НИЧЕГО про
  сам блок не объясняй:
\`\`\`calendar
[{"op":"add","title":"Короткое название","date":"YYYY-MM-DD","kind":"deadline","note":"необязательно"}]
\`\`\`
  - op: "add" или "remove". kind: "deadline" | "exam" | "milestone".
  - Чтобы убрать: {"op":"remove","title":"что убрать"} — удаляются только
    события, добавленные учеником или тобой (справочные даты не трогаются).
  - Можно несколько действий в массиве.
  - Добавляй блок ТОЛЬКО когда ученик реально просит изменить календарь; иначе
    блока быть не должно.
  - Если точной даты нет — не выдумывай: уточни дату или поставь ориентир и
    честно скажи об этом словами в тексте ответа.
`.trim();

type InMsg = { role: string; content: string };

// ── CORS ────────────────────────────────────────────────────────────────────
// Browser origins must be explicitly allowlisted via ALLOWED_ORIGINS (comma
// separated). The native mobile app sends NO Origin header, so it is unaffected
// by CORS and keeps working regardless of the allowlist.
function allowedOrigins(): string[] {
  return (Deno.env.get("ALLOWED_ORIGINS") ?? "")
    .split(",")
    .map((o) => o.trim())
    .filter((o) => o.length > 0);
}

// Resolves the Access-Control-Allow-Origin to echo for this request, or null
// when the browser origin is not allowlisted (browser will then block it).
function resolveCorsOrigin(req: Request): string | null {
  const origin = req.headers.get("origin");
  if (!origin) return null; // Non-browser caller (mobile app): no CORS needed.
  return allowedOrigins().includes(origin) ? origin : null;
}

function corsHeaders(req: Request): Record<string, string> {
  const headers: Record<string, string> = {
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    Vary: "Origin",
  };
  const origin = resolveCorsOrigin(req);
  if (origin) headers["Access-Control-Allow-Origin"] = origin;
  return headers;
}

Deno.serve(async (req: Request) => {
  const cors = corsHeaders(req);

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: cors });
  }

  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) {
    return json(cors, { error: "ANTHROPIC_API_KEY is not set" }, 500);
  }
  const model = Deno.env.get("ERALY_MODEL") ?? DEFAULT_MODEL;

  // (1) Require an authenticated Supabase JWT and bind the request to its user.
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.toLowerCase().startsWith("bearer ")) {
    return json(cors, { error: "Missing bearer token" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceKey) {
    return json(cors, { error: "Supabase environment is not configured" }, 500);
  }

  // Validate the caller's JWT by resolving the user it represents.
  const authClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userErr } = await authClient.auth.getUser();
  const userId = userData?.user?.id;
  if (userErr || !userId) {
    return json(cors, { error: "Invalid or expired token" }, 401);
  }

  // (2a) Body size cap. Prefer the declared length; fall back to byte length.
  const declaredLen = Number(req.headers.get("content-length") ?? "0");
  if (Number.isFinite(declaredLen) && declaredLen > MAX_BODY_BYTES) {
    return json(cors, { error: "Payload too large" }, 413);
  }
  const raw = await req.text();
  if (new TextEncoder().encode(raw).length > MAX_BODY_BYTES) {
    return json(cors, { error: "Payload too large" }, 413);
  }

  let body: { message?: string; history?: InMsg[]; profile?: unknown };
  try {
    body = JSON.parse(raw);
  } catch {
    return json(cors, { error: "Invalid JSON body" }, 400);
  }

  // (2b) Per-user rate limiting (service role bypasses RLS on rate_limits).
  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false },
  });
  const limit = await checkRateLimit(admin, userId);
  if (!limit.ok) {
    return json(
      cors,
      { error: "Rate limit exceeded", scope: limit.scope },
      429,
    );
  }

  const message = (body.message ?? "").trim();
  if (!message) return json(cors, { error: "Empty message" }, 400);

  const history = Array.isArray(body.history) ? body.history : [];
  const mapped = history
    .filter((m) => m && typeof m.content === "string" && m.content.length > 0)
    .map((m) => ({
      role: m.role === "user" ? "user" : "assistant",
      content: m.content,
    }));
  mapped.push({ role: "user", content: message });

  // The Anthropic Messages API requires the first message to use the "user"
  // role. Eraly's conversation opens with a seed greeting (assistant), so drop
  // any leading assistant turns; otherwise every request 400s and the client
  // silently falls back to the offline reply. Consecutive same-role messages
  // are allowed (the API merges them), so this is the only normalization needed.
  let firstUser = 0;
  while (firstUser < mapped.length && mapped[firstUser].role !== "user") {
    firstUser++;
  }
  const messages = mapped.slice(firstUser);

  // Inject the student's structured context as a system addendum. The client
  // already minimizes PII (no name, coarse region/GPA); we never add the id.
  const profileBlock = body.profile
    ? `\n\nКОНТЕКСТ УЧЕНИКА (JSON): ${JSON.stringify(body.profile)}`
    : "";

  // Bound the upstream call: a slow Anthropic response should fail fast with a
  // retry hint rather than hang until the function runtime limit (which, paired
  // with the client timeout, would otherwise wedge the student's turn).
  const upstream = new AbortController();
  const upstreamTimer = setTimeout(() => upstream.abort(), 25_000);
  let res: Response;
  try {
    res = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model,
        // A mentor reply often includes steps + a calendar action block; 1024
        // was tight enough to truncate longer answers mid-sentence (stop_reason
        // "max_tokens"). 2048 keeps replies whole at a still-modest cost.
        max_tokens: 2048,
        system: ERALY_SYSTEM_PROMPT + profileBlock,
        messages,
      }),
      signal: upstream.signal,
    });
  } catch (err) {
    const timedOut = err instanceof DOMException && err.name === "AbortError";
    return json(
      cors,
      { error: timedOut ? "Anthropic timed out" : "Anthropic request failed" },
      timedOut ? 504 : 502,
    );
  } finally {
    clearTimeout(upstreamTimer);
  }

  if (!res.ok) {
    const detail = await res.text();
    return json(cors, { error: `Anthropic error: ${res.status}`, detail }, 502);
  }

  const data = await res.json();
  const reply = Array.isArray(data?.content)
    ? data.content.map((c: { text?: string }) => c.text ?? "").join("").trim()
    : "";

  return json(cors, { reply });
});

// Atomically increments the per-minute and per-day counters for [userId] and
// reports whether either budget is exceeded. Backed by the `bump_rate_limit`
// SECURITY DEFINER function (migration 0002) so a single round-trip stays
// race-safe. Fails open on infra errors so a transient DB blip never blocks a
// student mid-conversation.
async function checkRateLimit(
  admin: ReturnType<typeof createClient>,
  userId: string,
): Promise<{ ok: true } | { ok: false; scope: "minute" | "day" }> {
  const now = new Date();
  const minuteBucket = now.toISOString().slice(0, 16); // yyyy-MM-ddTHH:mm
  const dayBucket = now.toISOString().slice(0, 10); // yyyy-MM-dd

  try {
    const minute = await admin.rpc("bump_rate_limit", {
      p_user_id: userId,
      p_scope: "minute",
      p_bucket: minuteBucket,
    });
    if (minute.error) return { ok: true }; // Fail open on DB error.
    if ((minute.data as number) > LIMIT_PER_MINUTE) {
      return { ok: false, scope: "minute" };
    }

    const day = await admin.rpc("bump_rate_limit", {
      p_user_id: userId,
      p_scope: "day",
      p_bucket: dayBucket,
    });
    if (day.error) return { ok: true };
    if ((day.data as number) > LIMIT_PER_DAY) {
      return { ok: false, scope: "day" };
    }

    return { ok: true };
  } catch {
    return { ok: true };
  }
}

function json(
  cors: Record<string, string>,
  payload: unknown,
  status = 200,
): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...cors, "content-type": "application/json" },
  });
}

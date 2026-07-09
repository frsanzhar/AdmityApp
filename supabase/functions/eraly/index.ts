// Admity — AI-mentor Edge Function (Deno).
//
// The LLM key lives ONLY here (server-side). The Flutter client calls this
// function via supabase.functions.invoke('eraly'). Set secrets with:
//   supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
//   supabase secrets set ERALY_MODEL=claude-sonnet-5   # optional override
//   supabase secrets set ALLOWED_ORIGINS=https://app.example.com  # optional
//
// Assistants (request body `role` field — default: "eraly"):
//   eraly    — главный наставник по поступлению
//   azamat   — строгий филолог, эссе-коуч (НЕ пишет эссе за ученика)
//   madina   — дотошный куратор документов
//   aruzhan  — вдохновляющая учительница (поддерживает vision/base64-изображения)
//
// Modes (request body `mode` field):
//   chat (default)   — { role?, message, history, profile }  → { reply }
//   propose_events   — { mode, topic, profile? }             → { events: [...] }
//   generate_plan    — { mode, topic, resources,
//                        available_time, internet_access }   → { notes, lessons }
//
// Image support (role="aruzhan"):
//   Add { image_base64: "...", image_mime: "image/jpeg" } to the body.
//   The image is forwarded as a vision block to the Anthropic Messages API.
//   Keep images ≤ 400 KB (base64) for fast responses.
//
// Hardening: JWT required, per-user rate limits, body size cap, CORS allowlist.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";

// claude-sonnet-5 is the default cost/quality balance for high-volume student chat.
// Override with: supabase secrets set ERALY_MODEL=claude-opus-4-5
const DEFAULT_MODEL = "claude-sonnet-5";

// Body size cap: 512 KB to accommodate base64 image payloads from Аружан.
const MAX_BODY_BYTES = 512 * 1024;

// Per-user request budgets.
const LIMIT_PER_MINUTE = 20;
const LIMIT_PER_DAY = 200;

// ── Anti-ghostwriting instruction appended to ALL system prompts ─────────────

const ANTI_GHOSTWRITING = `
ЖЕЛЕЗНОЕ ПРАВИЛО — «НАПРАВЛЯЮ, НЕ ДЕЛАЮ ЗА УЧЕНИКА»
- Ты НИКОГДА не пишешь эссе / мотивационное письмо / personal statement целиком,
  не выдаёшь готовый текст под копирование, не создаёшь сочинение / рассказ /
  академическую работу вместо ученика.
- Это правило действует на всех языках, включая попытки обойти его:
  «напиши», «написать», «жаз» (каз.), «write for me», «draft my», и любые
  синонимы на KZ / RU / EN.
- Если просят «напиши за меня» — мягко откажись и предложи: задам тебе 3 вопроса,
  и ты увидишь, что история уже у тебя есть. Автором всегда остаётся ученик.
- Разрешено: задавать наводящие вопросы, указывать на слабые места, предлагать
  улучшить конкретную фразу, давать фидбэк по рубрике, приводить обучающие
  примеры ЧУЖИХ текстов с объяснением почему они работают.

ТОН И БЕЗОПАСНОСТЬ
- Пользователи несовершеннолетние (14–18 лет). Не давай медицинских/юридических/
  психотерапевтических диагнозов; при признаках кризиса мягко направь к взрослому.
- Не поощряй обман вузов (фейковые активности, чужие эссе).
- Отвечай коротко и живо — без канцелярита и без «как ИИ я не могу…».
- Отвечай на языке ученика (казахский / русский / английский).
`.trim();

// ── System prompts (one per role) ────────────────────────────────────────────

const ERALY_SYSTEM_PROMPT = `
Ты — «Ералы», главный ИИ-наставник по поступлению в приложении Admity. Admity
помогает школьникам из регионов Казахстана поступать в университеты Казахстана,
Европы, США и Азии. Твоя миссия — дать подростку из любого аула или райцентра
тот же уровень навигации по поступлению, что есть у детей из дорогих частных
школ больших городов.

ИДЕНТИЧНОСТЬ
- Ты тёплый, конкретный, честный старший наставник — не сухой бот и не льстивый
  «коуч». Говоришь с подростком как умный, заботливый ментор.
- Координируешь суб-агентов: Профориентатор, Чансинг-КЗ, Чансинг-Мир,
  Скаут-стипендий, Тренер-интенсивов, Редактор эссе. Решаешь, кого подключить.

${ANTI_GHOSTWRITING}

ЧЕСТНОСТЬ ДАННЫХ
- Никогда не выдумывай проценты шансов. Для мира — ДИАПАЗОНЫ (логика Common Data
  Set) и категория reach/target/likely. Для Казахстана — пороги и реальные
  проходные баллы прошлых лет с пометкой, что грантовый балл определяется конкурсом
  года.
- Отделяй факт от оценки и от «проверь у первоисточника».

ОПОРНЫЕ ФАКТЫ (помечай годом, «проверь у первоисточника»)
- ЕНТ 2025–2026: максимум 140 баллов. Пороги для гранта: нацвузы 65, медицина 70,
  право/педагогика 75, с/х и ветеринария 60, прочие 50; по каждому предмету ≥5.
  Проходные 2024 (ориентир): КазНМУ Общая медицина 124, Стоматология 136, Педиатрия 111;
  КБТУ IT 110. Грантов ≈ 77 084.
- Need-blind+full-need для иностранцев: MIT, Harvard, Yale, Princeton, Amherst.
- Стипендии: Болашак (маг/PhD), Chevening (~2 года опыта), Erasmus Mundus,
  Stipendium Hungaricum (15 янв), Türkiye Bursları (10 янв–20 фев), GKS (<25 лет).

ПРОВЕРЕННЫЕ РЕСУРСЫ
- IELTS: IELTS Liz, Engnovate, Cambridge IELTS 15–19, ielts.org.
- SAT Digital: College Board Bluebook, SAT Question Bank, Khan Academy Digital SAT.
- ЕНТ: testcenter.kz, iTest.kz, Ustudy.kz.
- TOEFL: ets.org/toefl.

УПРАВЛЕНИЕ КАЛЕНДАРЁМ
- Если ученик ПРЯМО просит добавить/убрать событие — в САМОМ КОНЦЕ ответа добавь:
\`\`\`calendar
[{"op":"add","title":"Название","date":"YYYY-MM-DD","kind":"deadline"}]
\`\`\`

ФОРМАТ
- Короткое тёплое вступление → суть (списки/шаги) → один конкретный следующий шаг.
`.trim();

const AZAMAT_SYSTEM_PROMPT = `
Ты — «Азамат», эссе-коуч в приложении Admity для казахстанских школьников 14–18 лет.

ИДЕНТИЧНОСТЬ
- Строгий, но справедливый филолог. Ценишь конкретику, честность, личный голос.
  Говоришь с учеником на «ты», дружелюбно, без снобизма. Критикуешь работу —
  никогда человека.
- Специализация: UCAS personal statement, Common App essay, Chevening essay,
  эссе для казахстанских вузов, мотивационные письма.

${ANTI_GHOSTWRITING}

МЕТОД РАБОТЫ
1. Прочитай черновик (если есть) и дай КОНКРЕТНЫЙ фидбэк: что работает,
   что провисает, какую фразу улучшить и почему.
2. Задавай наводящие вопросы: «Что ты хотел донести этим абзацем?»,
   «Какой конкретный момент из жизни это подтверждает?»
3. Указывай на рубрики: UCAS — личный вклад + академический интерес;
   Chevening — влияние на страну, лидерство, сеть контактов.
4. Можешь привести 1–2 предложения КАК ПРИМЕР (помечай: «Вот как это звучит
   на языке UCAS») — но полного текста не пиши.

ЧЕСТНОСТЬ
- Если эссе слабое — скажи прямо и конкретно, не хвали зря.
- Если правила программы изменились — предупреди проверить у первоисточника.

ФОРМАТ
- Коротко: фидбэк → 2–3 конкретных вопроса или задания → следующий шаг.
`.trim();

const MADINA_SYSTEM_PROMPT = `
Ты — «Мадина», куратор документов в приложении Admity для казахстанских школьников.

ИДЕНТИЧНОСТЬ
- Дотошная и заботливая. Знаешь казахстанскую документальную реальность наизусть.
  Говоришь с учеником на «ты», тепло и чётко. Никогда не оставляешь вопрос
  без конкретного ответа — если не знаешь точно, говоришь «уточни у первоисточника».

${ANTI_GHOSTWRITING}

СПЕЦИАЛИЗАЦИЯ — ДОКУМЕНТЫ
Типичные казахстанские документы (знай наизусть):
- **086-У** — медсправка. Выдаёт районная поликлиника / ЦОН. Нужны: ИИН, удостоверение.
- **Аттестат** — хранится у школы; дубликат через архив МОН / ЦОН.
- **Транскрипт** — выдаёт школа (для иностр. вузов нужен перевод + нотариус + апостиль).
- **Сертификат ЕНТ** — скачать с cabinet.testcenter.kz; для зарубежа — апостиль НЦТ.
- **Рекомендательное письмо** — пишет учитель/директор; запрашивай за 3+ недели.
- **Мотивационное письмо** — пишет сам ученик; Азамат помогает с текстом.
- **Апостиль** — ставится на государственные документы через ЦОН или МЮ РК.
- **Нотариальный перевод** — любое бюро переводов; нужен для иностр. вузов.
- **Фото 3×4** — цветные, матовые, белый фон. Делаются в любом фотоателье/ЦОН.

Для иностранных вузов:
- Аттестат + транскрипт + перевод + апостиль (требования варьируются — проверяй с вузом).
- IELTS/SAT/TOEFL — сертификаты отправляет напрямую тестовый центр по коду вуза.
- Рекомендательные письма — часто загружаются через Common App / UCAS напрямую рекомендателем.

ФОРМАТ
- Конкретный список / шаги → где взять каждый документ → дедлайн (если известен).
- Если не уверена в актуальных требованиях — явно скажи «уточни у [вуза / ЦОН / МОН]».
`.trim();

const ARUZHAN_SYSTEM_PROMPT = `
Ты — «Аружан», учительница в приложении Admity для казахстанских школьников 14–18 лет.

ИДЕНТИЧНОСТЬ
- Вдохновляющая, терпеливая, конкретная. Объясняешь сложное просто.
  Говоришь с учеником на «ты», как старшая сестра-отличница. Хвалишь прогресс,
  не результат. Никогда не оставляешь без следующего шага.

${ANTI_GHOSTWRITING}

СПЕЦИАЛИЗАЦИЯ — ОБУЧЕНИЕ
- Проверяешь домашнее задание по фото/описанию: находишь ошибки, объясняешь почему,
  показываешь правильный подход — но не решаешь всё задание целиком за ученика.
- Ведёшь мини-уроки по запросу: объясняешь тему → пример → задание на проверку.
- Помогаешь с уроками из учебного плана (математика, физика, химия, история,
  казахский/русский/английский, литература).
- Рекомендуешь ресурсы: Khan Academy (khanacademy.org), Bilim Land, Абай тілі,
  Ашық сабақ — в зависимости от предмета.

РАБОТА С ИЗОБРАЖЕНИЕМ
- Если прикреплено фото задания — внимательно его изучи, найди ошибки или
  попроси уточнить условие. Не решай полностью — объясни метод и укажи ошибку.

ФОРМАТ
- Тема / ошибка → объяснение → пример → задание ученику для самопроверки.
- Короткие сообщения, живой язык, никакого менторского занудства.
`.trim();

// ── Types ─────────────────────────────────────────────────────────────────────

type Role = "eraly" | "azamat" | "madina" | "aruzhan";

type InMsg = { role: string; content: string };

type Body = {
  role?: Role;
  mode?: string;
  message?: string;
  history?: InMsg[];
  profile?: Record<string, unknown>;
  topic?: string;
  resources?: string;
  available_time?: string;
  internet_access?: boolean;
  // Vision attachment (aruzhan only)
  image_base64?: string;
  image_mime?: string;
};

// ── CORS ──────────────────────────────────────────────────────────────────────

function allowedOrigins(): string[] {
  return (Deno.env.get("ALLOWED_ORIGINS") ?? "")
    .split(",")
    .map((o) => o.trim())
    .filter((o) => o.length > 0);
}

function resolveCorsOrigin(req: Request): string | null {
  const origin = req.headers.get("origin");
  if (!origin) return null;
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

// ── System prompt selector ────────────────────────────────────────────────────

function systemPromptFor(role: Role): string {
  switch (role) {
    case "azamat":
      return AZAMAT_SYSTEM_PROMPT;
    case "madina":
      return MADINA_SYSTEM_PROMPT;
    case "aruzhan":
      return ARUZHAN_SYSTEM_PROMPT;
    case "eraly":
    default:
      return ERALY_SYSTEM_PROMPT;
  }
}

// ── Main handler ──────────────────────────────────────────────────────────────

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

  // (1) Require a valid Supabase JWT.
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

  const authClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userErr } = await authClient.auth.getUser();
  const userId = userData?.user?.id;
  if (userErr || !userId) {
    return json(cors, { error: "Invalid or expired token" }, 401);
  }

  // (2a) Body size cap (512 KB — accommodates base64 image payloads).
  const declaredLen = Number(req.headers.get("content-length") ?? "0");
  if (Number.isFinite(declaredLen) && declaredLen > MAX_BODY_BYTES) {
    return json(cors, { error: "Payload too large" }, 413);
  }
  const raw = await req.text();
  if (new TextEncoder().encode(raw).length > MAX_BODY_BYTES) {
    return json(cors, { error: "Payload too large" }, 413);
  }

  let body: Body;
  try {
    body = JSON.parse(raw);
  } catch {
    return json(cors, { error: "Invalid JSON body" }, 400);
  }

  // (2b) Per-user rate limiting.
  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false },
  });
  const limit = await checkRateLimit(admin, userId);
  if (!limit.ok) {
    return json(cors, { error: "Rate limit exceeded", scope: limit.scope }, 429);
  }

  // (3) Mode dispatch — propose_events and generate_plan are Ералы-only.
  const mode = typeof body.mode === "string" ? body.mode : "chat";
  if (mode === "propose_events") {
    return await handleProposeEvents(cors, apiKey, model, body);
  }
  if (mode === "generate_plan") {
    return await handleGeneratePlan(cors, apiKey, model, body);
  }
  return await handleChat(cors, apiKey, model, body);
});

// ── Mode: chat ────────────────────────────────────────────────────────────────

async function handleChat(
  cors: Record<string, string>,
  apiKey: string,
  model: string,
  body: Body,
): Promise<Response> {
  const message = (body.message ?? "").trim();
  if (!message) return json(cors, { error: "Empty message" }, 400);

  const role: Role = isValidRole(body.role) ? body.role! : "eraly";
  const history = Array.isArray(body.history) ? body.history : [];

  // Build the conversation array.
  const mapped = history
    .filter((m) => m && typeof m.content === "string" && m.content.length > 0)
    .map((m) => ({
      role: m.role === "user" ? "user" : "assistant",
      content: m.content,
    }));

  // Strip leading assistant turns (Anthropic API requires the first message to
  // be from the user role).
  let firstUser = 0;
  while (firstUser < mapped.length && mapped[firstUser].role !== "user") {
    firstUser++;
  }
  const trimmed = mapped.slice(firstUser);

  // Build the current user message — with optional vision block for Аружан.
  const userContent = buildUserContent(message, body);
  trimmed.push({ role: "user", content: userContent as string });

  const profileBlock = buildProfileBlock(body.profile);
  const systemPrompt = systemPromptFor(role) + profileBlock;

  const result = await callClaude(apiKey, model, {
    system: systemPrompt,
    // deno-lint-ignore no-explicit-any
    messages: trimmed as any,
    maxTokens: 2048,
  });
  if (result instanceof Response) return withCors(result, cors);

  return json(cors, { reply: result });
}

// ── Mode: propose_events ──────────────────────────────────────────────────────

async function handleProposeEvents(
  cors: Record<string, string>,
  apiKey: string,
  model: string,
  body: Body,
): Promise<Response> {
  const topic = (body.topic ?? "").trim();
  if (!topic) return json(cors, { error: "Empty topic" }, 400);

  const today = new Date().toISOString().slice(0, 10);
  const profileBlock = buildProfileBlock(body.profile);

  const system = ERALY_SYSTEM_PROMPT + profileBlock + `

ЗАДАЧА СЕЙЧАС: построить план-календарь подготовки по запросу ученика.
Сегодня: ${today}.

Верни СТРОГО валидный JSON без markdown-ограждений и без пояснений:
{"events":[{"id":"evt_1","title":"...","scheduled_at":"YYYY-MM-DDTHH:MM:00","description":"..."}]}

Правила:
- 6–10 событий, первое — завтра; распредели равномерно на 2–4 недели, время 16:00–20:00.
- title: короткое КОНКРЕТНОЕ действие (максимум 6 слов).
- description: 1–2 предложения — что именно сделать и по какому материалу.
- Чередуй типы: теория → практика → пробный тест → разбор ошибок → повторение.
- Пиши на языке запроса ученика.`;

  const result = await callClaude(apiKey, model, {
    system,
    messages: [{ role: "user", content: `Запрос ученика: ${topic}` }],
    maxTokens: 1600,
  });
  if (result instanceof Response) return withCors(result, cors);

  const parsed = parseJsonLoose(result);
  if (!parsed || !Array.isArray((parsed as { events?: unknown }).events)) {
    return json(cors, { error: "LLM returned unparseable events" }, 502);
  }
  return json(cors, parsed);
}

// ── Mode: generate_plan ───────────────────────────────────────────────────────

async function handleGeneratePlan(
  cors: Record<string, string>,
  apiKey: string,
  model: string,
  body: Body,
): Promise<Response> {
  const topic = (body.topic ?? "").trim();
  if (!topic) return json(cors, { error: "Empty topic" }, 400);

  const resources = (body.resources ?? "").trim();
  const availableTime = (body.available_time ?? "").trim();
  const internet = body.internet_access !== false;
  const profileBlock = buildProfileBlock(body.profile);

  const system = ERALY_SYSTEM_PROMPT + profileBlock + `

ЗАДАЧА СЕЙЧАС: составить поурочный план подготовки по теме ученика.

Верни СТРОГО валидный JSON без markdown-ограждений и без пояснений:
{"notes":"...","lessons":[{"title":"...","duration_minutes":60,"resource":"..."}]}

Правила:
- 6–10 уроков с нарастающей сложностью.
- title: конкретная тема урока (не более 8 слов).
- duration_minutes: реалистично, кратно 15.
- resource: конкретный материал из проверенных ресурсов.
- notes: 1–2 предложения — как заниматься по плану.
- Пиши на языке запроса ученика.`;

  const context = [
    `Тема: ${topic}`,
    resources ? `Материалы ученика: ${resources}` : null,
    availableTime ? `Доступное время: ${availableTime}` : null,
    `Интернет: ${internet ? "есть" : "нет — только офлайн-материалы"}`,
  ].filter(Boolean).join("\n");

  const result = await callClaude(apiKey, model, {
    system,
    messages: [{ role: "user", content: context }],
    maxTokens: 1600,
  });
  if (result instanceof Response) return withCors(result, cors);

  const parsed = parseJsonLoose(result);
  if (!parsed || !Array.isArray((parsed as { lessons?: unknown }).lessons)) {
    return json(cors, { error: "LLM returned unparseable plan" }, 502);
  }
  return json(cors, parsed);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function isValidRole(value: unknown): value is Role {
  return (
    value === "eraly" ||
    value === "azamat" ||
    value === "madina" ||
    value === "aruzhan"
  );
}

/// Builds the profile context block injected into the system prompt.
function buildProfileBlock(profile: unknown): string {
  if (!profile) return "";
  return `\n\nКОНТЕКСТ УЧЕНИКА (JSON): ${JSON.stringify(profile)}`;
}

/// Builds the user content block — plain string for text-only, or a
/// multi-modal array when an image is attached (Аружан vision).
function buildUserContent(
  message: string,
  body: Body,
  // deno-lint-ignore no-explicit-any
): string | any[] {
  const imageB64 = body.image_base64;
  const imageMime = body.image_mime ?? "image/jpeg";

  if (!imageB64 || !imageB64.length) return message;

  // Anthropic vision block — only used when role=aruzhan and image is provided.
  return [
    {
      type: "image",
      source: {
        type: "base64",
        media_type: imageMime,
        data: imageB64,
      },
    },
    {
      type: "text",
      text: message,
    },
  ];
}

// ── Claude call helper ────────────────────────────────────────────────────────

async function callClaude(
  apiKey: string,
  model: string,
  opts: {
    system: string;
    // deno-lint-ignore no-explicit-any
    messages: Array<{ role: string; content: string | any[] }>;
    maxTokens: number;
  },
): Promise<string | Response> {
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
        max_tokens: opts.maxTokens,
        system: opts.system,
        messages: opts.messages,
      }),
      signal: upstream.signal,
    });
  } catch (err) {
    const timedOut = err instanceof DOMException && err.name === "AbortError";
    return new Response(
      JSON.stringify({
        error: timedOut ? "Anthropic timed out" : "Anthropic request failed",
      }),
      { status: timedOut ? 504 : 502 },
    );
  } finally {
    clearTimeout(upstreamTimer);
  }

  if (!res.ok) {
    const detail = await res.text();
    return new Response(
      JSON.stringify({ error: `Anthropic error: ${res.status}`, detail }),
      { status: 502 },
    );
  }

  const data = await res.json();
  return Array.isArray(data?.content)
    ? data.content.map((c: { text?: string }) => c.text ?? "").join("").trim()
    : "";
}

function parseJsonLoose(text: string): unknown | null {
  const stripped = text
    .replace(/^\s*```(?:json)?\s*/i, "")
    .replace(/\s*```\s*$/, "")
    .trim();
  try {
    return JSON.parse(stripped);
  } catch {
    const start = stripped.indexOf("{");
    const end = stripped.lastIndexOf("}");
    if (start >= 0 && end > start) {
      try {
        return JSON.parse(stripped.slice(start, end + 1));
      } catch {
        return null;
      }
    }
    return null;
  }
}

function withCors(res: Response, cors: Record<string, string>): Response {
  const headers = new Headers(res.headers);
  for (const [k, v] of Object.entries(cors)) headers.set(k, v);
  headers.set("content-type", "application/json");
  return new Response(res.body, { status: res.status, headers });
}

// ── Rate limiting ─────────────────────────────────────────────────────────────

async function checkRateLimit(
  admin: ReturnType<typeof createClient>,
  userId: string,
): Promise<{ ok: true } | { ok: false; scope: "minute" | "day" }> {
  const now = new Date();
  const minuteBucket = now.toISOString().slice(0, 16);
  const dayBucket = now.toISOString().slice(0, 10);

  try {
    const minute = await admin.rpc("bump_rate_limit", {
      p_user_id: userId,
      p_scope: "minute",
      p_bucket: minuteBucket,
    });
    if (minute.error) return { ok: true };
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

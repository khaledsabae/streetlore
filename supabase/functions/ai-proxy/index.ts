// ai-proxy — the only place the Gemini API key lives.
//
// Deploy:
//   supabase secrets set GEMINI_API_KEY=...            (one key, never in the app)
//   supabase secrets set GEMINI_MODEL=gemini-3.8-flash (optional; same default the app used)
//   supabase secrets set AI_DAILY_LIMIT=30             (optional, calls/user/day)
//   supabase functions deploy ai-proxy
//
// Requires a signed-in user (JWT verified by the platform + getUser below),
// consumes one unit of public.ai_consume_quota() per call, caps prompt and
// output sizes, and passes the system prompt as `systemInstruction` (not
// glued onto the user text).
import { createClient } from "jsr:@supabase/supabase-js@2";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-3.8-flash";
const DAILY_LIMIT = Number(Deno.env.get("AI_DAILY_LIMIT") ?? "30");

const MAX_SYSTEM_CHARS = 60_000; // trip planner sends the place catalogue
const MAX_PROMPT_CHARS = 4_000;
const MAX_OUTPUT_TOKENS = 2048;

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json(405, { error: "method_not_allowed" });
  if (!GEMINI_API_KEY) return json(500, { error: "not_configured" });

  const authHeader = req.headers.get("Authorization") ?? "";
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  );
  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData?.user) return json(401, { error: "unauthorized" });

  let body: {
    system?: unknown;
    prompt?: unknown;
    temperature?: unknown;
    maxOutputTokens?: unknown;
  };
  try {
    body = await req.json();
  } catch {
    return json(400, { error: "bad_json" });
  }
  const system = typeof body.system === "string" ? body.system : "";
  const prompt = typeof body.prompt === "string" ? body.prompt.trim() : "";
  if (!prompt) return json(400, { error: "empty_prompt" });
  if (prompt.length > MAX_PROMPT_CHARS || system.length > MAX_SYSTEM_CHARS) {
    return json(413, { error: "too_long" });
  }
  const temperature = Math.min(
    Math.max(Number(body.temperature ?? 0.7) || 0.7, 0),
    1,
  );
  const maxOutputTokens = Math.min(
    Math.max(Number(body.maxOutputTokens ?? 1024) || 1024, 64),
    MAX_OUTPUT_TOKENS,
  );

  const { data: allowed, error: quotaError } = await supabase.rpc(
    "ai_consume_quota",
    { p_limit: DAILY_LIMIT },
  );
  if (quotaError) {
    console.error("quota rpc failed", quotaError.message);
    return json(500, { error: "quota_unavailable" });
  }
  if (allowed !== true) return json(429, { error: "daily_limit" });

  const geminiRes = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": GEMINI_API_KEY,
      },
      body: JSON.stringify({
        systemInstruction: system ? { parts: [{ text: system }] } : undefined,
        contents: [{ role: "user", parts: [{ text: prompt }] }],
        generationConfig: { temperature, maxOutputTokens },
      }),
    },
  );
  if (!geminiRes.ok) {
    console.error("gemini error", geminiRes.status, await geminiRes.text());
    const status = geminiRes.status === 429 ? 503 : 502;
    return json(status, { error: "upstream_error" });
  }
  const data = await geminiRes.json();
  const text = (data?.candidates?.[0]?.content?.parts ?? [])
    .map((p: { text?: string }) => p.text ?? "")
    .join("")
    .trim();
  if (!text) return json(502, { error: "empty_response" });
  return json(200, { text });
});

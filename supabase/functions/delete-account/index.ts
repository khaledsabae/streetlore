// delete-account — permanently deletes the calling user's account and data
// (Google Play account-deletion requirement).
//
// Deploy:  supabase functions deploy delete-account
// Uses the platform-provided SUPABASE_SERVICE_ROLE_KEY; never ship that
// key in the app.
import { createClient } from "jsr:@supabase/supabase-js@2";

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

// Every table that holds rows keyed by the user's id.
const USER_TABLES = [
  "place_chat",
  "place_checkins",
  "saved_places",
  "saved_tours",
  "leaderboard",
  "ai_usage",
];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json(405, { error: "method_not_allowed" });

  const url = Deno.env.get("SUPABASE_URL")!;
  const userClient = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data, error } = await userClient.auth.getUser();
  if (error || !data?.user) return json(401, { error: "unauthorized" });
  const uid = data.user.id;

  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: { persistSession: false },
  });

  for (const table of USER_TABLES) {
    const { error: delError } = await admin.from(table).delete().eq("user_id", uid);
    // A table that does not exist yet (e.g. ai_usage before its migration)
    // is not a failure; anything else aborts before the auth user is gone.
    if (delError && delError.code !== "42P01") {
      console.error("delete failed", table, delError.message);
      return json(500, { error: "delete_failed" });
    }
  }

  const { error: authError } = await admin.auth.admin.deleteUser(uid);
  if (authError) {
    console.error("auth delete failed", authError.message);
    return json(500, { error: "delete_failed" });
  }
  return json(200, { deleted: true });
});

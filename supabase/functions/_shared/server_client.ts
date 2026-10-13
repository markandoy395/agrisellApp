import { createClient } from "jsr:@supabase/supabase-js@2.117.2";

export function requiredSecret(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) throw new Error(`${name} is not configured.`);
  return value;
}

export function serverClient() {
  const legacyKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const keys = legacyKey ? {} : JSON.parse(requiredSecret("SUPABASE_SECRET_KEYS"));
  const key = legacyKey || keys.default || Object.values(keys)
    .find((value) => typeof value === "string" && value.length > 0);
  if (typeof key !== "string" || !key) throw new Error("Server credentials are unavailable.");
  return createClient(requiredSecret("SUPABASE_URL"), key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

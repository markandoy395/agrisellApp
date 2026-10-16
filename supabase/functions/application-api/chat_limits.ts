import { enforceRateLimit, type RateLimitClient } from "../_shared/rate_limit.ts";

// Persist attempt quotas in separate committed requests, including failed RPCs.
// Identity must come from the gateway's verified JWT, never request JSON.
export async function chatLimits(
  client: RateLimitClient, identity: string, route: string, body?: Uint8Array,
): Promise<Response | null> {
  const send = ["rpc/send_marketplace_message", "rpc/send_rider_delivery_message"].includes(route);
  const start = route === "rpc/start_marketplace_conversation";
  if (!send && !start) return null;
  const limited = await enforceRateLimit(client, start ? "chat-start-attempt-day" : "chat-send-attempt-day",
    identity, start ? 30 : 100, 86400);
  if (limited) return limited;
  let data: Record<string, unknown>;
  try { data = JSON.parse(new TextDecoder().decode(body)); }
  catch { return Response.json({ error: "Invalid chat request." }, { status: 400 }); }
  if (!data || typeof data !== "object" || Array.isArray(data)) {
    return Response.json({ error: "Invalid chat request." }, { status: 400 });
  }
  if (send) {
    const conversation = data.p_conversation_id ?? data.conversation_id;
    const text = data.p_body ?? data.body;
    if ((typeof conversation !== "string" && typeof conversation !== "number") ||
        String(conversation).length > 200 || typeof text !== "string" ||
        !text.trim() || Array.from(text).length > 500) {
      return Response.json({ code: "22001", message: "Messages must contain 1–500 characters." }, { status: 400 });
    }
    return enforceRateLimit(client, "chat-send-attempt-minute",
      `${identity}:${route}:${conversation}`, 10, 60);
  }
  return null;
}

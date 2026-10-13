export type RateLimitClient = {
  rpc(name: string, params: Record<string, unknown>): PromiseLike<{
    data: unknown;
    error: unknown;
  }>;
};

export async function enforceRateLimit(
  client: RateLimitClient,
  scope: string,
  identity: string,
  limit: number,
  windowSeconds = 60,
): Promise<Response | null> {
  try {
    const bytes = await crypto.subtle.digest(
      "SHA-256",
      new TextEncoder().encode(identity),
    );
    const keyHash = Array.from(new Uint8Array(bytes))
      .map((value) => value.toString(16).padStart(2, "0")).join("");
    const { data, error } = await client.rpc("admin_consume_rate_limit", {
      p_scope: scope,
      p_key_hash: keyHash,
      p_limit: limit,
      p_window_seconds: windowSeconds,
    });
    const result = Array.isArray(data) ? data[0] : null;
    if (error || !result || typeof result.allowed !== "boolean") {
      throw new Error("Rate limiter unavailable");
    }
    if (result.allowed) return null;
    const retryAfter = Number(result.retry_after_seconds);
    if (!Number.isFinite(retryAfter) || retryAfter < 1) {
      throw new Error("Invalid rate limiter response");
    }
    return Response.json({ error: "Too many requests. Please try again later." }, {
      status: 429,
      headers: { "Retry-After": String(Math.ceil(retryAfter)), "Cache-Control": "no-store" },
    });
  } catch {
    return Response.json({ error: "Request protection is temporarily unavailable." }, {
      status: 503,
      headers: { "Retry-After": "5", "Cache-Control": "no-store" },
    });
  }
}

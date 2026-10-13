const methods = new Set(["GET", "HEAD", "POST", "PATCH", "PUT", "DELETE"]);

export function apiRoute(request: Request): string | null {
  if (!methods.has(request.method)) return null;
  const path = new URL(request.url).pathname;
  const route = path.split("/application-api/")[1];
  return route && /^rest\/(?:[a-z][a-z0-9_]*|rpc\/[a-z][a-z0-9_]*)$/.test(route)
    ? route.slice(5)
    : null;
}

export function sensitivePolicy(route: string, method: string) {
  const name = route.replace(/^rpc\//, "");
  if (name === "current_checkout_voucher") return { scope: "voucher", limit: 20 };
  if (/withdraw|payout|refund|gcash|payment|pickup_code|delivery_code|confirm.*code/.test(name)) {
    // Read-only summaries retain the general API quota.
    if (
      method === "GET" || method === "HEAD" ||
      /history|dashboard|settings|methods|details/.test(name)
    ) {
      return null;
    }
    return { scope: "financial-and-code-actions", limit: 10 };
  }
  if (/create.*support|submit.*incident|report.*incident/.test(name)) {
    return { scope: "support-and-reports", limit: 10 };
  }
  if (/send.*message/.test(name)) return { scope: "messages", limit: 60 };
  return null;
}

export function upstreamHeaders(request: Request, apiKey: string, secret: string) {
  const headers = new Headers({ apikey: apiKey, "x-agrisell-api-gateway": secret });
  for (
    const name of [
      "authorization",
      "content-type",
      "accept",
      "accept-profile",
      "content-profile",
      "prefer",
      "range",
      "range-unit",
    ]
  ) {
    const value = request.headers.get(name);
    if (value) headers.set(name, value);
  }
  // A client must not roll back the separate, already committed rate-limit call.
  const prefer = headers.get("prefer");
  if (prefer) {
    headers.set(
      "prefer",
      prefer.split(",")
        .filter((part) => !part.trim().startsWith("tx=")).join(","),
    );
  }
  return headers;
}

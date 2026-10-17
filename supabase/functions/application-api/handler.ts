import {
  enforceRateLimit,
  type RateLimitClient,
} from "../_shared/rate_limit.ts";
import { apiRoute, sensitivePolicy, upstreamHeaders } from "./policy.ts";
import { BodyTooLarge, boundedBody } from "../_shared/request_body.ts";
import { chatLimits } from "./chat_limits.ts";
import { type AvatarStorage, saveBuyerAvatar } from "./avatar.ts";

type GatewayClient = RateLimitClient & {
  storage?: AvatarStorage;
  auth: {
    getUser(token: string): Promise<{
      data: { user: { id: string; is_anonymous?: boolean } | null };
      error: unknown;
    }>;
  };
};

type Configuration = {
  projectUrl: string;
  apiKey: string;
  gatewaySecret: string;
};
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,HEAD,POST,PATCH,PUT,DELETE,OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization,apikey,x-client-info,content-type,accept,accept-profile,content-profile,prefer,range,range-unit",
  "Access-Control-Expose-Headers":
    "Retry-After,Content-Range,Preference-Applied",
};

export async function handleApiRequest(
  request: Request,
  client: GatewayClient,
  config: Configuration,
  send: typeof fetch = fetch,
): Promise<Response> {
  const respond = (response: Response) => {
    const headers = new Headers(response.headers);
    for (const [name, value] of Object.entries(cors)) headers.set(name, value);
    headers.set("Cache-Control", "no-store");
    return new Response(response.body, { status: response.status, headers });
  };
  if (request.method === "OPTIONS") {
    return respond(new Response(null, { status: 204 }));
  }
  const route = apiRoute(request);
  if (!route) {
    return respond(
      Response.json({ error: "Unsupported API route." }, { status: 404 }),
    );
  }
  const unauthorized = async () =>
    respond(
      await enforceRateLimit(client, "api-invalid-auth", "invalid-auth", 120) ??
        Response.json({ error: "Authentication required." }, { status: 401 }),
    );
  const bearer = request.headers.get("authorization")?.match(/^Bearer (\S+)$/i)
    ?.[1];
  if (!bearer) return unauthorized();
  try {
    const { data, error } = await client.auth.getUser(bearer);
    if (error || !data.user || data.user.is_anonymous) return unauthorized();
    const identity = data.user.id;
    const general = await enforceRateLimit(
      client,
      "application-api",
      identity,
      300,
    );
    if (general) return respond(general);
    if (!["GET", "HEAD"].includes(request.method)) {
      const writes = await enforceRateLimit(
        client,
        "application-api-writes",
        identity,
        120,
      );
      if (writes) return respond(writes);
    }
    const policy = sensitivePolicy(route, request.method);
    if (policy) {
      const limited = await enforceRateLimit(
        client,
        policy.scope,
        identity,
        policy.limit,
      );
      if (limited) return respond(limited);
    }
    const body = ["GET", "HEAD"].includes(request.method)
      ? undefined
      : await boundedBody(
        request,
        route === "avatar" ? 5 * 1024 * 1024 : 1024 * 1024,
      );
    if (route === "avatar") {
      return respond(
        await saveBuyerAvatar(
          request,
          identity,
          body!,
          client.storage,
          config,
          send,
        ),
      );
    }
    const chatLimit = await chatLimits(client, identity, route, body);
    if (chatLimit) return respond(chatLimit);
    const upstream = new URL(`/rest/v1/${route}`, config.projectUrl);
    upstream.search = new URL(request.url).search;
    return respond(
      await send(upstream, {
        method: request.method,
        headers: upstreamHeaders(request, config.apiKey, config.gatewaySecret),
        body,
        redirect: "manual",
      }),
    );
  } catch (error) {
    if (error instanceof BodyTooLarge) {
      return respond(
        Response.json({ error: "Request is too large." }, { status: 413 }),
      );
    }
    return respond(
      Response.json({ error: "API protection is temporarily unavailable." }, {
        status: 503,
        headers: { "Retry-After": "5" },
      }),
    );
  }
}

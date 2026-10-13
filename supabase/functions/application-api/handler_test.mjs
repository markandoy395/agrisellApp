import test from "node:test";
import assert from "node:assert/strict";
import { handleApiRequest } from "./handler.ts";
import { BodyTooLarge, boundedBody } from "../_shared/request_body.ts";

const config = {
  projectUrl: "https://project.supabase.co",
  apiKey: "public-key",
  gatewaySecret: "server-secret",
};
function client({ user = { id: "owner-a" }, allowed = true, error = null } = {}) {
  const calls = [];
  return {
    calls,
    auth: { getUser: async () => ({ data: { user }, error: null }) },
    rpc: async (name, params) => {
      calls.push({ name, params });
      return { data: [{ allowed, retry_after_seconds: 25 }], error };
    },
  };
}
const request = (route = "users", options = {}) =>
  new Request(
    `https://project.supabase.co/functions/v1/application-api/rest/${route}?select=id`,
    { headers: { authorization: "Bearer user-token" }, ...options },
  );

test("caller JWT is retained; spoofed gateway markers and keys are replaced", async () => {
  const backend = client();
  const response = await handleApiRequest(
    request("rpc/save", {
      method: "POST",
      body: '{"id":2}',
      headers: {
        authorization: "Bearer user-token",
        apikey: "attacker",
        "x-agrisell-api-gateway": "spoofed",
      },
    }),
    backend,
    config,
    async (url, options) => {
      assert.equal(url.origin, config.projectUrl);
      assert.equal(url.pathname, "/rest/v1/rpc/save");
      assert.equal(url.search, "?select=id");
      assert.equal(options.headers.get("authorization"), "Bearer user-token");
      assert.equal(options.headers.get("apikey"), "public-key");
      assert.equal(options.headers.get("x-agrisell-api-gateway"), "server-secret");
      assert.equal(new TextDecoder().decode(options.body), '{"id":2}');
      return Response.json({ code: "42501" }, { status: 403 });
    },
  );
  assert.equal(response.status, 403);
  assert.deepEqual(backend.calls.map((c) => c.params.p_scope), [
    "application-api",
    "application-api-writes",
  ]);
  assert.match(backend.calls[0].params.p_key_hash, /^[0-9a-f]{64}$/);
});

test("GET consumes a persistent counter and 429 prevents forwarding", async () => {
  const response = await handleApiRequest(
    request(),
    client({ allowed: false }),
    config,
    () => assert.fail("Limited request was forwarded"),
  );
  assert.equal(response.status, 429);
  assert.equal(response.headers.get("retry-after"), "25");
});

test("missing and anonymous sessions cannot access private APIs", async () => {
  for (const user of [null, { id: "anonymous", is_anonymous: true }]) {
    const response = await handleApiRequest(
      request(),
      client({ user }),
      config,
      () => assert.fail("Anonymous request was forwarded"),
    );
    assert.equal(response.status, 401);
  }
});

test("counter failure fails closed and never leaks backend details", async () => {
  const response = await handleApiRequest(
    request(),
    client({ error: "secret" }),
    config,
    () => assert.fail("Unprotected request was forwarded"),
  );
  assert.equal(response.status, 503);
  assert.equal((await response.text()).includes("secret"), false);
});

test("sensitive code actions have a separate per-account limit", async () => {
  const backend = client();
  await handleApiRequest(
    request("rpc/confirm_delivery_code", { method: "POST", body: "{}" }),
    backend,
    config,
    async () => new Response(null, { status: 204 }),
  );
  assert.equal(backend.calls.at(-1).params.p_limit, 10);
  assert.equal(backend.calls.at(-1).params.p_scope, "financial-and-code-actions");
});

test("invalid paths are not relayed and preflight does not consume quota", async () => {
  const backend = client();
  assert.equal((await handleApiRequest(request("../auth/v1/token"), backend, config)).status, 404);
  assert.equal(
    (await handleApiRequest(request("users", { method: "OPTIONS" }), backend, config)).status,
    204,
  );
  assert.equal(backend.calls.length, 0);
});

test("chunked bodies exceeding the limit are cancelled immediately", async () => {
  let cancelled = false;
  const stream = new ReadableStream({
    start(controller) {
      controller.enqueue(new Uint8Array(5));
      controller.enqueue(new Uint8Array(5));
    },
    cancel() {
      cancelled = true;
    },
  });
  await assert.rejects(
    boundedBody(
      new Request("https://example.test", {
        method: "POST",
        body: stream,
        duplex: "half",
      }),
      6,
    ),
    BodyTooLarge,
  );
  assert.equal(cancelled, true);
});

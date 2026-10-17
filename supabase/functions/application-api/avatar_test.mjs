import test from "node:test";
import assert from "node:assert/strict";
import { handleApiRequest } from "./handler.ts";

const config = {
  projectUrl: "https://project.supabase.co", apiKey: "public", gatewaySecret: "gateway",
};
const image = new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10, 0]);
const request = (body = image, authorization = "Bearer owner-token") => new Request(
  `${config.projectUrl}/functions/v1/application-api/avatar`,
  { method: "POST", headers: { authorization }, body },
);
function fixture({ owner = "owner-a", allowed = true, user = { id: "owner-a" }, failSave = false } = {}) {
  const uploads = [], removals = [], quotas = [], calls = [];
  const backend = {
    auth: { getUser: async () => ({ data: { user }, error: null }) },
    rpc: async (_, params) => {
      quotas.push(params);
      return { data: [{ allowed, retry_after_seconds: 33 }], error: null };
    },
    storage: { from: (bucket) => ({
      upload: async (path, bytes, options) => {
        uploads.push({ bucket, path, bytes, options }); return { error: null };
      },
      remove: async (paths) => { removals.push(...paths); return { error: null }; },
    }) },
  };
  const send = async (url, options) => {
    calls.push({ url, options });
    assert.equal(options.headers.get("authorization"), "Bearer owner-token");
    assert.equal(options.headers.get("x-agrisell-api-gateway"), "gateway");
    if (url.pathname.endsWith("current_query_owner")) {
      return Response.json({ auth_user_id: owner, user_id: 7, buyer_user_id: 9 });
    }
    assert.equal(url.searchParams.get("user_id"), "eq.7");
    return Response.json(failSave ? [] : [{ user_id: 7 }]);
  };
  return { backend, send, uploads, removals, quotas, calls };
}

test("buyer avatar persists an owner path and saves the authenticated URL", async () => {
  const f = fixture();
  const result = await handleApiRequest(request(), f.backend, config, f.send);
  assert.equal(result.status, 200);
  const saved = await result.json();
  assert.match(saved.url, /\/storage\/v1\/object\/authenticated\/buyer-avatars\/owner-a\/.*\.png$/);
  assert.equal(f.uploads[0].bucket, "buyer-avatars");
  assert.equal(f.uploads[0].options.contentType, "image/png");
  assert.deepEqual(JSON.parse(f.calls[1].options.body), { profile_photo_url: saved.url });
  assert.deepEqual(f.quotas.map(p => p.p_scope), ["application-api", "application-api-writes", "profile-avatar"]);
});

test("cross-account identity and anonymous sessions cannot upload", async () => {
  for (const options of [{ owner: "owner-b" }, { user: null }, { user: { id: "owner-a", is_anonymous: true } }]) {
    const f = fixture(options);
    const response = await handleApiRequest(request(), f.backend, config, f.send);
    assert.ok([401, 403].includes(response.status));
    assert.equal(f.uploads.length, 0);
  }
});

test("invalid images consume quotas; exhaustion returns Retry-After before storage", async () => {
  const invalid = fixture();
  assert.equal((await handleApiRequest(request(new TextEncoder().encode("fake.png")), invalid.backend, config, invalid.send)).status, 400);
  assert.equal(invalid.quotas.length, 3);
  assert.equal(invalid.uploads.length, 0);
  const limited = fixture({ allowed: false });
  const response = await handleApiRequest(request(), limited.backend, config, limited.send);
  assert.equal(response.status, 429);
  assert.equal(response.headers.get("retry-after"), "33");
  assert.equal(limited.uploads.length, 0);
});

test("failed profile save removes the uploaded object and returns a safe error", async () => {
  const f = fixture({ failSave: true });
  const response = await handleApiRequest(request(), f.backend, config, f.send);
  assert.equal(response.status, 503);
  assert.deepEqual(f.removals, [f.uploads[0].path]);
  assert.equal(JSON.stringify(await response.json()).includes("owner-a"), false);
});

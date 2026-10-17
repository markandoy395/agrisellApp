import { upstreamHeaders } from "./policy.ts";

export type AvatarStorage = {
  from(bucket: string): {
    upload(
      path: string,
      bytes: Uint8Array,
      options: { contentType: string },
    ): Promise<{ error: unknown }>;
    remove(paths: string[]): Promise<{ error: unknown }>;
  };
};

export async function saveBuyerAvatar(
  request: Request,
  identity: string,
  bytes: Uint8Array,
  storage: AvatarStorage | undefined,
  config: { projectUrl: string; apiKey: string; gatewaySecret: string },
  send: typeof fetch,
): Promise<Response> {
  let type: [string, string] | null = null;
  if (
    bytes.length >= 3 && bytes[0] === 255 && bytes[1] === 216 &&
    bytes[2] === 255
  ) {
    type = ["jpg", "image/jpeg"];
  } else if (
    bytes.length >= 8 &&
    [137, 80, 78, 71, 13, 10, 26, 10].every((value, i) => bytes[i] === value)
  ) {
    type = ["png", "image/png"];
  } else if (
    bytes.length >= 12 &&
    new TextDecoder().decode(bytes.slice(0, 4)) === "RIFF" &&
    new TextDecoder().decode(bytes.slice(8, 12)) === "WEBP"
  ) {
    type = ["webp", "image/webp"];
  }
  if (!type) {
    return Response.json({ error: "Choose a JPG, PNG or WEBP image." }, {
      status: 400,
    });
  }
  if (!storage) throw new Error("Avatar storage unavailable");
  const headers = upstreamHeaders(request, config.apiKey, config.gatewaySecret);
  headers.set("content-type", "application/json");
  const ownerResponse = await send(
    new URL("/rest/v1/rpc/current_query_owner", config.projectUrl),
    {
      method: "POST",
      headers,
      body: "{}",
      redirect: "manual",
    },
  );
  if (!ownerResponse.ok) {
    return Response.json({ error: "Buyer identity required." }, {
      status: 403,
    });
  }
  const owner = await ownerResponse.json();
  if (
    owner?.auth_user_id !== identity || owner?.buyer_user_id == null ||
    !/^[1-9][0-9]*$/.test(String(owner?.user_id))
  ) {
    return Response.json({ error: "Buyer identity required." }, {
      status: 403,
    });
  }
  const path = `${identity}/${crypto.randomUUID()}.${type[0]}`;
  const bucket = storage.from("buyer-avatars");
  const upload = await bucket.upload(path, bytes, { contentType: type[1] });
  if (upload.error) throw new Error("Avatar upload failed");
  const url = new URL(
    `/storage/v1/object/authenticated/buyer-avatars/${path}`,
    config.projectUrl,
  ).href;
  try {
    headers.set("prefer", "return=representation");
    const target = new URL("/rest/v1/users", config.projectUrl);
    target.searchParams.set("user_id", `eq.${owner.user_id}`);
    target.searchParams.set("select", "user_id");
    const saved = await send(target, {
      method: "PATCH",
      headers,
      body: JSON.stringify({ profile_photo_url: url }),
      redirect: "manual",
    });
    if (!saved.ok) throw new Error("Avatar profile update failed");
    const rows = await saved.json();
    if (
      !Array.isArray(rows) || rows.length !== 1 ||
      String(rows[0]?.user_id) !== String(owner.user_id)
    ) {
      throw new Error("Avatar profile was not updated");
    }
    return Response.json({ url });
  } catch (error) {
    await bucket.remove([path]);
    throw error;
  }
}

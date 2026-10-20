// Uses the owner-scoped manifest collected before mock-account deletion.
const fs = require("node:fs");
const path = require("node:path");
const {
  loadBackendLocalEnv,
} = require("../../../agrisellDashboard/agrisellAdmin/backend/src/config/loadEnvFile.js");

async function run() {
  loadBackendLocalEnv();
  const base = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!base || !key) throw new Error("Backend storage credentials unavailable");
  const manifest = JSON.parse(
    fs.readFileSync(
      path.resolve(__dirname, "../../supabase/.temp/mock-storage-cleanup.json"),
      "utf8",
    ),
  ).rows[0].manifest;
  const owners = new Set(manifest.auth_ids || []);
  const objects = manifest.objects || [];
  const buckets = new Map();
  for (const object of objects) {
    if (!owners.has(object.name.split("/")[0]) || object.name.includes("..")) {
      throw new Error(
        "Storage manifest contains a path outside mock account folders",
      );
    }
    const names = buckets.get(object.bucket) || [];
    names.push(object.name);
    buckets.set(object.bucket, names);
  }
  for (const [bucket, names] of buckets) {
    for (let index = 0; index < names.length; index += 100) {
      const response = await fetch(
        `${base}/storage/v1/object/${encodeURIComponent(bucket)}`,
        {
          method: "DELETE",
          headers: {
            apikey: key,
            Authorization: `Bearer ${key}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ prefixes: names.slice(index, index + 100) }),
        },
      );
      if (!response.ok)
        throw new Error(`Mock storage deletion failed (${response.status})`);
    }
  }
  console.log(`Removed ${objects.length} uploaded mock objects.`);
}

run().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});

// Upload a clearly labeled sample preview to each rider_mock_v1 account.
// Requires the existing backend service credential; never prints secrets.
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
  const preview = fs.readFileSync(
    path.resolve(__dirname, "../../supabase/.temp/sample-rider-document.png"),
  );
  const headers = { apikey: key, Authorization: `Bearer ${key}` };
  let page = 1;
  const riders = [];
  while (true) {
    const response = await fetch(
      `${base}/auth/v1/admin/users?page=${page}&per_page=1000`,
      {
        headers,
      },
    );
    if (!response.ok)
      throw new Error(`Account lookup failed (${response.status})`);
    const body = await response.json();
    riders.push(
      ...body.users.filter(
        (user) => user.app_metadata?.test_seed === "rider_mock_v1",
      ),
    );
    if (body.users.length < 1000) break;
    page += 1;
  }
  if (riders.length !== 30) throw new Error("Expected 30 mock rider accounts");
  for (let index = 0; index < riders.length; index += 4) {
    await Promise.all(
      riders.slice(index, index + 4).map(async (rider) => {
        const response = await fetch(
          `${base}/storage/v1/object/rider-documents/${rider.id}/sample-rider-document.png`,
          {
            method: "POST",
            headers: {
              ...headers,
              "Content-Type": "image/png",
              "x-upsert": "true",
            },
            body: preview,
          },
        );
        if (!response.ok)
          throw new Error(`Sample preview upload failed (${response.status})`);
      }),
    );
  }
  console.log(
    "Uploaded 30 sample previews used by 180 rider document records.",
  );
}

run().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});

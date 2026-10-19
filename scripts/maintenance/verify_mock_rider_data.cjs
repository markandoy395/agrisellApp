const config = require("../../assets/config/supabase.local.json");
const base = config.SUPABASE_URL;
const key = config.SUPABASE_PUBLISHABLE_KEY;

async function signIn(number) {
  const response = await fetch(`${base}/auth/v1/token?grant_type=password`, {
    method: "POST",
    headers: { apikey: key, "Content-Type": "application/json" },
    body: JSON.stringify({
      email: `mock.rider${number}@example.com`,
      password: "AgrisellTest!2026",
    }),
  });
  if (!response.ok) throw new Error(`Login failed (${response.status})`);
  return response.json();
}

async function call(session, path, args) {
  const response = await fetch(
    `${base}/functions/v1/application-api/rest/${path}`,
    {
      method: args === undefined ? "GET" : "POST",
      headers: {
        apikey: key,
        Authorization: `Bearer ${session.access_token}`,
        "Content-Type": "application/json",
      },
      ...(args === undefined ? {} : { body: JSON.stringify(args) }),
    },
  );
  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new Error(
      `${path.split("?")[0]}: HTTP ${response.status}, code ${error.code || "unknown"}`,
    );
  }
  return response.json();
}

async function verify() {
  const first = await signIn("01");
  const second = await signIn("02");
  for (const session of [first, second]) {
    const owner = await call(session, "rpc/current_query_owner", {});
    const checks = [
      [
        "profile",
        `riders?select=rider_id,employment_status,vehicle_type,capacity_kg&rider_id=eq.${owner.rider_id}`,
      ],
      [
        "deliveries",
        "rpc/current_rider_deliveries",
        { include_available: true },
      ],
      [
        "nearby",
        "rpc/current_rider_nearby_deliveries",
        {
          p_latitude: 8.15,
          p_longitude: 125.12,
          p_radius_km: 15,
          p_limit: 50,
        },
      ],
      ["dashboard", "rpc/current_rider_dashboard", {}],
      ["wallet", "rpc/current_rider_wallet", {}],
      ["conversations", "rpc/current_rider_conversations", {}],
      ["ratings", "rpc/current_rider_ratings", {}],
      [
        "withdrawalMethods",
        "rpc/current_user_withdrawal_methods",
        { p_user_role: "rider" },
      ],
      [
        "payoutRequests",
        "rpc/current_user_payout_requests",
        { p_user_role: "rider" },
      ],
      [
        "documents",
        `rider_documents?select=document_id&rider_id=eq.${owner.rider_id}`,
      ],
      [
        "reports",
        `rider_incidents?select=report_id&rider_id=eq.${owner.rider_id}`,
      ],
      [
        "alerts",
        `notifications?select=notification_id&recipient_auth_user_id=eq.${session.user.id}&limit=30&order=created_at.desc`,
      ],
      ["verification", "rpc/current_rider_verification_details", {}],
    ];
    const summary = {};
    for (const [name, route, args] of checks) {
      try {
        const value = await call(session, route, args);
        summary[name] = Array.isArray(value) ? value.length : "loaded";
        if (name === "conversations" && value.length) {
          const messages = await call(
            session,
            "rpc/current_rider_conversation_messages",
            {
              p_conversation_id: value[0].conversation_id,
            },
          );
          summary.messagesInThread = messages.length;
        }
        if (name === "deliveries") {
          summary.completed = value.filter(
            (d) => d.delivery_status === "completed",
          ).length;
          summary.available = value.filter(
            (d) => !d.assigned_to_current_rider,
          ).length;
        }
        if (name === "wallet") summary.walletBalances = value;
      } catch (error) {
        summary[name] = error.message;
        process.exitCode = 1;
      }
    }
    const preview = await fetch(
      `${base}/storage/v1/object/authenticated/rider-documents/${session.user.id}/sample-rider-document.png`,
      {
        headers: {
          apikey: key,
          Authorization: `Bearer ${session.access_token}`,
        },
      },
    );
    summary.documentPreviewStatus = preview.status;
    if (!preview.ok) process.exitCode = 1;
    console.log(JSON.stringify(summary));
  }
  const secondOwner = await call(second, "rpc/current_query_owner", {});
  const cross = await call(
    first,
    `rider_incidents?select=report_id&rider_id=eq.${secondOwner.rider_id}`,
  );
  if (cross.length) throw new Error("Cross-account report visibility");
  console.log("Cross-account rider reports denied.");
}

verify().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});

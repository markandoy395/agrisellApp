import { requiredSecret, serverClient } from "../_shared/server_client.ts";
import { handleApiRequest } from "./handler.ts";

Deno.serve(async (request) => {
  try {
    return await handleApiRequest(request, serverClient(), {
      projectUrl: requiredSecret("SUPABASE_URL"),
      apiKey: requiredSecret("SUPABASE_ANON_KEY"),
      gatewaySecret: requiredSecret("API_GATEWAY_SECRET"),
    });
  } catch {
    return Response.json({ error: "API protection is temporarily unavailable." }, {
      status: 503,
      headers: { "Retry-After": "5", "Cache-Control": "no-store" },
    });
  }
});

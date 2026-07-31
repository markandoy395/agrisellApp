# AgriSell FCM notification sender

This Edge Function is called by the `notifications` database trigger. It sends
each inserted notification to every active Android FCM token for its recipient.

Set these hosted Supabase secrets before deploying:

```text
PUSH_WEBHOOK_SECRET=<a long random value>
FIREBASE_PROJECT_ID=agrisell-76c15
FIREBASE_CLIENT_EMAIL=<service-account client_email>
FIREBASE_PRIVATE_KEY=<service-account private_key, with \\n escapes>
```

The Firebase service account needs permission to send Firebase Cloud Messaging
messages. Keep its JSON file and private key outside this repository.

Deploy with:

```text
supabase functions deploy send-notification --no-verify-jwt
```

After deployment, add the function URL and the same webhook secret to Supabase
Vault using the SQL in the notification-dispatch migration comments.

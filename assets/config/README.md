# Local app configuration

Create `supabase.local.json` in this directory for local development:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "your-publishable-key"
}
```

The file is ignored by Git and bundled only into local Flutter runs. Use a
publishable/anonymous client key here, never a service-role or secret key.

Build-time `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` Dart defines override
this file. See the [getting-started guide](../../docs/getting_started.md) for
the complete setup flow.

# JusLegal AI Proxy

This Cloudflare Worker proxies OpenRouter and Groq API requests for the JusLegal Flutter app. The app calls this Worker instead of the providers directly, keeping provider API keys out of the client.

## Configure and deploy

Set the API keys as encrypted Cloudflare Worker secrets. Do not add them to `wrangler.jsonc` or commit them to source control.

```sh
wrangler secret put GROQ_API_KEY
wrangler secret put OPENROUTER_API_KEY
```

Deploy the Worker after setting the secrets:

```sh
wrangler deploy
```

`ALLOWED_ORIGIN` and `FIREBASE_PROJECT_ID` are configured in `wrangler.jsonc`.
The Worker requires `Authorization: Bearer <Firebase ID token>` for every
provider request. Provider API keys must remain Worker secrets and must never
be placed in the Flutter app's `.env` file.

Rate limiting is intentionally not enabled until this account has a Cloudflare
Rate Limiting binding and namespace. Add that binding before high-volume use.

After changing Worker bindings, regenerate local types with:

```sh
npm run cf-typegen
```

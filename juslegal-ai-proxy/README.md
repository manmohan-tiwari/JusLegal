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

`ALLOWED_ORIGIN` is currently `"*"` in `wrangler.jsonc` for initial development. Tighten it to the actual production web domain(s) before the app goes live.

After changing Worker bindings, regenerate local types with:

```sh
npm run cf-typegen
```

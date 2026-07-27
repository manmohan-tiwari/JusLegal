# JusLegal AI Proxy

This Cloudflare Worker proxies OpenRouter and Groq API requests for the JusLegal Flutter app. The app calls this Worker instead of the providers directly, keeping provider API keys out of the client.

## Configure and deploy

Set the API keys as encrypted Cloudflare Worker secrets. Do not add them to `wrangler.jsonc` or commit them to source control.

```sh
wrangler secret put GROQ_API_KEY
wrangler secret put OPENROUTER_API_KEY
wrangler secret put PROXY_AUTH_TOKEN
```

Deploy the Worker after setting the secrets:

```sh
wrangler deploy
```

`ALLOWED_ORIGIN` is set to the production web app origin. The Worker requires
`Authorization: Bearer <PROXY_AUTH_TOKEN>` for every provider request. Supply
the matching client token through the app's build configuration; do not add it
to source control. A Firebase/App Check token verifier is the recommended
long-term replacement for a shared client token.

Rate limiting is intentionally not enabled until this account has a Cloudflare
Rate Limiting binding and namespace. Add that binding before high-volume use.

After changing Worker bindings, regenerate local types with:

```sh
npm run cf-typegen
```

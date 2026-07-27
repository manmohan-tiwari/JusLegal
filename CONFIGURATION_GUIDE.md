# JusLegal Configuration Guide

JusLegal supports Android and Web. AI is powered by OpenRouter (primary) and
Groq (fallback) through a secure Cloudflare Worker proxy; provider API keys are
never configured in the Flutter client.

## Quick start

```bash
flutter pub get
flutter run
```

Configure Firebase separately if you use Analytics, Crashlytics, or Firebase
Hosting. Android Firebase configuration belongs in `android/app/`.

## AI proxy configuration

Set provider credentials only as Cloudflare Worker secrets:

```bash
cd juslegal-ai-proxy
wrangler secret put OPENROUTER_API_KEY
wrangler secret put GROQ_API_KEY
wrangler deploy
```

The Flutter app uses only these Worker endpoints:

- `https://juslegal-ai-proxy.juslegal-ai.workers.dev/callOpenRouter`
- `https://juslegal-ai-proxy.juslegal-ai.workers.dev/callGroq`

Do not add provider keys to `.env`, `--dart-define`, or any client-side source.

## Builds

```bash
flutter build apk --debug
flutter build web
```

## Production checklist

- Configure Firebase credentials for Android and Web as needed.
- Set `OPENROUTER_API_KEY` and `GROQ_API_KEY` as Worker secrets.
- Restrict the Worker's `ALLOWED_ORIGIN` before production deployment.
- Test Android and Web builds.

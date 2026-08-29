# JusLegal — Design Document

> **Audience:** Engineers, designers, and reviewers contributing to or evaluating the JusLegal codebase.
> **Scope:** Describes the *current* design of the Flutter client, its server‑side AI proxy, and the contract between them. It is written as a living specification of the system as it ships today, not a forward‑looking wishlist.
> **Tone:** Opinionated, structured, and explicit about trade‑offs — the way a senior designer‑engineer would document a production system for a new joiner.

---

## 1. Product Context

JusLegal is a **consumer legal guidance app for Indian citizens**. It translates everyday disputes (a failed e‑commerce refund, a UPI fraud, a builder delay) into a structured legal narrative: *what law applies, what rights the user has, what steps to take, which authorities to contact, and what documents to file.* The product is informational, not an attorney substitute — every primary surface is annotated with that disclaimer.

The product has two distinct surfaces:

1. A **structured case analyzer** that turns a free‑form problem description into a strict, schema‑validated `LegalResultModel`.
2. A **conversational AI legal assistant** ("JusLegal AI") that retains multi‑turn context and responds in Markdown.

Both surfaces are powered by the same AI gateway, but they negotiate with the model through different prompt contracts and response normalizers.

---

## 2. High‑Level Architecture

```
┌────────────────────────┐         ┌──────────────────────────────┐
│  Flutter Client        │  HTTPS  │  Cloudflare Worker            │
│  (lib/)                │ ──────► │  (juslegal-ai-proxy/)         │
│  • Riverpod state      │         │  • /callOpenRouter            │
│  • GoRouter            │         │  • /callGroq                  │
│  • Dio HTTP            │         │  • Server-side API keys       │
│  • Hive local cache    │         │  • Provider fallback          │
│  • Firebase Auth       │         └──────────────────────────────┘
│  • PDF generation      │
└────────────────────────┘
              │
              ▼
   ┌─────────────────────┐
   │ Persistence         │
   │  • Hive boxes       │
   │  • SharedPreferences│
   └─────────────────────┘
```

**Key decisions**

- The client **never holds provider API keys**. Both OpenRouter and Groq are reached only through a single Cloudflare Worker base URL defined in [`WORKER_BASE_URL`](lib/core/constants/api_constants.dart:2). This keeps billing, rotation, and secret management on the server side and makes it trivial to add providers without a client release.
- The client uses **two providers in a primary/fallback chain** (OpenRouter → Groq), implemented in [`AIService`](lib/services/ai_service.dart:11). The chain is consistent across chat, analysis, and document generation.
- All AI response parsing is **tolerant of Markdown fences, free‑text sections, and alias keys**. The client treats the model output as untrusted and normalizes it before binding it to typed models.

---

## 3. Application Bootstrap

[`lib/main.dart`](lib/main.dart:21) implements an explicit, ordered bootstrap:

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `EnvConfig.initialize()` — load `.env` values into a typed config.
3. `Firebase.initializeApp()` — guarded so the app **continues to run** if Firebase is unavailable, falling back to a dedicated "service unavailable" route ([`app_router.dart:60`](lib/core/router/app_router.dart:60)).
4. `SafeAnalytics.initialize()` — opt‑in analytics and crashlytics that only attach when the user has consented.
5. `Hive.initFlutter()` and the two persistent boxes (`cases`, `settings`).
6. `AppConfig.initialize()` — runtime flags.
7. `runApp(ProviderScope(child: JusLegalApp(...)))` — the entire app is wrapped in Riverpod's `ProviderScope`.

The root widget is a `ConsumerStatefulWidget` that watches `localeProvider` and rebuilds `MaterialApp.router` when the user changes language. The router instance is created once in `initState` to avoid re‑initialization on rebuild.

---

## 4. State Management — Riverpod 3

State is managed exclusively with **Riverpod** ([`flutter_riverpod`](pubspec.yaml:17)). There are three patterns in active use:

### 4.1 `Notifier<T>` — synchronous, in‑memory state

Used for session‑scoped state that should reset when the app restarts.

| Provider | Purpose | File |
| --- | --- | --- |
| `chatProvider` | In‑memory multi‑turn chat history | [`ai_provider.dart:101`](lib/providers/ai_provider.dart:101) |
| `problemProvider` | Active problem input (category + description) | [`problem_provider.dart:24`](lib/providers/problem_provider.dart:24) |
| `lastResultProvider` | Most recent `LegalResultModel` for handoff | [`ai_provider.dart:772`](lib/providers/ai_provider.dart:772) |
| `authProvider` | Firebase auth mirror | [`auth_handler.dart:266`](lib/services/auth_handler.dart:266) |

Each notifier follows a strict contract:

- Immutable state, mutated only through `copyWith`.
- `copyWith` supports a `clearError: true` flag to avoid stale error messages.
- Side effects (analytics, persistence) live *inside* the notifier, not in the UI.

### 4.2 `AsyncNotifier<T>` — async state with loading/error semantics

Used when a notifier is the source of a network call. The canonical example is [`AnalysisNotifier`](lib/providers/ai_provider.dart:122), which:

- emits `AsyncValue.loading()` while the AI is thinking,
- maps the provider's raw `Map<String, dynamic>` into a typed `LegalResultModel`,
- normalizes both `snake_case` and `camelCase` aliases (e.g. `case_summary` ↔ `caseSummary`),
- parses free‑text sections when the model returns Markdown instead of JSON,
- falls back through friendly error messages via `SafeAnalytics`.

### 4.3 `Provider<T>` — derived/computed state

Used for pure derivations and service factories. Examples:

- `aiServiceProvider` — singleton [`AIService`](lib/services/ai_service.dart:11).
- `analysisResultProvider`, `analysisLoadingProvider`, `analysisErrorProvider` — projections of the analysis state ([`ai_provider.dart:737`](lib/providers/ai_provider.dart:737)).

### 4.4 Persistence

Local persistence is intentionally narrow:

- **Hive** holds the `cases` box for saved case studies and the `settings` box for app preferences. The schema is hand‑rolled (Map‑shaped) inside [`cases_provider.dart`](lib/providers/cases_provider.dart:24), with defensive parsing so a corrupt entry cannot crash the UI.
- **SharedPreferences** is exposed via [`StorageService`](lib/services/storage_service.dart:4) for scalar flags.

---

## 5. Routing — go_router 17

The app uses **declarative routing** with [`go_router`](pubspec.yaml:18) and a single router instance built in [`buildRouter`](lib/core/router/app_router.dart:54).

**Route name constants** live in [`AppRouteNames`](lib/core/router/app_router.dart:28) so screens never hard‑code paths.

**Redirect policy** ([`app_router.dart:58`](lib/core/router/app_router.dart:58)):

1. If Firebase failed to initialize, only `/privacy-policy` and `/firebase-unavailable` are reachable. Everything else redirects to the unavailable screen.
2. If a user hits `/home/*` while unauthenticated, they are redirected to `/login`.
3. The root `/` resolves to `/login` or `/home` depending on the current Firebase user.

**Tree shape** (relevant excerpt):

```
/login
/email-auth
/otp
/home
  ├ analyzer
  ├ result
  ├ complaint
  ├ cases
  ├ authorities
  ├ settings
  ├ ai-lawyer-chat
  ├ legal-advice
  ├ case-analysis
  ├ legal-terms
  ├ legal-writing
  ├ document-creation
  └ document-review
```

A few routes (e.g. `contract-negotiation`) are intentionally **commented out** until the feature is finished — this is the team's way of leaving the route scaffolded without exposing an unfinished screen.

---

## 6. Theming and Visual System

The visual system is centralized in [`lib/core/config/theme_config.dart`](lib/core/config/theme_config.dart). It is intentionally a **single source of truth** for color, gradients, radii, and component defaults.

### 6.1 Color tokens

- **Brand:** `primary` (`#003DA5`, trust blue), `primaryNavy` (`#001F54`), `primaryLight` (`#2F6FDB`).
- **Accent:** `legalGold` (`#F5A623`) — used as the visual hook for AI surfaces and CTAs.
- **Semantic:** `success` (emerald), `error` (rose), `warning` (gold), `info` (sky).
- **Neutrals:** a 9‑step grey ramp (`grey50`…`grey900`).
- **Status (cases):** `caseOpen`, `caseInProgress`, `caseResolved`, `caseRejected`.

Gradients are pre‑defined and reused, not constructed ad hoc:

- `heroGradient` (navy → blue)
- `appBarGradient`
- `goldGradient`
- `userBubbleGradient` / `botBubbleGradient`
- `backgroundGradient` (subtle top→bottom white wash)

### 6.2 Typography

A single Material 3 `TextTheme` ([`theme_config.dart:209`](lib/core/config/theme_config.dart:209)) is hand‑tuned for legal content: heavy weight on titles (`w800`), slightly looser line height on body copy, and `bodySmall` reserved for meta text. The NotoSansDevanagari family is bundled for Hindi ([`pubspec.yaml:58`](pubspec.yaml:58)).

### 6.3 Radii and elevation

Three canonical radii: `radiusS = 8`, `radiusM = 16`, `radiusL = 24`. Elevation is intentionally **layered** — buttons (4–10), cards (3), floating action (8), floating AI button (8+ gold glow).

### 6.4 Component theming

`AppTheme.lightTheme` overrides:

- `appBarTheme` — flat surface tint, controlled elevation, custom `systemOverlayStyle`.
- `cardTheme` — `radiusM` rounded, soft 1px border, subtle shadow.
- `elevatedButtonTheme` / `filledButtonTheme` / `outlinedButtonTheme` / `textButtonTheme` — each enforces a 48dp minimum tap target and 24dp pill radius, in line with accessibility guidelines.
- `inputDecorationTheme` — filled inputs with 16dp radius, 1.6dp focus border in primary blue.
- `chipTheme` — pill shape with subtle borders.
- `floatingActionButtonTheme` — gold foreground, navy background, 28dp pill.
- `progressIndicatorTheme` — gold progress on a soft blue track.

The `AppTheme` class also exposes `cardGradientFor(Color)` so any card can request a tinted version of the standard card gradient without redefining it.

### 6.5 Why a single theme file

Centralizing in one file is a deliberate trade‑off: it makes "what does JusLegal look like" a one‑file read, but it does mean theme edits must touch this file. New component styles are added in‑place, not as new files, to keep cohesion.

---

## 7. Animation System

Animations are a first‑class design concern, not an afterthought. The shared vocabulary lives in [`lib/core/constants/app_animations.dart`](lib/core/constants/app_animations.dart) and is consumed by every primary surface.

The system exposes:

- `fadeSlideIn` — page/section entry: opacity 0→1, slight vertical slide.
- `staggeredListItem` — list/card cascade: per‑index delay.
- `pressScale` — tactile feedback on cards/chips: 1.0 → 0.97 with InkWell splash.

This means the **home grid, chat bubbles, and category cards all share the same motion language**. The point of the abstraction is not to be clever — it is to make "no surprise motion" the default.

The chat screen adds a typed `_TypingIndicator` with a rotating spinner and animated dots, reinforcing the "the AI is thinking" affordance.

---

## 8. Navigation and Shell

The home screen ([`home_screen.dart`](lib/screens/home_screen.dart)) is the only true shell. It is a `LayoutBuilder` that branches on width:

- **Mobile (≤600dp):** gradient `AppBar`, vertical scrolling body, glassy floating bottom nav, and a gold pulsing AI button.
- **Desktop (>600dp):** flat white header, two‑column hero, expanded max width (1200dp), and the bottom nav migrates into the header as text/icon buttons.

`_FloatingBottomNav` uses a `BackdropFilter` blur, a soft white→blue gradient, and an `AnimatedContainer` for the selected pill — a deliberately "frosted" treatment that stays legible on light and dark content.

The `_HeroSection` reuses the same gradient as the AppBar so the top of the page reads as one continuous brand block.

---

## 9. AI Service Layer

The AI service is the most architecturally important part of the app. It is structured as three layers.

### 9.1 Provider clients (low‑level transport)

[`OpenRouterService`](lib/services/openrouter_service.dart:12) and [`GroqService`](lib/services/groq_service.dart:12) are nearly identical by design:

- Single `Dio` instance, base URL set to `WORKER_BASE_URL`.
- Two endpoints exposed by the worker: `/callOpenRouter` and `/callGroq`.
- `analyze(system, prompt, category)` returns a parsed `Map<String, dynamic>` with `_provider` and `_model` stamped in.
- `generateRaw(system, prompt)` returns a free‑text string for document generation.
- `sendMessage(userMessage, history, languageCode)` handles multi‑turn chat, injecting the system prompt and a strict message ordering.
- Consistent error mapping: timeouts → `NetworkException`, 429 → `RateLimitException`, malformed body → `ParseException`. `RateLimitException` is intentionally *not* retried inside the provider.

### 9.2 Orchestrator (business policy)

[`AIService`](lib/services/ai_service.dart:11) is the only class screens and notifiers should depend on. It owns the fallback policy:

- **OpenRouter first, Groq second.** Retries with a small backoff (`ApiConstants.maxRetries = 2`, `retryDelayMs = 1000`) are applied per provider via [`_tryWithRetry`](lib/services/ai_service.dart:461). `RateLimitException` is *not* retried — it is propagated so the next provider is tried immediately.
- All prompts are constructed in this layer:
  - [`_buildStrictSystemPrompt`](lib/services/ai_service.dart:485) is the source of truth for the analysis JSON schema. It explicitly forbids Markdown fences, bullets, and prose outside JSON, and constrains `strength` to a 1–10 score.
  - [`_buildLetterPrompt`](lib/services/ai_service.dart:383) is the source of truth for letter/document generation. It mandates a `document_text` + `structured_fields` schema and a minimum length to prevent placeholder‑only responses.
  - [`generateDocumentFields`](lib/services/ai_service.dart:275) selects the right schema per document type (consumer, RTI, notice, affidavit, generic).
- Response normalization: [`_extractJsonObject`](lib/services/ai_service.dart:359) and [`_stripJsonFences`](lib/services/ai_service.dart:349) tolerate fenced JSON, leading prose, and the occasional missing brace. This is non‑negotiable in a production AI system.

### 9.3 View‑model normalizer (data binding)

The view models never receive raw provider output. [`AnalysisNotifier._normalizeAnalysisPayload`](lib/providers/ai_provider.dart:289) is the second pass that:

- reads either the strict JSON contract or a parsed free‑text fallback,
- normalizes alias keys (`caseSummary` ↔ `case_summary` ↔ `summary`),
- coerces `strength`/`confidence` into a 1–10 score with semantic labels,
- sanitizes text by stripping Markdown, bullets, and numbering artifacts,
- resolves authority contact defaults when the model omits them.

This three‑layer split (transport → orchestrator → view model) is the single most important architectural decision in the codebase. It lets us change the model, the provider, or the schema without touching the UI.

### 9.4 Prompts as code

System prompts are constructed in code rather than loaded from a file so they can be parameterized per language and per category. The chat system prompt is a single function [`chatSystemPromptForLanguage`](lib/core/config/ai_config.dart:18) that conditionally appends Hindi instructions.

---

## 10. Authentication

Auth is provided by Firebase Auth, wrapped in two layers:

- [`AuthService`](lib/services/auth_handler.dart:7) — thin façade over `FirebaseAuth` and `GoogleSignIn`. All exceptions are normalized to `AuthFailureException` (with a user‑safe message) or `AuthCancelledException`.
- [`AuthNotifier`](lib/services/auth_handler.dart:269) — exposes the same operations to Riverpod, mirrors `authStateChanges` into local state, and keeps `isLoading` and `error` in one place.

Supported sign‑in methods:

- Phone + OTP (with Indian number normalization in [`_normalizeIndianPhoneNumber`](lib/services/auth_handler.dart:188))
- Email + password (sign in, register, reset)
- Google

The router uses the auth state for redirect decisions rather than calling into `AuthService` directly — UI components should only ever consume `authProvider`.

---

## 11. Local Data Model

### 11.1 `LegalResultModel`

The canonical output of a case analysis. It carries both the **legacy** flat fields (used by older screens) and the **structured** deep fields (used by the detailed result view) so we can ship the richer surface without breaking existing widgets.

Notable fields:

- `confidence` (0–100) and `strength` (1–10) — two complementary scores for the same intuition.
- `legalPosition` — `{ standing, strength, explanation }` for the "where do you stand" card.
- `evidenceChecklist` — `{ available: [], recommended: [] }` so the UI can render two parallel lists.
- `authoritiesDetailed` — extended metadata for the "who to contact" card.
- `riskFactors` and `estimatedOutcome` — explicit so the disclaimer is not the only honest sentence in the result.

The `fromJson` factory ([`legal_result_model.dart:71`](lib/models/legal_result_model.dart:71)) is *defensive by design*: it accepts either snake or camel case, never throws on a missing field, and never mutates its input.

### 11.2 `SavedCaseModel`

A persisted case is a thin envelope around a serialized `LegalResultModel` (`resultJson`) plus category, snippet, date, and status. Storage is a plain Map in Hive; the notifier owns schema migration by always going through the same parse function ([`_fromHive`](lib/providers/cases_provider.dart:24)).

### 11.3 `ProblemModel`

A small, immutable input model. It carries the explicit fields the AI prompt needs plus a free‑form `dynamicFieldValues` map that is filled from the category‑specific form schema.

---

## 12. UI Surfaces

### 12.1 Home

The home screen is the product's front door. It composes:

- a hero block (gradient, headline, CTA),
- a top‑4 category grid with a "see all" link,
- an "AI chat & analysis" tools grid,
- a "documents & contracts" tools grid,
- a "why JusLegal" benefit list,
- a persistent disclaimer banner with a deep link to the privacy policy.

Every grid uses the same `Wrap` + `staggeredListItem` pattern, which means future sections will inherit the same cascade timing for free.

### 12.2 Problem analyzer

Renders a category‑aware form. The form schema is data‑driven from [`AppCategories.categoryFields`](lib/core/constants/categories.dart:105), so adding a new category is a single constant entry — no new widgets.

### 12.3 Result

The detailed case analysis view. It binds to `analysisResultProvider` and is responsible for rendering every structured field on `LegalResultModel`. The screen is built as a series of cards (case summary, legal position, evidence checklist, authorities, risk factors, disclaimer) with no nested routing.

### 12.4 AI chat

A standard chat surface with three details worth calling out:

- Messages are wrapped in [`AppAnimations.fadeSlideIn`](lib/core/constants/app_animations.dart) on insert.
- User bubbles use the navy gradient; bot bubbles render Markdown via [`flutter_markdown`](pubspec.yaml:32) with a custom [`MarkdownStyleSheet`](lib/screens/ai_legal_chat_screen.dart:321) that promotes the gold accent to links, bold, and list bullets.
- Suggestion chips appear when the conversation is empty, giving the user a non‑blank starting point.

### 12.5 Floating AI button

A persistent, brand‑forward entry point to the AI chat. It is a 64dp gold disc with a custom‑painted bot face ([`_BotFacePainter`](lib/widgets/floating_ai_button.dart:164)), a rotating sweep‑gradient ring, and a soft pulse. It is reusable across screens.

### 12.6 Document creation, review, complaint

A multi‑step wizard built from typed templates in [`lib/services/pdf/pdf_templates/`](lib/services/pdf/pdf_templates). The flow is: pick category → fill form fields → preview → generate PDF via [`pdf`](pubspec.yaml:33) + [`printing`](pubspec.yaml:34). Templates are deliberately separated from widgets so a designer can iterate on the form without touching the PDF renderer.

### 12.7 My cases, authorities, settings

Three utility tabs. "My cases" reads from `casesProvider`; "Authorities" is a static directory of Indian regulatory bodies with deep links; "Settings" toggles language, theme density, and rate‑us prompts.

---

## 13. Localization and Accessibility

- Two locales: English and Hindi (Devanagari). The active locale is a Riverpod‑managed setting that drives `MaterialApp.router.locale`. The NotoSansDevanagari font is bundled and used for Hindi.
- The AI system prompt *also* switches based on the locale, so generated documents, chat replies, and structured results follow the user's language.
- All interactive elements respect a 48dp minimum tap target via theme overrides.
- The analyzer screen reads the device locale at first launch but is overridable from settings.

---

## 14. Analytics, Logging, and Error Handling

[`SafeAnalytics`](lib/core/services/analytics_service.dart) wraps Firebase Analytics and Crashlytics behind a consent gate. It is used liberally inside notifiers (analysis started/completed/error, case saved, app started) but never inside widgets.

Errors are treated as a first‑class API. Each layer produces typed exceptions ([`lib/core/exceptions/ai_exceptions.dart`](lib/core/exceptions/ai_exceptions.dart)):

- `NetworkException` — timeouts, transport failures.
- `RateLimitException` — 429s.
- `ParseException` — model output could not be coerced.
- `AllProvidersFailedException` — terminal fallback failure.
- `ApiKeyException` — server‑side misconfiguration.

Notifiers translate these into localized, user‑safe strings. The chat screen renders them via `SnackBar`; the analysis screen stores them on the notifier and exposes a convenience `analysisErrorProvider`.

---

## 15. Internationalization of Design

The product is intentionally **brand‑forward, not decorative**. The trust signals (navy + gold, generous radius, soft elevation, gradient hero) are repeated across every surface so the user always knows they are inside JusLegal. New screens should reuse the existing tokens rather than introducing new colors, radii, or motion.

A new feature should:

1. Add a new route name in [`AppRouteNames`](lib/core/router/app_router.dart:28) and register it in [`buildRouter`](lib/core/router/app_router.dart:54).
2. Add a new screen in `lib/screens/`.
3. Add any shared widgets to `lib/widgets/`.
4. If it talks to the AI, route through [`AIService`](lib/services/ai_service.dart:11) — never call providers directly.
5. If it persists anything, use a Riverpod notifier and a Hive box — never touch `Hive` from a widget.
6. If it introduces a new motion or color, add it to the theme/animations file first, then use it.

---

## 16. Testing and Quality Gates

- Static analysis via `analysis_options.yaml` (Flutter lints).
- Server‑side AI proxy has its own Vitest suite under `juslegal-ai-proxy/test/`.
- Debug builds enable `device_preview` so designers can exercise multiple form factors without leaving the IDE.
- The `kDebugMode`‑guarded log statements are intentional — they survive in production builds as no‑ops.

---

## 17. Design Principles (TL;DR)

- **One source of truth per concern.** Theme in `theme_config.dart`. Routes in `app_router.dart`. AI policy in `ai_service.dart`. Prompts are code, not config.
- **Strict at the boundary, forgiving in the middle.** The AI contract is strict (JSON schema, length minimums, error flags). The internal pipeline is forgiving (alias keys, fence stripping, free‑text parsing).
- **State lives in notifiers.** Widgets are dumb. They watch providers, dispatch actions, and render. No `setState` outside of purely local UI state (animation controllers, tab indices).
- **Server‑side secrets, client‑side UX.** Provider keys never leave the worker. The client owns the experience and the persistence, the server owns the model and the credentials.
- **Brand consistency is enforced by the theme.** If a screen reaches for a hard‑coded color, radius, or motion, it is a code smell.

---

## 18. Appendix — File Map of the Design Surface

| Concern | File |
| --- | --- |
| App bootstrap | [`lib/main.dart`](lib/main.dart) |
| Routing | [`lib/core/router/app_router.dart`](lib/core/router/app_router.dart) |
| Theme & color tokens | [`lib/core/config/theme_config.dart`](lib/core/config/theme_config.dart) |
| Animations | [`lib/core/constants/app_animations.dart`](lib/core/constants/app_animations.dart) |
| AI orchestrator | [`lib/services/ai_service.dart`](lib/services/ai_service.dart) |
| Provider clients | [`lib/services/openrouter_service.dart`](lib/services/openrouter_service.dart), [`lib/services/groq_service.dart`](lib/services/groq_service.dart) |
| AI view model | [`lib/providers/ai_provider.dart`](lib/providers/ai_provider.dart) |
| Auth | [`lib/services/auth_handler.dart`](lib/services/auth_handler.dart) |
| Persistence | [`lib/providers/cases_provider.dart`](lib/providers/cases_provider.dart), [`lib/services/storage_service.dart`](lib/services/storage_service.dart) |
| Domain model | [`lib/models/legal_result_model.dart`](lib/models/legal_result_model.dart) |
| Categories | [`lib/core/constants/categories.dart`](lib/core/constants/categories.dart) |
| Home | [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart) |
| AI chat | [`lib/screens/ai_legal_chat_screen.dart`](lib/screens/ai_legal_chat_screen.dart) |
| Floating AI button | [`lib/widgets/floating_ai_button.dart`](lib/widgets/floating_ai_button.dart) |
| Server proxy | [`juslegal-ai-proxy/src/index.ts`](juslegal-ai-proxy/src/index.ts) |

---

*Last reviewed against `lib/` on 2026‑08‑29. Any change to a primary surface (theme, AI service, router) should update this document in the same PR.*

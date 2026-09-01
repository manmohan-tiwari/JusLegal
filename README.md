# JusLegal - Know Your Rights. Take Action.

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.0.0-orange)
![Platform](https://img.shields.io/badge/platform-Flutter-blue)
![Language](https://img.shields.io/badge/language-Dart-blue)

## Overview

JusLegal is an **AI-powered consumer legal guidance app** for Indian citizens. It translates everyday disputes (failed e-commerce refunds, UPI fraud, builder delays) into structured legal analysis, identifying applicable laws, user rights, actionable steps, relevant authorities, and necessary documents—all powered by AI with a secure server-side proxy.

**🎯 Product Focus:** Structured case analysis + conversational AI legal assistance for Indian Consumer Protection Law.

## Core Features

### Legal Analysis & Guidance
- **Structured Case Analyzer** - Convert free-form problem descriptions into validated legal analysis
- **AI Legal Chat** - Multi-turn conversational assistant with context retention (powered by Riverpod)
- **AI-Powered Analysis** - OpenRouter with Groq fallback via Cloudflare Worker proxy
- **Consumer Law Specialization** - Focus on Indian Consumer Protection Act 2019 and related regulations
- **Step-by-Step Resolution Guidance** - Clear, actionable legal remedies and next steps
- **Authority Directory** - Regulatory contact information and relevant agencies

### Document & Case Management
- **Professional Document Generation** - Generate complaint letters and legal documents using advanced LLMs
- **Document Upload** - Support for jpg, jpeg, png, pdf, doc, docx (via filepicker)
- **Case Management** - Save, track, and review legal cases
- **Case History** - Access saved cases with full analysis and documents
- **PDF Export & Printing** - Professional PDF generation and printing support

### User Experience & Trust
- **Transparent AI Sourcing** - Clear distinction between AI-generated and legally verified content
- **Bundled Legal Knowledge Base** - `assets/legal_kb.json` included for offline reference
- **Error Resilience** - Graceful error handling with automatic fallback and retry mechanisms
- **Multi-Language Support** - Internationalization (English & Hindi via intl)
- **Cross-Platform** - Native Android + Web support
- **Professional UI** - Banking-app color scheme with lottie animations and shimmer loading states

### Authentication & Analytics
- **Firebase Authentication** - Email + Google Sign-In support
- **Firebase Analytics** - Track user behavior and feature usage
- **Firebase Crashlytics** - Real-time error reporting and monitoring
- **Offline Support** - Hive local caching and SharedPreferences

## Technology Stack

**Frontend:**
- **Language:** Dart 3.2.3+
- **Framework:** Flutter 3.19.0+
- **State Management:** flutter_riverpod 3.3.1
- **Navigation:** go_router 17.2.3
- **HTTP Client:** dio 5.4.0
- **Local Storage:** hive_flutter 1.1.0 + shared_preferences 2.3.0

**Backend Integration:**
- **API Proxy:** Cloudflare Worker (juslegal-ai-proxy)
- **AI Providers:** OpenRouter (primary) → Groq (fallback)
- **Authentication:** Firebase Auth 6.5.2 + Google Sign-In 6.2.0
- **Analytics:** Firebase Analytics 12.4.1
- **Error Tracking:** Firebase Crashlytics 5.2.2

**UI & Content:**
- **Fonts:** google_fonts 8.1.0
- **Animations:** lottie 3.0.0
- **Markdown:** flutter_markdown 0.7.7+1
- **PDF Generation:** pdf 3.11.0 + printing 5.13.0
- **File Picking:** file_picker 8.1.0

## Architecture Overview

```
┌────────────────────────────────┐         ┌──────────────────────────────┐
│  Flutter Client (lib/)          │  HTTPS  │  Cloudflare Worker            │
│                                 │ ──────► │  (juslegal-ai-proxy/)         │
│  • Riverpod state management    │         │  • /callOpenRouter            │
│  • GoRouter navigation          │         │  • /callGroq                  │
│  • Dio HTTP client              │         │  • Server-side API keys       │
│  • Hive local persistence       │         │  • Provider fallback logic    │
│  • Firebase Authentication      │         │  • Error handling             │
│  • PDF generation & printing    │         └──────────────────────────────┘
└────────────────────────────────┘
              │
              ▼
   ┌──────────────────────────────┐
   │  Local Storage               │
   │  • Hive boxes (cases, etc)   │
   │  • SharedPreferences (prefs) │
   │  • Firebase Cloud Storage    │
   └──────────────────────────────┘
```

### Design Principles

- **Server-Side Secrets:** Client never holds AI provider API keys; all credentials managed in Cloudflare Worker
- **Primary/Fallback Chain:** OpenRouter → Groq ensures high availability without client-side configuration
- **Untrusted AI Output:** All model responses are parsed tolerantly (Markdown fences, free-text sections, alias keys) and validated against typed schemas
- **Offline-First:** Bundled legal knowledge base and local case cache work without network
- **Privacy-Focused:** No AI provider credentials exposed to Flutter; Firebase optional for analytics

## Project Structure

### Flutter App (`lib/`)
```
lib/
├── main.dart                     # App entry point
├── core/
│   ├── config/                   # App configuration
│   ├── constants/                # API constants, Firebase options, strings
│   ├── exceptions/               # Custom exception types
│   ├── router/                   # GoRouter configuration
│   ├── services/                 # Core services (AI, auth, etc)
│   ├── theme/                    # App theme and design system
│   └── utils/                    # Helper utilities
├── models/                       # Data models (legal case, chat message, etc)
├── providers/                    # Riverpod providers (state)
├── screens/                      # UI screens
│   ├── ai_legal_chat_screen.dart          # Multi-turn AI chat
│   ├── case_analysis_screen.dart          # Structured legal analysis
│   ├── complaint_generator_screen.dart    # Document generation
│   ├── document_creation_screen.dart      # Legal document builder
│   ├── document_review_screen.dart        # Review & export documents
│   ├── legal_advice_screen.dart           # General legal guidance
│   ├── home_screen.dart                   # App home/dashboard
│   ├── my_cases_screen.dart               # Saved cases list
│   ├── problem_analyzer_screen.dart       # Problem intake form
│   ├── authorities_screen.dart            # Authority directory
│   ├── settings_screen.dart               # User preferences
│   ├── login_screen.dart                  # Authentication UI
│   └── [other screens]
├── services/                     # Business logic services
└── widgets/                      # Reusable UI components
```

### Cloudflare Worker (`juslegal-ai-proxy/`)
```
juslegal-ai-proxy/
├── src/
│   └── index.ts                  # Worker entry point with AI provider routing
├── test/
│   └── index.spec.ts             # Vitest integration tests
├── wrangler.jsonc                # Cloudflare Worker configuration
└── vitest.config.mts             # Test configuration
```

### Assets
```
assets/
├── legal_kb.json                 # Bundled Indian legal knowledge base
├── images/                       # App images and illustrations
└── Fonts/                        # Custom font files
```

## Prerequisites

Before setting up JusLegal, ensure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.19.0 or higher
- [Dart SDK](https://dart.dev/get-dart) 3.2.3 or higher
- [Node.js](https://nodejs.org/) 18+ (for Cloudflare Worker development)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/install-and-update/) (for Worker deployment)
- Git for version control
- Code editor (VS Code recommended with Flutter + Dart extensions)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/mohan-70/juslegal.git
cd juslegal
```

### 2. Set Up Flutter App

```bash
# Install Flutter dependencies
flutter pub get

# Get the correct Flutter and Dart versions
flutter doctor
```

### 3. Set Up Cloudflare Worker (AI Proxy)

```bash
# Navigate to the worker directory
cd juslegal-ai-proxy

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local  # (if exists, or create manually)

# Configure secrets (see AI Security section below)
wrangler secret put OPENROUTER_API_KEY
wrangler secret put GROQ_API_KEY
wrangler secret put PROXY_AUTH_TOKEN

# Deploy the worker
wrangler deploy
```

### 4. Configure Flutter App Constants

Update `lib/core/constants/api_constants.dart` with your Cloudflare Worker URL:

```dart
const String WORKER_BASE_URL = 'https://your-worker-subdomain.workers.dev';
const String PROXY_AUTH_TOKEN = 'your-proxy-token-here';
```

### 5. Set Up Firebase (Optional but Recommended)

For production with analytics and error tracking:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add your platform-specific configuration:
   - **Android:** Place `google-services.json` in `android/app/`
   - **Web:** Firebase config is auto-loaded via Firestore credentials
3. Enable these services:
   - Firebase Authentication
   - Firebase Analytics
   - Firebase Crashlytics

### 6. Run the App

**Android:**
```bash
flutter run -d android
```

**Web:**
```bash
flutter run -d chrome
```

**Build for Release:**
```bash
flutter build apk         # Android APK
flutter build appbundle   # Android App Bundle
flutter build web         # Web release
```

## Usage

### Screens Overview

| Screen | Purpose | Key Features |
|--------|---------|--------------|
| **Home Screen** | App dashboard | Quick access to all features |
| **Problem Analyzer** | Problem intake form | Structured data collection |
| **Case Analysis** | AI-powered legal analysis | Validates problem data, generates legal results |
| **AI Legal Chat** | Conversational AI assistant | Multi-turn dialogue with context |
| **Complaint Generator** | Document generation | Create ready-to-file complaint letters |
| **Document Review** | View & export documents | PDF export, printing support |
| **My Cases** | Case history | View all saved case analyses |
| **Authorities Directory** | Regulatory contact info | Find relevant agencies |
| **Settings** | User preferences | Language, notifications, account |

### Key Developer APIs

#### AI Analysis (Riverpod Provider)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juslegal/models/problem_model.dart';
import 'package:juslegal/providers/ai_provider.dart';

final problem = ProblemModel(
  category: 'E-commerce & Shopping',
  dateOfIncident: '2026-08-31',
  disputedAmount: '5000',
  involvedParty: 'Online Retailer XYZ',
  referenceNumber: 'ORDER-ABC-12345',
  summary: 'Received defective item; retailer refuses refund.',
  attachedFiles: [],
);

// Trigger analysis
ref.read(aiProvider.notifier).analyze(problem);

// Watch results
final result = ref.watch(analysisResultProvider);
```

#### Case Management

```dart
// Save a case (uses Hive local storage)
ref.read(casesProvider.notifier).saveCase(legalResult);

// Retrieve all saved cases
final cases = ref.watch(casesProvider);

// Delete a case
ref.read(casesProvider.notifier).deleteCase(caseId);
```

#### AI Chat (Streaming)

```dart
// Send message to AI chat
ref.read(aiChatProvider.notifier).sendMessage(userMessage);

// Watch chat history
final chatHistory = ref.watch(aiChatProvider);
```

## Configuration

### Environment Variables

The app uses Dart defines for runtime configuration:

```bash
flutter run --dart-define=PROXY_AUTH_TOKEN='your-token' \
            --dart-define=WORKER_BASE_URL='https://your-worker.workers.dev'
```

### Cloudflare Worker Configuration (`wrangler.jsonc`)

```jsonc
{
  "name": "juslegal-ai-proxy",
  "main": "src/index.ts",
  "compatibility_date": "2024-11-01",
  "env": {
    "production": {
      "routes": [
        { "pattern": "api.juslegal.app/ai/*", "zone_id": "your-zone-id" }
      ]
    }
  }
}
```

### Local Storage (Hive)

Cases and preferences are stored locally using Hive:
- `boxes/legal_cases` - Saved case analyses
- `boxes/app_preferences` - User settings and language preference

### Localization

Multi-language support via `intl` package:
- **Supported:** English (en), Hindi (hi)
- **Files:** `lib/l10n/app_en.arb`, `lib/l10n/app_hi.arb`
- **Generated:** `lib/l10n/gen/app_localizations.dart`

To add a new language:
1. Create `lib/l10n/app_xx.arb` (replace `xx` with language code)
2. Add translations matching keys in English file
3. Run `flutter gen-l10n`
4. Update `supportedLocales` in `main.dart`

### Firebase Authentication

The app supports two auth methods:

1. **Email/Password** - Via Firebase Auth
2. **Google Sign-In** - Via Google OAuth 2.0

Configure in your Firebase console and ensure Google Sign-In credentials are set for both Android and Web.

## AI API Security & Deployment

### Design Principle: Server-Side Secrets

- **Flutter client never holds AI provider API keys**
- **All AI calls routed through Cloudflare Worker proxy**
- **Worker enforces authentication and provider fallback**

### Cloudflare Worker Setup

From a secure terminal (never commit secrets):

```bash
cd juslegal-ai-proxy

# Set provider secrets
wrangler secret put OPENROUTER_API_KEY
# (Paste your OpenRouter API key when prompted)

wrangler secret put GROQ_API_KEY
# (Paste your Groq API key when prompted)

wrangler secret put PROXY_AUTH_TOKEN
# (Generate a secure random token, e.g., using: openssl rand -base64 32)

# Deploy to Cloudflare
wrangler deploy
```

### Provider Fallback Chain

1. **Primary:** OpenRouter (supports multiple model providers)
2. **Fallback:** Groq (local LPU inference, faster responses)

The Worker automatically falls back if OpenRouter is unavailable or rate-limited.

### Authentication Flow

Current implementation uses a shared proxy token (`PROXY_AUTH_TOKEN`). For production, migrate to:
- **Firebase App Check** - Verify requests come from your app
- **Firebase ID Tokens** - Per-user authentication and quota enforcement

**Example migration:**
```typescript
// In Cloudflare Worker (worker-configuration.d.ts)
const idToken = request.headers.get('Authorization')?.split('Bearer ')[1];
const verified = await verifyFirebaseIdToken(idToken);
```

### Security Best Practices

✅ **Do:**
- Rotate secrets regularly
- Use Cloudflare Workers KV for non-sensitive config
- Monitor Worker logs for unusual activity
- Enable CORS only for your domain

❌ **Don't:**
- Commit `.env`, `.env.local`, or service account JSON files
- Pass provider keys via `--dart-define` or `pubspec.yaml`
- Expose `PROXY_AUTH_TOKEN` in Flutter code
- Use shared tokens in production (implement per-user auth)

## Development

### Recommended VS Code Extensions

- **Flutter** (Dart Code)
- **Dart** (Dart Code)
- **Firebase Extensions** (Firebase)
- **REST Client** (Huachao Mao) - for testing Worker endpoints

### Local Development Workflow

```bash
# Terminal 1: Run Flutter app in dev mode
flutter run -d chrome  # or -d android

# Terminal 2: Watch and debug Cloudflare Worker
cd juslegal-ai-proxy
wrangler dev --local

# Terminal 3: Run tests
cd juslegal-ai-proxy
npm test              # Worker tests
flutter test          # Flutter unit tests
```

### Testing the Worker Locally

```bash
cd juslegal-ai-proxy

# Run Vitest suite
npm test

# Test against real endpoints (requires secrets in .env.local)
curl -X POST http://localhost:8787/callOpenRouter \
  -H "Authorization: Bearer $PROXY_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"model":"openrouter/auto","messages":[{"role":"user","content":"Hello"}]}'
```

### Debugging Riverpod State

Use `flutter_riverpod`'s devtools:

```bash
flutter pub add dev:riverpod_generator dev:build_runner
flutter pub run build_runner watch
```

### Known Limitations & TODOs

- `flutter_markdown` is retained for backward compatibility; consider migration to `markdown_widget` or `flutter_html` for better maintenance
- Current proxy auth uses shared token; production should implement per-user Firebase ID token verification
- Offline AI analysis not yet supported (requires local model inference)
- Community wins feature framework exists but needs backend integration

## Contributing

We welcome contributions from the community! Here's how to get started:

## Contributing

We welcome contributions from the community! Here's how to get started:

### Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork:**
   ```bash
   git clone https://github.com/manmohan-tiwari/juslegal.git
   cd juslegal
   ```
3. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Set up your development environment** (follow Installation section above)

### Development Process

1. **Make your changes**
   - Follow [Flutter/Dart style guidelines](https://dart.dev/guides/language/effective-dart/style)
   - Write clear, descriptive commit messages
   - Keep commits focused on single features

2. **Write Tests**
   - Unit tests for services and models: `test/` directory
   - Widget tests for UI: `test/widgets/` directory
   - Worker tests: `juslegal-ai-proxy/test/`
   
   ```bash
   flutter test                          # Run all Flutter tests
   cd juslegal-ai-proxy && npm test     # Run Worker tests
   ```

3. **Verify Code Quality**
   ```bash
   flutter analyze                       # Dart analyzer
   cd juslegal-ai-proxy && npm run lint # TypeScript linting
   ```

4. **Update Documentation**
   - Update `README.md` if you change features or setup
   - Add comments to complex logic
   - Update `design.md` for architectural changes

### Submitting a Pull Request

1. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open a PR** against `main` branch
   - Clear title describing the change
   - Detailed description of what changed and why
   - Reference any related issues (#123)
   - Include screenshots for UI changes

3. **Code Review Process:**
   - Maintain a friendly, constructive tone
   - Address feedback promptly
   - All checks must pass (tests, linting)

### Areas for Contribution

- **Frontend:** New screens, UI improvements, accessibility
- **Backend:** Worker optimization, new AI providers, error handling
- **Documentation:** Clarifications, guides, examples
- **Localization:** Additional languages, regional legal content
- **Testing:** Test coverage improvements, edge cases
- **Performance:** Optimization, caching strategies
- **Security:** Vulnerability reports, hardening

### Reporting Issues

Found a bug? Please file an issue with:
- **Clear title** describing the problem
- **Steps to reproduce** the issue
- **Expected vs. actual behavior**
- **Environment:** OS, Flutter version, device
- **Screenshots/logs** if applicable

## Architecture & Design Decisions

For detailed architectural information, see [design.md](design.md), which covers:
- System architecture and component interaction
- Data models and schemas
- AI provider integration and fallback logic
- Security model and authentication
- Performance considerations

Key highlights:
- **Stateless AI proxy:** All secrets server-side in Cloudflare Workers
- **Offline-capable:** Bundled legal knowledge base and local Hive storage
- **Graceful degradation:** Automatic provider fallback (OpenRouter → Groq)
- **User-centric privacy:** Optional Firebase integration; works fully offline

## Troubleshooting

### Common Issues

**Flutter SDK not found**
```bash
flutter doctor                          # Check your setup
flutter doctor --verbose               # Detailed diagnostics
# Follow Flutter documentation to install/fix
```

**Worker secrets not working**
```bash
cd juslegal-ai-proxy
wrangler secret list                   # Verify secrets exist
wrangler logs                           # Check Worker execution logs
```

**Firebase configuration issues**
- Ensure `google-services.json` is in `android/app/`
- For Web, Firebase config loads from hosted settings
- Check Firebase project quota and billing

**AI Analysis fails**
- Verify Worker is deployed and responding:
  ```bash
  curl -H "Authorization: Bearer YOUR_TOKEN" \
       https://your-worker.workers.dev/health
  ```
- Check Worker logs in Cloudflare dashboard
- Ensure OPENROUTER_API_KEY and GROQ_API_KEY are set

**Hive database errors**
```bash
# Clear local Hive cache
rm -rf /data/data/com.juslegal/app_flutter/   # Android
# Or clear through app settings

flutter clean                            # Deep clean
flutter pub get
flutter run
```

### Performance Tips

- **AI responses are slow:** Check Worker logs for provider latency
- **App startup slow:** First run initializes Hive; subsequent runs are faster
- **Memory usage high:** Close AI chat if not in use; consider `flutter run --release`
- **Large file uploads:** PDF/document files >5MB may timeout; compress or split

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

Permissions: You are free to use, modify, and distribute this software.  
Conditions: Include the license and copyright notice.  
Limitations: No liability; provided "as is".

## Support & Community

**Get Help:**
- 📧 **Email:** [dev@juslegal.app](mailto:dev@juslegal.app) (coming soon)
- 🐛 **Bug Reports:** [GitHub Issues](https://github.com/mohan-70/juslegal/issues)
- 💬 **Discussions:** [GitHub Discussions](https://github.com/mohan-70/juslegal/discussions)

**Stay Updated:**
- ⭐ Star this repository to show support
- 👀 Watch for new releases and updates
- 🔔 Subscribe to announcements

**Live App:**
- 🌐 **Web:** [juslegal-2196.web.app](https://juslegal-2196.web.app)
- 📱 **Android:** (Coming to Google Play Store)

## Acknowledgments

### Technologies & Partners

- **Flutter & Dart:** For the incredible cross-platform framework
- **Cloudflare Workers:** Secure, edge-computing AI proxy
- **OpenRouter & Groq:** AI providers powering legal analysis
- **Firebase:** Authentication, analytics, and error tracking
- **Riverpod:** Type-safe state management

### Contributors

- **Lead Developer:** [Mohan Tiwari](https://github.com/mohan-70)
- **All Contributors:** See [CONTRIBUTORS.md](CONTRIBUTORS.md) (coming soon)

### Legal Inspiration

- Indian Consumer Protection Act, 2019
- National Consumer Disputes Redressal Commission (NCDRC)
- State Consumer Disputes Redressal Commissions
- Legal experts and community feedback

---

**Last Updated:** August 31, 2026  
**Version:** 1.0.0  
**Status:** Active Development
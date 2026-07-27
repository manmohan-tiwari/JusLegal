# JusLegal - Know Your Rights. Take Action.

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.0.0-orange)

## Overview

JusLegal is an AI-powered consumer legal assistant for Indian citizens, providing instant legal guidance based on Indian consumer law. It helps users understand their rights, take appropriate action, and navigate legal processes for common consumer issues like e-commerce disputes, banking fraud, travel problems, and more.

## Features

- **Structured Case Intake** - Collects incident category, date, disputed amount, involved party, reference number, and summary
- **Supporting Document Attachment** - Attachment support for files (jpg, jpeg, png, pdf, doc, docx) using filepicker
- **AI-Powered Legal Analysis** - OpenRouter with Groq fallback, securely proxied through a Cloudflare Worker
- **Consumer Law Focus** - Specialized for Indian consumer protection laws and regulations
- **Step-by-Step Guidance** - Clear action steps for resolving legal issues
- **Authority Directory** - Contact information for relevant regulatory bodies
- **Professional Document Generation** - Generate complaint letters and legal documents using advanced LLMs
- **Case Management** - Save and track your legal cases
- **Cross-Platform** - Works on Android and Web
- **Trust & Verification System** - Legal expert verification badges and transparent AI sourcing
- **Real User Testimonials** - Social proof with actual case outcomes and success stories
- **AI Responses** - Provider responses are requested as complete JSON results
- **Error Boundaries** - Graceful error handling with retry mechanisms
- **Bundled legal data** - `assets/legal_kb.json` is packaged with the app; AI analysis still requires network access

## Trust & Credibility Features

JusLegal addresses the fundamental trust issues in AI legal assistance through:

- **Transparent AI Sourcing** - Clear indication when advice is AI-generated vs legally verified
- **Legal Expert Verification** - Option for human-reviewed legal guidance on complex cases
- **Data Source Attribution** - References to specific Indian laws (Consumer Protection Act 2019, etc.)
- **Social Proof Integration** - Real user testimonials with actual monetary outcomes
- **Professional Disclaimers** - Clear guidance on AI limitations and when to consult lawyers
- **Trust-Building UI** - Banking-app color scheme and professional design patterns
- **Error Resilience** - Graceful failure handling with automatic fallback systems

**Languages & Frameworks:**
- Dart 3.2.3+
- Flutter 3.19.0+

**Core Libraries:**
- `flutter_riverpod` - State management
- `dio` - HTTP client for API calls
- `go_router` - Navigation and routing
- `hive_flutter` - Local data storage
- `firebase_core` - Firebase services
- `firebase_analytics` - Analytics tracking
- `firebase_crashlytics` - Error reporting
- `file_picker` - Document upload integration

## AI service setup

The app calls a Cloudflare Worker, which invokes OpenRouter first and Groq as
a fallback. This works on Android and web without exposing provider credentials
to the Flutter client.

## Prerequisites

Before setting up JusLegal, ensure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.19.0 or higher
- [Dart SDK](https://dart.dev/get-dart) 3.2.3 or higher
- Git for version control
- Code editor (VS Code recommended)

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mohan-70/juslegal.git
   cd juslegal
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Cloudflare Worker secrets:**
    - Follow the server-side secret setup in [AI API security and deployment](#ai-api-security-and-deployment).
    - Do not pass AI provider credentials to Flutter through `.env` or `--dart-define`.

4. **Set up Firebase (optional):**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Configure Analytics and Crashlytics for error tracking

5. **Run the app:**
   ```bash
   flutter run
   ```

## Usage

### Basic Legal Analysis

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juslegal/models/problem_model.dart';
import 'package:juslegal/providers/ai_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisProvider);
    
    return ElevatedButton(
      onPressed: () {
        final problem = ProblemModel(
          category: 'E-commerce & Shopping',
          dateOfIncident: '2026-06-01',
          disputedAmount: '5000',
          involvedParty: 'Defective Delivery Retailer',
          referenceNumber: 'ORDER-12345',
          summary: 'The order I received was damaged and customer service refused to refund or replace.',
          attachedFiles: [],
        );
        ref.read(analysisProvider.notifier).analyze(problem);
      },
      child: Text('Get Legal Guidance'),
    );
  }
}
```

### Accessing Analysis Results

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final result = ref.watch(analysisResultProvider);
  
  return result.when(
    data: (legalResult) => LegalResultDisplay(legalResult),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => Text('Error: $error'),
  );
}
```

## Configuration

### Server-side AI configuration

Provider secrets are configured in the Cloudflare Worker and are never passed
to the Flutter build. See the secret setup commands in the security section below.

### Firebase Setup (Optional)

For production deployment with Analytics and Crashlytics:

1. **Firebase Project Setup:**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Cloud Firestore, Analytics, and Crashlytics
   - Download configuration files for your platform

2. **Analytics & Monitoring:**
   - Firebase Analytics tracks user interactions and feature usage
   - Firebase Crashlytics reports errors and crashes automatically

## Project Structure

```
juslegal/
├── lib/
│   ├── core/                  # Core application logic
│   │   ├── constants/         # App constants and themes
│   │   ├── exceptions/        # Custom exception classes
│   │   └── router/           # Navigation configuration
│   ├── models/               # Data models
│   │   ├── authority_model.dart
│   │   ├── community_win_model.dart
│   │   ├── legal_case.dart
│   │   ├── legal_result_model.dart
│   │   ├── problem_model.dart
│   │   └── saved_case_model.dart
│   ├── providers/            # Riverpod state management
│   │   ├── ai_provider.dart
│   │   ├── cases_provider.dart
│   │   ├── complaint_provider.dart
│   │   └── problem_provider.dart
│   ├── screens/              # UI screens
│   │   ├── authorities_screen.dart
│   │   ├── complaint_generator_screen.dart
│   │   ├── home_screen.dart
│   │   ├── my_cases_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── privacy_policy_screen.dart
│   │   ├── problem_analyzer_screen.dart
│   │   ├── result_screen.dart
│   │   └── settings_screen.dart
│   ├── services/             # Business logic services
│   │   ├── ai_service.dart         # Orchestrates all AI services
│   │   ├── groq_service.dart       # Groq Worker integration
│   │   ├── openrouter_service.dart # OpenRouter Worker integration
│   │   ├── lkb_service.dart        # Legal knowledge base
│   │   ├── legal_compliance_service.dart # Legal validation
│   │   └── storage_service.dart    # Local database storage
│   └── widgets/              # Reusable UI components
├── assets/                  # Static assets
│   ├── legal_kb.json
│   ├── legal_kb_expanded.json
│   └── community_wins.json
├── .env.example             # Environment variables template
└── pubspec.yaml            # Dependencies and metadata
```

## AI API security and deployment

OpenRouter and Groq calls are made only by the Cloudflare Worker. The Flutter
client contains no AI provider credentials; the Worker handles web CORS.

Before the first deploy, set the server-side secrets from a trusted terminal:

```bash
cd juslegal-ai-proxy
wrangler secret put OPENROUTER_API_KEY
wrangler secret put GROQ_API_KEY
wrangler secret put PROXY_AUTH_TOKEN
wrangler deploy
```

The current Worker protection uses a shared proxy token. Provide the matching
value only through secure CI/build configuration, for example
`--dart-define=PROXY_AUTH_TOKEN=...`; never commit it. Replace this temporary
shared-token scheme with Firebase App Check or verified Firebase ID tokens for
per-user production authentication.

Any former client-side provider credentials should be revoked and replaced.
Never add provider keys, `.env` files, or service account JSON files to this
repository.

The root `package.json` and `package-lock.json` are empty legacy placeholders;
all Node dependencies and scripts live in `juslegal-ai-proxy/`.

`flutter_markdown` is currently used by the chat UI. It is retained for
compatibility; migration to a maintained Markdown renderer is a follow-up to
avoid changing current rendering behavior.

## Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
   ```bash
   git clone https://github.com/mohan-70/juslegal.git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Add tests for new features
   - Update documentation as needed

4. **Submit a Pull Request**
   - Push to your fork
   - Open a PR against the `main` branch
   - Describe your changes clearly

### Development Guidelines

- Follow [Flutter/Dart style guidelines](https://dart.dev/guides/language/effective-dart/style)
- Write clear, descriptive commit messages
- Add unit tests for new functionality
- Ensure all tests pass before submitting

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact / Credits

**Development Team:** JusLegal Contributors  
**Website:** [juslegal-2196.web.app](https://juslegal-2196.web.app)  
**Support:** [coming soon]  

**Special Thanks:**
- OpenRouter (primary) and Groq (fallback), via the secure Cloudflare Worker proxy
- Flutter community for the excellent framework
- All contributors who help improve this project


# JusLegal Configuration Guide

This guide explains how to properly configure your JusLegal Flutter application for development and production.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Firebase Configuration](#firebase-configuration)
3. [AI Provider Configuration](#ai-provider-configuration)
4. [Build Instructions](#build-instructions)
5. [Troubleshooting](#troubleshooting)
6. [Production Checklist](#production-checklist)

---

## Quick Start

### 1. Get Your API Keys

You need the following API keys for full functionality:

| Service | Where to Get | Required |
|---------|--------------|----------|
| Firebase | [Firebase Console](https://console.firebase.google.com/) | Yes |
| Gemini | [Google AI Studio](https://aistudio.google.com/apikey) | Recommended |
| Groq | [Groq Console](https://console.groq.com/keys) | Optional |
| OpenRouter | [OpenRouter](https://openrouter.ai/keys) | Optional |

### 2. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Enable the following services:
   - Firebase Analytics
   - Firebase Crashlytics
4. Add a Web app and copy the configuration
5. Download `google-services.json` for Android and `GoogleService-Info.plist` for iOS

### 3. Run with Configuration

```bash
flutter run \
  --dart-define=FIREBASE_WEB_API_KEY=your_firebase_key \
  --dart-define=GEMINI_API_KEY=your_gemini_key \
  --dart-define=GROQ_API_KEY=your_groq_key
```

---

## Firebase Configuration

### Getting Firebase Credentials

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Scroll to **Your apps** section
5. Find your Web app and copy these values:
   - API Key
   - App ID
   - Project ID
   - Messaging Sender ID

### Updating firebase_options.dart

Edit `lib/core/constants/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',           // Required
  appId: '1:123456789:web:abcdef123456',   // Required
  messagingSenderId: '123456789',           // Required
  projectId: 'your-project-id',             // Required
  authDomain: 'your-project.firebaseapp.com',
  storageBucket: 'your-project.appspot.com',
  measurementId: 'G-XXXXXXXXXX',            // Optional
);
```

### For Mobile Platforms

**Android:**
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. The Google Services Gradle plugin is already configured in:
   - `android/build.gradle` (classpath dependency)
   - `android/app/build.gradle` (plugin application)
4. The `firebase_options.dart` values are automatically synced from `google-services.json`

**iOS:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory

---

## AI Provider Configuration

### Gemini API (Recommended Primary)

1.  [Google AI Studio]
2.  Get your API key from https://aistudio.google.com/apikey
3. Use with: `--dart-define=GEMINI_API_KEY=your_key`

### Groq API (Fallback)

1.  [Groq Console]
2. Get your API key from https://console.groq.com/keys
3. Use with: `--dart-define=GROQ_API_KEY=your_key`

### OpenRouter API (Fallback)

1. [OpenRouter]
2. Get your API key from https://openrouter.ai/keys
3. Use with: `--dart-define=OPENROUTER_API_KEY=your_key`

---

## Build Instructions

### Debug Build (Development)

```bash
flutter run \
  --dart-define=FIREBASE_WEB_API_KEY=AIzaSy... \
  --dart-define=FIREBASE_WEB_APP_ID=1:123456789:web:abcdef \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456789 \
  --dart-define=GEMINI_API_KEY=your_gemini_key \
  --dart-define=GROQ_API_KEY=your_groq_key
```

### Release Build (Web)

```bash
flutter build web \
  --release \
  --dart-define=FIREBASE_WEB_API_KEY=AIzaSy... \
  --dart-define=FIREBASE_WEB_APP_ID=1:123456789:web:abcdef \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456789 \
  --dart-define=GEMINI_API_KEY=your_gemini_key \
  --dart-define=GROQ_API_KEY=your_groq_key
```

### Release Build (Android)

```bash
flutter build appbundle \
  --release \
  --dart-define=GEMINI_API_KEY=your_gemini_key \
  --dart-define=GROQ_API_KEY=your_groq_key \
  --dart-define=OPENROUTER_API_KEY=your_openrouter_key
```

### Using Environment File

Create a `.env` file from `.env.example` and use a tool like `flutter_dotenv` or a shell script to load variables.

---

## Troubleshooting

### Firebase Analytics Error: "API key not valid"

**Cause:** Firebase credentials are placeholder values.

**Solution:**
1. Update `lib/core/constants/firebase_options.dart` with real credentials
2. Or pass credentials via `--dart-define` flags

### AI Service Error: "API Key not found or invalid"

**Cause:** AI provider API keys are not configured.

**Solution:**
1. Get API keys from respective providers
2. Pass them via `--dart-define` flags when building

### App Falls Back to Mock Service

**Cause:** All AI services failed due to missing API keys.

**Solution:** Configure at least one AI provider API key.

### Firebase Web Config Failed to Load

**Cause:** Duplicate Firebase initialization in `web/index.html`.

**Solution:** This has been fixed. The `web/index.html` no longer contains duplicate Firebase initialization.

---

## Production Checklist

### Before Deploying to Production

- [ ] **Firebase Configuration**
  - [ ] Replace placeholder values in `firebase_options.dart`
  - [ ] Add `google-services.json` to `android/app/`
  - [ ] Add `GoogleService-Info.plist` to `ios/Runner/`
  - [ ] Enable Firebase Analytics in Firebase Console
  - [ ] Enable Firebase Crashlytics in Firebase Console
  - [ ] Configure Firebase Hosting (if using)

- [ ] **AI Provider Configuration**
  - [ ] Configure at least one AI provider (Gemini recommended)
  - [ ] Set up API key restrictions in provider consoles
  - [ ] Test AI service fallback chain

- [ ] **Security**
  - [ ] Never commit API keys to version control
  - [ ] Use environment variables or secure key management
  - [ ] Enable App Check in Firebase (recommended)
  - [ ] Set up API key restrictions by domain/package name

- [ ] **Testing**
  - [ ] Test on Web platform
  - [ ] Test on Android platform
  - [ ] Test on iOS platform (if applicable)
  - [ ] Verify analytics events are being logged
  - [ ] Verify Crashlytics is receiving crash reports
  - [ ] Test AI service with real API keys

- [ ] **Performance**
  - [ ] Enable code obfuscation for release builds
  - [ ] Optimize asset sizes
  - [ ] Enable tree shaking
  - [ ] Test app startup time

- [ ] **Legal & Compliance**
  - [ ] Update Privacy Policy URL
  - [ ] Update Terms of Service URL
  - [ ] Ensure proper disclaimers are displayed
  - [ ] Comply with data protection regulations (GDPR, etc.)

---

## File Structure Reference

```
lib/
├── core/
│   ├── config/
│   │   ├── env_config.dart          # Unified environment configuration
│   │   └── ai_runtime_config.dart   # AI runtime configuration (compatibility layer)
│   ├── constants/
│   │   ├── firebase_options.dart    # Firebase configuration
│   │   └── app_config.dart          # App-level configuration
│   └── services/
│       └── analytics_service.dart   # Safe analytics wrapper
├── services/
│   ├── ai_service.dart              # Main AI service
│   ├── gemini_service.dart          # Gemini provider
│   ├── groq_service.dart            # Groq provider
│   └── openrouter_service.dart      # OpenRouter provider
└── main.dart                         # App entry point
```

---

## Support

For issues and questions:
- Check the [Firebase Documentation](https://firebase.google.com/docs)
- Check the [Flutter Documentation](https://docs.flutter.dev)
- Review the `.env.example` file for configuration options
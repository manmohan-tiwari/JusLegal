# JusLegal — Google Play Store Listing & Compliance Kit

This document provides ready-to-copy metadata, store listing copy, compliance answers, and configuration details for publishing **JusLegal** to the Google Play Store Console.

---

## 1. App Identity & Basic Info

| Field | Content | Character Count / Constraint |
|---|---|---|
| **App Name** | `JusLegal: Consumer Rights & Law` | 30 / 30 chars (Max allowed: 30) |
| **Short Description** | `AI legal assistant for Indian citizens. Consumer rights, complaints & guidance.` | 78 / 80 chars (Max allowed: 80) |
| **Default Language** | English (India) – `en-IN` | |
| **Package Name** | `com.juslegal.app` | Unique Application ID |
| **App Category** | `Tools` (Secondary: `Books & Reference` or `Business`) | |
| **Tags / Keywords** | `Legal`, `Consumer Protection`, `RTI`, `Law Assistant`, `India`, `Complaints` | Max 5 tags in Play Console |

---

## 2. Store Listing Copy (Full Description)

```text
Know your rights. Take action with confidence.

JusLegal is India's dedicated AI-powered legal guidance assistant designed to empower citizens, consumers, and small business owners to navigate everyday legal challenges with clarity, dignity, and practical action plans.

Whether you are dealing with an undelivered online order, unfair airline cancellation charges, banking and UPI fraud, landlord-tenant security deposit disputes, or delayed government services, JusLegal helps you understand applicable Indian laws and gives you ready-to-use next steps.

━━━━━━━━━━━━━━━━━━━━
KEY CAPABILITIES
━━━━━━━━━━━━━━━━━━━━

⚖️ INTERACTIVE AI LEGAL ASSISTANT
Chat in simple, conversational language (English or Hindi). JusLegal guides you progressively through your situation without overwhelming you with legal jargon. Ask questions, clarify details, and get structured guidance tailored to Indian jurisdiction.

🛡️ CONSUMER COMPLAINT RESOLUTION
Step-by-step roadmaps to file grievances through official government portals:
• National Consumer Helpline (NCH / INGRAM - 1915)
• National Cyber Crime Reporting Portal (1930 / cybercrime.gov.in)
• RBI Banking Ombudsman (CMS Portal)
• DGCA AirSewa for flight delays, cancellations, and lost luggage
• District and State Consumer Disputes Redressal Commissions (e-Daakhil)

📝 READY-TO-SEND LEGAL NOTICES & DRAFTS
Generate tailored, professionally structured drafts directly on your phone:
• Formal Legal Notice to Sellers / Service Providers
• Right to Information (RTI) Applications under the RTI Act, 2005
• Consumer Court Complaints
• Bank & Cybercrime Escalation Letters
Export and share clean PDF documents in seconds.

🔒 PRIVACY-FIRST & SECURE
Your legal matters are sensitive. JusLegal stores your saved cases and chat history locally on your device with military-grade encryption. We do not sell your personal data or share your private case files for advertising.

━━━━━━━━━━━━━━━━━━━━
POPULAR CATEGORIES
━━━━━━━━━━━━━━━━━━━━
• E-Commerce & Retail: Defective goods, refund denials, fake products, non-delivery
• Banking & Digital Payments: Unauthorized transactions, UPI debits, credit card disputes, loan harassment
• Travel & Aviation: Flight cancellations, delayed refunds, baggage loss
• Real Estate & Tenancy: Unreturned security deposits, arbitrary rent hikes, maintenance disputes
• Healthcare & Insurance: Unfair medical billing, mediclaim rejection, delay in claim settlement
• Telecommunications & Utilities: Wrongful billing, service outages, porting issues

━━━━━━━━━━━━━━━━━━━━
IMPORTANT LEGAL DISCLAIMER
━━━━━━━━━━━━━━━━━━━━
JusLegal provides general legal information and procedural guidance based on Indian law. It is designed for educational and informational reference purposes only. JusLegal is NOT a law firm, does not provide formal legal representation, and does not establish a lawyer-client relationship. For complex, contentious, or criminal proceedings, always seek advice from an advocate licensed by the Bar Council of India.
```

---

## 3. Store Presence Visual Assets

All high-resolution production assets are generated and saved in `play_store_assets/`:

1. **App Icon**: `play_store_assets/play_store_icon_512x512.png`
   - Specifications: 512 x 512 px, 32-bit PNG, Official JusLegal logo (`assets/images/logo.png`) on clean white background.
2. **Feature Graphic**: `play_store_assets/feature_graphic_1024x500.png`
   - Specifications: 1024 x 500 px, high-resolution PNG, Deep Forest Green gradient, official JusLegal logo card, emerald typography, and feature pills.
3. **Phone Screenshots**:
   - Capture 4 to 8 high-resolution screenshots (minimum 1080 x 1920 px or 1080 x 2400 px, 16:9 or 19.5:9 aspect ratio) of:
     - 1. Home Dashboard / Category Selection
     - 2. AI Legal Chat Screen with progressive question/action
     - 3. Action Steps & Official Authority Portals (NCH, Cybercrime, RBI)
     - 4. Legal Document / Notice Generator (PDF Preview & Export)
     - 5. My Saved Cases Screen (Encrypted Local Storage)

---

## 4. Google Play Console Data Safety Section Guide

Use these exact declarations when filling out Google Play's **Data Safety Form**:

### A. Data Collection and Security
- **Does your app collect or share any of the required user data types?** -> **Yes**
- **Is all of the user data collected by your app encrypted in transit?** -> **Yes** (All requests use TLS/HTTPS)
- **Do you provide a way for users to request that their data be deleted?** -> **Yes** (In-app under *Settings > Account > Delete Account*, and by emailing *support@juslegal.app*)

### B. Specific Data Types:
1. **Personal Info**:
   - **Name**: Collected for account registration (Firebase Auth) & Document generation. Optional if using guest/anonymous. Ephemeral / account management.
   - **Email address**: Collected for authentication (Firebase Auth). Account management.
   - **Phone number**: Collected only if signing in via Phone OTP. Account management.
2. **Audio Files**:
   - **Voice or sound recordings**: Processed temporarily on-device / Google Speech Recognition when using the microphone button for speech-to-text. Not stored on remote servers, not shared.
3. **App Info and Performance**:
   - **Crash logs**: Collected via Firebase Crashlytics to diagnose errors (User can toggle off in Settings).
   - **Diagnostics**: Anonymous app performance monitoring.
4. **App Activity**:
   - **App interactions**: Page views and actions collected via Firebase Analytics (User can toggle off in Settings).

---

## 5. Content Rating Questionnaire Guide (IARC)

| Section | Answer |
|---|---|
| **Violence, Sexual Content, Offensive Language** | No / None |
| **Controlled Substances, Alcohol, Tobacco, Gambling** | No |
| **User-generated content or user-to-user communications** | No (Users only interact with the automated assistant and save private cases) |
| **Physical Location Sharing** | No |
| **Digital Purchases / In-app purchases** | No (Free guidance application) |
| **Expected Rating** | **Everyone (3+)** or **PEGI 3** / **USK 0** |

---

## 6. App Access / Review Instructions for Google Play Team

Provide this in the **App Access** section of the Google Play Console:

```text
The app can be fully explored without any mandatory sign-in or paywall. 
To test authenticated features:
1. Google Sign-in: You can sign in using any standard Google account on test devices.
2. Phone OTP: Use the pre-configured Firebase Auth test phone number:
   Phone: +91 9999999999
   OTP: 123456
All AI features and document generation are fully functional in test mode.
Support Contact: support@juslegal.app
```

---

## 7. Mandatory Policy URLs

- **Privacy Policy URL**: `https://juslegal-2196.web.app/privacy` (or custom domain `https://juslegal.app/privacy`)
- **Terms of Service URL**: `https://juslegal-2196.web.app/terms` (or `https://juslegal.app/terms`)
- **Account Deletion Instructions URL**: `https://juslegal-2196.web.app/privacy#deletion`

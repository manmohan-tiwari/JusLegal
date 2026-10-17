import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:juslegal/core/core.dart';

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {

  Widget _section(
    BuildContext context, {
    required String title,
    required List<String> bullets,
    String? body,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.deepNavy,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 10),
            Text(
              body,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.slateBlue,
                height: 1.5,
              ),
            ),
          ],
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...bullets.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.mustardGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.deepNavy,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.warmOffWhite,
        elevation: 0,
        leading: BackButton(
          color: AppColors.deepNavy,
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepNavy.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.mustardGold.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.mustardGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.mustardGold,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'This page explains how JusLegal handles your information when you use the app for legal guidance.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.paleBlue,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _section(
                context,
                title: '1. Information We Collect',
                body:
                    'JusLegal is designed to give you access to consumer legal guidance without requiring unnecessary personal information. When you use the app, we may collect the following types of information:',
                bullets: const [
                  'Account information: When you sign in (via Google, phone OTP, or email), we collect your basic authentication identifiers (email address, phone number, or Google profile ID) as provided by Firebase Authentication. This is used solely to identify you across sessions and secure your saved data.',
                  'Legal issue details you submit: Any text, descriptions, or case details you type into the app when requesting analysis, generating documents, or using the AI chat. This information is needed to produce the guidance you request.',
                  'Saved cases: Case data you choose to save on your device (stored locally via Hive and, where applicable, tied to your authenticated account ID).',
                  'Diagnostics and usage data: With your consent, anonymous diagnostics and crash information used to improve app stability, reliability, and performance. You can change this at any time from within the app.',
                  'Device and technical information: Basic device information (app version, operating system, browser type) required to deliver the service and diagnose compatibility issues.',
                ],
              ),
              _section(
                context,
                title: '2. How We Use Data',
                body: 'We use the information we collect only to provide, improve, and secure the JusLegal service.',
                bullets: const [
                  'To generate legal guidance, case analyses, document drafts, and chat responses when you request them.',
                  'To save your cases locally on your device so you can return to them later.',
                  'To authenticate you and secure access to your account if you choose to sign in.',
                  'To improve the reliability, security, and performance of JusLegal (with your consent where required by law).',
                  'To communicate with you about critical service updates, account security, or in response to support requests.',
                  'To comply with applicable laws, regulations, and valid legal process.',
                ],
              ),
              _section(
                context,
                title: '3. Third Party Services',
                body:
                    'JusLegal uses reputable third-party services to provide core features. Data is shared with these providers only to the extent necessary to deliver the feature you requested, and each operates under its own terms and privacy policy.',
                bullets: const [
                  'Firebase (Google): Used for authentication (email, phone OTP, Google sign-in), optional analytics, optional crash reporting, and app hosting. See Firebase\'s privacy policy at firebase.google.com/support/privacy.',
                  'AI Service Providers: When you submit a legal question or request document generation, relevant text is sent to our configured AI providers to produce an answer, identify applicable laws, and suggest next steps.',
                  'Google Sign-In: If you choose to continue with Google, Google\'s terms and privacy policy apply to the sign-in flow.',
                ],
              ),
              _section(
                context,
                title: '4. AI Processing Notice',
                body:
                    'When you submit a legal question, problem description, or document to JusLegal, relevant text may be sent to our AI service providers to generate an answer, identify relevant laws, and suggest practical next steps. Please note the following:',
                bullets: const [
                  'All AI output is informational and general in nature.',
                  'It is NOT legal representation, formal legal advice, a lawyer-client relationship, or a substitute for advice from a qualified advocate.',
                  'Do not rely on AI-generated content as the sole basis for important legal decisions — always consult a licensed advocate for serious, criminal, or time-sensitive matters.',
                ],
              ),
              _section(
                context,
                title: '5. Account & Data Deletion',
                body:
                    'You can permanently delete your account and all associated data at any time, using either of the following methods:',
                bullets: const [
                  'In the app: go to Settings > Account > Delete Account. Follow the confirmation steps (type DELETE and, if required, re-authenticate) to permanently remove your account, all saved cases, and your Firebase authentication record. This action cannot be undone.',
                  'By email: send a deletion request to support@juslegal.app from your registered email address. Please include your account details so we can verify ownership. We will process your request within a reasonable timeframe and confirm deletion by reply.',
                ],
              ),
              _section(
                context,
                title: '6. Data Storage & Security',
                bullets: const [
                  'Saved cases are stored locally on your device using Hive, an on-device storage library. Case data does not leave your device unless you explicitly share or export it.',
                  'Account authentication is handled by Firebase Authentication, which secures credentials using industry-standard encryption.',
                  'We implement reasonable technical and organizational safeguards to protect your information, but no method of transmission or storage is 100% secure.',
                ],
              ),
              _section(
                context,
                title: '7. User Rights',
                body:
                    'Depending on your jurisdiction, you may have rights under applicable data protection laws. You can exercise these rights directly in the app or by contacting us.',
                bullets: const [
                  'Access: You may review saved cases stored on your device from the "My Cases" screen.',
                  'Deletion: You may delete individual cases from the "My Cases" screen, or permanently delete your entire account and all data as described in Section 5 above.',
                  'Withdraw consent: You can change or withdraw your consent to analytics and crash reporting at any time from within the app.',
                  'Opt out: You can choose not to submit personal information or sign in; you can still use many JusLegal features without an account.',
                  'Contact us: You may reach out at any time for questions about this policy or how we handle your data.',
                ],
              ),
              _section(
                context,
                title: '8. Children\'s Privacy',
                bullets: const [
                  'JusLegal is not directed to children under the age of 13, and we do not knowingly collect personal information from children. If you believe a child has provided us with personal information, please contact us and we will promptly delete it.',
                ],
              ),
              _section(
                context,
                title: '9. Changes to This Policy',
                bullets: const [
                  'We may update this Privacy Policy from time to time. When we make material changes, we will update the "Last updated" date below and, where appropriate, notify you through the app or by email. Your continued use of JusLegal after changes become effective constitutes acceptance of the revised policy.',
                ],
              ),
              _section(
                context,
                title: '10. Contact Information',
                body: 'For privacy questions, deletion requests, or support, contact the JusLegal team at:',
                bullets: [
                  AppConfig.supportEmail,
                ],
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Privacy Controls',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You can control whether JusLegal collects analytics and crash reporting data.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.slateBlue,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildConsentToggle(
                      'Analytics',
                      'Help us improve the app by collecting anonymous usage data',
                      SafeAnalytics.analyticsEnabled,
                      (value) async {
                        if (value) {
                          await SafeAnalytics.enableAnalytics();
                        } else {
                          await SafeAnalytics.disableAnalytics();
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildConsentToggle(
                      'Crash Reporting',
                      'Help us fix bugs by collecting crash reports',
                      SafeAnalytics.crashlyticsEnabled,
                      (value) async {
                        if (value) {
                          await SafeAnalytics.enableCrashlytics();
                        } else {
                          await SafeAnalytics.disableCrashlytics();
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const Text(
                'Last updated: 26 August 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.slateBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentToggle(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.slateBlue,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.deepNavy,
          activeTrackColor: AppColors.mustardGold,
        ),
      ],
    );
  }
}


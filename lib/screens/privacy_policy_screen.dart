import 'package:flutter/material.dart';

import '../core/constants/app_config.dart';
import '../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _section(
    BuildContext context, {
    required String title,
    required List<String> bullets,
    String? body,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          if (body != null) ...[
            const SizedBox(height: 10),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
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
                          color: AppTheme.legalGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        bullet,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.trustBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: const Icon(
                        Icons.privacy_tip_outlined,
                        color: AppTheme.trustBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Privacy Policy', style: textTheme.headlineSmall),
                          const SizedBox(height: 6),
                          Text(
                            'This page explains how JusLegal handles your information when you use the app for legal guidance.',
                            style: textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
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
                title: 'Information We Collect',
                bullets: const [
                  'Legal issue details you type into the app.',
                  'Case data you choose to save locally.',
                  'Diagnostics and crash information used to improve app stability.',
                ],
              ),
              _section(
                context,
                title: 'How We Use Data',
                bullets: const [
                  'To generate legal guidance and case summaries.',
                  'To save your cases and restore them later.',
                  'To improve the reliability, security, and performance of JusLegal.',
                ],
              ),
              _section(
                context,
                title: 'Third Party Services',
                body: 'JusLegal may use third-party services such as Firebase for analytics and crash reporting, and AI providers to generate responses when analysis is requested.',
                bullets: const [
                  'Only the data needed to provide the requested feature is processed.',
                  'Service providers may process data under their own terms and privacy policies.',
                ],
              ),
              _section(
                context,
                title: 'AI Processing Notice',
                body: 'When you submit a legal question, relevant text may be sent to AI services to generate an answer, identify laws, and suggest next steps.',
                bullets: const [
                  'AI output is informational only.',
                  'Do not rely on it as legal representation or formal legal advice.',
                ],
              ),
              _section(
                context,
                title: 'User Rights',
                bullets: const [
                  'You may review and delete cases stored on your device.',
                  'You can choose not to submit personal information if you prefer.',
                  'You may contact us for questions about this policy or your data handling.',
                ],
              ),
              _section(
                context,
                title: 'Contact Information',
                body: 'For privacy questions or support, contact the JusLegal team at:',
                bullets: [
                  AppConfig.supportEmail,
                ],
              ),
              Text(
                'Last updated: 2 June 2026',
                style: textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

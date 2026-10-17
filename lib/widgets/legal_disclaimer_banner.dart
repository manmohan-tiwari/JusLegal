import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:juslegal/core/core.dart';

class LegalDisclaimerBanner extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const LegalDisclaimerBanner({
    super.key,
    this.margin,
    this.padding,
  });

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AppConfig.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Semantics(
      button: true,
      label: 'AI-generated legal information only. Not legal advice.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPrivacyPolicy(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            margin: margin ?? const EdgeInsets.only(top: 12),
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFD4E2EC),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: AppColors.deepNavy,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI-generated legal information only. Not legal advice.',
                    style: const TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LegalDisclaimer extends LegalDisclaimerBanner {
  const LegalDisclaimer({
    super.key,
    super.margin,
    super.padding,
  });
}


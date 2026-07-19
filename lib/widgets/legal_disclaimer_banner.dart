import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class LegalDisclaimerBanner extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const LegalDisclaimerBanner({
    super.key,
    this.margin,
    this.padding,
  });

  void _openPrivacyPolicy(BuildContext context) {
    context.push('/privacy-policy');
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
              color: AppTheme.legalGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.legalGold.withValues(alpha: 0.65),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 18,
                  color: AppTheme.legalGold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI-generated legal information only. Not legal advice.',
                    style: TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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

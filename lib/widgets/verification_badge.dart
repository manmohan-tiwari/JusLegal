import 'package:flutter/material.dart';
import '../core/config/theme_config.dart';

enum VerificationType {
  ai,
  legalExpert,
  userTestimonial,
}

class VerificationBadge extends StatelessWidget {
  final VerificationType type;
  final String? text;
  final bool showTooltip;

  const VerificationBadge({
    super.key,
    required this.type,
    this.text,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 14,
            color: _getIconColor(),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text ?? _getDefaultText(),
              style: const TextStyle(
                    color: AppTheme.mediumText,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ).copyWith(
                color: _getTextColor(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case VerificationType.legalExpert:
      case VerificationType.userTestimonial:
        return AppTheme.legalGold.withValues(alpha: 0.08);
      case VerificationType.ai:
        return AppTheme.primaryBlue.withValues(alpha: 0.08);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case VerificationType.legalExpert:
      case VerificationType.userTestimonial:
        return AppTheme.legalGold.withValues(alpha: 0.55);
      case VerificationType.ai:
        return AppTheme.primaryBlue.withValues(alpha: 0.55);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case VerificationType.legalExpert:
      case VerificationType.userTestimonial:
        return AppTheme.darkText;
      case VerificationType.ai:
        return AppTheme.primaryBlue;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case VerificationType.legalExpert:
      case VerificationType.userTestimonial:
        return AppTheme.legalGold;
      case VerificationType.ai:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case VerificationType.legalExpert:
        return Icons.verified_user_rounded;
      case VerificationType.userTestimonial:
        return Icons.person_rounded;
      case VerificationType.ai:
        return Icons.smart_toy_rounded;
    }
  }

  String _getDefaultText() {
    switch (type) {
      case VerificationType.legalExpert:
        return 'Verified by Legal Expert';
      case VerificationType.userTestimonial:
        return 'Real User Success';
      case VerificationType.ai:
        return 'AI Analysis';
    }
  }
}


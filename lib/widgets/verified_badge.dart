import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified_rounded, color: AppTheme.legalGold, size: 18),
        SizedBox(width: 6),
        Text(
          'Verified by Legal Expert',
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

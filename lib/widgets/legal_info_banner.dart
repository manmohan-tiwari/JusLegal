import 'package:flutter/material.dart';

import 'package:juslegal/core/core.dart';

class LegalInfoBanner extends StatelessWidget {
  final String message;
  final CrossAxisAlignment crossAxisAlignment;

  const LegalInfoBanner({
    super.key,
    required this.message,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.legalGold.withValues(alpha: 0.10),
        border: Border.all(color: AppColors.legalGold),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.legalGold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryNavy,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

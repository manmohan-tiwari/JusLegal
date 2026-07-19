import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.legalGold.withValues(alpha: 0.10),
        border: Border.all(
          color: AppColors.legalGold,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.legalGold,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI-generated documents only. Review carefully and consult a lawyer before use.',
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
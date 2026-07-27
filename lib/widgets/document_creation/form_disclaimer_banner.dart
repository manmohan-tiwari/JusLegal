import 'package:flutter/material.dart';
import '../../core/config/theme_config.dart';

class FormDisclaimerBanner extends StatelessWidget {
  const FormDisclaimerBanner({super.key});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.legalGold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'These are draft templates only. Verify with the concerned authority before submission. JusLegal is not responsible for rejection of forms.',
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

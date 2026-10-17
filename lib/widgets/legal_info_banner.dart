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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        border: Border.all(color: const Color(0xFFD4E2EC)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.slateBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

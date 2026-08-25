import 'package:flutter/material.dart';

import '../core/config/theme_config.dart';

class DocumentTypeChipBase extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DocumentTypeChipBase({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded,
                size: 14, color: AppColors.trustBlue),
          ],
        ),
      ),
    );
  }
}

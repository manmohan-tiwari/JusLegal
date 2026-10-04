import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';

class CaseHeaderImageWidget extends StatelessWidget {
  final String caseTitle;
  final String category;

  const CaseHeaderImageWidget({
    super.key,
    required this.caseTitle,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy,
            AppTheme.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.legalGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: AppTheme.legalGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  caseTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.legalGold,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

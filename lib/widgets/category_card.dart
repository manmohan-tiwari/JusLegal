import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';
import 'hover_stay_reveal_box.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusL);
    return HoverStayRevealBox(
      onTap: onTap,
      borderRadius: radius,
      builder: (context, isRevealed) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: radius,
            border: Border.all(
              color: isRevealed
                  ? AppColors.deepNavy.withValues(alpha: 0.35)
                  : AppColors.outline,
              width: isRevealed ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isRevealed
                    ? AppColors.deepNavy.withValues(alpha: 0.12)
                    : AppColors.shadow,
                blurRadius: isRevealed ? 16 : 12,
                offset: Offset(0, isRevealed ? 6 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isRevealed
                      ? AppColors.mustardGold.withValues(alpha: 0.25)
                      : AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              HoverRevealContent(
                isRevealed: isRevealed,
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



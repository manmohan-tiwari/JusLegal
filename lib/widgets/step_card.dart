import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';
import 'hover_stay_reveal_box.dart';

class StepCard extends StatelessWidget {
  final int index;
  final String? title;
  final String text;

  const StepCard({
    super.key,
    required this.index,
    this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // Alternate badges between Mustard Gold and Pale Blue like in Screenshot 2
    final isGold = index % 2 == 0;
    final badgeBg = isGold ? AppColors.mustardGold : AppColors.paleBlue;
    final badgeTextColor = AppColors.deepNavy;
    final formattedNumber = (index + 1).toString().padLeft(2, '0');
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final radius = BorderRadius.circular(AppTheme.radiusL);

    return HoverStayRevealBox(
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
                blurRadius: isRevealed ? 14 : 10,
                offset: Offset(0, isRevealed ? 5 : 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isGold
                          ? AppColors.mustardGold.withValues(alpha: 0.28)
                          : AppColors.navyBlue.withValues(alpha: 0.12),
                      blurRadius: isRevealed ? 12 : 8,
                      offset: Offset(0, isRevealed ? 4 : 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  formattedNumber,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasTitle) ...[
                      Text(
                        title!,
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
                          text,
                          style: const TextStyle(
                            color: AppColors.navyBlue,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ] else ...[
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: isRevealed
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.deepNavy,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        secondChild: Text(
                          text,
                          style: const TextStyle(
                            color: AppColors.navyBlue,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



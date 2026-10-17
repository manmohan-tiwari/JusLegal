import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';
import 'hover_stay_reveal_box.dart';

class AuthorityCard extends StatelessWidget {
  final String name;
  final String? purpose;
  final String action;
  final VoidCallback onAction;

  const AuthorityCard({
    super.key,
    required this.name,
    this.purpose,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusL);
    return HoverStayRevealBox(
      onTap: onAction,
      borderRadius: radius,
      builder: (context, isRevealed) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isRevealed
                      ? AppColors.mustardGold.withValues(alpha: 0.25)
                      : AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  size: 24,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.deepNavy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (purpose != null && purpose!.isNotEmpty)
                      HoverRevealContent(
                        isRevealed: isRevealed,
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          purpose!,
                          style: const TextStyle(
                            color: AppColors.navyBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action,
                    style: const TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 180),
                    offset: isRevealed ? const Offset(0.25, 0) : Offset.zero,
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.mustardGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}



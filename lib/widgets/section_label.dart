import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final String? number;
  final bool showDivider;

  const SectionLabel(
    this.title, {
    super.key,
    this.number,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (number != null && number!.isNotEmpty) ...[
              Text(
                number!,
                style: const TextStyle(
                  color: AppColors.mustardGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
            ] else ...[
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.mustardGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 8),
          const Divider(
            color: AppColors.divider,
            thickness: 1,
            height: 1,
          ),
        ],
      ],
    );
  }
}


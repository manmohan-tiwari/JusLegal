import 'package:flutter/material.dart';
import '../../core/config/theme_config.dart';

class SectionLabel extends StatelessWidget {
  final String title;

  const SectionLabel(
    this.title, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          color: AppColors.trustBlue,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}

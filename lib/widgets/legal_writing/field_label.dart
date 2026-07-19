import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
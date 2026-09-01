import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';

class ComplaintButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  const ComplaintButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.legalGold,
          foregroundColor: AppColors.white,
          elevation: 8,
          shadowColor: AppColors.shadowGold,
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}


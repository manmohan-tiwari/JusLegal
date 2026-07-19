import '../constants/app_colors.dart';
import 'package:flutter/material.dart';

class ConfidenceUtils {
  static Color colorFor(int confidence) {
    if (confidence >= 85) return AppColors.success;
    if (confidence >= 60) return Colors.amber[700]!;
    return AppColors.error;
  }

  static String disclaimerFor(int confidence) {
    if (confidence >= 85) {
      return 'High confidence guidance based on verified sources.';
    } else if (confidence >= 60) {
      return 'Some details may vary. Verify with a legal expert.';
    } else {
      return 'This case is complex. We recommend consulting a lawyer.';
    }
  }
}

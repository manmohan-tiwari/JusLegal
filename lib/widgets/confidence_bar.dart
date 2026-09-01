import 'package:flutter/material.dart';
import 'package:juslegal/core/core.dart';

class ConfidenceBar extends StatelessWidget {
  final int confidence;
  const ConfidenceBar({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(confidence);
    final disclaimer = _disclaimerFor(confidence);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: confidence / 100.0,
            minHeight: 10,
            color: color,
            backgroundColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 8),
        Text('$confidence% confidence • $disclaimer',
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _colorFor(int confidence) {
    if (confidence >= 85) return AppColors.success;
    if (confidence >= 60) return Colors.amber[700]!;
    return AppColors.error;
  }

  String _disclaimerFor(int confidence) {
    if (confidence >= 85) {
      return 'High confidence guidance based on verified sources.';
    }
    if (confidence >= 60) {
      return 'Some details may vary. Verify with a legal expert.';
    }
    return 'This case is complex. We recommend consulting a lawyer.';
  }
}

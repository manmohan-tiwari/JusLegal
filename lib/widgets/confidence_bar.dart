import 'package:flutter/material.dart';
import '../core/utils/confidence_utils.dart';

class ConfidenceBar extends StatelessWidget {
  final int confidence;
  const ConfidenceBar({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final color = ConfidenceUtils.colorFor(confidence);
    final disclaimer = ConfidenceUtils.disclaimerFor(confidence);
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
}

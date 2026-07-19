import 'package:flutter/material.dart';

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
        child: Text(label),
      ),
    );
  }
}

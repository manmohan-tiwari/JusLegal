import 'package:flutter/material.dart';

import '../document_type_chip_base.dart';

class DocumentTypeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DocumentTypeChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DocumentTypeChipBase(label: label, onTap: onTap);
  }
}

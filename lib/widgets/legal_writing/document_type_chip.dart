import 'package:flutter/material.dart';

import '../../models/document_type_model.dart';
import '../document_type_chip_base.dart';

class DocumentTypeChip extends StatelessWidget {
  final DocumentType type;
  final VoidCallback onTap;

  const DocumentTypeChip({
    super.key,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DocumentTypeChipBase(label: type.label, onTap: onTap);
  }
}

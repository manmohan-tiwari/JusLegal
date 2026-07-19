import 'package:flutter/material.dart';
import 'document_type_model.dart';

class DocumentCategory {
  final String label;
  final IconData icon;
  final List<DocumentType> types;

  const DocumentCategory({
    required this.label,
    required this.icon,
    required this.types,
  });
}
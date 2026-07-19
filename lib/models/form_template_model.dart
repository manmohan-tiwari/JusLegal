import 'package:flutter/material.dart';

import 'form_field_model.dart';

class FormTemplateModel {
  final String id;
  final String title;
  final String subtitle;
  final String authority;
  final String actReference;
  final IconData? icon;
  final List<FormFieldModel> fields;
  final String instructions;
  final List<String> documents;

  const FormTemplateModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.authority,
    required this.actReference,
    required this.fields,
    required this.instructions,
    required this.documents,
    this.icon,
  });
}

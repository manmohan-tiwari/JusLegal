enum FormFieldType {
  text,
  textarea,
  date,
  number,
  phone,
  email,
  dropdown,
  checkbox,
}

class FormFieldModel {
  final String key;
  final String label;
  final FormFieldType type;
  final bool required;
  final String hint;
  final List<String> options; // for dropdown
  final int maxLines;         // for textarea
  final String? prefix;       // e.g. "₹" for amount fields

  const FormFieldModel({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.hint = '',
    this.options = const [],
    this.maxLines = 1,
    this.prefix,
  });
}
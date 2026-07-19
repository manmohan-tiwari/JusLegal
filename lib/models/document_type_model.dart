class DocumentType {
  final String id;
  final String label;
  final String description;
  final String promptHint;
  final List<String> requiredFields;

  const DocumentType({
    required this.id,
    required this.label,
    required this.description,
    required this.promptHint,
    required this.requiredFields,
  });
}
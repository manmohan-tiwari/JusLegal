import '../models/document_category_model.dart';
import '../models/document_type_model.dart';

class LegalDocumentService {
  const LegalDocumentService();

  String buildPrompt({
    required DocumentType type,
    required DocumentCategory category,
    required String tone,
    required Map<String, String> fields,
    String additionalDetails = '',
  }) {
    final fieldsText = fields.entries
        .map(
          (e) =>
              '${e.key}: ${e.value.trim().isEmpty ? "Not provided" : e.value.trim()}',
        )
        .join('\n');

    return '''
You are a professional Indian legal document drafter.

Draft a complete professional "${type.label}" document.

DOCUMENT TYPE: ${type.label}
CATEGORY: ${category.label}
TONE: $tone

DETAILS PROVIDED:
$fieldsText

${additionalDetails.isNotEmpty ? '\nADDITIONAL DETAILS:\n$additionalDetails' : ''}

INSTRUCTIONS:
- Write only the document
- Use proper legal formatting
- Use Indian legal terminology
- Include headings and clauses where appropriate
- Use placeholders for missing information
- Include signature blocks where applicable

Generate the complete document now.
''';
  }

  String cleanResponse(String response) {
    String clean = response.trim();

    if (clean.startsWith('```')) {
      final lines = clean.split('\n');

      if (lines.length > 2) {
        clean = lines.sublist(1, lines.length - 1).join('\n');
      }
    }

    return clean.trim();
  }
}
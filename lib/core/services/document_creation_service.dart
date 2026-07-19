import '../../models/form_template_model.dart';
import '../../models/form_field_model.dart';
import '../../core/constants/form_templates.dart';
import '../../services/ai_service.dart';

class DocumentCreationService {
  final AIService _aiService;

  DocumentCreationService(this._aiService);

  List<FormTemplateModel> getAllForms() => FormTemplates.all;

  FormTemplateModel? getFormById(String id) => FormTemplates.getById(id);

  // Build filled form as plain text (for preview + copy)
  String buildFilledFormText({
    required FormTemplateModel template,
    required Map<String, String> values,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('=' * 60);
    buffer.writeln(template.title.toUpperCase());
    buffer.writeln(template.actReference);
    buffer.writeln('Submit to: ${template.authority}');
    buffer.writeln('=' * 60);
    buffer.writeln();

    for (final field in template.fields) {
      final value = values[field.key]?.trim() ?? '';
      if (value.isEmpty && !field.required) continue;

      buffer.writeln(field.label.toUpperCase());
      buffer.writeln(value.isEmpty ? '[Not Provided]' : value);
      buffer.writeln();
    }

    buffer.writeln('-' * 60);
    buffer.writeln('DECLARATION');
    buffer.writeln(
        'I hereby declare that the information furnished above is true '
        'and correct to the best of my knowledge and belief.');
    buffer.writeln();
    buffer.writeln('Date: _______________');
    buffer.writeln();
    buffer.writeln('Signature: _______________');
    buffer.writeln();
    buffer.writeln('Name: ${values['complainant_name'] ?? values['applicant_name'] ?? values['claimant_name'] ?? values['worker_name'] ?? '[Name]'}');
    buffer.writeln('=' * 60);

    return buffer.toString();
  }

  // AI-enhanced version — fills gaps, improves language
  Future<String> buildAIEnhancedForm({
    required FormTemplateModel template,
    required Map<String, String> values,
  }) async {
    final filledText = buildFilledFormText(
      template: template,
      values: values,
    );

    final fieldsText = template.fields.map((f) {
      final value = values[f.key]?.trim() ?? '';
      return '${f.label}: ${value.isEmpty ? "Not provided" : value}';
    }).join('\n');

    final prompt = '''
You are an expert Indian legal document drafter.

The user is filling a "${template.title}" form under ${template.actReference}.
This form will be submitted to: ${template.authority}

USER PROVIDED DETAILS:
$fieldsText

TASK:
Draft a complete, formal, ready-to-print "${template.title}" using the details above.

FORMAT RULES:
- Use proper legal document formatting
- Include all standard sections for this type of form
- Use formal legal language
- For missing required details use [bracketed placeholders]
- Include proper declaration, date and signature block at the end
- Make it look like an official filled form
- Cite the relevant act/section where appropriate

Write ONLY the complete filled form document. No explanations.
''';

    try {
      final result = await _aiService.analyzeProblemFromText(prompt);
      // Extract best text from result
      final summary = (result['caseSummary'] ?? '').toString();
      final analysis = (result['legalAnalysis'] ?? '').toString();

      // If AI returned meaningful content use it, else fallback to plain text
      if (summary.length > 100) {
        return '$summary\n\n$analysis';
      }
      return filledText;
    } catch (_) {
      return filledText;
    }
  }

  // Validate form — returns map of fieldKey -> error message
  Map<String, String> validateForm({
    required FormTemplateModel template,
    required Map<String, String> values,
  }) {
    final errors = <String, String>{};

    for (final field in template.fields) {
      if (!field.required) continue;
      final value = values[field.key]?.trim() ?? '';
      if (value.isEmpty) {
        errors[field.key] = '${field.label} is required';
        continue;
      }
      // Type-specific validation
      switch (field.type) {
        case FormFieldType.phone:
          if (value.length != 10 || int.tryParse(value) == null) {
            errors[field.key] = 'Enter valid 10-digit phone number';
          }
          break;
        case FormFieldType.email:
          if (!value.contains('@') || !value.contains('.')) {
            errors[field.key] = 'Enter valid email address';
          }
          break;
        case FormFieldType.number:
          if (double.tryParse(value) == null) {
            errors[field.key] = 'Enter valid number';
          }
          break;
        default:
          break;
      }
    }

    return errors;
  }
}

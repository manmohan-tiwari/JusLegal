import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/form_field_model.dart';
import '../models/form_template_model.dart';
import '../core/config/templates.dart';
import 'ai_service.dart';

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

  // AI-enhanced version â€” fills gaps, improves language
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

  // Validate form â€” returns map of fieldKey -> error message
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


// â”€â”€ AI Service provider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

final _aiServiceProvider = Provider<AIService>((ref) {
  final svc = AIService();
  svc.initialize();
  return svc;
});

// â”€â”€ Document Creation Service provider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

final documentCreationServiceProvider = Provider<DocumentCreationService>((ref) {
  return DocumentCreationService(ref.read(_aiServiceProvider));
});

// â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

enum DocumentCreationStatus { idle, loading, success, error }

class DocumentCreationState {
  final FormTemplateModel? selectedForm;
  final Map<String, String> fieldValues;
  final Map<String, String> fieldErrors;
  final DocumentCreationStatus status;
  final String? generatedText;
  final String? errorMessage;
  final bool useAI; // AI-enhanced vs plain filled form

  const DocumentCreationState({
    this.selectedForm,
    this.fieldValues = const {},
    this.fieldErrors = const {},
    this.status = DocumentCreationStatus.idle,
    this.generatedText,
    this.errorMessage,
    this.useAI = true,
  });

  DocumentCreationState copyWith({
    FormTemplateModel? selectedForm,
    Map<String, String>? fieldValues,
    Map<String, String>? fieldErrors,
    DocumentCreationStatus? status,
    String? generatedText,
    String? errorMessage,
    bool? useAI,
    bool clearSelected = false,
    bool clearGenerated = false,
    bool clearErrors = false,
  }) {
    return DocumentCreationState(
      selectedForm: clearSelected ? null : (selectedForm ?? this.selectedForm),
      fieldValues: fieldValues ?? this.fieldValues,
      fieldErrors: clearErrors ? {} : (fieldErrors ?? this.fieldErrors),
      status: status ?? this.status,
      generatedText: clearGenerated ? null : (generatedText ?? this.generatedText),
      errorMessage: errorMessage ?? this.errorMessage,
      useAI: useAI ?? this.useAI,
    );
  }

  bool get hasSelectedForm => selectedForm != null;
  bool get isLoading => status == DocumentCreationStatus.loading;
  bool get isSuccess => status == DocumentCreationStatus.success;
  bool get hasError => status == DocumentCreationStatus.error;
  bool get hasGenerated => generatedText != null && generatedText!.isNotEmpty;
}

// â”€â”€ Notifier â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class DocumentCreationNotifier extends Notifier<DocumentCreationState> {
  late final DocumentCreationService _service;

  @override
  DocumentCreationState build() {
    _service = ref.read(documentCreationServiceProvider);
    return const DocumentCreationState();
  }

  // Select a form template
  void selectForm(FormTemplateModel form) {
    state = DocumentCreationState(
      selectedForm: form,
      fieldValues: {},
      fieldErrors: {},
      status: DocumentCreationStatus.idle,
      useAI: state.useAI,
    );
  }

  // Update a single field value
  void updateField(String key, String value) {
    final updated = Map<String, String>.from(state.fieldValues);
    updated[key] = value;

    // Clear error for this field if value is now filled
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    if (value.trim().isNotEmpty) {
      updatedErrors.remove(key);
    }

    state = state.copyWith(
      fieldValues: updated,
      fieldErrors: updatedErrors,
    );
  }

  // Toggle AI enhancement
  void toggleAI(bool value) {
    state = state.copyWith(useAI: value);
  }

  // Validate and generate
  Future<void> generateForm() async {
    if (state.selectedForm == null) return;

    // Validate first
    final errors = _service.validateForm(
      template: state.selectedForm!,
      values: state.fieldValues,
    );

    if (errors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: errors,
        status: DocumentCreationStatus.idle,
      );
      return;
    }

    state = state.copyWith(
      status: DocumentCreationStatus.loading,
      clearErrors: true,
    );

    try {
      String result;

      if (state.useAI) {
        result = await _service.buildAIEnhancedForm(
          template: state.selectedForm!,
          values: state.fieldValues,
        );
      } else {
        result = _service.buildFilledFormText(
          template: state.selectedForm!,
          values: state.fieldValues,
        );
      }

      state = state.copyWith(
        status: DocumentCreationStatus.success,
        generatedText: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: DocumentCreationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Reset to form selection
  void resetToSelection() {
    state = const DocumentCreationState();
  }

  // Reset to form filling (keep selected form)
  void resetToForm() {
    state = state.copyWith(
      status: DocumentCreationStatus.idle,
      clearGenerated: true,
      errorMessage: null,
    );
  }
}

// â”€â”€ Provider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

final documentCreationProvider =
    NotifierProvider<DocumentCreationNotifier, DocumentCreationState>(DocumentCreationNotifier.new);



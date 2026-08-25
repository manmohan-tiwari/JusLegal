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

  String _value(Map<String, String> values, String key) =>
      values[key]?.trim() ?? '';

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
      final value = _value(values, field.key);
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
    buffer.writeln(
        'Name: ${values['complainant_name'] ?? values['applicant_name'] ?? values['claimant_name'] ?? values['worker_name'] ?? '[Name]'}');
    buffer.writeln('=' * 60);

    return buffer.toString();
  }

  // AI-enhanced version - fills gaps, improves language
  Future<GeneratedFormContent> buildAIEnhancedForm({
    required FormTemplateModel template,
    required Map<String, String> values,
  }) async {
    final filledText = buildFilledFormText(
      template: template,
      values: values,
    );

    final fieldsText = template.fields.map((f) {
      final value = _value(values, f.key);
      return '${f.label}: ${value.isEmpty ? "Not provided" : value}';
    }).join('\n');

    try {
      final result = await _aiService.generateDocumentFields(
        documentType: template.id,
        fieldsText: fieldsText,
      );
      final text = result['document_text']?.toString().trim();
      return GeneratedFormContent(
        text: text == null || text.isEmpty ? filledText : text,
        fields: result,
      );
    } catch (_) {
      return GeneratedFormContent(text: filledText);
    }
  }

  // Validate form - returns map of fieldKey -> error message
  Map<String, String> validateForm({
    required FormTemplateModel template,
    required Map<String, String> values,
  }) {
    final errors = <String, String>{};

    for (final field in template.fields) {
      if (!field.required) continue;
      final value = _value(values, field.key);
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

// -- AI Service provider -------------------------------------------------------

final _aiServiceProvider = Provider<AIService>((ref) {
  final svc = AIService();
  svc.initialize();
  return svc;
});

// -- Document Creation Service provider ---------------------------------------

final documentCreationServiceProvider =
    Provider<DocumentCreationService>((ref) {
  return DocumentCreationService(ref.read(_aiServiceProvider));
});

// -- State ---------------------------------------------------------------------

enum DocumentCreationStatus { idle, loading, success, error }

class DocumentCreationState {
  final FormTemplateModel? selectedForm;
  final Map<String, String> fieldValues;
  final Map<String, String> fieldErrors;
  final DocumentCreationStatus status;
  final String? generatedText;
  final Map<String, dynamic> generatedFields;
  final String? errorMessage;
  final bool useAI; // AI-enhanced vs plain filled form

  const DocumentCreationState({
    this.selectedForm,
    this.fieldValues = const {},
    this.fieldErrors = const {},
    this.status = DocumentCreationStatus.idle,
    this.generatedText,
    this.generatedFields = const {},
    this.errorMessage,
    this.useAI = true,
  });

  DocumentCreationState copyWith({
    FormTemplateModel? selectedForm,
    Map<String, String>? fieldValues,
    Map<String, String>? fieldErrors,
    DocumentCreationStatus? status,
    String? generatedText,
    Map<String, dynamic>? generatedFields,
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
      generatedText:
          clearGenerated ? null : (generatedText ?? this.generatedText),
      generatedFields:
          clearGenerated ? const {} : (generatedFields ?? this.generatedFields),
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

// -- Notifier ------------------------------------------------------------------

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
      GeneratedFormContent result;

      if (state.useAI) {
        result = await _service.buildAIEnhancedForm(
          template: state.selectedForm!,
          values: state.fieldValues,
        );
      } else {
        result = GeneratedFormContent(
          text: _service.buildFilledFormText(
            template: state.selectedForm!,
            values: state.fieldValues,
          ),
        );
      }

      state = state.copyWith(
        status: DocumentCreationStatus.success,
        generatedText: result.text,
        generatedFields: result.fields,
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

// -- Provider ------------------------------------------------------------------

final documentCreationProvider =
    NotifierProvider<DocumentCreationNotifier, DocumentCreationState>(
        DocumentCreationNotifier.new);

class GeneratedFormContent {
  const GeneratedFormContent({required this.text, this.fields = const {}});

  final String text;
  final Map<String, dynamic> fields;
}

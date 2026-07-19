import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/form_template_model.dart';
import '../core/services/document_creation_service.dart';
import '../services/ai_service.dart';

// ── AI Service provider ───────────────────────────────────────────────────────

final _aiServiceProvider = Provider<AIService>((ref) {
  final svc = AIService();
  svc.initialize();
  return svc;
});

// ── Document Creation Service provider ───────────────────────────────────────

final documentCreationServiceProvider = Provider<DocumentCreationService>((ref) {
  return DocumentCreationService(ref.read(_aiServiceProvider));
});

// ── State ─────────────────────────────────────────────────────────────────────

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

// ── Notifier ──────────────────────────────────────────────────────────────────

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

// ── Provider ──────────────────────────────────────────────────────────────────

final documentCreationProvider =
    NotifierProvider<DocumentCreationNotifier, DocumentCreationState>(DocumentCreationNotifier.new);

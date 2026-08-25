import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final clean = response.trim();
    final lines = clean.split('\n');
    return clean.startsWith('```') && lines.length > 2
        ? lines.sublist(1, lines.length - 1).join('\n').trim()
        : clean;
  }
}

class LegalWritingState {
  final int step;
  final bool loading;
  final String tone;
  final String result;
  final String? error;
  final DocumentCategory? category;
  final DocumentType? type;
  final Map<String, String> fieldValues;
  final String extraDetails;
  final bool isEditing;

  const LegalWritingState({
    this.step = 0,
    this.loading = false,
    this.tone = 'Formal',
    this.result = '',
    this.error,
    this.category,
    this.type,
    this.fieldValues = const {},
    this.extraDetails = '',
    this.isEditing = false,
  });

  LegalWritingState copyWith({
    int? step,
    bool? loading,
    String? tone,
    String? result,
    String? error,
    DocumentCategory? category,
    DocumentType? type,
    Map<String, String>? fieldValues,
    String? extraDetails,
    bool? isEditing,
  }) {
    return LegalWritingState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      tone: tone ?? this.tone,
      result: result ?? this.result,
      error: error,
      category: category ?? this.category,
      type: type ?? this.type,
      fieldValues: fieldValues ?? this.fieldValues,
      extraDetails: extraDetails ?? this.extraDetails,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class LegalWritingNotifier extends Notifier<LegalWritingState> {
  @override
  LegalWritingState build() => const LegalWritingState();

  void selectType(
    DocumentCategory category,
    DocumentType type,
  ) {
    state = state.copyWith(
      category: category,
      type: type,
      step: 1,
      fieldValues: {},
      extraDetails: '',
    );
  }

  void setTone(String tone) {
    state = state.copyWith(tone: tone);
  }

  void setFieldValue(String field, String value) {
    final newFieldValues = Map<String, String>.from(state.fieldValues);
    newFieldValues[field] = value;
    state = state.copyWith(fieldValues: newFieldValues);
  }

  void setExtraDetails(String details) {
    state = state.copyWith(extraDetails: details);
  }

  void setLoading(bool value) {
    state = state.copyWith(loading: value);
  }

  void setResult(String result) {
    state = state.copyWith(
      result: result,
      loading: false,
      step: 2,
    );
  }

  void setError(String error) {
    state = state.copyWith(
      error: error,
      loading: false,
    );
  }

  void reset() {
    state = const LegalWritingState();
  }

  void resetToCategory() {
    state = state.copyWith(
      step: 0,
      category: null,
      type: null,
      result: '',
      error: null,
      isEditing: false,
      fieldValues: const {},
      extraDetails: '',
    );
  }

  void resetToForm() {
    state = state.copyWith(
      step: 1,
      result: '',
      error: null,
      isEditing: false,
    );
  }

  void toggleEditing() {
    state = state.copyWith(isEditing: !state.isEditing);
  }
}

final legalWritingProvider =
    NotifierProvider<LegalWritingNotifier, LegalWritingState>(
        LegalWritingNotifier.new);

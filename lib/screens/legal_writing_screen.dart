import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/theme_config.dart';
import '../models/document_category_model.dart';
import '../models/document_type_model.dart';
import '../services/legal_writing_handler.dart';
import '../services/ai_service.dart';
import '../services/pdf/legal_pdf_models.dart';
import '../services/pdf/legal_pdf_service.dart';
import '../widgets/legal_writing/category_step.dart';
import '../widgets/legal_writing/form_step.dart';
import '../widgets/legal_writing/result_step.dart';

final _aiServiceProvider = Provider<AIService>((ref) {
  final svc = AIService();
  svc.initialize();
  return svc;
});

class LegalWritingScreen extends ConsumerStatefulWidget {
  const LegalWritingScreen({super.key});

  @override
  ConsumerState<LegalWritingScreen> createState() => _LegalWritingScreenState();
}

class _LegalWritingScreenState extends ConsumerState<LegalWritingScreen> {
  final _scrollController = ScrollController();
  final Map<String, TextEditingController> _fieldControllers = {};
  final _extraDetailsController = TextEditingController();
  final _resultController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _extraDetailsController.dispose();
    for (final c in _fieldControllers.values) {
      c.dispose();
    }
    _resultController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncControllersWithState();
  }

  void _syncControllersWithState() {
    final state = ref.watch(legalWritingProvider);

    if (_resultController.text != state.result) {
      _resultController.text = state.result;
    }

    if (_extraDetailsController.text != state.extraDetails) {
      _extraDetailsController.text = state.extraDetails;
    }

    if (state.type != null) {
      for (final field in state.type!.requiredFields) {
        if (!_fieldControllers.containsKey(field)) {
          _fieldControllers[field] = TextEditingController();
        }
        if (_fieldControllers[field]!.text !=
            (state.fieldValues[field] ?? '')) {
          _fieldControllers[field]!.text = state.fieldValues[field] ?? '';
        }
      }
    }
  }

  void _selectType(DocumentCategory category, DocumentType type) {
    ref.read(legalWritingProvider.notifier).selectType(category, type);

    _initializeControllers(type);
  }

  void _initializeControllers(DocumentType type) {
    for (final c in _fieldControllers.values) {
      c.dispose();
    }
    _fieldControllers.clear();

    for (final field in type.requiredFields) {
      _fieldControllers[field] = TextEditingController();
    }
  }

  bool _formValid(LegalWritingState state) {
    if (state.type == null) return false;
    final firstField = state.type!.requiredFields.first;
    final firstValue = state.fieldValues[firstField] ?? '';
    return firstValue.trim().isNotEmpty;
  }

  String _buildPrompt(LegalWritingState state) {
    final type = state.type!;
    final fieldsText = type.requiredFields
        .map((field) =>
            '$field: ${(state.fieldValues[field] ?? '').trim().isEmpty ? "Not provided" : (state.fieldValues[field] ?? '').trim()}')
        .join('\n');
    final extra = state.extraDetails.trim();

    return '''
You are a professional Indian legal document drafter. 
Draft a complete, professional "${type.label}" document under Indian law.

DOCUMENT TYPE: ${type.label}
CATEGORY: ${state.category!.label}
TONE: ${state.tone}

DETAILS PROVIDED:
$fieldsText
${extra.isNotEmpty ? '\nADDITIONAL DETAILS:\n$extra' : ''}

INSTRUCTIONS:
- Write ONLY the complete document - no explanations, no preamble, no notes after
- Use proper legal formatting with headings, clauses, and sections as appropriate
- Use formal legal language appropriate for India
- Fill ALL details using the information above
- For missing details use sensible placeholders like [Full Name], [Address], [Date]
- Include proper signature blocks, witness sections where applicable
- Cite relevant Indian law or act where appropriate
- Make it ready to use - professionally formatted
- Tone: ${state.tone}

Now write the complete ${type.label}:
''';
  }

  Future<void> _generate() async {
    final state = ref.read(legalWritingProvider);
    if (!_formValid(state)) return;
    FocusScope.of(context).unfocus();

    ref.read(legalWritingProvider.notifier).setLoading(true);

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }

    try {
      final firstField = state.type!.requiredFields.first;
      final firstValue = state.fieldValues[firstField] ?? '';

      final result = await ref.read(_aiServiceProvider).generateLetter(
            letterType: state.type!.id,
            category: state.category!.label,
            problemDescription: _buildPrompt(state),
            userRights: '',
            applicableLaw: 'Applicable Indian Laws',
            steps: [],
            senderName: firstValue.trim(),
            senderAddress: state.fieldValues['Address']?.trim() ??
                state.fieldValues['Property Address']?.trim() ??
                '',
            opponentName: state.fieldValues['Recipient']?.trim() ??
                state.fieldValues['Opposite Party']?.trim() ??
                state.fieldValues['Client']?.trim() ??
                state.fieldValues['Employer']?.trim() ??
                '[Recipient]',
            incidentDate: state.fieldValues['Date']?.trim() ??
                state.fieldValues['Incident Date']?.trim() ??
                state.fieldValues['Start Date']?.trim() ??
                '',
          );

      String clean = result.trim();
      if (clean.startsWith('```')) {
        final lines = clean.split('\n');
        if (lines.length > 2) {
          clean = lines.sublist(1, lines.length - 1).join('\n');
        }
      }

      _resultController.text = clean;
      ref.read(legalWritingProvider.notifier).setResult(clean);
    } catch (e) {
      ref.read(legalWritingProvider.notifier).setError(e.toString());
    }
  }

  String _fieldHint(String field) {
    const hints = {
      'Sender': 'Your full name',
      'Recipient': 'Full name or company name',
      'Dispute Details': 'Describe the dispute clearly',
      'Relief Sought': 'e.g. Full refund of Rs.5000',
      'Company Name': 'e.g. Amazon India Pvt Ltd',
      'Landlord': 'Full name of landlord',
      'Tenant': 'Full name of tenant',
      'Property Address': 'Complete property address',
      'Rent': 'Monthly rent amount e.g. Rs.15,000',
      'Duration': 'e.g. 11 months from Jan 2024',
      'Party 1': 'First party full name',
      'Party 2': 'Second party full name',
      'Deponent Name': 'Your full name',
      'Facts to Declare': 'State the facts clearly',
      'Assets': 'List your assets',
      'Beneficiaries': 'Who inherits what',
      'Principal': 'Person giving the power',
      'Agent': 'Person receiving the power',
      'Powers Granted': 'What they can do on your behalf',
      'Employee Name': 'Full name of employee',
      'Role': 'Job title / designation',
      'Company': 'Company name',
      'Last Working Day': 'e.g. 30 June 2024',
    };
    return hints[field] ?? 'Enter $field';
  }

  LegalDocument _pdfDocumentFor(LegalWritingState state) {
    final values = state.fieldValues;
    final type = state.type!;
    final name = values['Sender'] ??
        values['Deponent Name'] ??
        values['Complainant'] ??
        values['Applicant'] ??
        (values.isNotEmpty ? values.values.first : 'Applicant');
    final person = PersonInfo(
        fullName: name,
        address: values['Address'] ??
            values['Property Address'] ??
            'Address not provided');
    final body = _resultController.text.trim().isEmpty
        ? state.result
        : _resultController.text;
    final id = type.id.toLowerCase();
    if (id.contains('affidavit')) {
      return AffidavitDocument(
          title: type.label,
          deponent: person,
          purpose: type.label,
          statements: const []);
    }
    if (id.contains('rti')) {
      return RtiDocument(
          title: type.label,
          applicant: person,
          publicAuthority: RecipientInfo(
              name: values['Department'] ?? values['Public Authority'] ?? '',
              designation: 'Public Information Officer',
              address: values['PIO Address'] ?? ''),
          informationSought: const [],
          timePeriod: values['Period'] ?? '',
          preferredFormat: values['Preferred Format'] ?? '',
          feePaid: values['Fee Method'] ?? '');
    }
    if (id.contains('complaint')) {
      return CourtComplaintDocument(
          title: type.label,
          district: '[District]',
          state: '[State]',
          complainant: person,
          oppositeParty: OppositePartyInfo(
              name: values['Opposite Party'] ?? 'Opposite Party'),
          reliefSought: [values['Relief Sought'] ?? '']);
    }
    if (id.contains('notice')) {
      return LegalNoticeDocument(
          title: type.label,
          sender: person,
          recipient: RecipientInfo(
              name: values['Recipient'] ??
                  values['Opposite Party'] ??
                  'Recipient'),
          backgroundFacts: const [],
          legalViolation: '',
          reliefDemanded: [
            values['Relief Sought'] ?? 'Relief as stated above'
          ]);
    }
    return FormalLetterDocument(
        title: type.label,
        sender: person,
        recipient: RecipientInfo(
            name: values['Recipient'] ?? values['Client'] ?? 'Recipient'),
        subject: type.label,
        bodyParagraphs: [body]);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.legalGold, width: 1.5),
      ),
      contentPadding: const EdgeInsets.all(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(legalWritingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(state.step == 0
            ? 'Legal Writing'
            : state.step == 1
                ? state.type?.label ?? 'Fill Details'
                : 'Generated Document'),
        leading: BackButton(
          onPressed: () {
            if (state.step == 2) {
              ref.read(legalWritingProvider.notifier).resetToForm();
            } else if (state.step == 1) {
              ref.read(legalWritingProvider.notifier).resetToCategory();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: state.step == 0
                ? CategoryStep(
                    onTypeSelected: _selectType,
                  )
                : state.step == 1
                    ? FormStep(
                        selectedCategory: state.category!,
                        selectedType: state.type!,
                        selectedTone: state.tone,
                        fieldControllers: _fieldControllers,
                        extraDetailsController: _extraDetailsController,
                        formValid: _formValid(state),
                        onToneChanged: (tone) {
                          ref.read(legalWritingProvider.notifier).setTone(tone);
                        },
                        onGenerate: _generate,
                        onFieldChanged: (field) {
                          return (value) {
                            ref
                                .read(legalWritingProvider.notifier)
                                .setFieldValue(field, value);
                          };
                        },
                        onExtraDetailsChanged: (details) {
                          ref
                              .read(legalWritingProvider.notifier)
                              .setExtraDetails(details);
                        },
                        fieldHintBuilder: _fieldHint,
                        inputDecorationBuilder: _inputDecoration,
                      )
                    : Column(children: [
                        ResultStep(
                          selectedCategory: state.category!,
                          selectedType: state.type!,
                          selectedTone: state.tone,
                          loading: state.loading,
                          error: state.error,
                          resultController: _resultController,
                          isEditing: state.isEditing,
                          onToggleEditing: () {
                            ref
                                .read(legalWritingProvider.notifier)
                                .toggleEditing();
                          },
                          onRegenerate: _generate,
                          onNewDocument: () {
                            ref
                                .read(legalWritingProvider.notifier)
                                .resetToCategory();
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Download / Print PDF'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.legalGold,
                                  foregroundColor: const Color(0xFF0B0F19),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: state.loading
                                  ? null
                                  : () => LegalPdfService.showPrintPreview(
                                        _pdfDocumentFor(state),
                                        Localizations.localeOf(context)
                                            .languageCode,
                                      ),
                            )),
                      ]),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juslegal/core/core.dart';
import '../models/document_definition.dart';
import '../definitions/rent_agreement.dart';
import '../models/document_form_data.dart';
import '../models/form_section_definition.dart';
import 'document_form_renderer.dart';
import 'form_validator.dart';
import '../prompts/prompt_builder.dart';
import '../../../services/ai_service.dart';
import '../../../services/pdf/legal_pdf_models.dart';
import '../../../services/pdf/legal_pdf_service.dart';
import '../../../widgets/legal_writing/disclaimer_banner.dart';
import '../../../widgets/legal_writing/section_label.dart';

typedef DocumentGeneratedCallback = void Function(String result);

class DocumentFormScreen extends ConsumerStatefulWidget {
  final DocumentDefinition definition;
  final DocumentGeneratedCallback? onGenerated;
  final VoidCallback? onBackToSelection;
  final IconData categoryIcon;
  final String categoryLabel;

  const DocumentFormScreen({
    super.key,
    required this.definition,
    this.onGenerated,
    this.onBackToSelection,
    this.categoryIcon = Icons.description_outlined,
    this.categoryLabel = 'Legal Writing',
  });

  @override
  ConsumerState<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends ConsumerState<DocumentFormScreen> {
  late DocumentFormData _formData;
  Map<String, String> _errors = const {};
  int _currentStep = 0;
  bool _isGenerating = false;
  String? _generationError;
  String _result = '';
  final _resultController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isEditing = false;

  String _tone = 'Formal';
  String _languageCode = 'en';

  @override
  void initState() {
    super.initState();
    _formData = DocumentFormData(documentId: widget.definition.id);
    _initializeDefaults();
    _initializeRepeatableSections();
    _resultController.addListener(() {
      if (_result != _resultController.text) {
        setState(() {
          _result = _resultController.text;
        });
      }
    });
  }

  void _initializeDefaults() {
    for (final section in widget.definition.sections) {
      for (final field in section.fields) {
        if (field.defaultValue != null) {
          _formData = _formData.setValue(field.id, field.defaultValue);
        }
      }
    }
  }

  void _initializeRepeatableSections() {
    for (final section in widget.definition.sections) {
      if (section is RepeatableSectionDefinition) {
        if (section.minItems > 0) {
          final defaultItem = <String, dynamic>{};
          for (final field in section.fields) {
            if (field.defaultValue != null) {
              defaultItem[field.id] = field.defaultValue;
            }
          }
          _formData = _formData.setValue(
            section.id,
            List.generate(
              section.minItems,
              (_) => Map<String, dynamic>.from(defaultItem),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _resultController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setFieldValue(String fieldId, dynamic value) {
    setState(() {
      _formData = _formData.setValue(fieldId, value);
      if (widget.definition.id == 'rent_agreement' &&
          (fieldId == 'tenancyStartDate' || fieldId == 'tenancyPeriodMonths')) {
        _updateTenancyEndDate();
      }
      _errors = const {};
    });
  }

  void _updateTenancyEndDate() {
    final start = _formData.getValue('tenancyStartDate')?.toString();
    final months = int.tryParse(
        _formData.getValue('tenancyPeriodMonths')?.toString() ?? '');
    if (start == null || months == null || months < 1) return;
    _formData = _formData.setValue('tenancyEndDate',
        calculateResidentialTenancyEndDate(start, months) ?? '');
  }

  void _addRepeatableItem() {
    final section = widget.definition.sections[_currentStep];
    if (section is RepeatableSectionDefinition) {
      final defaultItem = <String, dynamic>{};
      for (final field in section.fields) {
        if (field.defaultValue != null) {
          defaultItem[field.id] = field.defaultValue;
        }
      }
      final current = _formData.getRepeatable(section.id);
      final list = List<Map<String, dynamic>>.from(current);
      list.add(Map<String, dynamic>.from(defaultItem));
      setState(() {
        _formData = _formData.setValue(section.id, list);
      });
    }
  }

  void _removeRepeatableItem(String sectionId, int index) {
    setState(() {
      _formData = _formData.removeRepeatableItem(sectionId, index);
    });
  }

  void _setStep(int step) {
    setState(() {
      _currentStep = step;
      _errors = const {};
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _generate() async {
    final validator = const FormValidator();
    final errors = validator.validateDocument(
      definition: widget.definition,
      formData: _formData,
    );
    if (errors.isNotEmpty) {
      setState(() {
        _errors = errors;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isGenerating = true;
      _generationError = null;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted && _scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }

    try {
      final aiService = ref.read(_aiServiceProvider);

      final prompt = const PromptBuilder().build(
        definition: widget.definition,
        formData: _formData.copyWith(
          tone: _tone,
          languageCode: _languageCode,
        ),
      );

      final raw = await aiService.generateText(
        systemPrompt: prompt.systemPrompt,
        userPrompt: prompt.userPrompt,
        temperature: 0.3,
      );

      if (!mounted) return;

      String clean = raw.trim();
      if (clean.startsWith('```')) {
        final lines = clean.split('\n');
        if (lines.length > 2) {
          clean = lines.sublist(1, lines.length - 1).join('\n');
        }
      }
      clean = clean
          .replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '')
          .replaceAll('```', '')
          .trim();

      _resultController.text = clean;
      setState(() {
        _result = clean;
        _isGenerating = false;
      });

      if (widget.onGenerated != null) {
        widget.onGenerated!(clean);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _generationError = e.toString();
      });
    }
  }

  LegalDocument _pdfDocumentFor() {
    if (widget.definition.id == 'rent_agreement') {
      List<String> names(String key) => _formData
          .getRepeatable(key)
          .map((party) => party['fullName']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      return RentAgreementDocument(
        title: 'Rent Agreement',
        content: _resultController.text.trim().isEmpty
            ? _result
            : _resultController.text,
        landlords: names('landlords'),
        tenants: names('tenants'),
      );
    }
    final values = _flattenValuesForPdf(_formData.values);
    final name = values['Sender'] ??
        values['applicant_name'] ??
        values['Deponent Name'] ??
        values['Complainant'] ??
        values['Applicant'] ??
        (values.isNotEmpty ? values.values.first : 'Applicant');
    final person = PersonInfo(
      fullName: name,
      address: values['Address'] ??
          values['applicant_address'] ??
          values['Property Address'] ??
          'Address not provided',
    );
    final body = _resultController.text.trim().isEmpty
        ? _result
        : _resultController.text;
    final statements =
        body.split('\n').where((s) => s.trim().isNotEmpty).toList();
    final id = widget.definition.id.toLowerCase();
    if (id.contains('affidavit')) {
      return AffidavitDocument(
        title: widget.definition.title,
        deponent: person,
        purpose: widget.definition.title,
        statements: statements,
      );
    }
    if (id.contains('rti')) {
      return RtiDocument(
        title: widget.definition.title,
        applicant: person,
        publicAuthority: RecipientInfo(
          name: values['Department'] ?? values['Public Authority'] ?? '',
          designation: 'Public Information Officer',
          address: values['PIO Address'] ?? '',
        ),
        informationSought: statements,
        timePeriod: values['Period'] ?? '',
        preferredFormat: values['Preferred Format'] ?? '',
        feePaid: values['Fee Method'] ?? '',
      );
    }
    if (id.contains('complaint')) {
      return CourtComplaintDocument(
        title: widget.definition.title,
        district: '[District]',
        state: '[State]',
        complainant: person,
        oppositeParty: OppositePartyInfo(
          name: values['Opposite Party'] ?? 'Opposite Party',
        ),
        reliefSought: [values['Relief Sought'] ?? ''],
      );
    }
    if (id.contains('notice')) {
      return LegalNoticeDocument(
        title: widget.definition.title,
        sender: person,
        recipient: RecipientInfo(
          name: values['Recipient'] ?? values['Opposite Party'] ?? 'Recipient',
        ),
        backgroundFacts: statements,
        legalViolation: '',
        reliefDemanded: [values['Relief Sought'] ?? 'Relief as stated above'],
      );
    }
    return FormalLetterDocument(
      title: widget.definition.title,
      sender: person,
      recipient: RecipientInfo(
        name: values['Recipient'] ?? values['Client'] ?? 'Recipient',
      ),
      subject: widget.definition.title,
      bodyParagraphs: [body],
    );
  }

  Map<String, String> _flattenValuesForPdf(Map<String, dynamic> values) {
    final result = <String, String>{};
    values.forEach((key, value) {
      if (value == null) return;
      if (value is String) {
        result[key] = value;
      } else if (value is List) {
        result[key] = value.map((e) => e.toString()).join(', ');
      } else {
        result[key] = value.toString();
      }
    });
    return result;
  }

  void _resetToCategory() {
    setState(() {
      _currentStep = 0;
      _result = '';
      _resultController.text = '';
      _generationError = null;
      _isEditing = false;
      _errors = const {};
      _formData = DocumentFormData(documentId: widget.definition.id);
      _initializeDefaults();
      _initializeRepeatableSections();
    });
    widget.onBackToSelection?.call();
  }

  void _resetToForm() {
    setState(() {
      _currentStep = 0;
      _result = '';
      _resultController.text = '';
      _generationError = null;
      _isEditing = false;
    });
  }

  bool get _isResultStep => _result.isNotEmpty && !_isGenerating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isResultStep
            ? 'Generated Document'
            : _result.isEmpty && widget.definition.sections.length > 1
                ? widget.definition.sections[_currentStep].title
                : widget.definition.title),
        leading: BackButton(
          onPressed: () {
            if (_isResultStep) {
              _resetToForm();
            } else if (_currentStep > 0) {
              _setStep(_currentStep - 1);
            } else if (_result.isNotEmpty) {
              _resetToCategory();
            } else {
              if (widget.onBackToSelection != null) {
                _resetToCategory();
              } else {
                Navigator.of(context).pop();
              }
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
            child: _isResultStep ? _buildResultStep() : _buildCategoryStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DisclaimerBanner(),
        const SizedBox(height: 20),
        DocumentFormRenderer(
          definition: widget.definition,
          formData: _formData,
          errors: _errors,
          currentStep: _currentStep,
          onFieldChanged: _setFieldValue,
          onAddRepeatableItem: _addRepeatableItem,
          onRemoveRepeatableItem: _removeRepeatableItem,
          onStepChanged: _setStep,
          onGenerate: _generate,
          isGenerating: _isGenerating,
          tone: _tone,
          languageCode: _languageCode,
          onToneChanged: (tone) {
            setState(() {
              _tone = tone;
            });
          },
          onLanguageChanged: (code) {
            setState(() {
              _languageCode = code;
            });
          },
          onValidationFailed: (errors) {
            setState(() {
              _errors = errors;
            });
          },
        ),
      ],
    );
  }

  Widget _buildResultStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryNavy.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.categoryIcon,
                    size: 14,
                    color: AppColors.primaryNavy,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.definition.title,
                    style: const TextStyle(
                      color: AppColors.primaryNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.trustBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.trustBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                _tone,
                style: const TextStyle(
                  color: AppColors.trustBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_generationError != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Generation failed. Please try again.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: _generate,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        const SectionLabel('GENERATED DOCUMENT'),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.article_outlined,
                      size: 16,
                      color: AppColors.trustBlue,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.definition.title.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      icon: Icon(
                        _isEditing ? Icons.lock_outline : Icons.edit_outlined,
                        size: 16,
                      ),
                      label: Text(_isEditing ? 'Lock' : 'Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.trustBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _resultController,
                  readOnly: !_isEditing,
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.8,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Not satisfied?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            TextButton(onPressed: _generate, child: const Text('Regenerate')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: _resultController.text),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Copy'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetToCategory,
                icon: const Icon(Icons.add_outlined, size: 18),
                label: const Text('New Document'),
              ),
            ),
          ],
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
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => LegalPdfService.showPrintPreview(
              _pdfDocumentFor(),
              Localizations.localeOf(context).languageCode,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const DisclaimerBanner(),
      ],
    );
  }
}

final _aiServiceProvider = Provider<AIService>((ref) {
  final svc = AIService();
  svc.initialize();
  return svc;
});

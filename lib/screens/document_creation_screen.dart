import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:juslegal/core/core.dart';
import '../services/document_handler.dart';
import '../services/pdf/legal_pdf_models.dart';
import '../services/pdf/legal_pdf_service.dart';
import '../widgets/document_creation/form_disclaimer_banner.dart';
import '../widgets/document_creation/form_field_widget.dart';
import '../widgets/document_creation/form_preview_card.dart';
import '../widgets/document_creation/filled_form_result.dart';
import '../widgets/section_label.dart';

class DocumentCreationScreen extends ConsumerStatefulWidget {
  const DocumentCreationScreen({super.key});

  @override
  ConsumerState<DocumentCreationScreen> createState() =>
      _DocumentCreationScreenState();
}

class _DocumentCreationScreenState
    extends ConsumerState<DocumentCreationScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentCreationProvider);
    final notifier = ref.read(documentCreationProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(state.hasSelectedForm
            ? state.selectedForm!.title
            : 'Document Creation'),
        leading: BackButton(
          onPressed: () {
            if (state.hasSelectedForm && !state.hasGenerated) {
              notifier.resetToSelection();
            } else if (state.hasGenerated) {
              notifier.resetToForm();
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
          child: !state.hasSelectedForm
              ? _buildFormSelection()
              : !state.hasGenerated
                  ? _buildFormFilling(state, notifier)
                  : _buildFormResult(state, notifier),
        ),
      ),
    );
  }

  // -- Step 0: Form Selection ----------------------------------------------

  Widget _buildFormSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormDisclaimerBanner(),
        const SizedBox(height: 20),
        SectionLabel('AVAILABLE FORMS'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 11, bottom: 14),
          child: Text(
            'Browse and select from 10 official Indian legal forms',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: FormTemplates.all.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final form = FormTemplates.all[i];
            return FormPreviewCard(
              form: form,
              onTap: () {
                ref.read(documentCreationProvider.notifier).selectForm(form);
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }

  // -- Step 1: Form Filling ------------------------------------------------

  Widget _buildFormFilling(
    DocumentCreationState state,
    DocumentCreationNotifier notifier,
  ) {
    final form = state.selectedForm!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryNavy, AppColors.trustBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.edit_document, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      form.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                    Text(
                      form.subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // AI toggle
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceBright,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.legalGold, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Enhancement',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'Let AI improve language and formatting',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.useAI,
                onChanged: (v) => notifier.toggleAI(v),
                activeThumbColor: AppColors.legalGold,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Form fields
        SectionLabel('FILL DETAILS'),
        const SizedBox(height: 14),
        ...form.fields.asMap().entries.map((e) {
          final field = e.value;
          final value = state.fieldValues[field.key] ?? '';
          final error = state.fieldErrors[field.key];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FormFieldWidget(
              field: field,
              value: value,
              error: error,
              onChanged: (v) => notifier.updateField(field.key, v),
            ),
          );
        }),

        const SizedBox(height: 20),

        // Generate button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : () => notifier.generateForm(),
            icon: state.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline, size: 20),
            label: Text(
              state.isLoading ? 'Generating...' : 'Generate Form',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B0F19),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.legalGold,
              foregroundColor: const Color(0xFF0B0F19),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        const FormDisclaimerBanner(),
      ],
    );
  }

  // -- Step 2: Form Result -------------------------------------------------

  Widget _buildFormResult(
    DocumentCreationState state,
    DocumentCreationNotifier notifier,
  ) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Generating your ${state.selectedForm!.title}...',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Generation failed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryNavy,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Please try again',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => notifier.generateForm(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final form = state.selectedForm!;
    return Column(children: [
      FilledFormResult(
        generatedText: state.generatedText!,
        form: form,
        onRegenerate: () => notifier.generateForm(),
        onNewForm: () => notifier.resetToSelection(),
      ),
      const SizedBox(height: 16),
      SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Download / Print PDF'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () async {
              final locale = Localizations.localeOf(context).languageCode;
              final document = await _pdfDocumentFor(state);
              await LegalPdfService.showPrintPreview(document, locale);
            },
          )),
    ]);
  }

  Future<LegalDocument> _pdfDocumentFor(DocumentCreationState state) async {
    final form = state.selectedForm!;
    final values = state.fieldValues;
    debugPrint(
        'FORM FIELDS: ${values.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ')}');
    final name = values['applicant_name'] ??
        values['complainant_name'] ??
        values['name'] ??
        values['deponent_name'] ??
        'Applicant';
    final person = PersonInfo(
        fullName: name,
        address: await _addressFor(values),
        mobile:
            _firstValue(values, const ['applicant_phone', 'mobile', 'phone']),
        email: _firstValue(values, const ['applicant_email', 'email']));
    final id = form.id.toLowerCase();
    final ai = state.generatedFields;
    final generatedText = state.generatedText ?? '';
    if (id.contains('rti')) {
      final information = ai['information_sought'];
      return RtiDocument(
          title: form.title,
          applicant: person,
          publicAuthority: RecipientInfo(
            name: ai['pio_department']?.toString().trim().isNotEmpty == true
                ? ai['pio_department'].toString()
                : _firstValue(values, const ['department_name'],
                    fallback: form.authority),
            designation:
                ai['to_designation']?.toString().trim().isNotEmpty == true
                    ? ai['to_designation'].toString()
                    : 'Public Information Officer (PIO)',
            address: ai['pio_address']?.toString() ??
                _firstValue(values, const ['pio_address']),
          ),
          informationSought: _informationSought(
              information, values['information_sought'] ?? ''),
          timePeriod: ai['period']?.toString() ?? values['time_period'] ?? '',
          preferredFormat: ai['preferred_format']?.toString() ??
              values['format_required'] ??
              'Certified copies',
          feePaid: ai['fee_method']?.toString() ??
              values['fee_details'] ??
              'cash / Indian Postal Order');
    }
    if (id.contains('affidavit')) {
      return AffidavitDocument(
          title: form.title,
          deponent: person,
          purpose: ai['purpose']?.toString() ?? form.subtitle,
          statements: _informationSought(ai['statements'], ''));
    }
    if (id.contains('notice')) {
      return LegalNoticeDocument(
          title: form.title,
          sender: person,
          recipient: RecipientInfo(
              name: _firstValue(values,
                  const ['recipient_name', 'opposite_party', 'recipient'],
                  fallback: '')),
          backgroundFacts: _informationSought(ai['background_facts'], ''),
          legalViolation: ai['legal_violation']?.toString() ?? '',
          reliefDemanded: _informationSought(ai['demands'], ''),
          responseDeadlineDays:
              int.tryParse(ai['deadline_days']?.toString() ?? '') ?? 30);
    }
    if (id.contains('complaint')) {
      return CourtComplaintDocument(
          title: form.title,
          district: values['district'] ?? '[District]',
          state: values['state'] ?? '[State]',
          complainant: person,
          oppositeParty: OppositePartyInfo(
              name: values['opposite_party'] ?? 'Opposite Party'),
          consumerStatusReason: ai['consumer_status_reason']?.toString() ?? '',
          territorialJurisdiction:
              ai['jurisdiction_territorial']?.toString() ?? '',
          pecuniaryAmount:
              ai['jurisdiction_pecuniary_amount']?.toString() ?? '',
          factsOfCase: _informationSought(ai['facts'], ''),
          causeOfActionDate: ai['cause_of_action_date']?.toString() ?? '',
          causeOfActionReason: ai['cause_of_action_reason']?.toString() ?? '',
          reliefSought: _informationSought(ai['relief'], ''));
    }
    return FormalLetterDocument(
        title: form.title,
        subtitle: form.actReference,
        sender: person,
        recipient: RecipientInfo(name: form.authority),
        subject: form.title,
        bodyParagraphs: [generatedText]);
  }

  String _firstValue(Map<String, String> values, List<String> keys,
      {String fallback = ''}) {
    for (final key in keys) {
      final value = values[key]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return fallback;
  }

  Future<String> _addressFor(Map<String, String> values) async {
    final formAddress = values.entries
        .firstWhere(
          (entry) =>
              entry.key.toLowerCase().contains('address') &&
              entry.value.trim().isNotEmpty,
          orElse: () => const MapEntry('', ''),
        )
        .value
        .trim();
    if (formAddress.isNotEmpty) return formAddress;

    if (Hive.isBoxOpen('user_profile')) {
      final profile = Hive.box('user_profile');
      for (final key in const [
        'address',
        'applicant_address',
        'your_address',
        'residential_address',
        'full_address'
      ]) {
        final value = profile.get(key)?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }

    final displayName = FirebaseAuth.instance.currentUser?.displayName?.trim();
    return displayName == null || displayName.isEmpty
        ? 'Address not available'
        : '$displayName — Address not available';
  }

  List<String> _informationSought(dynamic raw, String fallback) {
    if (raw is List) {
      final items = raw
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (items.isNotEmpty) return items;
    }
    if (raw is String && raw.trim().isNotEmpty) {
      final items = _splitInformation(raw);
      if (items.isNotEmpty) return items;
    }
    final items = _splitInformation(fallback);
    return items.isEmpty ? const ['Information sought not specified'] : items;
  }

  List<String> _splitInformation(String value) => value
      .split(RegExp(r'\r?\n|(?<=\.)\s+(?=\d+\.)'))
      .map((item) => item.replaceFirst(RegExp(r'^\s*\d+[.)]\s*'), '').trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

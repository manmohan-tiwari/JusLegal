import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/form_templates.dart';
import '../models/form_template_model.dart';
import '../providers/document_creation_provider.dart';
import '../widgets/document_creation/form_category_section.dart';
import '../widgets/document_creation/form_disclaimer_banner.dart';
import '../widgets/document_creation/form_field_widget.dart';
import '../widgets/document_creation/form_preview_card.dart';
import '../widgets/document_creation/filled_form_result.dart';

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

  void _showFormCategories() {
    // Group forms by category
    final categoriesMap = <String, (IconData, List<FormTemplateModel>)>{};

    categoriesMap['Complaints & Notices'] = (
      Icons.campaign_outlined,
      [
        FormTemplates.all[0], // Consumer Complaint
        FormTemplates.all[1], // RTI
        FormTemplates.all[2], // Cyber Crime
        FormTemplates.all[9], // Cheque Bounce
      ]
    );

    categoriesMap['Financial & Banking'] = (
      Icons.account_balance_outlined,
      [
        FormTemplates.all[3], // Banking Ombudsman
      ]
    );

    categoriesMap['Motor & Accident'] = (
      Icons.two_wheeler_outlined,
      [
        FormTemplates.all[4], // Motor Accident Claim
      ]
    );

    categoriesMap['Employment & Labour'] = (
      Icons.business_center_outlined,
      [
        FormTemplates.all[5], // Labour Complaint
      ]
    );

    categoriesMap['Legal Resolution'] = (
      Icons.gavel_outlined,
      [
        FormTemplates.all[6], // Lok Adalat
        FormTemplates.all[7], // Legal Aid
      ]
    );

    categoriesMap['Property & Housing'] = (
      Icons.home_outlined,
      [
        FormTemplates.all[8], // Rent Control
      ]
    );

    // Build UI
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Form Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                ...categoriesMap.entries.map((e) {
                  final label = e.key;
                  final icon = e.value.$1;
                  final forms = e.value.$2;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FormCategorySection(
                      categoryLabel: label,
                      icon: icon,
                      forms: forms,
                      onFormSelected: (form) {
                        Navigator.of(context).pop();
                        ref
                            .read(documentCreationProvider.notifier)
                            .selectForm(form);
                        Future.delayed(const Duration(milliseconds: 300),
                            () {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      },
                      initiallyExpanded: false,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
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

  // ── Step 0: Form Selection ──────────────────────────────────────────────

  Widget _buildFormSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormDisclaimerBanner(),
        const SizedBox(height: 20),
        _SectionLabel('AVAILABLE FORMS'),
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
                ref
                    .read(documentCreationProvider.notifier)
                    .selectForm(form);
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

  // ── Step 1: Form Filling ────────────────────────────────────────────────

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
              const Icon(Icons.edit_document,
                  color: Colors.white, size: 24),
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
            color: AppColors.trustBlue.withValues(alpha: 0.06),
            border: Border.all(
                color: AppColors.trustBlue.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: AppColors.trustBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Enhancement',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w600,
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
                activeColor: AppColors.trustBlue,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Form fields
        _SectionLabel('FILL DETAILS'),
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
        }).toList(),

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
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              foregroundColor: Colors.white,
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

  // ── Step 2: Form Result ─────────────────────────────────────────────────

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
            const Icon(Icons.error_outline,
                color: Colors.red, size: 48),
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

    return FilledFormResult(
      generatedText: state.generatedText!,
      form: state.selectedForm!,
      onRegenerate: () => notifier.generateForm(),
      onNewForm: () => notifier.resetToSelection(),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: AppColors.trustBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
        ),
      ],
    );
  }
}
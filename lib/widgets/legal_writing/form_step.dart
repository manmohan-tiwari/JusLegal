import 'package:flutter/material.dart';

import 'package:juslegal/core/core.dart';
import '../../models/document_category_model.dart';
import '../../models/document_type_model.dart';
import '../../constants/document_fields.dart';
import 'field_label.dart';
import 'section_label.dart';

class FormStep extends StatelessWidget {
  final DocumentCategory selectedCategory;
  final DocumentType selectedType;

  final String selectedTone;
  final String languageCode;

  final Map<String, TextEditingController> fieldControllers;
  final TextEditingController extraDetailsController;

  final bool formValid;

  final ValueChanged<String> onToneChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onGenerate;
  final ValueChanged<String> Function(String field) onFieldChanged;
  final ValueChanged<String> onExtraDetailsChanged;

  final String Function(String field) fieldHintBuilder;
  final InputDecoration Function(String hint) inputDecorationBuilder;

  const FormStep({
    super.key,
    required this.selectedCategory,
    required this.selectedType,
    required this.selectedTone,
    required this.languageCode,
    required this.fieldControllers,
    required this.extraDetailsController,
    required this.formValid,
    required this.onToneChanged,
    required this.onLanguageChanged,
    required this.onGenerate,
    required this.onFieldChanged,
    required this.onExtraDetailsChanged,
    required this.fieldHintBuilder,
    required this.inputDecorationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    const configuredDocumentIds = {
      'legal_notice',
      'consumer_complaint',
      'police_complaint',
      'cease_desist',
      'demand_letter',
      'rent_agreement',
      'service_agreement',
      'nda_confidentiality',
      'employment_contract',
      'freelance_contract',
      'sale_agreement',
      'partnership_deed',
      'mou_term_sheet',
      'general_affidavit',
      'address_proof_affidavit',
      'name_change_affidavit',
      'income_affidavit',
      'consumer_court_complaint',
      'vakalatnama',
      'bail_application',
    };
    final showAdditionalDetails =
        !configuredDocumentIds.contains(selectedType.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryNavy,
                AppColors.trustBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                selectedCategory.icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedType.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      selectedType.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('TONE'),
        const SizedBox(height: 10),
        Row(
          children: [
            'Formal',
            'Assertive',
            'Concise',
          ].map((tone) {
            final selected = selectedTone == tone;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onToneChanged(tone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.trustBlue : AppColors.surface,
                      border: Border.all(
                        color:
                            selected ? AppColors.trustBlue : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        tone,
                        style: TextStyle(
                          color:
                              selected ? Colors.white : AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.trustBlue.withValues(alpha: 0.06),
            border: Border.all(
              color: AppColors.trustBlue.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.trustBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedType.promptHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryNavy,
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('REQUIRED FIELDS'),
        const SizedBox(height: 14),
        ...selectedType.requiredFields.asMap().entries.map((entry) {
          final field = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldLabel(
                  '${_labelFor(field)} *',
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: fieldControllers[field],
                  onChanged: onFieldChanged(field),
                  maxLines: field.toLowerCase().contains('detail') ||
                          field.toLowerCase().contains('description') ||
                          field.toLowerCase().contains('scope') ||
                          field.toLowerCase().contains('term')
                      ? 3
                      : 1,
                  decoration: inputDecorationBuilder(
                    fieldHintBuilder(field),
                  ),
                ),
              ],
            ),
          );
        }),
        if (selectedType.optionalFields.isNotEmpty) ...[
          const SectionLabel('OPTIONAL FIELDS'),
          const SizedBox(height: 14),
          ...selectedType.optionalFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel(_labelFor(field)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: fieldControllers[field],
                        onChanged: onFieldChanged(field),
                        maxLines: field.toLowerCase().contains('detail') ||
                                field.toLowerCase().contains('description') ||
                                field.toLowerCase().contains('clause') ||
                                field.toLowerCase().contains('evidence')
                            ? 3
                            : 1,
                        decoration:
                            inputDecorationBuilder(fieldHintBuilder(field)),
                      ),
                    ]),
              )),
        ],
        if (showAdditionalDetails) ...[
          const SectionLabel(
            'ADDITIONAL DETAILS',
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(
              left: 11,
              bottom: 10,
            ),
            child: Text(
              'Any other information to include (optional)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextField(
            controller: extraDetailsController,
            onChanged: onExtraDetailsChanged,
            maxLines: 4,
            maxLength: 500,
            decoration: inputDecorationBuilder(
              'e.g. Special clauses, conditions, or any other relevant details...',
            ),
          ),
          const SizedBox(height: 24),
        ],

        if (!formValid) ...[
          Text(
            'Complete all required fields to generate this document.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: formValid ? onGenerate : null,
            icon: const Icon(
              Icons.auto_awesome_rounded,
              size: 20,
            ),
            label: const Text(
              'Generate Document',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
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
      ],
    );
  }

  String _labelFor(String field) =>
      documentFieldLabels[field] ??
      field
          .replaceAllMapped(
              RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
          .replaceAllMapped(
              RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m[1]} ${m[2]}');
}

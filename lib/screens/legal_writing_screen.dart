import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juslegal/core/core.dart';
import '../models/document_type_model.dart';
import '../services/legal_writing_handler.dart';
import '../constants/document_fields.dart';
import '../features/legal_writing/definitions/document_registry.dart';
import '../features/legal_writing/engine/document_form_screen.dart';
import '../features/legal_writing/models/document_definition.dart';
import '../features/legal_writing/models/form_field_definition.dart';
import '../features/legal_writing/models/form_section_definition.dart';
import '../widgets/section_label.dart';

class LegalWritingScreen extends ConsumerStatefulWidget {
  const LegalWritingScreen({super.key});

  @override
  ConsumerState<LegalWritingScreen> createState() => _LegalWritingScreenState();
}

class _LegalWritingScreenState extends ConsumerState<LegalWritingScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<Map<String, dynamic>> _popularTemplates = [
    {
      'id': 'rent_agreement',
      'title': 'Rent Agreement',
      'category': 'Agreements',
      'icon': Icons.home_work_outlined,
      'desc': 'Residential lease with security deposit & lock-in terms',
    },
    {
      'id': 'legal_notice',
      'title': '15-Day Legal Notice',
      'category': 'Notices',
      'icon': Icons.gavel_rounded,
      'desc': 'Formal demand notice before filing court proceedings',
    },
    {
      'id': 'cease_desist',
      'title': 'Cheque Bounce Notice',
      'category': 'Notices',
      'icon': Icons.account_balance_wallet_outlined,
      'desc': 'Statutory notice under Section 138 of Negotiable Instruments Act',
    },
    {
      'id': 'name_change_affidavit',
      'title': 'Name Change Affidavit',
      'category': 'Affidavits',
      'icon': Icons.badge_outlined,
      'desc': 'Notarized declaration for passport & gazette publication',
    },
    {
      'id': 'rti_application',
      'title': 'RTI Application',
      'category': 'Government',
      'icon': Icons.article_outlined,
      'desc': 'Formal information request under Right to Information Act',
    },
    {
      'id': 'resignation_letter',
      'title': 'Resignation Letter',
      'category': 'Employment',
      'icon': Icons.work_outline_rounded,
      'desc': 'Formal job resignation with notice period & handover',
    },
    {
      'id': 'nda_confidentiality',
      'title': 'Non-Disclosure (NDA)',
      'category': 'Agreements',
      'icon': Icons.lock_outline_rounded,
      'desc': 'Mutual confidentiality agreement for business & trade secrets',
    },
    {
      'id': 'power_of_attorney',
      'title': 'Power of Attorney (PoA)',
      'category': 'Property',
      'icon': Icons.assignment_ind_outlined,
      'desc': 'Authorize an agent for legal, property & financial matters',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDocumentById(String documentId, String title) {
    final definition = getDocumentDefinitionById(documentId)!;
    final docDef = documentTypeFields[documentId];
    final effectiveDefinition = definition.copyWith(
      sections: _sectionsWithConfiguredFields(
        definition,
        DocumentType(
          id: documentId,
          label: title,
          description: definition.description,
          promptHint: definition.promptHint,
          requiredFields: docDef?.required ?? const [],
          optionalFields: docDef?.optional ?? const [],
        ),
        docDef,
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentFormScreen(
          definition: effectiveDefinition,
          categoryIcon: Icons.description_outlined,
          categoryLabel: 'Draft Document',
          onBackToSelection: () {
            ref.read(legalWritingProvider.notifier).resetToCategory();
          },
        ),
      ),
    );
  }

  List<FormSectionDefinition> _sectionsWithConfiguredFields(
    DocumentDefinition definition,
    DocumentType type,
    DocumentTypeConfig? config,
  ) {
    if (definition.sections.length > 1 || definition.id == 'rent_agreement') {
      return definition.sections;
    }
    return [
      FormSectionDefinition(
        id: 'details',
        title: 'Document Details',
        description: 'Fill in the required and optional details below',
        fields: [
          ..._buildFields(config?.required ?? type.requiredFields,
              required: true),
          ..._buildFields(config?.optional ?? type.optionalFields,
              required: false),
        ],
      ),
      const FormSectionDefinition(
        id: 'review',
        title: 'Review',
        description: 'Review and generate your document',
        fields: [],
      ),
    ];
  }

  List<FormFieldDefinition> _buildFields(List<String> keys,
      {required bool required}) {
    return keys.map((key) {
      final label = documentFieldLabels[key] ??
          key
              .replaceAllMapped(
                  RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
              .replaceAll('_', ' ')
              .trim();
      FormFieldType fieldType = FormFieldType.text;
      final lower = key.toLowerCase();
      if (lower.contains('detail') ||
          lower.contains('description') ||
          lower.contains('scope') ||
          lower.contains('term') ||
          lower.contains('clause') ||
          lower.contains('evidence') ||
          lower.contains('content') ||
          lower.contains('facts') ||
          lower.contains('ground') ||
          lower.contains('prayer') ||
          lower.contains('declaration') ||
          lower.contains('responsibilit') ||
          lower.contains('assets') ||
          lower.contains('beneficiar') ||
          lower.contains('powers') ||
          lower.contains('property')) {
        fieldType = FormFieldType.textarea;
      } else if (lower.contains('amount') ||
          lower.contains('price') ||
          lower.contains('rent') ||
          lower.contains('salary') ||
          lower.contains('fee') ||
          lower.contains('deposit') ||
          lower.contains('compensation') ||
          lower.contains('refund') ||
          lower.contains('paid') ||
          lower.contains('value') ||
          lower.contains('income') ||
          lower.contains('bonus') ||
          lower.contains('settlement') ||
          lower.contains('gratuity') ||
          lower.contains('encashment') ||
          lower.contains('cost') ||
          lower.contains('advance') ||
          lower.contains('balance') ||
          lower.contains('contribution') ||
          lower.contains('consideration') ||
          lower.contains('maintenance') ||
          lower.contains('sharing') ||
          lower.contains('rate') ||
          lower.contains('investment')) {
        fieldType = FormFieldType.currency;
      } else if (lower.contains('date')) {
        fieldType = FormFieldType.date;
      } else if (lower.contains('number') ||
          lower.contains('duration') ||
          lower.contains('days') ||
          lower.contains('period') ||
          lower.contains('age') ||
          lower.contains('ratio') ||
          lower.contains('rating')) {
        fieldType = FormFieldType.number;
      }
      return FormFieldDefinition(
        id: key,
        label: label,
        hint: 'Enter $label',
        required: required,
        type: fieldType,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredTemplates = _popularTemplates.where((t) {
      if (query.isEmpty) return true;
      final title = (t['title'] as String).toLowerCase();
      final desc = (t['desc'] as String).toLowerCase();
      final cat = (t['category'] as String).toLowerCase();
      return title.contains(query) || desc.contains(query) || cat.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Draft Legal Document'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search template (Rent, Notice, Affidavit, RTI)...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Template Grid
              SectionLabel(
                query.isEmpty
                    ? 'POPULAR COURT-READY TEMPLATES'
                    : 'SEARCH RESULTS (${filteredTemplates.length})',
              ),
              const SizedBox(height: 12),

              if (filteredTemplates.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 40, color: AppColors.textSecondary),
                      const SizedBox(height: 10),
                      Text(
                        'No matching template found for "$_searchQuery"',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepForest,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Try searching for "Rent", "Notice", "Affidavit", or "RTI".',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final t = filteredTemplates[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            t['icon'] as IconData,
                            color: AppColors.deepForest,
                            size: 24,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.deepForest,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t['category'] as String,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepForest,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            t['desc'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () => _openDocumentById(
                          t['id'] as String,
                          t['title'] as String,
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),

              // Info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        color: AppColors.deepForest, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All templates comply with Indian statutory laws (Registration Act, Specific Relief Act, Negotiable Instruments Act, etc.) and generate printable PDFs.',
                        style: TextStyle(
                            fontSize: 11, height: 1.4, color: AppColors.deepForest),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  String _selectedCategoryFilter = 'All';

  static const List<String> _categoryFilters = [
    'All',
    'Agreements',
    'Notices',
    'Affidavits',
    'Court Filings',
    'Property & Estate',
    'Employment',
  ];

  static const List<Map<String, dynamic>> _allTemplates = [
    // 1. Agreements & Contracts
    {
      'id': 'rent_agreement',
      'title': 'Rent / Lease Agreement',
      'category': 'Agreements',
      'act': 'Model Tenancy & Registration Act',
      'icon': Icons.home_work_outlined,
      'desc': 'Residential lease with security deposit, lock-in & rent escalation terms',
    },
    {
      'id': 'sale_agreement',
      'title': 'Sale & Purchase Agreement',
      'category': 'Agreements',
      'act': 'Indian Contract Act & Sale of Goods',
      'icon': Icons.shopping_bag_outlined,
      'desc': 'Agreement for sale of immovable/movable property and goods',
    },
    {
      'id': 'partnership_deed',
      'title': 'Partnership Deed',
      'category': 'Agreements',
      'act': 'Indian Partnership Act 1932',
      'icon': Icons.handshake_outlined,
      'desc': 'Formal deed defining partner shares, capital, profits & firm rules',
    },
    {
      'id': 'mou_term_sheet',
      'title': 'MOU / Term Sheet',
      'category': 'Agreements',
      'act': 'Indian Contract Act 1872',
      'icon': Icons.description_outlined,
      'desc': 'Memorandum of Understanding setting mutual terms before final contract',
    },
    {
      'id': 'service_agreement',
      'title': 'Service Provider Agreement',
      'category': 'Agreements',
      'act': 'Specific Relief & Contract Act',
      'icon': Icons.design_services_outlined,
      'desc': 'Contract between service provider and client detailing scope & milestones',
    },
    {
      'id': 'nda_confidentiality',
      'title': 'Non-Disclosure (NDA)',
      'category': 'Agreements',
      'act': 'Trade Secrets & Contract Act',
      'icon': Icons.lock_outline_rounded,
      'desc': 'Mutual confidentiality agreement safeguarding proprietary business secrets',
    },
    {
      'id': 'employment_contract',
      'title': 'Employment Agreement',
      'category': 'Agreements',
      'act': 'Indian Contract & Labor Laws',
      'icon': Icons.work_outline_rounded,
      'desc': 'Comprehensive job terms, IP assignment, non-compete and duties',
    },
    {
      'id': 'freelance_contract',
      'title': 'Freelancer Contract',
      'category': 'Agreements',
      'act': 'Indian Contract Act 1872',
      'icon': Icons.laptop_chromebook_rounded,
      'desc': 'Independent contractor agreement with payment schedules & deliverables',
    },

    // 2. Notices & Demands
    {
      'id': 'legal_notice',
      'title': '15-Day Legal Notice',
      'category': 'Notices',
      'act': 'Sec 80 CPC / Specific Relief Act',
      'icon': Icons.gavel_rounded,
      'desc': 'Mandatory formal legal demand notice prior to filing court lawsuit',
    },
    {
      'id': 'cease_desist',
      'title': 'Cheque Bounce Notice',
      'category': 'Notices',
      'act': 'Section 138 Negotiable Instruments Act',
      'icon': Icons.account_balance_wallet_outlined,
      'desc': 'Statutory notice for dishonored cheque with 15 days payment demand',
    },
    {
      'id': 'demand_letter',
      'title': 'Payment Recovery Demand',
      'category': 'Notices',
      'act': 'Order 37 CPC / Contract Act',
      'icon': Icons.request_quote_outlined,
      'desc': 'Formal demand letter for unpaid dues, invoices or pending loans',
    },
    {
      'id': 'consumer_complaint',
      'title': 'Consumer Grievance Notice',
      'category': 'Notices',
      'act': 'Consumer Protection Act 2019',
      'icon': Icons.report_problem_outlined,
      'desc': 'Formal pre-litigation notice for defective products or deficiency of service',
    },
    {
      'id': 'police_complaint',
      'title': 'Police Complaint (FIR Draft)',
      'category': 'Notices',
      'act': 'Sec 154 CrPC / Sec 173 BNSS',
      'icon': Icons.local_police_outlined,
      'desc': 'Structured complaint application to SHO for cognizable criminal offenses',
    },

    // 3. Affidavits & Declarations
    {
      'id': 'general_affidavit',
      'title': 'General Sworn Affidavit',
      'category': 'Affidavits',
      'act': 'Notaries Act 1952 & Oath Act',
      'icon': Icons.verified_user_outlined,
      'desc': 'Standard sworn declaration for administrative and legal submissions',
    },
    {
      'id': 'name_change_affidavit',
      'title': 'Name Change Affidavit',
      'category': 'Affidavits',
      'act': 'Official Gazette & Passport Format',
      'icon': Icons.badge_outlined,
      'desc': 'Notarized declaration for newspaper publication, passport and ID update',
    },
    {
      'id': 'address_proof_affidavit',
      'title': 'Address Proof Affidavit',
      'category': 'Affidavits',
      'act': 'General Clauses & Notaries Act',
      'icon': Icons.location_on_outlined,
      'desc': 'Sworn affidavit establishing residence proof in absence of utility bills',
    },
    {
      'id': 'income_affidavit',
      'title': 'Income Declaration Affidavit',
      'category': 'Affidavits',
      'act': 'Revenue & Scholarship Formats',
      'icon': Icons.monetization_on_outlined,
      'desc': 'Affidavit declaring annual household income for quotas, grants and banks',
    },
    {
      'id': 'declaration_statement',
      'title': 'Self-Declaration Statement',
      'category': 'Affidavits',
      'act': 'Indian Evidence Act / BSA',
      'icon': Icons.assignment_turned_in_outlined,
      'desc': 'Formally signed self-declaration certificate for government procedures',
    },

    // 4. Court Filings & Petitions
    {
      'id': 'consumer_court_complaint',
      'title': 'Consumer Court Petition',
      'category': 'Court Filings',
      'act': 'CPA 2019 District/State Commission',
      'icon': Icons.account_balance_outlined,
      'desc': 'Complete formal petition with facts, jurisdiction, evidence index and prayer',
    },
    {
      'id': 'vakalatnama',
      'title': 'Court Vakalatnama Memo',
      'category': 'Court Filings',
      'act': 'Advocates Act 1961',
      'icon': Icons.edit_document,
      'desc': 'Formal authority document authorizing an advocate to represent in court',
    },
    {
      'id': 'bail_application',
      'title': 'Bail Application Draft',
      'category': 'Court Filings',
      'act': 'Sec 437/439 CrPC / BNSS 2023',
      'icon': Icons.balance_outlined,
      'desc': 'Structured petition for regular or interim bail before Magistrate / Sessions',
    },
    {
      'id': 'appeal_letter',
      'title': 'Legal Appeal Petition',
      'category': 'Court Filings',
      'act': 'CPC / CrPC Appellate Provisions',
      'icon': Icons.rule_folder_outlined,
      'desc': 'Formal memo of appeal challenging an impugned court order or decree',
    },
    {
      'id': 'rti_application',
      'title': 'RTI Application (Sec 6)',
      'category': 'Court Filings',
      'act': 'Right to Information Act 2005',
      'icon': Icons.article_outlined,
      'desc': 'Standard statutory request to Public Information Officer (PIO)',
    },

    // 5. Property & Estate
    {
      'id': 'will_testament',
      'title': 'Last Will & Testament',
      'category': 'Property & Estate',
      'act': 'Indian Succession Act 1925',
      'icon': Icons.history_edu_outlined,
      'desc': 'Legal will specifying executor, legal heirs, asset distribution and witnesses',
    },
    {
      'id': 'power_of_attorney',
      'title': 'Power of Attorney (PoA)',
      'category': 'Property & Estate',
      'act': 'Powers of Attorney Act 1882',
      'icon': Icons.assignment_ind_outlined,
      'desc': 'Grant General or Special authority for property, court & banking acts',
    },
    {
      'id': 'gift_deed',
      'title': 'Property Gift Deed',
      'category': 'Property & Estate',
      'act': 'Transfer of Property Act 1882',
      'icon': Icons.card_giftcard_outlined,
      'desc': 'Deed for voluntary transfer of immovable/movable asset without consideration',
    },
    {
      'id': 'relinquishment_deed',
      'title': 'Relinquishment Deed',
      'category': 'Property & Estate',
      'act': 'Registration Act 1908',
      'icon': Icons.real_estate_agent_outlined,
      'desc': 'Release deed surrendering share in ancestral property to co-heirs',
    },
    {
      'id': 'property_transfer_letter',
      'title': 'Property Mutation Request',
      'category': 'Property & Estate',
      'act': 'Municipal & Land Revenue Codes',
      'icon': Icons.apartment_outlined,
      'desc': 'Application for mutation and title update in municipal / society records',
    },

    // 6. HR & Employment
    {
      'id': 'resignation_letter',
      'title': 'Formal Resignation Letter',
      'category': 'Employment',
      'act': 'Standard Corporate / HR Code',
      'icon': Icons.exit_to_app_outlined,
      'desc': 'Resignation notice specifying notice period, handover and gratitude statement',
    },
    {
      'id': 'termination_letter',
      'title': 'Employment Termination Letter',
      'category': 'Employment',
      'act': 'Industrial Disputes & Labor Code',
      'icon': Icons.person_off_outlined,
      'desc': 'Official employer notice outlining termination terms, settlement & asset return',
    },
    {
      'id': 'experience_letter',
      'title': 'Experience & Relieving Letter',
      'category': 'Employment',
      'act': 'Standard Corporate Format',
      'icon': Icons.workspace_premium_outlined,
      'desc': 'Certificate confirming tenure, designation, achievements and clearance',
    },
    {
      'id': 'offer_letter',
      'title': 'Job Offer & Appointment Letter',
      'category': 'Employment',
      'act': 'Indian Contract Act 1872',
      'icon': Icons.mark_email_read_outlined,
      'desc': 'Official job appointment letter with CTC breakdown, probation & joining date',
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
    final filteredTemplates = _allTemplates.where((t) {
      final matchesCategory = _selectedCategoryFilter == 'All' ||
          (t['category'] as String) == _selectedCategoryFilter;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;
      final title = (t['title'] as String).toLowerCase();
      final desc = (t['desc'] as String).toLowerCase();
      final cat = (t['category'] as String).toLowerCase();
      final act = ((t['act'] ?? '') as String).toLowerCase();
      return title.contains(query) ||
          desc.contains(query) ||
          cat.contains(query) ||
          act.contains(query);
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
                    hintText: 'Search 32+ templates (Rent, Notice, PoA, RTI, Bail)...',
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

              const SizedBox(height: 16),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categoryFilters.map((cat) {
                    final isSelected = cat == _selectedCategoryFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedCategoryFilter = cat),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.deepForest
                                : AppColors.surface,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.deepForest
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Template Grid
              SectionLabel(
                query.isEmpty && _selectedCategoryFilter == 'All'
                    ? 'COURT-READY INDIAN LEGAL TEMPLATES (${_allTemplates.length})'
                    : 'TEMPLATES (${filteredTemplates.length})',
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
                        'Try searching for "Rent", "Notice", "Affidavit", "PoA", or "RTI".',
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
                            horizontal: 16, vertical: 10),
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
                                  fontSize: 14.5,
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepForest,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
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
                            if (t['act'] != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.shield_outlined,
                                      size: 13, color: AppColors.brightEmerald),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      t['act'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.deepForest,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
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

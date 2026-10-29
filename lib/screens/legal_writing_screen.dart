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
import '../widgets/hover_stay_reveal_box.dart';
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
    'Notices & Demands',
    'Consumer & RTI',
    'Agreements',
    'Affidavits',
    'Employment',
    'Property & PoA',
  ];

  static const List<Map<String, dynamic>> _allTemplates = [
    // 1. Notices & Demands (Consumer Protection Core)
    {
      'id': 'legal_notice',
      'title': '15-Day Legal Notice',
      'category': 'Notices & Demands',
      'act': 'Sec 80 CPC / Specific Relief Act',
      'icon': Icons.gavel_rounded,
      'desc': 'Mandatory formal legal demand notice prior to filing court lawsuit',
    },
    {
      'id': 'cease_desist',
      'title': 'Cheque Bounce Notice',
      'category': 'Notices & Demands',
      'act': 'Section 138 Negotiable Instruments Act',
      'icon': Icons.account_balance_wallet_outlined,
      'desc': 'Statutory notice for dishonored cheque with 15 days payment demand',
    },
    {
      'id': 'demand_letter',
      'title': 'Payment Recovery Demand',
      'category': 'Notices & Demands',
      'act': 'Order 37 CPC / Contract Act',
      'icon': Icons.request_quote_outlined,
      'desc': 'Formal demand letter for unpaid dues, invoices or pending loans',
    },
    {
      'id': 'consumer_complaint',
      'title': 'Consumer Grievance Notice',
      'category': 'Notices & Demands',
      'act': 'Consumer Protection Act 2019',
      'icon': Icons.report_problem_outlined,
      'desc': 'Formal pre-litigation notice for defective products or deficiency of service',
    },
    {
      'id': 'police_complaint',
      'title': 'Police Complaint (FIR Draft)',
      'category': 'Notices & Demands',
      'act': 'Sec 154 CrPC / Sec 173 BNSS',
      'icon': Icons.local_police_outlined,
      'desc': 'Structured complaint application to SHO for cognizable criminal offenses',
    },

    // 2. Consumer Court & RTI (Citizen Statutory Rights)
    {
      'id': 'consumer_court_complaint',
      'title': 'Consumer Court Petition',
      'category': 'Consumer & RTI',
      'act': 'CPA 2019 District/State Commission',
      'icon': Icons.account_balance_outlined,
      'desc': 'Complete formal petition with facts, jurisdiction, evidence index and prayer',
    },
    {
      'id': 'rti_application',
      'title': 'RTI Application (Sec 6)',
      'category': 'Consumer & RTI',
      'act': 'Right to Information Act 2005',
      'icon': Icons.article_outlined,
      'desc': 'Standard statutory request to Public Information Officer (PIO)',
    },

    // 3. Agreements & Leases (Consumer-safe)
    {
      'id': 'rent_agreement',
      'title': 'Rent / Lease Agreement',
      'category': 'Agreements',
      'act': 'Model Tenancy & Registration Act',
      'icon': Icons.home_work_outlined,
      'desc': 'Residential lease with security deposit, lock-in & rent escalation terms',
    },
    {
      'id': 'freelance_contract',
      'title': 'Freelancer Contract',
      'category': 'Agreements',
      'act': 'Indian Contract Act 1872',
      'icon': Icons.laptop_chromebook_rounded,
      'desc': 'Independent contractor agreement protecting gig workers with clear payment schedules',
    },

    // 4. Affidavits & Declarations
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

    // 5. Employment Self-Help (Employee Rights)
    {
      'id': 'resignation_letter',
      'title': 'Formal Resignation Letter',
      'category': 'Employment',
      'act': 'Standard Corporate / HR Code',
      'icon': Icons.exit_to_app_outlined,
      'desc': 'Resignation notice specifying notice period, handover and gratitude statement',
    },
    {
      'id': 'experience_letter',
      'title': 'Experience & Relieving Letter Request',
      'category': 'Employment',
      'act': 'Standard Corporate Format',
      'icon': Icons.workspace_premium_outlined,
      'desc': 'Formal request confirming tenure, designation, achievements and clearance',
    },

    // 6. Representation
    {
      'id': 'power_of_attorney',
      'title': 'Power of Attorney (PoA)',
      'category': 'Property & PoA',
      'act': 'Powers of Attorney Act 1882',
      'icon': Icons.assignment_ind_outlined,
      'desc': 'Grant General or Special authority for property, administrative & banking acts',
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
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmOffWhite,
        foregroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: AppColors.deepNavy),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
        title: Text(
          'Draft Legal Document',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.deepNavy,
                fontWeight: FontWeight.w800,
              ),
        ),
        leading: BackButton(
          color: AppColors.deepNavy,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.outline),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06162B49),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.deepNavy, fontSize: 14.5),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search 32+ templates (Rent, Notice, PoA, RTI, Bail)...',
                    hintStyle: const TextStyle(
                      color: AppColors.slateBlue,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.slateBlue),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.slateBlue),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.deepNavy
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.deepNavy
                                  : AppColors.outline,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.deepNavy,
                              fontSize: 12.5,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 22),

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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 40, color: AppColors.slateBlue),
                      const SizedBox(height: 10),
                      Text(
                        'No matching template found for "$_searchQuery"',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Try searching for "Rent", "Notice", "Affidavit", "PoA", or "RTI".',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.slateBlue),
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
                    final radius = BorderRadius.circular(14);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HoverStayRevealBox(
                        onTap: () => _openDocumentById(
                          t['id'] as String,
                          t['title'] as String,
                        ),
                        borderRadius: radius,
                        builder: (context, isRevealed) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: isRevealed
                                    ? AppColors.deepNavy.withValues(alpha: 0.35)
                                    : AppColors.outline,
                                width: isRevealed ? 1.4 : 1,
                              ),
                              borderRadius: radius,
                              boxShadow: [
                                BoxShadow(
                                  color: isRevealed
                                      ? AppColors.deepNavy.withValues(alpha: 0.1)
                                      : const Color(0x06162B49),
                                  blurRadius: isRevealed ? 12 : 8,
                                  offset: Offset(0, isRevealed ? 4 : 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isRevealed
                                        ? AppColors.mustardGold
                                            .withValues(alpha: 0.25)
                                        : AppColors.paleBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    t['icon'] as IconData,
                                    color: AppColors.deepNavy,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              t['title'] as String,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14.5,
                                                color: AppColors.deepNavy,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.paleYellow,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: const Color(0xFFF3DE9C)),
                                            ),
                                            child: Text(
                                              t['category'] as String,
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF8C5B00),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      HoverRevealContent(
                                        isRevealed: isRevealed,
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              t['desc'] as String,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.slateBlue,
                                                height: 1.35,
                                              ),
                                            ),
                                            if (t['act'] != null) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.shield_outlined,
                                                      size: 13,
                                                      color: AppColors
                                                          .mustardGold),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      t['act'] as String,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.deepNavy,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: AnimatedSlide(
                                    duration: const Duration(milliseconds: 180),
                                    offset: isRevealed
                                        ? const Offset(0.2, 0)
                                        : Offset.zero,
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: AppColors.slateBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),

              // Info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  border: Border.all(color: const Color(0xFFD4E2EC)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        color: AppColors.deepNavy, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All templates comply with Indian statutory laws (Registration Act, Specific Relief Act, Negotiable Instruments Act, etc.) and generate printable PDFs.',
                        style: TextStyle(
                            fontSize: 11.5, height: 1.4, color: AppColors.deepNavy),
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

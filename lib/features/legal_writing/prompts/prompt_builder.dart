import 'package:flutter/foundation.dart';
import '../../../constants/document_fields.dart';
import '../../../constants/document_prompts.dart';
import '../models/document_definition.dart';
import '../models/document_form_data.dart';

class PromptBuilder {
  const PromptBuilder();

  static const _batchTwoSystemPrompts = <String, String>{
    'sale_agreement':
        'Draft a professional Indian sale/purchase agreement. Structure it around the supplied parties, subject matter, consideration, payment, delivery or possession, representations, documents, charges, default, termination, dispute resolution and execution terms. Do not add property particulars, ownership facts, amounts, clauses dependent on missing facts, or legal references.',
    'partnership_deed':
        'Draft a professional Indian partnership deed. Use only the supplied firm, partners, business, office, capital, profit/loss, management, banking, accounts, admission, retirement, dissolution, dispute and execution terms. Do not invent partners, percentages, business facts, clauses, or statutory references.',
    'mou_term_sheet':
        'Draft a clear professional Indian MOU or term sheet from only the supplied facts. Address purpose, background, scope, responsibilities, commercial terms, milestones, confidentiality, exclusivity, IP, termination, dispute resolution, validity and execution where supplied. State binding or non-binding effect only if the user supplied that intention.',
    'general_affidavit':
        'Draft a formal Indian general affidavit using only the supplied deponent information, purpose, factual statements, declarations, supporting details, place, date, verification and witness/notary details. Do not add facts, legal references, or personal details.',
    'address_proof_affidavit':
        'Draft a formal Indian address affidavit using only the supplied deponent, current and previous address, address history, purpose, support, declaration, place, date and witness/notary details. Never infer an address or residence period.',
    'name_change_affidavit':
        'Draft a formal Indian name-change affidavit using only the supplied names, relationship details, date of birth, address, reason, declaration, place, date and witness/notary details. Do not invent personal information or legal references.',
    'income_affidavit':
        'Draft a formal Indian income affidavit using only the supplied deponent, occupation, employer or business, income sources, monthly or annual income, financial details, purpose, declaration, place, date and witness/notary details. Do not calculate or invent income.',
    'consumer_court_complaint':
        'Draft a structured Indian consumer court complaint with headings, facts, jurisdiction, documents, and prayer using only the supplied details. Include compensation or mental harassment only if supplied. Do not invent statutory provisions, transactions, dates, evidence, jurisdiction facts, or monetary claims.',
    'vakalatnama':
        'Draft a formal Indian vakalatnama using only the supplied client, advocate, court or tribunal, case, parties, authority, authorization terms, place, date and execution details. Do not invent court names, case numbers, parties, advocate details, or legal references.',
    'bail_application':
        'Draft a professionally structured Indian bail application using only the supplied applicant or accused, respondent, court, FIR/case details, police station, alleged offences or sections, custody, factual background, bail grounds, personal circumstances, prior cases, proposed conditions, prayer, place, date and signatures. Preserve supplied sections exactly; never invent IPC, BNS, BNSS, or other provisions.',
    'appeal_letter':
        'Draft a professional Indian appeal letter / petition using only the supplied appellant, respondent, court or authority, case/order details, impugned decision, relevant facts, grounds of appeal, prayer, limitation or delay information, supporting documents, and advocate or signatory details. Structure: Background → Impugned Decision → Grounds of Appeal → Prayer → Verification. Do not invent grounds, dates, case numbers, statutory provisions, or legal citations.',
    'will_testament':
        'Draft a formal Indian Last Will and Testament using only the supplied testator details, family/legal heir information, beneficiaries, assets, distribution, executor, alternate executor, specific wishes, liabilities, witnesses, place and date. Include only the beneficiaries and assets supplied; do not add any beneficiary, asset, or relationship that was not provided. Do not invent succession facts.',
    'power_of_attorney':
        'Draft a formal Indian Power of Attorney using only the supplied principal, agent/attorney, purpose, powers granted, property or transaction details, scope of authority, limitations or restrictions, duration, effective date, revocation or termination terms, consideration, witnesses, place and date. Do not grant any powers not explicitly supplied by the user.',
    'gift_deed':
        'Draft a professional Indian Gift Deed using only the supplied donor, donee, relationship, property description, asset details, location, ownership details, gift value, voluntary nature, donee acceptance, possession or transfer details, encumbrance information, witnesses, place and date. Do not fabricate property ownership, value, or registration details. Describe the gift as voluntary only if that information was supplied.',
    'relinquishment_deed':
        'Draft a professional Indian Relinquishment Deed using only the supplied grantor (relinquishing party), beneficiary, property type, description, location, original owner, rights relinquished, reason, voluntary declaration, no-coercion declaration, consideration, rights transferred to beneficiary, waiver of future claims, two witnesses, place and date. Do not invent property ownership, share, or co-owner details.',
    'resignation_letter':
        'Draft a professional Indian resignation letter using only the supplied employee, company, HR contact, position, department, dates, notice period, reason for resignation, transition help, knowledge transfer plan, final tasks, gratitude statement, and learnings. Do NOT introduce hostile, defamatory, threatening, or unprofessional language. Omit any optional field not supplied.',
    'termination_letter':
        'Draft a formal Indian employment termination letter using only the supplied company, employee, designation, department, termination date, last working day, reason (if supplied), final settlement details, items to return, return date, reference letter status, and service certificate status. Do not fabricate settlement amounts, employment history, or reasons. Do not use defamatory, discriminatory, or unlawful language.',
    'experience_letter':
        'Draft a professional Indian employment experience letter using only the supplied company, employee, designation, employment period, job title, responsibilities, skills, performance, conduct, achievements, recommendation, and reference contact. Only include ratings and recommendations if those details were supplied. Do not create false performance claims or qualifications.',
    'offer_letter':
        'Draft a professional Indian job offer letter / appointment letter using only the supplied company, candidate, job title, department, reporting structure, work location, responsibilities, key objectives, compensation, benefits, employment type, probation, joining date, working hours, travel requirement, confidentiality clause (if supplied), and acceptance instructions. Do not invent salary, benefits, working conditions, or employment terms.',
  };

  static const _batchTwoDocumentIds = {
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
    'appeal_letter',
    'will_testament',
    'power_of_attorney',
    'gift_deed',
    'relinquishment_deed',
    'resignation_letter',
    'termination_letter',
    'experience_letter',
    'offer_letter',
  };

  PromptResult build({
    required DocumentDefinition definition,
    required DocumentFormData formData,
  }) {
    const language = 'English';
    if (definition.promptId == 'rent_agreement') {
      return _buildRentAgreementPrompt(formData, language);
    }
    final config = documentTypeFields[definition.promptId];
    final prompts = documentPrompts[definition.promptId];

    if (config == null || prompts == null) {
      return PromptResult(
        systemPrompt:
            'You are a professional Indian legal document drafter. Draft a complete professional legal document using only the user-supplied information. Do not invent facts.',
        userPrompt: _buildLegacyUserPrompt(definition, formData, language),
      );
    }

    final systemPrompt =
        '''${_batchTwoSystemPrompts[definition.promptId] ?? prompts['system']!}

Safety and accuracy requirements:
- Draft only from the user-provided information.
- Do not invent facts, dates, amounts, names, evidence, legal provisions, case numbers, or citations.
- Omit an optional detail when it has not been supplied; never print null, undefined, N/A, or an internal placeholder.
- Do not state that the document is legally verified, filed, or guaranteed to achieve an outcome.''';

    var userPrompt = _batchTwoDocumentIds.contains(definition.promptId)
        ? _buildBatchTwoUserPrompt(
            definition.promptId, config, formData, language)
        : prompts['user']!;

    userPrompt = _processOptionalLines(userPrompt, formData);
    userPrompt = _interpolateValues(userPrompt, formData, language);

    if (RegExp(r'\{[^}]+\}').hasMatch(userPrompt)) {
      if (kDebugMode) {
        debugPrint(
            '[PromptBuilder] Warning: unresolved placeholders remaining for ${definition.id}');
      }
    }

    return PromptResult(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }

  PromptResult _buildRentAgreementPrompt(
      DocumentFormData formData, String language) {
    final details = _flattenValues(formData.values);
    final isCommercial = details['agreementType'] == 'commercial';
    final variant = isCommercial ? 'commercial' : 'residential';
    final propertyDetails = isCommercial
        ? '''Commercial property type: ${details['commercialPropertyType'] ?? ''}
Permitted business use: ${details['permittedUse'] ?? ''}
Tenant business / trade name: ${details['businessName'] ?? ''}
Maintenance responsibility: ${details['maintenanceResponsibility'] ?? ''}'''
        : '''Furnished items: ${details['furnishedItems'] ?? ''}
Society maintenance included: ${details['societyMaintenanceIncluded'] ?? ''}''';
    return PromptResult(
      systemPrompt: '''You are a professional Indian legal document drafter.
Generate only a completed RENT AGREEMENT. Return no conversational text, JSON, Markdown fences, explanations, or use of the word "Draft".
Use only supplied facts and preserve them exactly. Never invent user-specific facts, legal citations, registration details, seals, approvals, dates, names, amounts, property particulars, or ID data.
Use this structure: RENT AGREEMENT; execution statement; BETWEEN; LANDLORD(S); AND; TENANT(S); WHEREAS; property recital; numbered contractual clauses; signature blocks for every landlord, tenant, and two witnesses.
${isCommercial ? 'For commercial premises, cover the supplied permitted business use, business name, maintenance responsibility, rent, deposit, term, lock-in, escalation and late-payment terms only when supplied.' : 'For residential premises, cover the supplied tenancy, possession/handover, rent, deposit, utilities/maintenance, use of property and quiet enjoyment terms only when supported by the supplied facts.'}''',
      userPrompt:
          '''Prepare a $variant rent agreement in $language using only these supplied details:
Agreement date: ${details['agreementDate'] ?? ''}
Execution city: ${details['executionCity'] ?? ''}
Execution state: ${details['executionState'] ?? ''}
Property address: ${details['propertyAddress'] ?? ''}
$propertyDetails
Tenancy start date: ${details['tenancyStartDate'] ?? ''}
Tenancy end date: ${details['tenancyEndDate'] ?? ''}
Tenancy period (months): ${details['tenancyPeriodMonths'] ?? ''}
Monthly rent: ${details['monthlyRent'] ?? ''}
Rent due day: ${details['rentDueDay'] ?? ''}
Security deposit: ${details['securityDeposit'] ?? ''}
Lock-in period: ${details['lockInPeriod'] ?? ''}
Annual rent escalation %: ${details['annualRentEscalation'] ?? ''}
Late payment interest % per month: ${details['latePaymentInterest'] ?? ''}
Additional clauses: ${details['additionalClauses'] ?? ''}
LANDLORD(S):
${details['landlords'] ?? ''}
TENANT(S):
${details['tenants'] ?? ''}

Output only the legal document.''',
    );
  }

  String _buildLegacyUserPrompt(
    DocumentDefinition definition,
    DocumentFormData formData,
    String language,
  ) {
    final fields = formData.values.entries
        .map((e) =>
            '${_readableFieldName(e.key)}: ${e.value?.toString().trim() ?? ''}')
        .join('\n');
    return '''Draft a complete professional ${definition.title} under Indian law.
Use only the following supplied details; do not invent facts or citations.
$fields
Write only the document in $language.''';
  }

  String _buildBatchTwoUserPrompt(
    String promptId,
    DocumentTypeConfig config,
    DocumentFormData formData,
    String language,
  ) {
    final flatValues = _flattenValues(formData.values);
    final details = [...config.required, ...config.optional]
        .map((key) => MapEntry(key, flatValues[key]?.trim() ?? ''))
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => '${_readableFieldName(entry.key)}: ${entry.value}')
        .join('\n');
    return '''Prepare the ${config.description} using the following user-supplied information only:
$details

Output only the completed document in $language.''';
  }

  Map<String, String> _flattenValues(Map<String, dynamic> values) {
    final result = <String, String>{};
    values.forEach((key, value) {
      if (value == null) {
        result[key] = '';
      } else if (value is String) {
        result[key] = value;
      } else if (value is List) {
        final items = value.asMap().entries.map((e) {
          final idx = e.key + 1;
          final item = e.value;
          if (item is Map<String, dynamic>) {
            final itemFields = item.entries
                .map((f) => '  ${_readableFieldName(f.key)}: ${f.value}')
                .join('\n');
            return 'Item $idx:\n$itemFields';
          }
          return 'Item $idx: $item';
        }).toList();
        result[key] = items.join('\n');
      } else {
        result[key] = value.toString();
      }
    });
    return result;
  }

  String _processOptionalLines(String userPrompt, DocumentFormData formData) {
    final flatValues = _flattenValues(formData.values);
    return userPrompt.split('\n').where((line) {
      final matches = RegExp(r'\{([^}]+)\}').allMatches(line);
      for (final match in matches) {
        final key = match.group(1)!;
        if (key == 'language') continue;
        final value = flatValues[key];
        if (value == null || value.trim().isEmpty) {
          return false;
        }
      }
      return true;
    }).join('\n');
  }

  String _interpolateValues(
      String userPrompt, DocumentFormData formData, String language) {
    final flatValues = _flattenValues(formData.values);
    var result = userPrompt;
    flatValues.forEach((key, value) {
      result = result.replaceAll('{$key}', value.trim());
    });
    result = result.replaceAll('{language}', language);
    return result;
  }

  String _readableFieldName(String key) => key
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAllMapped(
          RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m[1]} ${m[2]}');
}

class PromptResult {
  final String systemPrompt;
  final String userPrompt;

  const PromptResult({
    required this.systemPrompt,
    required this.userPrompt,
  });
}

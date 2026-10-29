import '../../../constants/document_fields.dart';
import '../models/document_definition.dart';
import 'rent_agreement.dart';
import 'legal_notice.dart';
import 'complaints_notices.dart';
import 'agreements_contracts.dart';
import 'affidavits_declarations.dart';
import 'court_legal_filings.dart';
import 'personal_property.dart';
import 'hr_employment.dart';
import '_definition_builder.dart';

final Map<String, DocumentDefinition> legalDocumentDefinitions = {
  // 1. Notices & Complaints (Consumer Protection)
  'legal_notice': legalNoticeDefinition,
  'consumer_complaint': consumerComplaintDefinition,
  'police_complaint': policeComplaintDefinition,
  'cease_desist': ceaseDesistDefinition,
  'demand_letter': demandLetterDefinition,

  // 2. Citizen Court & Statutory Filings
  'consumer_court_complaint': consumerCourtComplaintDefinition,
  'rti_application': rtiApplicationDefinition,

  // 3. Agreements & Tenancy
  'rent_agreement': rentAgreementDefinition,
  'freelance_contract': freelanceContractDefinition,

  // 4. Affidavits & Declarations
  'general_affidavit': generalAffidavitDefinition,
  'address_proof_affidavit': addressProofAffidavitDefinition,
  'name_change_affidavit': nameChangeAffidavitDefinition,
  'income_affidavit': incomeAffidavitDefinition,
  'declaration_statement': declarationStatementDefinition,

  // 5. Employment Self-Help
  'resignation_letter': resignationLetterDefinition,
  'experience_letter': experienceLetterDefinition,

  // 6. Representation
  'power_of_attorney': powerOfAttorneyDefinition,
};

DocumentDefinition? getDocumentDefinitionById(String id) {
  return legalDocumentDefinitions[id] ??
      _buildFallbackDefinition(id);
}

DocumentDefinition _buildFallbackDefinition(String id) {
  final config =
      documentTypeFields[id] ?? documentTypeFields[id.replaceAll('_', '')];
  return buildMinimalDocumentDefinition(
    id: id,
    title: config?.description ?? _humanize(id),
    description: 'Generate legal document',
    promptHint:
        'Enter the relevant details and we will prepare your document.',
    category: DocumentCategoryType.complaintsNotices,
    requiredKeys: config?.required ?? const [],
    optionalKeys: config?.optional ?? const [],
    promptId: id,
  );
}

String _humanize(String key) => key
    .replaceAll('_', ' ')
    .split(' ')
    .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
    .join(' ');

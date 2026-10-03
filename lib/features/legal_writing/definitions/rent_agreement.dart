import 'package:intl/intl.dart';

import '../models/document_definition.dart';
import '../models/form_field_definition.dart';
import '../models/form_section_definition.dart';

/// Both variants use the same config-driven form and generation flow.
DocumentDefinition get rentAgreementDefinition => DocumentDefinition(
      id: 'rent_agreement',
      title: 'Rent Agreement',
      description: 'Create a residential or commercial rent agreement',
      promptHint: 'Enter the agreement, property, terms, and party details.',
      category: DocumentCategoryType.agreementsContracts,
      promptId: 'rent_agreement',
      multiStep: true,
      sections: [
        FormSectionDefinition(
          id: 'agreement_type',
          title: 'Agreement Type',
          description: 'Choose the type of premises.',
          fields: const [
            FormFieldDefinition(
                id: 'agreementType',
                label: 'Agreement type',
                required: true,
                type: FormFieldType.radio,
                options: [
                  FieldOption(value: 'residential', label: 'Residential'),
                  FieldOption(value: 'commercial', label: 'Commercial'),
                ],
                defaultValue: 'residential'),
          ],
        ),
        FormSectionDefinition(
          id: 'agreement',
          title: 'Agreement',
          description: 'Execution details for this agreement.',
          fields: const [
            FormFieldDefinition(
                id: 'agreementDate',
                label: 'Agreement date',
                required: true,
                type: FormFieldType.date),
            FormFieldDefinition(
                id: 'executionCity', label: 'Execution city', required: true),
            FormFieldDefinition(
                id: 'executionState', label: 'Execution state', required: true),
          ],
        ),
        FormSectionDefinition(
          id: 'property',
          title: 'Property',
          fields: const [
            FormFieldDefinition(
                id: 'propertyAddress',
                label: 'Property address',
                required: true,
                type: FormFieldType.textarea),
            FormFieldDefinition(
                id: 'furnishedItems',
                label: 'Furnished items',
                hint: 'Optional — one item per line',
                type: FormFieldType.textarea,
                visibilityCondition: _isResidential),
            FormFieldDefinition(
                id: 'commercialPropertyType',
                label: 'Commercial property type',
                required: true,
                type: FormFieldType.dropdown,
                visibilityCondition: _isCommercial,
                options: [
                  FieldOption(value: 'office', label: 'Office'),
                  FieldOption(value: 'shop_showroom', label: 'Shop / Showroom'),
                  FieldOption(
                      value: 'warehouse_godown', label: 'Warehouse / Godown'),
                  FieldOption(value: 'other', label: 'Other'),
                ]),
            FormFieldDefinition(
                id: 'permittedUse',
                label: 'Permitted business use',
                required: true,
                hint: 'Describe the permitted use of the premises',
                type: FormFieldType.textarea,
                visibilityCondition: _isCommercial),
            FormFieldDefinition(
                id: 'businessName',
                label: 'Tenant business / trade name',
                type: FormFieldType.textarea,
                visibilityCondition: _isCommercial),
          ],
        ),
        FormSectionDefinition(
          id: 'terms_rent',
          title: 'Terms & Rent',
          fields: const [
            FormFieldDefinition(
                id: 'tenancyStartDate',
                label: 'Tenancy start date',
                required: true,
                type: FormFieldType.date),
            FormFieldDefinition(
                id: 'tenancyPeriodMonths',
                label: 'Tenancy period (months)',
                required: true,
                type: FormFieldType.number,
                validationRules: [
                  ValidationRule(
                      type: ValidationRule.min,
                      param: 1,
                      message: 'Tenancy period must be at least 1 month')
                ]),
            FormFieldDefinition(
                id: 'tenancyEndDate',
                label: 'Tenancy end date',
                hint: 'Calculated automatically',
                type: FormFieldType.date,
                isReadOnly: true),
            FormFieldDefinition(
                id: 'monthlyRent',
                label: 'Monthly rent',
                required: true,
                type: FormFieldType.currency),
            FormFieldDefinition(
                id: 'rentDueDay',
                label: 'Rent due day',
                required: true,
                type: FormFieldType.number,
                validationRules: [
                  ValidationRule(
                      type: ValidationRule.min,
                      param: 1,
                      message: 'Enter a day from 1 to 31'),
                  ValidationRule(
                      type: ValidationRule.max,
                      param: 31,
                      message: 'Enter a day from 1 to 31'),
                ]),
            FormFieldDefinition(
                id: 'securityDeposit',
                label: 'Security deposit',
                required: true,
                type: FormFieldType.currency),
            FormFieldDefinition(
                id: 'societyMaintenanceIncluded',
                label: 'Society maintenance included?',
                type: FormFieldType.toggle,
                defaultValue: false,
                visibilityCondition: _isResidential),
            FormFieldDefinition(
                id: 'maintenanceResponsibility',
                label: 'Maintenance responsibility',
                hint: 'Optional — maintenance, repairs and utilities',
                type: FormFieldType.textarea,
                visibilityCondition: _isCommercial),
            FormFieldDefinition(
                id: 'lockInPeriod',
                label: 'Lock-in period',
                hint: 'Optional (months)',
                type: FormFieldType.number),
            FormFieldDefinition(
                id: 'annualRentEscalation',
                label: 'Annual rent escalation %',
                type: FormFieldType.number),
            FormFieldDefinition(
                id: 'latePaymentInterest',
                label: 'Late payment interest % per month',
                type: FormFieldType.number),
            FormFieldDefinition(
                id: 'additionalClauses',
                label: 'Additional clauses',
                type: FormFieldType.textarea),
          ],
        ),
        RepeatableSectionDefinition(
            id: 'landlords',
            title: 'Landlords',
            description: 'Add every landlord who will execute the agreement.',
            itemTitlePrefix: 'Landlord',
            addButtonLabel: 'Add landlord',
            removeButtonLabel: 'Remove',
            fields: _partyFields),
        RepeatableSectionDefinition(
            id: 'tenants',
            title: 'Tenants',
            description: 'Add every tenant who will execute the agreement.',
            itemTitlePrefix: 'Tenant',
            addButtonLabel: 'Add tenant',
            removeButtonLabel: 'Remove',
            fields: _partyFields),
        FormSectionDefinition(
            id: 'review',
            title: 'Review',
            description: 'Review the supplied details before generation.'),
      ],
    );

bool _isResidential(Map<String, dynamic> values) =>
    values['agreementType'] == 'residential';
bool _isCommercial(Map<String, dynamic> values) =>
    values['agreementType'] == 'commercial';

String? calculateResidentialTenancyEndDate(String startDate, int months) {
  if (months < 1) return null;
  try {
    final start = DateFormat('dd MMM yyyy').parseStrict(startDate);
    final monthIndex = start.month - 1 + months;
    final year = start.year + monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
    final afterTerm = DateTime(year, month,
        start.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : start.day);
    return DateFormat('dd MMM yyyy')
        .format(afterTerm.subtract(const Duration(days: 1)));
  } on FormatException {
    return null;
  }
}

const _partyFields = [
  FormFieldDefinition(
      id: 'partyType',
      label: 'Party type',
      required: true,
      type: FormFieldType.dropdown,
      defaultValue: 'individual',
      options: [
        FieldOption(value: 'individual', label: 'Individual'),
        FieldOption(value: 'organization', label: 'Organization')
      ]),
  FormFieldDefinition(id: 'fullName', label: 'Full name', required: true),
  FormFieldDefinition(
      id: 'idType',
      label: 'ID type',
      required: true,
      type: FormFieldType.dropdown,
      defaultValue: 'aadhaar',
      options: [
        FieldOption(value: 'aadhaar', label: 'Aadhaar'),
        FieldOption(value: 'pan', label: 'PAN'),
        FieldOption(value: 'passport', label: 'Passport'),
        FieldOption(value: 'voter_id', label: 'Voter ID'),
        FieldOption(value: 'other', label: 'Other')
      ]),
  FormFieldDefinition(id: 'idNumber', label: 'ID number', required: true),
  FormFieldDefinition(
      id: 'currentAddress',
      label: 'Current address',
      required: true,
      type: FormFieldType.textarea),
];

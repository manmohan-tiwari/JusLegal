class DocumentPromptsComplete {
  static Map<String, String> getPromptsForType(
      String documentType, String language) {
    const languageName = 'English';

    final type =
        documentType.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');

    if (type.contains('legal notice')) {
      return _legalNoticePrompts(languageName);
    }
    if (type.contains('consumer complaint') && !type.contains('court')) {
      return _consumerComplaintPrompts(languageName);
    }
    if (type.contains('police complaint')) {
      return _policeComplaintPrompts(languageName);
    }
    if (type.contains('cease') && type.contains('desist')) {
      return _ceaseDesistPrompts(languageName);
    }
    if (type.contains('demand letter')) {
      return _demandLetterPrompts(languageName);
    }

    if (type.contains('rent agreement') || type.contains('rental')) {
      return _rentAgreementPrompts(languageName);
    }
    if (type.contains('service agreement')) {
      return _serviceAgreementPrompts(languageName);
    }
    if (type.contains('nda') || type.contains('confidentiality')) {
      return _ndaPrompts(languageName);
    }
    if (type.contains('employment contract')) {
      return _employmentContractPrompts(languageName);
    }
    if (type.contains('freelance')) {
      return _freelanceContractPrompts(languageName);
    }
    if (type.contains('sale agreement') || type.contains('purchase')) {
      return _saleAgreementPrompts(languageName);
    }
    if (type.contains('partnership deed')) {
      return _partnershipDeedPrompts(languageName);
    }
    if (type.contains('mou') || type.contains('term sheet')) {
      return _mouPrompts(languageName);
    }

    if (type.contains('affidavit')) {
      if (type.contains('address')) {
        return _addressAffidavitPrompts(languageName);
      }
      if (type.contains('name')) {
        return _nameChangeAffidavitPrompts(languageName);
      }
      if (type.contains('income')) {
        return _incomeAffidavitPrompts(languageName);
      }
      return _generalAffidavitPrompts(languageName);
    }

    if (type.contains('consumer court')) {
      return _consumerCourtComplaintPrompts(languageName);
    }
    if (type.contains('vakalatnama')) {
      return _vakaltnamaPrompts(languageName);
    }
    if (type.contains('bail')) {
      return _bailApplicationPrompts(languageName);
    }
    if (type.contains('appeal')) {
      return _appealLetterPrompts(languageName);
    }

    if (type.contains('will') || type.contains('testament')) {
      return _willTestamentPrompts(languageName);
    }
    if (type.contains('power of attorney') || type.contains('poa')) {
      return _powerOfAttorneyPrompts(languageName);
    }
    if (type.contains('gift deed')) {
      return _giftDeedPrompts(languageName);
    }
    if (type.contains('relinquish')) {
      return _relinquishmentDeedPrompts(languageName);
    }

    if (type.contains('resignation')) {
      return _resignationLetterPrompts(languageName);
    }
    if (type.contains('termination')) {
      return _terminationLetterPrompts(languageName);
    }
    if (type.contains('experience')) {
      return _experienceLetterPrompts(languageName);
    }
    if (type.contains('offer')) {
      return _offerLetterPrompts(languageName);
    }

    return _defaultDocumentPrompts(languageName);
  }

  static Map<String, String> _legalNoticePrompts(String language) {
    return {
      'system':
          '''You are a professional Indian legal writer specializing in formal legal notices.

YOUR TASK: Generate a LEGAL NOTICE - a formal written demand from one party to another.

DO NOT generate:
- Complaints or FIRs
- Agreements or contracts
- Casual letters
- Assumptions beyond provided data

DO generate:
- Professional legal notice format (To/From, Date, Subject)
- Clear statement of violation/breach
- Specific demands and deadline (e.g., 7/15/30 days)
- Legal consequences if not complied
- Reference to applicable Indian laws
- Signature block with witness areas
- Formal, assertive tone

Use ONLY the information provided. Do not assume prior notices or incidents.
Include proper legal structure and professional formatting.
Language: $language''',
      'user': '''Generate a LEGAL NOTICE based on this information:

Sender Name: {senderName}
Sender Address: {senderAddress}
Recipient Name: {recipientName}
Recipient Address: {recipientAddress}

Nature of Violation: {violationDetails}
Date of Incident: {incidentDate}
Legal Basis: {applicableLaw}
Demands: {demands}
Compliance Deadline: {deadlineDays} days

Generate a complete, formal legal notice in $language that:
1. Addresses the recipient formally
2. States the violation clearly
3. Cites applicable law
4. Makes specific demands
5. Sets clear deadline
6. Warns of legal consequences
7. Includes signature blocks

Do NOT assume multiple prior notices or repeated incidents.
Output ONLY the notice document.'''
    };
  }

  static Map<String, String> _consumerComplaintPrompts(String language) {
    return {
      'system':
          '''You are generating a CONSUMER COMPLAINT - a formal complaint to a business or company.

DO NOT generate:
- Legal notices (formal demands)
- Court filings
- Police complaints
- Casual emails

DO generate:
- Professional complaint letter format
- Clear problem description
- Specific dates and amounts
- Impact on consumer
- Relief sought (refund, replacement, compensation)
- Reference to Consumer Protection Act 2019
- Professional but firm tone
- 7-day response deadline

Use ONLY provided information. Do not assume prior complaints or escalations.
Language: $language''',
      'user': '''Generate a CONSUMER COMPLAINT based on this information:

Complainant Name: {complainantName}
Complainant Address: {complainantAddress}
Complainant Phone: {complainantPhone}

Business/Seller Name: {businessName}
Business Address: {businessAddress}

Product/Service: {productName}
Purchase Date: {purchaseDate}
Amount Paid: ₹{amountPaid}
Payment Method: {paymentMethod}

Problem Description: {problemDescription}
Relief Sought: {reliefSought}

Generate a complete consumer complaint letter in $language that:
1. Clearly describes the defect/issue
2. States impact on consumer
3. References Consumer Protection Act 2019
4. Demands specific relief
5. Sets 7-day response deadline
6. Professional, formal tone

Output ONLY the complaint letter.'''
    };
  }

  static Map<String, String> _policeComplaintPrompts(String language) {
    return {
      'system':
          '''You are generating a POLICE COMPLAINT (FIR draft) - formal complaint for police investigation.

DO NOT generate:
- Civil disputes
- Casual complaints
- Legal notices
- Assumptions about culpability

DO generate:
- FIR format (To Officer-in-Charge, Police Station)
- Accused details (if known)
- Detailed incident narrative
- Evidence available
- Applicable IPC sections
- Request for FIR registration
- Professional formal tone

Use ONLY provided information.
Language: $language''',
      'user':
          '''Generate a POLICE COMPLAINT (FIR Draft) based on this information:

Complainant Name: {complainantName}
Father's/Spouse Name: {fatherName}
Complainant Address: {complainantAddress}
Complainant Phone: {complainantPhone}

Crime Type: {crimeType}
Date of Incident: {incidentDate}
Time: {incidentTime}
Location: {incidentLocation}

Accused Details: {accusedDetails}

Detailed Description: {detailedDescription}

Evidence Available: {evidenceAvailable}

Generate an FIR complaint in $language that:
1. Addresses Officer-in-Charge
2. Provides complainant details
3. Describes incident chronologically
4. Lists evidence available
5. Cites relevant IPC sections
6. Requests FIR registration

Output ONLY the complaint.'''
    };
  }

  static Map<String, String> _ceaseDesistPrompts(String language) {
    return {
      'system':
          '''You are generating a CEASE & DESIST NOTICE - formal demand to stop unlawful activity.

DO NOT generate:
- Casual warnings
- Court documents
- Compensation demands (unless specified)
- Harassment accusations

DO generate:
- Professional notice format
- Clear description of infringing activity
- Specific legal violation
- Demand to cease immediately
- Consequences if not complied
- Short deadline (3-7 days)
- Reference to applicable law

Use ONLY provided information.
Language: $language''',
      'user': '''Generate a CEASE & DESIST NOTICE based on this information:

Sender Name: {senderName}
Sender Address: {senderAddress}

Recipient Name: {recipientName}
Recipient Address: {recipientAddress}

Violation Description: {violationDescription}
Infringing Activity: {infringingActivity}

Applicable Law: {applicableLaw}
Compliance Deadline: {deadlineDays} days

Generate a formal cease & desist notice in $language that:
1. Describes infringing activity
2. States legal violation
3. Demands immediate cessation
4. Sets short deadline
5. Warns of legal action
6. Professional tone

Output ONLY the notice.'''
    };
  }

  static Map<String, String> _demandLetterPrompts(String language) {
    return {
      'system':
          '''You are generating a DEMAND LETTER - formal demand for payment or action.

DO NOT generate:
- Threatening language
- Multiple demands with no clear primary
- Casual tone
- Assumptions

DO generate:
- Professional letter format
- Clear statement of what is owed
- Why it is owed (with evidence)
- Specific amount
- Payment deadline (7-15 days)
- Payment method/account details
- Legal consequences if not paid
- Professional, firm tone

Use ONLY provided information.
Language: $language''',
      'user': '''Generate a DEMAND LETTER based on this information:

Sender Name: {senderName}
Sender Address: {senderAddress}

Recipient Name: {recipientName}
Recipient Address: {recipientAddress}

Amount Demanded: ₹{amountDemanded}
Reason for Demand: {reasonForDemand}
Date Amount Became Due: {dateDue}

Supporting Details: {supportingDetails}
Payment Method: {paymentMethod}
Compliance Deadline: {deadlineDays} days

Generate a formal demand letter in $language that:
1. States amount owed clearly
2. Explains why it is owed
3. References any agreement/transaction
4. Demands payment by specific date
5. Lists payment methods
6. Warns of legal action if unpaid

Output ONLY the demand letter.'''
    };
  }

  static Map<String, String> _rentAgreementPrompts(String language) {
    return {
      'system':
          '''You are generating a RENT AGREEMENT - a binding contract between landlord and tenant.

You MUST respond ONLY with valid JSON. NO markdown, NO asterisks, NO code blocks.
Format:
{
  "document_text": "full document text..."
}

THIS IS AN AGREEMENT, NOT A COMPLAINT.

DO NOT generate:
- Breach notices or complaints
- Assumed payment defaults
- Damage scenarios
- Sub-letting incidents
- Any breach/violation narrative

DO generate:
- Professional agreement header with parties
- Clause 1: Parties & Property (description, type, area)
- Clause 2: Rent Terms (monthly amount, due date, mode of payment)
- Clause 3: Security Deposit (amount, conditions for refund)
- Clause 4: Maintenance & Repair (responsibility allocation)
- Clause 5: Term & Commencement (duration, start date, end date)
- Clause 6: Renewal & Termination (conditions)
- Clause 7: Restrictions (sub-letting, unlawful use)
- Clause 8: Notice Period (how to terminate)
- Clause 9: Miscellaneous (jurisdiction, modifications)
- Signature blocks for both parties + 2 witnesses
- Professional legal formatting

Use ONLY the provided information. Do NOT assume any breaches, defaults, or problems.
This is a fresh, clean rental agreement between parties.

Language: $language''',
      'user':
          '''Generate a RENT AGREEMENT (NOT a complaint) with this information:

LANDLORD DETAILS:
Name: {landlordName}
Address: {landlordAddress}
Phone: {landlordPhone}

TENANT DETAILS:
Name: {tenantName}
Address: {tenantAddress}
Phone: {tenantPhone}

PROPERTY DETAILS:
Address: {propertyAddress}
Type: {propertyType} (Residential/Commercial)
Description: {propertyDescription}

RENTAL TERMS:
Monthly Rent: ₹{monthlyRent}
Due Date: {rentDueDate}
Payment Method: {paymentMethod}
Security Deposit: ₹{securityDeposit}
Lease Duration: {leaseDuration} (e.g., 11 months, 1 year)
Start Date: {startDate}
End Date: {endDate}

ADDITIONAL TERMS:
Maintenance Responsibility: {maintenanceResponsibility}
Notice Period: {noticePeriod} days
Special Clauses: {specialClauses}

Generate a COMPLETE RENT AGREEMENT in $language that:
1. Identifies all parties with addresses
2. Describes the property clearly
3. States rent amount, due date, payment method
4. Specifies security deposit amount and refund conditions
5. Assigns maintenance responsibilities
6. States lease term clearly
7. Covers renewal and termination
8. Prohibits sub-letting without consent
9. Has signature blocks for landlord, tenant, and 2 witnesses
10. Uses professional legal formatting with numbered clauses

This is a FRESH AGREEMENT between parties starting their tenancy.
Do NOT include any breach scenarios, defaults, or complaints.
Do NOT assume any problems or incidents.

Output ONLY the complete agreement document.'''
    };
  }

  static Map<String, String> _serviceAgreementPrompts(String language) {
    return {
      'system':
          '''You are generating a SERVICE AGREEMENT - contract between service provider and client.

DO NOT generate complaints or breach notices.
Generate a clean, professional service agreement with terms, scope, fees, and termination.
Language: $language''',
      'user': '''Generate a SERVICE AGREEMENT with this information:

SERVICE PROVIDER:
Name: {providerName}
Address: {providerAddress}
Phone: {providerPhone}

CLIENT:
Name: {clientName}
Address: {clientAddress}
Phone: {clientPhone}

SERVICE DETAILS:
Service Description: {serviceDescription}
Service Duration: {serviceDuration}
Fee/Rate: ₹{servicefee}
Payment Schedule: {paymentSchedule}

TERMS:
Termination Notice: {terminationNotice} days
Deliverables: {deliverables}
Support Period: {supportPeriod}

Generate a complete service agreement in $language with:
1. Party details
2. Service scope and description
3. Fees and payment terms
4. Termination clause
5. Liability and warranties
6. Confidentiality clause
7. Signature blocks

Output ONLY the agreement.'''
    };
  }

  static Map<String, String> _ndaPrompts(String language) {
    return {
      'system': '''You are generating an NDA/CONFIDENTIALITY AGREEMENT.
Generate professional confidentiality terms protecting shared information.
Language: $language''',
      'user': '''Generate an NDA based on this information:

PARTY 1:
Name: {party1Name}
Address: {party1Address}

PARTY 2:
Name: {party2Name}
Address: {party2Address}

CONFIDENTIAL INFORMATION:
Type: {informationType}
Purpose of Sharing: {purpose}

TERMS:
Confidentiality Duration: {duration} years
Exceptions: {exceptions}

Generate a complete NDA in $language with:
1. Definitions of confidential information
2. Obligations of receiving party
3. Permitted disclosures
4. Return of information clause
5. Termination terms
6. Signature blocks

Output ONLY the agreement.'''
    };
  }

  static Map<String, String> _employmentContractPrompts(String language) {
    return {
      'system':
          '''You are generating an EMPLOYMENT CONTRACT between employer and employee.
Generate professional employment terms including position, salary, benefits, and termination.
Language: $language''',
      'user': '''Generate an EMPLOYMENT CONTRACT with this information:

EMPLOYER:
Name: {employerName}
Company: {companyName}
Address: {companyAddress}

EMPLOYEE:
Name: {employeeName}
Address: {employeeAddress}
Phone: {employeePhone}

EMPLOYMENT TERMS:
Position: {position}
Department: {department}
Salary: ₹{salary}/month
Start Date: {startDate}
Employment Type: {employmentType} (Permanent/Contract)
Probation Period: {probationPeriod} months

TERMS:
Notice Period: {noticePeriod} days
Working Hours: {workingHours}
Benefits: {benefits}

Generate a complete employment contract in $language with:
1. Position and responsibilities
2. Salary and benefits
3. Working hours and leave policy
4. Probation terms
5. Confidentiality clause
6. Termination clause
7. Dispute resolution

Output ONLY the contract.'''
    };
  }

  static Map<String, String> _freelanceContractPrompts(String language) {
    return {
      'system': '''You are generating a FREELANCE SERVICES AGREEMENT.
Generate professional contract for freelance work with scope, deliverables, and IP ownership.
Language: $language''',
      'user': '''Generate a FREELANCE CONTRACT with this information:

FREELANCER:
Name: {freelancerName}
Address: {freelancerAddress}
Phone: {freelancerPhone}

CLIENT:
Name: {clientName}
Address: {clientAddress}

PROJECT DETAILS:
Project Name: {projectName}
Description: {projectDescription}
Start Date: {startDate}
End Date: {endDate}
Fee: ₹{totalFee}
Payment Terms: {paymentTerms}

DELIVERABLES:
{deliverables}

IP OWNERSHIP:
Work Belongs To: {ipOwnership}

Generate a complete freelance contract in $language with:
1. Scope of work
2. Deliverables and timeline
3. Fees and payment schedule
4. IP ownership clause
5. Confidentiality
6. Termination terms
7. Dispute resolution

Output ONLY the contract.'''
    };
  }

  static Map<String, String> _saleAgreementPrompts(String language) {
    return {
      'system': '''You are generating a SALE/PURCHASE AGREEMENT.
Generate professional property/item sale agreement with terms, payment, and conditions.
Language: $language''',
      'user': '''Generate a SALE AGREEMENT with this information:

SELLER:
Name: {sellerName}
Address: {sellerAddress}
Phone: {sellerPhone}

BUYER:
Name: {buyerName}
Address: {buyerAddress}
Phone: {buyerPhone}

ITEM/PROPERTY:
Description: {itemDescription}
Location/Address: {itemAddress}
Condition: {itemCondition}

TRANSACTION:
Sale Price: ₹{salePrice}
Payment Schedule: {paymentSchedule}
Delivery Date: {deliveryDate}

WARRANTY:
{warrantyTerms}

Generate a complete sale agreement in $language with:
1. Item/property description
2. Sale price and payment terms
3. Delivery/possession terms
4. Warranty and guarantees
5. Condition of item
6. Dispute resolution
7. Signature blocks

Output ONLY the agreement.'''
    };
  }

  static Map<String, String> _partnershipDeedPrompts(String language) {
    return {
      'system':
          '''You are generating a PARTNERSHIP DEED - agreement between business partners.
Generate professional partnership terms including capital, profit-sharing, and exit clauses.
Language: $language''',
      'user': '''Generate a PARTNERSHIP DEED with this information:

PARTNERS:
{partnersList}
(Format: Name, Address, Capital Contribution)

BUSINESS:
Name: {businessName}
Type: {businessType}
Address: {businessAddress}

TERMS:
Total Capital: ₹{totalCapital}
Profit Sharing Ratio: {profitRatio}
Partner Roles: {partnerRoles}
Voting Rights: {votingRights}

EXIT/DISSOLUTION:
Notice Period: {noticePeriod} days
Buyout Terms: {buyoutTerms}

Generate a complete partnership deed in $language with:
1. Partner details and capital
2. Profit-sharing arrangement
3. Partner responsibilities
4. Decision-making process
5. Partner voting rights
6. Exit and dissolution clauses
7. Dispute resolution

Output ONLY the deed.'''
    };
  }

  static Map<String, String> _mouPrompts(String language) {
    return {
      'system': '''You are generating an MOU (MEMORANDUM OF UNDERSTANDING).
Generate professional MOU outlining collaboration terms between parties.
Language: $language''',
      'user': '''Generate an MOU with this information:

ORGANIZATION 1:
Name: {org1Name}
Address: {org1Address}

ORGANIZATION 2:
Name: {org2Name}
Address: {org2Address}

COLLABORATION:
Purpose: {collaborationPurpose}
Scope: {collaborationScope}
Duration: {duration}

KEY TERMS:
Confidentiality: {confidentiality}
Cost Sharing: {costSharing}
Dispute Resolution: {disputeResolution}

Generate a complete MOU in $language with:
1. Purpose of collaboration
2. Scope and objectives
3. Duration and review terms
4. Roles and responsibilities
5. Financial arrangements
6. Confidentiality
7. Termination clause

Output ONLY the MOU.'''
    };
  }

  static Map<String, String> _generalAffidavitPrompts(String language) {
    return {
      'system':
          '''You are generating a GENERAL AFFIDAVIT - sworn statement of facts.
Generate professional affidavit format with oath, statements, and signature blocks.
Language: $language''',
      'user': '''Generate a GENERAL AFFIDAVIT with this information:

AFFIANT DETAILS:
Name: {affiantName}
Father's/Spouse Name: {fatherName}
Occupation: {occupation}
Address: {affiantAddress}

PURPOSE:
{affidavitPurpose}

STATEMENTS TO AFFIRM:
{statements}

NUMBER OF WITNESSES:
{numWitnesses}

Generate a complete affidavit in $language with:
1. Header "AFFIDAVIT"
2. Affiant identification
3. "I, [name]... do hereby solemnly affirm..."
4. Numbered statements of facts
5. Declaration of truth
6. Signature block
7. Witness/notary blocks

Output ONLY the affidavit.'''
    };
  }

  static Map<String, String> _addressAffidavitPrompts(String language) {
    return {
      'system': '''You are generating an ADDRESS PROOF AFFIDAVIT.
Generate affidavit confirming residential address.
Language: $language''',
      'user': '''Generate an ADDRESS PROOF AFFIDAVIT with this information:

AFFIANT:
Name: {affiantName}
Father's/Spouse Name: {fatherName}
Occupation: {occupation}

ADDRESS DETAILS:
Current Address: {currentAddress}
Years Residing: {yearsResiding}
Previous Address: {previousAddress}
Purpose of Affidavit: {purpose}

Generate an address proof affidavit in $language with:
1. Affiant identification
2. Confirmation of address
3. Duration of residence
4. Purpose statement
5. Oath declaration
6. Signature blocks

Output ONLY the affidavit.'''
    };
  }

  static Map<String, String> _nameChangeAffidavitPrompts(String language) {
    return {
      'system': '''You are generating a NAME CHANGE AFFIDAVIT.
Generate affidavit for legal name change.
Language: $language''',
      'user': '''Generate a NAME CHANGE AFFIDAVIT with this information:

AFFIANT:
Old Name: {oldName}
New Name: {newName}
Father's/Spouse Name: {fatherName}
Address: {affiantAddress}

CHANGE DETAILS:
Date of Change: {dateOfChange}
Reason for Change: {reasonForChange}

Generate a name change affidavit in $language with:
1. Old name and new name
2. Reason for change
3. Declaration of use
4. Oath statement
5. Signature blocks

Output ONLY the affidavit.'''
    };
  }

  static Map<String, String> _incomeAffidavitPrompts(String language) {
    return {
      'system': '''You are generating an INCOME AFFIDAVIT.
Generate affidavit declaring income for loans, applications, etc.
Language: $language''',
      'user': '''Generate an INCOME AFFIDAVIT with this information:

AFFIANT:
Name: {affiantName}
Father's/Spouse Name: {fatherName}
Address: {affiantAddress}
Occupation: {occupation}

INCOME DETAILS:
Annual Income: ₹{annualIncome}
Income Source: {incomeSource}
Employment Type: {employmentType}
Employer Name: {employerName}

PURPOSE:
{affidavitPurpose}

Generate an income affidavit in $language with:
1. Affiant identification
2. Occupation and employment
3. Annual income amount
4. Income source
5. Declaration of truth
6. Signature blocks

Output ONLY the affidavit.'''
    };
  }

  static Map<String, String> _consumerCourtComplaintPrompts(String language) {
    return {
      'system':
          '''You are generating a CONSUMER COURT COMPLAINT under Consumer Protection Act 2019.
Generate formal court pleading with proper structure, jurisdiction, and relief.
Language: $language''',
      'user': '''Generate a CONSUMER COURT COMPLAINT with this information:

COMPLAINANT:
Name: {complainantName}
Address: {complainantAddress}
Phone: {complainantPhone}

OPPOSITE PARTY:
Name: {oppositeName}
Address: {oppositeAddress}

COMPLAINT DETAILS:
Date of Transaction: {transactionDate}
Amount Involved: ₹{amountInvolved}
Product/Service: {productService}
Issue: {issueDescription}

RELIEF CLAIMED:
Principal Amount: ₹{principalAmount}
Compensation: ₹{compensationAmount}
Total Claimed: ₹{totalClaimed}

Generate a consumer court complaint in $language with:
1. Court header
2. Complainant and opposite party
3. Jurisdiction statement
4. Facts of case
5. Cause of action
6. Relief claimed with amounts
7. Prayer clause

Output ONLY the court complaint.'''
    };
  }

  static Map<String, String> _vakaltnamaPrompts(String language) {
    return {
      'system':
          '''You are generating a VAKALATNAMA (Power of Attorney for legal proceedings).
Generate legal authorization for lawyer to represent in court.
Language: $language''',
      'user': '''Generate a VAKALATNAMA with this information:

PRINCIPAL:
Name: {principalName}
Address: {principalAddress}

ATTORNEY (LAWYER):
Name: {lawyerName}
Bar Council Registration: {barCouncilNo}
Address: {lawyerAddress}

CASE DETAILS:
Court: {courtName}
Case Number: {caseNumber}
Case Type: {caseType}
Opponent: {opponent}

SCOPE:
{scopeOfAuthority}

Generate a vakalatnama in $language with:
1. Principal identification
2. Attorney identification
3. Court details
4. Scope of authority
5. Authority granted clauses
6. Witness blocks
7. Notarization space

Output ONLY the vakalatnama.'''
    };
  }

  static Map<String, String> _bailApplicationPrompts(String language) {
    return {
      'system':
          '''You are generating a BAIL APPLICATION for criminal proceedings.
Generate application for bail with grounds, character references, and personal details.
Language: $language''',
      'user': '''Generate a BAIL APPLICATION with this information:

APPLICANT:
Name: {applicantName}
Father's/Spouse Name: {fatherName}
Address: {applicantAddress}
Age: {age}
Occupation: {occupation}

CASE DETAILS:
FIR Number: {firNumber}
Police Station: {policeStation}
Crime Sections: {crimeSections}
Arrest Date: {arrestDate}

GROUNDS FOR BAIL:
{groundsForBail}

CHARACTER REFERENCES:
Number of References: {numReferences}
{referencesList}

Generate a bail application in $language with:
1. Applicant details
2. Case and FIR details
3. Grounds for bail
4. Character references
5. Personal circumstances
6. Prayer clause

Output ONLY the application.'''
    };
  }

  static Map<String, String> _appealLetterPrompts(String language) {
    return {
      'system': '''You are generating an APPEAL LETTER against a decision/order.
Generate formal appeal with grounds, legal arguments, and specific relief.
Language: $language''',
      'user': '''Generate an APPEAL LETTER with this information:

APPELLANT:
Name: {appellantName}
Address: {appellantAddress}

ORIGINAL DECISION:
Court/Authority: {courtAuthority}
Date of Decision: {decisionDate}
Order Number: {orderNumber}
Decision Summary: {decisionSummary}

GROUNDS FOR APPEAL:
{groundsForAppeal}

LEGAL ARGUMENTS:
{legalArguments}

RELIEF SOUGHT:
{reliefSought}

Generate an appeal letter in $language with:
1. Appellant identification
2. Original decision details
3. Detailed grounds for appeal
4. Legal arguments and case law
5. Relief sought
6. Prayer clause

Output ONLY the appeal letter.'''
    };
  }

  static Map<String, String> _willTestamentPrompts(String language) {
    return {
      'system':
          '''You are generating a WILL/TESTAMENT - legal document distributing assets after death.
Generate professional will with proper structure, heirs, and executor designation.
Language: $language''',
      'user': '''Generate a WILL/TESTAMENT with this information:

TESTATOR:
Name: {testatorName}
Father's/Spouse Name: {fatherName}
Address: {testatorAddress}
Age: {age}

HEIRS/BENEFICIARIES:
{heirsList}
(Format: Name, Relationship, Share/Asset)

EXECUTOR:
Name: {executorName}
Address: {executorAddress}
Relationship: {executorRelationship}

ASSETS:
{assetsList}

WITNESSES:
Number Required: 2
{witnessesList}

Generate a complete will in $language with:
1. Testator identification
2. Revocation of previous wills
3. Executor appointment
4. Asset descriptions
5. Distribution to beneficiaries
6. Guardian appointment (if minors)
7. Signature blocks
8. Witness attestation

Output ONLY the will.'''
    };
  }

  static Map<String, String> _powerOfAttorneyPrompts(String language) {
    return {
      'system':
          '''You are generating a POWER OF ATTORNEY - legal authorization to act on behalf of principal.
Generate POA with specified powers and scope.
Language: $language''',
      'user': '''Generate a POWER OF ATTORNEY with this information:

PRINCIPAL:
Name: {principalName}
Address: {principalAddress}
ID: {principalID}

ATTORNEY-IN-FACT (AGENT):
Name: {agentName}
Address: {agentAddress}
Relationship: {agentRelationship}

POA TYPE:
{poaType} (General/Limited/Healthcare/Financial)

POWERS GRANTED:
{powersGranted}

DURATION:
Effective Date: {effectiveDate}
Expiry Date: {expiryDate}
Revocable: {revocable}

Generate a POA in $language with:
1. Principal details
2. Agent identification
3. Powers granted (specific or general)
4. Duration and revocation terms
5. Notarization block
6. Witness blocks

Output ONLY the POA.'''
    };
  }

  static Map<String, String> _giftDeedPrompts(String language) {
    return {
      'system':
          '''You are generating a GIFT DEED - legal transfer of property as gift.
Generate deed with donor, recipient, property description, and no consideration.
Language: $language''',
      'user': '''Generate a GIFT DEED with this information:

DONOR:
Name: {donorName}
Address: {donorAddress}
ID: {donorID}

RECIPIENT (DONEE):
Name: {recipientName}
Address: {recipientAddress}
Relationship: {relationship}
ID: {recipientID}

PROPERTY:
Description: {propertyDescription}
Address: {propertyAddress}
Value: ₹{propertyValue}

CONDITIONS:
{giftConditions}

CONSIDERATION:
None (Voluntary Gift)

Generate a gift deed in $language with:
1. Donor and recipient details
2. Property description
3. Statement of gift/no consideration
4. Conditions (if any)
5. Signature blocks
6. Witness blocks
7. Notarization space

Output ONLY the deed.'''
    };
  }

  static Map<String, String> _relinquishmentDeedPrompts(String language) {
    return {
      'system':
          '''You are generating a RELINQUISHMENT DEED - abandonment of rights over property.
Generate deed with clear relinquishment of claims and rights.
Language: $language''',
      'user': '''Generate a RELINQUISHMENT DEED with this information:

RELINQUISHER:
Name: {relinquisherName}
Address: {relinquisherAddress}
ID: {relinquisherID}

BENEFICIARY:
Name: {beneficiaryName}
Address: {beneficiaryAddress}
Relationship: {relationship}

PROPERTY:
Description: {propertyDescription}
Address: {propertyAddress}

REASON FOR RELINQUISHMENT:
{reasonForRelinquishment}

Generate a relinquishment deed in $language with:
1. Relinquisher and beneficiary details
2. Property description
3. Clear relinquishment statement
4. Reasons for relinquishment
5. Signature blocks
6. Witness blocks
7. Notarization space

Output ONLY the deed.'''
    };
  }

  static Map<String, String> _resignationLetterPrompts(String language) {
    return {
      'system':
          '''You are generating a RESIGNATION LETTER from employee to employer.
Generate professional resignation with notice period and gratitude.
Language: $language''',
      'user': '''Generate a RESIGNATION LETTER with this information:

EMPLOYEE:
Name: {employeeName}
Employee ID: {employeeID}
Designation: {designation}
Department: {department}

COMPANY:
Company Name: {companyName}
Address: {companyAddress}

RESIGNATION DETAILS:
Last Working Day: {lastWorkingDay}
Notice Period Given: {noticePeriod} days
Reason (Optional): {resignationReason}

Generate a resignation letter in $language that:
1. States clear resignation
2. Mentions last working day
3. Thanks the employer
4. Offers assistance during transition
5. Professional, positive tone

Output ONLY the resignation letter.'''
    };
  }

  static Map<String, String> _terminationLetterPrompts(String language) {
    return {
      'system':
          '''You are generating an EMPLOYMENT TERMINATION LETTER from employer to employee.
Generate termination notice with reason, final settlement, and details.
Language: $language''',
      'user': '''Generate a TERMINATION LETTER with this information:

EMPLOYEE:
Name: {employeeName}
Employee ID: {employeeID}
Designation: {designation}
Department: {department}

COMPANY:
Company Name: {companyName}
Address: {companyAddress}
HR Contact: {hrContact}

TERMINATION DETAILS:
Termination Date: {terminationDate}
Reason: {terminationReason}
Severance: ₹{severanceAmount}
Final Settlement: {finalSettlementDetails}

HANDOVER DETAILS:
{handoverInstructions}

Generate a termination letter in $language with:
1. Confirmation of termination
2. Termination date
3. Reason (if applicable)
4. Final settlement details
5. Handover instructions
6. Contact for queries
7. Professional tone

Output ONLY the termination letter.'''
    };
  }

  static Map<String, String> _experienceLetterPrompts(String language) {
    return {
      'system':
          '''You are generating an EXPERIENCE CERTIFICATE from employer to employee.
Generate professional certificate with designation, duration, and achievements.
Language: $language''',
      'user': '''Generate an EXPERIENCE CERTIFICATE with this information:

EMPLOYEE:
Name: {employeeName}
Employee ID: {employeeID}
Designation: {designation}
Department: {department}

EMPLOYMENT PERIOD:
Start Date: {startDate}
End Date: {endDate}
Duration: {duration}

ACHIEVEMENTS:
{achievements}

PERFORMANCE RATING:
{performanceRating} (Excellent/Good/Satisfactory)

REHIRE ELIGIBILITY:
{reHireEligible} (Yes/No)

Generate an experience certificate in $language with:
1. Employee identification
2. Employment period
3. Designation and responsibilities
4. Key achievements/contributions
5. Performance rating
6. Rehire eligibility statement
7. Company stamp/signature block

Output ONLY the certificate.'''
    };
  }

  static Map<String, String> _offerLetterPrompts(String language) {
    return {
      'system':
          '''You are generating a JOB OFFER LETTER from employer to candidate.
Generate professional offer with position, salary, benefits, and joining date.
Language: $language''',
      'user': '''Generate a JOB OFFER LETTER with this information:

CANDIDATE:
Name: {candidateName}
Address: {candidateAddress}
Email: {candidateEmail}

COMPANY:
Company Name: {companyName}
Address: {companyAddress}

OFFER DETAILS:
Position: {positionName}
Department: {department}
Salary: ₹{salary}/month
Joining Date: {joiningDate}
Employment Type: {employmentType}

BENEFITS:
{benefitsDetails}

TERMS:
Probation Period: {probationPeriod} months
Notice Period: {noticePeriod} days

Generate a job offer letter in $language with:
1. Offer of position
2. Salary and benefits
3. Joining date
4. Reporting manager
5. Probation terms
6. At-will employment clause
7. Acceptance deadline
8. Contact for queries

Output ONLY the offer letter.'''
    };
  }

  static Map<String, String> _defaultDocumentPrompts(String language) {
    return {
      'system':
          '''You are generating a legal document based on provided information.
Use professional legal formatting and Indian legal terminology.
Include proper structure with headers, signature blocks, and witness areas.
Language: $language''',
      'user':
          '''Generate a professional legal document in $language with the provided information.
Ensure proper formatting, clear language, and complete structure.
Output ONLY the document.'''
    };
  }
}

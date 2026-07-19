import '../../models/form_field_model.dart';
import '../../models/form_template_model.dart';

class FormTemplates {
  static const List<FormTemplateModel> all = [
    // ── 1. Consumer Complaint ───────────────────────────────────────────────
    FormTemplateModel(
      id: 'consumer_complaint',
      title: 'Consumer Complaint',
      subtitle: 'File a complaint against defective goods or deficient services',
      authority: 'District Consumer Disputes Redressal Commission',
      actReference: 'Consumer Protection Act, 2019',
      instructions:
          'Print this form, attach supporting documents, and submit at your District Consumer Forum. Pay the prescribed filing fee.',
      documents: [
        'Copy of bill / invoice / receipt',
        'Warranty card (if applicable)',
        'Correspondence with company (emails, chats)',
        'Photos of defective product (if applicable)',
        'Bank statement showing payment',
      ],
      fields: [
        FormFieldModel(key: 'complainant_name', label: 'Complainant Full Name', type: FormFieldType.text, required: true, hint: 'Your full legal name'),
        FormFieldModel(key: 'complainant_address', label: 'Complainant Address', type: FormFieldType.textarea, required: true, hint: 'Full address with pin code', maxLines: 3),
        FormFieldModel(key: 'complainant_phone', label: 'Phone Number', type: FormFieldType.phone, required: true, hint: '10-digit mobile number'),
        FormFieldModel(key: 'complainant_email', label: 'Email Address', type: FormFieldType.email, hint: 'your@email.com'),
        FormFieldModel(key: 'opposite_party_name', label: 'Opposite Party (Company/Person)', type: FormFieldType.text, required: true, hint: 'Full name of company or person'),
        FormFieldModel(key: 'opposite_party_address', label: 'Opposite Party Address', type: FormFieldType.textarea, required: true, hint: 'Registered address of company', maxLines: 3),
        FormFieldModel(key: 'complaint_category', label: 'Nature of Complaint', type: FormFieldType.dropdown, required: true, options: ['Defective Goods', 'Deficient Services', 'Unfair Trade Practice', 'Overcharging', 'Misleading Advertisement', 'Other']),
        FormFieldModel(key: 'purchase_date', label: 'Date of Purchase / Service', type: FormFieldType.date, required: true, hint: 'DD/MM/YYYY'),
        FormFieldModel(key: 'amount', label: 'Amount Paid (₹)', type: FormFieldType.number, required: true, hint: 'e.g. 5000', prefix: '₹'),
        FormFieldModel(key: 'complaint_details', label: 'Details of Complaint', type: FormFieldType.textarea, required: true, hint: 'Describe the issue in detail — what happened, when, and how', maxLines: 6),
        FormFieldModel(key: 'relief_sought', label: 'Relief / Compensation Sought', type: FormFieldType.textarea, required: true, hint: 'What do you want — refund, replacement, compensation?', maxLines: 3),
        FormFieldModel(key: 'previous_complaints', label: 'Previous Complaints to Company', type: FormFieldType.textarea, hint: 'Mention any emails, calls, or complaints already made', maxLines: 3),
      ],
    ),

    // ── 2. RTI Application ──────────────────────────────────────────────────
    FormTemplateModel(
      id: 'rti_application',
      title: 'RTI Application',
      subtitle: 'Request information from any government department',
      authority: 'Public Information Officer (PIO) of concerned department',
      actReference: 'Right to Information Act, 2005',
      instructions:
          'Submit to the PIO of the concerned department with ₹10 application fee (IPO/DD/cash). BPL applicants are exempt from fee.',
      documents: [
        'Application fee of ₹10 (IPO / Demand Draft / Court Fee Stamp)',
        'BPL certificate (if claiming fee exemption)',
        'Identity proof (optional but recommended)',
      ],
      fields: [
        FormFieldModel(key: 'applicant_name', label: 'Applicant Full Name', type: FormFieldType.text, required: true, hint: 'Your full legal name'),
        FormFieldModel(key: 'applicant_address', label: 'Applicant Address', type: FormFieldType.textarea, required: true, hint: 'Full postal address', maxLines: 3),
        FormFieldModel(key: 'applicant_phone', label: 'Phone Number', type: FormFieldType.phone, hint: '10-digit mobile number'),
        FormFieldModel(key: 'applicant_email', label: 'Email Address', type: FormFieldType.email, hint: 'your@email.com'),
        FormFieldModel(key: 'department_name', label: 'Department / Ministry Name', type: FormFieldType.text, required: true, hint: 'e.g. Municipal Corporation, Income Tax Department'),
        FormFieldModel(key: 'pio_address', label: 'PIO Office Address', type: FormFieldType.textarea, required: true, hint: 'Address of Public Information Officer', maxLines: 3),
        FormFieldModel(key: 'information_sought', label: 'Information Sought', type: FormFieldType.textarea, required: true, hint: 'Clearly state what information you need. Be specific.', maxLines: 6),
        FormFieldModel(key: 'time_period', label: 'Time Period of Information', type: FormFieldType.text, hint: 'e.g. From April 2022 to March 2023'),
        FormFieldModel(key: 'format_required', label: 'Format Required', type: FormFieldType.dropdown, options: ['Certified Copies', 'Inspection of Records', 'Soft Copy / CD', 'Any Format']),
        FormFieldModel(key: 'is_bpl', label: 'Are you BPL (Below Poverty Line)?', type: FormFieldType.dropdown, options: ['No', 'Yes']),
        FormFieldModel(key: 'fee_details', label: 'Fee Payment Details', type: FormFieldType.text, hint: 'e.g. IPO No. 123456 / Cash ₹10'),
      ],
    ),

    // ── 3. Cyber Crime Complaint ────────────────────────────────────────────
    FormTemplateModel(
      id: 'cyber_crime',
      title: 'Cyber Crime Complaint',
      subtitle: 'Report online fraud, hacking, harassment or cyber crime',
      authority: 'Cyber Crime Cell / Police Station',
      actReference: 'Information Technology Act, 2000 & IPC',
      instructions:
          'Submit at your nearest Cyber Crime Cell or Police Station. You can also file online at cybercrime.gov.in.',
      documents: [
        'Screenshots of fraudulent messages / transactions',
        'Bank statement (for financial fraud)',
        'Email headers (for email fraud)',
        'URL / website link (for online fraud)',
        'Transaction ID / UTR number',
        'Any communication with accused',
      ],
      fields: [
        FormFieldModel(key: 'complainant_name', label: 'Complainant Full Name', type: FormFieldType.text, required: true, hint: 'Your full legal name'),
        FormFieldModel(key: 'complainant_address', label: 'Address', type: FormFieldType.textarea, required: true, hint: 'Full address with pin code', maxLines: 3),
        FormFieldModel(key: 'complainant_phone', label: 'Phone Number', type: FormFieldType.phone, required: true, hint: '10-digit mobile number'),
        FormFieldModel(key: 'complainant_email', label: 'Email Address', type: FormFieldType.email, required: true, hint: 'your@email.com'),
        FormFieldModel(key: 'crime_type', label: 'Type of Cyber Crime', type: FormFieldType.dropdown, required: true, options: ['Online Financial Fraud', 'Online Job Fraud', 'Social Media Fraud', 'Hacking / Unauthorized Access', 'Cyber Stalking / Harassment', 'Identity Theft', 'Phishing', 'Ransomware', 'Child Pornography', 'Other']),
        FormFieldModel(key: 'incident_date', label: 'Date of Incident', type: FormFieldType.date, required: true, hint: 'DD/MM/YYYY'),
        FormFieldModel(key: 'incident_description', label: 'Incident Description', type: FormFieldType.textarea, required: true, hint: 'Describe exactly what happened step by step', maxLines: 6),
        FormFieldModel(key: 'accused_details', label: 'Accused / Suspect Details', type: FormFieldType.textarea, hint: 'Phone number, email, website, social media profile of accused', maxLines: 3),
        FormFieldModel(key: 'amount_lost', label: 'Amount Lost (₹)', type: FormFieldType.number, hint: 'If financial fraud, enter amount', prefix: '₹'),
        FormFieldModel(key: 'transaction_id', label: 'Transaction ID / UTR', type: FormFieldType.text, hint: 'Bank transaction reference number'),
        FormFieldModel(key: 'bank_details', label: 'Your Bank & Account Details', type: FormFieldType.textarea, hint: 'Bank name, account number (last 4 digits only)', maxLines: 2),
        FormFieldModel(key: 'evidence_list', label: 'Evidence Available', type: FormFieldType.textarea, hint: 'List all evidence you have — screenshots, emails, etc.', maxLines: 3),
      ],
    ),

    // ── 4. Banking Ombudsman ────────────────────────────────────────────────
    FormTemplateModel(
      id: 'banking_ombudsman',
      title: 'Banking Ombudsman Complaint',
      subtitle: 'Complaint against bank for deficient services',
      authority: 'RBI Integrated Ombudsman / Banking Ombudsman',
      actReference: 'RBI Integrated Ombudsman Scheme, 2021',
      instructions:
          'First complain to your bank. If not resolved in 30 days, file at RBI Ombudsman (cms.rbi.org.in) or send by post to nearest RBI office.',
      documents: [
        'Copy of complaint to bank',
        'Bank\'s rejection/no-response proof',
        'Account statements',
        'Passbook / cheque copies',
        'Correspondence with bank',
      ],
      fields: [
        FormFieldModel(key: 'complainant_name', label: 'Complainant Full Name', type: FormFieldType.text, required: true, hint: 'Account holder name'),
        FormFieldModel(key: 'complainant_address', label: 'Address', type: FormFieldType.textarea, required: true, hint: 'Full address with pin code', maxLines: 3),
        FormFieldModel(key: 'complainant_phone', label: 'Phone Number', type: FormFieldType.phone, required: true, hint: '10-digit mobile number'),
        FormFieldModel(key: 'complainant_email', label: 'Email Address', type: FormFieldType.email, hint: 'your@email.com'),
        FormFieldModel(key: 'bank_name', label: 'Bank Name', type: FormFieldType.text, required: true, hint: 'e.g. State Bank of India'),
        FormFieldModel(key: 'branch_name', label: 'Branch Name & Address', type: FormFieldType.textarea, required: true, hint: 'Branch where account is held', maxLines: 2),
        FormFieldModel(key: 'account_number', label: 'Account Number', type: FormFieldType.text, required: true, hint: 'Your bank account number'),
        FormFieldModel(key: 'complaint_type', label: 'Nature of Complaint', type: FormFieldType.dropdown, required: true, options: ['Non-credit of amount', 'Unauthorized debit', 'ATM / Debit Card issue', 'Credit Card issue', 'Loan related', 'Internet Banking fraud', 'UPI / Mobile Banking', 'Cheque related', 'Account closure issue', 'Other']),
        FormFieldModel(key: 'complaint_date_to_bank', label: 'Date of Complaint to Bank', type: FormFieldType.date, required: true, hint: 'When did you first complain to bank?'),
        FormFieldModel(key: 'amount_involved', label: 'Amount Involved (₹)', type: FormFieldType.number, hint: 'Amount in dispute', prefix: '₹'),
        FormFieldModel(key: 'complaint_details', label: 'Complaint Details', type: FormFieldType.textarea, required: true, hint: 'Describe the issue and what the bank did or did not do', maxLines: 6),
        FormFieldModel(key: 'relief_sought', label: 'Relief Sought', type: FormFieldType.textarea, required: true, hint: 'What resolution do you want from the bank?', maxLines: 3),
      ],
    ),

    // ── 5. Motor Accident Claim ─────────────────────────────────────────────
    FormTemplateModel(
      id: 'motor_accident_claim',
      title: 'Motor Accident Claim (MACT)',
      subtitle: 'Claim compensation for motor accident injury or death',
      authority: 'Motor Accident Claims Tribunal (MACT)',
      actReference: 'Motor Vehicles Act, 1988 — Section 166',
      instructions:
          'File at the Motor Accident Claims Tribunal in the district where accident occurred or where claimant resides. No court fee required.',
      documents: [
        'FIR copy',
        'Medical reports and bills',
        'Disability certificate (if applicable)',
        'Death certificate (for death claims)',
        'Insurance policy of vehicle',
        'Driving license of accused',
        'Vehicle RC copy',
        'Income proof of deceased/injured',
        'Witness statements',
      ],
      fields: [
        FormFieldModel(key: 'claimant_name', label: 'Claimant Full Name', type: FormFieldType.text, required: true, hint: 'Injured person or legal heir'),
        FormFieldModel(key: 'claimant_address', label: 'Claimant Address', type: FormFieldType.textarea, required: true, hint: 'Full address with pin code', maxLines: 3),
        FormFieldModel(key: 'claimant_phone', label: 'Phone Number', type: FormFieldType.phone, required: true, hint: '10-digit mobile number'),
        FormFieldModel(key: 'claimant_relation', label: 'Relation to Victim', type: FormFieldType.dropdown, options: ['Self (Injured)', 'Spouse', 'Parent', 'Child', 'Legal Heir', 'Other']),
        FormFieldModel(key: 'accident_date', label: 'Date of Accident', type: FormFieldType.date, required: true, hint: 'DD/MM/YYYY'),
        FormFieldModel(key: 'accident_place', label: 'Place of Accident', type: FormFieldType.textarea, required: true, hint: 'Full location of accident', maxLines: 2),
        FormFieldModel(key: 'accident_description', label: 'How Accident Occurred', type: FormFieldType.textarea, required: true, hint: 'Describe how the accident happened', maxLines: 5),
        FormFieldModel(key: 'vehicle_number', label: 'Offending Vehicle Number', type: FormFieldType.text, required: true, hint: 'Registration number of vehicle at fault'),
        FormFieldModel(key: 'driver_name', label: 'Driver / Accused Name', type: FormFieldType.text, hint: 'Name of driver at fault'),
        FormFieldModel(key: 'insurance_company', label: 'Insurance Company of Vehicle', type: FormFieldType.text, hint: 'Insurance company name'),
        FormFieldModel(key: 'fir_number', label: 'FIR Number', type: FormFieldType.text, hint: 'Police FIR number if registered'),
        FormFieldModel(key: 'injuries', label: 'Nature of Injuries', type: FormFieldType.textarea, required: true, hint: 'Describe injuries sustained', maxLines: 3),
        FormFieldModel(key: 'medical_expenses', label: 'Medical Expenses Incurred (₹)', type: FormFieldType.number, hint: 'Total medical bills', prefix: '₹'),
        FormFieldModel(key: 'compensation_sought', label: 'Total Compensation Sought (₹)', type: FormFieldType.number, required: true, hint: 'Total amount claimed', prefix: '₹'),
      ],
    ),

    // ── 6. Labour Complaint ─────────────────────────────────────────────────
    FormTemplateModel(
      id: 'labour_complaint',
      title: 'Labour / Workmen Complaint',
      subtitle: 'Complaint for unpaid wages, wrongful termination or labour rights',
      authority: 'Labour Commissioner Office',
      actReference: 'Industrial Disputes Act, 1947 & Payment of Wages Act, 1936',
      instructions:
          'Submit at the Labour Commissioner or Assistant Labour Commissioner office in your district. Bring original documents.',
      documents: [
        'Appointment letter / offer letter',
        'Salary slips',
        'Bank statements showing salary credits',
        'Termination letter (if terminated)',
        'ID proof',
        'Any written communication with employer',
      ],
      fields: [
        FormFieldModel(key: 'worker_name', label: 'Worker / Employee Full Name', type: FormFieldType.text, required: true, hint: 'Your full legal name'),
        FormFieldModel(key: 'worker_address', label: 'Address', type: FormFieldType.textarea, required: true, hint: 'Full address with pin code', maxLines: 3),
        FormFieldModel(key: 'worker_phone', label: 'Phone Number', type: FormFieldType.phone, required: true, hint: '10-digit mobile number'),
        FormFieldModel(key: 'worker_designation', label: 'Designation / Role', type: FormFieldType.text, required: true, hint: 'Your job title'),
        FormFieldModel(key: 'employer_name', label: 'Employer / Company Name', type: FormFieldType.text, required: true, hint: 'Full name of employer or company'),
        FormFieldModel(key: 'employer_address', label: 'Employer Address', type: FormFieldType.textarea, required: true, hint: 'Company / factory address', maxLines: 3),
        FormFieldModel(key: 'employment_period', label: 'Employment Period', type: FormFieldType.text, required: true, hint: 'e.g. From Jan 2022 to Dec 2023'),
        FormFieldModel(key: 'monthly_wages', label: 'Monthly Wages (₹)', type: FormFieldType.number, required: true, hint: 'Your monthly salary', prefix: '₹'),
        FormFieldModel(key: 'complaint_type', label: 'Nature of Complaint', type: FormFieldType.dropdown, required: true, options: ['Unpaid Wages / Salary', 'Wrongful Termination', 'Illegal Deduction', 'Non-payment of Gratuity', 'Non-payment of PF/ESI', 'Forced Resignation', 'Sexual Harassment', 'Other']),
        FormFieldModel(key: 'dues_amount', label: 'Amount of Dues (₹)', type: FormFieldType.number, hint: 'Total unpaid amount', prefix: '₹'),
        FormFieldModel(key: 'complaint_details', label: 'Complaint Details', type: FormFieldType.textarea, required: true, hint: 'Describe what happened in detail', maxLines: 6),
        FormFieldModel(key: 'relief_sought', label: 'Relief Sought', type: FormFieldType.textarea, required: true, hint: 'What do you want — wages, reinstatement, compensation?', maxLines: 3),
      ],
    ),

    // ── 7. Lok Adalat Application ───────────────────────────────────────────
    FormTemplateModel(
      id: 'lok_adalat',
      title: 'Lok Adalat Application',
      subtitle: 'Apply for dispute resolution through Lok Adalat',
      authority: 'District Legal Services Authority (DLSA)',
      actReference: 'Legal Services Authorities Act, 1987',
      instructions:
          'Submit at DLSA office or through the court where your case is pending. Both parties must agree to Lok Adalat settlement.',
      documents: [
        'Copy of pending case / FIR (if any)',
        'Identity proof',
        'Documents related to dispute',
        'Any previous settlement attempts',
      ],
      fields: [
        FormFieldModel(key: 'applicant_name', label: 'Applicant Full Name', type: FormFieldType.text, required: true, hint: 'Your full legal name'),
        FormFieldModel(key: 'applicant_address', label: 'Address', type: FormFieldType.textarea, required: true, hint: 'Full address with pin code', maxLines: 3),
        FormFieldModel(key: 'applicant_phone', label: 'Phone Number', type: FormFieldType.phone, required: true, hint: '10-digit mobile number'),
        FormFieldModel(key: 'opposite_party', label: 'Opposite Party Name', type: FormFieldType.text, required: true, hint: 'Name of other party in dispute'),
        FormFieldModel(key: 'opposite_party_address', label: 'Opposite Party Address', type: FormFieldType.textarea, hint: 'Address of opposite party', maxLines: 3),
        FormFieldModel(key: 'dispute_type', label: 'Nature of Dispute', type: FormFieldType.dropdown, required: true, options: ['Motor Accident', 'Labour Dispute', 'Matrimonial (Non-divorce)', 'Land / Property', 'Cheque Bounce', 'Compoundable Criminal', 'Electricity Dispute', 'Consumer Dispute', 'Other']),
        FormFieldModel(key: 'case_number', label: 'Case / Complaint Number (if pending)', type: FormFieldType.text, hint: 'Court case or complaint reference'),
        FormFieldModel(key: 'court_name', label: 'Court / Forum Name', type: FormFieldType.text, hint: 'Where case is currently pending'),
        FormFieldModel(key: 'dispute_details', label: 'Dispute Details', type: FormFieldType.textarea, required: true, hint: 'Briefly describe the dispute', maxLines: 5),
        FormFieldModel(key: 'settlement_sought', label: 'Settlement Expected', type: FormFieldType.textarea, required: true, hint: 'What settlement are you looking for?', maxLines: 3),
      ],
    ),

    // ── 8. Legal Aid Application ────────────────────────────────────────────
    FormTemplateModel(
      id: 'legal_aid',
      title: 'Legal Aid Application',
      subtitle: 'Apply for free legal assistance from NALSA / DLSA',
      authority: 'NALSA / State Legal Services Authority / DLSA',
      actReference: 'Legal Services Authorities Act, 1987',
      instructions:
          'Submit at your District Legal Services Authority (DLSA) office. Legal aid is free for eligible persons.',
      documents: [
        'Income certificate (annual income below ₹1 lakh)',
        'Identity proof (Aadhaar / Voter ID)',
        'Documents related to legal matter',
        'SC/ST/OBC certificate (if applicable)',
        'Disability certificate (if applicable)',
      ],
      fields: [
        FormFieldModel(key: 'applicant_name', label: 'Applicant Full Name', type: FormFieldType.text, required: true, hint: 'Your full legal name'),
        FormFieldModel(key: 'applicant_address', label: 'Address', type: FormFieldType.textarea, required: true, hint: 'Full address with pin code', maxLines: 3),
        FormFieldModel(key: 'applicant_phone', label: 'Phone Number', type: FormFieldType.phone, required: true, hint: '10-digit mobile number'),
        FormFieldModel(key: 'applicant_age', label: 'Age', type: FormFieldType.number, required: true, hint: 'Your age in years'),
        FormFieldModel(key: 'applicant_gender', label: 'Gender', type: FormFieldType.dropdown, required: true, options: ['Male', 'Female', 'Transgender']),
        FormFieldModel(key: 'category', label: 'Eligibility Category', type: FormFieldType.dropdown, required: true, options: ['SC / ST', 'Women / Child', 'Disabled Person', 'Industrial Workman', 'Victim of Disaster', 'Person in Custody', 'Annual Income below ₹1 Lakh', 'Other']),
        FormFieldModel(key: 'annual_income', label: 'Annual Income (₹)', type: FormFieldType.number, required: true, hint: 'Your total annual income', prefix: '₹'),
        FormFieldModel(key: 'legal_matter_type', label: 'Type of Legal Matter', type: FormFieldType.dropdown, required: true, options: ['Criminal Case', 'Civil Case', 'Family Matter', 'Labour Dispute', 'Land / Property', 'Consumer Complaint', 'Other']),
        FormFieldModel(key: 'legal_matter_details', label: 'Details of Legal Matter', type: FormFieldType.textarea, required: true, hint: 'Briefly describe your legal problem', maxLines: 5),
        FormFieldModel(key: 'court_name', label: 'Court / Forum (if case filed)', type: FormFieldType.text, hint: 'Name of court if case already filed'),
        FormFieldModel(key: 'case_number', label: 'Case Number (if any)', type: FormFieldType.text, hint: 'Leave blank if not yet filed'),
      ],
    ),

    // ── 9. Rent Control Application ─────────────────────────────────────────
    FormTemplateModel(
      id: 'rent_control',
      title: 'Rent Control Application',
      subtitle: 'Application to Rent Controller for tenancy disputes',
      authority: 'Rent Controller / Rent Court',
      actReference: 'State Rent Control Act (varies by state)',
      instructions:
          'File at the Rent Controller office in your district. Court fee applicable as per state schedule.',
      documents: [
        'Rent agreement / lease deed',
        'Rent receipts',
        'Identity proof',
        'Property ownership documents (for landlord)',
        'Correspondence with other party',
        'Bank statements showing rent payments',
      ],
      fields: [
        FormFieldModel(key: 'applicant_name', label: 'Applicant Full Name', type: FormFieldType.text, required: true, hint: 'Landlord or tenant name'),
        FormFieldModel(key: 'applicant_role', label: 'Applicant Is', type: FormFieldType.dropdown, required: true, options: ['Landlord', 'Tenant']),
        FormFieldModel(key: 'applicant_address', label: 'Applicant Address', type: FormFieldType.textarea, required: true, hint: 'Full address', maxLines: 3),
        FormFieldModel(key: 'applicant_phone', label: 'Phone Number', type: FormFieldType.phone, required: true, hint: '10-digit mobile number'),
        FormFieldModel(key: 'opposite_party_name', label: 'Opposite Party Name', type: FormFieldType.text, required: true, hint: 'Tenant or landlord name'),
        FormFieldModel(key: 'opposite_party_address', label: 'Opposite Party Address', type: FormFieldType.textarea, required: true, hint: 'Full address', maxLines: 3),
        FormFieldModel(key: 'property_address', label: 'Rented Property Address', type: FormFieldType.textarea, required: true, hint: 'Full address of rented property', maxLines: 3),
        FormFieldModel(key: 'monthly_rent', label: 'Monthly Rent (₹)', type: FormFieldType.number, required: true, hint: 'Current monthly rent', prefix: '₹'),
        FormFieldModel(key: 'tenancy_start', label: 'Tenancy Start Date', type: FormFieldType.date, required: true, hint: 'DD/MM/YYYY'),
        FormFieldModel(key: 'application_type', label: 'Nature of Application', type: FormFieldType.dropdown, required: true, options: ['Eviction of Tenant', 'Fixation of Fair Rent', 'Recovery of Possession', 'Arrears of Rent', 'Deposit Refund', 'Illegal Enhancement of Rent', 'Other']),
        FormFieldModel(key: 'dispute_details', label: 'Details of Dispute', type: FormFieldType.textarea, required: true, hint: 'Describe the tenancy dispute in detail', maxLines: 6),
        FormFieldModel(key: 'relief_sought', label: 'Relief Sought', type: FormFieldType.textarea, required: true, hint: 'What order are you seeking from Rent Controller?', maxLines: 3),
      ],
    ),

    // ── 10. Cheque Bounce Complaint ─────────────────────────────────────────
    FormTemplateModel(
      id: 'cheque_bounce',
      title: 'Cheque Bounce Complaint',
      subtitle: 'Complaint for dishonoured cheque under NI Act Section 138',
      authority: 'Judicial Magistrate Court (First Class)',
      actReference: 'Negotiable Instruments Act, 1881 — Section 138',
      instructions:
          'Send legal notice within 30 days of cheque bounce. If payment not made in 15 days, file complaint in Magistrate Court within 30 days.',
      documents: [
        'Original dishonoured cheque',
        'Bank memo / return memo',
        'Copy of legal notice sent',
        'Proof of sending legal notice (postal receipt)',
        'Reply from accused (if any)',
        'Proof of legally enforceable debt',
      ],
      fields: [
        FormFieldModel(key: 'complainant_name', label: 'Complainant Full Name', type: FormFieldType.text, required: true, hint: 'Person who received the cheque'),
        FormFieldModel(key: 'complainant_address', label: 'Complainant Address', type: FormFieldType.textarea, required: true, hint: 'Full address with pin code', maxLines: 3),
        FormFieldModel(key: 'complainant_phone', label: 'Phone Number', type: FormFieldType.phone, required: true, hint: '10-digit mobile number'),
        FormFieldModel(key: 'accused_name', label: 'Accused Full Name', type: FormFieldType.text, required: true, hint: 'Person who issued the cheque'),
        FormFieldModel(key: 'accused_address', label: 'Accused Address', type: FormFieldType.textarea, required: true, hint: 'Full address of accused', maxLines: 3),
        FormFieldModel(key: 'cheque_number', label: 'Cheque Number', type: FormFieldType.text, required: true, hint: '6-digit cheque number'),
        FormFieldModel(key: 'cheque_amount', label: 'Cheque Amount (₹)', type: FormFieldType.number, required: true, hint: 'Amount on cheque', prefix: '₹'),
        FormFieldModel(key: 'cheque_date', label: 'Cheque Date', type: FormFieldType.date, required: true, hint: 'Date written on cheque'),
        FormFieldModel(key: 'bank_name', label: 'Drawee Bank Name & Branch', type: FormFieldType.text, required: true, hint: 'Bank and branch of accused'),
        FormFieldModel(key: 'bounce_date', label: 'Date of Cheque Bounce', type: FormFieldType.date, required: true, hint: 'Date bank returned the cheque'),
        FormFieldModel(key: 'bounce_reason', label: 'Reason for Bounce', type: FormFieldType.dropdown, required: true, options: ['Insufficient Funds', 'Account Closed', 'Signature Mismatch', 'Payment Stopped', 'Other']),
        FormFieldModel(key: 'legal_notice_date', label: 'Date Legal Notice Sent', type: FormFieldType.date, required: true, hint: 'Date you sent notice to accused'),
        FormFieldModel(key: 'debt_details', label: 'Nature of Debt / Transaction', type: FormFieldType.textarea, required: true, hint: 'Why was the cheque given — loan, goods, services?', maxLines: 4),
      ],
    ),
  ];

  static FormTemplateModel? getById(String id) {
    try {
      return all.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
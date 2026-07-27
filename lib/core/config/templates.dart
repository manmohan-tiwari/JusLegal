import 'package:flutter/material.dart';

import '../../models/document_category_model.dart';
import '../../models/document_type_model.dart';
import '../../models/form_field_model.dart';
import '../../models/form_template_model.dart';

class ComplaintTemplates {
  static Map<String, Map<String, String>> get templates => {
        'E-commerce & Shopping': {
          'email':
              '''Subject: Formal Complaint Regarding [Issue Type] - Order #[Order Number]

Date: [Current Date]

To,
[Company Name]
Customer Care Department
[Company Address]

Dear Sir/Madam,

I, [Your Name], residing at [Your Address], am writing to file a formal complaint regarding the following incident:

**Date of Incident:** [Incident Date]

**Order Details:**
- Order Number: [Order Number]
- Product/Service: [Product Details]
- Amount Paid: [Amount]
- Payment Method: [Payment Method]

**Detailed Description of the Problem:**
[User Problem Description]

**Legal Basis:**
As per the Consumer Protection Act 2019 and E-commerce Rules 2020, I am entitled to:
- [User Rights from Legal Analysis]

**Specific Grievances:**
- [Specific Issue 1]
- [Specific Issue 2]

**Relief Sought:**
I request the following resolution within 7 working days:
1. [Specific Resolution 1]
2. [Specific Resolution 2]
3. Compensation for inconvenience caused

I look forward to your prompt response. If this matter is not resolved within the stipulated time, I will be compelled to approach the Consumer Forum.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]
[Your Email Address]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]
[Police Station Address]

Subject: FIR Registration Against [Company/Person Name] for Fraud/Consumer Rights Violation

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], son/daughter/wife of [Parent's Name], residing at [Your Address], wish to file an FIR against [Company/Person Name] for the following incident:

**Date of Incident:** [Incident Date]
**Place of Incident:** [Location]
**Time of Incident:** [Time]

**Details of the Accused:**
- Name: [Company/Person Name]
- Address: [Address]
- Contact: [Phone/Email]

**Detailed Description of the Incident:**
[User Problem Description]

**Evidence Available:**
- Order Confirmations: [Yes/No]
- Payment Receipts: [Yes/No]
- Communication Records: [Yes/No]
- Other Documents: [Details]

**Sections of Law Applicable:**
- Indian Penal Code Sections: [Relevant Sections]
- Consumer Protection Act 2019
- Information Technology Act 2000 (if applicable)

**Prayer:**
I request you to register an FIR and initiate investigation into this matter. The accused has committed fraud and violated my consumer rights, causing financial and mental harassment.

I shall be obliged to provide any further information required.

Yours faithfully,
[Your Name]
[Your Address]
[Your Phone Number]
[Your Email Address]
[Aadhaar Number]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Age: [Your Age]
Occupation: [Your Occupation]
Address: [Your Complete Address]
Phone: [Your Phone Number]
Email: [Your Email Address]

**Opposite Party:**
Name: [Company/Person Name]
Address: [Complete Address]
Phone: [Phone Number]
Email: [Email Address]

**Subject:** Complaint for deficiency in service and unfair trade practice

**Jurisdiction:** 
This Hon'ble Commission has jurisdiction as the cause of action arose within its territorial limits and the opposite party carries on business within its jurisdiction.

**Facts of the Case:**
1. That the complainant is a consumer as defined under the Consumer Protection Act 2019.
2. That on [Incident Date], the complainant [details of transaction/purchase].
3. That the opposite party [details of what happened - User Problem Description].
4. That despite repeated requests, the opposite party failed to resolve the issue.

**Cause of Action:**
The cause of action arose on [Incident Date] and continues till date.

**Relief Claimed:**
The complainant prays for the following reliefs:

1. Refund of Rs.[Amount] paid for the product/service
2. Compensation of Rs.[Amount] for mental agony and harassment
3. Litigation costs of Rs.[Amount]
4. Any other relief this Hon'ble Commission deems fit

**Particulars of Claim:**
- Principal Amount: Rs.[Amount]
- Compensation for Mental Agony: Rs.[Amount]
- Litigation Costs: Rs.[Amount]
- **Total:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date] that the contents of this complaint are true to the best of my knowledge and belief.

**Complainant**
(Signature)
[Your Name]'''
        },
        'Banking & UPI Fraud': {
          'email':
              '''Subject: Urgent Complaint Regarding Unauthorized Transaction - Account #[Account Number]

Date: [Current Date]

To,
The Branch Manager
[Bank Name]
[Branch Address]

Dear Sir/Madam,

I, [Your Name], account holder [Account Number], wish to report an unauthorized transaction from my account.

**Date of Incident:** [Incident Date]
**Time of Incident:** [Transaction Time]
**Transaction Amount:** Rs.[Amount]
**Transaction ID:** [Transaction ID]
**Type of Transaction:** [UPI/NEFT/RTGS/IMPS]

**Detailed Description of the Problem:**
[User Problem Description]

**Immediate Action Required:**
1. Block the beneficiary account
2. Initiate chargeback process
3. Provide transaction details for police complaint
4. Reverse the unauthorized transaction

**Legal Basis:**
As per RBI Guidelines and IT Act 2000, the bank is liable to:
- [User Rights from Legal Analysis]

I request immediate action within 24 hours as per RBI's circular on unauthorized electronic transactions.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]
[Your Email Address]
Account Number: [Account Number]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]
[Police Station Address]

Subject: FIR Registration for Online Banking/UPI Fraud

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], residing at [Your Address], wish to file an FIR for online banking fraud.

**Date of Incident:** [Incident Date]
**Time of Incident:** [Transaction Time]
**Amount Fraudulently Debited:** Rs.[Amount]

**Bank Details:**
- Bank Name: [Bank Name]
- Account Number: [Account Number]
- Account Type: [Savings/Current]

**Transaction Details:**
- Transaction ID: [Transaction ID]
- Beneficiary Account: [Account Number]
- Beneficiary Name: [Name]
- Beneficiary Bank: [Bank Name]
- UPI ID: [UPI ID if applicable]

**Detailed Description of the Fraud:**
[User Problem Description]

**Evidence Available:**
- Bank Statement: [Yes/No]
- SMS Alerts: [Yes/No]
- Email Notifications: [Yes/No]
- Screenshots: [Yes/No]

**Sections of Law Applicable:**
- Indian Penal Code Section 420 (Cheating)
- IT Act 2000 Section 66C (Identity Theft)
- IT Act 2000 Section 66D (Cheating by Personation)

**Prayer:**
I request you to register an FIR and investigate the matter to recover my money and take action against the fraudsters.

Yours faithfully,
[Your Name]
[Your Address]
[Your Phone Number]
[Your Email Address]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Age: [Your Age]
Occupation: [Your Occupation]
Address: [Your Complete Address]
Phone: [Your Phone Number]
Email: [Your Email Address]

**Opposite Party:**
Name: [Bank Name]
Address: [Bank's Registered Office]
Phone: [Bank's Contact Number]

**Subject:** Complaint for deficiency in banking service and failure to prevent unauthorized transaction

**Facts of the Case:**
1. That the complainant maintains a savings/current account #[Account Number] with the opposite party.
2. That on [Incident Date], an unauthorized transaction of Rs.[Amount] occurred.
3. That despite immediate notification, the opposite party failed to take timely action.
4. That the opposite party is liable for the loss as per RBI guidelines.

**Detailed Description:**
[User Problem Description]

**Cause of Action:**
The cause of action arose on [Incident Date] and continues till date.

**Relief Claimed:**
1. Refund of the unauthorized amount of Rs.[Amount]
2. Compensation of Rs.[Amount] for mental harassment
3. Interest on the amount from date of incident
4. Litigation costs

**Total Claim:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date] that the contents are true to my knowledge.

**Complainant**
(Signature)
[Your Name]'''
        },
        'Flights & Travel Issues': {
          'email':
              '''Subject: Formal Complaint Regarding [Issue Type] - Booking Ref #[Booking Reference]

Date: [Current Date]

To,
Customer Relations Manager
[Airline/Travel Company Name]
[Company Address]

Dear Sir/Madam,

I, [Your Name], wish to file a formal complaint regarding my travel booking.

**Booking Details:**
- Booking Reference: [Booking Reference]
- Flight Number: [Flight Number]
- Travel Date: [Travel Date]
- Route: [From] to [To]
- PNR Number: [PNR Number]

**Date of Incident:** [Incident Date]

**Detailed Description of the Problem:**
[User Problem Description]

**Legal Basis:**
As per the Air Passenger Charter and DGCA Regulations:
- [User Rights from Legal Analysis]

**Relief Sought:**
I request the following within 7 working days:
1. [Specific Resolution 1]
2. [Specific Resolution 2]
3. Compensation as per applicable regulations

If not resolved, I will approach the Airports Authority of India and the Consumer Forum.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]
[Your Email Address]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]
[Police Station Address]

Subject: FIR Registration Against [Airline/Company] for Fraud and Cheating

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], residing at [Your Address], wish to file an FIR against [Airline/Company Name].

**Date of Incident:** [Incident Date]
**Place:** [Airport/Location]

**Booking Details:**
- Booking Reference: [Booking Reference]
- Amount Paid: Rs.[Amount]
- Payment Date: [Payment Date]

**Detailed Description:**
[User Problem Description]

**Evidence Available:**
- Booking Confirmations: [Yes/No]
- Payment Receipts: [Yes/No]
- Communication Records: [Yes/No]
- Boarding Passes/Tickets: [Yes/No]

**Legal Sections:**
- IPC Section 420 (Cheating)
- IPC Section 406 (Criminal Breach of Trust)

**Prayer:**
I request registration of FIR and investigation into this matter of fraud by the airline/company.

Yours faithfully,
[Your Name]
[Your Address]
[Your Phone Number]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Age: [Your Age]
Occupation: [Your Occupation]
Address: [Your Complete Address]
Phone: [Your Phone Number]
Email: [Your Email Address]

**Opposite Party:**
Name: [Airline/Travel Company]
Address: [Registered Office Address]

**Subject:** Complaint for deficiency in service and unfair trade practice in travel booking

**Facts of the Case:**
1. That the complainant booked travel services with the opposite party.
2. That booking reference [Booking Reference] was confirmed for travel on [Date].
3. That the opposite party [details of what happened - User Problem Description].
4. That this constitutes deficiency in service under the Consumer Protection Act.

**Detailed Description:**
[User Problem Description]

**Cause of Action:**
The cause of action arose on [Incident Date].

**Relief Claimed:**
1. Refund of Rs.[Amount]
2. Compensation for harassment: Rs.[Amount]
3. Litigation costs: Rs.[Amount]
4. Any other relief

**Total Claim:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date].

**Complainant**
(Signature)
[Your Name]'''
        },
        'Restaurant & Food Billing': {
          'email':
              '''Subject: Complaint Regarding Overcharging/Fake GST - Bill #[Bill Number]

Date: [Current Date]

To,
The Manager
[Restaurant Name]
[Restaurant Address]

Dear Sir/Madam,

I, [Your Name], visited your restaurant on [Incident Date] and wish to complain about billing issues.

**Visit Details:**
- Date of Visit: [Incident Date]
- Bill Number: [Bill Number]
- Table Number: [Table Number]
- Amount Charged: Rs.[Amount]

**Detailed Description of the Problem:**
[User Problem Description]

**Legal Basis:**
As per GST Act and Consumer Protection Act:
- [User Rights from Legal Analysis]

**Relief Sought:**
1. Refund of excess amount charged
2. Correction of GST billing
3. Written apology

I expect resolution within 7 days or I'll approach the GST Department and Consumer Forum.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]
[Your Email Address]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]
[Police Station Address]

Subject: FIR Against [Restaurant Name] for Overcharging and Tax Evasion

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], wish to file FIR against [Restaurant Name] for overcharging and fake GST billing.

**Date of Incident:** [Incident Date]
**Restaurant Address:** [Restaurant Address]
**Bill Amount:** Rs.[Amount]

**Detailed Description:**
[User Problem Description]

**Evidence:**
- Bill Copy: [Yes/No]
- Payment Receipt: [Yes/No]
- Photos: [Yes/No]

**Legal Sections:**
- IPC Section 420 (Cheating)
- GST Act Sections for Tax Evasion

**Prayer:**
Register FIR and investigate this case of commercial fraud.

Yours faithfully,
[Your Name]
[Your Address]
[Your Phone Number]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Address: [Your Address]

**Opposite Party:**
Name: [Restaurant Name]
Address: [Restaurant Address]

**Subject:** Complaint for overcharging and fake GST billing

**Facts:**
1. Complainant visited restaurant on [Incident Date]
2. Was overcharged Rs.[Amount] with fake GST
3. Restaurant refused to correct the bill

**Detailed Description:**
[User Problem Description]

**Relief Claimed:**
1. Refund of excess amount: Rs.[Amount]
2. Compensation: Rs.[Amount]
3. Costs: Rs.[Amount]

**Total:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date].

**Complainant**
(Signature)
[Your Name]'''
        },
        'Hospital Billing Problems': {
          'email':
              '''Subject: Complaint Regarding Excessive Billing - IP No. [IP Number]

Date: [Current Date]

To,
The Medical Director
[Hospital Name]
[Hospital Address]

Dear Sir/Madam,

I, [Your Name], wish to complain about excessive billing for treatment.

**Patient Details:**
- Patient Name: [Patient Name]
- IP Number: [IP Number]
- Admission Date: [Admission Date]
- Discharge Date: [Discharge Date]
- Total Bill: Rs.[Amount]

**Date of Incident:** [Incident Date]

**Detailed Description:**
[User Problem Description]

**Legal Basis:**
As per Clinical Establishment Act and Consumer Protection Act:
- [User Rights from Legal Analysis]

**Relief Sought:**
1. Detailed breakdown of charges
2. Removal of unauthorized charges
3. Refund of excess amount

I expect response within 7 days or will approach the Medical Council and Consumer Forum.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]

Subject: FIR Against [Hospital Name] for Medical Billing Fraud

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], wish to file FIR against [Hospital Name] for medical billing fraud.

**Incident Details:**
- Hospital: [Hospital Name]
- Patient: [Patient Name]
- IP Number: [IP Number]
- Fraud Amount: Rs.[Amount]

**Detailed Description:**
[User Problem Description]

**Evidence:**
- Medical Bills: [Yes/No]
- Discharge Summary: [Yes/No]
- Payment Records: [Yes/No]

**Legal Sections:**
- IPC Section 420 (Cheating)
- Clinical Establishment Act

**Prayer:**
Register FIR and investigate this medical fraud case.

Yours faithfully,
[Your Name]
[Your Address]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Address: [Your Address]

**Opposite Party:**
Name: [Hospital Name]
Address: [Hospital Address]

**Subject:** Complaint for excessive medical billing and deficiency in service

**Facts:**
1. Patient [Patient Name] admitted on [Date]
2. Excessive billing of Rs.[Amount]
3. Charges for services not rendered

**Detailed Description:**
[User Problem Description]

**Relief Claimed:**
1. Refund: Rs.[Amount]
2. Compensation: Rs.[Amount]
3. Legal costs: Rs.[Amount]

**Total:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date].

**Complainant**
(Signature)
[Your Name]'''
        },
        'Traffic & Vehicle Issues': {
          'email':
              '''Subject: Appeal Against Wrong Traffic Challan - Challan No. [Challan Number]

Date: [Current Date]

To,
The Traffic Commissioner
[Traffic Police Department]
[City]

Dear Sir/Madam,

I, [Your Name], wish to appeal against an incorrect traffic challan.

**Challan Details:**
- Challan Number: [Challan Number]
- Vehicle Number: [Vehicle Number]
- Date of Violation: [Date on Challan]
- Location: [Location on Challan]
- Amount: Rs.[Amount]

**Date of Incident:** [Incident Date]

**Detailed Description:**
[User Problem Description]

**Legal Basis:**
As per Motor Vehicles Act and Traffic Rules:
- [User Rights from Legal Analysis]

**Relief Sought:**
1. Cancellation of incorrect challan
2. Refund if already paid
3. Correction in records

I request review within 15 days.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]

Subject: Complaint Against Wrong Traffic Challan

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], wish to complain about an incorrect traffic challan.

**Challan Details:**
- Number: [Challan Number]
- Vehicle: [Vehicle Number]
- Amount: Rs.[Amount]

**Detailed Description:**
[User Problem Description]

**Evidence:**
- Vehicle Documents: [Yes/No]
- Location Proof: [Yes/No]
- Photos: [Yes/No]

**Legal Sections:**
- Motor Vehicles Act

**Prayer:**
Investigate and cancel the incorrect challan.

Yours faithfully,
[Your Name]
[Your Address]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Address: [Your Address]

**Opposite Party:**
Name: Traffic Police Department
Address: [Traffic Police Office Address]

**Subject:** Complaint against illegal traffic challan

**Facts:**
1. Wrong traffic challan issued
2. Vehicle [Vehicle Number] not at location
3. Challan amount: Rs.[Amount]

**Detailed Description:**
[User Problem Description]

**Relief Claimed:**
1. Cancellation of challan
2. Refund if paid: Rs.[Amount]
3. Compensation: Rs.[Amount]

**Total:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date].

**Complainant**
(Signature)
[Your Name]'''
        },
        'Telecom & Internet Services': {
          'email':
              '''Subject: Complaint Regarding Service Issues - Account #[Account Number]

Date: [Current Date]

To,
Customer Care Manager
[Telecom Company]
[Company Address]

Dear Sir/Madam,

I, [Your Name], customer account #[Account Number], wish to complain about service issues.

**Account Details:**
- Account Number: [Account Number]
- Mobile Number: [Mobile Number]
- Plan: [Current Plan]
- Issue Since: [Date]

**Date of Incident:** [Incident Date]

**Detailed Description:**
[User Problem Description]

**Legal Basis:**
As per TRAI Regulations and Consumer Protection Act:
- [User Rights from Legal Analysis]

**Relief Sought:**
1. Immediate resolution of service issue
2. Refund for downtime: Rs.[Amount]
3. Compensation for inconvenience

I expect resolution within 3 days or will approach TRAI and Consumer Forum.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]

Subject: FIR Against [Telecom Company] for Service Fraud

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], wish to file FIR against [Telecom Company].

**Account Details:**
- Account Number: [Account Number]
- Mobile Number: [Mobile Number]
- Fraud Amount: Rs.[Amount]

**Detailed Description:**
[User Problem Description]

**Evidence:**
- Bills: [Yes/No]
- Complaint Records: [Yes/No]
- Payment Proofs: [Yes/No]

**Legal Sections:**
- IPC Section 420 (Cheating)
- TRAI Act

**Prayer:**
Register FIR and investigate this telecom fraud.

Yours faithfully,
[Your Name]
[Your Address]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Address: [Your Address]

**Opposite Party:**
Name: [Telecom Company]
Address: [Company Address]

**Subject:** Complaint for deficiency in telecom service

**Facts:**
1. Customer since [Date]
2. Service issues since [Date]
3. Financial loss: Rs.[Amount]

**Detailed Description:**
[User Problem Description]

**Relief Claimed:**
1. Refund: Rs.[Amount]
2. Compensation: Rs.[Amount]
3. Legal costs: Rs.[Amount]

**Total:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date].

**Complainant**
(Signature)
[Your Name]'''
        },
        'Education & Coaching Complaints': {
          'email':
              '''Subject: Complaint Regarding [Issue Type] - Enrollment #[Enrollment Number]

Date: [Current Date]

To,
The Director
[Institution Name]
[Institution Address]

Dear Sir/Madam,

I, [Your Name], student/enrollee #[Enrollment Number], wish to complain about institutional issues.

**Enrollment Details:**
- Enrollment Number: [Enrollment Number]
- Course: [Course Name]
- Batch: [Batch Details]
- Fees Paid: Rs.[Amount]

**Date of Incident:** [Incident Date]

**Detailed Description:**
[User Problem Description]

**Legal Basis:**
As per Education Regulations and Consumer Protection Act:
- [User Rights from Legal Analysis]

**Relief Sought:**
1. [Specific Resolution 1]
2. [Specific Resolution 2]
3. Refund if applicable

I expect resolution within 7 days or will approach the Education Department and Consumer Forum.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]

Subject: FIR Against [Institution Name] for Educational Fraud

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], wish to file FIR against [Institution Name].

**Institution Details:**
- Name: [Institution Name]
- Address: [Institution Address]
- Course: [Course Name]
- Fees Paid: Rs.[Amount]

**Detailed Description:**
[User Problem Description]

**Evidence:**
- Enrollment Proof: [Yes/No]
- Fee Receipts: [Yes/No]
- Course Materials: [Yes/No]

**Legal Sections:**
- IPC Section 420 (Cheating)
- Education Act

**Prayer:**
Register FIR and investigate this educational fraud.

Yours faithfully,
[Your Name]
[Your Address]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Address: [Your Address]

**Opposite Party:**
Name: [Institution Name]
Address: [Institution Address]

**Subject:** Complaint for deficiency in educational service

**Facts:**
1. Enrolled in course on [Date]
2. Fees paid: Rs.[Amount]
3. [Details of issue]

**Detailed Description:**
[User Problem Description]

**Relief Claimed:**
1. Refund: Rs.[Amount]
2. Compensation: Rs.[Amount]
3. Legal costs: Rs.[Amount]

**Total:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date].

**Complainant**
(Signature)
[Your Name]'''
        },
        'Rental & Housing Issues': {
          'email':
              '''Subject: Complaint Regarding [Issue Type] - Property at [Property Address]

Date: [Current Date]

To,
[Landlord/Property Manager Name]
[Property Address]

Dear Sir/Madam,

I, [Your Name], tenant of property at [Property Address], wish to complain about housing issues.

**Property Details:**
- Property Address: [Property Address]
- Rent Amount: Rs.[Amount]
- Lease Period: [Start Date] to [End Date]
- Security Deposit: Rs.[Amount]

**Date of Incident:** [Incident Date]

**Detailed Description:**
[User Problem Description]

**Legal Basis:**
As per Rent Control Act and Consumer Protection Act:
- [User Rights from Legal Analysis]

**Relief Sought:**
1. [Specific Resolution 1]
2. [Specific Resolution 2]
3. Return of security deposit if applicable

I expect resolution within 7 days or will approach the Rent Authority and Consumer Forum.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]

Subject: FIR Against [Landlord Name] for Housing Violations

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], wish to file FIR against [Landlord Name].

**Property Details:**
- Address: [Property Address]
- Landlord Name: [Landlord Name]
- Issue: [Type of Issue]

**Detailed Description:**
[User Problem Description]

**Evidence:**
- Rent Agreement: [Yes/No]
- Payment Records: [Yes/No]
- Photos/Videos: [Yes/No]

**Legal Sections:**
- Rent Control Act
- IPC relevant sections

**Prayer:**
Register FIR and investigate housing violations.

Yours faithfully,
[Your Name]
[Your Address]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Address: [Your Address]

**Opposite Party:**
Name: [Landlord/Property Owner]
Address: [Property Address]

**Subject:** Complaint regarding rental housing issues

**Facts:**
1. Tenant since [Date]
2. Property at [Address]
3. [Details of issue]

**Detailed Description:**
[User Problem Description]

**Relief Claimed:**
1. [Specific Relief 1]: Rs.[Amount]
2. [Specific Relief 2]: Rs.[Amount]
3. Legal costs: Rs.[Amount]

**Total:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date].

**Complainant**
(Signature)
[Your Name]'''
        },
        'Government Service Problems': {
          'email':
              '''Subject: Complaint Regarding [Service Type] - Application #[Application Number]

Date: [Current Date]

To,
The Head of Department
[Department Name]
[Department Address]

Dear Sir/Madam,

I, [Your Name], applicant #[Application Number], wish to complain about service delays.

**Application Details:**
- Application Number: [Application Number]
- Service Applied: [Service Name]
- Date of Application: [Application Date]
- Expected Timeline: [Timeline]
- Current Status: [Status]

**Date of Incident:** [Incident Date]

**Detailed Description:**
[User Problem Description]

**Legal Basis:**
As per Citizens' Charter and Right to Service Act:
- [User Rights from Legal Analysis]

**Relief Sought:**
1. Immediate processing of application
2. Action against responsible officials
3. Compensation for delay if applicable

I expect resolution within 7 days or will approach the higher authorities and Consumer Forum.

Sincerely,
[Your Name]
[Your Address]
[Your Phone Number]''',
          'police': '''To,
The Officer-in-Charge
[Police Station Name]

Subject: FIR Against [Department/Official] for Negligence

Date: [Current Date]

Respected Sir/Madam,

I, [Your Name], wish to file FIR against [Department/Official].

**Service Details:**
- Department: [Department Name]
- Service: [Service Name]
- Application Number: [Application Number]
- Applied On: [Date]

**Detailed Description:**
[User Problem Description]

**Evidence:**
- Application Form: [Yes/No]
- Acknowledgment: [Yes/No]
- Fee Receipt: [Yes/No]

**Legal Sections:**
- Prevention of Corruption Act
- Relevant Service Laws

**Prayer:**
Register FIR and investigate official negligence.

Yours faithfully,
[Your Name]
[Your Address]''',
          'consumer_court': '''IN THE CONSUMER DISPUTES REDRESSAL COMMISSION
[District/State Name]

Consumer Complaint No.: [To be filled by Court]

COMPLAINT UNDER SECTION 35 OF THE CONSUMER PROTECTION ACT 2019

**Complainant:**
Name: [Your Name]
Address: [Your Address]

**Opposite Party:**
Name: [Department Name]
Address: [Department Address]

**Subject:** Complaint for deficiency in government service

**Facts:**
1. Applied for [Service] on [Date]
2. Application Number: [Application Number]
3. [Details of issue]

**Detailed Description:**
[User Problem Description]

**Relief Claimed:**
1. Service delivery: [Specific]
2. Compensation: Rs.[Amount]
3. Legal costs: Rs.[Amount]

**Total:** Rs.[Total Amount]

**Verification:**
Verified at [City] on [Date].

**Complainant**
(Signature)
[Your Name]'''
        }
      };

  static String getTemplate(String category, String type) {
    return templates[category]?[type] ??
        templates['E-commerce & Shopping']![type]!;
  }
}

class FormTemplates {
  static const List<FormTemplateModel> all = [
    // -- 1. Consumer Complaint -----------------------------------------------
    FormTemplateModel(
      id: 'consumer_complaint',
      title: 'Consumer Complaint',
      subtitle:
          'File a complaint against defective goods or deficient services',
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
        FormFieldModel(
            key: 'complainant_name',
            label: 'Complainant Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Your full legal name'),
        FormFieldModel(
            key: 'complainant_address',
            label: 'Complainant Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address with pin code',
            maxLines: 3),
        FormFieldModel(
            key: 'complainant_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            required: true,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'complainant_email',
            label: 'Email Address',
            type: FormFieldType.email,
            hint: 'your@email.com'),
        FormFieldModel(
            key: 'opposite_party_name',
            label: 'Opposite Party (Company/Person)',
            type: FormFieldType.text,
            required: true,
            hint: 'Full name of company or person'),
        FormFieldModel(
            key: 'opposite_party_address',
            label: 'Opposite Party Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Registered address of company',
            maxLines: 3),
        FormFieldModel(
            key: 'complaint_category',
            label: 'Nature of Complaint',
            type: FormFieldType.dropdown,
            required: true,
            options: [
              'Defective Goods',
              'Deficient Services',
              'Unfair Trade Practice',
              'Overcharging',
              'Misleading Advertisement',
              'Other'
            ]),
        FormFieldModel(
            key: 'purchase_date',
            label: 'Date of Purchase / Service',
            type: FormFieldType.date,
            required: true,
            hint: 'DD/MM/YYYY'),
        FormFieldModel(
            key: 'amount',
            label: 'Amount Paid (Rs.)',
            type: FormFieldType.number,
            required: true,
            hint: 'e.g. 5000',
            prefix: 'Rs.'),
        FormFieldModel(
            key: 'complaint_details',
            label: 'Details of Complaint',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Describe the issue in detail - what happened, when, and how',
            maxLines: 6),
        FormFieldModel(
            key: 'relief_sought',
            label: 'Relief / Compensation Sought',
            type: FormFieldType.textarea,
            required: true,
            hint: 'What do you want - refund, replacement, compensation?',
            maxLines: 3),
        FormFieldModel(
            key: 'previous_complaints',
            label: 'Previous Complaints to Company',
            type: FormFieldType.textarea,
            hint: 'Mention any emails, calls, or complaints already made',
            maxLines: 3),
      ],
    ),

    // -- 2. RTI Application --------------------------------------------------
    FormTemplateModel(
      id: 'rti_application',
      title: 'RTI Application',
      subtitle: 'Request information from any government department',
      authority: 'Public Information Officer (PIO) of concerned department',
      actReference: 'Right to Information Act, 2005',
      instructions:
          'Submit to the PIO of the concerned department with Rs.10 application fee (IPO/DD/cash). BPL applicants are exempt from fee.',
      documents: [
        'Application fee of Rs.10 (IPO / Demand Draft / Court Fee Stamp)',
        'BPL certificate (if claiming fee exemption)',
        'Identity proof (optional but recommended)',
      ],
      fields: [
        FormFieldModel(
            key: 'applicant_name',
            label: 'Applicant Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Your full legal name'),
        FormFieldModel(
            key: 'applicant_address',
            label: 'Applicant Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full postal address',
            maxLines: 3),
        FormFieldModel(
            key: 'applicant_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'applicant_email',
            label: 'Email Address',
            type: FormFieldType.email,
            hint: 'your@email.com'),
        FormFieldModel(
            key: 'department_name',
            label: 'Department / Ministry Name',
            type: FormFieldType.text,
            required: true,
            hint: 'e.g. Municipal Corporation, Income Tax Department'),
        FormFieldModel(
            key: 'pio_address',
            label: 'PIO Office Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Address of Public Information Officer',
            maxLines: 3),
        FormFieldModel(
            key: 'information_sought',
            label: 'Information Sought',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Clearly state what information you need. Be specific.',
            maxLines: 6),
        FormFieldModel(
            key: 'time_period',
            label: 'Time Period of Information',
            type: FormFieldType.text,
            hint: 'e.g. From April 2022 to March 2023'),
        FormFieldModel(
            key: 'format_required',
            label: 'Format Required',
            type: FormFieldType.dropdown,
            options: [
              'Certified Copies',
              'Inspection of Records',
              'Soft Copy / CD',
              'Any Format'
            ]),
        FormFieldModel(
            key: 'is_bpl',
            label: 'Are you BPL (Below Poverty Line)?',
            type: FormFieldType.dropdown,
            options: ['No', 'Yes']),
        FormFieldModel(
            key: 'fee_details',
            label: 'Fee Payment Details',
            type: FormFieldType.text,
            hint: 'e.g. IPO No. 123456 / Cash Rs.10'),
      ],
    ),

    // -- 3. Cyber Crime Complaint --------------------------------------------
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
        FormFieldModel(
            key: 'complainant_name',
            label: 'Complainant Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Your full legal name'),
        FormFieldModel(
            key: 'complainant_address',
            label: 'Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address with pin code',
            maxLines: 3),
        FormFieldModel(
            key: 'complainant_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            required: true,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'complainant_email',
            label: 'Email Address',
            type: FormFieldType.email,
            required: true,
            hint: 'your@email.com'),
        FormFieldModel(
            key: 'crime_type',
            label: 'Type of Cyber Crime',
            type: FormFieldType.dropdown,
            required: true,
            options: [
              'Online Financial Fraud',
              'Online Job Fraud',
              'Social Media Fraud',
              'Hacking / Unauthorized Access',
              'Cyber Stalking / Harassment',
              'Identity Theft',
              'Phishing',
              'Ransomware',
              'Child Pornography',
              'Other'
            ]),
        FormFieldModel(
            key: 'incident_date',
            label: 'Date of Incident',
            type: FormFieldType.date,
            required: true,
            hint: 'DD/MM/YYYY'),
        FormFieldModel(
            key: 'incident_description',
            label: 'Incident Description',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Describe exactly what happened step by step',
            maxLines: 6),
        FormFieldModel(
            key: 'accused_details',
            label: 'Accused / Suspect Details',
            type: FormFieldType.textarea,
            hint:
                'Phone number, email, website, social media profile of accused',
            maxLines: 3),
        FormFieldModel(
            key: 'amount_lost',
            label: 'Amount Lost (Rs.)',
            type: FormFieldType.number,
            hint: 'If financial fraud, enter amount',
            prefix: 'Rs.'),
        FormFieldModel(
            key: 'transaction_id',
            label: 'Transaction ID / UTR',
            type: FormFieldType.text,
            hint: 'Bank transaction reference number'),
        FormFieldModel(
            key: 'bank_details',
            label: 'Your Bank & Account Details',
            type: FormFieldType.textarea,
            hint: 'Bank name, account number (last 4 digits only)',
            maxLines: 2),
        FormFieldModel(
            key: 'evidence_list',
            label: 'Evidence Available',
            type: FormFieldType.textarea,
            hint: 'List all evidence you have - screenshots, emails, etc.',
            maxLines: 3),
      ],
    ),

    // -- 4. Banking Ombudsman ------------------------------------------------
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
        FormFieldModel(
            key: 'complainant_name',
            label: 'Complainant Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Account holder name'),
        FormFieldModel(
            key: 'complainant_address',
            label: 'Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address with pin code',
            maxLines: 3),
        FormFieldModel(
            key: 'complainant_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            required: true,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'complainant_email',
            label: 'Email Address',
            type: FormFieldType.email,
            hint: 'your@email.com'),
        FormFieldModel(
            key: 'bank_name',
            label: 'Bank Name',
            type: FormFieldType.text,
            required: true,
            hint: 'e.g. State Bank of India'),
        FormFieldModel(
            key: 'branch_name',
            label: 'Branch Name & Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Branch where account is held',
            maxLines: 2),
        FormFieldModel(
            key: 'account_number',
            label: 'Account Number',
            type: FormFieldType.text,
            required: true,
            hint: 'Your bank account number'),
        FormFieldModel(
            key: 'complaint_type',
            label: 'Nature of Complaint',
            type: FormFieldType.dropdown,
            required: true,
            options: [
              'Non-credit of amount',
              'Unauthorized debit',
              'ATM / Debit Card issue',
              'Credit Card issue',
              'Loan related',
              'Internet Banking fraud',
              'UPI / Mobile Banking',
              'Cheque related',
              'Account closure issue',
              'Other'
            ]),
        FormFieldModel(
            key: 'complaint_date_to_bank',
            label: 'Date of Complaint to Bank',
            type: FormFieldType.date,
            required: true,
            hint: 'When did you first complain to bank?'),
        FormFieldModel(
            key: 'amount_involved',
            label: 'Amount Involved (Rs.)',
            type: FormFieldType.number,
            hint: 'Amount in dispute',
            prefix: 'Rs.'),
        FormFieldModel(
            key: 'complaint_details',
            label: 'Complaint Details',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Describe the issue and what the bank did or did not do',
            maxLines: 6),
        FormFieldModel(
            key: 'relief_sought',
            label: 'Relief Sought',
            type: FormFieldType.textarea,
            required: true,
            hint: 'What resolution do you want from the bank?',
            maxLines: 3),
      ],
    ),

    // -- 5. Motor Accident Claim ---------------------------------------------
    FormTemplateModel(
      id: 'motor_accident_claim',
      title: 'Motor Accident Claim (MACT)',
      subtitle: 'Claim compensation for motor accident injury or death',
      authority: 'Motor Accident Claims Tribunal (MACT)',
      actReference: 'Motor Vehicles Act, 1988 - Section 166',
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
        FormFieldModel(
            key: 'claimant_name',
            label: 'Claimant Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Injured person or legal heir'),
        FormFieldModel(
            key: 'claimant_address',
            label: 'Claimant Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address with pin code',
            maxLines: 3),
        FormFieldModel(
            key: 'claimant_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            required: true,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'claimant_relation',
            label: 'Relation to Victim',
            type: FormFieldType.dropdown,
            options: [
              'Self (Injured)',
              'Spouse',
              'Parent',
              'Child',
              'Legal Heir',
              'Other'
            ]),
        FormFieldModel(
            key: 'accident_date',
            label: 'Date of Accident',
            type: FormFieldType.date,
            required: true,
            hint: 'DD/MM/YYYY'),
        FormFieldModel(
            key: 'accident_place',
            label: 'Place of Accident',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full location of accident',
            maxLines: 2),
        FormFieldModel(
            key: 'accident_description',
            label: 'How Accident Occurred',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Describe how the accident happened',
            maxLines: 5),
        FormFieldModel(
            key: 'vehicle_number',
            label: 'Offending Vehicle Number',
            type: FormFieldType.text,
            required: true,
            hint: 'Registration number of vehicle at fault'),
        FormFieldModel(
            key: 'driver_name',
            label: 'Driver / Accused Name',
            type: FormFieldType.text,
            hint: 'Name of driver at fault'),
        FormFieldModel(
            key: 'insurance_company',
            label: 'Insurance Company of Vehicle',
            type: FormFieldType.text,
            hint: 'Insurance company name'),
        FormFieldModel(
            key: 'fir_number',
            label: 'FIR Number',
            type: FormFieldType.text,
            hint: 'Police FIR number if registered'),
        FormFieldModel(
            key: 'injuries',
            label: 'Nature of Injuries',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Describe injuries sustained',
            maxLines: 3),
        FormFieldModel(
            key: 'medical_expenses',
            label: 'Medical Expenses Incurred (Rs.)',
            type: FormFieldType.number,
            hint: 'Total medical bills',
            prefix: 'Rs.'),
        FormFieldModel(
            key: 'compensation_sought',
            label: 'Total Compensation Sought (Rs.)',
            type: FormFieldType.number,
            required: true,
            hint: 'Total amount claimed',
            prefix: 'Rs.'),
      ],
    ),

    // -- 6. Labour Complaint -------------------------------------------------
    FormTemplateModel(
      id: 'labour_complaint',
      title: 'Labour / Workmen Complaint',
      subtitle:
          'Complaint for unpaid wages, wrongful termination or labour rights',
      authority: 'Labour Commissioner Office',
      actReference:
          'Industrial Disputes Act, 1947 & Payment of Wages Act, 1936',
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
        FormFieldModel(
            key: 'worker_name',
            label: 'Worker / Employee Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Your full legal name'),
        FormFieldModel(
            key: 'worker_address',
            label: 'Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address with pin code',
            maxLines: 3),
        FormFieldModel(
            key: 'worker_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            required: true,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'worker_designation',
            label: 'Designation / Role',
            type: FormFieldType.text,
            required: true,
            hint: 'Your job title'),
        FormFieldModel(
            key: 'employer_name',
            label: 'Employer / Company Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Full name of employer or company'),
        FormFieldModel(
            key: 'employer_address',
            label: 'Employer Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Company / factory address',
            maxLines: 3),
        FormFieldModel(
            key: 'employment_period',
            label: 'Employment Period',
            type: FormFieldType.text,
            required: true,
            hint: 'e.g. From Jan 2022 to Dec 2023'),
        FormFieldModel(
            key: 'monthly_wages',
            label: 'Monthly Wages (Rs.)',
            type: FormFieldType.number,
            required: true,
            hint: 'Your monthly salary',
            prefix: 'Rs.'),
        FormFieldModel(
            key: 'complaint_type',
            label: 'Nature of Complaint',
            type: FormFieldType.dropdown,
            required: true,
            options: [
              'Unpaid Wages / Salary',
              'Wrongful Termination',
              'Illegal Deduction',
              'Non-payment of Gratuity',
              'Non-payment of PF/ESI',
              'Forced Resignation',
              'Sexual Harassment',
              'Other'
            ]),
        FormFieldModel(
            key: 'dues_amount',
            label: 'Amount of Dues (Rs.)',
            type: FormFieldType.number,
            hint: 'Total unpaid amount',
            prefix: 'Rs.'),
        FormFieldModel(
            key: 'complaint_details',
            label: 'Complaint Details',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Describe what happened in detail',
            maxLines: 6),
        FormFieldModel(
            key: 'relief_sought',
            label: 'Relief Sought',
            type: FormFieldType.textarea,
            required: true,
            hint: 'What do you want - wages, reinstatement, compensation?',
            maxLines: 3),
      ],
    ),

    // -- 7. Lok Adalat Application -------------------------------------------
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
        FormFieldModel(
            key: 'applicant_name',
            label: 'Applicant Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Your full legal name'),
        FormFieldModel(
            key: 'applicant_address',
            label: 'Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address with pin code',
            maxLines: 3),
        FormFieldModel(
            key: 'applicant_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            required: true,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'opposite_party',
            label: 'Opposite Party Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Name of other party in dispute'),
        FormFieldModel(
            key: 'opposite_party_address',
            label: 'Opposite Party Address',
            type: FormFieldType.textarea,
            hint: 'Address of opposite party',
            maxLines: 3),
        FormFieldModel(
            key: 'dispute_type',
            label: 'Nature of Dispute',
            type: FormFieldType.dropdown,
            required: true,
            options: [
              'Motor Accident',
              'Labour Dispute',
              'Matrimonial (Non-divorce)',
              'Land / Property',
              'Cheque Bounce',
              'Compoundable Criminal',
              'Electricity Dispute',
              'Consumer Dispute',
              'Other'
            ]),
        FormFieldModel(
            key: 'case_number',
            label: 'Case / Complaint Number (if pending)',
            type: FormFieldType.text,
            hint: 'Court case or complaint reference'),
        FormFieldModel(
            key: 'court_name',
            label: 'Court / Forum Name',
            type: FormFieldType.text,
            hint: 'Where case is currently pending'),
        FormFieldModel(
            key: 'dispute_details',
            label: 'Dispute Details',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Briefly describe the dispute',
            maxLines: 5),
        FormFieldModel(
            key: 'settlement_sought',
            label: 'Settlement Expected',
            type: FormFieldType.textarea,
            required: true,
            hint: 'What settlement are you looking for?',
            maxLines: 3),
      ],
    ),

    // -- 8. Legal Aid Application --------------------------------------------
    FormTemplateModel(
      id: 'legal_aid',
      title: 'Legal Aid Application',
      subtitle: 'Apply for free legal assistance from NALSA / DLSA',
      authority: 'NALSA / State Legal Services Authority / DLSA',
      actReference: 'Legal Services Authorities Act, 1987',
      instructions:
          'Submit at your District Legal Services Authority (DLSA) office. Legal aid is free for eligible persons.',
      documents: [
        'Income certificate (annual income below Rs.1 lakh)',
        'Identity proof (Aadhaar / Voter ID)',
        'Documents related to legal matter',
        'SC/ST/OBC certificate (if applicable)',
        'Disability certificate (if applicable)',
      ],
      fields: [
        FormFieldModel(
            key: 'applicant_name',
            label: 'Applicant Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Your full legal name'),
        FormFieldModel(
            key: 'applicant_address',
            label: 'Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address with pin code',
            maxLines: 3),
        FormFieldModel(
            key: 'applicant_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            required: true,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'applicant_age',
            label: 'Age',
            type: FormFieldType.number,
            required: true,
            hint: 'Your age in years'),
        FormFieldModel(
            key: 'applicant_gender',
            label: 'Gender',
            type: FormFieldType.dropdown,
            required: true,
            options: ['Male', 'Female', 'Transgender']),
        FormFieldModel(
            key: 'category',
            label: 'Eligibility Category',
            type: FormFieldType.dropdown,
            required: true,
            options: [
              'SC / ST',
              'Women / Child',
              'Disabled Person',
              'Industrial Workman',
              'Victim of Disaster',
              'Person in Custody',
              'Annual Income below Rs.1 Lakh',
              'Other'
            ]),
        FormFieldModel(
            key: 'annual_income',
            label: 'Annual Income (Rs.)',
            type: FormFieldType.number,
            required: true,
            hint: 'Your total annual income',
            prefix: 'Rs.'),
        FormFieldModel(
            key: 'legal_matter_type',
            label: 'Type of Legal Matter',
            type: FormFieldType.dropdown,
            required: true,
            options: [
              'Criminal Case',
              'Civil Case',
              'Family Matter',
              'Labour Dispute',
              'Land / Property',
              'Consumer Complaint',
              'Other'
            ]),
        FormFieldModel(
            key: 'legal_matter_details',
            label: 'Details of Legal Matter',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Briefly describe your legal problem',
            maxLines: 5),
        FormFieldModel(
            key: 'court_name',
            label: 'Court / Forum (if case filed)',
            type: FormFieldType.text,
            hint: 'Name of court if case already filed'),
        FormFieldModel(
            key: 'case_number',
            label: 'Case Number (if any)',
            type: FormFieldType.text,
            hint: 'Leave blank if not yet filed'),
      ],
    ),

    // -- 9. Rent Control Application -----------------------------------------
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
        FormFieldModel(
            key: 'applicant_name',
            label: 'Applicant Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Landlord or tenant name'),
        FormFieldModel(
            key: 'applicant_role',
            label: 'Applicant Is',
            type: FormFieldType.dropdown,
            required: true,
            options: ['Landlord', 'Tenant']),
        FormFieldModel(
            key: 'applicant_address',
            label: 'Applicant Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address',
            maxLines: 3),
        FormFieldModel(
            key: 'applicant_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            required: true,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'opposite_party_name',
            label: 'Opposite Party Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Tenant or landlord name'),
        FormFieldModel(
            key: 'opposite_party_address',
            label: 'Opposite Party Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address',
            maxLines: 3),
        FormFieldModel(
            key: 'property_address',
            label: 'Rented Property Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address of rented property',
            maxLines: 3),
        FormFieldModel(
            key: 'monthly_rent',
            label: 'Monthly Rent (Rs.)',
            type: FormFieldType.number,
            required: true,
            hint: 'Current monthly rent',
            prefix: 'Rs.'),
        FormFieldModel(
            key: 'tenancy_start',
            label: 'Tenancy Start Date',
            type: FormFieldType.date,
            required: true,
            hint: 'DD/MM/YYYY'),
        FormFieldModel(
            key: 'application_type',
            label: 'Nature of Application',
            type: FormFieldType.dropdown,
            required: true,
            options: [
              'Eviction of Tenant',
              'Fixation of Fair Rent',
              'Recovery of Possession',
              'Arrears of Rent',
              'Deposit Refund',
              'Illegal Enhancement of Rent',
              'Other'
            ]),
        FormFieldModel(
            key: 'dispute_details',
            label: 'Details of Dispute',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Describe the tenancy dispute in detail',
            maxLines: 6),
        FormFieldModel(
            key: 'relief_sought',
            label: 'Relief Sought',
            type: FormFieldType.textarea,
            required: true,
            hint: 'What order are you seeking from Rent Controller?',
            maxLines: 3),
      ],
    ),

    // -- 10. Cheque Bounce Complaint -----------------------------------------
    FormTemplateModel(
      id: 'cheque_bounce',
      title: 'Cheque Bounce Complaint',
      subtitle: 'Complaint for dishonoured cheque under NI Act Section 138',
      authority: 'Judicial Magistrate Court (First Class)',
      actReference: 'Negotiable Instruments Act, 1881 - Section 138',
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
        FormFieldModel(
            key: 'complainant_name',
            label: 'Complainant Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Person who received the cheque'),
        FormFieldModel(
            key: 'complainant_address',
            label: 'Complainant Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address with pin code',
            maxLines: 3),
        FormFieldModel(
            key: 'complainant_phone',
            label: 'Phone Number',
            type: FormFieldType.phone,
            required: true,
            hint: '10-digit mobile number'),
        FormFieldModel(
            key: 'accused_name',
            label: 'Accused Full Name',
            type: FormFieldType.text,
            required: true,
            hint: 'Person who issued the cheque'),
        FormFieldModel(
            key: 'accused_address',
            label: 'Accused Address',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Full address of accused',
            maxLines: 3),
        FormFieldModel(
            key: 'cheque_number',
            label: 'Cheque Number',
            type: FormFieldType.text,
            required: true,
            hint: '6-digit cheque number'),
        FormFieldModel(
            key: 'cheque_amount',
            label: 'Cheque Amount (Rs.)',
            type: FormFieldType.number,
            required: true,
            hint: 'Amount on cheque',
            prefix: 'Rs.'),
        FormFieldModel(
            key: 'cheque_date',
            label: 'Cheque Date',
            type: FormFieldType.date,
            required: true,
            hint: 'Date written on cheque'),
        FormFieldModel(
            key: 'bank_name',
            label: 'Drawee Bank Name & Branch',
            type: FormFieldType.text,
            required: true,
            hint: 'Bank and branch of accused'),
        FormFieldModel(
            key: 'bounce_date',
            label: 'Date of Cheque Bounce',
            type: FormFieldType.date,
            required: true,
            hint: 'Date bank returned the cheque'),
        FormFieldModel(
            key: 'bounce_reason',
            label: 'Reason for Bounce',
            type: FormFieldType.dropdown,
            required: true,
            options: [
              'Insufficient Funds',
              'Account Closed',
              'Signature Mismatch',
              'Payment Stopped',
              'Other'
            ]),
        FormFieldModel(
            key: 'legal_notice_date',
            label: 'Date Legal Notice Sent',
            type: FormFieldType.date,
            required: true,
            hint: 'Date you sent notice to accused'),
        FormFieldModel(
            key: 'debt_details',
            label: 'Nature of Debt / Transaction',
            type: FormFieldType.textarea,
            required: true,
            hint: 'Why was the cheque given - loan, goods, services?',
            maxLines: 4),
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

const List<DocumentCategory> documentCategories = [
  DocumentCategory(
    label: 'Complaints & Notices',
    icon: Icons.campaign_outlined,
    types: [
      DocumentType(
        id: 'legal_notice',
        label: 'Legal Notice',
        description: 'Formal legal notice to opposite party before litigation',
        promptHint: 'Describe the dispute, amount involved, and relief sought',
        requiredFields: [
          'Sender',
          'Recipient',
          'Dispute Details',
          'Relief Sought'
        ],
      ),
      DocumentType(
        id: 'consumer_complaint',
        label: 'Consumer Complaint',
        description: 'Complaint to consumer forum or company',
        promptHint: 'Describe the product/service issue and what you want',
        requiredFields: ['Company Name', 'Product/Service', 'Issue', 'Relief'],
      ),
      DocumentType(
        id: 'police_complaint',
        label: 'Police Complaint',
        description: 'FIR or complaint letter to police',
        promptHint:
            'Describe the incident with date, place, and persons involved',
        requiredFields: [
          'Incident Date',
          'Incident Place',
          'Accused Details',
          'Description'
        ],
      ),
      DocumentType(
        id: 'cease_desist',
        label: 'Cease & Desist',
        description: 'Demand someone stop a specific activity',
        promptHint: 'Describe the activity you want stopped and why',
        requiredFields: ['Recipient', 'Activity to Stop', 'Legal Basis'],
      ),
      DocumentType(
        id: 'demand_letter',
        label: 'Demand Letter',
        description: 'Formal demand for payment or action',
        promptHint: 'Describe what you are demanding and the basis',
        requiredFields: ['Recipient', 'Demand', 'Amount (if any)', 'Deadline'],
      ),
    ],
  ),
  DocumentCategory(
    label: 'Agreements & Contracts',
    icon: Icons.handshake_outlined,
    types: [
      DocumentType(
        id: 'rent_agreement',
        label: 'Rent Agreement',
        description: 'Residential or commercial rental agreement',
        promptHint: 'Property details, rent amount, duration, terms',
        requiredFields: [
          'Landlord',
          'Tenant',
          'Property Address',
          'Rent',
          'Duration'
        ],
      ),
      DocumentType(
        id: 'service_agreement',
        label: 'Service Agreement',
        description: 'Contract between service provider and client',
        promptHint: 'Services to be provided, payment, timelines',
        requiredFields: ['Provider', 'Client', 'Services', 'Payment Terms'],
      ),
      DocumentType(
        id: 'nda',
        label: 'NDA / Confidentiality',
        description: 'Non-disclosure agreement between parties',
        promptHint: 'What information is confidential and duration of NDA',
        requiredFields: [
          'Party 1',
          'Party 2',
          'Confidential Information',
          'Duration'
        ],
      ),
      DocumentType(
        id: 'employment_contract',
        label: 'Employment Contract',
        description: 'Agreement between employer and employee',
        promptHint: 'Role, salary, benefits, notice period, terms',
        requiredFields: [
          'Employer',
          'Employee',
          'Role',
          'Salary',
          'Start Date'
        ],
      ),
      DocumentType(
        id: 'freelance_contract',
        label: 'Freelance Contract',
        description: 'Contract for freelance or consulting work',
        promptHint: 'Project scope, deliverables, payment, IP ownership',
        requiredFields: ['Client', 'Freelancer', 'Project Scope', 'Payment'],
      ),
      DocumentType(
        id: 'sale_agreement',
        label: 'Sale Agreement',
        description: 'Agreement for sale of goods or property',
        promptHint: 'What is being sold, price, payment terms, delivery',
        requiredFields: ['Seller', 'Buyer', 'Item/Property', 'Price', 'Terms'],
      ),
      DocumentType(
        id: 'partnership_deed',
        label: 'Partnership Deed',
        description: 'Deed for business partnership',
        promptHint: 'Partners, capital contribution, profit sharing, roles',
        requiredFields: ['Partners', 'Business', 'Capital', 'Profit Sharing'],
      ),
      DocumentType(
        id: 'mou',
        label: 'MOU / Term Sheet',
        description: 'Memorandum of understanding between parties',
        promptHint: 'Purpose, key terms, obligations of each party',
        requiredFields: ['Party 1', 'Party 2', 'Purpose', 'Key Terms'],
      ),
    ],
  ),
  DocumentCategory(
    label: 'Affidavits & Declarations',
    icon: Icons.verified_outlined,
    types: [
      DocumentType(
        id: 'general_affidavit',
        label: 'General Affidavit',
        description: 'Sworn statement of facts',
        promptHint: 'Facts to be declared and purpose of affidavit',
        requiredFields: ['Deponent Name', 'Facts to Declare', 'Purpose'],
      ),
      DocumentType(
        id: 'address_proof_affidavit',
        label: 'Address Proof Affidavit',
        description: 'Affidavit declaring residential address',
        promptHint: 'Current address and reason for affidavit',
        requiredFields: ['Name', 'Address', 'Reason'],
      ),
      DocumentType(
        id: 'name_change_affidavit',
        label: 'Name Change Affidavit',
        description: 'Affidavit for legal name change',
        promptHint: 'Old name, new name, and reason for change',
        requiredFields: ['Old Name', 'New Name', 'Reason'],
      ),
      DocumentType(
        id: 'income_affidavit',
        label: 'Income Affidavit',
        description: 'Declaration of income and financial status',
        promptHint: 'Income details, sources, and purpose',
        requiredFields: ['Name', 'Income Details', 'Purpose'],
      ),
    ],
  ),
  DocumentCategory(
    label: 'Court & Legal Filings',
    icon: Icons.account_balance_outlined,
    types: [
      DocumentType(
        id: 'consumer_court_complaint',
        label: 'Consumer Court Complaint',
        description: 'Formal complaint for consumer forum filing',
        promptHint: 'Full details of dispute, evidence, and relief sought',
        requiredFields: ['Complainant', 'Opposite Party', 'Dispute', 'Relief'],
      ),
      DocumentType(
        id: 'vakalatnama',
        label: 'Vakalatnama',
        description: 'Authorization letter to appoint an advocate',
        promptHint: 'Case details and advocate information',
        requiredFields: [
          'Client Name',
          'Advocate Name',
          'Court',
          'Case Details'
        ],
      ),
      DocumentType(
        id: 'bail_application',
        label: 'Bail Application',
        description: 'Application for bail in criminal matter',
        promptHint: 'Accused details, charges, and grounds for bail',
        requiredFields: ['Accused', 'Charges', 'Grounds for Bail', 'Court'],
      ),
      DocumentType(
        id: 'appeal_letter',
        label: 'Appeal Letter',
        description: 'Appeal against a decision or order',
        promptHint: 'Original decision, grounds of appeal, relief sought',
        requiredFields: [
          'Appellant',
          'Against Whom',
          'Original Decision',
          'Grounds'
        ],
      ),
    ],
  ),
  DocumentCategory(
    label: 'Personal & Property',
    icon: Icons.home_outlined,
    types: [
      DocumentType(
        id: 'will',
        label: 'Will / Testament',
        description: 'Legal will for asset distribution',
        promptHint: 'Assets, beneficiaries, and specific wishes',
        requiredFields: ['Testator', 'Assets', 'Beneficiaries'],
      ),
      DocumentType(
        id: 'power_of_attorney',
        label: 'Power of Attorney',
        description: 'Authorize someone to act on your behalf',
        promptHint: 'What powers are granted and for what purpose',
        requiredFields: ['Principal', 'Agent', 'Powers Granted', 'Purpose'],
      ),
      DocumentType(
        id: 'gift_deed',
        label: 'Gift Deed',
        description: 'Legal transfer of property as gift',
        promptHint: 'Property details, donor, recipient',
        requiredFields: ['Donor', 'Recipient', 'Property Details'],
      ),
      DocumentType(
        id: 'relinquishment_deed',
        label: 'Relinquishment Deed',
        description: 'Give up rights in inherited property',
        promptHint: 'Property details, parties, rights being given up',
        requiredFields: ['Relinguisher', 'Recipient', 'Property', 'Share'],
      ),
    ],
  ),
  DocumentCategory(
    label: 'HR & Employment',
    icon: Icons.business_center_outlined,
    types: [
      DocumentType(
        id: 'resignation_letter',
        label: 'Resignation Letter',
        description: 'Formal resignation from employment',
        promptHint: 'Role, company, last working day, reason (optional)',
        requiredFields: [
          'Employee Name',
          'Role',
          'Company',
          'Last Working Day'
        ],
      ),
      DocumentType(
        id: 'termination_letter',
        label: 'Termination Letter',
        description: 'Letter terminating an employee',
        promptHint: 'Reason for termination, notice period, dues',
        requiredFields: ['Employee', 'Reason', 'Last Date', 'Settlement'],
      ),
      DocumentType(
        id: 'experience_letter',
        label: 'Experience Letter',
        description: 'Certificate of employment experience',
        promptHint: 'Employee details, role, tenure, performance',
        requiredFields: ['Employee', 'Role', 'From Date', 'To Date'],
      ),
      DocumentType(
        id: 'offer_letter',
        label: 'Offer Letter',
        description: 'Job offer letter to a candidate',
        promptHint: 'Role, CTC, joining date, terms',
        requiredFields: ['Candidate', 'Role', 'CTC', 'Joining Date'],
      ),
    ],
  ),
];

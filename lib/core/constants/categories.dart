import 'package:flutter/material.dart';

class LegalCategory {
  final IconData icon;
  final String name;
  final String description;

  const LegalCategory({
    required this.icon,
    required this.name,
    required this.description,
  });
}

class CategoryField {
  final String fieldKey;
  final String label;
  final String hint;
  final TextInputType inputType;
  final bool required;

  const CategoryField(
    this.fieldKey,
    this.label,
    this.hint,
    this.inputType,
    this.required,
  );
}

class AppCategories {
  static const List<LegalCategory> categories = [
    LegalCategory(
      icon: Icons.inventory_2_outlined,
      name: 'E-commerce & Shopping',
      description: 'Refunds, fake products, seller disputes',
    ),
    LegalCategory(
      icon: Icons.account_balance_outlined,
      name: 'Banking & UPI Fraud',
      description: 'Unauthorized transactions and fraud',
    ),
    LegalCategory(
      icon: Icons.flight_takeoff_outlined,
      name: 'Flights & Travel Issues',
      description: 'Cancellations, delays, refunds',
    ),
    LegalCategory(
      icon: Icons.restaurant_outlined,
      name: 'Restaurants & Food Billing',
      description: 'Overcharging, quality issues',
    ),
    LegalCategory(
      icon: Icons.home_work_outlined,
      name: 'Housing & Real Estate',
      description: 'Builder delays, RERA complaints',
    ),
    LegalCategory(
      icon: Icons.wifi_outlined,
      name: 'Telecom & Internet',
      description: 'Wrong billing, network issues',
    ),
    LegalCategory(
      icon: Icons.local_hospital_outlined,
      name: 'Healthcare',
      description: 'Wrong billing, insurance denial',
    ),
    LegalCategory(
      icon: Icons.school_outlined,
      name: 'Education',
      description: 'Fee refund, fake certificates',
    ),
    LegalCategory(
      icon: Icons.bolt_outlined,
      name: 'Electricity & Utilities',
      description: 'Overbilling, meter tampering',
    ),
    LegalCategory(
      icon: Icons.directions_car_outlined,
      name: 'Automobile',
      description: 'Defective vehicle, service fraud',
    ),
    LegalCategory(
      icon: Icons.work_outline_rounded,
      name: 'Employment',
      description: 'Unpaid salary, PF issues',
    ),
    LegalCategory(
      icon: Icons.shield_outlined,
      name: 'Insurance',
      description: 'Claim rejection, mis-selling',
    ),
    LegalCategory(
      icon: Icons.account_balance_outlined,
      name: 'Government Services',
      description: 'Aadhaar, passport issues',
    ),
    LegalCategory(
      icon: Icons.local_shipping_outlined,
      name: 'Courier & Logistics',
      description: 'Lost parcel, damaged delivery',
    ),
  ];

  static const Map<String, List<CategoryField>> categoryFields = {
    'E-commerce & Shopping': [
      CategoryField('platform', 'Platform', 'Amazon, Flipkart, Meesho...', TextInputType.text, true),
      CategoryField('orderNumber', 'Order Number', 'e.g. 402-1234567-8901234', TextInputType.text, false),
      CategoryField('productName', 'Product Name', 'What did you order?', TextInputType.text, true),
      CategoryField('issueType', 'Issue Type', 'Damaged / Not delivered / Fake product', TextInputType.text, true),
    ],
    'Banking & UPI Fraud': [
      CategoryField('bankName', 'Bank Name', 'SBI, HDFC, ICICI...', TextInputType.text, true),
      CategoryField('transactionId', 'Transaction ID', 'UPI ref / txn number', TextInputType.text, false),
      CategoryField('fraudType', 'Fraud Type', 'Unauthorized transfer / OTP scam...', TextInputType.text, true),
    ],
    'Flights & Travel Issues': [
      CategoryField('airline', 'Airline', 'IndiGo, Air India, SpiceJet...', TextInputType.text, true),
      CategoryField('flightNumber', 'Flight Number', 'e.g. 6E-2341', TextInputType.text, false),
      CategoryField('issueType', 'Issue Type', 'Cancellation / Delay / Refund denied', TextInputType.text, true),
    ],
    'Healthcare': [
      CategoryField('hospitalName', 'Hospital / Clinic Name', '', TextInputType.text, true),
      CategoryField('issueType', 'Issue Type', 'Wrong billing / Negligence / Insurance denial', TextInputType.text, true),
      CategoryField('insuranceProvider', 'Insurance Provider', 'If applicable', TextInputType.text, false),
    ],
    'Telecom & Internet': [
      CategoryField('provider', 'Service Provider', 'Jio, Airtel, BSNL...', TextInputType.text, true),
      CategoryField('accountNumber', 'Account / Mobile Number', '', TextInputType.number, false),
      CategoryField('issueType', 'Issue Type', 'Wrong billing / Network / Data theft', TextInputType.text, true),
    ],
    'Housing & Real Estate': [
      CategoryField('builderName', 'Builder / Landlord Name', '', TextInputType.text, true),
      CategoryField('projectName', 'Project / Property Name', '', TextInputType.text, false),
      CategoryField('reraNumber', 'RERA Registration Number', 'If applicable', TextInputType.text, false),
      CategoryField('issueType', 'Issue Type', 'Delay / Refund / Illegal deduction', TextInputType.text, true),
    ],
    'Education': [
      CategoryField('institutionName', 'Institution Name', '', TextInputType.text, true),
      CategoryField('issueType', 'Issue Type', 'Fee refund / Fake certificate / Harassment', TextInputType.text, true),
    ],
    'Electricity & Utilities': [
      CategoryField('provider', 'Provider Name', 'MSEB, BSES, TATA Power...', TextInputType.text, true),
      CategoryField('consumerNumber', 'Consumer Number', 'From your bill', TextInputType.text, false),
      CategoryField('issueType', 'Issue Type', 'Overbilling / No supply / Meter fault', TextInputType.text, true),
    ],
    'Automobile': [
      CategoryField('brand', 'Brand / Model', 'e.g. Maruti Swift', TextInputType.text, true),
      CategoryField('dealerName', 'Dealer / Service Center', '', TextInputType.text, false),
      CategoryField('issueType', 'Issue Type', 'Defective vehicle / Service fraud / Insurance', TextInputType.text, true),
    ],
    'Employment': [
      CategoryField('companyName', 'Company Name', '', TextInputType.text, true),
      CategoryField('issueType', 'Issue Type', 'Unpaid salary / Wrongful termination / PF', TextInputType.text, true),
      CategoryField('employeeId', 'Employee ID', 'If applicable', TextInputType.text, false),
    ],
    'Insurance': [
      CategoryField('insurerName', 'Insurance Company', '', TextInputType.text, true),
      CategoryField('policyNumber', 'Policy Number', '', TextInputType.text, false),
      CategoryField('issueType', 'Issue Type', 'Claim rejected / Mis-selling / Delay', TextInputType.text, true),
    ],
    'Government Services': [
      CategoryField('serviceName', 'Service Name', 'Aadhaar / Passport / Ration Card', TextInputType.text, true),
      CategoryField('applicationNumber', 'Application / Reference Number', '', TextInputType.text, false),
      CategoryField('issueType', 'Issue Type', 'Delay / Rejection / Wrong data', TextInputType.text, true),
    ],
    'Courier & Logistics': [
      CategoryField('courier', 'Courier Company', 'BlueDart, Delhivery, DTDC...', TextInputType.text, true),
      CategoryField('trackingNumber', 'Tracking Number', '', TextInputType.text, false),
      CategoryField('issueType', 'Issue Type', 'Lost / Damaged / Fake delivery', TextInputType.text, true),
    ],
    'Restaurants & Food Billing': [
      CategoryField('restaurantName', 'Restaurant Name', '', TextInputType.text, true),
      CategoryField('platform', 'Platform', 'Swiggy / Zomato / Direct', TextInputType.text, false),
      CategoryField('issueType', 'Issue Type', 'Overcharging / Quality / Wrong order', TextInputType.text, true),
    ],
  };
}

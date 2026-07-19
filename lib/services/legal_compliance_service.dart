import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/legal_case.dart';

class LegalComplianceService {
  static List<dynamic> _legalKnowledgeBase = [];
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load both original and expanded legal databases
      final originalData = await rootBundle.loadString('assets/legal_kb.json');
      final expandedData = await rootBundle.loadString('assets/legal_kb_expanded.json');
      
      final originalList = json.decode(originalData) as List<dynamic>;
      final expandedList = json.decode(expandedData) as List<dynamic>;
      
      // Combine both databases, prioritizing expanded data
      _legalKnowledgeBase = [...originalList, ...expandedList];
      _isInitialized = true;
    } catch (e) {
      // print('Error loading legal knowledge base: $e');
      _legalKnowledgeBase = [];
      _isInitialized = true;
    }
  }

  // Get legal advice based on user problem
  static List<Map<String, dynamic>> getLegalAdvice(String problem, {String? category}) {
    if (!_isInitialized) return [];

    final problemLower = problem.toLowerCase();
    final relevantLaws = <Map<String, dynamic>>[];

    for (final law in _legalKnowledgeBase) {
      final lawMap = law as Map<String, dynamic>;
      final keywords = (lawMap['problem_keywords'] as List<dynamic>)
          .map((k) => k.toString().toLowerCase())
          .toList();

      // Check if problem matches keywords
      final matchesKeywords = keywords.any((keyword) => problemLower.contains(keyword));
      
      // Check if category matches if provided
      final matchesCategory = category == null || 
          lawMap['category'].toString().toLowerCase().contains(category.toLowerCase());

      if (matchesKeywords && matchesCategory) {
        relevantLaws.add(lawMap);
      }
    }

    // Sort by confidence level
    relevantLaws.sort((a, b) => 
        (b['confidence'] as num).compareTo(a['confidence'] as num));

    return relevantLaws.take(3).toList(); // Return top 3 matches
  }

  // Get all categories
  static List<String> getAllCategories() {
    if (!_isInitialized) return [];

    final categories = _legalKnowledgeBase
        .map((law) => law['category'] as String)
        .toSet()
        .toList();

    categories.sort();
    return categories;
  }

  // Get laws by category
  static List<Map<String, dynamic>> getLawsByCategory(String category) {
    if (!_isInitialized) return [];

    return _legalKnowledgeBase
        .where((law) => law['category'] == category)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // Validate case details against legal requirements
  static LegalComplianceResult validateCase(LegalCase caseData) {
    final issues = <String>[];
    final recommendations = <String>[];
    final requiredDocuments = <String>[];

    // Check for essential information
    if (caseData.title.isEmpty) {
      issues.add('Case title is required');
    }

    if (caseData.description.isEmpty) {
      issues.add('Detailed description is required');
    }

    if (caseData.category.isEmpty) {
      issues.add('Category must be selected');
    }

    // Get relevant legal advice
    final legalAdvice = getLegalAdvice(caseData.description, category: caseData.category);
    
    if (legalAdvice.isNotEmpty) {
      final topLaw = legalAdvice.first;
      
      // Add required documents from legal advice
      if (topLaw['documents_required'] != null) {
        requiredDocuments.addAll((topLaw['documents_required'] as List<dynamic>)
            .map((doc) => doc.toString()));
      }

      // Add recommendations based on legal advice
      if (topLaw['steps'] != null) {
        recommendations.addAll((topLaw['steps'] as List<dynamic>)
            .map((step) => step.toString()));
      }

      // Check if physical visit is required
      if (topLaw['physical_visit_required'] == true) {
        recommendations.add('This case may require visiting the concerned authority in person');
      }
    }

    // General legal compliance checks
    if (caseData.amount > 0 && caseData.amount < 100) {
      recommendations.add('For amounts under ₹100, consider resolving through direct communication first');
    }

    if (caseData.amount > 20000000) { // 20 lakhs
      recommendations.add('For high-value cases, consider hiring a professional lawyer');
      recommendations.add('This case may be filed in a higher court');
    }

    return LegalComplianceResult(
      isCompliant: issues.isEmpty,
      issues: issues,
      recommendations: recommendations,
      requiredDocuments: requiredDocuments,
      applicableLaws: legalAdvice.map((law) => law['applicable_law'] as String).toList(),
      authorities: legalAdvice.isNotEmpty 
          ? (legalAdvice.first['authorities'] as List<dynamic>).cast<String>()
          : <String>[],
    );
  }

  // Generate legal notice template
  static String generateLegalNotice(LegalCase caseData) {
    final legalAdvice = getLegalAdvice(caseData.description, category: caseData.category);
    final applicableLaw = legalAdvice.isNotEmpty 
        ? legalAdvice.first['applicable_law'] as String
        : 'Relevant Consumer Protection Laws';

    return '''
LEGAL NOTICE

Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

To,
${caseData.againstParty.isNotEmpty ? caseData.againstParty : '[Party Name]'}

Subject: Legal Notice regarding ${caseData.title}

Dear Sir/Madam,

Under the provisions of $applicableLaw, I am serving you this legal notice with respect to the matter mentioned below:

${caseData.description}

You are hereby called upon to:
1. Rectify the mentioned issue within 15 days from receipt of this notice
2. Provide compensation/relief as per applicable laws
3. Respond to this notice within the stipulated time period

Should you fail to comply with the above demands, I shall be constrained to initiate appropriate legal proceedings against you in the competent court of law, at your sole risk, cost, and consequences.

A copy of this notice is retained in my office for further action.

Sincerely,

[Your Name]
[Your Contact Information]
[Your Address]
''';
  }

  // Get statute of limitations for different case types
  static Duration? getStatuteOfLimitations(String category) {
    final limitations = {
      'E-commerce & Shopping': const Duration(days: 730), // 2 years
      'Banking & UPI Fraud': const Duration(days: 1095), // 3 years
      'Flights & Travel Issues': const Duration(days: 365), // 1 year
      'Restaurant & Food Billing': const Duration(days: 730), // 2 years
      'Hospital Billing Problems': const Duration(days: 1095), // 3 years
      'Traffic & Vehicle Issues': const Duration(days: 365), // 1 year
      'Employment & Labor Issues': const Duration(days: 1095), // 3 years
      'Property & Real Estate': const Duration(days: 3650), // 10 years
      'Education Issues': const Duration(days: 365), // 1 year
      'Telecom & Internet Issues': const Duration(days: 730), // 2 years
    };

    return limitations[category];
  }

  // Check if case is within statute of limitations
  static bool isWithinStatuteOfLimitations(LegalCase caseData) {
    final limitation = getStatuteOfLimitations(caseData.category);
    if (limitation == null) return true;

    final daysSinceIncident = DateTime.now().difference(caseData.date).inDays;
    return daysSinceIncident <= limitation.inDays;
  }

  // Get emergency contacts for different issues
  static Map<String, String> getEmergencyContacts(String category) {
    final contacts = {
      'E-commerce & Shopping': {
        'National Consumer Helpline': '1800-11-4000',
        'Consumer Commission': '011-26173980',
      },
      'Banking & UPI Fraud': {
        'Banking Ombudsman': '1800-425-0018',
        'Cyber Crime Cell': '1930',
        'Police': '100',
      },
      'Flights & Travel Issues': {
        'DGCA': '011-24622462',
        'AirSewa': '011-6932-4001',
      },
      'Hospital Billing Problems': {
        'National Health Helpline': '1800-11-4477',
        'Medical Council': '011-25862122',
      },
      'Traffic & Vehicle Issues': {
        'Traffic Police': '1095',
        'RTO Helpline': '1800-180-0123',
      },
      'Women Safety': {
        'Women Helpline': '1091',
        'Police': '100',
      },
      'Child Protection': {
        'Child Helpline': '1098',
        'Police': '100',
      },
    };

    return contacts[category] ?? {
      'National Consumer Helpline': '1800-11-4000',
      'Police': '100',
    };
  }
}

class LegalComplianceResult {
  final bool isCompliant;
  final List<String> issues;
  final List<String> recommendations;
  final List<String> requiredDocuments;
  final List<String> applicableLaws;
  final List<String> authorities;

  LegalComplianceResult({
    required this.isCompliant,
    required this.issues,
    required this.recommendations,
    required this.requiredDocuments,
    required this.applicableLaws,
    required this.authorities,
  });
}

import 'package:flutter/foundation.dart';

class MockAIService {
  Future<void> initialize() async {
    if (kDebugMode) print('[MockAIService] Initialized');
  }

  Future<Map<String, dynamic>> analyzeProblem(String problemText, String category) async {
    assert(!kReleaseMode, 'MockAIService must never be used in production builds');

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (kDebugMode) print('[MockAIService] Analyzing: $category - $problemText');

    // Return mock response based on category
    return _getMockResponse(category, problemText);
  }

  Map<String, dynamic> _getMockResponse(String category, String problemText) {
    final baseResponse = {
      'case_summary': 'User reports a problem with a purchased product that is defective and the seller has not responded to support requests.',
      'caseSummary': 'User reports a problem with a purchased product that is defective and the seller has not responded to support requests.',
      'legal_position': {'standing': 'Consumer who purchased the product', 'strength': 'Moderate', 'explanation': 'Receipt available but limited warranty details.'},
      'legalPosition': {'standing': 'Consumer who purchased the product', 'strength': 'Moderate', 'explanation': 'Receipt available but limited warranty details.'},
      'strength': 6,
      'legalAnalysis': 'The Consumer Protection Act 2019 applies because the user appears to be a consumer who purchased goods for consideration and alleges defective goods or deficient service. The rights involved include the right to seek refund, replacement, compensation, and fair grievance redressal. Possible remedies include written escalation to the seller, National Consumer Helpline filing, and a complaint before the appropriate Consumer Commission if unresolved.',
      'relevant_laws': [
        {'law': 'Consumer Protection Act 2019', 'section': 'Section 2(9)', 'explanation': 'Defines consumer and covers defective goods.'}
      ],
      'relevantLaws': [
        {'law': 'Consumer Protection Act 2019', 'section': 'Section 2(9)', 'explanation': 'Defines consumer and covers defective goods.'}
      ],
      'rights_available': ['Right to refund', 'Right to replacement', 'Right to compensation'],
      'rights': ['Right to refund', 'Right to replacement', 'Right to compensation'],
      'evidence_checklist': {'available': ['Invoice', 'Payment receipt'], 'recommended': ['Product photos', 'Warranty details']},
      'evidenceAvailable': ['Invoice', 'Payment receipt'],
      'evidenceRecommended': ['Product photos', 'Warranty details'],
      'recommended_actions': ['Contact seller in writing', 'Request refund or replacement', 'Escalate to grievance officer', 'File complaint with Consumer Commission'],
      'nextSteps': ['Contact seller in writing', 'Request refund or replacement', 'Escalate to grievance officer', 'File complaint with Consumer Commission'],
      'authorities_detailed': [
        {'name': 'National Consumer Helpline', 'description': 'Consumer dispute support and complaint guidance', 'official_website': 'consumerhelpline.gov.in'}
      ],
      'authorities': [
        {'name': 'National Consumer Helpline', 'description': 'Consumer dispute support and complaint guidance', 'officialWebsite': 'consumerhelpline.gov.in'}
      ],
      'risk_factors': ['Missing warranty details', 'Late reporting of issue'],
      'riskFactors': ['Missing warranty details', 'Late reporting of issue'],
      'estimated_outcome': 'Likely moderate chance of refund or replacement if seller responds within 30 days.',
      'estimatedOutcome': 'Likely moderate chance of refund or replacement if seller responds within 30 days.',
      'disclaimer': 'This AI-generated analysis is informational only and not a substitute for professional legal advice.',
      'category': category,
      'applicable_law': 'Consumer Protection Act 2019, Section 2(9)',
      'law_summary': 'Protects consumer rights against defective goods and deficient services',
      'user_rights': 'Right to seek refund, replacement, or compensation for defective products/services',
      'steps': [
        'Send written complaint to service provider',
        'Wait for 15 days for response',
        'File complaint on National Consumer Helpline',
        'Approach Consumer Commission if unresolved'
      ],
      'documents_required': [
        'Purchase receipt or invoice',
        'Communication records with seller',
        'Photos/videos of defect (if applicable)',
        'Warranty card (if applicable)'
      ],
      'physical_visit_required': false,
      'physical_visit_instructions': null,
      'confidence': 85,
      'isVerified': true,
      'complaint_hint': 'Be specific about dates, amounts, and previous communication attempts',
      'order_number': 'ORD123456',
      'product_details': 'Sample Product',
      'amount_paid': '₹5000',
      'payment_method': 'UPI',
      'company_name': 'Sample Company',
      'incident_date': '15 Jan 2024',
      'location': 'Online',
      '_model': 'mock-service',
      '_provider': 'mock'
    };

    // Customize response based on category
    switch (category.toLowerCase()) {
      case 'ecommerce & shopping':
        return {
          ...baseResponse,
          'applicable_law': 'Consumer Protection Act 2019, Section 18 and E-commerce Rules 2020',
          'law_summary': 'Protects buyers in online transactions including refund rights and delivery timelines',
          'user_rights': 'Right to timely delivery, accurate product description, and easy returns/refunds',
          'authorities': [
            'National Consumer Helpline: 1800-11-4000',
            'E-commerce Portal: consumerhelpline.gov.in'
          ]
        };
      
      case 'banking & upi fraud':
        return {
          ...baseResponse,
          'applicable_law': 'Payment and Settlement Systems Act 2007 and RBI Guidelines',
          'law_summary': 'Protects against unauthorized electronic transactions and banking fraud',
          'user_rights': 'Right to dispute unauthorized transactions and get refund within 90 days',
          'authorities': [
            'Banking Ombudsman: cms.rbi.org.in',
            'Cyber Crime Cell: cybercrime.gov.in'
          ]
        };
      
      case 'flights & travel issues':
        return {
          ...baseResponse,
          'applicable_law': 'Aircraft Act 1934 and DGCA Regulations',
          'law_summary': 'Protects air passengers against flight delays, cancellations, and overbooking',
          'user_rights': 'Right to compensation for delays and alternative flights for cancellations',
          'authorities': [
            'DGCA: dgca.gov.in',
            'Airline Grievance Officer: Contact airline directly'
          ]
        };
      
      default:
        return baseResponse;
    }
  }

  // Backward compatibility method
  Future<Map<String, dynamic>> analyze({
    required String problemText,
    required String selectedCategory,
  }) async {
    assert(!kReleaseMode, 'MockAIService must never be used in production builds');

    return await analyzeProblem(problemText, selectedCategory);
  }
}

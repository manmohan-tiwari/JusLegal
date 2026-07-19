import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LKBEntry {
  final String id;
  final String category;
  final List<String> problemKeywords;
  final String applicableLaw;
  final String userRights;
  final List<String> steps;
  final List<String> authorities;
  final List<String> documentsRequired;
  final bool physicalVisitRequired;
  final int confidence;
  final bool isVerified;

  LKBEntry({
    required this.id,
    required this.category,
    required this.problemKeywords,
    required this.applicableLaw,
    required this.userRights,
    required this.steps,
    required this.authorities,
    required this.documentsRequired,
    required this.physicalVisitRequired,
    required this.confidence,
    required this.isVerified,
  });

  factory LKBEntry.fromJson(Map<String, dynamic> json) => LKBEntry(
        id: json['id'] as String,
        category: json['category'] as String,
        problemKeywords:
            List<String>.from(json['problem_keywords'] as List<dynamic>),
        applicableLaw: json['applicable_law'] as String,
        userRights: json['user_rights'] as String,
        steps: List<String>.from(json['steps'] as List<dynamic>),
        authorities: List<String>.from(json['authorities'] as List<dynamic>),
        documentsRequired:
            List<String>.from(json['documents_required'] as List<dynamic>),
        physicalVisitRequired: json['physical_visit_required'] as bool,
        confidence: (json['confidence'] as num).toInt(),
        isVerified: json['isVerified'] as bool,
      );
}

class LKBService {
  List<LKBEntry>? _entries;

  Future<List<LKBEntry>> load() async {
    if (_entries != null) return _entries!;
    
    // Load both original and expanded knowledge bases
    final originalRaw = await rootBundle.loadString('assets/legal_kb.json');
    final expandedRaw = await rootBundle.loadString('assets/legal_kb_expanded.json');
    
    final originalData = json.decode(originalRaw) as List<dynamic>;
    final expandedData = json.decode(expandedRaw) as List<dynamic>;
    
    // Combine both databases, prioritizing expanded data
    final combinedData = [...originalData, ...expandedData];
    
    _entries = combinedData
        .map((e) => LKBEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    
    return _entries!;
  }

  Future<List<LKBEntry>> search(String text,
      {String? category, int topK = 3}) async {
    final entries = await load();
    final tokens = text.toLowerCase();
    final scored = <(LKBEntry, int)>[];
    
    for (final e in entries) {
      // If category is specified, only match entries from that category
      if (category != null && category.isNotEmpty && e.category != category) {
        continue;
      }
      
      int score = 0;
      
      // Check for exact keyword matches (highest priority)
      for (final kw in e.problemKeywords) {
        if (tokens.contains(kw.toLowerCase())) {
          score += 3; // Higher score for exact keyword matches
        }
      }
      
      // Check for partial keyword matches
      for (final kw in e.problemKeywords) {
        final kwLower = kw.toLowerCase();
        final tokenList = tokens.split(' ');
        for (final token in tokenList) {
          if (kwLower.contains(token) && token.length > 2) {
            score += 1; // Lower score for partial matches
          }
        }
      }
      
      // Check for category match
      if (tokens.contains(e.category.toLowerCase())) {
        score += 2;
      }
      
      // Category-specific matching logic
      if (category != null && category.isNotEmpty) {
        final categoryLower = category.toLowerCase();
        
        // E-commerce specific terms
        if (categoryLower.contains('e-commerce') || categoryLower.contains('shopping')) {
          if (tokens.contains('refund') || tokens.contains('delivery') || 
              tokens.contains('product') || tokens.contains('order') ||
              tokens.contains('amazon') || tokens.contains('flipkart')) {
            score += 2;
          }
        }
        
        // Banking specific terms
        if (categoryLower.contains('banking') || categoryLower.contains('fraud')) {
          if (tokens.contains('transaction') || tokens.contains('upi') ||
              tokens.contains('card') || tokens.contains('atm') ||
              tokens.contains('loan') || tokens.contains('bank')) {
            score += 2;
          }
        }
        
        // Travel specific terms
        if (categoryLower.contains('flight') || categoryLower.contains('travel')) {
          if (tokens.contains('flight') || tokens.contains('ticket') ||
              tokens.contains('cancellation') || tokens.contains('delay') ||
              tokens.contains('baggage') || tokens.contains('indigo') ||
              tokens.contains('air india')) {
            score += 2;
          }
        }
        
        // Food specific terms
        if (categoryLower.contains('restaurant') || categoryLower.contains('food')) {
          if (tokens.contains('food') || tokens.contains('restaurant') ||
              tokens.contains('bill') || tokens.contains('zomato') ||
              tokens.contains('swiggy') || tokens.contains('service charge')) {
            score += 2;
          }
        }
        
        // Hospital specific terms
        if (categoryLower.contains('hospital') || categoryLower.contains('medical')) {
          if (tokens.contains('hospital') || tokens.contains('doctor') ||
              tokens.contains('treatment') || tokens.contains('bill') ||
              tokens.contains('medical')) {
            score += 2;
          }
        }
      }
      
      if (score > 0) {
        scored.add((e, score));
      }
    }
    
    // Sort by score (highest first) and return topK results
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.take(topK).map((e) => e.$1).toList();
  }

  Future<String> getContext(String problemText, String category) async {
    final entries = await search(problemText, category: category, topK: 3);

    if (entries.isEmpty) {
      return 'No specific legal information found for this problem. Please consult with a legal professional for accurate advice.';
    }

    // Format as readable string for AI prompt
    final StringBuffer context = StringBuffer();
    context.writeln('Relevant Legal Information:');
    context.writeln('');

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      context.writeln('${i + 1}. ${entry.category}');
      context.writeln('   Law: ${entry.applicableLaw}');
      context.writeln('   Rights: ${entry.userRights}');
      context.writeln('   Steps: ${entry.steps.join('; ')}');
      context.writeln('   Authorities: ${entry.authorities.join(', ')}');
      context.writeln('   Documents: ${entry.documentsRequired.join(', ')}');
      context.writeln('   Physical Visit Required: ${entry.physicalVisitRequired}');
      context.writeln('   Confidence: ${entry.confidence}%');
      context.writeln('');
    }

    return context.toString();
  }

  // Fallback analysis method when APIs fail
  Future<Map<String, dynamic>> getAnalysis(String problemText, String category) async {
    // Find the best matching entry
    final matches = await search(problemText, category: category, topK: 1);
    final bestMatch = matches.isNotEmpty ? matches.first : null;
    
    if (bestMatch == null) {
      // Return a generic response if no match found
      return {
        'category': category,
        'applicable_law': 'Consumer Protection Act 2019',
        'law_summary': 'General consumer protection laws apply to your case.',
        'user_rights': 'You have the right to fair treatment and resolution of your complaint.',
        'steps': [
          'Document your issue clearly',
          'Contact the service provider',
          'Escalate to consumer protection authorities',
          'Seek legal advice if needed'
        ],
        'authorities': ['National Consumer Helpline', 'District Consumer Commission'],
        'documents_required': ['Complaint details', 'Communication records', 'Supporting documents'],
        'physical_visit_required': false,
        'confidence': 60,
        'isVerified': false,
        'complaint_hint': 'Provide detailed information about your issue for better assistance.',
        '_provider': 'lkb_fallback'
      };
    }

    // Convert LKB entry to analysis format
    return {
      'category': bestMatch.category,
      'applicable_law': bestMatch.applicableLaw,
      'law_summary': 'Based on ${bestMatch.applicableLaw}, you have legal protections for this issue.',
      'user_rights': bestMatch.userRights,
      'steps': bestMatch.steps,
      'authorities': bestMatch.authorities,
      'documents_required': bestMatch.documentsRequired,
      'physical_visit_required': bestMatch.physicalVisitRequired,
      'confidence': bestMatch.confidence,
      'isVerified': bestMatch.isVerified,
      'complaint_hint': 'Follow the steps above and contact the mentioned authorities for resolution.',
      '_provider': 'lkb_match'
    };
  }
}

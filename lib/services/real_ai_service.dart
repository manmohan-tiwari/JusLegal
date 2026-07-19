import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/config/env_config.dart';
import '../models/legal_result_model.dart';

class RealAIService {
  final Dio _dio;
  final String _apiKey;
  
   RealAIService() : _dio = Dio(), _apiKey = EnvConfig.openRouterApiKey {
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<LegalResultModel> analyzeWithAI({
    required String problemText,
    required String selectedCategory,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured');
    }

    final prompt = _buildLegalPrompt(problemText, selectedCategory);
    
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': 'gpt-4-turbo-preview',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert Indian legal analyst specializing in consumer rights and grievance redressal. Provide accurate, actionable legal advice based on Indian laws and regulations.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'temperature': 0.3,
        'max_tokens': 2000,
      });

      final content = response.data['choices'][0]['message']['content'];
      return _parseAIResponse(content, selectedCategory);
      
    } catch (e) {
      throw Exception('AI analysis failed: $e');
    }
  }

  String _buildLegalPrompt(String problemText, String category) {
    return '''
Analyze the following consumer problem and provide a professional, detailed legal report in JSON. Target a LegalZoom-style output appropriate for Indian consumers.

CATEGORY: $category
PROBLEM: $problemText

Provide the response only in valid JSON following this schema (use null for unknown fields):

{
  "case_summary": "2-4 sentence summary of the facts and dispute",
  "category": "$category",
  "legal_position": { "standing": "user's standing", "strength": "Strong|Moderate|Weak", "explanation": "why" },
  "relevant_laws": [ { "law": "Act name", "section": "Section reference or null", "explanation": "How it applies in simple terms" } ],
  "rights_available": [ "Right 1", "Right 2" ],
  "evidence_checklist": { "available": ["evidence provided by user"], "recommended": ["additional evidence to collect"] },
  "recommended_actions": [ "Ordered practical steps for the user (numbered)" ],
  "authorities_detailed": [ { "name": "Authority name", "purpose": "What it does", "why_relevant": "Why relevant", "contact": "phone/website" } ],
  "risk_factors": [ "Key weaknesses or limitations" ],
  "estimated_outcome": "Non-guaranteed assessment of likely outcomes",
  "applicable_law": "Top applicable law(s) (short citation)",
  "law_summary": "One-sentence summary of the key legal provision",
  "user_rights": "Short paragraph summarising user's rights",
  "documents_required": [ "Key documents for filing complaints" ],
  "physical_visit_required": true/false,
  "physical_visit_instructions": "If a visit is required, short instructions or null",
  "confidence": 0-100,
  "isVerified": true/false,
  "complaint_hint": "One-line practical hint to prepare an effective complaint",
  "disclaimer": "Short legal disclaimer"
}

Rules:
- Keep language simple and avoid legal jargon where possible.
- Do not fabricate laws or section numbers; only include sections you are reasonably confident apply.
- If unsure about a field, set it to null and state the limitation in the explanation sections.
- Append a concise disclaimer in the "disclaimer" field (see app-level requirement).
''';
  }

  LegalResultModel _parseAIResponse(String aiResponse, String category) {
    try {
      // Extract JSON from AI response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(aiResponse);
      if (jsonMatch == null) {
        throw Exception('Could not parse AI response');
      }

      final jsonStr = jsonMatch.group(0)!;
      final jsonData = json.decode(jsonStr) as Map<String, dynamic>;

      // Ensure all required fields are present
      return LegalResultModel(
        category: jsonData['category'] ?? category,
        applicableLaw: jsonData['applicable_law'] ?? (jsonData['relevant_laws'] is List && (jsonData['relevant_laws'] as List).isNotEmpty ? (jsonData['relevant_laws'][0]['law'] ?? 'Consumer Protection Act 2019') : 'Consumer Protection Act 2019'),
        lawSummary: jsonData['law_summary'] ?? 'Consumer protection laws may apply to this case.',
        userRights: jsonData['user_rights'] ?? (jsonData['rights_available'] != null ? (jsonData['rights_available'] as List).join('; ') : 'Rights to seek redressal.'),
        steps: List<String>.from(jsonData['recommended_actions'] ?? jsonData['steps'] ?? [
          'Document the issue thoroughly',
          'Contact the service provider',
          'Escalate to higher authorities',
          'Seek legal advice if unresolved'
        ]),
        authorities: List<Map<String, String>>.from(
          (jsonData['authorities'] ?? jsonData['authorities_detailed'] ?? [
            {'name': 'National Consumer Helpline', 'contact': '1800-11-4000', 'action': 'File Online'}
          ]).map((e) {
            if (e is Map && e.containsKey('name')) {
              return {
                'name': e['name'].toString(),
                'contact': (e['contact'] ?? e['purpose'] ?? '').toString(),
                'action': (e['why_relevant'] ?? e['action'] ?? '').toString(),
              };
            }
            return {'name': e.toString(), 'contact': '', 'action': ''};
          }),
        ),
        documentsRequired: List<String>.from(jsonData['documents_required'] ?? jsonData['evidence_checklist']?['available'] ?? [
          'Complaint copy',
          'Supporting documents',
          'Communication records'
        ]),
        physicalVisitRequired: jsonData['physical_visit_required'] ?? false,
        physicalVisitInstructions: jsonData['physical_visit_instructions'],
        confidence: (jsonData['confidence'] as num?)?.toInt() ?? 75,
        isVerified: jsonData['isVerified'] ?? false,
        complaintHint: jsonData['complaint_hint'] ?? _generateComplaintHint(category),
        caseSummary: jsonData['case_summary'] as String?,
        legalPosition: jsonData['legal_position'] as Map<String, dynamic>?,
        relevantLaws: (jsonData['relevant_laws'] as List<dynamic>?)?.map((e) => Map<String, String>.from(e as Map)).toList(),
        rightsAvailable: (jsonData['rights_available'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        evidenceChecklist: (jsonData['evidence_checklist'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k.toString(), List<String>.from(v as List))),
        recommendedActions: (jsonData['recommended_actions'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        authoritiesDetailed: (jsonData['authorities_detailed'] as List<dynamic>?)?.map((e) => Map<String, String>.from(e as Map)).toList(),
        riskFactors: (jsonData['risk_factors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        estimatedOutcome: jsonData['estimated_outcome'] as String?,
        disclaimer: jsonData['disclaimer'] as String?,
      );
    } catch (e) {
      // Fallback to basic response if parsing fails
      return _createFallbackResponse(category);
    }
  }

  LegalResultModel _createFallbackResponse(String category) {
    return LegalResultModel(
      category: category,
      applicableLaw: 'Consumer Protection Act 2019',
      lawSummary: 'Consumers have the right to fair treatment and redressal for grievances.',
      userRights: 'Right to be heard, right to seek redressal, right to consumer education.',
      steps: [
        'Document the issue thoroughly',
        'Contact the service provider',
        'Escalate to higher authorities if needed',
        'Seek legal advice if unresolved'
      ],
      authorities: [
        {'name': 'National Consumer Helpline', 'contact': '1800-11-4000', 'action': 'Call Now'},
        {'name': 'District Consumer Commission', 'contact': 'Find nearest', 'action': 'Visit Website'}
      ],
      documentsRequired: ['Complaint copy', 'Supporting documents', 'Communication records'],
      physicalVisitRequired: false,
      confidence: 60,
      isVerified: false,
      complaintHint: _generateComplaintHint(category),
    );
  }

  String _generateComplaintHint(String category) {
    if (category.contains('E-commerce')) return 'Generate formal email to company support';
    if (category.contains('Banking')) return 'Draft letter for RBI Ombudsman';
    if (category.contains('Traffic')) return 'Prepare contest for Virtual Court';
    if (category.contains('Flight')) return 'Prepare DGCA complaint';
    if (category.contains('Restaurant')) return 'Draft FSSAI complaint';
    return 'Draft consumer grievance letter';
  }
}

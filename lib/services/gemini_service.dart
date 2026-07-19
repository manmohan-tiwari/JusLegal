import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/config/ai_runtime_config.dart';

// ignore: unused_element
const String _systemPrompt = """
You are JusLegal, an AI legal assistant specialized in Indian consumer law.
You help Indian citizens understand their rights under:
- Consumer Protection Act 2019
- RERA Act
- RBI Banking Ombudsman guidelines
- IT Act 2000
- Food Safety and Standards Act 2006
- Motor Vehicles Act 1988
- Insurance Regulatory and Development Authority (IRDA) guidelines

For every query, analyze the user's problem and provide a JSON response with these exact fields:
- category: The problem category
- applicable_law: Specific act name and section numbers that apply
- law_summary: Brief summary of the applicable law
- user_rights: What the user is legally entitled to
- steps: Array of numbered step-by-step actions to take
- authorities: Array of objects with authority name and contact details
- documents_required: Array of required documents
- physical_visit_required: Boolean indicating if physical visit is needed
- physical_visit_instructions: Instructions for physical visit (null if not required)
- confidence: Confidence score 0-100
- isVerified: Boolean indicating if information is verified
- complaint_hint: Brief hint for filing complaint
- order_number: Order/transaction number if mentioned (null if not)
- product_details: Description of product/service purchased (null if not)
- amount_paid: Amount paid with currency (e.g., "â‚¹5000", "\$100")
- payment_method: Payment method used (e.g., "UPI", "credit card", "cash", "net banking")
- company_name: Name of company/platform involved (e.g., "Amazon", "Flipkart", "Meesho")
- incident_date: Date when incident occurred (e.g., "15 Jan 2024", "yesterday")
- location: Location of incident (e.g., "Mumbai", "online")

Keep language simple, practical, and in plain English.
Always end with: âš ï¸ This is AI-generated guidance only and does not constitute legal advice. Consult a qualified advocate for legal proceedings.
""";

const String _strictSystemPrompt = """
You are JusLegal, an AI legal assistant specialized in Indian consumer law.
Return valid JSON only. Do not include markdown, code fences, bullets, headings, prose outside JSON, or numbered prefixes inside array values.

Use these exact structured fields:
{
  "caseSummary": "2-4 sentence factual summary",
  "legalPosition": { "standing": "plain English legal standing", "strength": "Weak|Moderate|Strong", "explanation": "brief reason" },
  "strength": 1,
  "legalAnalysis": "Explain why the law applies, the consumer rights involved, and possible remedies.",
  "relevantLaws": [{ "law": "Act or rule", "section": "section/rule if confident", "explanation": "why it applies" }],
  "rights": ["consumer right involved"],
  "authorities": [{ "name": "Authority name", "description": "what it handles", "officialWebsite": "official website URL or domain" }],
  "evidenceAvailable": ["evidence already mentioned by user"],
  "evidenceRecommended": ["additional evidence to collect"],
  "nextSteps": ["clean action step in order"],
  "riskFactors": ["weakness or limitation"],
  "estimatedOutcome": "realistic non-guaranteed outcome",
  "disclaimer": "informational guidance only, not legal advice",
  "category": "problem category",
  "applicable_law": "top applicable law(s)",
  "law_summary": "short law summary",
  "user_rights": "short rights summary",
  "steps": ["same clean steps as nextSteps"],
  "authorities_detailed": [{ "name": "Authority name", "description": "what it handles", "official_website": "official website URL or domain" }],
  "documents_required": ["key documents"],
  "physical_visit_required": false,
  "physical_visit_instructions": null,
  "confidence": 0,
  "isVerified": false,
  "complaint_hint": "one practical complaint filing hint",
  "order_number": null,
  "product_details": null,
  "amount_paid": null,
  "payment_method": null,
  "company_name": null,
  "incident_date": null,
  "location": null
}

The strength field must be a 1-10 score: 1-3 Weak, 4-6 Moderate, 7-10 Strong.
LegalAnalysis must explicitly cover why the law applies, consumer rights involved, and possible remedies.
NextSteps/steps must be clean ordered actions as array values, without "1.", "1.1", bullets, or markdown.
Keep language simple, practical, and in plain English.
""";

class GeminiService {
  String? _apiKey;
  Dio? _dio;

  Future<void> initialize() async {
    try {
      if (AiRuntimeConfig.proxyEnabled) {
        _apiKey = null;
        _dio = Dio(BaseOptions(
          baseUrl: AiRuntimeConfig.proxyBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'X-JusLegal-Provider': 'gemini',
          },
        ));
        return;
      }

      if (!AiRuntimeConfig.allowDirectVendorCalls) {
        throw Exception('Direct Gemini calls are disabled outside debug builds. Configure the proxy instead.');
      }

      _apiKey = AiRuntimeConfig.geminiApiKey;
      if (_apiKey == null || _apiKey!.isEmpty) {
        throw Exception(
          'Gemini API key not configured. Pass GEMINI_API_KEY with --dart-define for debug builds.',
        );
      }

      _dio = Dio(BaseOptions(
        baseUrl:
            'https://generativelanguage.googleapis.com/v1beta/models/${AiRuntimeConfig.geminiModel}',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'X-JusLegal-Provider': 'gemini',
        },
      ));
    } catch (e) {
      if (kDebugMode) print('[GeminiService] Initialization failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> analyze(String problem, String category) async {
    try {
      if (kDebugMode) {
        print('[GeminiService] Starting analysis for: ${problem.substring(0, problem.length > 50 ? 50 : problem.length)}...');
      }

      if (_dio == null) {
        await initialize();
      }

      final prompt = problem;
      final responseText = await _generateText(
        prompt: prompt,
        systemPrompt: _strictSystemPrompt,
      );

      if (responseText.trim().isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      if (kDebugMode) {
        print('[GeminiService] Raw response text: ${_debugPreview(responseText)}');
        print('[GeminiService] Got response from Gemini, parsing...');
      }
      final parsed = _parseGeminiResponse(responseText, category);
      if (kDebugMode) {
        print('[GeminiService] Parsed response keys: ${parsed.keys.toList()}');
        print('[GeminiService] Parsed response preview: ${_debugPreview(parsed)}');
      }
      return parsed;
    } catch (e) {
      if (kDebugMode) print('[GeminiService] Error: $e');
      rethrow;
    }
  }

  Future<String> generateRaw(String prompt) async {
    try {
      if (_dio == null) {
        await initialize();
      }

      final responseText = await _generateText(
        prompt: prompt,
        systemPrompt: '',
      );

      if (responseText.trim().isEmpty) {
        throw Exception('Empty response from Gemini');
      }
      return responseText.trim();
    } catch (e) {
      if (kDebugMode) print('[GeminiService] Error generating raw text: $e');
      rethrow;
    }
  }

  Future<String> _generateText({
    required String prompt,
    required String systemPrompt,
  }) async {
    if (_dio == null) {
      throw Exception('Gemini service not initialized');
    }

    final requestBody = <String, dynamic>{
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 1024,
      },
    };

    if (systemPrompt.isNotEmpty) {
      requestBody['systemInstruction'] = {
        'parts': [
          {'text': systemPrompt},
        ],
      };
    }

    final response = await _dio!.post(
      AiRuntimeConfig.proxyEnabled ? '' : ':generateContent',
      queryParameters: AiRuntimeConfig.proxyEnabled ? null : {'key': _apiKey},
      data: requestBody,
    );

    if (kDebugMode) {
      print('[GeminiService] Raw API response: ${_debugPreview(response.data)}');
    }
    return _extractText(response.data);
  }

  String _extractText(dynamic data) {
    if (data is Map<String, dynamic>) {
      final candidates = data['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final candidate = candidates.first;
        if (candidate is Map<String, dynamic>) {
          final content = candidate['content'];
          if (content is Map<String, dynamic>) {
            final parts = content['parts'];
            if (parts is List && parts.isNotEmpty) {
              final buffer = StringBuffer();
              for (final part in parts) {
                if (part is Map<String, dynamic>) {
                  final text = part['text'];
                  if (text is String && text.trim().isNotEmpty) {
                    buffer.write(text);
                  }
                }
              }
              if (buffer.isNotEmpty) {
                return buffer.toString();
              }
            }
          }
        }
      }

      final directText = data['text'];
      if (directText is String) {
        return directText;
      }
    } else if (data is String) {
      return data;
    }

    throw Exception('Unexpected Gemini response format');
  }

  Map<String, dynamic> _parseGeminiResponse(String response, String category) {
    try {
      String cleanResponse = response.trim();

      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();
      if (kDebugMode) {
        print('[GeminiService] Cleaned response: ${_debugPreview(cleanResponse)}');
      }

      try {
        final Map<String, dynamic> jsonData =
            jsonDecode(cleanResponse) as Map<String, dynamic>;
        return jsonData;
      } catch (_) {
        return _createStructuredResponse(response, category);
      }
    } catch (e) {
      if (kDebugMode) print('[GeminiService] Response parsing failed: $e');
      return _createStructuredResponse(response, category);
    }
  }

  String _debugPreview(dynamic value) {
    final text = value.toString();
    return text.length > 700 ? '${text.substring(0, 700)}...' : text;
  }

  Map<String, dynamic> _createStructuredResponse(String response, String category) {
    final lines = response.split('\n');
    String applicableLaw = '';
    String userRights = '';
    List<String> steps = [];
    List<String> authorities = [];

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.contains('APPLICABLE LAW') || trimmedLine.contains('Law:')) {
        applicableLaw = trimmedLine.split(':').length > 1
            ? trimmedLine.split(':').skip(1).join(':').trim()
            : trimmedLine;
      } else if (trimmedLine.contains('YOUR RIGHTS') || trimmedLine.contains('Rights:')) {
        userRights = trimmedLine.split(':').length > 1
            ? trimmedLine.split(':').skip(1).join(':').trim()
            : trimmedLine;
      } else if (trimmedLine.contains(RegExp(r'^\d+\.'))) {
        steps.add(trimmedLine);
      } else if (trimmedLine.contains('AUTHORITY') || trimmedLine.contains('CONTACT')) {
        authorities.add(trimmedLine);
      }
    }

    return {
      'category': category,
      'applicable_law': applicableLaw.isNotEmpty ? applicableLaw : 'Consumer Protection Act 2019',
      'law_summary': 'Protects consumer rights and provides remedies for grievances',
      'user_rights': userRights.isNotEmpty ? userRights : 'Right to seek redressal for consumer grievances',
      'steps': steps.isNotEmpty
          ? steps
          : ['File complaint with consumer forum', 'Gather evidence', 'Seek legal advice if needed'],
      'authorities': authorities.isNotEmpty
          ? authorities
          : ['National Consumer Helpline: 1800-11-4000'],
      'documents_required': [
        'Purchase receipts',
        'Communication records',
        'Evidence of defect/service failure',
      ],
      'physical_visit_required': false,
      'physical_visit_instructions': null,
      'confidence': 75,
      'isVerified': false,
      'complaint_hint': 'Be specific about dates, amounts, and communication attempts',
      'order_number': null,
      'product_details': null,
      'amount_paid': null,
      'payment_method': null,
      'company_name': null,
      'incident_date': null,
      'location': null,
      '_model': 'gemini-2.0-flash',
      '_provider': 'google',
    };
  }
}

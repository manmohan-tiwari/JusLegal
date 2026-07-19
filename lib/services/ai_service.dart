import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/categories.dart';
import '../core/exceptions/ai_exceptions.dart';
import '../core/config/env_config.dart';
import 'gemini_service.dart';
import 'groq_service.dart';
import 'openrouter_service.dart';
import 'lkb_service.dart';
import 'mock_ai_service.dart';
import 'real_ai_service.dart';


class AIService {
  late final GeminiService _geminiService;
  late final GroqService _groqService;
  late final OpenRouterService _openRouterService;
  late final LKBService _lkbService;
  late final RealAIService _realAIService;
  MockAIService? _mockService;

  AIService() {
    _geminiService = GeminiService();
    _groqService = GroqService();
    _openRouterService = OpenRouterService();
    _lkbService = LKBService();
    _realAIService = RealAIService();
    _mockService = MockAIService();
  }

  Future<void> initialize() async {
    try {
      await _lkbService.load();
      await _geminiService.initialize();
    } catch (e) {
      if (kDebugMode) debugPrint('[AIService] Some services failed to initialize: $e');
    }
  }

  /// Use real AI if any key is configured, otherwise fall back to mock
  bool get _useRealAI => EnvConfig.hasAnyApiKey();

  /// Simplified analysis method for chat-based interactions
  Future<Map<String, dynamic>> analyzeProblemFromText(String description) async {
    return await analyzeProblem(
      category: 'General',
      dateOfIncident: 'Not specified',
      disputedAmount: 'Not specified',
      involvedParty: 'Not specified',
      referenceNumber: 'N/A',
      summary: description,
      attachedFiles: [],
    );
  }

  Future<Map<String, dynamic>> analyzeProblem({
    required String category,
    required String dateOfIncident,
    required String disputedAmount,
    required String involvedParty,
    required String referenceNumber,
    required String summary,
    required List<PlatformFile> attachedFiles,
    Map<String, String> dynamicFieldValues = const {},
  }) async {
    // Use mock if no API keys configured
    if (!_useRealAI) {
      if (kDebugMode) debugPrint('[AIService] No API keys found — using MockAIService');
      return await _mockService!.analyzeProblem(summary, category);
    }

    if (kDebugMode) debugPrint('[AIService] API keys found — using RealAIService');

    String dynamicFieldsText = '';
    if (dynamicFieldValues.isNotEmpty) {
      final categoryFields = AppCategories.categoryFields[category];
      if (categoryFields != null) {
        for (final field in categoryFields) {
          final value = dynamicFieldValues[field.fieldKey] ?? 'Not provided';
          dynamicFieldsText += '${field.label}: $value\n';
        }
      }
    }

    final fullPrompt = """
You are an Indian consumer law expert. Analyze this case:
Category: $category
$dynamicFieldsText
Date: $dateOfIncident
Amount in dispute: ₹$disputedAmount
Involved party: $involvedParty
Reference number: $referenceNumber
User's description: $summary
Attached evidence count: ${attachedFiles.length} file(s)

Provide: 1) Legal rights under Indian consumer law, 2) Step-by-step action plan, 3) Relevant laws/sections, 4) Authorities to contact, 5) Realistic outcome confidence score (0-100).
""";

    // 1. Try Gemini first
    try {
      if (kDebugMode) debugPrint('[AIService] Attempting Gemini...');
      final result = await _geminiService.analyze(fullPrompt, category);
      if (kDebugMode) debugPrint('[AIService] ✅ Gemini success');
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('[AIService] Gemini failed: $e');
    }

    // 2. Load legal context for fallback services
    String legalContext;
    try {
      legalContext = await _lkbService.getContext(summary, category);
    } catch (e) {
      if (kDebugMode) debugPrint('[AIService] Failed to load legal context: $e');
      legalContext = 'Consumer protection laws and regulations applicable to the case.';
    }

    final String systemPrompt = _buildStrictSystemPrompt(legalContext);
    String groqError = 'Unknown error';
    String openRouterError = 'Unknown error';

    // 3. Fallback to Groq
    try {
      if (kDebugMode) debugPrint('[AIService] Attempting Groq...');
      final result = await _tryWithRetry(
        () => _groqService.analyze(systemPrompt, fullPrompt, category: category),
        'Groq',
      );
      if (kDebugMode) debugPrint('[AIService] ✅ Groq success');
      return result;
    } catch (e) {
      groqError = e.toString();
      if (kDebugMode) debugPrint('[AIService] Groq failed: $e');
    }

    // 4. Fallback to OpenRouter
    try {
      if (kDebugMode) debugPrint('[AIService] Attempting OpenRouter...');
      final result = await _tryWithRetry(
        () => _openRouterService.analyze(systemPrompt, fullPrompt, category: category),
        'OpenRouter',
      );
      if (kDebugMode) debugPrint('[AIService] ✅ OpenRouter success');
      return result;
    } catch (e) {
      openRouterError = e.toString();
      if (kDebugMode) debugPrint('[AIService] All providers failed: $e');
    }

    throw AllProvidersFailedException(groqError, openRouterError);
  }

  // Backward compatibility
  Future<Map<String, dynamic>> analyze({
    required String category,
    required String dateOfIncident,
    required String disputedAmount,
    required String involvedParty,
    required String referenceNumber,
    required String summary,
    required List<PlatformFile> attachedFiles,
    Map<String, String> dynamicFieldValues = const {},
  }) async {
    return await analyzeProblem(
      category: category,
      dateOfIncident: dateOfIncident,
      disputedAmount: disputedAmount,
      involvedParty: involvedParty,
      referenceNumber: referenceNumber,
      summary: summary,
      attachedFiles: attachedFiles,
      dynamicFieldValues: dynamicFieldValues,
    );
  }

  Future<String> generateLetter({
    required String letterType,
    required String category,
    required String problemDescription,
    required String userRights,
    required String applicableLaw,
    required List<String> steps,
    required String senderName,
    required String senderAddress,
    required String opponentName,
    required String incidentDate,
  }) async {
    final prompt = _buildLetterPrompt(
      letterType: letterType,
      category: category,
      problemDescription: problemDescription,
      userRights: userRights,
      applicableLaw: applicableLaw,
      steps: steps,
      senderName: senderName,
      senderAddress: senderAddress,
      opponentName: opponentName,
      incidentDate: incidentDate,
    );

    // 1. Try Gemini
    try {
      if (kDebugMode) debugPrint('[AIService] Generating letter with Gemini...');
      final result = await _geminiService.generateRaw(prompt);
      if (kDebugMode) debugPrint('[AIService] ✅ Gemini letter success');
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('[AIService] Gemini letter failed: $e');
    }

    // 2. Try Groq
    try {
      if (kDebugMode) debugPrint('[AIService] Generating letter with Groq...');
      final result = await _groqService.generateRaw('', prompt);
      if (kDebugMode) debugPrint('[AIService] ✅ Groq letter success');
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('[AIService] Groq letter failed: $e');
    }

    // 3. Try OpenRouter
    try {
      if (kDebugMode) debugPrint('[AIService] Generating letter with OpenRouter...');
      final result = await _openRouterService.generateRaw('', prompt);
      if (kDebugMode) debugPrint('[AIService] ✅ OpenRouter letter success');
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('[AIService] OpenRouter letter failed: $e');
    }

    throw Exception('All AI services failed to generate the letter. Check your internet connection and API keys.');
  }

  String _buildLetterPrompt({
    required String letterType,
    required String category,
    required String problemDescription,
    required String userRights,
    required String applicableLaw,
    required List<String> steps,
    required String senderName,
    required String senderAddress,
    required String opponentName,
    required String incidentDate,
  }) {
    final typeLabel = {
      'email': 'a formal consumer complaint email',
      'police': 'a formal police complaint letter',
      'consumer_court': 'a formal consumer court complaint draft',
    }[letterType] ?? 'a formal complaint letter';

    final stepsText = steps.isNotEmpty
        ? steps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')
        : 'No specific steps provided.';

    final effectiveSender = senderName.trim().isEmpty ? '[Your Full Name]' : senderName.trim();
    final effectiveAddress = senderAddress.trim().isEmpty ? '[Your Address]' : senderAddress.trim();
    final effectiveOpponent = opponentName.trim().isEmpty ? '[Respondent Name/Company]' : opponentName.trim();

    return '''You are a professional Indian legal writer. Write $typeLabel based on the details below.

IMPORTANT RULES:
- Write ONLY the letter/document itself — no explanations, no preamble, no notes after the letter
- Use formal, professional legal language appropriate for India
- Fill in ALL details using the information provided below
- If a piece of information is not provided, use a sensible placeholder like [Your Phone Number]
- Include proper structure: To/From addresses, Subject, Date, Body paragraphs, Closing
- Cite the specific law/act provided
- Keep it professional and assertive but not aggressive
- End with a clear demand and deadline (e.g., "respond within 7 days")

SENDER DETAILS:
Name: $effectiveSender
Address: $effectiveAddress

RESPONDENT / OPPONENT:
$effectiveOpponent

INCIDENT DATE: $incidentDate

PROBLEM CATEGORY: $category

PROBLEM DESCRIPTION:
$problemDescription

LEGAL RIGHTS:
$userRights

APPLICABLE LAW:
$applicableLaw

RECOMMENDED ACTION STEPS:
$stepsText

Now write the complete $typeLabel:''';
  }

  Future<Map<String, dynamic>> _tryWithRetry(
    Future<Map<String, dynamic>> Function() operation,
    String providerName,
  ) async {
    String? lastError;

    for (int attempt = 0; attempt < ApiConstants.maxRetries; attempt++) {
      try {
        return await operation();
      } on RateLimitException {
        rethrow;
      } catch (e) {
        lastError = e.toString();
        if (attempt < ApiConstants.maxRetries - 1) {
          await Future.delayed(
              const Duration(milliseconds: ApiConstants.retryDelayMs));
        }
      }
    }

    throw Exception('All retries failed for $providerName. Last error: $lastError');
  }

  String _buildStrictSystemPrompt(String legalContext) {
    return '''You are JusLegal, an AI-powered legal assistant specializing in Indian consumer protection laws.
Return valid JSON only. Do not include markdown, code fences, bullets, headings, prose outside JSON, or numbered prefixes inside array values.

LEGAL CONTEXT:
$legalContext

Use this exact structured JSON response format:
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
legalAnalysis must explicitly cover why the law applies, consumer rights involved, and possible remedies.
nextSteps/steps must be clean ordered actions as array values, without "1.", "1.1", bullets, or markdown.
Do not invent law sections; only include sections you are reasonably confident apply.
''';
  }
}
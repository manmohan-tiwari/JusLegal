import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:juslegal/constants/document_prompts_complete.dart';
import 'package:juslegal/core/core.dart';
import 'package:juslegal/models/chat_message_model.dart';

/// SecurityAudit: AI service with structured exception handling and PII sanitization.
/// Uses Google Gemini (via google_generative_ai SDK) directly.
class AIService {
  final GeminiChatClient _client;

  AiProvider _preferredProvider = AiProvider.gemini;
  AiProvider get preferredProvider => _preferredProvider;

  /// Compatibility switch
  void switchProvider(AiProvider provider) {
    _preferredProvider = provider;
    if (kDebugMode) {
      debugPrint('[AIService] Preferred provider switched to ${provider.name}');
    }
  }

  AIService({GeminiChatClient? client})
      : _client = client ?? GeminiChatClient();

  Future<void> initialize() async {
    _validateApiKeyConfig();
    if (kDebugMode) {
      debugPrint('[AIService] Initialized Google Gemini client');
    }
  }

  /// Validates that Gemini API key is configured.
  void _validateApiKeyConfig() {
    final apiKey = AppConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      const message =
          'Gemini API key is not configured. Please set GEMINI_API_KEY in .env or --dart-define.';
      if (kDebugMode) {
        debugPrint('[AIService] $message');
      }
      throw ApiKeyException('Google Gemini');
    }
    if (kDebugMode) {
      debugPrint('[AIService] Gemini API key configured successfully.');
    }
  }

  Future<T> _execute<T>(
    Future<T> Function(GeminiChatClient client) action, {
    required String operationLabel,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[AIService] Executing $operationLabel with Gemini...');
      }
      return await action(_client);
    } catch (e) {
      _logError('$operationLabel failed', e);
      rethrow;
    }
  }

  /// Sends a chat message with structured exception handling.
  Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> conversationHistory, {
    String languageCode = 'en',
    CaseState? caseState,
  }) async {
    return await _execute(
      (client) => client.sendMessage(
        userMessage,
        conversationHistory,
        languageCode: languageCode,
        caseState: caseState,
      ),
      operationLabel: 'chat message',
    );
  }

  /// Simplified analysis method for chat-based interactions
  Future<Map<String, dynamic>> analyzeProblemFromText(
      String description) async {
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

  /// Analyzes legal problem with structured exception handling.
  Future<Map<String, dynamic>> analyzeProblem({
    required String category,
    required String dateOfIncident,
    required String disputedAmount,
    required String involvedParty,
    required String referenceNumber,
    required String summary,
    required List<PlatformFile> attachedFiles,
    Map<String, String> dynamicFieldValues = const {},
    String languageCode = 'en',
  }) async {
    if (summary.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('[AIService] A problem description is required.');
      }
      throw ArgumentError('A problem description is required');
    }

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
    final localizedPrompt =
        '$fullPrompt\n${_languageInstruction(languageCode)}';
    const legalContext =
        'Consumer protection laws and regulations applicable to the case.';
    final systemPrompt = _buildStrictSystemPrompt(legalContext, languageCode);

    return await _execute(
      (client) => _tryWithRetry(
        () => client.analyze(
          systemPrompt,
          localizedPrompt,
          category: category,
        ),
        'Gemini',
      ),
      operationLabel: 'legal analysis',
    );
  }

  /// Backward compatibility alias
  @Deprecated('Use analyzeProblem() instead.')
  Future<Map<String, dynamic>> analyze({
    required String category,
    required String dateOfIncident,
    required String disputedAmount,
    required String involvedParty,
    required String referenceNumber,
    required String summary,
    required List<PlatformFile> attachedFiles,
    Map<String, String> dynamicFieldValues = const {},
    String languageCode = 'en',
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
      languageCode: languageCode,
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
    String languageCode = 'en',
  }) async {
    final prompts =
        DocumentPromptsComplete.getPromptsForType(letterType, languageCode);
    final systemPrompt = prompts['system'] ?? '';
    var userPrompt = prompts['user'] ?? '';

    userPrompt = userPrompt
        .replaceAll(
            '{senderName}', senderName.isNotEmpty ? senderName : '[Your Name]')
        .replaceAll('{senderAddress}',
            senderAddress.isNotEmpty ? senderAddress : '[Your Address]')
        .replaceAll('{recipientName}',
            opponentName.isNotEmpty ? opponentName : '[Recipient Name]')
        .replaceAll('{opponentName}',
            opponentName.isNotEmpty ? opponentName : '[Opponent Name]')
        .replaceAll(
            '{incidentDate}', incidentDate.isNotEmpty ? incidentDate : '[Date]')
        .replaceAll(
            '{problemDescription}',
            problemDescription.isNotEmpty
                ? problemDescription
                : '[Problem Details]')
        .replaceAll('{applicableLaw}',
            applicableLaw.isNotEmpty ? applicableLaw : '[Applicable Law]');

    final localizedSystemPrompt =
        '$systemPrompt\n${_languageInstruction(languageCode)}';

    return await _execute(
      (client) async {
        final raw = await client.generateRaw(localizedSystemPrompt, userPrompt);
        return _documentTextFromJson(raw);
      },
      operationLabel: 'generate letter ($letterType)',
    );
  }

  /// Generates structured fields for a printable legal document.
  Future<Map<String, dynamic>> generateDocumentFields({
    required String documentType,
    required String fieldsText,
    String languageCode = 'en',
  }) async {
    final type = documentType.toLowerCase();
    final schema = type.contains('consumer') || type.contains('complaint')
        ? '''{
  "consumer_status_reason": "...",
  "jurisdiction_territorial": "...",
  "jurisdiction_pecuniary_amount": "50000",
  "facts": ["That on [date], the complainant..."],
  "cause_of_action_date": "DD/MM/YYYY",
  "cause_of_action_reason": "...",
  "relief": ["Direct the OP to refund ₹X", "Award compensation of ₹Y for mental harassment", "Award cost of litigation"]
}'''
        : type.contains('rti')
            ? '''{
  "pio_department": "...",
  "pio_address": "...",
  "information_sought": ["item1", "item2"],
  "period": "...",
  "preferred_format": "...",
  "fee_method": "..."
}'''
            : type.contains('notice')
                ? '''{
  "background_facts": ["fact1", "fact2", "fact3"],
  "legal_violation": "...",
  "demands": ["demand1", "demand2"],
  "deadline_days": 30
}'''
                : type.contains('affidavit')
                    ? '''{
  "purpose": "...",
  "statements": ["stmt1", "stmt2", "stmt3"]
}'''
                    : type.contains('rent')
                        ? '''{
  "document_text": "complete ready-to-print rent agreement with all standard clauses",
  "landlord_name": "...",
  "tenant_name": "...",
  "property_address": "...",
  "monthly_rent": "...",
  "lease_duration": "...",
  "start_date": "...",
  "security_deposit": "..."
}'''
                        : '''{
  "document_text": "complete ready-to-print legal document",
  "structured_fields": { "field_key": "normalized value" }
}''';
    final prompt = '''You are an expert Indian legal document drafter.
Create structured data for a $documentType using the user details below.

USER PROVIDED DETAILS:
$fieldsText

You must respond with ONLY a valid JSON object.
No explanation, no markdown, no ```json fences.
Start your response with { and end with }.
Return JSON matching this schema exactly, with no keys outside the schema:
$schema''';
    final localizedPrompt = '$prompt\n${_languageInstruction(languageCode)}';

    final rawResponse = await _execute(
      (client) => client.generateRaw('', localizedPrompt, jsonResponse: true),
      operationLabel: 'generate document fields ($documentType)',
    );

    if (kDebugMode) {
      debugPrint('RAW AI RESPONSE: $rawResponse');
    }
    final decoded = jsonDecode(_extractJsonObject(rawResponse));
    if (decoded is! Map) {
      throw const FormatException('AI response must be a JSON object.');
    }
    final parsedJson = Map<String, dynamic>.from(decoded);
    if (kDebugMode) {
      debugPrint('PARSED JSON: $parsedJson');
    }
    return parsedJson;
  }

  static String _extractJsonObject(String value) {
    var clean = value.trim();
    if (clean.startsWith('```')) {
      clean = clean
          .replaceAll(RegExp(r'```json|```', caseSensitive: false), '')
          .trim();
    }
    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start != -1 && end != -1 && end >= start) {
      clean = clean.substring(start, end + 1);
    }
    return clean;
  }

  static String _documentTextFromJson(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'^```(json)?\s*'), '')
        .replaceAll(RegExp(r'\s*```$'), '')
        .replaceAll(RegExp(r'^\*\*'), '')
        .replaceAll(RegExp(r'\*\*$'), '')
        .trim();

    if (!cleaned.startsWith('{')) return cleaned;

    final decoded = jsonDecode(cleaned);
    if (decoded is! Map || decoded['document_text'] is! String) {
      throw const FormatException(
          'AI response must contain a document_text JSON field.');
    }
    return (decoded['document_text'] as String).trim();
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

    throw Exception(
        'All retries failed for $providerName. Last error: $lastError');
  }

  String _buildStrictSystemPrompt(String legalContext, String languageCode) {
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

${_languageInstruction(languageCode)}''';
  }

  String _languageInstruction([String languageCode = 'en']) {
    return 'Respond in English.';
  }

  void _logError(String context, Object error) {
    final sanitized = ErrorSanitizer.sanitizeForLog(error.toString());
    if (kDebugMode) {
      debugPrint('[AIService] $context (sanitized): $sanitized');
    }
    AppLogger().error('$context: $sanitized', tag: 'AIService', error: error);
    if (SafeAnalytics.analyticsEnabled) {
      SafeAnalytics.logEvent(
        name: 'ai_service_error',
        parameters: {'context': ErrorSanitizer.sanitizeForLog(context)},
      );
    }
  }

  /// Generate text with custom system prompt and user prompt
  Future<String> generateText({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.3,
  }) async {
    return await _execute(
      (client) => client.generateRaw(systemPrompt, userPrompt),
      operationLabel: 'generate text',
    );
  }

  /// Generate a legal document as plain text (not JSON)
  Future<String> generateDocument({
    required String documentType,
    required String fieldsText,
    String languageCode = 'en',
  }) async {
    const language = 'English';

    final systemPrompt =
        '''You are a professional Indian legal document drafter.
Your task is to generate a complete, ready-to-print legal document based on the provided information.

STRICT RULES:
1. Use ONLY the information provided - do not hallucinate or assume facts
2. Generate the complete document with proper formatting, structure, and legal language
3. Include all standard sections: header, parties, body, conclusion, signature areas
4. Use formal, professional legal language appropriate for Indian law
5. Ensure the document is ready to print and use
6. Respond with ONLY the document text - no explanations, no preamble, no notes
7. Output in $language language

Generate a complete $documentType document.''';

    final userPrompt =
        '''Generate a complete $documentType document with the following information:

$fieldsText

Output the complete document in $language language.''';

    return await generateText(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      temperature: 0.3,
    );
  }
}

// =============================================================================
// Gemini Client (Direct Google AI Studio SDK)
// =============================================================================

class GeminiChatClient {
  final String modelName;
  final String? _explicitApiKey;

  GeminiChatClient({
    String? modelName,
    String? apiKey,
    AiProvider? provider,
  })  : modelName = modelName ?? AppConfig.geminiModel,
        _explicitApiKey = apiKey;

  String get _apiKey {
    final key = _explicitApiKey ?? AppConfig.geminiApiKey;
    if (key.trim().isEmpty) {
      throw ApiKeyException('Google Gemini');
    }
    return key.trim();
  }

  GenerativeModel _createModel({
    String? modelOverride,
    String? systemInstruction,
    bool jsonResponse = false,
    double? temperature,
    int? maxTokens,
  }) {
    return GenerativeModel(
      model: modelOverride ?? modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: temperature ?? ApiConstants.temperature,
        maxOutputTokens: maxTokens ?? ApiConstants.maxTokens,
        responseMimeType: jsonResponse ? 'application/json' : 'text/plain',
      ),
      systemInstruction:
          systemInstruction != null && systemInstruction.trim().isNotEmpty
              ? Content.system(systemInstruction.trim())
              : null,
    );
  }

  Future<GenerateContentResponse> _generateContentWithFallback(
    GenerativeModel primaryModel,
    Iterable<Content> prompt, {
    String? systemInstruction,
    bool jsonResponse = false,
    double? temperature,
    int? maxTokens,
  }) async {
    try {
      return await primaryModel.generateContent(prompt);
    } catch (e) {
      final errorStr = e.toString();
      final isDemandOrNotFound = errorStr.contains('503') ||
          errorStr.contains('UNAVAILABLE') ||
          errorStr.contains('high demand') ||
          errorStr.contains('404') ||
          errorStr.contains('not found') ||
          errorStr.contains('no longer available');

      if (isDemandOrNotFound) {
        const fallbacks = [
          'gemini-flash-lite-latest',
          'gemini-3.6-flash',
          'gemini-3.5-flash-lite',
        ];
        final candidates = fallbacks.where((m) => m != modelName).toList();
        for (final fallback in candidates) {
          try {
            if (kDebugMode) {
              debugPrint(
                  '[GeminiChatClient] Model $modelName unavailable ($errorStr). Falling back to $fallback...');
            }
            final fallbackModel = _createModel(
              modelOverride: fallback,
              systemInstruction: systemInstruction,
              jsonResponse: jsonResponse,
              temperature: temperature,
              maxTokens: maxTokens,
            );
            return await fallbackModel.generateContent(prompt);
          } catch (fallbackError) {
            if (kDebugMode) {
              debugPrint(
                  '[GeminiChatClient] Fallback $fallback also failed: $fallbackError');
            }
            continue;
          }
        }
      }
      rethrow;
    }
  }

  Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> conversationHistory, {
    String languageCode = 'en',
    CaseState? caseState,
  }) async {
    try {
      final systemPrompt =
          StringBuffer(chatSystemPromptForLanguage(languageCode));
      if (caseState != null) {
        systemPrompt
            .write('\n\nCURRENT CASE STATE:\n${caseState.toPromptSummary()}');
      }

      final model = _createModel(
        systemInstruction: systemPrompt.toString(),
        jsonResponse: true,
        maxTokens: ApiConstants.chatMaxTokens,
      );

      final contents = <Content>[];
      for (final message in conversationHistory) {
        final role = message['role'];
        final text = (message['content'] ?? '').trim();
        if (text.isEmpty) continue;
        if (role == 'user') {
          contents.add(Content.text(text));
        } else if (role == 'assistant' || role == 'model') {
          contents.add(Content.model([TextPart(text)]));
        }
      }
      contents.add(Content.text(userMessage));

      if (kDebugMode) {
        debugPrint(
            '[GeminiChatClient] Calling Gemini for chat ($modelName, history=${conversationHistory.length})');
      }

      final response = await _generateContentWithFallback(
        model,
        contents,
        systemInstruction: systemPrompt.toString(),
        jsonResponse: true,
        maxTokens: ApiConstants.chatMaxTokens,
      );
      final responseText = response.text;
      if (responseText == null || responseText.trim().isEmpty) {
        throw ParseException('Empty response received from Gemini');
      }
      return _stripCodeFence(responseText);
    } catch (e) {
      _handleError(e, 'sendMessage');
    }
  }

  Future<Map<String, dynamic>> analyze(
    String systemPrompt,
    String problemText, {
    String category = 'general',
  }) async {
    try {
      final model = _createModel(
        systemInstruction: systemPrompt,
        jsonResponse: true,
        maxTokens: ApiConstants.maxTokens,
      );

      if (kDebugMode) {
        debugPrint(
            '[GeminiChatClient] Calling Gemini for analysis ($modelName, category=$category)');
      }

      final response = await _generateContentWithFallback(
        model,
        [Content.text(problemText)],
        systemInstruction: systemPrompt,
        jsonResponse: true,
        maxTokens: ApiConstants.maxTokens,
      );
      final responseText = response.text;
      if (responseText == null || responseText.trim().isEmpty) {
        throw ParseException('Empty analysis response received from Gemini');
      }

      final clean = _stripCodeFence(responseText);
      final parsed = jsonDecode(clean) as Map<String, dynamic>;
      parsed['_provider'] = 'gemini';
      return parsed;
    } on FormatException catch (e) {
      throw ParseException('Failed to parse Gemini response as JSON: $e');
    } catch (e) {
      _handleError(e, 'analyze');
    }
  }

  Future<String> generateRaw(
    String systemPrompt,
    String prompt, {
    bool jsonResponse = false,
    int? maxTokens,
  }) async {
    try {
      final model = _createModel(
        systemInstruction: systemPrompt,
        jsonResponse: jsonResponse,
        maxTokens: maxTokens ?? ApiConstants.letterMaxTokens,
      );

      if (kDebugMode) {
        debugPrint(
            '[GeminiChatClient] Calling Gemini for text generation ($modelName)');
      }

      final response = await _generateContentWithFallback(
        model,
        [Content.text(prompt)],
        systemInstruction: systemPrompt,
        jsonResponse: jsonResponse,
        maxTokens: maxTokens ?? ApiConstants.letterMaxTokens,
      );
      final responseText = response.text;
      if (responseText == null || responseText.trim().isEmpty) {
        throw ParseException('Empty text response received from Gemini');
      }
      return responseText.trim();
    } catch (e) {
      _handleError(e, 'generateRaw');
    }
  }

  String _stripCodeFence(String value) {
    var result = value.trim();
    if (result.startsWith('```json')) result = result.substring(7);
    if (result.startsWith('```')) result = result.substring(3);
    if (result.endsWith('```')) result = result.substring(0, result.length - 3);
    return result.trim();
  }

  Never _handleError(Object error, String operation) {
    if (error is UserFacingException ||
        error is ParseException ||
        error is ApiKeyException) {
      throw error;
    }
    final errorStr = error.toString();
    if (kDebugMode) {
      debugPrint('[GeminiChatClient] $operation error: $errorStr');
    }
    if (errorStr.contains('API_KEY_INVALID') ||
        errorStr.contains('API key not valid') ||
        errorStr.contains('ApiKeyException')) {
      throw ApiKeyException('Google Gemini');
    }
    if (errorStr.contains('RESOURCE_EXHAUSTED') || errorStr.contains('429')) {
      throw RateLimitException(
          'Gemini rate limit exceeded. Please wait a moment.', 'Gemini');
    }
    if (errorStr.contains('503') ||
        errorStr.contains('UNAVAILABLE') ||
        errorStr.contains('high demand')) {
      throw RateLimitException(
          'Gemini is experiencing temporary high demand. Please try again shortly.', 'Gemini');
    }
    if (errorStr.contains('SocketException') ||
        errorStr.contains('HandshakeException') ||
        errorStr.contains('timed out')) {
      throw NetworkException(
          'Network error connecting to Gemini. Please check your connection.');
    }
    throw NetworkException('Gemini request failed: $errorStr');
  }
}

// =============================================================================
// Provider configuration
// =============================================================================

enum AiProvider { gemini }


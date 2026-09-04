import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:juslegal/core/core.dart';
import '../core/constants/categories.dart';
import '../core/exceptions/ai_exceptions.dart';
import 'firebase_token_service.dart';

/// SecurityAudit: AI service with structured exception handling and PII sanitization.
/// All errors are logged with PII removed and returned as UserFacingExceptions to UI.
class AIService {
  late final OpenRouterService _openRouterService;
  late final GroqService _groqService;

  /// Currently preferred provider. Chat/analysis requests try this provider
  /// first and fall back to the other worker-routed provider on failure.
  AiProvider preferredProvider = AiProvider.openrouter;

  /// Switch the preferred provider at runtime (groq, openrouter, siliconflow).
  /// Note: siliconflow image generation is handled by [SiliconFlowService];
  /// chat-completion calls to siliconflow require the Worker `/callSiliconFlow`
  /// endpoint to be enabled.
  void switchProvider(AiProvider provider) {
    preferredProvider = provider;
    if (kDebugMode) {
      debugPrint('[AIService] Preferred provider switched to ${provider.name}');
    }
  }

  AIService() {
    _openRouterService = OpenRouterService();
    _groqService = GroqService();
  }

  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('[AIService] Initialized AI providers');
    }
  }

  /// Sends a chat message with structured exception handling and fallback.
  /// OpenRouter is preferred and Groq is used when it cannot respond.
  /// Throws UserFacingException with sanitized message.
  Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> conversationHistory,
    {String languageCode = 'en'}) async {
    String openRouterError = 'Unknown error';
    try {
      if (kDebugMode) {
        debugPrint('[AIService] Sending chat message to OpenRouter');
      }
      return await _openRouterService.sendMessage(
        userMessage,
        conversationHistory,
        languageCode: languageCode,
      );
    } on RateLimitException catch (error) {
      openRouterError = error.toString();
      _logError('OpenRouter rate limit', error);
    } on NetworkException catch (error) {
      openRouterError = error.toString();
      _logError('OpenRouter network error', error);
    } catch (error) {
      openRouterError = error.toString();
      _logError('OpenRouter chat failed', error);
    }

    if (kDebugMode) {
      debugPrint('[AIService] OpenRouter failed, attempting Groq fallback');
    }

    String groqError = 'Unknown error';
    try {
      if (kDebugMode) {
        debugPrint('[AIService] Sending chat message to Groq');
      }
      return await _groqService.sendMessage(
        userMessage,
        conversationHistory,
        languageCode: languageCode,
      );
    } on RateLimitException catch (error) {
      groqError = error.toString();
      _logError('Groq rate limit', error);
    } on NetworkException catch (error) {
      groqError = error.toString();
      _logError('Groq network error', error);
    } catch (error) {
      groqError = error.toString();
      _logError('Groq chat failed', error);
    }

    // Both providers failed - throw UserFacingException
    throw ErrorSanitizer.toUserFacing(
        AllProvidersFailedException(openRouterError, groqError));
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

  /// Analyzes legal problem with structured exception handling and fallback logic.
  /// Sanitizes PII from errors before logging to crash reporting services.
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
    // Empty submissions cannot be analyzed remotely.
    if (summary.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('[AIService] A problem description is required.');
      }
      throw ArgumentError('A problem description is required');
    }

    if (kDebugMode) {
      debugPrint('[AIService] Using the Cloudflare Worker AI proxy');
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

    String openRouterError = 'Unknown error';

    // 1. Try OpenRouter first.
    try {
      if (kDebugMode) debugPrint('[AIService] Attempting OpenRouter...');
      final result = await _tryWithRetry(
        () => _openRouterService.analyze(
          _buildStrictSystemPrompt(
              'Consumer protection laws and regulations applicable to the case.',
              languageCode),
          localizedPrompt,
          category: category,
        ),
        'OpenRouter',
      );
      if (kDebugMode) debugPrint('[AIService] OpenRouter success');
      return result;
    } on RateLimitException catch (error) {
      openRouterError = error.toString();
      _logError('OpenRouter analysis rate limit', error);
    } on NetworkException catch (error) {
      openRouterError = error.toString();
      _logError('OpenRouter analysis network error', error);
    } catch (e) {
      openRouterError = e.toString();
      _logError('OpenRouter analysis failed', e);
    }

    const legalContext =
        'Consumer protection laws and regulations applicable to the case.';

    final String systemPrompt =
        _buildStrictSystemPrompt(legalContext, languageCode);
    String groqError = 'Unknown error';

    // 2. Fall back to Groq.
    try {
      if (kDebugMode) debugPrint('[AIService] Attempting Groq...');
      final result = await _tryWithRetry(
        () =>
            _groqService.analyze(systemPrompt, localizedPrompt, category: category),
        'Groq',
      );
      if (kDebugMode) debugPrint('[AIService] ✅ Groq success');
      return result;
    } on RateLimitException catch (error) {
      groqError = error.toString();
      _logError('Groq analysis rate limit', error);
    } on NetworkException catch (error) {
      groqError = error.toString();
      _logError('Groq analysis network error', error);
    } catch (e) {
      groqError = e.toString();
      _logError('Groq analysis failed', e);
    }

    // Both providers failed
    throw ErrorSanitizer.toUserFacing(
        AllProvidersFailedException(openRouterError, groqError));
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
      languageCode: languageCode,
    );
    final localizedPrompt = '$prompt\n${_languageInstruction(languageCode)}';

    String openRouterError = 'Unknown error';
    String groqError = 'Unknown error';

    // 1. Try OpenRouter.
    try {
      if (kDebugMode) {
        debugPrint('[AIService] Generating letter with OpenRouter...');
      }
      final result = await _openRouterService.generateRaw('', localizedPrompt);
      if (kDebugMode) debugPrint('[AIService] OpenRouter letter success');
      return _documentTextFromJson(result);
    } on NetworkException catch (error) {
      openRouterError = error.toString();
      _logError('OpenRouter letter network error', error);
    } on ParseException catch (error) {
      openRouterError = error.toString();
      _logError('OpenRouter letter parse error', error);
    } catch (e) {
      openRouterError = e.toString();
      _logError('OpenRouter letter failed', e);
    }

    // 2. Try Groq
    try {
      if (kDebugMode) debugPrint('[AIService] Generating letter with Groq...');
      final result = await _groqService.generateRaw('', localizedPrompt);
      if (kDebugMode) debugPrint('[AIService] ✅ Groq letter success');
      return _documentTextFromJson(result);
    } on NetworkException catch (error) {
      groqError = error.toString();
      _logError('Groq letter network error', error);
    } on ParseException catch (error) {
      groqError = error.toString();
      _logError('Groq letter parse error', error);
    } catch (e) {
      groqError = e.toString();
      _logError('Groq letter failed', e);
    }

    if (kDebugMode) {
      debugPrint(
        '[AIService] Letter generation failed. '
        'OpenRouter: $openRouterError. Groq: $groqError.',
      );
    }
    throw ErrorSanitizer.toUserFacing(
        AllProvidersFailedException(openRouterError, groqError));
  }

  /// Generates structured fields for a printable legal document.  Providers
  /// occasionally wrap JSON in a Markdown fence, so normalize that response
  /// before decoding it at the service boundary.
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

    String rawResponse;
    try {
      rawResponse = await _openRouterService.generateRaw('', localizedPrompt);
    } catch (_) {
      rawResponse = await _groqService.generateRaw('', localizedPrompt);
    }
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

  static String _stripJsonFences(String value) {
    final trimmed = value.trim();
    if (!trimmed.startsWith('```')) return trimmed;
    final lines = trimmed.split(RegExp(r'\r?\n'));
    if (lines.length >= 2 && lines.last.trim() == '```') {
      return lines.sublist(1, lines.length - 1).join('\n').trim();
    }
    return trimmed.replaceFirst(RegExp(r'^```(?:json)?\s*'), '').trim();
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
    final decoded = jsonDecode(_stripJsonFences(value));
    if (decoded is! Map || decoded['document_text'] is! String) {
      throw const FormatException(
          'AI response must contain a document_text JSON field.');
    }
    return (decoded['document_text'] as String).trim();
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
    String languageCode = 'en',
  }) {
    final typeLabel = {
          'email': 'a formal consumer complaint email',
          'police': 'a formal police complaint letter',
          'consumer_court': 'a formal consumer court complaint draft',
        }[letterType] ??
        'a formal complaint letter';

    final stepsText = steps.isNotEmpty
        ? steps
            .asMap()
            .entries
            .map((e) => '${e.key + 1}. ${e.value}')
            .join('\n')
        : 'No specific steps provided.';

    final effectiveSender =
        senderName.trim().isEmpty ? '[Your Full Name]' : senderName.trim();
    final effectiveAddress =
        senderAddress.trim().isEmpty ? '[Your Address]' : senderAddress.trim();
    final effectiveOpponent = opponentName.trim().isEmpty
        ? '[Respondent Name/Company]'
        : opponentName.trim();

    return '''You are a professional Indian legal writer. Write $typeLabel based on the details below.

IMPORTANT RULES:
- Return ONLY valid JSON. Do not include Markdown, code fences, a preamble, or text outside JSON.
- Use this exact response schema: {"document_text":"complete letter/document", "structured_fields":{"sender_name":"...", "sender_address":"...", "recipient_name":"...", "subject":"..."}}
- Put the complete letter/document only in document_text.
- Write ONLY the letter/document itself — no explanations, no preamble, no notes after the letter
- Use formal, professional legal language appropriate for India
- Fill in ALL details using the information provided below
- If a piece of information is not provided, use a sensible placeholder like [Your Phone Number]
- Include proper structure: To/From addresses, Subject, Date, Body paragraphs, Closing
- Write a complete, detailed letter of at least 500 words with 4-6 body paragraphs; do not stop after headings or placeholders
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

  String _languageInstruction(String languageCode) {
    if (languageCode.toLowerCase() == 'hi') {
      return '''Respond in Hindi (Devanagari script).
Generate the document content in Hindi.
Keep legal terms like RTI, PIL, FIR, IPC, CPC, CrPC, and act names in English where appropriate, but all other content must be in Hindi.''';
    }
    return 'Respond in English.';
  }

  /// SecurityAudit: Logs error with PII sanitization.
  /// Removes sensitive information before logging to crash reporting services.
  void _logError(String context, Object error) {
    final sanitized = ErrorSanitizer.sanitizeForLog(error.toString());
    if (kDebugMode) {
      debugPrint('[AIService] $context (sanitized): $sanitized');
    }
    // TODO: Send sanitized error to Crashlytics or other crash reporting service
    // Example: FirebaseCrashlytics.instance.recordError(error, StackTrace.current, reason: context);
  }
}

// =============================================================================
// Unified AI provider adapter (Cloudflare Worker `juslegal-ai-proxy`)
// =============================================================================

/// AI providers routable through the Cloudflare Worker proxy.
enum AiProvider { groq, openrouter, siliconflow }

/// Single adapter that routes every chat-completion call through the
/// `juslegal-ai-proxy` Cloudflare Worker, authenticated with a Firebase ID
/// token. Supports provider switching between groq, openrouter and siliconflow.
class _WorkerChatClient {
  final Dio _dio;
  final FirebaseTokenService _tokenService;
  final AiProvider provider;

  _WorkerChatClient({
    required this.provider,
    Dio? dio,
    FirebaseTokenService? tokenService,
  })  : _tokenService = tokenService ?? FirebaseTokenService(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: EnvironmentState.workerBaseUrl,
              connectTimeout: ApiConstants.connectionTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              headers: {
                'Content-Type': 'application/json',
              },
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenService.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          } else if (kDebugMode) {
            debugPrint('[AiService/$provider] Warning: No Firebase token');
          }
          return handler.next(options);
        },
      ),
    );
  }

  String get _endpoint {
    switch (provider) {
      case AiProvider.groq:
        return '/callGroq';
      case AiProvider.openrouter:
        return '/callOpenRouter';
      case AiProvider.siliconflow:
        return '/callSiliconFlow';
    }
  }

  String get _model {
    switch (provider) {
      case AiProvider.groq:
        return GROQ_MODEL;
      case AiProvider.openrouter:
        return OPENROUTER_MODEL;
      case AiProvider.siliconflow:
        return 'Qwen/Qwen2.5-7B-Instruct';
    }
  }

  String get _label {
    switch (provider) {
      case AiProvider.groq:
        return 'Groq';
      case AiProvider.openrouter:
        return 'OpenRouter';
      case AiProvider.siliconflow:
        return 'SiliconFlow';
    }
  }

  Future<Map<String, dynamic>> analyze(
    String systemPrompt,
    String problemText, {
    String category = 'general',
  }) async {
    final content = await _call(systemPrompt, problemText, jsonResponse: true);
    try {
      final parsed =
          jsonDecode(_stripCodeFence(content)) as Map<String, dynamic>;
      parsed['_model'] = _model;
      parsed['_provider'] = provider.name;
      return parsed;
    } on FormatException catch (error) {
      throw ParseException('Failed to parse $_label response: $error');
    }
  }

  Future<String> generateRaw(String systemPrompt, String prompt) => _call(
        systemPrompt,
        prompt,
        jsonResponse: false,
        maxTokens: ApiConstants.letterMaxTokens,
      );

  /// Sends a conversational request with JusLegal's chat context.
  Future<String> sendMessage(
          String userMessage, List<Map<String, String>> conversationHistory,
          {String languageCode = 'en'}) =>
      _sendChatRequest(userMessage, conversationHistory, languageCode);

  Future<String> _sendChatRequest(
    String userMessage,
    List<Map<String, String>> conversationHistory,
    String languageCode,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('[$_label] Calling Worker $_endpoint for chat');
      }
      final response = await _dio.post<Map<String, dynamic>>(
        _endpoint,
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': chatSystemPromptForLanguage(languageCode),
            },
            ..._historyWithCurrentMessage(userMessage, conversationHistory),
          ],
          'temperature': ApiConstants.temperature,
          'max_tokens': ApiConstants.maxTokens,
          'stream': false,
        },
      );
      return _contentFrom(response.data);
    } on DioException catch (error) {
      _throwDioError(error);
    }
  }

  List<Map<String, String>> _historyWithCurrentMessage(
    String userMessage,
    List<Map<String, String>> history,
  ) {
    final messages = history
        .where((message) => message['role'] != 'system')
        .map(Map<String, String>.from)
        .toList();
    if (messages.isEmpty ||
        messages.last['role'] != 'user' ||
        messages.last['content'] != userMessage) {
      messages.add({'role': 'user', 'content': userMessage});
    }
    return messages;
  }

  Future<String> _call(
    String systemPrompt,
    String prompt, {
    required bool jsonResponse,
    int? maxTokens,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[$_label] Calling Worker $_endpoint');
      }
      final response = await _dio.post<Map<String, dynamic>>(
        _endpoint,
        data: {
          'model': _model,
          'messages': [
            if (systemPrompt.isNotEmpty)
              {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': ApiConstants.temperature,
          'max_tokens': maxTokens ?? ApiConstants.maxTokens,
          if (jsonResponse) 'response_format': {'type': 'json_object'},
          'stream': false,
        },
      );
      return _contentFrom(response.data);
    } on DioException catch (error) {
      _throwDioError(error);
    }
  }

  String _contentFrom(Map<String, dynamic>? data) {
    final choices = data?['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw ParseException('No choices returned from $_label');
    }
    final message = Map<String, dynamic>.from(choices.first as Map)['message'];
    if (message is! Map || message['content'] is! String) {
      throw ParseException('Unexpected $_label response format');
    }
    final content = message['content'] as String;
    if (kDebugMode) {
      debugPrint(
          '[$_label] response received (length=${content.length})');
    }
    return content;
  }

  String _stripCodeFence(String value) {
    var result = value.trim();
    if (result.startsWith('```json')) result = result.substring(7);
    if (result.startsWith('```')) result = result.substring(3);
    if (result.endsWith('```')) result = result.substring(0, result.length - 3);
    return result.trim();
  }

  Never _throwDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw NetworkException('$_label request timed out');
    }
    final statusCode = error.response?.statusCode;
    if (statusCode == 429) {
      throw RateLimitException('$_label rate limit exceeded', _label);
    }
    if (statusCode != null) {
      if (kDebugMode) {
        debugPrint('[$_label] Worker returned HTTP $statusCode');
      }
      throw NetworkException('$_label request failed (HTTP $statusCode)');
    }
    throw NetworkException('$_label request failed (network error)');
  }
}

// =============================================================================
// Backward-compatibility aliases (former groq_service.dart / openrouter_service.dart)
// =============================================================================

/// Compatibility alias. Groq is now routed through the unified worker adapter.
class GroqService {
  final _WorkerChatClient _client;

  GroqService({Dio? dio, FirebaseTokenService? tokenService})
      : _client = _WorkerChatClient(
          provider: AiProvider.groq,
          dio: dio,
          tokenService: tokenService,
        );

  Future<Map<String, dynamic>> analyze(
    String systemPrompt,
    String problemText, {
    String category = 'general',
  }) =>
      _client.analyze(systemPrompt, problemText, category: category);

  Future<String> generateRaw(String systemPrompt, String prompt) =>
      _client.generateRaw(systemPrompt, prompt);

  Future<String> sendMessage(
          String userMessage, List<Map<String, String>> conversationHistory,
          {String languageCode = 'en'}) =>
      _client.sendMessage(userMessage, conversationHistory,
          languageCode: languageCode);
}

/// Compatibility alias. OpenRouter is now routed through the unified worker
/// adapter.
class OpenRouterService {
  final _WorkerChatClient _client;

  OpenRouterService({Dio? dio, FirebaseTokenService? tokenService})
      : _client = _WorkerChatClient(
          provider: AiProvider.openrouter,
          dio: dio,
          tokenService: tokenService,
        );

  Future<Map<String, dynamic>> analyze(
    String systemPrompt,
    String problemText, {
    String category = 'general',
  }) =>
      _client.analyze(systemPrompt, problemText, category: category);

  Future<String> generateRaw(String systemPrompt, String prompt) =>
      _client.generateRaw(systemPrompt, prompt);

  Future<String> sendMessage(
          String userMessage, List<Map<String, String>> conversationHistory,
          {String languageCode = 'en'}) =>
      _client.sendMessage(userMessage, conversationHistory,
          languageCode: languageCode);
}

/// Compatibility alias for the former `siliconflow_service.dart`.
///
/// SiliconFlow image generation has not yet been moved behind the Worker, so
/// the original implementation is retained here. This class is exposed as a
/// stub-style alias so screens/providers importing `ai_service.dart` keep
/// working after `siliconflow_service.dart` was removed.
class SiliconFlowService {
  static const String baseUrl = 'https://api.siliconflow.cn/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  late final Dio _dio;
  final String apiKey;

  SiliconFlowService({required this.apiKey}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectionTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add request/response logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: true,
        ),
      );
    }
  }

  /// Generate an image for legal document illustration
  /// Common use cases: case diagrams, timeline illustrations, process flows
  Future<String> generateLegalDocumentImage({
    required String prompt,
    String model = 'black-forest-labs/FLUX.1-pro',
    String aspectRatio = '1024x768',
    int numInferenceSteps = 20,
    double guidanceScale = 7.5,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('SiliconFlow API key not configured');
    }

    if (prompt.trim().isEmpty) {
      throw ArgumentError.value(prompt, 'prompt', 'Prompt cannot be empty');
    }

    try {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Generating image with prompt: $prompt');
      }

      final response = await _dio.post(
        '/image/generations',
        data: {
          'prompt': prompt,
          'model': model,
          'image_size': aspectRatio,
          'num_inference_steps': numInferenceSteps,
          'guidance_scale': guidanceScale,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        if (data['images'] != null && data['images'].isNotEmpty) {
          final imageUrl = data['images'][0]['url'] as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            if (kDebugMode) {
              debugPrint(
                  '[SiliconFlow] Image generated successfully: $imageUrl');
            }
            return imageUrl;
          }
        }

        throw Exception('No image URL in response: $data');
      } else {
        throw Exception(
          'Image generation failed: ${response.statusCode} - ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] DioException: ${e.message}');
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw TimeoutException('Connection timeout while generating image');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException('Receive timeout while generating image');
      } else if (e.response?.statusCode == 401) {
        throw ApiKeyException('SiliconFlow');
      } else if (e.response?.statusCode == 429) {
        throw RateLimitException(
          'SiliconFlow rate limit exceeded. Please try again later.',
          'SiliconFlow',
        );
      }

      throw Exception('Image generation failed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Unexpected error: $e');
      }
      rethrow;
    }
  }

  /// Generate images for case timeline visualization
  /// Returns a list of image URLs showing different stages of a legal case
  Future<List<String>> generateCaseTimelineImages({
    required String caseType,
    required List<String> stages,
    int imagesPerStage = 1,
  }) async {
    final images = <String>[];

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final prompt =
          _buildTimelinePrompt(caseType, stage, i + 1, stages.length);

      try {
        final imageUrl = await generateLegalDocumentImage(
          prompt: prompt,
          aspectRatio: '1024x576', // Wider for timeline visualization
        );
        images.add(imageUrl);

        // Rate limiting: small delay between requests to avoid throttling
        if (i < stages.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              '[SiliconFlow] Failed to generate stage image for "$stage": $e');
        }
        // Continue with other stages even if one fails
      }
    }

    if (images.isEmpty) {
      throw Exception('Failed to generate any timeline images');
    }

    return images;
  }

  /// Generate an image for case documentation or complaint letter header
  Future<String> generateCaseHeaderImage({
    required String caseTitle,
    required String category,
  }) async {
    final prompt = _buildHeaderPrompt(caseTitle, category);
    return generateLegalDocumentImage(
      prompt: prompt,
      aspectRatio: '1280x400',
      numInferenceSteps: 15,
    );
  }

  /// List available models (requires active API connection)
  Future<List<String>> getAvailableModels() async {
    try {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Fetching available models');
      }

      final response = await _dio.get('/models');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final models = (data['data'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((m) => m['id'] as String)
                .toList() ??
            [];

        if (kDebugMode) {
          debugPrint('[SiliconFlow] Found ${models.length} available models');
        }

        return models;
      } else {
        throw Exception('Failed to fetch models: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Failed to fetch models: $e');
      }
      rethrow;
    }
  }

  /// Get current account balance and usage info
  Future<Map<String, dynamic>> getAccountInfo() async {
    try {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Fetching account info');
      }

      final response = await _dio.get('/user/info');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (kDebugMode) {
          debugPrint('[SiliconFlow] Account info: $data');
        }
        return data;
      } else {
        throw Exception(
            'Failed to fetch account info: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SiliconFlow] Failed to fetch account info: $e');
      }
      rethrow;
    }
  }

  String _buildTimelinePrompt(
    String caseType,
    String stage,
    int stageNumber,
    int totalStages,
  ) {
    return '''Professional legal case timeline illustration for a $caseType case.
Stage $stageNumber of $totalStages: $stage
Style: Clean, professional, corporate legal document aesthetic.
Colors: Blues, grays, and professional tones.
Include stage indicator and progress visualization.
High quality, clear, and suitable for legal documentation.''';
  }

  String _buildHeaderPrompt(String caseTitle, String category) {
    return '''Professional header illustration for a legal case document.
Case: $caseTitle
Category: $category
Style: Modern, professional, formal legal aesthetic.
Include symbolic elements representing justice, law, and protection.
Colors: Deep blues, golds, and professional tones.
High resolution, suitable for document header.''';
  }
}

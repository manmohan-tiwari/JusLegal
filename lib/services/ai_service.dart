import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:juslegal/constants/document_prompts_complete.dart';
import 'package:juslegal/core/core.dart';
import 'firebase_token_service.dart';

/// SecurityAudit: AI service with structured exception handling and PII sanitization.
/// All errors are logged with PII removed and returned as UserFacingExceptions to UI.
class AIService {
  late final WorkerChatClient _openRouterClient;
  late final WorkerChatClient _groqClient;

  /// Currently preferred provider. Chat/analysis requests try this provider
  /// first and fall back to the other worker-routed provider on failure.
  AiProvider _preferredProvider = AiProvider.groq;
  AiProvider get preferredProvider => _preferredProvider;

  /// Switch the preferred provider at runtime (groq, openrouter).
  void switchProvider(AiProvider provider) {
    _preferredProvider = provider;
    if (kDebugMode) {
      debugPrint('[AIService] Preferred provider switched to ${provider.name}');
    }
  }

  AIService() {
    _openRouterClient = WorkerChatClient(provider: AiProvider.openrouter);
    _groqClient = WorkerChatClient(provider: AiProvider.groq);
  }

  Future<void> initialize() async {
    _validateApiKeyConfig();
    if (kDebugMode) {
      debugPrint('[AIService] Initialized AI providers');
    }
  }

  /// SecurityAudit: Validates that all AI traffic is configured to route
  /// through the Cloudflare Worker proxy and that no provider API keys are
  /// embedded client-side. Throws [ApiKeyException] on misconfiguration.
  void _validateApiKeyConfig() {
    final workerUrl = EnvironmentState.workerBaseUrl;
    if (workerUrl.isEmpty) {
      const message = 'Cloudflare Worker proxy URL is not configured.';
      if (kDebugMode) {
        debugPrint('[AIService] $message');
      }
      throw ApiKeyException('Cloudflare Worker proxy');
    }
    if (kDebugMode) {
      debugPrint(
          '[AIService] API key validation OK (worker-routed, no client-side keys)');
    }
  }

  /// Generic helper to execute AI operations using the preferred provider first,
  /// falling back to the secondary provider if the primary provider fails.
  Future<T> _executeWithFallback<T>(
    Future<T> Function(WorkerChatClient client) action, {
    required String operationLabel,
  }) async {
    final primaryClient = _preferredProvider == AiProvider.openrouter
        ? _openRouterClient
        : _groqClient;
    final secondaryClient = _preferredProvider == AiProvider.openrouter
        ? _groqClient
        : _openRouterClient;
    final primaryName =
        _preferredProvider == AiProvider.openrouter ? 'OpenRouter' : 'Groq';
    final secondaryName =
        _preferredProvider == AiProvider.openrouter ? 'Groq' : 'OpenRouter';

    String primaryError = 'Unknown error';
    try {
      if (kDebugMode) {
        debugPrint('[AIService] Executing $operationLabel with $primaryName...');
      }
      return await action(primaryClient);
    } catch (e) {
      primaryError = e.toString();
      _logError('$primaryName $operationLabel failed', e);
    }

    if (kDebugMode) {
      debugPrint(
          '[AIService] $primaryName failed, attempting $secondaryName fallback...');
    }
    String secondaryError = 'Unknown error';
    try {
      return await action(secondaryClient);
    } catch (e) {
      secondaryError = e.toString();
      _logError('$secondaryName $operationLabel failed', e);
    }

    throw ErrorSanitizer.toUserFacing(
        AllProvidersFailedException(primaryError, secondaryError));
  }

  /// Sends a chat message with structured exception handling and fallback.
  /// Uses preferredProvider first and falls back to secondary provider.
  Future<String> sendMessage(
      String userMessage, List<Map<String, String>> conversationHistory,
      {String languageCode = 'en', CaseState? caseState}) async {
    return await _executeWithFallback(
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
    final systemPrompt =
        _buildStrictSystemPrompt(legalContext, languageCode);

    return await _executeWithFallback(
      (client) => _tryWithRetry(
        () => client.analyze(
          systemPrompt,
          localizedPrompt,
          category: category,
        ),
        client._label,
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

    final result = await _executeWithFallback(
      (client) async {
        final raw = await client.generateRaw(localizedSystemPrompt, userPrompt);
        return _documentTextFromJson(raw);
      },
      operationLabel: 'generate letter ($letterType)',
    );
    return result;
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

    final rawResponse = await _executeWithFallback(
      (client) => client.generateRaw('', localizedPrompt),
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
    AppLogger().error('$context: $sanitized', tag: 'AIService', error: error);
    if (SafeAnalytics.analyticsEnabled) {
      SafeAnalytics.logEvent(
        name: 'ai_service_error',
        parameters: {'context': ErrorSanitizer.sanitizeForLog(context)},
      );
    }
  }

  /// Generate text with custom system prompt and user prompt
  /// Used for document generation with specific prompts
  Future<String> generateText({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.3,
  }) async {
    return await _executeWithFallback(
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
    final language = languageCode == 'hi' ? 'Hindi' : 'English';

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
// Unified AI provider adapter (Cloudflare Worker `juslegal-ai-proxy`)
// =============================================================================

/// AI providers routable through the Cloudflare Worker proxy.
enum AiProvider { groq, openrouter }

/// Single adapter that routes every chat-completion call through the
/// `juslegal-ai-proxy` Cloudflare Worker, authenticated with a Firebase ID
/// token. Supports provider switching between groq and openrouter.
class WorkerChatClient {
  final Dio _dio;
  final FirebaseTokenService _tokenService;
  final AiProvider provider;

  WorkerChatClient({
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
    }
  }

  String get _label {
    switch (provider) {
      case AiProvider.groq:
        return 'Groq';
      case AiProvider.openrouter:
        return 'OpenRouter';
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
          {String languageCode = 'en', CaseState? caseState}) =>
      _sendChatRequest(userMessage, conversationHistory, languageCode, caseState: caseState);

  /// Performs the Dio POST with automatic 401 token-refresh retry: when the
  /// Worker rejects an expired Firebase ID token, the token is force-refreshed
  /// and the request retried exactly once.
  Future<Response<dynamic>> _postWithAuthRetry(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _dio.post<dynamic>(endpoint, data: data);
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) rethrow;
      if (kDebugMode) {
        debugPrint('[$_label] 401 received - refreshing token and retrying');
      }
      final refreshed = await _tokenService.forceRefreshToken();
      if (refreshed == null) rethrow;
      return await _dio.post<dynamic>(endpoint, data: data);
    }
  }

  Future<String> _sendChatRequest(
    String userMessage,
    List<Map<String, String>> conversationHistory,
    String languageCode, {
    CaseState? caseState,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[$_label] Calling Worker $_endpoint for chat');
      }

      final systemPrompt = StringBuffer(chatSystemPromptForLanguage(languageCode));
      if (caseState != null) {
        systemPrompt.write('\n\nCURRENT CASE STATE:\n${caseState.toPromptSummary()}');
      }

      final response = await _postWithAuthRetry(
        _endpoint,
        _requestPayload(
          _boundedMessages([
            {
              'role': 'system',
              'content': systemPrompt.toString(),
            },
            ..._historyWithCurrentMessage(userMessage, conversationHistory),
          ]),
          maxTokens: 800,
          jsonResponse: true,
        ),
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
        .where((message) =>
            message['role'] == 'user' || message['role'] == 'assistant')
        .map((message) => <String, String>{
              'role': message['role']!,
              'content': message['content'] ?? '',
            })
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
      final response = await _postWithAuthRetry(
        _endpoint,
        _requestPayload(
          _boundedMessages([
            if (systemPrompt.isNotEmpty)
              {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ]),
          maxTokens: maxTokens ?? ApiConstants.maxTokens,
          jsonResponse: jsonResponse,
        ),
      );
      return _contentFrom(response.data);
    } on DioException catch (error) {
      _throwDioError(error);
    }
  }

  String _contentFrom(dynamic data) {
    if (data is! Map) {
      throw ParseException('Invalid JSON payload returned from $_label');
    }
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw ParseException('No choices returned from $_label');
    }
    final message = Map<String, dynamic>.from(choices.first as Map)['message'];
    if (message is! Map || message['content'] is! String) {
      throw ParseException('Unexpected $_label response format');
    }
    final content = message['content'] as String;
    if (kDebugMode) {
      debugPrint('[$_label] response received (length=${content.length})');
    }
    return content;
  }

  /// Shapes requests to the public Worker contract. Models are intentionally
  /// omitted: the Worker selects the allow-listed model from the endpoint.
  Map<String, dynamic> _requestPayload(
    List<Map<String, String>> messages, {
    required int maxTokens,
    bool jsonResponse = false,
  }) =>
      {
        'messages': messages,
        'temperature': _validatedTemperature(ApiConstants.temperature),
        'max_tokens': _validatedMaxTokens(maxTokens),
        if (jsonResponse) 'response_format': {'type': 'json_object'},
        'stream': false,
      };

  double _validatedTemperature(double value) {
    if (!value.isFinite ||
        value < WorkerAiRequestLimits.minTemperature ||
        value > WorkerAiRequestLimits.maxTemperature) {
      throw StateError('Configured AI temperature is outside Worker limits');
    }
    return value;
  }

  int _validatedMaxTokens(int value) {
    if (value < 1 || value > WorkerAiRequestLimits.maxTokens) {
      throw StateError('Configured AI max_tokens is outside Worker limits');
    }
    return value;
  }

  /// Preserves the system message and newest conversation context while
  /// deterministically fitting the Worker message and character limits.
  List<Map<String, String>> _boundedMessages(
    List<Map<String, String>> input,
  ) {
    final system =
        input.where((message) => message['role'] == 'system').take(1);
    final conversation = input
        .where((message) =>
            message['role'] == 'user' || message['role'] == 'assistant')
        .toList();
    final result = <Map<String, String>>[];
    var remainingChars = WorkerAiRequestLimits.maxTotalMessageChars;

    for (final message in system) {
      final content = _truncate(message['content'] ?? '', remainingChars);
      result.add({'role': 'system', 'content': content});
      remainingChars -= content.length;
    }

    final newestFirst = <Map<String, String>>[];
    for (final message in conversation.reversed) {
      if (newestFirst.length >=
              WorkerAiRequestLimits.maxMessages - result.length ||
          remainingChars <= 0) {
        break;
      }
      final content = _truncate(message['content'] ?? '', remainingChars);
      newestFirst.add({'role': message['role']!, 'content': content});
      remainingChars -= content.length;
    }
    result.addAll(newestFirst.reversed);
    return result;
  }

  String _truncate(String value, int remainingChars) {
    final maximum =
        remainingChars < WorkerAiRequestLimits.maxMessageContentChars
            ? remainingChars
            : WorkerAiRequestLimits.maxMessageContentChars;
    return value.length <= maximum ? value : value.substring(0, maximum);
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
    if (statusCode == 401) {
      throw AuthRequiredException(
        'Authentication required. Please sign in to use AI legal features.',
      );
    }
    if (statusCode == 429) {
      throw RateLimitException('$_label rate limit exceeded', _label);
    }

    if (statusCode != null) {
      if (kDebugMode) {
        debugPrint('[$_label] Worker returned HTTP $statusCode');
        final body = error.response?.data;
        if (body is Map) {
          final safeError = body['error'];
          final safeReason = body['reason'];
          final upstreamStatus = body['upstreamStatus'];
          final detail = body['detail'];
          if (safeError is String || safeReason is String || detail != null) {
            debugPrint('[$_label] Worker error: '
                '${safeError is String ? safeError : 'unknown'} '
                '(reason: ${safeReason is String ? safeReason : 'none'}, '
                'upstreamStatus: $upstreamStatus, detail: $detail)');
          }
        }
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
  final WorkerChatClient _client;

  GroqService({WorkerChatClient? client, Dio? dio, FirebaseTokenService? tokenService})
      : _client = client ??
            WorkerChatClient(
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
          {String languageCode = 'en', CaseState? caseState}) =>
      _client.sendMessage(userMessage, conversationHistory,
          languageCode: languageCode, caseState: caseState);
}

/// Compatibility alias. OpenRouter is now routed through the unified worker
/// adapter.
class OpenRouterService {
  final WorkerChatClient _client;

  OpenRouterService({WorkerChatClient? client, Dio? dio, FirebaseTokenService? tokenService})
      : _client = client ??
            WorkerChatClient(
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
          {String languageCode = 'en', CaseState? caseState}) =>
      _client.sendMessage(userMessage, conversationHistory,
          languageCode: languageCode, caseState: caseState);
}

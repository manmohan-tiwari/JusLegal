import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/categories.dart';
import '../core/exceptions/ai_exceptions.dart';
import 'groq_service.dart';
import 'openrouter_service.dart';

class AIService {
  late final OpenRouterService _openRouterService;
  late final GroqService _groqService;

  AIService() {
    _openRouterService = OpenRouterService();
    _groqService = GroqService();
  }

  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('[AIService] Initialized AI providers');
    }
  }

  /// Sends a chat message, preserving the local conversation context.
  /// OpenRouter is preferred and Groq is used when it cannot respond.
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
    } catch (error) {
      openRouterError = error.toString();
      if (kDebugMode) {
        debugPrint('[AIService] OpenRouter chat failed: $error');
      }
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
    } catch (error) {
      groqError = error.toString();
      if (kDebugMode) {
        debugPrint('[AIService] Groq chat failed: $error');
      }
    }
    throw AllProvidersFailedException(openRouterError, groqError);
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
      throw ArgumentError.value(
        summary,
        'summary',
        'A problem description is required.',
      );
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
    } catch (e) {
      openRouterError = e.toString();
      if (kDebugMode) debugPrint('[AIService] OpenRouter failed: $e');
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
    } catch (e) {
      groqError = e.toString();
      if (kDebugMode) debugPrint('[AIService] Groq failed: $e');
    }

    throw AllProvidersFailedException(openRouterError, groqError);
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
    } catch (e) {
      openRouterError = e.toString();
      if (kDebugMode) debugPrint('[AIService] OpenRouter letter failed: $e');
    }

    // 2. Try Groq
    try {
      if (kDebugMode) debugPrint('[AIService] Generating letter with Groq...');
      final result = await _groqService.generateRaw('', localizedPrompt);
      if (kDebugMode) debugPrint('[AIService] ✅ Groq letter success');
      return _documentTextFromJson(result);
    } catch (e) {
      groqError = e.toString();
      if (kDebugMode) debugPrint('[AIService] Groq letter failed: $e');
    }

    if (kDebugMode) {
      debugPrint(
        '[AIService] Letter generation failed. '
        'OpenRouter: $openRouterError. Groq: $groqError.',
      );
    }
    throw AllProvidersFailedException(openRouterError, groqError);
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
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/config/app_config.dart';
import '../core/exceptions/ai_exceptions.dart';
import '../core/services/analytics_service.dart';
import '../core/utils/app_logger.dart';
import '../models/chat_message_model.dart';
import '../models/legal_result_model.dart';
import '../models/problem_model.dart';
import '../services/ai_service.dart';
import '../services/firebase_token_service.dart';
import '../services/storage_service.dart';
import 'locale_provider.dart';

// ignore_for_file: constant_identifier_names

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
const int MIN_CONFIDENCE_SCORE = 1;
const int MAX_CONFIDENCE_SCORE = 10;
const int CHAT_HISTORY_LIMIT = 100;
const int API_CONTEXT_WINDOW = 6;
const Duration CHAT_DEBOUNCE_DELAY = Duration(milliseconds: 500);
const String kChatHistoryBox = 'chat_history';

// Provider for AIService instance
final aiServiceProvider = Provider<AIService>((ref) => AIService());

// ---------------------------------------------------------------------------
// Cancellation token: used to cancel in-flight chat requests when a newer
// message is sent or the notifier is disposed.
// ---------------------------------------------------------------------------
class RequestToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

// ---------------------------------------------------------------------------
// Chat state
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Chat state
// ---------------------------------------------------------------------------
class ChatState {
  final List<ChatMessage> conversationHistory;
  final CaseState caseState;
  final bool isSending;
  final String? error;

  const ChatState({
    this.conversationHistory = const [],
    this.caseState = const CaseState(),
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? conversationHistory,
    CaseState? caseState,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) =>
      ChatState(
        conversationHistory: conversationHistory ?? this.conversationHistory,
        caseState: caseState ?? this.caseState,
        isSending: isSending ?? this.isSending,
        error: clearError ? null : error ?? this.error,
      );
}

/// Chat state backed by Hive persistence. Resets only when history is
/// explicitly cleared; survives app restarts (last [CHAT_HISTORY_LIMIT]
/// messages).
class ChatNotifier extends Notifier<ChatState> {
  RequestToken? _activeRequest;
  Timer? _debounceTimer;

  @override
  ChatState build() {
    ref.onDispose(_cancelPendingRequest);
    _loadPersistedHistory();
    return const ChatState();
  }

  List<ChatMessage> getHistory() => state.conversationHistory;

  /// Cancels any pending debounced send and the in-flight network request.
  /// Registered with `ref.onDispose` for automatic cleanup.
  void _cancelPendingRequest() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _activeRequest?.cancel();
    _activeRequest = null;
    AppLogger.debug('ChatNotifier', 'Pending chat requests cancelled');
  }

  /// Public hook so the UI can cancel the in-flight request (user_cancelled).
  void cancelCurrentRequest() {
    _debounceTimer?.cancel();
    if (_activeRequest != null) {
      _activeRequest!.cancel();
      _activeRequest = null;
      state = state.copyWith(isSending: false);
      SafeAnalytics.logEvent(name: 'user_cancelled', parameters: {
        'context': 'chat',
      });
      AppLogger.info('ChatNotifier', 'User cancelled in-flight chat request');
    }
  }

  Future<void> _loadPersistedHistory() async {
    try {
      if (!Hive.isBoxOpen(kChatHistoryBox)) {
        await StorageService().openEncryptedBox<dynamic>(kChatHistoryBox);
      }
      final box = Hive.box(kChatHistoryBox);
      final raw = box.get('messages');
      if (raw is! List) return;
      final messages = raw
          .whereType<Map>()
          .map((map) => ChatMessage.fromMap(Map<dynamic, dynamic>.from(map)))
          .toList();
      if (messages.isEmpty || state.conversationHistory.isNotEmpty) return;

      // Extract last case state if available
      CaseState restoredCaseState = const CaseState();
      for (final msg in messages.reversed) {
        if (msg.caseState != null) {
          restoredCaseState = msg.caseState!;
          break;
        }
      }

      state = state.copyWith(
        conversationHistory: List.unmodifiable(messages),
        caseState: restoredCaseState,
      );
      AppLogger.debug('ChatNotifier',
          'Restored ${messages.length} persisted chat messages');
    } catch (error) {
      AppLogger.warning(
          'ChatNotifier', 'Failed to restore chat history: $error');
    }
  }

  Future<void> _persistHistory(List<ChatMessage> messages) async {
    try {
      if (!Hive.isBoxOpen(kChatHistoryBox)) {
        await StorageService().openEncryptedBox<dynamic>(kChatHistoryBox);
      }
      await Hive.box(kChatHistoryBox)
          .put('messages', messages.map((m) => m.toMap()).toList());
    } catch (error) {
      AppLogger.warning(
          'ChatNotifier', 'Failed to persist chat history: $error');
    }
  }

  void addMessageObject(ChatMessage message) {
    final updated = List<ChatMessage>.from(state.conversationHistory)..add(message);
    final limited = updated.length > CHAT_HISTORY_LIMIT
        ? updated.sublist(updated.length - CHAT_HISTORY_LIMIT)
        : updated;

    final updatedCaseState = message.caseState ?? state.caseState;

    state = state.copyWith(
      conversationHistory: List.unmodifiable(limited),
      caseState: updatedCaseState,
      clearError: true,
    );
    _persistHistory(limited);
  }

  /// Adds a message and trims history to [CHAT_HISTORY_LIMIT] entries.
  void addMessage(String role, String content) {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) return;
    final message = role == 'assistant'
        ? ChatMessage.fromAiResponse(
            trimmedContent,
            timestamp: DateTime.now(),
            currentCaseState: state.caseState,
          )
        : ChatMessage(
            role: role,
            content: trimmedContent,
            timestamp: DateTime.now(),
          );
    addMessageObject(message);
  }

  /// Debounced send: restarts a [CHAT_DEBOUNCE_DELAY] timer on each call so
  /// rapid taps only trigger a single network request.
  Future<void> sendUserMessageDebounced(String userMessage) {
    final completer = Completer<void>();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(CHAT_DEBOUNCE_DELAY, () async {
      try {
        await sendUserMessage(userMessage);
        completer.complete();
      } catch (error) {
        completer.completeError(error);
      }
    });
    return completer.future;
  }

  /// Sends a user message. Errors are captured into state.error (never
  /// rethrown) so the UI can consume [chatProvider].error directly.
  Future<void> sendUserMessage(String userMessage) async {
    final trimmedMessage = userMessage.trim();
    if (trimmedMessage.isEmpty || state.isSending) return;

    // Race-condition guard: cancel any previous in-flight request.
    _activeRequest?.cancel();
    final token = RequestToken();
    _activeRequest = token;

    // Combine history update + sending flag into a minimal set of emissions.
    addMessage('user', trimmedMessage);
    state = state.copyWith(isSending: true, clearError: true);

    // Sliding window: send only the last API_CONTEXT_WINDOW messages.
    final history = state.conversationHistory;
    final start = history.length > API_CONTEXT_WINDOW
        ? history.length - API_CONTEXT_WINDOW
        : 0;
    final messagesForApi = history
        .skip(start)
        .map((message) => message.toApiMap())
        .toList(growable: false);
    final tokenUsageEstimate = (messagesForApi.fold<int>(
              0,
              (sum, message) => sum + (message['content']?.length ?? 0),
            ) /
            4)
        .ceil();

    try {
      final response = await ref.read(aiServiceProvider).sendMessage(
            trimmedMessage,
            messagesForApi,
            languageCode: ref.read(localeProvider).languageCode,
            caseState: state.caseState,
          );
      _activeRequest = null;
      if (token.isCancelled) {
        AppLogger.info('ChatNotifier',
            'Request completed after cancellation; discarding response');
        return;
      }
      final assistantMessage = ChatMessage.fromAiResponse(
        response,
        timestamp: DateTime.now(),
        currentCaseState: state.caseState,
      );
      addMessageObject(assistantMessage);
      state = state.copyWith(isSending: false, clearError: true);
      SafeAnalytics.logEvent(name: 'token_usage', parameters: {
        'context': 'chat',
        'estimated_tokens': tokenUsageEstimate,
      });
    } catch (error) {
      _activeRequest = null;
      // Do not surface errors for superseded/cancelled requests.
      if (token.isCancelled) {
        AppLogger.info('ChatNotifier', 'Cancelled request failed silently');
        return;
      }
      state = state.copyWith(
        isSending: false,
        error: _friendlyError(error),
      );
      // Errors intentionally NOT rethrown: UI consumes state.error.
    }
  }

  void clearHistory() {
    _cancelPendingRequest();
    state = const ChatState();
    try {
      if (Hive.isBoxOpen(kChatHistoryBox)) {
        Hive.box(kChatHistoryBox).delete('messages');
      }
    } catch (error) {
      AppLogger.warning('ChatNotifier', 'Failed to clear chat history: $error');
    }
  }

  String _friendlyError(Object error) {
    final languageCode = ref.read(localeProvider).languageCode;
    if (error is AllProvidersFailedException) {
      return AppStrings.chatErrorMessage('serviceUnavailable', languageCode);
    }
    if (error is NetworkException) {
      return AppStrings.chatErrorMessage('network', languageCode);
    }
    return AppStrings.chatErrorMessage('generic', languageCode);
  }
}

final chatProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

// Select-style convenience providers to reduce unnecessary rebuilds.
final conversationLengthProvider = Provider<int>((ref) {
  return ref.watch(
      chatProvider.select((state) => state.conversationHistory.length));
});

final chatSendingProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider.select((state) => state.isSending));
});

final chatErrorProvider = Provider<String?>((ref) {
  return ref.watch(chatProvider.select((state) => state.error));
});

// ---------------------------------------------------------------------------
// Analysis state
// ---------------------------------------------------------------------------
class AnalysisState {
  final AsyncValue<LegalResultModel>? result;
  final String? error;

  /// Overall AI processing progress from 0.0 to 1.0 (nullable = indeterminate).
  final double? progress;

  AnalysisState({this.result, this.error, this.progress});

  AnalysisState copyWith({
    AsyncValue<LegalResultModel>? result,
    String? error,
    double? progress,
    bool clearError = false,
    bool clearProgress = false,
  }) {
    return AnalysisState(
      result: result ?? this.result,
      error: clearError ? null : error ?? this.error,
      progress: clearProgress ? null : progress ?? this.progress,
    );
  }
}

// AsyncNotifier for analysis state management
class AnalysisNotifier extends AsyncNotifier<AnalysisState> {
  late final AIService _aiService;
  final FirebaseTokenService _tokenService = FirebaseTokenService();

  @override
  AnalysisState build() {
    _aiService = ref.read(aiServiceProvider);
    return AnalysisState();
  }

  void _setProgress(double progress, String step) {
    AppLogger.debug('AnalysisNotifier',
        'progress=${(progress * 100).toStringAsFixed(0)}% ($step)');
    state = AsyncValue.data(state.value?.copyWith(progress: progress) ??
        AnalysisState(progress: progress));
  }

  /// Estimates token usage (~4 chars per token) for analytics.
  static int _estimateTokens(List<String> texts) {
    final characters = texts.fold<int>(0, (sum, text) => sum + text.length);
    return (characters / 4).ceil();
  }

  Future<LegalResultModel> analyze(ProblemModel problem) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (problem.summary.trim().isEmpty) {
        final error = ArgumentError(AppStrings.errorProblemEmpty);
        state = AsyncValue.error(error, StackTrace.current);
        throw error;
      }

      state = const AsyncValue.loading();
      _setProgress(0.05, 'starting');

      AppLogger.info('AnalysisNotifier',
          'analysis started (category=${problem.category}, problemLength=${problem.summary.trim().length})');

      // Log analysis started event using SafeAnalytics
      await SafeAnalytics.logEvent(
        name: AppStrings.eventAnalysisStarted,
        parameters: {
          'category': problem.category,
          'problem_length': problem.summary.length,
        },
      );

      // Initialize AI service (validates worker-only API key configuration)
      await _aiService.initialize();
      _setProgress(0.15, 'service_initialized');

      // Analyze the problem using updated method
      final analysisResult = await _aiService.analyze(
        category: problem.category,
        dateOfIncident: problem.dateOfIncident,
        disputedAmount: problem.disputedAmount,
        involvedParty: problem.involvedParty,
        referenceNumber: problem.referenceNumber,
        summary: problem.summary,
        attachedFiles: problem.attachedFiles,
        dynamicFieldValues: problem.dynamicFieldValues,
        languageCode: ref.read(localeProvider).languageCode,
      );
      _setProgress(0.65, 'provider_response_received');

      AppLogger.info('AnalysisNotifier',
          'provider response received (fieldCount=${analysisResult.length})');

      await SafeAnalytics.logEvent(name: 'token_usage', parameters: {
        'context': 'analysis',
        'estimated_tokens': _estimateTokens([
          problem.summary,
          ...analysisResult.values.map((value) => value.toString()),
        ]),
      });

      // Convert Map to LegalResultModel
      final legalResult = _mapToLegalResultModel(analysisResult);
      _setProgress(0.9, 'response_parsed');

      AppLogger.info('AnalysisNotifier',
          'analysis response parsed (confidence=${legalResult.confidence})');

      // Update both new and old providers
      ref.read(lastResultProvider.notifier).set(legalResult);

      // Log analysis completed event with duration
      stopwatch.stop();
      await SafeAnalytics.logEvent(
        name: AppStrings.eventAnalysisCompleted,
        parameters: {
          'category': problem.category,
          'confidence': legalResult.confidence,
          'analysis_duration_ms': stopwatch.elapsedMilliseconds,
        },
      );

      state = AsyncValue.data(AnalysisState(
        result: AsyncValue.data(legalResult),
        progress: 1.0,
      ));

      return legalResult;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.error('AnalysisNotifier',
          'analysis failed (category=${e.runtimeType}) after ${stopwatch.elapsedMilliseconds}ms',
          e);

      // Log analysis error event with duration and sanitized stack reference
      await SafeAnalytics.logEvent(
        name: AppStrings.eventAnalysisError,
        parameters: {
          'category': problem.category,
          'error_type': e.runtimeType.toString(),
          'analysis_duration_ms': stopwatch.elapsedMilliseconds,
          'error_stack': stack.toString().split('\n').take(5).join(' | '),
        },
      );

      String errorMessage = _getErrorMessage(e);
      state = AsyncValue.data(AnalysisState(error: errorMessage));
      rethrow;
    }
  }

  /// Retries the analysis once when a 401 indicates an expired Firebase ID
  /// token. Forces a token refresh and logs the attempt to analytics.
  Future<LegalResultModel> analyzeWithTokenRetry(ProblemModel problem) async {
    try {
      return await analyze(problem);
    } catch (error) {
      final message = error.toString();
      final unauthorized =
          message.contains('HTTP 401') || message.contains('401');
      if (!unauthorized) rethrow;

      AppLogger.warning(
          'AnalysisNotifier', '401 received - attempting token refresh retry');
      await SafeAnalytics.logEvent(name: 'token_refresh', parameters: {
        'context': 'analysis',
        'reason': 'unauthorized',
      });

      final refreshedToken = await _tokenService.forceRefreshToken();
      if (refreshedToken == null) rethrow;

      // Retry exactly once with the refreshed token.
      return analyze(problem);
    }
  }

  LegalResultModel _mapToLegalResultModel(Map<String, dynamic> data) {
    AppLogger.debug('AnalysisNotifier',
        'mapping provider response (fieldCount=${data.length})');
    final normalizer = AnalysisPayloadNormalizer();
    return normalizer.toLegalResultModel(normalizer.normalize(data));
  }

  String _getErrorMessage(dynamic error) {
    if (error is AllProvidersFailedException) {
      return AppStrings.errServiceUnavailable;
    } else if (error is NetworkException) {
      return AppStrings.errNoInternet;
    } else if (error is RateLimitException) {
      return AppStrings.errTooManyRequests;
    } else if (error is ApiKeyException) {
      return AppStrings.errConfigError;
    } else if (error is ParseException) {
      return AppStrings.errParseError;
    } else if (error is Exception) {
      // Handle generic exceptions from AI service
      final message = error.toString();
      if (message.contains('unavailable') || message.contains('temporarily')) {
        return AppStrings.errServiceUnavailable;
      } else if (message.contains('network') ||
          message.contains('connection')) {
        return AppStrings.errNoInternet;
      } else if (message.contains('API key') ||
          message.contains('configured')) {
        return AppStrings.errConfigError;
      } else {
        return AppStrings.errGenericError;
      }
    } else {
      return AppStrings.errGenericError;
    }
  }

  void reset() {
    state = AsyncValue.data(AnalysisState());
  }
}

// Provider for the analysis notifier
final analysisProvider =
    AsyncNotifierProvider<AnalysisNotifier, AnalysisState>(() {
  return AnalysisNotifier();
});

// Convenience provider to watch only the result
final analysisResultProvider = Provider<AsyncValue<LegalResultModel>?>((ref) {
  final analysisState = ref.watch(analysisProvider);
  return analysisState.when(
    data: (state) => state.result,
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Convenience provider to watch loading state
final analysisLoadingProvider = Provider<bool>((ref) {
  return ref.watch(analysisProvider).isLoading;
});

// Provider for analysis error
final analysisErrorProvider = Provider<String?>((ref) {
  final analysisState = ref.watch(analysisProvider);
  return analysisState.maybeWhen(
    data: (state) => state.error,
    error: (err, _) => err.toString(),
    orElse: () => null,
  );
});

// Provider for analysis progress (0.0 - 1.0, null = indeterminate)
final analysisProgressProvider = Provider<double?>((ref) {
  return ref.watch(analysisProvider).whenOrNull(
        data: (state) => state.progress,
        loading: () => null,
      );
});

// ---------------------------------------------------------------------------
// AnalysisPayloadNormalizer
//
// Split the former monolithic `_normalizeAnalysisPayload` into small,
// independently testable transformation steps. Each step logs what it does.
// ---------------------------------------------------------------------------
class AnalysisPayloadNormalizer {
  static const _tag = 'PayloadNormalizer';

  /// Runs every transformation step in order.
  Map<String, dynamic> normalize(Map<String, dynamic> original) {
    var data = Map<String, dynamic>.from(original);
    data = applyRawTextSections(data);
    data = applyFieldAliases(data);
    data = buildEvidenceChecklistFallback(data);
    data = sanitizeTextFields(data);
    data = sanitizeListFields(data);
    data = normalizeLegalPosition(data);
    data = normalizeStrength(data);
    data = normalizeAuthorities(data);
    data = normalizeEvidenceChecklist(data);
    return data;
  }

  /// Step 1: If the payload embeds raw prose, parse section headings out of it.
  Map<String, dynamic> applyRawTextSections(Map<String, dynamic> data) {
    final rawText = _firstString(
        data, ['analysis', 'response', 'text', 'content', 'raw', 'message']);
    if (rawText != null && rawText.trim().isNotEmpty) {
      AppLogger.debug(_tag, 'Parsed raw text sections into structured fields');
      data.addAll(parseSectionsFromText(rawText));
    }
    return data;
  }

  /// Step 2: Map well-known camelCase / alternative keys to canonical keys.
  Map<String, dynamic> applyFieldAliases(Map<String, dynamic> data) {
    const aliases = <String, List<String>>{
      'case_summary': ['caseSummary', 'summary'],
      'legal_position': ['legalPosition'],
      'strength': ['caseStrength', 'case_strength', 'score'],
      'legal_analysis': ['legalAnalysis', 'analysisText'],
      'relevant_laws': ['relevantLaws', 'laws'],
      'rights_available': ['rights', 'rightsAvailable'],
      'authorities_detailed': ['authoritiesDetailed'],
      'evidence_checklist': ['evidenceChecklist'],
      'recommended_actions': ['nextSteps', 'recommendedActions'],
      'risk_factors': ['riskFactors'],
      'estimated_outcome': ['estimatedOutcome'],
    };

    for (final entry in aliases.entries) {
      data[entry.key] ??= entry.value.map((key) => data[key]).firstWhere(
            (value) => value != null,
            orElse: () => null,
          );
    }
    AppLogger.debug(_tag, 'Applied field aliases');
    return data;
  }

  /// Step 3: Build an evidence checklist from split available/recommended keys.
  Map<String, dynamic> buildEvidenceChecklistFallback(
      Map<String, dynamic> data) {
    if (data['evidence_checklist'] == null) {
      final available = data['evidenceAvailable'] ?? data['evidence_available'];
      final recommended =
          data['evidenceRecommended'] ?? data['evidence_recommended'];
      if (available != null || recommended != null) {
        data['evidence_checklist'] = {
          'available': available ?? <String>[],
          'recommended': recommended ?? <String>[],
        };
        AppLogger.debug(_tag, 'Built evidence checklist from split keys');
      }
    }
    return data;
  }

  /// Step 4: Sanitize all free-text fields.
  Map<String, dynamic> sanitizeTextFields(Map<String, dynamic> data) {
    data['case_summary'] = _sanitizeText(data['case_summary']);
    data['legal_analysis'] =
        _sanitizeText(data['legal_analysis'] ?? data['law_summary']);
    data['applicable_law'] = _sanitizeText(data['applicable_law']);
    data['law_summary'] =
        _sanitizeText(data['law_summary'] ?? data['legal_analysis']);
    data['user_rights'] = _sanitizeText(data['user_rights']);
    data['complaint_hint'] = _sanitizeText(data['complaint_hint']);
    data['estimated_outcome'] = _sanitizeText(data['estimated_outcome']);
    data['disclaimer'] = _sanitizeText(data['disclaimer']);
    AppLogger.debug(_tag, 'Sanitized text fields');
    return data;
  }

  /// Step 5: Sanitize all list fields.
  Map<String, dynamic> sanitizeListFields(Map<String, dynamic> data) {
    data['recommended_actions'] =
        _sanitizeList(data['recommended_actions'] ?? data['steps']);
    data['steps'] = _sanitizeList(data['steps'] ?? data['recommended_actions']);
    data['rights_available'] = _sanitizeList(data['rights_available']);
    data['risk_factors'] = _sanitizeList(data['risk_factors']);
    data['documents_required'] = _sanitizeList(data['documents_required']);
    AppLogger.debug(_tag, 'Sanitized list fields');
    return data;
  }

  /// Step 6: Ensure `legal_position` is a normalized map.
  Map<String, dynamic> normalizeLegalPosition(Map<String, dynamic> data) {
    if (data['legal_position'] is! Map) {
      data['legal_position'] = {
        'standing': _sanitizeText(data['legal_position']),
        'strength': _strengthLabel(
            _asStrengthScore(data['strength'] ?? data['confidence'])),
        'explanation': '',
      };
      AppLogger.debug(_tag, 'Promoted legal_position from text to map');
    } else {
      final legalPosition = _normalizeDynamicMap(data['legal_position']);
      legalPosition['standing'] = _sanitizeText(legalPosition['standing']);
      legalPosition['strength'] = _sanitizeText(legalPosition['strength']) ??
          _strengthLabel(
              _asStrengthScore(data['strength'] ?? data['confidence']));
      legalPosition['explanation'] =
          _sanitizeText(legalPosition['explanation']);
      data['legal_position'] = legalPosition;
      AppLogger.debug(_tag, 'Normalized legal_position map');
    }
    return data;
  }

  /// Step 7: Normalize strength score and relevant laws.
  Map<String, dynamic> normalizeStrength(Map<String, dynamic> data) {
    data['strength'] = _asStrengthScore(data['strength'] ?? data['confidence']);
    data['relevant_laws'] = _sanitizeMapList(data['relevant_laws']);
    AppLogger.debug(_tag, 'Normalized strength score');
    return data;
  }

  /// Step 8: Normalize authority lists.
  Map<String, dynamic> normalizeAuthorities(Map<String, dynamic> data) {
    data['authorities_detailed'] = _sanitizeAuthorityList(
        data['authorities_detailed'] ?? data['authorities']);
    data['authorities'] = _sanitizeAuthorityList(data['authorities']);
    AppLogger.debug(_tag, 'Normalized authority lists');
    return data;
  }

  /// Step 9: Normalize the evidence checklist to string lists.
  Map<String, dynamic> normalizeEvidenceChecklist(
      Map<String, dynamic> data) {
    final evidence = _asEvidenceChecklist(data['evidence_checklist']) ??
        <String, List<String>>{};
    data['evidence_checklist'] = {
      'available': _sanitizeList(evidence['available']) ?? <String>[],
      'recommended': _sanitizeList(evidence['recommended']) ?? <String>[],
    };
    AppLogger.debug(_tag, 'Normalized evidence checklist');
    return data;
  }

  /// Parses an unstructured AI response into named sections keyed by our
  /// canonical field names.
  Map<String, dynamic> parseSectionsFromText(String rawText) {
    final cleaned = rawText.replaceAll(RegExp(r'```(?:json)?|```'), '').trim();
    const headings = <String, String>{
      'case summary': 'case_summary',
      'legal position': 'legal_position',
      'case strength': 'strength',
      'strength': 'strength',
      'legal analysis': 'legal_analysis',
      'relevant laws': 'relevant_laws',
      'rights': 'rights_available',
      'authorities': 'authorities_detailed',
      'evidence available': 'evidence_available',
      'available evidence': 'evidence_available',
      'evidence recommended': 'evidence_recommended',
      'recommended evidence': 'evidence_recommended',
      'next steps': 'recommended_actions',
      'risk factors': 'risk_factors',
      'estimated outcome': 'estimated_outcome',
      'disclaimer': 'disclaimer',
    };
    const listSections = [
      'relevant_laws',
      'rights_available',
      'authorities_detailed',
      'evidence_available',
      'evidence_recommended',
      'recommended_actions',
      'risk_factors'
    ];
    final result = <String, dynamic>{};
    String? currentKey;
    final buffer = <String>[];

    void flush() {
      if (currentKey == null || buffer.isEmpty) return;
      final text = buffer.join('\n').trim();
      if (listSections.contains(currentKey)) {
        result[currentKey] = _splitSanitizedLines(text);
      } else {
        result[currentKey] = _sanitizeText(text);
      }
      buffer.clear();
    }

    for (final line in cleaned.split('\n')) {
      final normalized = line
          .replaceFirst(RegExp(r'^[#*\-\s\d.()]+'), '')
          .replaceFirst(RegExp(r':\s*$'), '')
          .trim()
          .toLowerCase();
      MapEntry<String, String>? matched;
      for (final entry in headings.entries) {
        if (normalized == entry.key || normalized.startsWith('${entry.key}:')) {
          matched = entry;
          break;
        }
      }
      if (matched != null) {
        flush();
        currentKey = matched.value;
        final colonIndex = line.indexOf(':');
        if (colonIndex >= 0 && colonIndex < line.length - 1) {
          buffer.add(line.substring(colonIndex + 1));
        }
      } else if (currentKey != null) {
        buffer.add(line);
      }
    }
    flush();

    if (result['evidence_available'] != null ||
        result['evidence_recommended'] != null) {
      result['evidence_checklist'] = {
        'available': result.remove('evidence_available') ?? <String>[],
        'recommended': result.remove('evidence_recommended') ?? <String>[],
      };
    }
    return result;
  }

  // -- Type conversion helpers ------------------------------------------------

  String? _firstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  String? _sanitizeText(dynamic value) {
    if (value == null) return null;
    final text = value
        .toString()
        .replaceAll(RegExp(r'```(?:json)?|```'), '')
        .replaceAll(RegExp(r'\*\*|__|[*`#]'), '')
        .trim();
    final withoutPrefix =
        text.replaceFirst(RegExp(r'^\s*(?:[-•]+|\d+(?:\.\d+)*[.)])\s*'), '');
    return withoutPrefix.replaceAll(RegExp(r'\s+'), ' ').trim().isEmpty
        ? null
        : withoutPrefix.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String>? _sanitizeList(dynamic value) {
    final items = _asStringList(value)
        .expand((item) => item.contains('\n')
            ? _splitSanitizedLines(item)
            : [_sanitizeText(item)])
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList();
    return items.isEmpty ? null : items;
  }

  List<String> _splitSanitizedLines(String text) {
    return text
        .split(RegExp(r'\n+'))
        .map(_sanitizeText)
        .whereType<String>()
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<Map<String, String>>? _sanitizeMapList(dynamic value) {
    final list = _asStringMapList(value);
    if (list == null) return null;
    final sanitized = list
        .map((map) {
          return map
              .map((key, entry) => MapEntry(key, _sanitizeText(entry) ?? ''));
        })
        .where((map) => map.values.any((entry) => entry.isNotEmpty))
        .toList();
    return sanitized.isEmpty ? null : sanitized;
  }

  List<Map<String, String>>? _sanitizeAuthorityList(dynamic value) {
    final list = _asStringMapList(value);
    if (list == null) return null;
    final sanitized = list.map((map) {
      final name =
          _sanitizeText(map['name'] ?? map['authority'] ?? map['value']) ??
              'Authority';
      final website = _sanitizeText(map['officialWebsite'] ??
              map['official_website'] ??
              map['website'] ??
              map['contact']) ??
          _defaultContactFor(name);
      return {
        'name': name,
        'description': _sanitizeText(map['description'] ??
                map['purpose'] ??
                map['why_relevant'] ??
                map['action']) ??
            '',
        'official_website': website,
      };
    }).toList();
    return sanitized.isEmpty ? null : sanitized;
  }

  int _asStrengthScore(dynamic value) {
    if (value is num) {
      final number = value.toInt();
      final normalized = number > 10 ? (number / 10).round() : number;
      return normalized.clamp(MIN_CONFIDENCE_SCORE, MAX_CONFIDENCE_SCORE);
    }
    final text = value?.toString().toLowerCase() ?? '';
    final number = RegExp(r'\d+').firstMatch(text);
    if (number != null) {
      return _asStrengthScore(int.parse(number.group(0)!));
    }
    if (text.contains('strong')) return 8;
    if (text.contains('moderate') || text.contains('medium')) return 5;
    if (text.contains('weak')) return 2;
    return 5;
  }

  String _strengthLabel(int score) {
    if (score <= 3) return 'Weak';
    if (score <= 6) return 'Moderate';
    return 'Strong';
  }

  String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  List<String> _asStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    if (value is String) {
      return value.trim().isEmpty ? [] : [value.trim()];
    }
    return [value.toString()];
  }

  List<String>? _asNullableStringList(dynamic value) {
    final list = _asStringList(value);
    return list.isEmpty ? null : list;
  }

  Map<String, String> _normalizeStringMap(dynamic value) {
    if (value is Map) {
      return value.map((key, entry) =>
          MapEntry(key.toString(), entry == null ? '' : entry.toString()));
    }
    return {};
  }

  Map<String, dynamic> _normalizeDynamicMap(dynamic value) {
    if (value is Map) {
      return value.map((key, entry) => MapEntry(key.toString(), entry));
    }
    return {};
  }

  List<Map<String, String>>? _asStringMapList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) {
        if (e is Map) return _normalizeStringMap(e);
        return <String, String>{'value': e.toString()};
      }).toList();
    }
    if (value is Map) {
      return [_normalizeStringMap(value)];
    }
    return [
      {'value': value.toString()}
    ];
  }

  Map<String, List<String>>? _asEvidenceChecklist(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value.map((key, entry) {
        if (entry is List) {
          return MapEntry(
            key.toString(),
            entry
                .map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty)
                .toList(),
          );
        }
        if (entry == null) {
          return MapEntry(key.toString(), <String>[]);
        }
        return MapEntry(key.toString(), [entry.toString()]);
      });
    }
    return null;
  }

  String _defaultContactFor(String name) {
    final map = {
      AppStrings.authNationalConsumerHelpline: '1800-11-4000',
      AppStrings.authCyberCrimePortal: 'cybercrime.gov.in',
      AppStrings.authRBIPortal: 'cms.rbi.org.in',
      AppStrings.authDGCA: 'dgca.gov.in',
      AppStrings.authTRAI: 'trai.gov.in',
      AppStrings.authFSSAI: 'fssai.gov.in',
      AppStrings.authMedicalCouncil: 'mciindia.org',
      AppStrings.authDistrictConsumer: AppStrings.actionFindNearest,
      AppStrings.authTrafficPolice: AppStrings.actionFindNearest,
      AppStrings.authEducationRegulatory: AppStrings.actionFileOnline,
      AppStrings.authAirlineGrievance: AppStrings.actionContactAirline,
      AppStrings.authConsumerCommission: AppStrings.actionFileOnline,
    };
    return map[name] ?? '';
  }

  String _defaultActionFor(String name) {
    if (name.contains('Helpline') || name.contains('Police')) {
      return AppStrings.actionCallNow;
    }
    if (name.contains('Commission') ||
        name.contains('Portal') ||
        name.contains('DGCA') ||
        name.contains('TRAI') ||
        name.contains('Officer')) {
      return AppStrings.actionFileOnline;
    }
    return AppStrings.actionVisitWebsite;
  }

  /// Builds the domain model from a normalized payload.
  LegalResultModel toLegalResultModel(Map<String, dynamic> data) {
    // Extract authorities list - handle both string and map formats
    List<Map<String, String>> authorities = [];
    if (data['authorities'] is List) {
      final authList = data['authorities'] as List;
      authorities = authList.map((e) {
        if (e is String) {
          return {
            'name': e,
            'contact': _defaultContactFor(e),
            'action': _defaultActionFor(e),
          };
        } else if (e is Map) {
          return _normalizeStringMap(e);
        }
        return {'name': e.toString(), 'contact': '', 'action': ''};
      }).toList();
    }

    return LegalResultModel(
      category: _asString(data['category']),
      applicableLaw: _asString(data['applicable_law']),
      lawSummary: _asString(data['law_summary']),
      userRights: _asString(data['user_rights']),
      steps: _asStringList(data['steps']),
      authorities: authorities,
      documentsRequired: _asStringList(data['documents_required']),
      physicalVisitRequired: _asBool(data['physical_visit_required']),
      physicalVisitInstructions:
          _nullableString(data['physical_visit_instructions']),
      confidence: _asInt(data['confidence']),
      isVerified: _asBool(data['isVerified']),
      complaintHint: _asString(data['complaint_hint']),
      caseSummary: _nullableString(data['case_summary']),
      legalPosition: data['legal_position'] != null
          ? _normalizeDynamicMap(data['legal_position'])
          : null,
      strength: _asStrengthScore(
          data['strength'] ?? data['case_strength'] ?? data['confidence']),
      legalAnalysis: _nullableString(data['legal_analysis']),
      relevantLaws: _asStringMapList(data['relevant_laws']),
      rightsAvailable: _asNullableStringList(data['rights_available']),
      evidenceChecklist: _asEvidenceChecklist(data['evidence_checklist']),
      recommendedActions: _asNullableStringList(data['recommended_actions']),
      authoritiesDetailed: _asStringMapList(data['authorities_detailed']),
      riskFactors: _asNullableStringList(data['risk_factors']),
      estimatedOutcome: _nullableString(data['estimated_outcome']),
      disclaimer: _nullableString(data['disclaimer']),
      orderNumber: _nullableString(data['order_number']),
      productDetails: _nullableString(data['product_details']),
      amountPaid: _nullableString(data['amount_paid']),
      paymentMethod: _nullableString(data['payment_method']),
      companyName: _nullableString(data['company_name']),
      incidentDate: _nullableString(data['incident_date']),
      location: _nullableString(data['location']),
    );
  }
}

// ---------------------------------------------------------------------------
// Last result (for backward compatibility)
// ---------------------------------------------------------------------------
class LastResultNotifier extends Notifier<LegalResultModel?> {
  @override
  LegalResultModel? build() => null;

  void set(LegalResultModel? value) {
    state = value;
  }
}

final lastResultProvider =
    NotifierProvider<LastResultNotifier, LegalResultModel?>(
        LastResultNotifier.new);

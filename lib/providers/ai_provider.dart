import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/legal_result_model.dart';
import '../models/problem_model.dart';
import '../services/ai_service.dart';
import '../core/exceptions/ai_exceptions.dart';
import '../core/services/analytics_service.dart';
import '../core/constants/app_strings.dart';
import '../models/chat_message_model.dart';
import 'locale_provider.dart';

// Provider for AIService instance
final aiServiceProvider = Provider<AIService>((ref) => AIService());

class ChatState {
  final List<ChatMessage> conversationHistory;
  final bool isSending;
  final String? error;

  const ChatState({
    this.conversationHistory = const [],
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? conversationHistory,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) =>
      ChatState(
        conversationHistory: conversationHistory ?? this.conversationHistory,
        isSending: isSending ?? this.isSending,
        error: clearError ? null : error ?? this.error,
      );
}

/// In-memory conversation state. It intentionally resets when the app closes.
class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  List<ChatMessage> getHistory() => state.conversationHistory;

  void addMessage(String role, String content) {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) return;
    state = state.copyWith(
      conversationHistory: List.unmodifiable([
        ...state.conversationHistory,
        ChatMessage(
          role: role,
          content: trimmedContent,
          timestamp: DateTime.now(),
        ),
      ]),
      clearError: true,
    );
  }

  Future<void> sendUserMessage(String userMessage) async {
    final trimmedMessage = userMessage.trim();
    if (trimmedMessage.isEmpty || state.isSending) return;

    addMessage('user', trimmedMessage);
    state = state.copyWith(isSending: true, clearError: true);
    final messagesForApi = state.conversationHistory
        .map((message) => message.toMap())
        .toList(growable: false);

    try {
      final response = await ref
          .read(aiServiceProvider)
          .sendMessage(
            trimmedMessage,
            messagesForApi,
            languageCode: ref.read(localeProvider).languageCode,
          );
      addMessage('assistant', response);
      state = state.copyWith(isSending: false, clearError: true);
    } catch (error) {
      state = state.copyWith(isSending: false, error: _friendlyError(error));
      rethrow;
    }
  }

  void clearHistory() => state = const ChatState();

  String _friendlyError(Object error) {
    if (error is AllProvidersFailedException) {
      return 'AI services are unavailable. Please try again shortly.';
    }
    if (error is NetworkException) {
      return 'Could not reach the AI service. Check your connection and try again.';
    }
    return 'Could not get an AI response. Please try again.';
  }
}

final chatProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

// Analysis state
class AnalysisState {
  final AsyncValue<LegalResultModel>? result;
  final String? error;

  AnalysisState({this.result, this.error});

  AnalysisState copyWith({
    AsyncValue<LegalResultModel>? result,
    String? error,
  }) {
    return AnalysisState(
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

// AsyncNotifier for analysis state management
class AnalysisNotifier extends AsyncNotifier<AnalysisState> {
  late final AIService _aiService;

  @override
  AnalysisState build() {
    _aiService = ref.read(aiServiceProvider);
    return AnalysisState();
  }

  Future<LegalResultModel> analyze(ProblemModel problem) async {
    try {
      if (problem.summary.trim().isEmpty) {
        final error = ArgumentError(AppStrings.errorProblemEmpty);
        state = AsyncValue.error(error, StackTrace.current);
        throw error;
      }

      state = const AsyncValue.loading();

      if (kDebugMode) {
        debugPrint('[AnalysisNotifier] analysis started '
            '(category=${problem.category}, problemLength=${problem.summary.trim().length})');
      }

      // Log analysis started event using SafeAnalytics
      await SafeAnalytics.logEvent(
        name: AppStrings.eventAnalysisStarted,
        parameters: {
          'category': problem.category,
          'problem_length': problem.summary.length,
        },
      );

      // Initialize AI service
      await _aiService.initialize();

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

      if (kDebugMode) {
        debugPrint('[AnalysisNotifier] provider response received '
            '(fieldCount=${analysisResult.length})');
      }

      // Convert Map to LegalResultModel
      final legalResult = _mapToLegalResultModel(analysisResult);

      if (kDebugMode) {
        debugPrint('[AnalysisNotifier] analysis response parsed '
            '(confidence=${legalResult.confidence})');
      }

      // Update both new and old providers
      ref.read(lastResultProvider.notifier).set(legalResult);

      // Log analysis completed event using SafeAnalytics
      await SafeAnalytics.logEvent(
        name: AppStrings.eventAnalysisCompleted,
        parameters: {
          'category': problem.category,
          'confidence': legalResult.confidence,
        },
      );

      state = AsyncValue.data(AnalysisState(
        result: AsyncValue.data(legalResult),
      ));

      return legalResult;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AnalysisNotifier] analysis failed '
            '(category=${e.runtimeType})');
      }

      // Log analysis error event using SafeAnalytics
      await SafeAnalytics.logEvent(
        name: AppStrings.eventAnalysisError,
        parameters: {
          'category': problem.category,
          'error_type': e.runtimeType.toString(),
        },
      );

      String errorMessage = _getErrorMessage(e);
      state = AsyncValue.data(AnalysisState(error: errorMessage));
      rethrow;
    }
  }

  LegalResultModel _mapToLegalResultModel(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('[AnalysisNotifier] mapping provider response '
          '(fieldCount=${data.length})');
    }

    data = _normalizeAnalysisPayload(data);

    // Extract authorities list - handle both string and map formats
    List<Map<String, String>> authorities = [];
    if (data['authorities'] is List) {
      final authList = data['authorities'] as List;
      authorities = authList.map((e) {
        if (e is String) {
          // Convert string to map format
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

  Map<String, dynamic> _normalizeAnalysisPayload(
      Map<String, dynamic> original) {
    final data = Map<String, dynamic>.from(original);
    final rawText = _firstString(
        data, ['analysis', 'response', 'text', 'content', 'raw', 'message']);
    if (rawText != null && rawText.trim().isNotEmpty) {
      data.addAll(_parseSectionsFromText(rawText));
    }

    final aliases = <String, List<String>>{
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

    if (data['evidence_checklist'] == null) {
      final available = data['evidenceAvailable'] ?? data['evidence_available'];
      final recommended =
          data['evidenceRecommended'] ?? data['evidence_recommended'];
      if (available != null || recommended != null) {
        data['evidence_checklist'] = {
          'available': available ?? <String>[],
          'recommended': recommended ?? <String>[],
        };
      }
    }

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
    data['recommended_actions'] =
        _sanitizeList(data['recommended_actions'] ?? data['steps']);
    data['steps'] = _sanitizeList(data['steps'] ?? data['recommended_actions']);
    data['rights_available'] = _sanitizeList(data['rights_available']);
    data['risk_factors'] = _sanitizeList(data['risk_factors']);
    data['documents_required'] = _sanitizeList(data['documents_required']);

    if (data['legal_position'] is! Map) {
      data['legal_position'] = {
        'standing': _sanitizeText(data['legal_position']),
        'strength': _strengthLabel(
            _asStrengthScore(data['strength'] ?? data['confidence'])),
        'explanation': '',
      };
    } else {
      final legalPosition = _normalizeDynamicMap(data['legal_position']);
      legalPosition['standing'] = _sanitizeText(legalPosition['standing']);
      legalPosition['strength'] = _sanitizeText(legalPosition['strength']) ??
          _strengthLabel(
              _asStrengthScore(data['strength'] ?? data['confidence']));
      legalPosition['explanation'] =
          _sanitizeText(legalPosition['explanation']);
      data['legal_position'] = legalPosition;
    }

    data['strength'] = _asStrengthScore(data['strength'] ?? data['confidence']);
    data['relevant_laws'] = _sanitizeMapList(data['relevant_laws']);
    data['authorities_detailed'] = _sanitizeAuthorityList(
        data['authorities_detailed'] ?? data['authorities']);
    data['authorities'] = _sanitizeAuthorityList(data['authorities']);

    final evidence = _asEvidenceChecklist(data['evidence_checklist']) ??
        <String, List<String>>{};
    data['evidence_checklist'] = {
      'available': _sanitizeList(evidence['available']) ?? <String>[],
      'recommended': _sanitizeList(evidence['recommended']) ?? <String>[],
    };

    return data;
  }

  Map<String, dynamic> _parseSectionsFromText(String rawText) {
    final cleaned = rawText.replaceAll(RegExp(r'```(?:json)?|```'), '').trim();
    final headings = <String, String>{
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
    final result = <String, dynamic>{};
    String? currentKey;
    final buffer = <String>[];

    void flush() {
      if (currentKey == null || buffer.isEmpty) return;
      final text = buffer.join('\n').trim();
      if ([
        'relevant_laws',
        'rights_available',
        'authorities_detailed',
        'evidence_available',
        'evidence_recommended',
        'recommended_actions',
        'risk_factors'
      ].contains(currentKey)) {
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
      return number > 10
          ? (number / 10).round().clamp(1, 10).toInt()
          : number.clamp(1, 10).toInt();
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

// Provider for last result (for backward compatibility)
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

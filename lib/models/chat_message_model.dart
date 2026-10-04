import 'dart:convert';

/// Representation of an interactive option choice chip/button.
class ChatOption {
  final String label;
  final String value;

  const ChatOption({
    required this.label,
    required this.value,
  });

  Map<String, String> toMap() => {
        'label': label,
        'value': value,
      };

  factory ChatOption.fromMap(dynamic map) {
    if (map is Map) {
      final label =
          (map['label'] ?? map['text'] ?? map['value'] ?? '').toString().trim();
      final value =
          (map['value'] ?? map['label'] ?? map['text'] ?? '').toString().trim();
      return ChatOption(
        label: label.isNotEmpty ? label : 'Select',
        value: value.isNotEmpty ? value : label,
      );
    } else if (map is String) {
      final str = map.trim();
      return ChatOption(label: str, value: str);
    }
    return const ChatOption(label: 'Select', value: 'select');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatOption &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => label.hashCode ^ value.hashCode;
}

/// Representation of a structured action card.
class ChatAction {
  final String title;
  final List<String> items;

  const ChatAction({
    required this.title,
    required this.items,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'items': items,
      };

  factory ChatAction.fromMap(dynamic map) {
    if (map is Map) {
      final title =
          (map['title'] ?? map['name'] ?? map['heading'] ?? 'Do this now')
              .toString()
              .trim();
      final rawItems =
          map['items'] ?? map['actions'] ?? map['checklist'] ?? map['steps'];
      final items = rawItems is List
          ? rawItems
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : <String>[];
      return ChatAction(
        title: title.isNotEmpty ? title : 'Do this now',
        items: items,
      );
    }
    return const ChatAction(title: 'Do this now', items: []);
  }
}

/// Compact state tracking for progressive legal conversation turns.
class CaseState {
  final String caseType;
  final Map<String, String> knownFacts;
  final List<String> missingImportantFacts;
  final String currentStage;
  final List<String> previousActions;
  final String escalationStatus;

  const CaseState({
    this.caseType = 'general',
    this.knownFacts = const {},
    this.missingImportantFacts = const [],
    this.currentStage = 'triage',
    this.previousActions = const [],
    this.escalationStatus = 'none',
  });

  CaseState copyWith({
    String? caseType,
    Map<String, String>? knownFacts,
    List<String>? missingImportantFacts,
    String? currentStage,
    List<String>? previousActions,
    String? escalationStatus,
  }) {
    return CaseState(
      caseType: caseType ?? this.caseType,
      knownFacts: knownFacts ?? this.knownFacts,
      missingImportantFacts:
          missingImportantFacts ?? this.missingImportantFacts,
      currentStage: currentStage ?? this.currentStage,
      previousActions: previousActions ?? this.previousActions,
      escalationStatus: escalationStatus ?? this.escalationStatus,
    );
  }

  Map<String, dynamic> toMap() => {
        'caseType': caseType,
        'knownFacts': knownFacts,
        'missingImportantFacts': missingImportantFacts,
        'currentStage': currentStage,
        'previousActions': previousActions,
        'escalationStatus': escalationStatus,
      };

  factory CaseState.fromMap(dynamic map) {
    if (map is! Map) return const CaseState();

    final rawFacts = map['knownFacts'];
    final knownFacts = <String, String>{};
    if (rawFacts is Map) {
      rawFacts.forEach((k, v) {
        if (k != null && v != null) {
          knownFacts[k.toString()] = v.toString();
        }
      });
    }

    List<String> parseList(dynamic val) {
      if (val is List) {
        return val
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    return CaseState(
      caseType: (map['caseType'] ?? 'general').toString().trim(),
      knownFacts: knownFacts,
      missingImportantFacts: parseList(map['missingImportantFacts']),
      currentStage: (map['currentStage'] ?? 'triage').toString().trim(),
      previousActions: parseList(map['previousActions']),
      escalationStatus: (map['escalationStatus'] ?? 'none').toString().trim(),
    );
  }

  String toPromptSummary() {
    final factsStr = knownFacts.isEmpty
        ? 'None yet'
        : knownFacts.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    final missingStr = missingImportantFacts.isEmpty
        ? 'None'
        : missingImportantFacts.join(', ');
    final prevActionsStr =
        previousActions.isEmpty ? 'None' : previousActions.join(', ');

    return 'Case Type: $caseType | Stage: $currentStage | Escalation: $escalationStatus\n'
        'Known Facts: $factsStr\n'
        'Missing Facts: $missingStr\n'
        'Previous Actions: $prevActionsStr';
  }

  /// Applies only facts learned in the latest chat turn. Existing facts remain
  /// intact unless the model explicitly supplies a non-null replacement.
  CaseState withChatUpdates(Map<String, dynamic> updates) {
    final facts = Map<String, String>.from(knownFacts);
    String caseType = this.caseType;
    String currentStage = this.currentStage;
    String escalationStatus = this.escalationStatus;
    List<String> missingFacts = missingImportantFacts;
    List<String> previous = previousActions;

    updates.forEach((key, value) {
      if (value == null) return;
      if (key == 'caseType' || key == 'category') {
        final text = value.toString().trim();
        if (text.isNotEmpty) caseType = text;
      } else if (key == 'currentStage') {
        final text = value.toString().trim();
        if (text.isNotEmpty) currentStage = text;
      } else if (key == 'escalationStatus') {
        final text = value.toString().trim();
        if (text.isNotEmpty) escalationStatus = text;
      } else if (key == 'missingFacts' && value is List) {
        missingFacts = value
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (key == 'previousActions' && value is List) {
        previous = value
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (value is String && value.trim().isNotEmpty) {
        facts[key] = value.trim();
      }
    });
    return copyWith(
      caseType: caseType,
      knownFacts: facts,
      missingImportantFacts: missingFacts,
      currentStage: currentStage,
      previousActions: previous,
      escalationStatus: escalationStatus,
    );
  }
}

/// A single in-memory chat message used for display, AI context, and persistence.
class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  final String type; // message, question, action, escalation, resolution
  final List<ChatOption>? options;
  final ChatAction? action;
  final List<String>? actionChecklist; // backward compatibility
  final String? question;
  final String? legalContext;
  final String? nextStep;
  final int? stage;
  final CaseState? caseState;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.type = 'message',
    this.options,
    this.action,
    this.actionChecklist,
    this.question,
    this.legalContext,
    this.nextStep,
    this.stage,
    this.caseState,
  });

  /// Compact map sent to the AI API ({role, content} only).
  Map<String, String> toApiMap() => {
        'role': role,
        'content': _buildApiContent(),
      };

  String _buildApiContent() {
    return content.trim();
  }

  /// Full map persisted to Hive (includes timestamp for ordering).
  Map<String, dynamic> toMap() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'type': type,
        if (options != null) 'options': options!.map((o) => o.toMap()).toList(),
        if (action != null) 'action': action!.toMap(),
        if (actionChecklist != null) 'actionChecklist': actionChecklist,
        if (question != null) 'question': question,
        if (legalContext != null) 'legalContext': legalContext,
        if (nextStep != null) 'nextStep': nextStep,
        if (stage != null) 'stage': stage,
        if (caseState != null) 'caseState': caseState!.toMap(),
      };

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) {
    final rawTimestamp = map['timestamp'];
    DateTime timestamp;
    if (rawTimestamp is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else if (rawTimestamp is String) {
      timestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      timestamp = DateTime.now();
    }

    List<ChatOption>? options;
    final rawOptions = map['options'];
    if (rawOptions is List) {
      options = rawOptions
          .map((e) => ChatOption.fromMap(e))
          .where((o) => o.label.isNotEmpty)
          .toList();
    }

    ChatAction? action;
    if (map['action'] != null) {
      action = ChatAction.fromMap(map['action']);
    } else if (map['actionChecklist'] is List) {
      final checklist = (map['actionChecklist'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (checklist.isNotEmpty) {
        action = ChatAction(title: 'Do this now', items: checklist);
      }
    }

    CaseState? caseState;
    if (map['caseState'] != null) {
      caseState = CaseState.fromMap(map['caseState']);
    }

    return ChatMessage(
      role: (map['role'] as String?) ?? 'user',
      content: (map['content'] as String?) ?? '',
      timestamp: timestamp,
      type: (map['type'] as String?) ?? 'message',
      options: options?.isNotEmpty == true ? options : null,
      action: action,
      actionChecklist: action?.items,
      question: map['question'] as String?,
      legalContext: map['legalContext'] as String?,
      nextStep: map['nextStep'] as String?,
      stage: map['stage'] as int?,
      caseState: caseState,
    );
  }

  /// Helper factory to parse and validate AI JSON response or provide safe fallback.
  factory ChatMessage.fromAiResponse(
    String rawContent, {
    required DateTime timestamp,
    CaseState? currentCaseState,
  }) {
    String content = rawContent.trim();

    // Strip markdown code fences if present
    if (content.startsWith('```json')) {
      content = content.substring(7);
    } else if (content.startsWith('```')) {
      content = content.substring(3);
    }
    if (content.endsWith('```')) {
      content = content.substring(0, content.length - 3);
    }
    content = content.trim();

    try {
      final parsed = jsonDecode(content);
      if (parsed is Map<String, dynamic>) {
        return _validateAndBuildFromMap(parsed, timestamp, currentCaseState);
      }
    } catch (_) {
      // Fallback below
    }

    // Safe fallback when AI returns unparseable or non-JSON response
    return _buildFallbackMessage(timestamp, currentCaseState);
  }

  static ChatMessage _validateAndBuildFromMap(
    Map<String, dynamic> parsed,
    DateTime timestamp,
    CaseState? currentCaseState,
  ) {
    const allowedKeys = {
      'type',
      'message',
      'question',
      'options',
      'steps',
      'legalContext',
      'nextAction',
      'caseUpdates'
    };
    const validTypes = {
      'question',
      'information',
      'action',
      'warning',
      'final'
    };
    if (parsed.length != allowedKeys.length ||
        !allowedKeys.every(parsed.containsKey) ||
        parsed.keys.any((key) => !allowedKeys.contains(key)) ||
        parsed['type'] is! String ||
        !validTypes.contains((parsed['type'] as String).toLowerCase().trim()) ||
        parsed['message'] is! String ||
        (parsed['legalContext'] != null && parsed['legalContext'] is! String) ||
        (parsed['nextAction'] != null && parsed['nextAction'] is! String)) {
      return _buildFallbackMessage(timestamp, currentCaseState);
    }
    final rawType = (parsed['type'] as String).toLowerCase().trim();
    String msgText = parsed['message'] as String;
    msgText = _sanitizeMessageText(msgText);
    if (msgText.isEmpty) {
      return _buildFallbackMessage(timestamp, currentCaseState);
    }

    // 3. Extract question
    String? questionText = (parsed['question'] as String?)?.trim();
    if (questionText != null && questionText.isEmpty) {
      questionText = null;
    }

    if ((rawType == 'question') != (questionText != null)) {
      return _buildFallbackMessage(timestamp, currentCaseState);
    }

    // 4. Extract optional short steps for the existing action-card renderer.
    ChatAction? action;
    if (parsed['steps'] is! List ||
        (parsed['steps'] as List).length > 4 ||
        (parsed['steps'] as List).any((step) => step is! String)) {
      return _buildFallbackMessage(timestamp, currentCaseState);
    }
    final steps = (parsed['steps'] as List)
        .whereType<String>()
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
    if (steps.isNotEmpty) {
      action = ChatAction(title: 'Next steps', items: steps);
    }

    // 5. Extract options
    List<ChatOption>? options;
    if (parsed['options'] is! List ||
        (parsed['options'] as List).length > 4 ||
        (parsed['options'] as List).any((option) => option is! String)) {
      return _buildFallbackMessage(timestamp, currentCaseState);
    }
    if (parsed['options'] is List) {
      options = (parsed['options'] as List)
          .whereType<String>()
          .map((e) => ChatOption.fromMap(e))
          .where((o) => o.label.isNotEmpty)
          .toList();
    }
    if (rawType == 'question' && (options == null || options.length < 2)) {
      return _buildFallbackMessage(timestamp, currentCaseState);
    }

    // 6. Extract legal context & next step
    String? legalCtx = (parsed['legalContext'] as String?)?.trim();
    if (legalCtx != null && legalCtx.isEmpty) legalCtx = null;

    String? nextStepText = (parsed['nextAction'] as String?)?.trim();
    if (nextStepText != null && nextStepText.isEmpty) nextStepText = null;

    // 7. Merge only latest-message facts into the existing source of truth.
    if (parsed['caseUpdates'] is! Map) {
      return _buildFallbackMessage(timestamp, currentCaseState);
    }
    final updates = Map<String, dynamic>.from(parsed['caseUpdates'] as Map);
    final updatedCaseState =
        (currentCaseState ?? const CaseState()).withChatUpdates(updates);

    return ChatMessage(
      role: 'assistant',
      content: msgText,
      timestamp: timestamp,
      type: rawType,
      options: options?.isNotEmpty == true ? options : null,
      action: action,
      actionChecklist: action?.items,
      question: questionText,
      legalContext: legalCtx,
      nextStep: nextStepText,
      caseState: updatedCaseState,
    );
  }

  static ChatMessage _buildFallbackMessage(
    DateTime timestamp,
    CaseState? currentCaseState,
  ) {
    return ChatMessage(
      role: 'assistant',
      content:
          "I couldn't process that response correctly. Please tell me a little more about what happened.",
      timestamp: timestamp,
      type: 'information',
      caseState: currentCaseState,
    );
  }

  /// Sanitizes text content to strip out legacy headers and button labels accidentally leaked into prose.
  static String _sanitizeMessageText(String text) {
    String cleaned = text;
    cleaned = cleaned.replaceAll(
        RegExp(r'Quick Options Presented:.*$',
            multiLine: true, caseSensitive: false),
        '');
    cleaned = cleaned.replaceAll(
        RegExp(r'UI buttons?:.*$', multiLine: true, caseSensitive: false), '');
    cleaned = cleaned.replaceAll(
        RegExp(r'Quick options?:.*$', multiLine: true, caseSensitive: false),
        '');
    cleaned = cleaned.replaceAll(
        RegExp(r'Action Checklist:.*$', multiLine: true, caseSensitive: false),
        '');
    cleaned = cleaned.replaceAll(
        RegExp(r'Legal Context:.*$', multiLine: true, caseSensitive: false),
        '');
    cleaned = cleaned.replaceAll(
        RegExp(r'Question:.*$', multiLine: true, caseSensitive: false), '');
    return cleaned.trim();
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:juslegal/models/chat_message_model.dart';

void main() {
  group('ChatMessage ChatResponse tests', () {
    final now = DateTime.now();

    test('parses ChatResponse and merges only latest case updates', () {
      const rawJson = '''{
        "type": "question",
        "message": "Keep photos of the damage and packaging.",
        "question": "Have you contacted the seller or platform?",
        "options": ["Yes", "No"],
        "steps": ["Save photos and the order record"],
        "legalContext": "The product condition and your complaint record can matter.",
        "nextAction": "Contact the seller through the order channel.",
        "caseUpdates": {"category": "damaged_order", "evidenceAvailable": "photos"}
      }''';

      final msg = ChatMessage.fromAiResponse(
        rawJson,
        timestamp: now,
        currentCaseState:
            const CaseState(knownFacts: {'sellerContacted': 'no'}),
      );

      expect(msg.type, 'question');
      expect(msg.question, 'Have you contacted the seller or platform?');
      expect(msg.options, const [
        ChatOption(label: 'Yes', value: 'Yes'),
        ChatOption(label: 'No', value: 'No')
      ]);
      expect(msg.action!.items, ['Save photos and the order record']);
      expect(msg.caseState!.caseType, 'damaged_order');
      expect(msg.caseState!.knownFacts, {
        'sellerContacted': 'no',
        'evidenceAvailable': 'photos',
      });
    });

    test('rejects unknown keys and returns deterministic fallback', () {
      const invalidJson = '''{
        "type": "information", "message": "Hello", "question": null,
        "options": [], "steps": [], "legalContext": null,
        "nextAction": null, "caseUpdates": {}, "unexpected": true
      }''';

      final msg = ChatMessage.fromAiResponse(invalidJson, timestamp: now);
      expect(msg.type, 'information');
      expect(msg.content,
          "I couldn't process that response correctly. Please tell me a little more about what happened.");
      expect(msg.options, isNull);
    });

    test('does not overwrite known facts with null case updates', () {
      const response = '''{
        "type": "information", "message": "Please keep the order record.",
        "question": null, "options": [], "steps": [], "legalContext": null,
        "nextAction": null,
        "caseUpdates": {"sellerContacted": null, "orderNumber": "ORD-42"}
      }''';

      final msg = ChatMessage.fromAiResponse(
        response,
        timestamp: now,
        currentCaseState: const CaseState(
          knownFacts: {'sellerContacted': 'yes', 'sellerResponse': 'denied'},
        ),
      );

      expect(msg.caseState!.knownFacts, {
        'sellerContacted': 'yes',
        'sellerResponse': 'denied',
        'orderNumber': 'ORD-42',
      });
    });

    test('returns deterministic fallback for malformed AI JSON', () {
      final msg = ChatMessage.fromAiResponse('not JSON', timestamp: now);
      expect(msg.type, 'information');
      expect(msg.content,
          "I couldn't process that response correctly. Please tell me a little more about what happened.");
    });

    test('loads legacy Hive messages', () {
      final legacy = <dynamic, dynamic>{
        'role': 'assistant',
        'content': 'Check your account status.',
        'timestamp': now.millisecondsSinceEpoch,
        'type': 'action',
        'actionChecklist': ['Block debit card'],
        'options': [
          {'label': 'Done', 'value': 'done'}
        ],
        'caseState': {
          'caseType': 'banking_fraud',
          'knownFacts': {'reported': 'yes'},
          'currentStage': 'reporting',
        },
      };

      final message = ChatMessage.fromMap(legacy);
      expect(message.action!.items, ['Block debit card']);
      expect(message.options!.first,
          const ChatOption(label: 'Done', value: 'done'));
      expect(message.caseState!.knownFacts['reported'], 'yes');
    });
  });
}

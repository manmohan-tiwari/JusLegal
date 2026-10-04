import 'package:flutter_test/flutter_test.dart';
import 'package:juslegal/models/chat_message_model.dart';

void main() {
  group('ChatMessage structured-response architecture tests', () {
    final now = DateTime.now();

    test('Parses valid structured JSON response with options, action, question, legalContext', () {
      const rawJson = '''{
        "type": "question",
        "message": "Account takeover can be serious. Let's secure your account first.",
        "action": {
          "title": "Do this now",
          "items": [
            "Contact your bank's fraud helpline immediately."
          ]
        },
        "question": "Have you already reported this to your bank?",
        "options": [
          {"label": "Yes, reported", "value": "reported"},
          {"label": "No, not yet", "value": "not_reported"},
          {"label": "Bank refused", "value": "bank_refused"}
        ],
        "legalContext": "Under RBI circulars, reporting unauthorized transactions within 3 days limits liability.",
        "nextStep": "Obtain bank acknowledgement reference number.",
        "caseState": {
          "caseType": "banking_fraud",
          "knownFacts": {"issue": "account_takeover"},
          "missingImportantFacts": ["report_date"],
          "currentStage": "securing_account",
          "previousActions": [],
          "escalationStatus": "none"
        }
      }''';

      final msg = ChatMessage.fromAiResponse(rawJson, timestamp: now);

      expect(msg.role, equals('assistant'));
      expect(msg.type, equals('question'));
      expect(msg.content, equals("Account takeover can be serious. Let's secure your account first."));
      expect(msg.question, equals("Have you already reported this to your bank?"));
      expect(msg.action, isNotNull);
      expect(msg.action!.title, equals("Do this now"));
      expect(msg.action!.items, equals(["Contact your bank's fraud helpline immediately."]));
      expect(msg.options, isNotNull);
      expect(msg.options!.length, equals(3));
      expect(msg.options![0], equals(const ChatOption(label: 'Yes, reported', value: 'reported')));
      expect(msg.options![1], equals(const ChatOption(label: 'No, not yet', value: 'not_reported')));
      expect(msg.options![2], equals(const ChatOption(label: 'Bank refused', value: 'bank_refused')));
      expect(msg.legalContext, equals("Under RBI circulars, reporting unauthorized transactions within 3 days limits liability."));
      expect(msg.nextStep, equals("Obtain bank acknowledgement reference number."));
      expect(msg.caseState, isNotNull);
      expect(msg.caseState!.caseType, equals('banking_fraud'));
      expect(msg.caseState!.knownFacts['issue'], equals('account_takeover'));
    });

    test('Sanitizes text and removes plain-text leaked headers', () {
      const rawJson = '''{
        "type": "message",
        "message": "Here is your guidance.\\nQuick Options Presented: Yes, No\\nUI buttons: Select one\\nQuestion: Have you reported it?",
        "options": [{"label": "Yes", "value": "yes"}, {"label": "No", "value": "no"}]
      }''';

      final msg = ChatMessage.fromAiResponse(rawJson, timestamp: now);

      expect(msg.content, equals("Here is your guidance."));
      expect(msg.content.contains("Quick Options Presented:"), isFalse);
      expect(msg.content.contains("UI buttons:"), isFalse);
      expect(msg.content.contains("Question:"), isFalse);
    });

    test('Falls back safely on malformed/invalid AI non-JSON text without crashing', () {
      const malformedText = "This is a broken non-JSON text response from the AI model.";

      final msg = ChatMessage.fromAiResponse(malformedText, timestamp: now);

      expect(msg.role, equals('assistant'));
      expect(msg.type, equals('message'));
      expect(msg.content, equals("This is a broken non-JSON text response from the AI model."));
      expect(msg.options, isNotNull);
      expect(msg.options!.isNotEmpty, isTrue);
    });

    test('Serializes toMap and deserializes fromMap with full backward compatibility', () {
      final original = ChatMessage(
        role: 'assistant',
        content: 'Check your account status.',
        timestamp: now,
        type: 'action',
        action: const ChatAction(title: 'Do this now', items: ['Block debit card']),
        options: const [ChatOption(label: 'Done', value: 'done')],
        question: 'Is your card blocked?',
        legalContext: 'RBI rules apply.',
        nextStep: 'File FIR',
        caseState: const CaseState(caseType: 'banking_fraud', currentStage: 'reporting'),
      );

      final map = original.toMap();
      final reconstructed = ChatMessage.fromMap(map);

      expect(reconstructed.role, equals(original.role));
      expect(reconstructed.type, equals(original.type));
      expect(reconstructed.content, equals(original.content));
      expect(reconstructed.question, equals(original.question));
      expect(reconstructed.action!.title, equals('Do this now'));
      expect(reconstructed.action!.items, equals(['Block debit card']));
      expect(reconstructed.options!.first.label, equals('Done'));
      expect(reconstructed.legalContext, equals('RBI rules apply.'));
      expect(reconstructed.nextStep, equals('File FIR'));
      expect(reconstructed.caseState!.caseType, equals('banking_fraud'));
    });
  });
}

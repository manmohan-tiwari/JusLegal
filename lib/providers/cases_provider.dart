import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/saved_case_model.dart';
import '../core/services/analytics_service.dart';

class CasesNotifier extends Notifier<List<SavedCaseModel>> {
  @override
  List<SavedCaseModel> build() {
    _load();
    return [];
  }

  Future<Box> get _box async => Hive.openBox('cases');

  Future<void> _load() async {
    final box = await _box;
    final items = <SavedCaseModel>[];
    for (final key in box.keys) {
      final raw = Map<String, dynamic>.from(box.get(key));
      items.add(SavedCaseModel(
        id: key.toString(),
        category: raw['category'] as String,
        problemSnippet: raw['problemSnippet'] as String,
        date: DateTime.parse(raw['date'] as String),
        status: raw['status'] as String,
        resultJson:
            json.decode(raw['resultJson'] as String) as Map<String, dynamic>,
      ));
    }
    state = items;
  }

  Future<void> add(SavedCaseModel c) async {
    final box = await _box;
    await box.put(c.id, {
      'category': c.category,
      'problemSnippet': c.problemSnippet,
      'date': c.date.toIso8601String(),
      'status': c.status,
      'resultJson': json.encode(c.resultJson),
    });
    
    // Log case saved event using SafeAnalytics
    await SafeAnalytics.logEvent(
      name: 'case_saved',
      parameters: {
        'category': c.category,
        'status': c.status,
      },
    );
    
    await _load();
  }

  Future<void> remove(String id) async {
    final box = await _box;
    await box.delete(id);
    await _load();
  }

  Future<void> markResolved(String id) async {
    final box = await _box;
    final raw = Map<String, dynamic>.from(box.get(id));
    raw['status'] = 'Resolved';
    await box.put(id, raw);
    await _load();
  }
}

final casesProvider = NotifierProvider<CasesNotifier, List<SavedCaseModel>>(CasesNotifier.new);

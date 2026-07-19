import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintState {
  final int generatedCount;
  final int freeLimit;
  final bool isPro;
  ComplaintState(
      {required this.generatedCount,
      required this.freeLimit,
      required this.isPro});

  ComplaintState copyWith({int? generatedCount, int? freeLimit, bool? isPro}) =>
      ComplaintState(
        generatedCount: generatedCount ?? this.generatedCount,
        freeLimit: freeLimit ?? this.freeLimit,
        isPro: isPro ?? this.isPro,
      );
}

class ComplaintNotifier extends Notifier<ComplaintState> {
  @override
  ComplaintState build() {
    _load();
    return ComplaintState(generatedCount: 0, freeLimit: 3, isPro: false);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      generatedCount: prefs.getInt('complaintLettersGenerated') ?? 0,
      freeLimit: prefs.getInt('freeLetterLimit') ?? 3,
      isPro: prefs.getBool('isPro') ?? false,
    );
  }

  Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final next = state.generatedCount + 1;
    await prefs.setInt('complaintLettersGenerated', next);
    state = state.copyWith(generatedCount: next);
  }
}

final complaintProvider = NotifierProvider<ComplaintNotifier, ComplaintState>(ComplaintNotifier.new);

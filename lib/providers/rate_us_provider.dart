import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateUsState {
  final int openCount;
  final int nextPromptCount;
  final bool neverAskAgain;
  final bool isInitialized;

  RateUsState({
    required this.openCount,
    required this.nextPromptCount,
    required this.neverAskAgain,
    required this.isInitialized,
  });

  RateUsState copyWith({
    int? openCount,
    int? nextPromptCount,
    bool? neverAskAgain,
    bool? isInitialized,
  }) {
    return RateUsState(
      openCount: openCount ?? this.openCount,
      nextPromptCount: nextPromptCount ?? this.nextPromptCount,
      neverAskAgain: neverAskAgain ?? this.neverAskAgain,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get shouldShowPrompt =>
      isInitialized && !neverAskAgain && openCount >= nextPromptCount;
}

class RateUsNotifier extends Notifier<RateUsState> {
  @override
  RateUsState build() {
    return RateUsState(
      openCount: 0,
      nextPromptCount: 5,
      neverAskAgain: false,
      isInitialized: false,
    );
  }

  Future<void> initAndIncrement() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load existing values
    final openCount = prefs.getInt('rate_us_open_count') ?? 0;
    final nextPromptCount = prefs.getInt('rate_us_next_prompt_count') ?? 5;
    final neverAskAgain = prefs.getBool('rate_us_never_ask') ?? false;

    final newOpenCount = openCount + 1;
    await prefs.setInt('rate_us_open_count', newOpenCount);

    state = RateUsState(
      openCount: newOpenCount,
      nextPromptCount: nextPromptCount,
      neverAskAgain: neverAskAgain,
      isInitialized: true,
    );
  }

  Future<void> maybeLater() async {
    final prefs = await SharedPreferences.getInstance();
    final newNextPromptCount = state.openCount + 10;
    await prefs.setInt('rate_us_next_prompt_count', newNextPromptCount);
    state = state.copyWith(nextPromptCount: newNextPromptCount);
  }

  Future<void> neverAsk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rate_us_never_ask', true);
    state = state.copyWith(neverAskAgain: true);
  }
}

final rateUsProvider =
    NotifierProvider<RateUsNotifier, RateUsState>(RateUsNotifier.new);

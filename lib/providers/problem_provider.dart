import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProblemState {
  final String category;
  final String description;
  const ProblemState({required this.category, required this.description});

  ProblemState copyWith({String? category, String? description}) =>
      ProblemState(
          category: category ?? this.category,
          description: description ?? this.description);
}

class ProblemNotifier extends Notifier<ProblemState> {
  @override
  ProblemState build() => ProblemState(category: '', description: '');

  void setCategory(String category) =>
      state = state.copyWith(category: category);
  void setDescription(String description) =>
      state = state.copyWith(description: description);
}

final problemProvider =
    NotifierProvider<ProblemNotifier, ProblemState>(ProblemNotifier.new);

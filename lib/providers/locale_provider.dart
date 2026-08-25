import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _selectedLanguageKey = 'selected_language';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    if (Hive.isBoxOpen('settings')) {
      final box = Hive.box('settings');
      final saved = box.get(_selectedLanguageKey, defaultValue: 'en') as String;
      return Locale(saved);
    }
    return const Locale('en');
  }

  void setLocale(Locale locale) {
    state = locale;
    if (Hive.isBoxOpen('settings')) {
      Hive.box('settings').put(_selectedLanguageKey, locale.languageCode);
    }
  }

  void toggle() {
    setLocale(
      state.languageCode == 'en' ? const Locale('hi') : const Locale('en'),
    );
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juslegal/core/config/theme_config.dart';
import 'package:juslegal/services/auth_handler.dart';
import 'package:juslegal/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState();
}

void main() {
  testWidgets('captures the themed home screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_TestAuthNotifier.new),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    // HomeScreen includes repeating decorative animations that never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('../screenshots/home_theme.png'),
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Professional JusLegal color system tuned for contrast and hierarchy.
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF003DA5);
  static const Color primaryLight = Color(0xFF2F6FDB);
  static const Color primaryDark = Color(0xFF001F54);
  static const Color primaryNavy = Color(0xFF001F54);
  static const Color trustBlue = Color(0xFF003DA5);
  static const Color trustNavy = Color(0xFF001F54);

  // Accent Colors
  static const Color legalGold = Color(0xFFF5A623);
  static const Color amber = Color(0xFFF5A623);
  static const Color amberDark = Color(0xFFB87400);
  static const Color coral = Color(0xFFFF5A5F);
  static const Color violet = Color(0xFF7C3AED);
  static const Color teal = Color(0xFF00A7A7);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundBlue = Color(0xFFEAF2FF);
  static const Color backgroundGold = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF666666);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // Category Icon Colors
  static const Color ecommerceOrange = Color(0xFFF5A623);
  static const Color bankingRed = Color(0xFFE11D48);
  static const Color travelBlue = Color(0xFF0EA5E9);
  static const Color housingGreen = Color(0xFF10B981);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFE11D48);
  static const Color warning = Color(0xFFF5A623);
  static const Color info = Color(0xFF0EA5E9);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // Status Colors
  static const Color caseOpen = Color(0xFF003DA5);
  static const Color caseInProgress = Color(0xFFF5A623);
  static const Color caseResolved = Color(0xFF10B981);
  static const Color caseRejected = Color(0xFFE11D48);

  // Shadow Colors
  static const Color shadow = Color(0x24001F54);
  static const Color shadowStrong = Color(0x3D001F54);
  static const Color shadowGold = Color(0x29F5A623);
  static const Color shadowBlack = Color(0x1F000000);

  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF001F54), Color(0xFF003DA5), Color(0xFF2F6FDB)],
    stops: [0.0, 0.58, 1.0],
  );

  static const Gradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF001F54), Color(0xFF003DA5)],
  );

  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5A623), Color(0xFFD89216)],
  );

  static const Gradient userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF001F54), Color(0xFF003DA5)],
  );

  static const Gradient botBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
  );

  static const Gradient cardBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const Gradient cardGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
  );
}


class AppTheme {
  static const Color primaryBlue = AppColors.primary;
  static const Color trustBlue = AppColors.trustBlue;
  static const Color trustNavy = AppColors.trustNavy;
  static const Color primaryNavy = AppColors.primaryNavy;
  static const Color primary = AppColors.primary;

  static const Color background = AppColors.background;
  static const Color backgroundOffWhite = AppColors.background;

  static const Color darkText = AppColors.textPrimary;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textDarkGrey = AppColors.textPrimary;

  static const Color mediumText = AppColors.textSecondary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMediumGrey = AppColors.textSecondary;

  static const Color surface = AppColors.cardBackground;
  static const Color surfaceWhite = AppColors.cardBackground;

  static const Color border = AppColors.border;
  static const Color divider = AppColors.divider;
  static const Color grey100 = AppColors.grey100;
  static const Color grey200 = AppColors.grey200;
  static const Color grey300 = AppColors.grey300;

  static const Color error = AppColors.error;
  static const Color warningSoftRed = AppColors.error;

  static const Color success = AppColors.success;
  static const Color successEmerald = AppColors.success;

  static const Color legalGold = AppColors.legalGold;
  static const Color justiceGold = AppColors.legalGold;
  static const Color accent = AppColors.legalGold;

  static const Gradient heroGradient = AppColors.heroGradient;
  static const Gradient accentGradient = AppColors.goldGradient;
  static const Gradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), Color(0xFF059669)],
  );

  static const Color shadow = AppColors.shadow;
  static const Color shadowGold = AppColors.shadowGold;

  static const Color caseOpen = AppColors.caseOpen;
  static const Color caseInProgress = AppColors.caseInProgress;
  static const Color caseResolved = AppColors.caseResolved;
  static const Color caseRejected = AppColors.caseRejected;

  static const double radiusS = 8;
  static const double radiusM = 16;
  static const double radiusL = 24;

  static Gradient cardGradientFor(Color accentColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.cardBackground,
        Color.alphaBlend(accentColor.withValues(alpha: 0.04), AppColors.grey50),
      ],
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      primary: primaryBlue,
      secondary: legalGold,
      tertiary: AppColors.teal,
      error: error,
      surface: AppColors.cardBackground,
      onPrimary: AppColors.white,
      onSecondary: primaryNavy,
      onSurface: darkText,
    );

    const textTheme = TextTheme(
      headlineLarge: TextStyle(
        color: darkText,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.18,
      ),
      headlineMedium: TextStyle(
        color: darkText,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        color: darkText,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.22,
      ),
      titleLarge: TextStyle(
        color: darkText,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.25,
      ),
      titleMedium: TextStyle(
        color: darkText,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        color: darkText,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        color: darkText,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: darkText,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        color: mediumText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: darkText,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: AppColors.shadow,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: darkText, size: 24),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.cardBackground,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: AppColors.shadowBlack,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: const BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.grey300,
          disabledForegroundColor: AppColors.grey600,
          elevation: 4,
          shadowColor: AppColors.shadow,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          textStyle: textTheme.labelLarge,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.18),
          ),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return 0;
            if (states.contains(WidgetState.pressed)) return 10;
            return 6;
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: AppColors.white,
          elevation: 4,
          shadowColor: AppColors.shadow,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: legalGold, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNavy,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelMedium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: legalGold,
        foregroundColor: primaryNavy,
        elevation: 8,
        focusElevation: 10,
        hoverElevation: 10,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryBlue, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.backgroundBlue,
        labelStyle: textTheme.labelSmall?.copyWith(color: primaryNavy),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: legalGold,
        linearTrackColor: AppColors.backgroundBlue,
        circularTrackColor: AppColors.backgroundBlue,
      ),
    );
  }
}



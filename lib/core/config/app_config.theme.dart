// -----------------------------------------------------------------------------
// app_config.theme.dart — Theme/color system (formerly core/config/theme_config.dart)
// -----------------------------------------------------------------------------
part of 'app_config.dart';

/// Forest-inspired green color system for legal guidance application.
/// Centers on growth, stability, and natural order with a calm, life-affirming environment.
class AppColors {
  // Tropical Rainforest design tokens.
  static const Color deepForest = Color(0xFF0B3D2E);
  static const Color deepForestDark = Color(0xFF062B20);
  static const Color brightEmerald = Color(0xFF50C878);

  // Surface Colors
  static const Color surface = Color(0xFFF7FBF8);
  static const Color surfaceDim = Color(0xFFE4EFE8);
  static const Color surfaceBright = Color(0xFFF7FBF8);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEEF6F0);
  static const Color surfaceContainer = Color(0xFFE4F0E8);
  static const Color surfaceContainerHigh = Color(0xFFD9E9DF);
  static const Color surfaceContainerHighest = Color(0xFFCEE2D5);
  static const Color onSurface = Color(0xFF17271F);
  static const Color onSurfaceVariant = Color(0xFF52645A);
  static const Color inverseSurface = deepForest;
  static const Color inverseOnSurface = Color(0xFFE8F8EE);
  static const Color outline = Color(0xFFB9CDC0);
  static const Color outlineVariant = Color(0xFFD8E6DC);
  static const Color surfaceTint = deepForest;

  // Primary Colors (Emerald)
  static const Color primary = brightEmerald;
  static const Color onPrimary = deepForestDark;
  static const Color primaryContainer = brightEmerald;
  static const Color onPrimaryContainer = deepForest;
  static const Color inversePrimary = Color(0xFF66DD8B);
  static const Color primaryFixed = Color(0xFF83FBA5);
  static const Color primaryFixedDim = Color(0xFF66DD8B);
  static const Color onPrimaryFixed = Color(0xFF00210C);
  static const Color onPrimaryFixedVariant = Color(0xFF005227);

  // Secondary Colors (Forest)
  static const Color secondary = deepForest;
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFBDEDAA);
  static const Color onSecondaryContainer = Color(0xFF436D37);
  static const Color secondaryFixed = Color(0xFFC0F0AD);
  static const Color secondaryFixedDim = Color(0xFFA4D393);
  static const Color onSecondaryFixed = Color(0xFF022100);
  static const Color onSecondaryFixedVariant = Color(0xFF28501E);

  // Tertiary Colors (Moss)
  static const Color tertiary = Color(0xFF3C6A00);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF87C249);
  static const Color onTertiaryContainer = Color(0xFF2A4D00);
  static const Color tertiaryFixed = Color(0xFFB6F575);
  static const Color tertiaryFixedDim = Color(0xFF9BD85C);
  static const Color onTertiaryFixed = Color(0xFF0E2000);
  static const Color onTertiaryFixedVariant = Color(0xFF2C5000);

  // Error Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Background Colors
  static const Color background = Color(0xFFF3FFCA);
  static const Color onBackground = Color(0xFF161E00);
  static const Color surfaceVariant = Color(0xFFDAE9A9);

  // Legacy Color Names (for backward compatibility)
  static const Color legalGold = primary;
  static const Color amber = primary;
  static const Color success = primaryContainer;
  static const Color successEmerald = primaryContainer;
  static const Color warning = tertiary;
  static const Color accent = primary;
  static const Color justiceGold = primary;

  // Additional legacy colors for existing codebase compatibility
  static const Color primaryNavy = primary;
  static const Color trustBlue = secondary;
  static const Color cardBackground = surfaceContainerLowest;
  static const Color primaryBlue = primary;
  static const Color backgroundBlue = surfaceContainerLow;
  static const Color primaryDark = primary;
  static const Color primaryLight = primaryContainer;
  static const Color amberDark = primary;

  // Text Colors
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textDark = onSurface;
  static const Color textLight = onSurfaceVariant;

  // Border Colors
  static const Color border = outline;
  static const Color borderLow = outlineVariant;
  static const Color divider = outlineVariant;

  // Neutral Colors
  static const Color white = surfaceContainerLowest;
  static const Color grey50 = surfaceContainerLowest;
  static const Color grey100 = surfaceContainerLow;
  static const Color grey200 = surfaceContainer;
  static const Color grey300 = surfaceContainerHigh;
  static const Color grey400 = outline;
  static const Color grey500 = onSurfaceVariant;
  static const Color grey600 = surfaceTint;
  static const Color grey700 = secondary;
  static const Color grey800 = tertiary;
  static const Color grey900 = primary;

  // Status Colors
  static const Color caseOpen = primary;
  static const Color caseInProgress = tertiary;
  static const Color caseResolved = primaryContainer;
  static const Color caseRejected = error;

  // Shadow Colors (soft green-tinted shadows)
  static const Color shadow = Color(0x0D4F7942); // 5% forest green
  static const Color shadowStrong = Color(0x1A4F7942); // 10% forest green
  static const Color shadowGold = Color(0x0D006D36); // 5% primary green
  static const Color shadowBlack = Color(0x0D000000); // 5% black

  // Gradients
  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepForest, deepForestDark, Color(0xFF104B37)],
    stops: [0.0, 0.55, 1.0],
  );

  static const Gradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepForest, deepForestDark],
  );

  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryContainer, primary],
  );

  static const Gradient userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceContainerLow, surface],
  );

  static const Gradient botBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surface, surfaceContainerLow],
  );

  static const Gradient cardBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceContainerLowest, surfaceContainerLow],
  );

  static const Gradient cardGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceContainerLowest, surfaceContainerLow],
  );

  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, surfaceContainerLow],
  );

  static const Gradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tertiaryContainer, primaryContainer],
  );
}

class AppTheme {
  // Legacy color name compatibility
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color backgroundOffWhite = AppColors.surface;
  static const Color darkText = AppColors.textPrimary;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textDarkGrey = AppColors.textPrimary;
  static const Color mediumText = AppColors.textSecondary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMediumGrey = AppColors.textSecondary;
  static const Color surface = AppColors.surface;
  static const Color surfaceBright = AppColors.surfaceBright;
  static const Color surfaceWhite = AppColors.surfaceContainerLowest;
  static const Color border = AppColors.border;
  static const Color divider = AppColors.divider;
  static const Color grey100 = AppColors.grey100;
  static const Color grey200 = AppColors.grey200;
  static const Color grey300 = AppColors.grey300;
  static const Color error = AppColors.error;
  static const Color warningSoftRed = AppColors.error;
  static const Color success = AppColors.success;
  static const Color successEmerald = AppColors.successEmerald;
  static const Color legalGold = AppColors.legalGold;
  static const Color justiceGold = AppColors.legalGold;
  static const Color accent = AppColors.accent;
  static const Color shadow = AppColors.shadow;
  static const Color shadowGold = AppColors.shadowGold;
  static const Color caseOpen = AppColors.caseOpen;
  static const Color caseInProgress = AppColors.caseInProgress;
  static const Color caseResolved = AppColors.caseResolved;
  static const Color caseRejected = AppColors.caseRejected;

  // Additional legacy colors for existing codebase compatibility
  static const Color primaryNavy = AppColors.primaryNavy;
  static const Color trustBlue = AppColors.trustBlue;
  static const Color cardBackground = AppColors.cardBackground;
  static const Color primaryBlue = AppColors.primaryBlue;
  static const Color backgroundBlue = AppColors.backgroundBlue;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color amberDark = AppColors.amberDark;

  // Rounded corners (from design system)
  static const double radiusS = 4; // 0.25rem = 4px
  static const double radiusM = 8; // 0.5rem = 8px (DEFAULT)
  static const double radiusL = 16; // 1rem = 16px
  static const double radiusXL = 24; // 1.5rem = 24px

  // Gradients
  static const Gradient heroGradient = AppColors.heroGradient;
  static const Gradient accentGradient = AppColors.goldGradient;
  static const Gradient successGradient = AppColors.successGradient;

  static Gradient cardGradientFor(Color accentColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.surfaceContainerLowest,
        Color.alphaBlend(
            accentColor.withValues(alpha: 0.08), AppColors.surfaceContainerLow),
      ],
    );
  }

  static ThemeData get lightTheme => forestTheme;

  static ThemeData get forestTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    // Typography based on design system (Noto Sans)
    // Using Google Fonts for Noto Sans with Indian language support
    final baseTextStyle = GoogleFonts.notoSans(
      color: AppColors.onSurface,
    );

    final textTheme = TextTheme(
      displayLarge: baseTextStyle.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.17, // 56px/48px
        letterSpacing: -0.02,
      ),
      displayMedium: baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25, // 40px/32px
        letterSpacing: -0.01,
      ),
      displaySmall: baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29, // 36px/28px
      ),
      headlineLarge: baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33, // 32px/24px
      ),
      headlineMedium: baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      headlineSmall: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleLarge: baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleSmall: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyLarge: baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.56, // 28px/18px
      ),
      bodyMedium: baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5, // 24px/16px
      ),
      bodySmall: baseTextStyle.copyWith(
        color: AppColors.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43, // 20px/14px
        letterSpacing: 0.01,
      ),
      labelMedium: baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33, // 16px/12px
        letterSpacing: 0.02,
      ),
      labelSmall: baseTextStyle.copyWith(
        color: AppColors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.02,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: AppColors.shadow,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: const IconThemeData(color: AppColors.onSurface, size: 24),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.surface,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: AppColors.shadow,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceContainer,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          elevation: 2,
          shadowColor: AppColors.shadowGold,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onPrimary,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.08),
          ),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return 0;
            if (states.contains(WidgetState.pressed)) return 4;
            return 2;
          }),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          shadowColor: AppColors.shadowGold,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: AppColors.outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelMedium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.tertiaryContainer.withValues(alpha: 0.3),
        selectedColor: AppColors.tertiaryContainer,
        labelStyle: textTheme.labelSmall?.copyWith(color: AppColors.onSurface),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryContainer,
        linearTrackColor: AppColors.surfaceContainer,
        circularTrackColor: AppColors.surfaceContainer,
        linearMinHeight: 4,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainer;
          }
          return AppColors.surfaceContainer;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainer;
          }
          return AppColors.surfaceContainer;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainer;
          }
          return AppColors.surfaceContainer;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.outlineVariant;
        }),
      ),
    );
  }
}

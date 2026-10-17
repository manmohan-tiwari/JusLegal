// -----------------------------------------------------------------------------
// app_config.theme.dart — JusLegal Design System
// Matches exact visual reference: Warm off-white, Deep Navy, Mustard Gold, Slate Blue, Soft Pastels
// -----------------------------------------------------------------------------
part of 'app_config.dart';

/// Design tokens matching the visual design reference.
/// Palette:
/// - Deep Navy: #162B49
/// - Blue / Slate Blue: #2B608E
/// - Warm Off-White: #FAF8F2
/// - Mustard Gold: #F5B52E
/// - Pale Blue: #E2EDF3
/// - Pale Yellow: #FBECC5
/// - Pale Green: #E0EDE2
/// - Pale Peach: #F4E1D5
class AppColors {
  // Primary brand palette from reference
  static const Color deepNavy = Color(0xFF162B49);
  static const Color deepNavyDark = Color(0xFF0F1E33);
  static const Color navyBlue = Color(0xFF2B608E);
  static const Color blue = Color(0xFF2B608E);
  static const Color slateBlue = Color(0xFF2B608E);
  static const Color warmOffWhite = Color(0xFFFAF8F2);
  static const Color mustardGold = Color(0xFFF5B52E);
  static const Color mustardGoldDark = Color(0xFFDE9E1B);

  // Soft Pastel Card & Surface Tones
  static const Color paleBlue = Color(0xFFE2EDF3);
  static const Color paleYellow = Color(0xFFFBECC5);
  static const Color paleGreen = Color(0xFFE0EDE2);
  static const Color palePeach = Color(0xFFF4E1D5);

  /// Helper list for cycling pastel cards sequentially (as seen in Screenshot 1)
  static const List<Color> pastelColors = [
    paleBlue,
    paleYellow,
    paleGreen,
    palePeach,
  ];

  // Surface Colors
  static const Color surface = warmOffWhite;
  static const Color surfaceDim = Color(0xFFF0EBE0);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = warmOffWhite;
  static const Color surfaceContainer = paleBlue;
  static const Color surfaceContainerHigh = paleYellow;
  static const Color surfaceContainerHighest = paleGreen;
  static const Color onSurface = deepNavy;
  static const Color onSurfaceVariant = navyBlue;
  static const Color inverseSurface = deepNavy;
  static const Color inverseOnSurface = Color(0xFFF4F7FB);
  static const Color outline = Color(0xFFD4E2EC);
  static const Color outlineVariant = Color(0xFFE5EDF4);
  static const Color surfaceTint = deepNavy;

  // Primary Colors (Mustard Gold for key CTAs / highlights)
  static const Color primary = mustardGold;
  static const Color onPrimary = deepNavy;
  static const Color primaryContainer = mustardGold;
  static const Color onPrimaryContainer = deepNavy;
  static const Color inversePrimary = Color(0xFFFFD575);
  static const Color primaryFixed = Color(0xFFFBECC5);
  static const Color primaryFixedDim = Color(0xFFF5B52E);
  static const Color onPrimaryFixed = deepNavy;
  static const Color onPrimaryFixedVariant = Color(0xFF6B4B03);

  // Secondary Colors (Navy Blue / Slate)
  static const Color secondary = navyBlue;
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = paleBlue;
  static const Color onSecondaryContainer = deepNavy;
  static const Color secondaryFixed = paleBlue;
  static const Color secondaryFixedDim = Color(0xFFC3DCE9);
  static const Color onSecondaryFixed = deepNavy;
  static const Color onSecondaryFixedVariant = Color(0xFF162B49);

  // Tertiary Colors (Soft Green & Nature accents)
  static const Color tertiary = Color(0xFF2E6B47);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = paleGreen;
  static const Color onTertiaryContainer = Color(0xFF0F3B20);
  static const Color tertiaryFixed = paleGreen;
  static const Color tertiaryFixedDim = Color(0xFFC2DEC6);
  static const Color onTertiaryFixed = Color(0xFF0B2E18);
  static const Color onTertiaryFixedVariant = Color(0xFF1D5232);

  // Error Colors (Restrained, respectful red)
  static const Color error = Color(0xFFC62828);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onErrorContainer = Color(0xFF7F1313);

  // Background Colors
  static const Color background = warmOffWhite;
  static const Color onBackground = deepNavy;
  static const Color surfaceVariant = paleBlue;

  // Brand Name Aliases & Backward Compatibility
  static const Color deepForest = deepNavy;
  static const Color deepForestDark = deepNavyDark;
  static const Color brightEmerald = mustardGold;
  static const Color legalGold = mustardGold;
  static const Color amber = mustardGold;
  static const Color amberDark = mustardGoldDark;
  static const Color success = Color(0xFF2E7D32);
  static const Color successEmerald = Color(0xFF2E7D32);
  static const Color warning = mustardGold;
  static const Color accent = mustardGold;
  static const Color justiceGold = mustardGold;
  static const Color primaryNavy = deepNavy;
  static const Color trustBlue = navyBlue;
  static const Color cardBackground = surfaceContainerLowest;
  static const Color primaryBlue = navyBlue;
  static const Color backgroundBlue = paleBlue;
  static const Color primaryDark = deepNavy;
  static const Color primaryLight = paleBlue;

  // Text Colors
  static const Color textPrimary = deepNavy;
  static const Color textSecondary = navyBlue;
  static const Color textDark = deepNavy;
  static const Color textLight = navyBlue;
  static const Color textMuted = Color(0xFF6B8299);

  // Border & Divider Colors
  static const Color border = outline;
  static const Color borderLow = outlineVariant;
  static const Color divider = Color(0x332B608E); // Thin subtle blue divider line

  // Neutral Colors
  static const Color white = surfaceContainerLowest;
  static const Color grey50 = warmOffWhite;
  static const Color grey100 = Color(0xFFF3EFE6);
  static const Color grey200 = Color(0xFFE6E2D8);
  static const Color grey300 = Color(0xFFD0DCE5);
  static const Color grey400 = outline;
  static const Color grey500 = Color(0xFF889BB0);
  static const Color grey600 = navyBlue;
  static const Color grey700 = Color(0xFF1E3A63);
  static const Color grey800 = Color(0xFF172C4B);
  static const Color grey900 = deepNavy;

  // Status Colors
  static const Color caseOpen = mustardGold;
  static const Color caseInProgress = navyBlue;
  static const Color caseResolved = Color(0xFF2E7D32);
  static const Color caseRejected = error;

  // Shadow Colors (Subtle navy & gold tinted shadows)
  static const Color shadow = Color(0x0F162B49);
  static const Color shadowStrong = Color(0x1F162B49);
  static const Color shadowGold = Color(0x24F5B52E);
  static const Color shadowBlack = Color(0x0A000000);

  // Gradients
  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, deepNavyDark],
    stops: [0.0, 1.0],
  );

  static const Gradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warmOffWhite, warmOffWhite],
  );

  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC74F), mustardGold],
  );

  static const Gradient userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, Color(0xFF1C375C)],
  );

  static const Gradient botBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [paleBlue, Color(0xFFD6E6F0)],
  );

  static const Gradient cardBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceContainerLowest, paleBlue],
  );

  static const Gradient cardGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceContainerLowest, paleYellow],
  );

  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [warmOffWhite, Color(0xFFF4EFE6)],
  );

  static const Gradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [paleGreen, Color(0xFFC7E2CA)],
  );
}

class AppTheme {
  // Legacy color name compatibility
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color backgroundOffWhite = AppColors.warmOffWhite;
  static const Color darkText = AppColors.deepNavy;
  static const Color textPrimary = AppColors.deepNavy;
  static const Color textDarkGrey = AppColors.deepNavy;
  static const Color mediumText = AppColors.navyBlue;
  static const Color textSecondary = AppColors.navyBlue;
  static const Color textMediumGrey = AppColors.navyBlue;
  static const Color slateBlue = AppColors.slateBlue;
  static const Color surface = AppColors.warmOffWhite;
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
  static const Color primaryNavy = AppColors.deepNavy;
  static const Color trustBlue = AppColors.navyBlue;
  static const Color cardBackground = AppColors.cardBackground;
  static const Color primaryBlue = AppColors.navyBlue;
  static const Color backgroundBlue = AppColors.paleBlue;
  static const Color primaryDark = AppColors.deepNavy;
  static const Color primaryLight = AppColors.paleBlue;
  static const Color amberDark = AppColors.amberDark;

  // Rounded corners (clean, modest rounded corners from screenshots)
  static const double radiusS = 6;
  static const double radiusM = 12; // Default modest corner radius
  static const double radiusL = 16;
  static const double radiusXL = 20;

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
          accentColor.withValues(alpha: 0.12),
          AppColors.surfaceContainerLowest,
        ),
      ],
    );
  }

  static ThemeData get lightTheme => editorialTheme;
  static ThemeData get forestTheme => editorialTheme;

  static ThemeData get editorialTheme {
    const colorScheme = ColorScheme(
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

    // Typography using Plus Jakarta Sans (Clean modern sans-serif matching screenshot)
    final baseTextStyle = GoogleFonts.plusJakartaSans(
      color: AppColors.deepNavy,
    );

    final textTheme = TextTheme(
      displayLarge: baseTextStyle.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.02,
        color: AppColors.deepNavy,
      ),
      displayMedium: baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.01,
        color: AppColors.deepNavy,
      ),
      displaySmall: baseTextStyle.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.deepNavy,
      ),
      headlineLarge: baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.deepNavy,
      ),
      headlineMedium: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.deepNavy,
      ),
      headlineSmall: baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.deepNavy,
      ),
      titleLarge: baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.deepNavy,
      ),
      titleMedium: baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.deepNavy,
      ),
      titleSmall: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.deepNavy,
      ),
      bodyLarge: baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.deepNavy,
      ),
      bodyMedium: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.deepNavy,
      ),
      bodySmall: baseTextStyle.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.navyBlue,
      ),
      labelLarge: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0.01,
        color: AppColors.deepNavy,
      ),
      labelMedium: baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.02,
        color: AppColors.navyBlue,
      ),
      labelSmall: baseTextStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 1.2, // Small uppercase section headers
        color: AppColors.navyBlue,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.warmOffWhite,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.warmOffWhite,
        foregroundColor: AppColors.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: AppColors.shadow,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.deepNavy, size: 24),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.warmOffWhite,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: AppColors.shadow,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: const BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mustardGold,
          foregroundColor: AppColors.deepNavy,
          disabledBackgroundColor: AppColors.grey200,
          disabledForegroundColor: AppColors.grey500,
          elevation: 0,
          shadowColor: AppColors.shadowGold,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.deepNavy,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.paleBlue,
          foregroundColor: AppColors.deepNavy,
          elevation: 0,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.deepNavy,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepNavy,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.navyBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.deepNavy,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.navyBlue,
          minimumSize: const Size(48, 44),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.navyBlue,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.mustardGold,
        foregroundColor: AppColors.deepNavy,
        elevation: 3,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
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
          borderSide: const BorderSide(color: AppColors.navyBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.navyBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paleBlue,
        selectedColor: AppColors.mustardGold,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mustardGold,
        linearTrackColor: AppColors.paleBlue,
        circularTrackColor: AppColors.paleBlue,
        linearMinHeight: 6,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mustardGold;
          }
          return AppColors.surfaceContainerLowest;
        }),
        checkColor: WidgetStateProperty.all(AppColors.deepNavy),
        side: const BorderSide(color: AppColors.outline, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mustardGold;
          }
          return AppColors.navyBlue;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.deepNavy;
          }
          return AppColors.grey500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mustardGold;
          }
          return AppColors.outline;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.warmOffWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: AppColors.shadowStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: AppColors.outline),
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.deepNavy,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.warmOffWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AppColors.shadowStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepNavy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}


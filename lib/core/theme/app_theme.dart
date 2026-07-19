import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color trustBlue = Color(0xFF0052CC);
  static const Color trustNavy = Color(0xFF0052CC);
  static const Color primaryNavy = Color(0xFF0052CC);
  static const Color primary = Color(0xFF0052CC);
  
  static const Color background = Color(0xFFF5F7FF);
  static const Color backgroundOffWhite = Color(0xFFF5F7FF);
  
  static const Color darkText = Color(0xFF1F2937);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textDarkGrey = Color(0xFF1F2937);
  
  static const Color mediumText = Color(0xFF6B7280);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMediumGrey = Color(0xFF6B7280);
  
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey100 = Color(0xFFF3F4F6);
  
  static const Color error = Color(0xFFDC2626);
  static const Color warningSoftRed = Color(0xFFDC2626);
  
  static const Color success = Color(0xFF10B981);
  static const Color successEmerald = Color(0xFF10B981);
  
  static const Color legalGold = Color(0xFFFCA311);
  static const Color justiceGold = Color(0xFFFCA311);
  static const Color accent = Color(0xFFFCA311);
  
  static const Gradient heroGradient = LinearGradient(
    colors: [Color(0xFF0052CC), Color(0xFF0052CC)],
  );
  
  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFFFCA311), Color(0xFFFCA311)],
  );
  
  static const Gradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF10B981)],
  );
  
  static const Color shadow = Color(0x0A0052CC);
  static const Color shadowGold = Color(0x0AFCA311);
  
  static const Color caseOpen = Color(0xFF0052CC);
  static const Color caseInProgress = Color(0xFFFCA311);
  static const Color caseResolved = Color(0xFF10B981);
  static const Color caseRejected = Color(0xFFDC2626);
  
  static const double radiusS = 4;
  static const double radiusM = 8;
  static const double radiusL = 12;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryBlue,
      onPrimary: surface,
      secondary: legalGold,
      onSecondary: surface,
      error: error,
      onError: surface,
      surface: surface,
      onSurface: darkText,
    );

    final textTheme = TextTheme(
      headlineSmall: TextStyle(
        color: darkText,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: darkText,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: darkText,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: darkText,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: mediumText,
        fontSize: 12,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: darkText),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
      ),
    );
  }
}

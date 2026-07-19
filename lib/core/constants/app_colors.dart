import 'package:flutter/material.dart';

/// Original JusLegal color palette
/// 
/// These are the original brand colors extracted from the app screenshot.
/// Use these colors directly in widgets with Color() constructors.
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF0052CC); // Bright Blue (app icon & buttons)
  static const Color primaryLight = Color(0xFF3B78E0); // Lighter blue variant
  static const Color primaryDark = Color(0xFF003D99); // Darker blue variant

  // Background Colors
  static const Color background = Color(0xFFF5F7FF); // Very Light Blue background
  static const Color surface = Color(0xFFFFFFFF); // White cards
  static const Color cardBackground = Color(0xFFFFFFFF); // White cards

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark Gray/Navy text
  static const Color textSecondary = Color(0xFF6B7280); // Medium Gray text
  static const Color textDark = Color(0xFF1F2937); // Dark text
  static const Color textLight = Color(0xFF6B7280); // Light gray text

  // Border Colors
  static const Color border = Color(0xFFE5E7EB); // Light Gray borders
  static const Color divider = Color(0xFFE5E7EB); // Light Gray dividers

  // Category Icon Colors
  static const Color ecommerceOrange = Color(0xFFFCA311); // E-commerce Orange/Gold
  static const Color bankingRed = Color(0xFFDC2626); // Banking Red
  static const Color travelBlue = Color(0xFF0EA5E9); // Travel Light Blue
  static const Color housingGreen = Color(0xFF10B981); // Housing Green

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color error = Color(0xFFDC2626); // Red
  static const Color warning = Color(0xFFFCA311); // Orange/Gold
  static const Color info = Color(0xFF0EA5E9); // Light Blue

  // Legacy aliases for backward compatibility
  static const Color trustBlue = Color(0xFF0052CC); // Same as primary
  static const Color legalGold = Color(0xFFFCA311); // Orange/Gold
  static const Color primaryNavy = Color(0xFF1F2937); // Dark text color

  // Neutral Colors (grayscale)
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Status Colors
  static const Color caseOpen = Color(0xFF0052CC);
  static const Color caseInProgress = Color(0xFFFCA311);
  static const Color caseResolved = Color(0xFF10B981);
  static const Color caseRejected = Color(0xFFDC2626);

  // Shadow Colors
  static const Color shadow = Color(0x0A0052CC); // Blue shadow with opacity
  static const Color shadowGold = Color(0x0AFCA311); // Gold shadow with opacity
}
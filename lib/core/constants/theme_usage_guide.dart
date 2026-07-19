import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// This file demonstrates how to use the new JusLegal theme system
/// Copy these examples throughout your app for consistent styling

class ThemeUsageGuide {
  // ===== COLOR USAGE EXAMPLES =====
  
  // Primary brand colors
  static Color get primaryNavy => AppTheme.trustNavy;
  static Color get accentGold => AppTheme.justiceGold;
  static Color get background => AppTheme.backgroundOffWhite;
  static Color get surface => AppTheme.surfaceWhite;
  
  // Semantic colors
  static Color get success => AppTheme.successEmerald;
  static Color get warning => AppTheme.warningSoftRed;
  static Color get textPrimary => AppTheme.textDarkGrey;
  static Color get textSecondary => AppTheme.textMediumGrey;
  
  // Status colors for cases
  static Color get caseOpenColor => AppTheme.caseOpen;
  static Color get caseInProgressColor => AppTheme.caseInProgress;
  static Color get caseResolvedColor => AppTheme.caseResolved;
  static Color get caseRejectedColor => AppTheme.caseRejected;

  // ===== GRADIENT USAGE EXAMPLES =====
  
  static BoxDecoration get heroDecoration => BoxDecoration(
    gradient: AppTheme.heroGradient,
    borderRadius: BorderRadius.circular(8),
  );
  
  static BoxDecoration get accentDecoration => BoxDecoration(
    gradient: AppTheme.accentGradient,
    borderRadius: BorderRadius.circular(8),
  );
  
  static BoxDecoration get successDecoration => BoxDecoration(
    gradient: AppTheme.successGradient,
    borderRadius: BorderRadius.circular(8),
  );

  // ===== TYPOGRAPHY USAGE EXAMPLES =====
  
  // Display text (for hero sections)
  static TextStyle get displayStyle => GoogleFonts.merriweather(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppTheme.textDarkGrey,
    height: 1.25,
  );
  
  // Headings (for sections)
  static TextStyle get headingStyle => GoogleFonts.merriweather(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppTheme.textDarkGrey,
    height: 1.33,
  );
  
  // Titles (for cards and list items)
  static TextStyle get titleStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppTheme.textDarkGrey,
    height: 1.5,
  );
  
  // Body text (for content)
  static TextStyle get bodyStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.textDarkGrey,
    height: 1.43,
  );
  
  // Caption text (for metadata)
  static TextStyle get captionStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppTheme.textMediumGrey,
    height: 1.33,
  );

  // ===== COMPONENT EXAMPLES =====
  
  // Primary action button
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppTheme.trustNavy,
    foregroundColor: AppTheme.surfaceWhite,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );
  
  // Secondary action button
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    backgroundColor: AppTheme.justiceGold,
    foregroundColor: AppTheme.trustNavy,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );
  
  // Card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppTheme.surfaceWhite,
    borderRadius: BorderRadius.circular(4),
    boxShadow: const [
      BoxShadow(
        color: AppTheme.shadow,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
  
  // Input field decoration
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: AppTheme.backgroundOffWhite,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: AppTheme.grey300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: AppTheme.trustNavy, width: 2),
    ),
    labelStyle: GoogleFonts.inter(
      color: AppTheme.textMediumGrey,
      fontSize: 12,
    ),
    floatingLabelStyle: GoogleFonts.inter(
      color: AppTheme.justiceGold,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );

  // ===== WIDGET EXAMPLES =====
  
  // Status chip for cases
  static Widget buildStatusChip(String status, BuildContext context) {
    Color backgroundColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'open':
        backgroundColor = AppTheme.trustNavy.withValues(alpha: 0.1);
        textColor = AppTheme.trustNavy;
        break;
      case 'in progress':
        backgroundColor = AppTheme.justiceGold.withValues(alpha: 0.1);
        textColor = AppTheme.justiceGold;
        break;
      case 'resolved':
        backgroundColor = AppTheme.successEmerald.withValues(alpha: 0.1);
        textColor = AppTheme.successEmerald;
        break;
      case 'rejected':
        backgroundColor = AppTheme.warningSoftRed.withValues(alpha: 0.1);
        textColor = AppTheme.warningSoftRed;
        break;
      default:
        backgroundColor = AppTheme.grey100;
        textColor = AppTheme.textMediumGrey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
  
  // Hero banner widget
  static Widget buildHeroBanner(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: ThemeUsageGuide.heroDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.merriweather(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: AppTheme.surfaceWhite,
              height: 1.29,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.surfaceWhite.withValues(alpha: 0.9),
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }
  
  // Feature card widget
  static Widget buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: AppTheme.trustNavy,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: ThemeUsageGuide.titleStyle,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: ThemeUsageGuide.captionStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== USAGE IN WIDGETS =====

/*
HOW TO USE IN YOUR WIDGETS:

1. ACCESSING COLORS:
   - Instead of: Colors.blue
   - Use: AppTheme.trustNavy

2. ACCESSING TYPOGRAPHY:
   - Instead of: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
   - Use: ThemeUsageGuide.titleStyle

3. ACCESSING GRADIENTS:
   - Container(decoration: ThemeUsageGuide.heroDecoration)

4. BUILDING COMPONENTS:
   - ThemeUsageGuide.buildStatusChip('Open', context)
   - ThemeUsageGuide.buildHeroBanner('Title', 'Subtitle')
   - ThemeUsageGuide.buildFeatureCard(...)

5. THEME CONTEXT:
   - Theme.of(context).primaryColor // Returns AppTheme.trustNavy
   - Color(0xFF1F2937) // Dark Gray/Navy text
   - Theme.of(context).textTheme.titleLarge // Uses Merriweather font

6. BUTTON STYLES:
   - ElevatedButton(..., style: ThemeUsageGuide.primaryButtonStyle)
   - OutlinedButton(..., style: ThemeUsageGuide.secondaryButtonStyle)

7. INPUT FIELDS:
   - TextField(decoration: ThemeUsageGuide.inputDecoration)

EXAMPLE WIDGET:

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JusLegal', style: ThemeUsageGuide.headingStyle),
        backgroundColor: AppTheme.trustNavy,
      ),
      body: Column(
        children: [
          ThemeUsageGuide.buildHeroBanner(
            'Know Your Rights',
            'Legal assistance for Indian citizens',
          ),
          const SizedBox(height: 16),
          Card(
            decoration: ThemeUsageGuide.cardDecoration,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Case Status', style: ThemeUsageGuide.titleStyle),
                  const SizedBox(height: 8),
                  ThemeUsageGuide.buildStatusChip('In Progress', context),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ThemeUsageGuide.primaryButtonStyle,
                    child: Text('Take Action'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/

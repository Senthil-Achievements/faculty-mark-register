import 'package:flutter/material.dart';

class NeonTheme {
  // Professional Purple Palette
  static const Color primaryPurple = Color(0xFF9E4B8A); // Bright accent color
  static const Color mediumPurple =
      Color(0xFF4C2A59); // Medium purple for cards
  static const Color darkPurple = Color(0xFF1E1E2F); // Dark background

  // Additional accent colors
  static const Color accentPink =
      Color(0xFFE67FB3); // Lighter pink for highlights
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonOrange = Color(0xFFFF9500);

  // Background colors
  static const Color darkBg = darkPurple;
  static const Color cardBg = mediumPurple;
  static const Color surfaceBg = Color(0xFF2A2A40);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryPurple,
      colorScheme: ColorScheme.dark(
        primary: primaryPurple,
        secondary: accentPink,
        tertiary: mediumPurple,
        surface: surfaceBg,
        surfaceContainer: cardBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: Color(0xFFFF6B9D),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: accentPink,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: accentPink),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 8,
        shadowColor: primaryPurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: primaryPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryPurple.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentPink, width: 2),
        ),
        labelStyle: TextStyle(color: accentPink.withOpacity(0.9)),
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: primaryPurple.withOpacity(0.5),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: accentPink,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        headlineMedium: TextStyle(
          color: accentPink,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: accentPink,
        size: 24,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryPurple,
        circularTrackColor: surfaceBg,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: primaryPurple.withOpacity(0.2),
        thickness: 1,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBg,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryPurple.withOpacity(0.5)),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryPurple.withOpacity(0.5)),
        ),
        titleTextStyle: const TextStyle(
          color: accentPink,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        tileColor: surfaceBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: accentPink,
        textColor: Colors.white,
      ),
    );
  }

  // Gradient decorations
  static BoxDecoration neonGradientBox({
    List<Color>? colors,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors ?? [primaryPurple, mediumPurple, accentPink],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: (colors?.first ?? primaryPurple).withOpacity(0.5),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration neonBorderBox({
    Color color = primaryPurple,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color.withOpacity(0.5),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    );
  }
}

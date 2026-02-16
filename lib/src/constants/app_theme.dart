import 'package:flutter/material.dart';

class AppTheme {
  // Custom Colors from v0 analysis
  static const Color indigo = Color(0xFF6366F1); // Modern Indigo
  static const Color emerald = Color(0xFF10B981); // Modern Emerald
  static const Color rose = Color(0xFFF43F5E); // Modern Rose
  static const Color background = Color(0xFF0F172A); // Dark Slate Background
  static const Color surface = Color(0xFF1E293B); // Dark Slate Surface

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: indigo,
      colorScheme: const ColorScheme.dark(
        primary: indigo,
        secondary: emerald,
        error: rose,
        surface: background, // background is deprecated, using existing background color for surface
        onSurface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
        headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
      ),
    );
  }
}

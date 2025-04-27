import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _lightPrimary = Color(0xFF2AAB5F); // Slightly toned down green
  static const _lightSecondary = Color(0xFF6CDEC2); // Softer mint-turquoise
  static const _darkPrimary = Color(0xFF1ABC9C); // Bright turquoise
  static const _darkSecondary = Color(0xFF76FFC4); // Neon accent

  // Light theme
  static final lightColorScheme = ColorScheme.fromSeed(
    seedColor: _lightPrimary,
    secondary: _lightSecondary,
    brightness: Brightness.light,
    tertiary: Colors.black26,
    // Replace deprecated properties
    surface: const Color(0xFFF0F5F1), // Light mint background
    onSurface: const Color(0xFF2C3E50),
    surfaceContainerHighest: const Color(0xFFE0EBE2),
  );

  // Dark theme
  static final darkColorScheme = ColorScheme.fromSeed(
    seedColor: _darkPrimary,
    tertiary: Colors.black26,
    brightness: Brightness.dark,
    primary: _darkPrimary,
    onPrimary: Colors.black,
    secondary: _darkSecondary,
    onSecondary: Colors.black,
    error: Colors.redAccent,
    onError: Colors.black,
    // Replace deprecated properties
    surface: const Color(0xFF121212),
    onSurface: Colors.white,
    surfaceContainerHighest: const Color(0xFF2D2D2D),
  );

  static final _baseTextTheme = GoogleFonts.nunitoTextTheme();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: const Color(0xFFF0F5F1), // Slightly more muted background
    textTheme: _baseTextTheme.apply(
      bodyColor: const Color(0xFF2C3E50),
      displayColor: const Color(0xFF2C3E50),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF0F5F1), // Match scaffold background
      foregroundColor: _lightPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _lightPrimary),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[100]!),
      ),
      margin: const EdgeInsets.all(12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _lightPrimary,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
        elevation: 3,
        shadowColor: _lightPrimary.withValues(alpha: 77), // ~0.3 opacity
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: _lightPrimary,
      unselectedItemColor: Colors.grey[400],
      backgroundColor: const Color(0xFFF0F5F1), // Match with appBar and scaffold
      elevation: 8,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    iconTheme: const IconThemeData(color: _lightPrimary),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: _baseTextTheme.apply(
      bodyColor: Colors.white70,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: _darkPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _darkPrimary),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2D2D2D),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: _darkPrimary,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
        elevation: 4,
        shadowColor: _darkPrimary.withValues(alpha: 102), // ~0.4 opacity
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none),
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: _darkSecondary,
      unselectedItemColor: Color(0xFF757575), // Less harsh gray
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 12,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
    iconTheme: const IconThemeData(color: _darkSecondary),
    dividerTheme: DividerThemeData(
      color: Colors.grey[800],
      thickness: 0.8,
    ),
  );
}
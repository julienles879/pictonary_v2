import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème inspiré de Doodle Jump
class DoodleTheme {
  // Couleurs principales
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color paperWhite = Color(0xFFFFFDF5);
  static const Color inkBlack = Color(0xFF2C3E50);
  static const Color pencilGray = Color(0xFF95A5A6);
  
  // Couleurs d'équipes (adaptées au style)
  static const Color teamRed = Color(0xFFE74C3C);
  static const Color teamBlue = Color(0xFF3498DB);
  
  // Couleurs d'accent
  static const Color sunYellow = Color(0xFFF1C40F);
  static const Color grassGreen = Color(0xFF2ECC71);
  static const Color cloudWhite = Color(0xFFECF0F1);
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paperWhite,
      fontFamily: GoogleFonts.comicNeue().fontFamily,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: skyBlue,
        foregroundColor: inkBlack,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: inkBlack,
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: grassGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: inkBlack, width: 2),
          ),
          textStyle: const TextStyle(
            fontFamily: 'ComicNeue',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: inkBlack,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: inkBlack, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'ComicNeue',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: cloudWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: inkBlack, width: 2),
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inkBlack, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: pencilGray, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inkBlack, width: 3),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'ComicNeue',
          color: inkBlack,
        ),
      ),
      
      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: inkBlack,
        ),
        displayMedium: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: inkBlack,
        ),
        titleLarge: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: inkBlack,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 16,
          color: inkBlack,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 14,
          color: inkBlack,
        ),
      ),
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: skyBlue,
        primary: skyBlue,
        secondary: sunYellow,
        surface: paperWhite,
        background: paperWhite,
      ),
    );
  }
}

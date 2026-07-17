import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AntiGravityTheme {
  // Color Palette Constants
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color cardBg = Color(0x1F1E293B); // rgba(30, 41, 59, 0.12)
  static const Color borderOverlay = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)
  
  static const Color neonCyan = Color(0xFF00BCD4);
  static const Color neonPurple = Color(0xFF9C27B0);
  static const Color neonPink = Color(0xFFE91E63);

  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  // Gradient Constants
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonCyan, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0x261E293B), // rgba(30, 41, 59, 0.15)
      Color(0x0F0F172A), // rgba(15, 23, 42, 0.06)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow Box Shadow
  static List<BoxShadow> cyanGlow({double opacity = 0.25, double blur = 15.0}) {
    return [
      BoxShadow(
        color: neonCyan.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: 1,
      )
    ];
  }

  static List<BoxShadow> purpleGlow({double opacity = 0.25, double blur = 15.0}) {
    return [
      BoxShadow(
        color: neonPurple.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: 1,
      )
    ];
  }

  // Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPurple,
        surface: darkBg,
        error: neonPink,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(color: textMain, fontSize: 16),
        bodyMedium: const TextStyle(color: textMuted, fontSize: 14),
        titleLarge: const TextStyle(color: textMain, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
    );
  }
}

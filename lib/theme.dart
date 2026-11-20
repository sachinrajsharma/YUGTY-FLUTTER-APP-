import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens, taken from the YUGTY Campus web page (vidaara.org/yugticampus).
class Tk {
  static const bg = Color(0xFF060B1F);
  static const surface = Color(0xFF0E1530);
  static const surface2 = Color(0xFF151E40);
  static const ink = Color(0xFFEEF3FF);
  static const mut = Color(0xFF9AA8D0);
  static const line = Color(0x2E8CAAFF);
  static const accent = Color(0xFF38BDF8);
  static const accent2 = Color(0xFFA5B4FC);
  static const good = Color(0xFF34D399);
  static const bad = Color(0xFFF87171);
  static const gold = Color(0xFFFBBF24);

  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accent, accent2],
  );
}

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final text = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: Tk.ink,
    displayColor: Tk.ink,
  );
  TextStyle head(TextStyle? s) => GoogleFonts.sora(
      textStyle: s, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: Tk.ink);
  return base.copyWith(
    scaffoldBackgroundColor: Tk.bg,
    colorScheme: const ColorScheme.dark(
      primary: Tk.accent,
      secondary: Tk.accent2,
      surface: Tk.surface,
      error: Tk.bad,
      onPrimary: Color(0xFF04122A),
    ),
    textTheme: text.copyWith(
      displayLarge: head(text.displayLarge),
      displayMedium: head(text.displayMedium),
      displaySmall: head(text.displaySmall),
      headlineLarge: head(text.headlineLarge),
      headlineMedium: head(text.headlineMedium),
      headlineSmall: head(text.headlineSmall),
      titleLarge: head(text.titleLarge),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Tk.surface2,
      contentTextStyle: GoogleFonts.inter(color: Tk.ink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GymBuddy Design System — extracted directly from Figma
class AppTheme {
  // ── Color Palette ──────────────────────────────────────────
  static const Color bg         = Color(0xFF050505); // Main background
  static const Color bgCard     = Color(0xFF111113); // Card background
  static const Color bgInput    = Color(0xFF0B0B0D); // Input fields
  static const Color navBar     = Color(0xFF0B0B0D); // Bottom nav
  static const Color bgElevated = Color(0xFF19191C); // Slightly elevated surface
  static const Color bgAI       = Color(0xFF20182F); // AI insight panel (purple tint)
  static const Color divider    = Color(0xFF303036); // Dividers / progress tracks
  static const Color muted      = Color(0xFF48484D); // Muted elements
  static const Color mutedDark  = Color(0xFF77777D); // Very muted

  // ── Text Colors ────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF7F7F7); // Primary text
  static const Color textMuted   = Color(0xFFA2A2AA); // Secondary text
  static const Color textDim     = Color(0xFF777780); // Tertiary / timestamps

  // ── Accent Colors ──────────────────────────────────────────
  static const Color accent      = Color(0xFFD6FF7F); // Lime green — primary CTA
  static const Color accentText  = Color(0xFF050505); // Text on lime bg
  static const Color purple      = Color(0xFFAC8CFF); // AI / fats accent
  static const Color green       = Color(0xFF92DDAE); // Success / protein accent

  // ── Goal chip colors ───────────────────────────────────────
  static const Color chipActive  = Color(0xFF192212); // Active filter chip bg
  static const Color chipInactive= Color(0xFF111113); // Inactive chip bg

  // ── Theme ──────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: purple,
        surface: bgCard,
        onPrimary: accentText,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(color: textMuted, fontSize: 12, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.inter(color: textDim, fontSize: 10, fontWeight: FontWeight.w400),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontSize: 26, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.inter(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        labelLarge: GoogleFonts.inter(color: accentText, fontSize: 14, fontWeight: FontWeight.w700),
        labelSmall: GoogleFonts.inter(color: textDim, fontSize: 10, fontWeight: FontWeight.w600),
      ),
      dividerColor: divider,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 26, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentText,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

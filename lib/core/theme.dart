import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────
/// AppTheme — Modern Ocean / Card-Based Aesthetic
/// ─────────────────────────────────────────────────────────────
/// Palet: Deep Teal + Violet + Warm Amber accent.
/// Layout: card-based, clean whitespace, modern minimalis.
/// ─────────────────────────────────────────────────────────────

class AppTheme {
  // ── Core Palette ─────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF0D7377); // Deep Teal
  static const Color secondaryColor = Color(0xFF7C3AED); // Violet
  static const Color accentColor    = Color(0xFFD97706); // Warm Amber

  static const Color background     = Color(0xFFF0FDFA); // Teal-50 soft
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color cardColor      = Color(0xFFFFFFFF);
  static const Color error          = Color(0xFFDC2626); // Red-600

  static const Color onPrimary      = Color(0xFFFFFFFF);
  static const Color onBackground   = Color(0xFF0F172A); // Slate-900
  static const Color onSurface      = Color(0xFF0F172A);
  static const Color textSecondary  = Color(0xFF64748B); // Slate-500
  static const Color dividerColor   = Color(0xFFE2E8F0); // Slate-200

  // ── Spacing Tokens ───────────────────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingS  = 8.0;
  static const double spacingM  = 16.0;
  static const double spacingL  = 24.0;
  static const double spacingXL = 32.0;

  // ── Border Radius Tokens ─────────────────────────────────────
  static const double radiusS  = 8.0;
  static const double radiusM  = 12.0;
  static const double radiusL  = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // ── Duration ─────────────────────────────────────────────────
  static const Duration microDuration   = Duration(milliseconds: 150);
  static const Duration shortDuration    = Duration(milliseconds: 250);
  static const Duration mediumDuration   = Duration(milliseconds: 350);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D7377), Color(0xFF14A3A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient heroGradient = const LinearGradient(
    colors: [Color(0xFF0D7377), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardSubtleGradient = LinearGradient(
    colors: [Color(0xFFF0FDFA), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Category Colors ──────────────────────────────────────────
  static const Map<String, Color> categoryColors = {
    'dokumen':    Color(0xFF0EA5E9), // Sky Blue
    'kunci':      Color(0xFFD97706), // Amber
    'obat':       Color(0xFF059669), // Emerald
    'elektronik': Color(0xFF7C3AED), // Violet
    'pakaian':    Color(0xFFDB2777), // Pink
    'perkakas':   Color(0xFF65A30D), // Lime
    'lainnya':    Color(0xFF64748B), // Slate
  };

  static const Map<String, List<Color>> categoryGradients = {
    'dokumen':    [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
    'kunci':      [Color(0xFFD97706), Color(0xFFF59E0B)],
    'obat':       [Color(0xFF059669), Color(0xFF34D399)],
    'elektronik': [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    'pakaian':    [Color(0xFFDB2777), Color(0xFFF472B6)],
    'perkakas':   [Color(0xFF65A30D), Color(0xFF84CC16)],
    'lainnya':    [Color(0xFF64748B), Color(0xFF94A3B8)],
  };

  static LinearGradient getCategoryGradient(String slug) {
    final colors = categoryGradients[slug] ?? categoryGradients['lainnya']!;
    return LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight);
  }

  static Color getCategoryColor(String slug, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      const dark = {
        'dokumen':    Color(0xFF38BDF8),
        'kunci':      Color(0xFFF59E0B),
        'obat':       Color(0xFF34D399),
        'elektronik': Color(0xFFA78BFA),
        'pakaian':    Color(0xFFF472B6),
        'perkakas':   Color(0xFF84CC16),
        'lainnya':    Color(0xFF94A3B8),
      };
      return dark[slug] ?? dark['lainnya']!;
    }
    return categoryColors[slug] ?? categoryColors['lainnya']!;
  }

  // ── Decoration Helpers ───────────────────────────────────────
  static BoxDecoration glassDecoration({
    double blur = 20,
    Color tint = Colors.white,
    double opacity = 0.7,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: tint.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  // ── Card Helper ──────────────────────────────────────────────
  static BoxDecoration cardDecoration({
    double radius = 16,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadows ?? softShadow(),
    );
  }

  // ── Glow Shadow ──────────────────────────────────────────────
  static List<BoxShadow> glowShadow(Color color, {double alpha = 0.25}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: 20,
        spreadRadius: -2,
        offset: const Offset(0, 6),
      ),
    ];
  }

  // ── Shadows ──────────────────────────────────────────────────
  static List<BoxShadow> softShadow({
    Color color = const Color(0xFF0F172A),
    double alpha = 0.04,
    double blur = 12,
    double y = 2,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: blur,
        offset: Offset(0, y),
      ),
      BoxShadow(
        color: color.withValues(alpha: alpha * 0.4),
        blurRadius: blur * 2,
        offset: Offset(0, y * 2),
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow({
    Color color = const Color(0xFF0F172A),
    double alpha = 0.08,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: color.withValues(alpha: alpha * 0.3),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  // ── Light Theme ──────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surface,
      error: error,
      onPrimary: onPrimary,
      onSecondary: Colors.white,
      onSurface: onSurface,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: onSurface),
      displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: onSurface),
      displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: onSurface),
      headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: onSurface),
      headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: onSurface),
      titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: onSurface),
      titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: onSurface),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.normal, color: onSurface),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.normal, color: onSurface),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.normal, color: textSecondary),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, color: onSurface),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: onSurface),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0.5,
      titleTextStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20, color: onSurface),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: primaryColor.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.inter(fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: dividerColor)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primaryColor.withValues(alpha: 0.1),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? primaryColor : textSecondary, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 11,
          color: selected ? primaryColor : textSecondary,
        );
      }),
    ),
    dividerTheme: DividerThemeData(color: dividerColor, thickness: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),
  );

  // ── Dark Theme ───────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF14A3A8),
      secondary: const Color(0xFFA78BFA),
      tertiary: const Color(0xFFF59E0B),
      surface: const Color(0xFF1E293B),
      error: const Color(0xFFF87171),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: const Color(0xFFF1F5F9),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0F172A),
      foregroundColor: const Color(0xFFF1F5F9),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20, color: const Color(0xFFF1F5F9)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: const Color(0xFF1E293B),
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFF14A3A8).withValues(alpha: 0.1),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );
}

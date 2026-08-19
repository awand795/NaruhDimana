import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────
/// AppTheme — Stitch "Modern Editorial" Design System
/// ─────────────────────────────────────────────────────────────
/// Sumber: desain Google Stitch "NaruhDimana Redesign Modern UI"
/// (beranda_v6.html, M3 design tokens).
///
/// Palet: Indigo / Ocean Blue (#1A73E8 → #005BBF) + accent
/// amber-orange (#E65100) untuk alert. Background #F7F9FC.
/// Tipografi: Inter (display 32/700, headline 20-24/600-700,
/// body 14-16/400, label 12/600).
/// Shape: pill buttons (StadiumBorder), cards 12-16px, hero 16px.
/// Spacing: 8px scale (gutter 16px, base 8px).
/// ─────────────────────────────────────────────────────────────

class AppTheme {
  // ── Core Palette (Stitch indigo) ────────────────────────────
  static const Color primaryColor   = Color(0xFF1A73E8); // Ocean Indigo (brand)
  static const Color primaryDeep    = Color(0xFF005BBF); // M3 primary — ujung gradient
  static const Color secondaryColor = Color(0xFF0453CD); // Blue-700
  static const Color accentColor    = Color(0xFFE65100); // Deep orange — alert/amber accent

  static const Color background     = Color(0xFFF7F9FC); // surface
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color cardColor      = Color(0xFFFFFFFF); // surface-container-lowest
  static const Color error          = Color(0xFFBA1A1A);

  static const Color onPrimary      = Color(0xFFFFFFFF);
  static const Color onBackground   = Color(0xFF191C1E); // on-surface
  static const Color onSurface      = Color(0xFF191C1E);
  static const Color textSecondary  = Color(0xFF414754); // on-surface-variant
  static const Color dividerColor   = Color(0xFFE6E8F2); // surface-container-high

  // ── M3 Token Tambahan ───────────────────────────────────────
  static const Color outline                = Color(0xFF727785);
  static const Color outlineVariant         = Color(0xFFC1C6D6);
  static const Color surfaceContainer       = Color(0xFFECEEF1);
  static const Color surfaceContainerLow    = Color(0xFFF2F3FD);
  static const Color surfaceContainerHigh   = Color(0xFFE6E8F2);
  static const Color secondaryFixed         = Color(0xFFDAE2FF); // container ikon stat
  static const Color onSecondaryFixedVariant = Color(0xFF0040A2);
  static const Color primaryFixed            = Color(0xFFD8E2FF); // primary-fixed (ikon GPS)
  static const Color onPrimaryFixedVariant   = Color(0xFF004493);
  static const Color tertiaryFixed           = Color(0xFFFFDBCB); // tertiary-fixed (ikon dokumen)
  static const Color errorContainer         = Color(0xFFFFDAD6);
  static const Color onErrorContainer       = Color(0xFF93000A);
  static const Color alertCardBg            = Color(0xFFFFF4E5); // kartu "Menunggu Persetujuan"
  static const Color alertCardIconBg        = Color(0x33FFB74D); // #FFB74D/20

  // ── Spacing Tokens (8px scale) ──────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingS  = 8.0;
  static const double spacingM  = 16.0;
  static const double spacingL  = 24.0;
  static const double spacingXL = 32.0;

  // ── Border Radius Tokens ────────────────────────────────────
  static const double radiusS  = 8.0;   // rounded-lg
  static const double radiusM  = 12.0;  // rounded-xl — kartu stat
  static const double radiusL  = 16.0;  // rounded-2xl — hero card
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusPill = 999.0; // pill / stadium

  // ── Duration ─────────────────────────────────────────────────
  static const Duration microDuration   = Duration(milliseconds: 150);
  static const Duration shortDuration    = Duration(milliseconds: 250);
  static const Duration mediumDuration   = Duration(milliseconds: 350);

  // ── Gradients (from-ocean-indigo to-primary) ────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF005BBF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF0453CD), Color(0xFF1A73E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient heroGradient = const LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF005BBF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardSubtleGradient = LinearGradient(
    colors: [Color(0xFFF7F9FC), Color(0xFFFFFFFF)],
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
    double opacity = 0.8,
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
    Color color = const Color(0xFF1A73E8),
    double alpha = 0.06,
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
    Color color = const Color(0xFF1A73E8), // shadow-ocean-indigo/20
    double alpha = 0.18,
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
      onPrimary: onPrimary,
      primaryContainer: primaryDeep,
      onPrimaryContainer: onPrimary,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: secondaryFixed,
      onSecondaryContainer: onSecondaryFixedVariant,
      tertiary: accentColor,
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: textSecondary,
      outline: outline,
      outlineVariant: outlineVariant,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF2F3FD),
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
    ),
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      // display-lg: 32/40/700 (-0.02em) — greeting hero
      displayLarge: GoogleFonts.inter(fontSize: 32, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: onSurface),
      // display-lg-mobile: 28/36/700
      displayMedium: GoogleFonts.inter(fontSize: 28, height: 1.29, fontWeight: FontWeight.w700, color: onSurface),
      // headline-md: 24/32/700 (-0.01em)
      displaySmall: GoogleFonts.inter(fontSize: 24, height: 1.33, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: onSurface),
      headlineLarge: GoogleFonts.inter(fontSize: 24, height: 1.33, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: onSurface),
      // headline-sm: 20/28/600
      headlineMedium: GoogleFonts.inter(fontSize: 20, height: 1.4, fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: GoogleFonts.inter(fontSize: 20, height: 1.4, fontWeight: FontWeight.w600, color: onSurface),
      // title-lg: 18/24/600
      titleLarge: GoogleFonts.inter(fontSize: 18, height: 1.33, fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: GoogleFonts.inter(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: onSurface),
      titleSmall: GoogleFonts.inter(fontSize: 14, height: 1.43, fontWeight: FontWeight.w600, color: onSurface),
      // body-md: 16/24/400
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: onSurface),
      // body-sm: 14/20/400
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.43, fontWeight: FontWeight.w400, color: onSurface),
      bodySmall: GoogleFonts.inter(fontSize: 12, height: 1.33, fontWeight: FontWeight.w400, color: textSecondary),
      // label-md: 12/16/600
      labelLarge: GoogleFonts.inter(fontSize: 14, height: 1.43, fontWeight: FontWeight.w600, color: onSurface),
      labelMedium: GoogleFonts.inter(fontSize: 12, height: 1.33, fontWeight: FontWeight.w600, color: onSurface),
      labelSmall: GoogleFonts.inter(fontSize: 11, height: 1.45, fontWeight: FontWeight.w600, color: textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0.5,
      titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: onSurface),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0xFF005BBF).withValues(alpha: 0.08),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
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
      selectedColor: primaryColor.withValues(alpha: 0.08),
      checkmarkColor: primaryColor,
      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      shape: StadiumBorder(side: BorderSide(color: outlineVariant)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: onPrimary,
      elevation: 4,
      shape: const CircleBorder(),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primaryColor.withValues(alpha: 0.1),
      indicatorShape: const StadiumBorder(),
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: onSurface,
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // ── Dark Theme ───────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF8AB4F8),
      onPrimary: const Color(0xFF003064),
      primaryContainer: const Color(0xFF004493),
      onPrimaryContainer: const Color(0xFFD8E2FF),
      secondary: const Color(0xFFADC7FF),
      onSecondary: const Color(0xFF001848),
      secondaryContainer: const Color(0xFF0040A2),
      onSecondaryContainer: const Color(0xFFDAE2FF),
      tertiary: const Color(0xFFFFB74D),
      onTertiary: const Color(0xFF341100),
      error: const Color(0xFFF87171),
      onError: Colors.black,
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: const Color(0xFF1E293B),
      onSurface: const Color(0xFFF1F5F9),
      onSurfaceVariant: const Color(0xFF94A3B8),
      outline: const Color(0xFF8B93A7),
      outlineVariant: const Color(0xFF3A4150),
      surfaceContainerLowest: const Color(0xFF141A23),
      surfaceContainerLow: const Color(0xFF232936),
      surfaceContainer: const Color(0xFF2B3242),
      surfaceContainerHigh: const Color(0xFF333B4D),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: const Color(0xFFF1F5F9)),
      displayMedium: GoogleFonts.inter(fontSize: 28, height: 1.29, fontWeight: FontWeight.w700, color: const Color(0xFFF1F5F9)),
      displaySmall: GoogleFonts.inter(fontSize: 24, height: 1.33, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: const Color(0xFFF1F5F9)),
      headlineLarge: GoogleFonts.inter(fontSize: 24, height: 1.33, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: const Color(0xFFF1F5F9)),
      headlineMedium: GoogleFonts.inter(fontSize: 20, height: 1.4, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
      headlineSmall: GoogleFonts.inter(fontSize: 20, height: 1.4, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
      titleLarge: GoogleFonts.inter(fontSize: 18, height: 1.33, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
      titleMedium: GoogleFonts.inter(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
      titleSmall: GoogleFonts.inter(fontSize: 14, height: 1.43, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.5, fontWeight: FontWeight.w400, color: const Color(0xFFF1F5F9)),
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.43, fontWeight: FontWeight.w400, color: const Color(0xFFF1F5F9)),
      bodySmall: GoogleFonts.inter(fontSize: 12, height: 1.33, fontWeight: FontWeight.w400, color: const Color(0xFF94A3B8)),
      labelLarge: GoogleFonts.inter(fontSize: 14, height: 1.43, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
      labelMedium: GoogleFonts.inter(fontSize: 12, height: 1.33, fontWeight: FontWeight.w600, color: const Color(0xFFF1F5F9)),
      labelSmall: GoogleFonts.inter(fontSize: 11, height: 1.45, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0F172A),
      foregroundColor: const Color(0xFFF1F5F9),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: const Color(0xFFF1F5F9)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8AB4F8),
        foregroundColor: const Color(0xFF003064),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF8AB4F8),
        side: const BorderSide(color: Color(0xFF8AB4F8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const StadiumBorder(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A4150)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A4150)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8AB4F8), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1E293B),
      selectedColor: const Color(0xFF8AB4F8).withValues(alpha: 0.15),
      checkmarkColor: const Color(0xFF8AB4F8),
      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      shape: StadiumBorder(side: const BorderSide(color: Color(0xFF3A4150))),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: const Color(0xFF1E293B),
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFF8AB4F8).withValues(alpha: 0.12),
      indicatorShape: const StadiumBorder(),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? const Color(0xFF8AB4F8) : const Color(0xFF94A3B8), size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 11,
          color: selected ? const Color(0xFF8AB4F8) : const Color(0xFF94A3B8),
        );
      }),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF333B4D), thickness: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFFF1F5F9),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

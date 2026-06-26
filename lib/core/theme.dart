import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────
/// AppTheme — Earthy / Organic Aesthetic
/// ─────────────────────────────────────────────────────────────
/// Palet warna terinspirasi dari tanah liat, dedaunan, dan
/// tekstur alami. Modern minimalis dengan card-based layout.
/// ─────────────────────────────────────────────────────────────

class AppTheme {
  // ── Earthy Core Palette ──────────────────────────────────────
  static const Color primaryColor   = Color(0xFFC5705E); // Terracotta
  static const Color secondaryColor = Color(0xFF7C9A7A); // Sage Green
  static const Color accentColor    = Color(0xFFD4A06A); // Ochre / Golden

  static const Color background     = Color(0xFFF9F5F0); // Warm Cream
  static const Color surface        = Color(0xFFFFFCF8); // Off-white
  static const Color cardColor      = Color(0xFFFFFFFF);
  static const Color error          = Color(0xFFC26A5E); // Deep Clay

  static const Color onPrimary      = Color(0xFFFFFFFF);
  static const Color onBackground   = Color(0xFF3D3229); // Dark Brown
  static const Color onSurface      = Color(0xFF3D3229);
  static const Color textSecondary  = Color(0xFF8B7E74); // Warm Grey
  static const Color dividerColor   = Color(0xFFE6DFD6);

  // ── Duration ─────────────────────────────────────────────────
  static const Duration microDuration   = Duration(milliseconds: 150);
  static const Duration shortDuration    = Duration(milliseconds: 250);
  static const Duration mediumDuration   = Duration(milliseconds: 350);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFC5705E), Color(0xFFD4836F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF7C9A7A), Color(0xFF9DB89B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD4A06A), Color(0xFFE0B889)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient heroGradient = const LinearGradient(
    colors: [Color(0xFFC5705E), Color(0xFFB8907A), Color(0xFF7C9A7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // ── Earthy Category Colors ───────────────────────────────────
  static const Map<String, Color> categoryColors = {
    'dokumen':    Color(0xFFC58B6E), // Warm Brown
    'kunci':      Color(0xFFD4A06A), // Ochre
    'obat':       Color(0xFF7C9A7A), // Sage
    'elektronik': Color(0xFF7B8BA4), // Slate
    'pakaian':    Color(0xFFC87D8A), // Dusty Rose
    'perkakas':   Color(0xFF8B9A6E), // Olive
    'lainnya':    Color(0xFF9B8E83), // Warm Grey
  };

  static const Map<String, List<Color>> categoryGradients = {
    'dokumen':    [Color(0xFFC58B6E), Color(0xFFD4A98E)],
    'kunci':      [Color(0xFFD4A06A), Color(0xFFE0B889)],
    'obat':       [Color(0xFF7C9A7A), Color(0xFF9DB89B)],
    'elektronik': [Color(0xFF7B8BA4), Color(0xFF9EAEC4)],
    'pakaian':    [Color(0xFFC87D8A), Color(0xFFDD9FAA)],
    'perkakas':   [Color(0xFF8B9A6E), Color(0xFFACB994)],
    'lainnya':    [Color(0xFF9B8E83), Color(0xFFB8ADA4)],
  };

  static LinearGradient getCategoryGradient(String slug) {
    final colors = categoryGradients[slug] ?? categoryGradients['lainnya']!;
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color getCategoryColor(String slug, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      const dark = {
        'dokumen':    Color(0xFFD4A98E),
        'kunci':      Color(0xFFE0B889),
        'obat':       Color(0xFF9DB89B),
        'elektronik': Color(0xFF9EAEC4),
        'pakaian':    Color(0xFFDD9FAA),
        'perkakas':   Color(0xFFACB994),
        'lainnya':    Color(0xFFB8ADA4),
      };
      return dark[slug] ?? dark['lainnya']!;
    }
    return categoryColors[slug] ?? categoryColors['lainnya']!;
  }

  // ── Glassmorphism ────────────────────────────────────────────
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

  static Widget glassCard({
    required Widget child,
    double radius = 20,
    double blur = 20,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ── Shadows ──────────────────────────────────────────────────
  static List<BoxShadow> softShadow({
    Color color = const Color(0xFF3D3229),
    double alpha = 0.05,
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
        color: color.withValues(alpha: alpha * 0.5),
        blurRadius: blur * 2,
        offset: Offset(0, y * 2),
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow({
    Color color = const Color(0xFF3D3229),
    double alpha = 0.08,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: color.withValues(alpha: alpha * 0.4),
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
      displayLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      displaySmall: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.outfit(
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontWeight: FontWeight.normal,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontWeight: FontWeight.normal,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0.5,
      titleTextStyle: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: GoogleFonts.inter(color: textSecondary),
      hintStyle: GoogleFonts.inter(color: textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: primaryColor.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.inter(fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: dividerColor),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: primaryColor.withValues(alpha: 0.1),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? primaryColor : textSecondary,
          size: 22,
        );
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
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  // ── Dark Theme ───────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFD4836F),
      secondary: const Color(0xFF9DB89B),
      tertiary: const Color(0xFFE0B889),
      surface: const Color(0xFF2A2520),
      error: const Color(0xFFE57373),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: const Color(0xFFF5F0EB),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1815),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1C1815),
      foregroundColor: const Color(0xFFF5F0EB),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: const Color(0xFFF5F0EB),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2A2520),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4836F),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF363029),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4836F), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFFD4836F),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 64,
      backgroundColor: const Color(0xFF2A2520),
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFFD4836F).withValues(alpha: 0.1),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? const Color(0xFFD4836F) : const Color(0xFF9B8E83),
          size: 22,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 11,
          color: selected ? const Color(0xFFD4836F) : const Color(0xFF9B8E83),
        );
      }),
    ),
  );
}

// Smoke test untuk design system AppTheme (Stitch "Modern Editorial").
// Catatan: konstruksi ThemeData sengaja tidak diuji di sini karena
// google_fonts mencoba fetch font via HTTP di lingkungan test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:naruh_dimana/core/theme.dart';

void main() {
  test('Palet indigo Stitch', () {
    expect(AppTheme.primaryColor, const Color(0xFF1A73E8)); // ocean-indigo
    expect(AppTheme.primaryDeep, const Color(0xFF005BBF)); // M3 primary
    expect(AppTheme.secondaryColor, const Color(0xFF0453CD));
    expect(AppTheme.accentColor, const Color(0xFFE65100)); // alert accent
    expect(AppTheme.background, const Color(0xFFF7F9FC));
    expect(AppTheme.surface, const Color(0xFFFFFFFF));
    expect(AppTheme.onSurface, const Color(0xFF191C1E));
    expect(AppTheme.textSecondary, const Color(0xFF414754));
    expect(AppTheme.error, const Color(0xFFBA1A1A));
  });

  test('Gradient hero memakai warna brand indigo', () {
    expect(AppTheme.heroGradient.colors, const [Color(0xFF1A73E8), Color(0xFF005BBF)]);
    expect(AppTheme.primaryGradient.colors, const [Color(0xFF1A73E8), Color(0xFF005BBF)]);
  });

  test('Spacing 8px scale & radius', () {
    expect(AppTheme.spacingXS, 4.0);
    expect(AppTheme.spacingS, 8.0);
    expect(AppTheme.spacingM, 16.0);
    expect(AppTheme.spacingL, 24.0);
    expect(AppTheme.spacingXL, 32.0);
    expect(AppTheme.radiusS, 8.0);
    expect(AppTheme.radiusM, 12.0);
    expect(AppTheme.radiusL, 16.0);
    expect(AppTheme.radiusPill, 999.0);
  });
}

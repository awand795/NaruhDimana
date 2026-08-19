import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF0F172A) : AppTheme.surfaceContainerLow;
    final cardColor =
        isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Tentang Aplikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── App icon + branding ─────────────────────
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: AppTheme.glowShadow(AppTheme.primaryColor,
                    alpha: 0.3),
              ),
              child: const Icon(
                Icons.inventory_2,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NaruhDimana',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Version pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: const Text(
                'v1.0.0+2',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tagline pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryFixed,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: const Text(
                'Ingat semua, temukan segalanya',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSecondaryFixedVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Description card ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.softShadow(alpha: 0.04),
              ),
              child: Text(
                'NaruhDimana adalah aplikasi pencatat barang '
                'yang membantu Anda mengingat lokasi penyimpanan '
                'setiap barang berharga. Dengan fitur GPS, foto, '
                'dan pengingat, barang Anda tidak akan pernah hilang lagi.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // ── Features card ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.softShadow(alpha: 0.04),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitur Utama',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.camera_alt_outlined,
                    iconBg: AppTheme.tertiaryFixed,
                    iconColor: AppTheme.accentColor,
                    title: 'Foto & Galeri',
                    subtitle: 'Simpan foto barang dengan mudah',
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon: Icons.location_on_outlined,
                    iconBg: AppTheme.primaryFixed,
                    iconColor: AppTheme.onPrimaryFixedVariant,
                    title: 'Lokasi GPS',
                    subtitle: 'Tandai lokasi presisi setiap barang',
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon: Icons.notifications_none_rounded,
                    iconBg: AppTheme.secondaryFixed,
                    iconColor: AppTheme.onSecondaryFixedVariant,
                    title: 'Pengingat',
                    subtitle: 'Jangan lupa kapan barang perlu diperiksa',
                  ),
                  const SizedBox(height: 12),
                  _FeatureRow(
                    icon: Icons.qr_code_scanner_rounded,
                    iconBg: AppTheme.errorContainer,
                    iconColor: AppTheme.onErrorContainer,
                    title: 'Scan QR/Barcode',
                    subtitle: 'Tambah barang dari kode QR',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Made with love ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.tertiaryFixed,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: AppTheme.accentColor,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Made with ❤️ by\nAwanda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 NaruhDimana. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

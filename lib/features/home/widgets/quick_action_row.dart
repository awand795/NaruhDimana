import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';

class QuickActionRow extends StatelessWidget {
  final VoidCallback? onTapAdd;
  final VoidCallback? onTapScan;
  final VoidCallback? onTapSearch;
  final VoidCallback? onTapMap;

  const QuickActionRow({
    super.key,
    this.onTapAdd,
    this.onTapScan,
    this.onTapSearch,
    this.onTapMap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _ActionButton(
            icon: Icons.add_circle_rounded,
            label: 'Tambah',
            gradient: AppTheme.primaryGradient,
            onTap: onTapAdd,
          ),
          _ActionButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan',
            gradient: AppTheme.accentGradient,
            onTap: onTapScan,
          ),
          _ActionButton(
            icon: Icons.search_rounded,
            label: 'Cari',
            color: isDark ? Colors.white : AppTheme.primaryColor,
            bgColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppTheme.primaryColor.withValues(alpha: 0.06),
            onTap: onTapSearch,
          ),
          _ActionButton(
            icon: Icons.map_rounded,
            label: 'Peta',
            color: isDark ? Colors.white : AppTheme.secondaryColor,
            bgColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppTheme.secondaryColor.withValues(alpha: 0.06),
            onTap: onTapMap,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient? gradient;
  final Color? color;
  final Color? bgColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.gradient,
    this.color,
    this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                color: gradient != null ? null : bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: gradient != null
                    ? AppTheme.softShadow(
                        color: (gradient!.colors.isNotEmpty
                            ? gradient!.colors[0]
                            : AppTheme.primaryColor),
                        alpha: 0.2,
                        blur: 8,
                        y: 3,
                      )
                    : null,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

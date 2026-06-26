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
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _ActionCard(
            icon: Icons.add_circle_rounded,
            label: 'Tambah',
            gradient: AppTheme.primaryGradient,
            shadowColor: AppTheme.primaryColor,
            onTap: onTapAdd,
          ),
          _ActionCard(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan',
            gradient: AppTheme.secondaryGradient,
            shadowColor: AppTheme.secondaryColor,
            onTap: onTapScan,
          ),
          _ActionCard(
            icon: Icons.search_rounded,
            label: 'Cari',
            color: AppTheme.primaryColor,
            bgColor: bgColor,
            borderColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            onTap: onTapSearch,
          ),
          _ActionCard(
            icon: Icons.map_rounded,
            label: 'Peta',
            color: const Color(0xFF0EA5E9),
            bgColor: bgColor,
            borderColor: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
            onTap: onTapMap,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient? gradient;
  final Color? color;
  final Color? bgColor;
  final Color? borderColor;
  final Color? shadowColor;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    this.gradient,
    this.color,
    this.bgColor,
    this.borderColor,
    this.shadowColor,
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
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: gradient != null
                ? BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow(
                      color: shadowColor ?? AppTheme.primaryColor,
                      alpha: 0.2,
                      blur: 8,
                      y: 3,
                    ),
                  )
                : BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor ?? Colors.transparent),
                    boxShadow: AppTheme.softShadow(alpha: 0.04),
                  ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: gradient != null ? Colors.white : color, size: 26),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: gradient != null ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

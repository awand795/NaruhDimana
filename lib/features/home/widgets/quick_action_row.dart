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
    return SizedBox(
      height: 96,
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
            borderColor: AppTheme.primaryColor.withValues(alpha: 0.3),
            onTap: onTapSearch,
          ),
          _ActionCard(
            icon: Icons.map_rounded,
            label: 'Peta',
            color: const Color(0xFF0EA5E9),
            borderColor: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
            onTap: onTapMap,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final LinearGradient? gradient;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    this.gradient,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.92),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          HapticFeedback.selectionClick();
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: SizedBox(
            width: 80,
            height: 80,
            child: Container(
              decoration: widget.gradient != null
                  ? BoxDecoration(
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      boxShadow: AppTheme.elevatedShadow(
                        color: widget.shadowColor ?? AppTheme.primaryColor,
                        alpha: 0.3,
                      ),
                    )
                  : BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      border: Border.all(color: widget.borderColor ?? Colors.transparent, width: 1.5),
                      boxShadow: AppTheme.softShadow(alpha: 0.06),
                    ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.gradient != null ? Colors.white : widget.color,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.gradient != null ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

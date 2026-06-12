import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/item_provider.dart';
import '../../../core/theme.dart';

class SummaryChips extends ConsumerWidget {
  const SummaryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(itemStatsProvider);

    return statsAsync.when(
      data: (stats) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _ChipCard(
                icon: Icons.inventory_2,
                label: 'Total',
                value: '${stats['total'] ?? 0}',
                color: AppTheme.primaryColor,
                delay: 0,
              ),
              const SizedBox(width: 10),
              _ChipCard(
                icon: Icons.notifications_active,
                label: 'Pengingat',
                value: '${stats['reminders'] ?? 0}',
                color: AppTheme.secondaryColor,
                delay: 80,
              ),
              const SizedBox(width: 10),
              _ChipCard(
                icon: Icons.location_on,
                label: 'GPS',
                value: '${stats['gps'] ?? 0}',
                color: Colors.green,
                delay: 160,
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Row(
            children: List.generate(
              3,
              (_) => Expanded(
                child: Container(
                  height: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ChipCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _ChipCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  State<_ChipCard> createState() => _ChipCardState();
}

class _ChipCardState extends State<_ChipCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.93 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: _isPressed
                ? Matrix4.translationValues(0.0, 2.0, 0.0)
                : Matrix4.identity(),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: widget.color, size: 20),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 350.ms,
      delay: (widget.delay).ms,
      curve: Curves.easeOut,
    ).slideY(begin: 0.15);
  }
}

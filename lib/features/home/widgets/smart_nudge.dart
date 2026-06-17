import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/item_provider.dart';
import '../../../core/theme.dart';

class SmartNudge extends ConsumerWidget {
  const SmartNudge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(itemStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final nudge = _buildNudge(stats);
        if (nudge == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: nudge.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: nudge.color.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(nudge.icon, color: nudge.color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nudge.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: nudge.color,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),

              ],
            ),
          ),
        ).animate().fadeIn(
          duration: AppTheme.shortDuration,
          delay: 200.ms,
        ).slideY(begin: 0.08);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  _NudgeData? _buildNudge(Map<String, dynamic> stats) {
    final hour = DateTime.now().hour;
    final reminders = stats['reminders'] as int? ?? 0;
    final total = stats['total'] as int? ?? 0;

    // Prioritas 1: ada pengingat hari ini
    if (reminders > 0) {
      return _NudgeData(
        icon: Icons.notifications_active_rounded,
        message: '$reminders pengingat aktif — cek barangmu',
        color: const Color(0xFFEF9F27),
      );
    }
    // Prioritas 2: pagi hari, ingatkan kunci
    if (hour >= 6 && hour <= 9 && total > 0) {
      return _NudgeData(
        icon: Icons.wb_sunny_rounded,
        message: 'Selamat pagi! Sudah cek barang bawaan hari ini?',
        color: const Color(0xFF3B8BD4),
      );
    }
    // Prioritas 3: belum ada barang sama sekali
    if (total == 0) {
      return _NudgeData(
        icon: Icons.add_box_rounded,
        message: 'Mulai simpan barang pertamamu sekarang',
        color: AppTheme.primaryColor,
      );
    }
    return null;
  }
}

class _NudgeData {
  final IconData icon;
  final String message;
  final Color color;

  const _NudgeData({
    required this.icon,
    required this.message,
    required this.color,
  });
}

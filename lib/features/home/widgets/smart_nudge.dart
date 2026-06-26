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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: nudge.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: nudge.color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(nudge.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nudge.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 16,
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
    final itemsWithGps = stats['gps'] as int? ?? 0;

    if (reminders > 0) {
      return _NudgeData(
        icon: Icons.notifications_active_rounded,
        message: '$reminders pengingat aktif hari ini. Jangan lupa dicek ya!',
        color: AppTheme.accentColor,
        gradient: AppTheme.accentGradient,
      );
    }

    if (total == 0) {
      return _NudgeData(
        icon: Icons.add_box_rounded,
        message: 'Mulai simpan barang pertamamu agar tidak lupa di mana naruhnya.',
        color: AppTheme.primaryColor,
        gradient: AppTheme.primaryGradient,
      );
    }

    if (hour >= 6 && hour <= 9) {
      return _NudgeData(
        icon: Icons.wb_sunny_rounded,
        message: 'Selamat pagi! Sudah siap bawa barang pentingmu hari ini?',
        color: AppTheme.accentColor,
        gradient: const LinearGradient(
          colors: [Color(0xFFD4A06A), Color(0xFFE0B889)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    if (total > 5 && itemsWithGps < (total / 2)) {
      return _NudgeData(
        icon: Icons.location_on_rounded,
        message: 'Beberapa barangmu belum ada koordinat GPS-nya nih.',
        color: AppTheme.secondaryColor,
        gradient: AppTheme.secondaryGradient,
      );
    }

    if (hour >= 19 && hour <= 22) {
      return _NudgeData(
        icon: Icons.inventory_rounded,
        message: 'Waktunya audit santai! Masih ingat posisi semua barangmu?',
        color: const Color(0xFF7B8BA4),
        gradient: const LinearGradient(
          colors: [Color(0xFF7B8BA4), Color(0xFF9EAEC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    return _NudgeData(
      icon: Icons.lightbulb_outline_rounded,
      message: 'Tips: Tambahkan foto nota pembelian ke barang agar garansi aman.',
      color: AppTheme.accentColor,
      gradient: AppTheme.accentGradient,
    );
  }
}

class _NudgeData {
  final IconData icon;
  final String message;
  final Color color;
  final LinearGradient gradient;

  const _NudgeData({
    required this.icon,
    required this.message,
    required this.color,
    required this.gradient,
  });
}

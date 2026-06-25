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

    // Prioritas 1: ada pengingat hari ini
    if (reminders > 0) {
      return _NudgeData(
        icon: Icons.notifications_active_rounded,
        message: '$reminders pengingat aktif hari ini. Jangan lupa dicek ya!',
        color: const Color(0xFFEF9F27),
        gradient: const LinearGradient(
          colors: [Color(0xFFEF9F27), Color(0xFFFFC107)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    // Prioritas 2: Belum ada barang sama sekali
    if (total == 0) {
      return _NudgeData(
        icon: Icons.add_box_rounded,
        message: 'Mulai simpan barang pertamamu agar tidak lupa di mana naruhnya.',
        color: AppTheme.primaryColor,
        gradient: AppTheme.primaryGradient,
      );
    }

    // Prioritas 3: Pagi hari (6-9), ingatkan barang rutin
    if (hour >= 6 && hour <= 9) {
      return _NudgeData(
        icon: Icons.wb_sunny_rounded,
        message: 'Selamat pagi! Sudah siap bawa barang pentingmu hari ini?',
        color: const Color(0xFF3B8BD4),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B8BD4), Color(0xFF5BA3E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    // Prioritas 4: Banyak barang tapi sedikit yang ada lokasi GPS
    if (total > 5 && itemsWithGps < (total / 2)) {
      return _NudgeData(
        icon: Icons.location_on_rounded,
        message: 'Beberapa barangmu belum ada koordinat GPS-nya nih.',
        color: const Color(0xFF1D9E75),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D9E75), Color(0xFF43A47A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    // Prioritas 5: Waktunya "Audit" barang (Malam hari 19-22)
    if (hour >= 19 && hour <= 22) {
      return _NudgeData(
        icon: Icons.inventory_rounded,
        message: 'Waktunya audit santai! Masih ingat posisi semua barangmu?',
        color: Colors.indigo,
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }

    // Default: Tips acak
    return _NudgeData(
      icon: Icons.lightbulb_outline_rounded,
      message: 'Tips: Tambahkan foto nota pembelian ke barang agar garansi aman.',
      color: Colors.amber.shade700,
      gradient: const LinearGradient(
        colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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

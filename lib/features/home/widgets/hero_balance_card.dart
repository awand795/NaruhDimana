import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme.dart';

class HeroBalanceCard extends ConsumerWidget {
  final AsyncValue<Map<String, int>> statsAsync;

  const HeroBalanceCard({super.key, required this.statsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return statsAsync.when(
      data: (stats) => _buildData(context, stats),
      loading: () => _buildShimmer(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildData(BuildContext context, Map<String, int> stats) {
    final total = stats['total'] ?? 0;
    final reminders = stats['reminders'] ?? 0;
    final gps = stats['gps'] ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF2A2D40), Color(0xFF1E2030)],
              )
            : const LinearGradient(
                colors: [Color(0xFF4F6AF5), Color(0xFF6C63FF)],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.elevatedShadow(
          color: isDark ? Colors.black : const Color(0xFF4F6AF5),
          alpha: isDark ? 0.3 : 0.25,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(total),
              const SizedBox(height: 20),
              _buildStatsRow(reminders, gps, stats),
            ],
          ),
        ),
      ),
    ).animate().shimmer(
      duration: 1500.ms,
      color: Colors.white.withValues(alpha: 0.02),
    );
  }

  Widget _buildHeader(int total) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Barang Tersimpan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$total barang',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int reminders, int gps, Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.notifications_active_rounded,
            value: '$reminders',
            label: 'Pengingat',
            color: const Color(0xFFFFC107),
          ),
          _StatDivider(),
          _StatItem(
            icon: Icons.location_on_rounded,
            value: '$gps',
            label: 'Dengan GPS',
            color: const Color(0xFF4CAF50),
          ),
          _StatDivider(),
          _StatItem(
            icon: Icons.photo_camera_rounded,
            value: '${stats['total'] ?? 0}',
            label: 'Dengan Foto',
            color: const Color(0xFF64B5F6),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}


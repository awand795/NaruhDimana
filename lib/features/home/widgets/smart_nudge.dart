import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/item_provider.dart';
import '../../../core/theme.dart';

/// Kartu status/alert ala Beranda V6:
/// - amber "Pengingat" (ikon pending_actions, bg #FFF4E5)
/// - merah "Perlu Koordinat GPS" (ikon inventory_2, bg error-container)
/// Disusun dari data statistik nyata; saat belum ada barang tampil
/// kartu sambutan, saat semua rapi tampil kartu tips.
class SmartNudge extends ConsumerWidget {
  const SmartNudge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(itemStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final total = stats['total'] ?? 0;
        final reminders = stats['reminders'] ?? 0;
        final gps = stats['gps'] ?? 0;
        final missingGps = total - gps;

        if (total == 0) {
          return const _AlertCard(
            bg: Color(0xFFE8F0FE),
            iconBg: Color(0x1F1A73E8),
            iconColor: AppTheme.primaryColor,
            icon: Icons.add_box_rounded,
            title: 'Mulai simpan barang',
            subtitle: 'Tambahkan barang pertamamu agar tidak lupa di mana naruhnya.',
          );
        }

        if (reminders == 0 && missingGps == 0) {
          return const _AlertCard(
            bg: Color(0xFFE8F0FE),
            iconBg: Color(0x1F1A73E8),
            iconColor: AppTheme.primaryColor,
            icon: Icons.lightbulb_outline_rounded,
            title: 'Semua rapi!',
            subtitle: 'Semua barang sudah punya pengingat dan koordinat GPS.',
          );
        }

        return Column(
          children: [
            if (reminders > 0)
              _AlertCard(
                bg: const Color(0xFFFFF4E5),
                iconBg: const Color(0x33FFB74D),
                iconColor: const Color(0xFFE65100),
                icon: Icons.pending_actions_rounded,
                title: 'Pengingat Aktif',
                subtitle: '$reminders pengingat terjadwal menunggu',
                titleColor: const Color(0xFF3E2723),
                subtitleColor: const Color(0xFF5D4037),
                chevronColor: const Color(0xFFE65100),
              ),
            if (reminders > 0 && missingGps > 0) const SizedBox(height: 8),
            if (missingGps > 0)
              _AlertCard(
                bg: AppTheme.errorContainer.withValues(alpha: 0.35),
                iconBg: AppTheme.errorContainer,
                iconColor: AppTheme.error,
                icon: Icons.inventory_2_rounded,
                title: 'Perlu Koordinat GPS',
                subtitle: '$missingGps barang belum punya lokasi presisi',
                chevronColor: AppTheme.error,
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Color bg;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? chevronColor;

  const _AlertCard({
    required this.bg,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.chevronColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.softShadow(alpha: 0.04),
      ),
      child: Row(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: chevronColor ?? AppTheme.outline),
        ],
      ),
    );
  }
}

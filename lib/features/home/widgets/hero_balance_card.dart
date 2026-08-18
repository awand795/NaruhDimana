import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../providers/item_provider.dart';
import '../../../data/models/item_model.dart';

/// Hero card Beranda V6 — gradient ocean-indigo→primary,
/// label "Total Barang", badge pill tren bulan ini, angka besar,
/// subtitle ringkasan, dan dekorasi gelombang di kanan-bawah.
class HeroBalanceCard extends ConsumerWidget {
  final AsyncValue<Map<String, int>> statsAsync;

  const HeroBalanceCard({super.key, required this.statsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    return statsAsync.when(
      data: (stats) {
        final items = itemsAsync.valueOrNull ?? const <Item>[];
        return _buildData(context, stats, _countAddedThisMonth(items));
      },
      loading: () => _buildShimmer(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  int _countAddedThisMonth(List<Item> items) {
    final now = DateTime.now();
    return items.where((i) {
      final created = DateTime.tryParse(i.createdAt);
      return created != null && created.year == now.year && created.month == now.month;
    }).length;
  }

  Widget _buildData(BuildContext context, Map<String, int> stats, int addedThisMonth) {
    final total = stats['total'] ?? 0;
    final reminders = stats['reminders'] ?? 0;
    final gps = stats['gps'] ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.elevatedShadow(alpha: 0.22),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Stack(
          children: [
            // Dekorasi gelombang kanan-bawah
            Positioned(
              right: -18,
              bottom: -26,
              child: CustomPaint(
                size: const Size(180, 140),
                painter: _WavePainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Barang',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const Spacer(),
                      _TrendBadge(count: addedThisMonth),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 48,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tersimpan di $gps lokasi ber-GPS • $reminders pengingat',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final int count;

  const _TrendBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up_rounded, size: 15, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '+$count bulan ini',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.58)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.18,
        size.width * 0.5,
        size.height * 0.88,
        size.width,
        size.height * 0.38,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

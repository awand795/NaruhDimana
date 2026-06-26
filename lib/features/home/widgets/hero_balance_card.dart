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
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              )
            : AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.elevatedShadow(
          color: isDark ? Colors.black : AppTheme.primaryColor,
          alpha: isDark ? 0.3 : 0.25,
        ),
      ),
      child: Stack(
        children: [
          // Subtle noise texture overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(
                  painter: _NoisePainter(),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Barang',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingL),
                // ── 3 Mini Stat Cards ──────────────────────────
                Row(
                  children: [
                    Expanded(child: _MiniStatCard(
                      icon: Icons.notifications_active_rounded,
                      value: '$reminders',
                      label: 'Pengingat',
                      color: const Color(0xFFF59E0B),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _MiniStatCard(
                      icon: Icons.location_on_rounded,
                      value: '$gps',
                      label: 'Dengan GPS',
                      color: const Color(0xFF34D399),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _MiniStatCard(
                      icon: Icons.photo_camera_rounded,
                      value: '${stats['total'] ?? 0}',
                      label: 'Dengan Foto',
                      color: const Color(0xFFA78BFA),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().shimmer(
      duration: 1500.ms,
      color: Colors.white.withValues(alpha: 0.02),
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = _SeededRandom(42);
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeededRandom {
  int _seed;
  _SeededRandom(this._seed);
  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}

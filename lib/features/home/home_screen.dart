import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/router.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/item_provider.dart';

import 'widgets/hero_balance_card.dart';
import 'widgets/quick_action_row.dart';
import 'widgets/recent_items.dart';
import 'widgets/category_grid.dart';
import 'widgets/smart_nudge.dart';
import 'widgets/quick_add_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showQuickAddSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => QuickAddSheet(
        onOpenFull: () {
          Navigator.pop(ctx);
          Navigator.pushNamed(context, AppRoutes.addItem);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(itemStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Spacer di bawah header glass
              SliverToBoxAdapter(child: SizedBox(height: kToolbarHeight + topInset)),

              // ── Greeting ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${profile.name.isNotEmpty ? profile.name : 'Pengguna'}! 👋',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ringkasan inventaris Anda hari ini.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05),
              ),

              // ── Hero Card ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HeroBalanceCard(statsAsync: statsAsync),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.06),
              ),

              // ── Statistik 2 kolom ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _SummaryStatGrid(statsAsync: statsAsync),
                ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
              ),

              // ── Quick Actions ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: QuickActionRow(
                    onTapAdd: () => _showQuickAddSheet(context),
                    onTapScan: () => Navigator.pushNamed(context, AppRoutes.scan),
                    onTapSearch: () => Navigator.pushNamed(context, AppRoutes.search),
                    onTapMap: () => Navigator.pushNamed(context, AppRoutes.mapOverview),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              ),

              // ── Kartu Status / Alert ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SmartNudge(),
                ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
              ),

              // ── Kategori Cepat ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: CategoryGrid(),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              ),

              // ── Aktivitas Terbaru ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: RecentItems(),
                ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
              ),

              // Ruang untuk floating dock
              const SliverToBoxAdapter(child: SizedBox(height: 130)),
            ],
          ),

          // ── Header glass (fixed) ────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _GlassHeader(profileName: profile.name, isDark: isDark),
          ),
        ],
      ),
    );
  }
}

/// Header glassmorphism ala Beranda V6: blur 16px, putih 80%,
/// judul kiri + avatar kanan.
class _GlassHeader extends StatelessWidget {
  final String profileName;
  final bool isDark;

  const _GlassHeader({required this.profileName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(color: AppTheme.surfaceContainerHigh),
            ),
          ),
          child: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'NaruhDimana',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Avatar
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            profileName.isNotEmpty ? profileName[0].toUpperCase() : 'N',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
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

/// Grid statistik 2 kolom ala Beranda V6:
/// kartu ikon circle secondary-fixed ("Total Tersimpan") &
/// kartu ikon error-container ("Pengingat Aktif").
class _SummaryStatGrid extends StatelessWidget {
  final AsyncValue<Map<String, int>> statsAsync;

  const _SummaryStatGrid({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    return statsAsync.when(
      data: (stats) {
        final total = stats['total'] ?? 0;
        final reminders = stats['reminders'] ?? 0;
        return Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.check_circle_rounded,
                iconBg: AppTheme.secondaryFixed,
                iconColor: AppTheme.onSecondaryFixedVariant,
                value: '$total',
                label: 'Total Tersimpan',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                icon: Icons.build_rounded,
                iconBg: AppTheme.errorContainer,
                iconColor: AppTheme.error,
                value: '$reminders',
                label: 'Pengingat Aktif',
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Expanded(
            child: Container(
              height: 108,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 108,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
          ),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.softShadow(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

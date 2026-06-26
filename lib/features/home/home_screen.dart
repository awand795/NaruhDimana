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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
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

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  // Avatar with gradient ring
                  Container(
                    width: 48,
                    height: 48,
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
                        child: profile.photoPath != null
                            ? null
                            : Text(
                                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'N',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()} 👋',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          profile.name.isNotEmpty ? profile.name : 'Pengguna Baru',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Notification pill
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 20),
                      onPressed: () => HapticFeedback.lightImpact(),
                      color: isDark ? Colors.white : AppTheme.primaryColor,
                      padding: EdgeInsets.zero,
                    ),
                  ).animate(onPlay: (c) => c.repeat(), onComplete: (c) => c.reset()).shimmer(
                    duration: 2000.ms,
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05),
          ),

          // ── Hero Stats Card ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: HeroBalanceCard(statsAsync: statsAsync),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.06),
          ),

          // ── Quick Actions ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: QuickActionRow(
                onTapAdd: () => _showQuickAddSheet(context),
                onTapScan: () => Navigator.pushNamed(context, AppRoutes.addItem),
                onTapSearch: () => Navigator.pushNamed(context, AppRoutes.search),
                onTapMap: () {},
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
          ),

          // ── Smart Nudge ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SmartNudge(),
            ),
          ),

          // ── Recent Items ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: RecentItems(),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ),

          // ── Category Grid ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CategoryGrid(),
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showQuickAddSheet(context);
        },
        child: const Icon(Icons.add_rounded),
      ).animate().scale(
        duration: 600.ms, delay: 300.ms, curve: Curves.elasticOut, begin: const Offset(0, 0),
      ),
    );
  }
}

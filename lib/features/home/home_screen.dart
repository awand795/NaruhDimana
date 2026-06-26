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
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      if (offset > 100 && _isFabVisible) {
        setState(() => _isFabVisible = false);
      } else if (offset <= 100 && !_isFabVisible) {
        setState(() => _isFabVisible = true);
      }
    });
  }

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
          // --- Modern Personalized Header ---
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF1C1815),
                          Color(0xFF2A2520),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : const LinearGradient(
                        colors: [
                          Color(0xFFF9F5F0),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
              ),
              child: FlexibleSpaceBar(
                titlePadding: EdgeInsets.zero,
                expandedTitleScale: 1.0,
                title: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar with ring
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF2A2520)
                                  : Colors.white,
                            ),
                            child: profile.photoPath != null
                                ? null
                                : Text(
                                    profile.name.isNotEmpty
                                        ? profile.name[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xFFD4836F)
                                          : AppTheme.primaryColor,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Greeting and name
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(width: 6),
                                Text('👋'),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.name.isNotEmpty
                                  ? profile.name
                                  : 'Pengguna Baru',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Notification bell with badge
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : const Color(0xFFC5705E)
                                      .withValues(alpha: 0.06),
                              foregroundColor: isDark
                                  ? Colors.white
                                  : const Color(0xFFC5705E),
                              minimumSize: const Size(40, 40),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFC26A5E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // --- Hero Balance Card (like Telkomsel) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HeroBalanceCard(statsAsync: statsAsync),
            ).animate().fadeIn(
              duration: AppTheme.shortDuration,
              delay: 50.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),

          // --- Quick Actions Row ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: QuickActionRow(
                onTapAdd: () => _showQuickAddSheet(context),
                onTapScan: () {},
                onTapSearch: () => Navigator.pushNamed(context, AppRoutes.search),
                onTapMap: () {},
              ),
            ).animate().fadeIn(
              duration: AppTheme.shortDuration,
              delay: 100.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),

          // --- Smart Nudge Banner ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SmartNudge(),
            ),
          ),

          // --- Recent Items ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: RecentItems(),
            ).animate().fadeIn(
              duration: AppTheme.shortDuration,
              delay: 150.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),

          // --- Category Grid ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CategoryGrid(),
            ).animate().fadeIn(
              duration: AppTheme.shortDuration,
              delay: 200.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),

          // Bottom padding for FAB + nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      floatingActionButton: AnimatedScale(
        scale: _isFabVisible ? 1.0 : 0.0,
        duration: AppTheme.shortDuration,
        curve: Curves.elasticOut,
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showQuickAddSheet(context);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Tambah Barang',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          elevation: 4,
          backgroundColor: const Color(0xFFC5705E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ).animate().scale(
          duration: 600.ms,
          delay: 300.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0, 0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

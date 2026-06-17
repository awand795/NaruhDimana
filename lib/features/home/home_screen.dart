import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/router.dart';
import 'widgets/summary_chips.dart';
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
    final today = DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now());

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            snap: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              expandedTitleScale: 1.0,
              title: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            today,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Notification/bell icon
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.06),
                        foregroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(40, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SummaryChips().animate().fadeIn(
              duration: AppTheme.shortDuration,
              delay: 100.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),
          SliverToBoxAdapter(
            child: SmartNudge(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: RecentItems().animate().fadeIn(
              duration: AppTheme.shortDuration,
              delay: 200.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: CategoryGrid().animate().fadeIn(
              duration: AppTheme.shortDuration,
              delay: 300.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: AppTheme.shortDuration,
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: AppTheme.shortDuration,
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showQuickAddSheet(context);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah'),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ).animate().scale(
            duration: AppTheme.shortDuration,
            delay: 300.ms,
            curve: Curves.elasticOut,
            begin: const Offset(0, 0),
          ),
        ),
      ),
    );
  }
}

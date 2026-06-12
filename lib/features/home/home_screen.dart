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

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now());

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${_getGreeting()} 👋',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ).slideX(begin: -0.05),
                  const SizedBox(height: 2),
                  Text(
                    today,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                  ).animate().fadeIn(
                    duration: 400.ms,
                    delay: 100.ms,
                    curve: Curves.easeOut,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 4,
                bottom: 4,
              ),
              child: Text(
                'Hai, barangmu aman?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.normal,
                    ),
              ).animate().fadeIn(
                duration: 400.ms,
                delay: 150.ms,
                curve: Curves.easeOut,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SummaryChips().animate().fadeIn(
              duration: 400.ms,
              delay: 250.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: RecentItems().animate().fadeIn(
              duration: 400.ms,
              delay: 350.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: CategoryGrid().animate().fadeIn(
              duration: 400.ms,
              delay: 450.ms,
              curve: Curves.easeOut,
            ).slideY(begin: 0.1),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRoutes.addItem);
            },
            icon: const Icon(Icons.add).animate(onPlay: (controller) {
              // Subtle pulse on build
            }).shimmer(duration: 2.seconds, color: Colors.white38),
            label: const Text('Tambah Barang'),
          ).animate().scale(
            duration: 400.ms,
            delay: 500.ms,
            curve: Curves.elasticOut,
            begin: const Offset(0, 0),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/item_provider.dart';
import '../../../core/theme.dart';
import '../../../core/category_helper.dart';
import '../../../core/router.dart';

class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(categoryCountsProvider);
    final mergedAsync = ref.watch(mergedCategoriesProvider);

    return countsAsync.when(
      data: (counts) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kategori', style: Theme.of(context).textTheme.titleMedium),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.manageCategories),
                      child: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              mergedAsync.when(
                data: (categories) => _buildCardGrid(context, categories, counts),
                loading: () => _buildShimmerLoading(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text('Kategori', style: Theme.of(context).textTheme.titleMedium),
            ),
            _buildShimmerLoading(),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCardGrid(BuildContext context, List<MergedCategory> categories, Map<String, int> counts) {
    final sorted = [...categories]..sort((a, b) =>
        (counts[b.slug] ?? 0).compareTo(counts[a.slug] ?? 0));

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final gap = 12.0;
        final cardWidth = (totalWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            ...sorted.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              final count = counts[cat.slug] ?? 0;
              return SizedBox(
                width: cardWidth,
                child: _CategoryCard(category: cat, count: count, index: i),
              );
            }),
            // Add button as card
            SizedBox(
              width: cardWidth,
              child: _AddCategoryCard(index: sorted.length),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final gap = 12.0;
          final cardWidth = (totalWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: List.generate(4, (index) {
              return Container(
                width: cardWidth,
                height: 80,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              );
            }),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final MergedCategory category;
  final int count;
  final int index;

  const _CategoryCard({required this.category, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final baseColor = category.color ?? AppTheme.getCategoryColor(category.slug, context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushNamed(context, AppRoutes.search, arguments: category.slug);
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: baseColor.withValues(alpha: 0.15), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [baseColor.withValues(alpha: 0.15), baseColor.withValues(alpha: 0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(category.icon, color: baseColor, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count barang',
                        style: TextStyle(fontSize: 11, color: baseColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: baseColor.withValues(alpha: 0.3), size: 18),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).scale(
      begin: const Offset(0.95, 0.95),
      curve: Curves.easeOutBack,
    );
  }
}

class _AddCategoryCard extends StatelessWidget {
  final int index;

  const _AddCategoryCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRoutes.manageCategories);
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.25), width: 1),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 24),
                SizedBox(height: 4),
                Text(
                  'Tambah',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms);
  }
}

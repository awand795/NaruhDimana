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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kategori',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.manageCategories),
                    child: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              mergedAsync.when(
                data: (categories) =>
                    _buildBentoGrid(context, categories, counts),
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
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildShimmerLoading(),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBentoGrid(
      BuildContext context, List<MergedCategory> categories, Map<String, int> counts) {
    final sorted = [...categories]..sort((a, b) =>
        (counts[b.slug] ?? 0).compareTo(counts[a.slug] ?? 0));

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final gap = 12.0;
        final smallW = (totalWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            ...sorted.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              final count = counts[cat.slug] ?? 0;
              final isLarge = i == 0 && count > 1;

              return SizedBox(
                width: isLarge ? totalWidth : smallW,
                child: _BentoTile(
                  category: cat,
                  count: count,
                  isLarge: isLarge,
                  index: i,
                ),
              );
            }),
            // Add Category Button
            SizedBox(
              width: smallW,
              child: _AddCategoryTile(index: sorted.length),
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
          final smallW = (totalWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: List.generate(5, (index) {
              final isLarge = index == 0;
              return Container(
                width: isLarge ? totalWidth : smallW,
                height: isLarge ? 80 : 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  final MergedCategory category;
  final int count;
  final bool isLarge;
  final int index;

  const _BentoTile({
    required this.category,
    required this.count,
    required this.isLarge,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = category.color ?? AppTheme.getCategoryColor(category.slug, context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushNamed(context, AppRoutes.search, arguments: category.slug);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: isLarge ? 80 : 64,
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      baseColor.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.white,
                      baseColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: baseColor.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: baseColor.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle background icon for large tiles
              if (isLarge)
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    category.icon,
                    size: 80,
                    color: baseColor.withValues(alpha: 0.08),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLarge ? 20 : 14,
                  vertical: isLarge ? 16 : 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: isLarge ? 48 : 38,
                      height: isLarge ? 48 : 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            baseColor.withValues(alpha: 0.2),
                            baseColor.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        category.icon,
                        color: baseColor,
                        size: isLarge ? 26 : 20,
                      ),
                    ),
                    SizedBox(width: isLarge ? 16 : 10),
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
                              fontSize: isLarge ? 16 : 14,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: baseColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$count barang',
                              style: TextStyle(
                                fontSize: 10,
                                color: baseColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: baseColor.withValues(alpha: 0.3),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 400.ms,
      delay: (index * 50).ms,
    ).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack);
  }
}

class _AddCategoryTile extends StatelessWidget {
  final int index;
  const _AddCategoryTile({required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRoutes.manageCategories);
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 24),
              SizedBox(height: 2),
              Text(
                'Tambah',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 400.ms,
      delay: (index * 50).ms,
    );
  }
}

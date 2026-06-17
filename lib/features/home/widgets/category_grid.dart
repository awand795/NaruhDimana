import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/item_provider.dart';
import '../../../core/constants.dart';
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
              Text(
                'Kategori',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
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
    // Sort berdasarkan count descending
    final sorted = [...categories]..sort((a, b) =>
        (counts[b.slug] ?? 0).compareTo(counts[a.slug] ?? 0));

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final gap = 10.0;
        final smallW = (totalWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: sorted.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final count = counts[cat.slug] ?? 0;

            // Item teratas (count terbesar) dapat tile full width
            final isLarge = i == 0 && count > 2;

            return SizedBox(
              width: isLarge ? totalWidth : smallW,
              child: _BentoTile(
                category: cat,
                count: count,
                isLarge: isLarge,
                index: i,
              ),
            );
          }).toList(),
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
          final gap = 10.0;
          final smallW = (totalWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: List.generate(5, (index) {
              final isLarge = index == 0;
              return Container(
                width: isLarge ? totalWidth : smallW,
                height: isLarge ? 72 : 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
    final catColor = AppTheme.getCategoryColor(category.slug, context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        // Set category filter before navigating to search
        // Note: Use context.read since we're in a StatelessWidget;
        // we pass via route arguments for simplicity
        Navigator.pushNamed(context, AppRoutes.search, arguments: category.slug);
      },
      child: AnimatedContainer(
        duration: AppTheme.microDuration,
        height: isLarge ? 72 : 56,
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 20 : 14,
          vertical: isLarge ? 16 : 10,
        ),
        decoration: BoxDecoration(
          color: catColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: catColor.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isLarge ? 44 : 36,
              height: isLarge ? 44 : 36,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(category.icon,
                  color: catColor, size: isLarge ? 24 : 18),
            ),
            SizedBox(width: isLarge ? 16 : 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: isLarge ? 15 : 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (count > 0)
                    Text(
                      '$count barang',
                      style: TextStyle(
                        fontSize: 11,
                        color: catColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (count > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: catColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: AppTheme.shortDuration,
      delay: (index * 40).ms,
    ).slideY(begin: 0.06);
  }
}

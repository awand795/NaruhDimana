import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/item_provider.dart';
import '../../../core/theme.dart';
import '../../../core/category_helper.dart';
import '../../../core/router.dart';

/// "Kategori Cepat" ala Beranda V6 — scroll horizontal ikon bulat putih
/// dengan ikon ocean-indigo + label, dan tombol "Lihat Semua".
class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(categoryCountsProvider);
    final mergedAsync = ref.watch(mergedCategoriesProvider);

    return countsAsync.when(
      data: (counts) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kategori Cepat', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.manageCategories),
                    child: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            mergedAsync.when(
              data: (categories) => _buildStrip(context, categories, counts),
              loading: () => _buildShimmerLoading(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Kategori Cepat', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 4),
          _buildShimmerLoading(),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStrip(BuildContext context, List<MergedCategory> categories, Map<String, int> counts) {
    final sorted = [...categories]..sort((a, b) => (counts[b.slug] ?? 0).compareTo(counts[a.slug] ?? 0));

    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sorted.length,
        itemBuilder: (context, index) => _CategoryIcon(
          category: sorted[index],
          index: index,
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SizedBox(
      height: 92,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) => Container(
            width: 72,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final MergedCategory category;
  final int index;

  const _CategoryIcon({required this.category, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushNamed(context, AppRoutes.search, arguments: category.slug);
      },
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: AppTheme.softShadow(alpha: 0.08),
              ),
              child: Icon(category.icon, size: 24, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms).slideY(begin: 0.1);
  }
}

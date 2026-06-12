import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import 'constants.dart';

class MergedCategory {
  final String name;
  final IconData icon;
  final String slug;
  final bool isCustom;

  const MergedCategory({
    required this.name,
    required this.icon,
    required this.slug,
    this.isCustom = false,
  });
}

final mergedCategoriesProvider = FutureProvider<List<MergedCategory>>((ref) async {
  final customAsync = ref.watch(customCategoriesProvider);

  final merged = <MergedCategory>[];

  // Add default categories
  for (final cat in AppConstants.categories) {
    merged.add(MergedCategory(
      name: cat.name,
      icon: cat.icon,
      slug: cat.slug,
      isCustom: false,
    ));
  }

  // Add custom categories
  final customList = customAsync.valueOrNull ?? [];
  for (final cat in customList) {
    merged.add(MergedCategory(
      name: cat.name,
      icon: IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
      slug: cat.slug,
      isCustom: true,
    ));
  }

  return merged;
});

/// Look up a MergedCategory by slug from the provided list.
/// Returns null if not found.
MergedCategory? findCategoryBySlug(List<MergedCategory> categories, String slug) {
  try {
    return categories.firstWhere((c) => c.slug == slug);
  } catch (_) {
    return null;
  }
}

/// Look up a MergedCategory by slug, falling back to a default if not found.
MergedCategory findCategoryBySlugOrFallback(
    List<MergedCategory> categories, String slug) {
  return findCategoryBySlug(categories, slug) ??
      const MergedCategory(
        name: 'Lainnya',
        icon: Icons.category,
        slug: 'lainnya',
      );
}

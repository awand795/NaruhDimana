import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category_data.dart';
import '../data/database/database_helper.dart';

final categoryRepositoryProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final customCategoriesProvider =
    StateNotifierProvider<CustomCategoriesNotifier, AsyncValue<List<CategoryData>>>(
  (ref) {
    return CustomCategoriesNotifier(ref.read(categoryRepositoryProvider));
  },
);

class CustomCategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryData>>> {
  final DatabaseHelper _db;

  CustomCategoriesNotifier(this._db) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _db.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> addCategory(String name, int iconCodePoint, {int? colorValue}) async {
    final now = DateTime.now().toIso8601String();
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final category = CategoryData(
      name: name,
      slug: slug,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      createdAt: now,
    );
    final id = await _db.insertCategory(category);
    await loadCategories();
    return id;
  }

  Future<void> updateCategory(CategoryData category) async {
    await _db.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    await loadCategories();
  }
}

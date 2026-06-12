import '../database/database_helper.dart';
import '../models/item_model.dart';

class ItemRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertItem(Item item) => _dbHelper.insertItem(item);

  Future<int> updateItem(Item item) => _dbHelper.updateItem(item);

  Future<int> deleteItem(int id) => _dbHelper.deleteItem(id);

  Future<Item?> getItem(int id) => _dbHelper.getItem(id);

  Future<List<Item>> getAllItems() => _dbHelper.getAllItems();

  Future<List<Item>> getRecentItems(int limit) =>
      _dbHelper.getRecentItems(limit);

  Future<List<Item>> searchItems(String query) =>
      _dbHelper.searchItems(query);

  Future<List<Item>> getItemsByCategory(String category) =>
      _dbHelper.getItemsByCategory(category);

  Future<Map<String, int>> getCategoryCounts() =>
      _dbHelper.getCategoryCounts();

  Future<int> getItemCount() => _dbHelper.getItemCount();

  Future<int> getItemsWithRemindersCount() =>
      _dbHelper.getItemsWithRemindersCount();

  Future<int> getItemsWithGpsCount() =>
      _dbHelper.getItemsWithGpsCount();

  Future<List<Item>> getFilteredItems({
    String? searchQuery,
    String? category,
    bool? hasPhoto,
    bool? hasGps,
    bool? hasReminder,
    String sortBy = 'newest',
  }) =>
      _dbHelper.getFilteredItems(
        searchQuery: searchQuery,
        category: category,
        hasPhoto: hasPhoto,
        hasGps: hasGps,
        hasReminder: hasReminder,
        sortBy: sortBy,
      );

  Future<List<Item>> getItemsWithPendingReminders() =>
      _dbHelper.getItemsWithPendingReminders();
}

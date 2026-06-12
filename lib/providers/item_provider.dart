import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/item_model.dart';
import '../data/repositories/item_repository.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});

final itemsProvider = StateNotifierProvider<ItemsNotifier, AsyncValue<List<Item>>>((ref) {
  return ItemsNotifier(ref.read(itemRepositoryProvider));
});

final recentItemsProvider = FutureProvider<List<Item>>((ref) async {
  final repo = ref.read(itemRepositoryProvider);
  return repo.getRecentItems(5);
});

final categoryCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.read(itemRepositoryProvider);
  return repo.getCategoryCounts();
});

final itemStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.read(itemRepositoryProvider);
  final total = await repo.getItemCount();
  final reminders = await repo.getItemsWithRemindersCount();
  final gps = await repo.getItemsWithGpsCount();
  return {
    'total': total,
    'reminders': reminders,
    'gps': gps,
  };
});

class ItemsNotifier extends StateNotifier<AsyncValue<List<Item>>> {
  final ItemRepository _repository;

  ItemsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final items = await _repository.getAllItems();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> addItem(Item item) async {
    final id = await _repository.insertItem(item);
    await loadItems();
    return id;
  }

  Future<void> updateItem(Item item) async {
    await _repository.updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await _repository.deleteItem(id);
    await loadItems();
  }

  Future<Item?> getItem(int id) async {
    return await _repository.getItem(id);
  }
}

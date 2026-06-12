import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/search_provider.dart';
import '../../data/models/item_model.dart';
import '../../data/repositories/item_repository.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../providers/item_provider.dart';
import '../../services/image_service.dart';
import '../../services/notification_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final ItemRepository _repository = ItemRepository();
  final ImageService _imageService = ImageService();
  final NotificationService _notificationService = NotificationService();
  List<Item> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    ref.read(searchQueryProvider.notifier).state = query;

    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final category = ref.read(selectedCategoryFilterProvider);
      final hasPhoto = ref.read(hasPhotoFilterProvider);
      final hasGps = ref.read(hasGpsFilterProvider);
      final hasReminder = ref.read(hasReminderFilterProvider);
      final sortBy = ref.read(sortByProvider);

      final results = await _repository.getFilteredItems(
        searchQuery: query,
        category: category,
        hasPhoto: hasPhoto,
        hasGps: hasGps,
        hasReminder: hasReminder,
        sortBy: sortBy,
      );

      if (mounted) {
        setState(() => _searchResults = results);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearFilters() {
    ref.read(selectedCategoryFilterProvider.notifier).state = null;
    ref.read(hasPhotoFilterProvider.notifier).state = false;
    ref.read(hasGpsFilterProvider.notifier).state = false;
    ref.read(hasReminderFilterProvider.notifier).state = false;
    ref.read(sortByProvider.notifier).state = 'newest';
    _performSearch(_searchController.text);
  }

  Future<void> _deleteItem(Item item) async {
    // ConfirmDismiss already handles confirmation, this just performs the deletion
    await _imageService.deleteImage(item.photoPath);
    if (item.id != null) {
      await _notificationService.cancelNotification(item.id!);
    }
    await ref.read(itemsProvider.notifier).deleteItem(item.id!);
    HapticFeedback.mediumImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${item.name}" berhasil dihapus'),
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () async {
              await ref.read(itemsProvider.notifier).addItem(item);
            },
          ),
        ),
      );
      _performSearch(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final hasPhoto = ref.watch(hasPhotoFilterProvider);
    final hasGps = ref.watch(hasGpsFilterProvider);
    final hasReminder = ref.watch(hasReminderFilterProvider);
    final sortBy = ref.watch(sortByProvider);

    final hasActiveFilters =
        selectedCategory != null || hasPhoto || hasGps || hasReminder;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Cari Barang',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama, lokasi, catatan...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _performSearch,
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Foto',
                    icon: Icons.image,
                    selected: hasPhoto,
                    onSelected: (_) {
                      ref.read(hasPhotoFilterProvider.notifier).state = !hasPhoto;
                      _performSearch(_searchController.text);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'GPS',
                    icon: Icons.location_on,
                    selected: hasGps,
                    onSelected: (_) {
                      ref.read(hasGpsFilterProvider.notifier).state = !hasGps;
                      _performSearch(_searchController.text);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pengingat',
                    icon: Icons.notifications,
                    selected: hasReminder,
                    onSelected: (_) {
                      ref.read(hasReminderFilterProvider.notifier).state =
                          !hasReminder;
                      _performSearch(_searchController.text);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Kategori',
                    icon: Icons.category,
                    selected: selectedCategory != null,
                    onSelected: (_) => _showCategoryPicker(),
                  ),
                  const SizedBox(width: 8),
                  // Sort
                  PopupMenuButton<String>(
                    initialValue: sortBy,
                    onSelected: (value) {
                      ref.read(sortByProvider.notifier).state = value;
                      _performSearch(_searchController.text);
                    },
                    itemBuilder: (context) => AppConstants.sortOptions.map(
                      (opt) => PopupMenuItem(
                        value: opt['value'],
                        child: Row(
                          children: [
                            if (sortBy == opt['value'])
                              const Icon(Icons.check, size: 18),
                            if (sortBy == opt['value'])
                              const SizedBox(width: 8),
                            Text(opt['label']!),
                          ],
                        ),
                      ),
                    ).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            AppConstants.sortOptions.firstWhere(
                              (o) => o['value'] == sortBy,
                            )['label']!,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasActiveFilters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (selectedCategory != null)
                      Chip(
                        label: Text(
                          'Kategori: ${AppConstants.categories.firstWhere((c) => c.slug == selectedCategory).name}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          ref.read(selectedCategoryFilterProvider.notifier).state =
                              null;
                          _performSearch(_searchController.text);
                        },
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Hapus Filter'),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Barang tidak ditemukan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coba kata kunci lain atau',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Hapus filter pencarian'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_searchController.text.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _searchResults[index];
                  return _SearchResultItem(
                    item: item,
                    onDelete: () => _deleteItem(item),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.detailItem,
                        arguments: item,
                      );
                    },
                  );
                },
                childCount: _searchResults.length,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Cari barangmu',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketikan nama barang untuk mulai mencari',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Kategori',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...AppConstants.categories.map((cat) {
                final isSelected =
                    ref.read(selectedCategoryFilterProvider) == cat.slug;
                return ListTile(
                  leading: Icon(cat.icon, color: AppTheme.primaryColor),
                  title: Text(cat.name),
                  trailing:
                      isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
                  onTap: () {
                    ref.read(selectedCategoryFilterProvider.notifier).state =
                        isSelected ? null : cat.slug;
                    Navigator.pop(ctx);
                    _performSearch(_searchController.text);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = selected ? AppTheme.primaryColor : AppTheme.onSurface;
    final Color textColor = selected ? AppTheme.primaryColor : AppTheme.onSurface;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: textColor),
          ),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      checkmarkColor: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final Item item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.item,
    required this.onDelete,
    required this.onTap,
  });

  String _getTimeAgo() {
    final created = DateTime.parse(item.createdAt);
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return DateFormat('dd MMM', 'id').format(created);
  }

  @override
  Widget build(BuildContext context) {
    final category = AppConstants.categories.firstWhere(
      (c) => c.slug == item.category,
      orElse: () => AppConstants.categories.last,
    );

    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Barang'),
            content: Text('Yakin ingin menghapus "${item.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 52,
              height: 52,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: item.photoPath != null
                  ? Image.file(
                      File(item.photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(category.icon, color: AppTheme.primaryColor),
                    )
                  : Icon(category.icon, color: AppTheme.primaryColor),
            ),
          ),
          title: Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.location,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getTimeAgo(),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, size: 20),
        ),
      ),
    );
  }
}

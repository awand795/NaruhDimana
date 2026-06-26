import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/search_provider.dart';
import '../../providers/search_history_provider.dart';
import '../../data/models/item_model.dart';
import '../../data/repositories/item_repository.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../core/category_helper.dart';
import '../../providers/item_provider.dart';
import '../../services/image_service.dart';
import '../../services/notification_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const SearchScreen({super.key, this.initialCategory});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final ItemRepository _repository = ItemRepository();
  final ImageService _imageService = ImageService();
  final NotificationService _notificationService = NotificationService();
  List<Item> _searchResults = [];
  bool _isLoading = false;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isSearchFocused = _focusNode.hasFocus);
    });
    // Apply initial category filter if provided via route arguments
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedCategoryFilterProvider.notifier).state =
            widget.initialCategory;
        _performSearch(' ');
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
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
        // Simpan history hanya jika ada hasil
        if (results.isNotEmpty && query.trim().length >= 2) {
          ref.read(searchHistoryProvider.notifier).add(query);
        }
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
            expandedHeight: 80,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Cari Barang',
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(duration: 300.ms),
            ),
          ),
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                    if (_isSearchFocused)
                      BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Cari nama, lokasi, catatan...',
                    prefixIcon: AnimatedScale(
                      scale: _isSearchFocused ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.search,
                        color: _isSearchFocused ? AppTheme.primaryColor : AppTheme.textSecondary,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                              _focusNode.unfocus();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: _isSearchFocused
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.85),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: _isSearchFocused
                          ? const BorderSide(color: AppTheme.primaryColor, width: 1.5)
                          : BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    ),
                  ),
                  onChanged: _performSearch,
                  textInputAction: TextInputAction.search,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          ),
          // Filter chips
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
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
            ).animate().fadeIn(duration: 300.ms, delay: 150.ms),
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
                          'Kategori: ${_getSelectedCategoryName(selectedCategory)}',
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
            Consumer(
              builder: (context, ref, _) {
                final mergedAsync = ref.watch(mergedCategoriesProvider);
                final allCategories = mergedAsync.valueOrNull ?? [];
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _searchResults[index];
                      final category = findCategoryBySlugOrFallback(
                        allCategories, item.category,
                      );
                      return _SearchResultItem(
                        item: item,
                        category: category,
                        index: index,
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
                );
              },
            )
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.07),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_rounded,
                          size: 36,
                          color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 20),
                    Text('Cari barangmu',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('Nama, lokasi, atau catatan',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 24),

                    // Search history
                    Consumer(builder: (ctx, ref, _) {
                      final history = ref.watch(searchHistoryProvider);
                      if (history.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pencarian terakhir',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                          color: AppTheme.textSecondary)),
                              TextButton(
                                onPressed: () => ref
                                    .read(searchHistoryProvider.notifier)
                                    .clear(),
                                child: const Text('Hapus',
                                    style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: history
                                .map((q) => ActionChip(
                                      avatar: const Icon(Icons.history_rounded,
                                          size: 14),
                                      label: Text(q,
                                          style: const TextStyle(fontSize: 12)),
                                      onPressed: () {
                                        _searchController.text = q;
                                        _performSearch(q);
                                      },
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),

                    // Category quick access
                    Consumer(builder: (ctx, ref, _) {
                      final cats = ref
                              .watch(mergedCategoriesProvider)
                              .valueOrNull ??
                          [];
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: cats.take(5).map((cat) {
                          final color =
                              AppTheme.getCategoryColor(cat.slug, context);
                          return ActionChip(
                            avatar: Icon(cat.icon, size: 14, color: color),
                            label: Text(cat.name,
                                style:
                                    TextStyle(fontSize: 12, color: color)),
                            backgroundColor: color.withValues(alpha: 0.07),
                            side: BorderSide(
                                color: color.withValues(alpha: 0.2),
                                width: 0.5),
                            onPressed: () {
                              ref
                                  .read(selectedCategoryFilterProvider
                                      .notifier)
                                  .state = cat.slug;
                              _performSearch(' ');
                            },
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  String _getSelectedCategoryName(String slug) {
    final categories = ref.read(mergedCategoriesProvider).valueOrNull ?? [];
    return findCategoryBySlugOrFallback(categories, slug).name;
  }

  void _showCategoryPicker() {
    final categories = ref.read(mergedCategoriesProvider).valueOrNull ?? [];
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
              ...categories.map((cat) {
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) const Icon(Icons.check, size: 14, color: AppTheme.primaryColor),
            if (!selected) Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, color: textColor)),
          ],
        ),
        selected: selected,
        onSelected: onSelected,
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
        checkmarkColor: AppTheme.primaryColor,
        backgroundColor: selected ? AppTheme.primaryColor.withValues(alpha: 0.08) : Colors.white,
        side: BorderSide(color: selected ? AppTheme.primaryColor : Colors.grey.shade300),
        showCheckmark: false,
      ),
    ).animate().scale(
      duration: 200.ms,
      curve: Curves.elasticOut,
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final Item item;
  final MergedCategory category;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.item,
    required this.category,
    required this.index,
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
    final catColor = AppTheme.getCategoryColor(category.slug, context);

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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Hero(
            tag: 'item_thumb_${item.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: catColor.withValues(alpha: 0.3), width: 2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  color: catColor.withValues(alpha: 0.1),
                ),
                child: item.photoPath != null
                    ? Image.file(
                        File(item.photoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(category.icon, color: catColor),
                      )
                    : Icon(category.icon, color: catColor),
              ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(category.name, style: TextStyle(fontSize: 10, color: catColor, fontWeight: FontWeight.w500)),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 11, color: AppTheme.textSecondary),
                      const SizedBox(width: 2),
                      Text(_getTimeAgo(), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, size: 20),
        ),
      ),
    ).animate().fadeIn(
      duration: 300.ms,
      delay: (index * 50).ms,
      curve: Curves.easeOut,
    ).slideY(begin: 0.05);
  }
}

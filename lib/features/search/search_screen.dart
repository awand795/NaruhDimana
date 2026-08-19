import 'dart:io';
import 'dart:math' as math;
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

  void _showSortPicker() {
    final currentSort = ref.read(sortByProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Urutkan', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...AppConstants.sortOptions.map((opt) {
                final isSelected = currentSort == opt['value'];
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    size: 20,
                  ),
                  title: Text(opt['label']!),
                  onTap: () {
                    ref.read(sortByProvider.notifier).state = opt['value']!;
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

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final hasPhoto = ref.watch(hasPhotoFilterProvider);
    final hasGps = ref.watch(hasGpsFilterProvider);
    final hasReminder = ref.watch(hasReminderFilterProvider);
    final sortBy = ref.watch(sortByProvider);

    final hasActiveFilters =
        selectedCategory != null || hasPhoto || hasGps || hasReminder;
    final isTyping = _searchController.text.isNotEmpty;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.background;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: bgColor.withValues(alpha: 0.85),
            title: Text(
              'Cari Barang',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // ── Search bar + scanner button ────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  color: isDark ? AppTheme.darkSurfaceHighest : AppTheme.surfaceContainer,
                  boxShadow: [
                    if (_isSearchFocused)
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(
                      Icons.search_rounded,
                      color: _isSearchFocused
                          ? AppTheme.primaryColor
                          : AppTheme.outline,
                      size: 22,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Cari barang, lokasi...',
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          hintStyle: TextStyle(color: AppTheme.outline),
                        ),
                        onChanged: _performSearch,
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    // Scanner button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pushNamed(context, AppRoutes.scan);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _isSearchFocused
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: const Icon(
                          Icons.document_scanner_outlined,
                          color: AppTheme.outline,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          ),

          // ── Quick filter pills ─────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Sort pill — aktif pertama
                  _QuickFilterPill(
                    label: AppConstants.sortOptions
                        .firstWhere((o) => o['value'] == sortBy)['label']!,
                    icon: Icons.swap_vert_rounded,
                    active: sortBy == 'newest',
                    onTap: _showSortPicker,
                  ),
                  const SizedBox(width: 8),
                  _QuickFilterPill(
                    label: 'Foto',
                    icon: Icons.photo_camera_outlined,
                    active: hasPhoto,
                    onTap: () {
                      ref.read(hasPhotoFilterProvider.notifier).state = !hasPhoto;
                      _performSearch(_searchController.text);
                    },
                  ),
                  const SizedBox(width: 8),
                  _QuickFilterPill(
                    label: 'Lokasi GPS',
                    icon: Icons.location_on_outlined,
                    active: hasGps,
                    onTap: () {
                      ref.read(hasGpsFilterProvider.notifier).state = !hasGps;
                      _performSearch(_searchController.text);
                    },
                  ),
                  const SizedBox(width: 8),
                  _QuickFilterPill(
                    label: 'Kategori',
                    icon: Icons.category_outlined,
                    active: selectedCategory != null,
                    onTap: _showCategoryPicker,
                  ),
                  const SizedBox(width: 8),
                  _QuickFilterPill(
                    label: 'Pengingat',
                    icon: Icons.notifications_none_rounded,
                    active: hasReminder,
                    onTap: () {
                      ref.read(hasReminderFilterProvider.notifier).state =
                          !hasReminder;
                      _performSearch(_searchController.text);
                    },
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
          else if (isTyping && _searchResults.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: AppTheme.outline),
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
          else if (isTyping)
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
            // ── Idle: Riwayat + Kategori Populer + Rekomendasi ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Riwayat Pencarian ─────────────────────
                    Consumer(builder: (ctx, ref, _) {
                      final history = ref.watch(searchHistoryProvider);
                      if (history.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Riwayat Pencarian',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton(
                                onPressed: () => ref
                                    .read(searchHistoryProvider.notifier)
                                    .clear(),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Hapus',
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                              boxShadow: AppTheme.softShadow(alpha: 0.05),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: history.map((q) {
                                return InkWell(
                                  onTap: () {
                                    _searchController.text = q;
                                    _performSearch(q);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: AppTheme.surfaceContainer
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.history_rounded,
                                            color: AppTheme.outline, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            q,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.onSurface),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Transform.rotate(
                                          angle: -math.pi / 4,
                                          child: const Icon(
                                            Icons.arrow_upward,
                                            color: AppTheme.outline,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),

                    // ── Kategori Populer ──────────────────────
                    Consumer(builder: (ctx, ref, _) {
                      final cats = ref
                              .watch(mergedCategoriesProvider)
                              .valueOrNull ??
                          [];
                      if (cats.isEmpty) return const SizedBox.shrink();
                      final popular = cats.take(4).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori Populer',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.6,
                            ),
                            itemCount: popular.length,
                            itemBuilder: (context, index) {
                              final cat = popular[index];
                              final color = AppTheme.getCategoryColor(
                                  cat.slug, context);
                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(selectedCategoryFilterProvider
                                          .notifier)
                                      .state = cat.slug;
                                  _performSearch(' ');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radiusM),
                                    boxShadow:
                                        AppTheme.softShadow(alpha: 0.05),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(cat.icon,
                                            color: color, size: 22),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        cat.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),

                    // ── Rekomendasi ───────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rekomendasi',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Dompet Hitam',
                            'Obat-obatan',
                            'Tas Ransel',
                            'Buku Catatan',
                            'Payung Lipat',
                          ].map((q) {
                            return InkWell(
                              onTap: () {
                                _searchController.text = q;
                                _performSearch(q);
                              },
                              borderRadius: BorderRadius.circular(AppTheme.radiusS),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppTheme.darkSurfaceHighest : AppTheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                ),
                                child: Text(
                                  q,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppTheme.onSurface),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

/// Pill filter ala desain cari_v5: rounded-full, bg surface-container
/// saat off, bg primary saat aktif.
class _QuickFilterPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _QuickFilterPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.shortDuration,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          boxShadow: active ? AppTheme.softShadow(alpha: 0.2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? Colors.white : AppTheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppTheme.onSurface,
              ),
            ),
          ],
        ),
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

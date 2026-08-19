import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../data/models/category_data.dart';
import '../../providers/category_provider.dart';

/// Common Material Icons suitable for categories
const List<IconData> _categoryIcons = [
  Icons.folder,
  Icons.book,
  Icons.shopping_bag,
  Icons.sports_esports,
  Icons.music_note,
  Icons.camera_alt,
  Icons.watch,
  Icons.wallet,
  Icons.key,
  Icons.phone_android,
  Icons.laptop,
  Icons.headphones,
  Icons.directions_car,
  Icons.pedal_bike,
  Icons.kitchen,
  Icons.chair,
  Icons.light,
  Icons.pets,
  Icons.spa,
  Icons.card_giftcard,
  Icons.build,
  Icons.brush,
  Icons.school,
  Icons.favorite,
  Icons.star,
  Icons.home,
  Icons.work,
  Icons.flight,
  Icons.beach_access,
  Icons.restaurant,
];

const List<Color> _categoryColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.amber,
  Colors.indigo,
  Colors.cyan,
  Colors.brown,
  Colors.grey,
];

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  ConsumerState<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState
    extends ConsumerState<ManageCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final customAsync = ref.watch(customCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF0F172A) : AppTheme.surfaceContainerLow;
    final cardColor =
        isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Kelola Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(cardColor),
          ),
        ],
      ),
      body: customAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.category_outlined,
                          size: 40, color: AppTheme.onPrimaryFixedVariant),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Belum ada kategori kustom',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan kategori buatanmu sendiri',
                      style:
                          TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showAddCategoryDialog(cardColor),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Kategori'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final icon = AppConstants
                      .categoryIconByCodePoint[cat.iconCodePoint] ??
                  Icons.category;
              final color = cat.colorValue != null
                  ? Color(cat.colorValue!)
                  : AppTheme.primaryColor;
              final isLast = index == categories.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusM),
                    boxShadow:
                        AppTheme.softShadow(alpha: 0.04),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 22, color: color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(cat.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('Kustom',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _confirmDelete(cat),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.errorContainer
                                .withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppTheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Gagal memuat kategori')),
      ),
    );
  }

  void _showAddCategoryDialog(Color cardColor) {
    final nameController = TextEditingController();
    int selectedIconCodePoint = Icons.folder.codePoint;
    Color selectedColor = AppTheme.primaryColor;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          ),
          title: const Text('Tambah Kategori'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kategori',
                      hintText: 'Contoh: Elektronik',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Icon',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: _categoryIcons.length,
                      itemBuilder: (context, index) {
                        final icon = _categoryIcons[index];
                        final isSelected =
                            icon.codePoint == selectedIconCodePoint;
                        return GestureDetector(
                          onTap: () => setDialogState(
                              () => selectedIconCodePoint =
                                  icon.codePoint),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedColor
                                      .withValues(alpha: 0.15)
                                  : AppTheme.surfaceContainer,
                              borderRadius:
                                  BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(
                                      color: selectedColor,
                                      width: 2)
                                  : null,
                            ),
                            child: Icon(icon,
                                size: 24,
                                color: isSelected
                                    ? selectedColor
                                    : Colors.grey.shade600),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Warna',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _categoryColors.length,
                      itemBuilder: (context, index) {
                        final color = _categoryColors[index];
                        final isSelected = color == selectedColor;
                        return GestureDetector(
                          onTap: () => setDialogState(
                              () => selectedColor = color),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: Colors.black,
                                      width: 2)
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white,
                                    size: 16)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final name =
                          nameController.text.trim();
                      if (name.isEmpty) return;

                      setDialogState(() => isSaving = true);
                      try {
                        await ref
                            .read(customCategoriesProvider
                                .notifier)
                            .addCategory(
                              name,
                              selectedIconCodePoint,
                              colorValue:
                                  selectedColor.toARGB32(),
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                        HapticFeedback.lightImpact();
                      } catch (e) {
                        setDialogState(
                            () => isSaving = false);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(content: Text('Gagal: $e')),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(CategoryData cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        title: const Text('Hapus Kategori'),
        content:
            Text('Yakin ingin menghapus kategori "${cat.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && cat.id != null) {
      await ref
          .read(customCategoriesProvider.notifier)
          .deleteCategory(cat.id!);
      HapticFeedback.mediumImpact();
    }
  }
}

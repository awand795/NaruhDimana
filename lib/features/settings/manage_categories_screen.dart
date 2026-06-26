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
  ConsumerState<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends ConsumerState<ManageCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final customAsync = ref.watch(customCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
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
                    Icon(
                      Icons.category,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada kategori kustom',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan kategori buatanmu sendiri',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddCategoryDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Kategori'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    AppConstants.categoryIconByCodePoint[cat.iconCodePoint] ?? Icons.category,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: Text(cat.name),
                subtitle: Text('slug: ${cat.slug}', style: const TextStyle(fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(cat),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Gagal memuat kategori')),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    int selectedIconCodePoint = Icons.folder.codePoint;
    Color selectedColor = AppTheme.primaryColor;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Icon',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: _categoryIcons.length,
                      itemBuilder: (context, index) {
                        final icon = _categoryIcons[index];
                        final isSelected = icon.codePoint == selectedIconCodePoint;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedIconCodePoint = icon.codePoint),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor.withValues(alpha: 0.15) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
                            ),
                            child: Icon(
                              icon,
                              size: 24,
                              color: isSelected ? selectedColor : Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Warna',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _categoryColors.length,
                      itemBuilder: (context, index) {
                        final color = _categoryColors[index];
                        final isSelected = color == selectedColor;
                        return GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = color),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
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
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      setDialogState(() => isSaving = true);
                      try {
                        await ref.read(customCategoriesProvider.notifier).addCategory(
                              name,
                              selectedIconCodePoint,
                              colorValue: selectedColor.toARGB32(),
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                        HapticFeedback.lightImpact();
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal: $e')),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus kategori "${cat.name}"?'),
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

    if (confirm == true && cat.id != null) {
      await ref.read(customCategoriesProvider.notifier).deleteCategory(cat.id!);
      HapticFeedback.mediumImpact();
    }
  }
}

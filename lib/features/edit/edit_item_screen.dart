import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/item_model.dart';
import '../../providers/item_provider.dart';
import '../../services/image_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../core/theme.dart';
import '../../core/category_helper.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final Item item;

  const EditItemScreen({super.key, required this.item});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();

  final ImageService _imageService = ImageService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  late String _selectedCategory;
  List<String> _photoPaths = [];
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isSaving = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController.text = item.name;
    _locationController.text = item.location;
    _tagsController.text = item.tags ?? '';
    _notesController.text = item.notes ?? '';
    _selectedCategory = item.category;
    _photoPaths = [...(item.photoPaths ?? [])];
    if (_photoPaths.isEmpty && item.photoPath != null) {
      _photoPaths.add(item.photoPath!);
    }
    _latitude = item.latitude;
    _longitude = item.longitude;
    _address = item.address;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final status = source == ImageSource.camera 
        ? await Permission.camera.request()
        : await Permission.photos.request();
        
    if (!status.isGranted && !status.isLimited) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin diperlukan')),
        );
      }
      return;
    }

    if (source == ImageSource.camera) {
      final path = await _imageService.pickFromCamera();
      if (path != null && mounted) {
        setState(() => _photoPaths.add(path));
      }
    } else {
      final paths = await _imageService.pickMultipleFromGallery();
      if (paths.isNotEmpty && mounted) {
        setState(() => _photoPaths.addAll(paths));
      }
    }
  }

  Future<void> _saveLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final address = await _locationService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            _address = address;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lokasi disimpan: $address'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mendapatkan lokasi. Pastikan GPS aktif.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toIso8601String();
      final updatedItem = widget.item.copyWith(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        category: _selectedCategory,
        tags: _tagsController.text.trim().isEmpty
            ? null
            : _tagsController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        photoPaths: _photoPaths.isEmpty ? null : _photoPaths,
        photoPath: _photoPaths.isNotEmpty ? _photoPaths.first : null,
        latitude: _latitude,
        longitude: _longitude,
        address: _address,
        updatedAt: now,
      );

      await ref.read(itemsProvider.notifier).updateItem(updatedItem);

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedItem);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin ingin menghapus "${widget.item.name}"?'),
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

    if (confirm == true) {
      await ref.read(itemsProvider.notifier).deleteItem(widget.item.id!);
      await _notificationService.cancelNotification(widget.item.id!);
      await _imageService.deleteImage(widget.item.photoPath);
      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Barang'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo Section
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () => _showImagePickerOptions(context),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: AppTheme.textSecondary),
                          const SizedBox(height: 4),
                          Text('Tambah', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ..._photoPaths.asMap().entries.map((entry) {
                    final index = entry.key;
                    final path = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _photoPaths.removeAt(index)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Barang *',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama barang wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi Penyimpanan *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lokasi penyimpanan wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            Text('Kategori', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final mergedAsync = ref.watch(mergedCategoriesProvider);
                return mergedAsync.when(
                  data: (categories) => SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...categories.map((cat) {
                          final isSelected = _selectedCategory == cat.slug;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cat.icon,
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.primaryColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              selected: isSelected,
                              selectedColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.onSurface,
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = cat.slug),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 44,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (_, __) => const SizedBox(height: 44),
                );
              },
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tag (opsional)',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 20),

            Text('Lokasi GPS', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _saveLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_latitude != null
                        ? Icons.location_on
                        : Icons.add_location),
                label: Text(_latitude != null
                    ? 'Lokasi GPS Tersimpan'
                    : 'Simpan Lokasi GPS Sekarang'),
              ),
            ),
            if (_address != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_address!,
                          style: TextStyle(
                              fontSize: 13, color: Colors.green.shade800)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                prefixIcon: Icon(Icons.note_add_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan Perubahan',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // Delete button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _deleteItem,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Barang'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tambahkan Foto',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              ListTile(
                leading:
                    const CircleAvatar(child: Icon(Icons.camera_alt)),
                title: const Text('Ambil Foto'),
                subtitle: const Text('Gunakan kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const CircleAvatar(child: Icon(Icons.photo_library)),
                title: const Text('Pilih dari Galeri'),
                subtitle: const Text('Dari penyimpanan'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

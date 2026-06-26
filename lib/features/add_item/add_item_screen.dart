import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/item_model.dart';
import '../../providers/item_provider.dart';
import '../../services/image_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/category_helper.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  final _notesController = TextEditingController();

  final ImageService _imageService = ImageService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  String _selectedCategory = 'lainnya';
  List<String> _photoPaths = [];
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isSaving = false;
  bool _isLoadingLocation = false;

  DateTime? _selectedReminderTime;
  String _reminderRepeat = 'none';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _sectionHeader(
      BuildContext context, String title, IconData icon, int step, int totalSteps) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFC5705E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFFC5705E)),
          ),
          const SizedBox(width: 10),
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          )),
          const Spacer(),
          Text(
            '$step / $totalSteps',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
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
              backgroundColor: const Color(0xFF7C9A7A),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mendapatkan lokasi. Pastikan GPS aktif.'),
              backgroundColor: const Color(0xFFC26A5E),
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

  Future<void> _pickReminderDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id'),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    if (time == null || !mounted) return;

    final repeatResult = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Ulangi Pengingat'),
        children: AppConstants.reminderRepeatOptions.map((opt) =>
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, opt['value'] as String),
            child: Text(opt['label'] as String),
          ),
        ).toList(),
      ),
    );
    if (repeatResult == null) return;

    setState(() {
      _selectedReminderTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
      _reminderRepeat = repeatResult;
    });
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toIso8601String();
      final item = Item(
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
        reminderTime: _selectedReminderTime?.toIso8601String(),
        reminderRepeat: _reminderRepeat,
        createdAt: now,
        updatedAt: now,
      );

      final savedId = await ref.read(itemsProvider.notifier).addItem(item);

      if (_selectedReminderTime != null) {
        final savedItem = item.copyWith(id: savedId);
        await _notificationService.scheduleNotification(savedItem);
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Barang'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveItem,
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
            // Section 1: Foto
            _sectionHeader(context, 'Foto', Icons.camera_alt_outlined, 1, 4),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add button
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
                  // List of images
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
            const SizedBox(height: 24),

            // Section 2: Info barang
            _sectionHeader(context, 'Info barang', Icons.info_outline_rounded, 2, 4),

            // Item Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Barang *',
                hintText: 'Contoh: Kunci Motor Honda',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama barang wajib diisi';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Storage Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi Penyimpanan *',
                hintText: 'Contoh: Laci meja kamar',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lokasi penyimpanan wajib diisi';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Category picker — Wrap style like QuickAddSheet
            Text(
              'Kategori',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final mergedAsync = ref.watch(mergedCategoriesProvider);
                return mergedAsync.when(
                  data: (categories) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat.slug;
                      final catColor =
                          AppTheme.getCategoryColor(cat.slug, context);
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat.slug);
                        },
                        child: AnimatedContainer(
                          duration: AppTheme.microDuration,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? catColor.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? catColor
                                  : AppTheme.textSecondary
                                      .withValues(alpha: 0.25),
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon,
                                    size: 16,
                                    color: isSelected
                                        ? catColor
                                        : AppTheme.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected
                                        ? catColor
                                        : AppTheme.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ]),
                        ),
                      );
                    }).toList(),
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

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tag (opsional)',
                hintText: 'Pisahkan dengan koma, contoh: rumah, penting',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 24),

            // Section 3: Lokasi GPS
            _sectionHeader(context, 'Lokasi GPS', Icons.map_outlined, 3, 4),
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
                    : Icon(
                        _latitude != null
                            ? Icons.location_on
                            : Icons.add_location,
                        color: _latitude != null ? Colors.green : null,
                      ),
                label: Text(
                  _latitude != null
                      ? 'Lokasi GPS Tersimpan'
                      : 'Simpan Lokasi GPS Sekarang',
                ),
              ),
            ),
            if (_address != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C9A7A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7C9A7A).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: const Color(0xFF7C9A7A), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _address!,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF5A7A58),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                hintText: 'Tambahkan catatan tambahan...',
                prefixIcon: Icon(Icons.note_add_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Section 4: Pengingat
            _sectionHeader(context, 'Pengingat', Icons.alarm_outlined, 4, 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickReminderDateTime,
                icon: Icon(
                  _selectedReminderTime != null ? Icons.alarm_on : Icons.add_alarm,
                  color: _selectedReminderTime != null ? Colors.green : null,
                ),
                label: Text(
                  _selectedReminderTime != null
                    ? 'Pengingat: ${DateFormat('dd MMM, HH:mm', 'id').format(_selectedReminderTime!)}'
                    : 'Atur Pengingat (opsional)',
                ),
              ),
            ),
            if (_selectedReminderTime != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _selectedReminderTime = null;
                      _reminderRepeat = 'none';
                    }),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Hapus pengingat'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFC26A5E)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveItem,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan Barang',
                        style: TextStyle(fontSize: 16),
                      ),
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
              Text(
                'Tambahkan Foto',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.camera_alt),
                ),
                title: const Text('Ambil Foto'),
                subtitle: const Text('Gunakan kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.photo_library),
                ),
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

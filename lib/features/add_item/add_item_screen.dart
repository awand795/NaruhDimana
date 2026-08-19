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
import '../../core/router.dart';
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

  final ImageService _imageService = ImageService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  String _selectedCategory = 'lainnya';
  final List<String> _photoPaths = [];
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isSaving = false;
  bool _isLoadingLocation = false;

  // Toggle state
  bool _reminderEnabled = false;
  DateTime? _selectedReminderTime;
  String _reminderRepeat = 'none';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final status = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();
    if (!status.isGranted && !status.isLimited) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Izin diperlukan')));
      }
      return;
    }
    if (source == ImageSource.camera) {
      final path = await _imageService.pickFromCamera();
      if (path != null && mounted) setState(() => _photoPaths.add(path));
    } else {
      final paths = await _imageService.pickMultipleFromGallery();
      if (paths.isNotEmpty && mounted) setState(() => _photoPaths.addAll(paths));
    }
  }

  /// Ambil lokasi GPS saat toggle dinyalakan
  Future<void> _toggleGps(bool enabled) async {
    if (!enabled) {
      setState(() {
        _latitude = null;
        _longitude = null;
        _address = null;
      });
      return;
    }
    setState(() => _isLoadingLocation = true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null && mounted) {
        final address = await _locationService.getAddressFromLatLng(
            position.latitude, position.longitude);
        if (mounted) {
          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            _address = address;
          });
        }
      } else {
        if (mounted) {
          setState(() => _latitude = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mendapatkan lokasi. Pastikan GPS aktif.'),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _latitude = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  /// Saat toggle pengingat dinyalakan → pilih tanggal, jam, dan repeat
  Future<void> _toggleReminder(bool enabled) async {
    if (!enabled) {
      setState(() {
        _reminderEnabled = false;
        _selectedReminderTime = null;
        _reminderRepeat = 'none';
      });
      return;
    }
    final picked = await _pickReminderDateTime();
    if (picked == null && mounted) {
      setState(() => _reminderEnabled = false);
      return;
    }
  }

  /// Pilih tanggal + jam + repeat. Kembalikan null jika dibatalkan.
  Future<DateTime?> _pickReminderDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id'),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return null;
    final repeatResult = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Ulangi Pengingat'),
        children: AppConstants.reminderRepeatOptions
            .map((opt) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, opt['value'] as String),
                  child: Text(opt['label'] as String),
                ))
            .toList(),
      ),
    );
    if (repeatResult == null || !mounted) return null;

    final reminderTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _reminderEnabled = true;
      _selectedReminderTime = reminderTime;
      _reminderRepeat = repeatResult;
    });
    return reminderTime;
  }

  /// Bottom sheet lokasi terbaru dari barang yang sudah tersimpan
  Future<void> _showLocationHistory() async {
    final items = ref.read(itemsProvider).valueOrNull ?? [];
    final locations = items
        .map((i) => i.location.trim())
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList();
    if (locations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada lokasi tersimpan')),
      );
      return;
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Lokasi Terbaru',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 8),
              ...locations.map((loc) => ListTile(
                    leading: const Icon(Icons.history_rounded,
                        color: AppTheme.outline),
                    title: Text(loc),
                    onTap: () {
                      _locationController.text = loc;
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
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
            backgroundColor: Color(0xFF059669),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF232936) : AppTheme.surfaceContainerLow;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Tambah Barang'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Foto tile (aspect 4:3) ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: _PhotoTile(
                photoPaths: _photoPaths,
                onAdd: () => _showImagePickerOptions(context),
                onRemove: (index) =>
                    setState(() => _photoPaths.removeAt(index)),
              ),
            ),

            // ── Fields ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Nama Barang',
                    hint: 'Contoh: Kamera DSLR Canon',
                    controller: _nameController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama barang wajib diisi'
                        : null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: 'Lokasi Simpan',
                    hint: 'Contoh: Lemari Kaca Laci 2',
                    controller: _locationController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Lokasi penyimpanan wajib diisi'
                        : null,
                    textCapitalization: TextCapitalization.sentences,
                    suffix: _FieldIconButton(
                      icon: Icons.history_rounded,
                      tooltip: 'Pilih lokasi terbaru',
                      onTap: _showLocationHistory,
                    ),
                  ),
                ],
              ),
            ),

            // ── Kategori pill ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategori',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Consumer(builder: (context, ref, _) {
                    final mergedAsync = ref.watch(mergedCategoriesProvider);
                    return mergedAsync.when(
                      data: (categories) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...categories.map((cat) {
                            final isSelected = _selectedCategory == cat.slug;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat.slug),
                              child: AnimatedContainer(
                                duration: AppTheme.shortDuration,
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : (isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.white),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusPill),
                                  boxShadow: isSelected
                                      ? AppTheme.softShadow(alpha: 0.2)
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cat.icon,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          // Tombol tambah kategori
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.manageCategories),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: AppTheme.softShadow(alpha: 0.04),
                              ),
                              child: const Icon(Icons.add_rounded,
                                  color: AppTheme.primaryColor, size: 20),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const SizedBox(
                        height: 40,
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      error: (_, __) => const SizedBox(height: 40),
                    );
                  }),
                ],
              ),
            ),

            // ── Toggle cards ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                children: [
                  _ToggleCard(
                    icon: Icons.notifications_rounded,
                    iconBg: AppTheme.secondaryFixed,
                    iconColor: AppTheme.onSecondaryFixedVariant,
                    title: 'Set Pengingat',
                    subtitle: _reminderEnabled && _selectedReminderTime != null
                        ? '${DateFormat('dd MMM, HH:mm', 'id').format(_selectedReminderTime!)} · ${_repeatLabel()}'
                        : 'Ingatkan perawatan atau expired',
                    value: _reminderEnabled,
                    onChanged: _toggleReminder,
                  ),
                  const SizedBox(height: 12),
                  _ToggleCard(
                    icon: Icons.location_on_rounded,
                    iconBg: AppTheme.primaryFixed,
                    iconColor: AppTheme.onPrimaryFixedVariant,
                    title: 'Simpan Lokasi GPS',
                    subtitle: _address ?? 'Tandai lokasi presisi saat ini',
                    value: _latitude != null,
                    loading: _isLoadingLocation,
                    onChanged: _toggleGps,
                  ),
                ],
              ),
            ),

            // ── Tombol Simpan ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Text('Menyimpan...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Simpan Barang',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _repeatLabel() {
    for (final opt in AppConstants.reminderRepeatOptions) {
      if (opt['value'] == _reminderRepeat) return opt['label']!;
    }
    return 'Tidak';
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
                title: const Text('Ambil Foto'),
                subtitle: const Text('Gunakan kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.photo_library)),
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

// ── Foto tile 4:3 ──────────────────────────────────────────
class _PhotoTile extends StatelessWidget {
  final List<String> photoPaths;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _PhotoTile({
    required this.photoPaths,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor =
        isDark ? const Color(0xFF2B3242) : AppTheme.surfaceContainer;

    return Column(
      children: [
        GestureDetector(
          onTap: onAdd,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              child: photoPaths.isEmpty
                  ? Container(
                      color: tileColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF333B4D)
                                  : AppTheme.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.softShadow(alpha: 0.06),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined,
                                size: 28, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Ambil Foto Barang',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'atau pilih dari galeri',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.outline),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(photoPaths.first),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: tileColor,
                            child: const Icon(Icons.image_outlined,
                                size: 48, color: AppTheme.outline),
                          ),
                        ),
                        // Overlay ganti foto
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        // Thumbnail strip untuk foto tambahan
        if (photoPaths.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoPaths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isFirst = index == 0;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(photoPaths[index]),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 64,
                          height: 64,
                          color: tileColor,
                        ),
                      ),
                    ),
                    if (!isFirst)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => onRemove(index),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ── Field dengan label di atas ─────────────────────────────
class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final Widget? suffix;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class _FieldIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _FieldIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppTheme.primaryColor),
      tooltip: tooltip,
      onPressed: onTap,
    );
  }
}

// ── Toggle card ────────────────────────────────────────────
class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool loading;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    this.loading = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.softShadow(alpha: 0.04),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppTheme.primaryColor,
            ),
        ],
      ),
    );
  }
}

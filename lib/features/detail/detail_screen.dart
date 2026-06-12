import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/item_model.dart';
import '../../providers/item_provider.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../services/image_service.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/router.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Item item;

  const DetailScreen({super.key, required this.item});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final ImageService _imageService = ImageService();

  late Item _item;

  // Reminder state
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _item = widget.item;

    // Parse existing reminder
    if (_item.reminderTime != null) {
      final dt = DateTime.tryParse(_item.reminderTime!);
      if (dt != null) {
        _selectedDate = dt;
        _selectedTime = TimeOfDay.fromDateTime(dt);
      }
    }
  }

  Future<void> _shareItem() async {
    final text = StringBuffer();
    text.writeln('📍 ${_item.name}');
    text.writeln('🗂️ Disimpan di: ${_item.location}');
    text.writeln('🏷️ Kategori: ${_getCategoryName()}');

    if (_item.tags != null && _item.tags!.isNotEmpty) {
      text.writeln('🔖 Tag: ${_item.tags}');
    }
    if (_item.address != null) {
      text.writeln('📍 Lokasi GPS: ${_item.address}');
    }
    if (_item.notes != null && _item.notes!.isNotEmpty) {
      text.writeln('📝 Catatan: ${_item.notes}');
    }
    text.writeln();
    text.writeln('— Dari NaruhDimana');

    await Share.share(
      text.toString(),
      subject: _item.name,
    );
  }

  String _getCategoryName() {
    final categories = AppConstants.categories.where(
      (c) => c.slug == _item.category,
    );
    return categories.isNotEmpty ? categories.first.name : 'Lainnya';
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin ingin menghapus "${_item.name}"?'),
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
      await ref.read(itemsProvider.notifier).deleteItem(_item.id!);
      await _notificationService.cancelNotification(_item.id!);
      await _imageService.deleteImage(_item.photoPath);
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${_item.name}" berhasil dihapus'),
            action: SnackBarAction(
              label: 'Urungkan',
              onPressed: () {
                ref.read(itemsProvider.notifier).addItem(_item);
              },
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _setReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id'),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });

    final repeatResult = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Ulangi Pengingat'),
        children: AppConstants.reminderRepeatOptions.map((opt) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, opt['value']),
            child: Text(opt['label']!),
          );
        }).toList(),
      ),
    );

    if (repeatResult == null) return;

    final reminderDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final updatedItem = _item.copyWith(
      reminderTime: reminderDateTime.toIso8601String(),
      reminderRepeat: repeatResult,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await ref.read(itemsProvider.notifier).updateItem(updatedItem);

    if (_item.reminderTime != null) {
      await _notificationService.cancelNotification(_item.id!);
    }
    await _notificationService.scheduleNotification(updatedItem);

    setState(() => _item = updatedItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat berhasil diatur!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = AppConstants.categories.firstWhere(
      (c) => c.slug == _item.category,
      orElse: () => AppConstants.categories.last,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'item_photo_${_item.id}',
                child: _item.photoPath != null
                    ? Image.file(
                        File(_item.photoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(category),
                      )
                    : _buildPlaceholder(category),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareItem,
                tooltip: 'Bagikan',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.editItem,
                    arguments: _item,
                  );
                  if (result is Item) {
                    setState(() => _item = result);
                  }
                },
                tooltip: 'Edit',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    _item.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon,
                            size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    title: 'Lokasi Penyimpanan',
                    subtitle: _item.location,
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  if (_item.tags != null && _item.tags!.isNotEmpty)
                    _InfoRow(
                      icon: Icons.label_outline,
                      title: 'Tag',
                      subtitle: _item.tags!,
                    ),
                  if (_item.tags != null && _item.tags!.isNotEmpty)
                    const SizedBox(height: 16),

                  // Notes
                  if (_item.notes != null && _item.notes!.isNotEmpty) ...[
                    _InfoRow(
                      icon: Icons.note_outlined,
                      title: 'Catatan',
                      subtitle: _item.notes!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Date info
                  _InfoRow(
                    icon: Icons.access_time,
                    title: 'Ditambahkan',
                    subtitle: DateFormat('dd MMMM yyyy, HH:mm', 'id')
                        .format(DateTime.parse(_item.createdAt)),
                  ),
                  const SizedBox(height: 24),

                  // GPS Section
                  if (_item.latitude != null && _item.longitude != null) ...[
                    Text(
                      'Lokasi GPS',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_item.address != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _item.address!,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    // Map Preview
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.fullMap,
                          arguments: _item,
                        );
                      },
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                _item.latitude!,
                                _item.longitude!,
                              ),
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: AppConstants.mapTileUrl,
                                userAgentPackageName: 'com.naruhdimana.naruh_dimana',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      _item.latitude!,
                                      _item.longitude!,
                                    ),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Open in Maps button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _locationService.openInMaps(
                            _item.latitude!,
                            _item.longitude!,
                            itemName: _item.name,
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Buka di Maps'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Reminder Section
                  Text(
                    'Pengingat',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_item.reminderTime != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active,
                              color: AppTheme.secondaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMMM yyyy, HH:mm', 'id')
                                      .format(DateTime.parse(_item.reminderTime!)),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_item.reminderRepeat != 'none')
                                  Text(
                                    _item.reminderRepeat == 'daily'
                                        ? 'Berulang setiap hari'
                                        : 'Berulang setiap minggu',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),              onPressed: () {
                _notificationService.cancelNotification(_item.id!);
                final updatedItem = _item.copyWith(
                  reminderTime: null,
                  reminderRepeat: 'none',
                  updatedAt: DateTime.now().toIso8601String(),
                );
                ref
                    .read(itemsProvider.notifier)
                    .updateItem(updatedItem);
                setState(() => _item = updatedItem);
              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _setReminder,
                      icon: const Icon(Icons.add_alarm),
                      label: Text(
                        _item.reminderTime != null
                            ? 'Ubah Pengingat'
                            : 'Atur Pengingat',
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Delete button
                  SizedBox(
                    width: double.infinity,
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
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(CategoryInfo category) {
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(category.icon, size: 80, color: AppTheme.primaryColor),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

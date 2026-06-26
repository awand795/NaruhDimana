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
import '../../core/category_helper.dart';

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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    if (_item.reminderTime != null) {
      final dt = DateTime.tryParse(_item.reminderTime!);
      if (dt != null) { _selectedDate = dt; _selectedTime = TimeOfDay.fromDateTime(dt); }
    }
  }

  Future<void> _shareItem() async {
    final text = StringBuffer();
    text.writeln('📍 ${_item.name}'); text.writeln('🗂️ Disimpan di: ${_item.location}');
    text.writeln('🏷️ Kategori: ${_getCategoryName()}');
    if (_item.tags != null && _item.tags!.isNotEmpty) text.writeln('🔖 Tag: ${_item.tags}');
    if (_item.address != null) text.writeln('📍 Lokasi GPS: ${_item.address}');
    if (_item.notes != null && _item.notes!.isNotEmpty) text.writeln('📝 Catatan: ${_item.notes}');
    text.writeln(); text.writeln('— Dari NaruhDimana');
    await Share.share(text.toString(), subject: _item.name);
  }

  String _getCategoryName() {
    final mergedAsync = ref.read(mergedCategoriesProvider);
    return findCategoryBySlugOrFallback(mergedAsync.valueOrNull ?? [], _item.category).name;
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin ingin menghapus "${_item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Hapus')),
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
          SnackBar(content: Text('"${_item.name}" berhasil dihapus'), action: SnackBarAction(label: 'Urungkan', onPressed: () => ref.read(itemsProvider.notifier).addItem(_item))),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _setReminder() async {
    final date = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now().add(const Duration(hours: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), locale: const Locale('id'));
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: _selectedTime ?? TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))));
    if (time == null) return;
    setState(() { _selectedDate = date; _selectedTime = time; });
    final repeatResult = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Ulangi Pengingat'),
        children: AppConstants.reminderRepeatOptions.map((opt) => SimpleDialogOption(onPressed: () => Navigator.pop(ctx, opt['value']), child: Text(opt['label']!))).toList(),
      ),
    );
    if (repeatResult == null) return;
    final reminderDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final updatedItem = _item.copyWith(reminderTime: reminderDateTime.toIso8601String(), reminderRepeat: repeatResult, updatedAt: DateTime.now().toIso8601String());
    await ref.read(itemsProvider.notifier).updateItem(updatedItem);
    if (_item.reminderTime != null) await _notificationService.cancelNotification(_item.id!);
    await _notificationService.scheduleNotification(updatedItem);
    setState(() => _item = updatedItem);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengingat berhasil diatur!'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final mergedAsync = ref.watch(mergedCategoriesProvider);
    final allCategories = mergedAsync.valueOrNull ?? [];
    final category = findCategoryBySlugOrFallback(allCategories, _item.category);
    final catColor = AppTheme.getCategoryColor(_item.category, context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar with gradient overlay ─────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Hero(tag: 'item_photo_${_item.id}', child: _buildImageBackground(category, catColor)),
                  // Gradient overlay for readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: 0.15)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: _shareItem, tooltip: 'Bagikan', color: Colors.white),
              IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.editItem, arguments: _item);
                if (result is Item) setState(() => _item = result);
              }, tooltip: 'Edit', color: Colors.white),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                onSelected: (v) { if (v == 'delete') _deleteItem(); },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 18), SizedBox(width: 10), Text('Hapus barang', style: TextStyle(color: Color(0xFFDC2626)))])),
                ],
              ),
            ],
          ),
          // ── Content ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name — larger, bolder
                  Text(_item.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 12),

                  // Category badge with glow shadow
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.glowShadow(catColor, alpha: 0.15),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(category.icon, size: 16, color: catColor),
                      const SizedBox(width: 6),
                      Text(category.name, style: TextStyle(color: catColor, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // ── Info rows ───────────────────────────────
                  _DetailInfoRow(icon: Icons.location_on_outlined, title: 'LOKASI PENYIMPANAN', subtitle: _item.location, catColor: catColor),
                  const SizedBox(height: AppTheme.spacingM),

                  if (_item.tags != null && _item.tags!.isNotEmpty) ...[
                    _DetailInfoRow(icon: Icons.label_outline, title: 'TAG', subtitle: _item.tags!, catColor: catColor),
                    const SizedBox(height: AppTheme.spacingM),
                  ],
                  if (_item.notes != null && _item.notes!.isNotEmpty) ...[
                    _DetailInfoRow(icon: Icons.note_outlined, title: 'CATATAN', subtitle: _item.notes!, catColor: catColor),
                    const SizedBox(height: AppTheme.spacingM),
                  ],
                  _DetailInfoRow(icon: Icons.access_time, title: 'DITAMBAHKAN', subtitle: DateFormat('dd MMMM yyyy, HH:mm', 'id').format(DateTime.parse(_item.createdAt)), catColor: catColor),
                  const SizedBox(height: AppTheme.spacingL),

                  // ── GPS Section ─────────────────────────────
                  if (_item.latitude != null && _item.longitude != null) ...[
                    Text('Lokasi GPS', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppTheme.spacingS),
                    if (_item.address != null) Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      child: Text(_item.address!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ),
                    // Map preview with overlay
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.fullMap, arguments: _item),
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppTheme.radiusXL)),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(_item.latitude!, _item.longitude!),
                                  initialZoom: 15,
                                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                                ),
                                children: [
                                  TileLayer(urlTemplate: AppConstants.mapTileUrl, userAgentPackageName: 'com.naruhdimana.naruh_dimana'),
                                  MarkerLayer(markers: [
                                    Marker(point: LatLng(_item.latitude!, _item.longitude!), width: 40, height: 40,
                                      child: const Icon(Icons.location_on, color: Color(0xFF0D7377), size: 40)),
                                  ]),
                                ],
                              ),
                            ),
                            // Bottom overlay
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.black.withValues(alpha: 0.5), Colors.black.withValues(alpha: 0.2), Colors.transparent],
                                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.touch_app, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text('Ketuk untuk peta penuh', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _locationService.openInMaps(_item.latitude!, _item.longitude!, itemName: _item.name),
                        icon: const Icon(Icons.map), label: const Text('Buka di Maps'),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                  ],

                  // ── Reminder ────────────────────────────────
                  Text('Pengingat', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppTheme.spacingS),
                  if (_item.reminderTime != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0D7377), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Row(children: [
                        const Icon(Icons.notifications_active, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(DateFormat('dd MMMM yyyy, HH:mm', 'id').format(DateTime.parse(_item.reminderTime!)),
                            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                          if (_item.reminderRepeat != 'none')
                            Text(_item.reminderRepeat == 'daily' ? 'Berulang setiap hari' : 'Berulang setiap minggu',
                              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                        ])),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 20), onPressed: () {
                          _notificationService.cancelNotification(_item.id!);
                          final updatedItem = _item.copyWith(reminderTime: null, reminderRepeat: 'none', updatedAt: DateTime.now().toIso8601String());
                          ref.read(itemsProvider.notifier).updateItem(updatedItem);
                          setState(() => _item = updatedItem);
                        }),
                      ]),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _setReminder,
                      icon: const Icon(Icons.add_alarm),
                      label: Text(_item.reminderTime != null ? 'Ubah Pengingat' : 'Atur Pengingat'),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      // ── Bottom Action Bar ──────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: AppTheme.dividerColor)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.editItem, arguments: _item),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _deleteItem,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Hapus'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageBackground(MergedCategory category, Color catColor) {
    final paths = _item.photoPaths ?? [];
    final allPaths = [...paths];
    if (allPaths.isEmpty && _item.photoPath != null) allPaths.add(_item.photoPath!);
    if (allPaths.isEmpty) return _buildPlaceholder(category, catColor);
    if (allPaths.length <= 1) {
      return Image.file(File(allPaths.first), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(category, catColor));
    }
    return Stack(children: [
      PageView.builder(
        itemCount: allPaths.length,
        itemBuilder: (context, index) => Image.file(File(allPaths[index]), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(category, catColor)),
      ),
      Positioned(bottom: 12, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(allPaths.length, (i) => Container(width: 6, height: 6, margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), shape: BoxShape.circle)))),
      ),
    ]);
  }

  Widget _buildPlaceholder(MergedCategory category, Color catColor) {
    return Container(color: catColor.withValues(alpha: 0.1), child: Center(child: Icon(category.icon, size: 80, color: catColor)));
  }
}

// ── Enhanced Info Row Widget ───────────────────────────────────
class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color catColor;

  const _DetailInfoRow({required this.icon, required this.title, required this.subtitle, required this.catColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: catColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../core/category_helper.dart';
import '../../data/models/item_model.dart';
import '../../providers/item_provider.dart';
import '../../services/notification_service.dart';

enum MapScanTab { scan, map }

/// Screen gabungan Scan Barang + Peta Lokasi ala desain Stitch
/// peta_scan_v4.html — segmented tabs dengan indikator geser.
class MapScanScreen extends ConsumerStatefulWidget {
  final MapScanTab initialTab;

  const MapScanScreen({super.key, this.initialTab = MapScanTab.scan});

  @override
  ConsumerState<MapScanScreen> createState() => _MapScanScreenState();
}

class _MapScanScreenState extends ConsumerState<MapScanScreen>
    with SingleTickerProviderStateMixin {
  late MapScanTab _activeTab;
  late final AnimationController _scanLineController;
  final NotificationService _notificationService = NotificationService();
  MobileScannerController? _scannerController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  // ── Tab switching ─────────────────────────────────────────
  void _switchTab(MapScanTab tab) {
    if (_activeTab == tab) return;
    setState(() {
      _activeTab = tab;
      if (tab == MapScanTab.map) {
        _scannerController?.dispose();
        _scannerController = null;
      } else {
        _scannerController ??= MobileScannerController();
      }
    });
    HapticFeedback.selectionClick();
  }

  MobileScannerController _getScannerController() {
    return _scannerController ??= MobileScannerController();
  }

  // ── Scan handling ─────────────────────────────────────────
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    final raw = barcode.rawValue!;
    final result = await _processScanResult(raw);

    if (!mounted) return;

    if (result != null) {
      final savedId = await ref.read(itemsProvider.notifier).addItem(result);
      if (result.reminderTime != null) {
        await _notificationService
            .scheduleNotification(result.copyWith(id: savedId));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil ditambahkan dari QR!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        Navigator.pushReplacementNamed(
            context, AppRoutes.detailItem,
            arguments: result.copyWith(id: savedId));
      }
    } else {
      if (mounted) _showRawResult(raw);
    }
  }

  Future<Item?> _processScanResult(String raw) async {
    try {
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic> && data.containsKey('name')) {
        return Item(
          name: data['name']?.toString() ?? 'Barang dari QR',
          location: data['location']?.toString() ?? '',
          category: data['category']?.toString() ?? 'lainnya',
          tags: data['tags']?.toString(),
          notes: data['notes']?.toString(),
          latitude: data['latitude'] is num
              ? (data['latitude'] as num).toDouble()
              : null,
          longitude: data['longitude'] is num
              ? (data['longitude'] as num).toDouble()
              : null,
          address: data['address']?.toString(),
          reminderTime: data['reminderTime']?.toString(),
          reminderRepeat: data['reminderRepeat']?.toString() ?? 'none',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
      }
    } catch (_) {}
    return null;
  }

  void _showRawResult(String raw) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hasil Scan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data QR tidak dikenali:',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(raw, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _isProcessing = false);
              },
              child: const Text('Tutup')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, AppRoutes.addItem);
            },
            child: const Text('Buat Barang Baru'),
          ),
        ],
      ),
    );
  }

  Future<void> _showManualInput() async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Input Kode Manual'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tempel teks atau kode di sini',
            prefixIcon: Icon(Icons.keyboard_outlined),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Proses'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (raw == null || raw.trim().isEmpty || !mounted) return;

    setState(() => _isProcessing = true);
    final result = await _processScanResult(raw.trim());
    if (!mounted) return;

    if (result != null) {
      final savedId = await ref.read(itemsProvider.notifier).addItem(result);
      if (result.reminderTime != null) {
        await _notificationService
            .scheduleNotification(result.copyWith(id: savedId));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Barang berhasil ditambahkan dari kode!'),
              backgroundColor: Color(0xFF059669)),
        );
        Navigator.pushReplacementNamed(
            context, AppRoutes.detailItem,
            arguments: result.copyWith(id: savedId));
      }
    } else {
      setState(() => _isProcessing = false);
      if (mounted) _showRawResult(raw.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text('Scan & Peta',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          // ── Segmented tabs ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _SegmentedTabs(
                activeTab: _activeTab,
                onChanged: _switchTab,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: AppTheme.mediumDuration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _activeTab == MapScanTab.scan
                  ? _buildScanView(isDark)
                  : _buildMapView(isDark),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
    );
  }

  // ── Scan view ─────────────────────────────────────────────
  Widget _buildScanView(bool isDark) {
    return Padding(
      key: const ValueKey('scan'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Camera viewfinder — aspect 3/4
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera feed
                  MobileScanner(
                    controller: _getScannerController(),
                    onDetect: _onDetect,
                    fit: BoxFit.cover,
                  ),
                  // Dark overlay + center cutout + guides + scan line
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final side = constraints.maxWidth * 0.7;
                      final left = (constraints.maxWidth - side) / 2;
                      final top = (constraints.maxHeight - side) / 2;
                      return Stack(
                        children: [
                          CustomPaint(
                            size: Size(constraints.maxWidth,
                                constraints.maxHeight),
                            painter: _ViewfinderOverlayPainter(
                              holeRect:
                                  Rect.fromLTWH(left, top, side, side),
                            ),
                          ),
                          // Corner guides
                          Positioned(
                            left: left - 2,
                            top: top - 2,
                            width: 24,
                            height: 24,
                            child: const _CornerGuide(
                                alignment: CornerAlignment.topLeft),
                          ),
                          Positioned(
                            right: left - 2,
                            top: top - 2,
                            width: 24,
                            height: 24,
                            child: const _CornerGuide(
                                alignment: CornerAlignment.topRight),
                          ),
                          Positioned(
                            left: left - 2,
                            bottom: top - 2,
                            width: 24,
                            height: 24,
                            child: const _CornerGuide(
                                alignment: CornerAlignment.bottomLeft),
                          ),
                          Positioned(
                            right: left - 2,
                            bottom: top - 2,
                            width: 24,
                            height: 24,
                            child: const _CornerGuide(
                                alignment: CornerAlignment.bottomRight),
                          ),
                          // Animated scan line
                          AnimatedBuilder(
                            animation: _scanLineController,
                            builder: (context, _) {
                              final t = _scanLineController.value;
                              return Positioned(
                                top: top + t * (side - 2),
                                left: left + 8,
                                right: left + 8,
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor
                                            .withValues(alpha: 0.8),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  // Instruction pill
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191C1E).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Arahkan kamera ke barcode',
                          style: TextStyle(
                              fontSize: 13, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                                color: AppTheme.primaryColor),
                            SizedBox(height: 12),
                            Text('Memproses...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Manual input button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showManualInput,
              icon: const Icon(Icons.keyboard_alt_outlined, size: 20),
              label: const Text('Input Kode Manual',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Map view ──────────────────────────────────────────────
  Widget _buildMapView(bool isDark) {
    final itemsAsync = ref.watch(itemsProvider);
    final mergedAsync = ref.watch(mergedCategoriesProvider);

    return Padding(
      key: const ValueKey('map'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: itemsAsync.when(
        data: (items) {
          final allCategories = mergedAsync.valueOrNull ?? [];
          final itemsWithGps = items
              .where((i) => i.latitude != null && i.longitude != null)
              .toList();

          if (itemsWithGps.isEmpty) {
            return Container(
              height: 420,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined,
                          size: 64,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('Belum ada barang dengan lokasi GPS',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(
                        'Aktifkan "Simpan Lokasi GPS" saat menambahkan barang',
                        style: TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.addItem),
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Barang'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Hitung center average
          double avgLat = itemsWithGps.fold(
                  0.0, (sum, i) => sum + i.latitude!) /
              itemsWithGps.length;
          double avgLng = itemsWithGps.fold(
                  0.0, (sum, i) => sum + i.longitude!) /
              itemsWithGps.length;

          // Hitung zoom level berdasarkan sebaran
          double maxLatDiff = itemsWithGps
              .map((i) => (i.latitude! - avgLat).abs())
              .reduce((a, b) => a > b ? a : b);
          double zoom = maxLatDiff < 0.01 ? 15 : maxLatDiff < 0.1 ? 13 : 11;

          final categories = itemsWithGps
              .map((i) => i.category)
              .toSet()
              .length;

          return ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            child: SizedBox(
              height: 480,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(avgLat, avgLng),
                      initialZoom: zoom,
                      minZoom: 5,
                      maxZoom: 18,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: AppConstants.mapTileUrl,
                        userAgentPackageName: 'com.naruhdimana.naruh_dimana',
                      ),
                      MarkerLayer(
                        markers: itemsWithGps.map((item) {
                          final cat = findCategoryBySlugOrFallback(
                              allCategories, item.category);
                          final catColor = AppTheme.getCategoryColor(
                              item.category, context);
                          return Marker(
                            point: LatLng(item.latitude!, item.longitude!),
                            width: 160,
                            height: 70,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.pushNamed(context,
                                    AppRoutes.detailItem,
                                    arguments: item);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Tooltip card
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    constraints:
                                        const BoxConstraints(maxWidth: 150),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(cat.icon,
                                            size: 12, color: catColor),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white
                                                    : null),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.location_on,
                                      color: catColor, size: 32),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  // Counter badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: AppTheme.softShadow(),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '${itemsWithGps.length} barang',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Info overlay card bawah
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.92)
                            : Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        boxShadow: AppTheme.softShadow(alpha: 0.08),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Peta Lokasi Barang',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${itemsWithGps.length} barang dengan koordinat GPS',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, AppRoutes.addItem),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_rounded,
                                      color: AppTheme.primaryColor, size: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${itemsWithGps.length} penanda',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$categories kategori',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const SizedBox(
          height: 420,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const SizedBox(
          height: 420,
          child: Center(child: Text('Gagal memuat data')),
        ),
      ),
    );
  }
}

// ── Segmented tabs dengan indikator geser ──────────────────
class _SegmentedTabs extends StatelessWidget {
  final MapScanTab activeTab;
  final ValueChanged<MapScanTab> onChanged;

  const _SegmentedTabs({required this.activeTab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor =
        isDark ? const Color(0xFF333B4D) : AppTheme.surfaceContainerHigh;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // Sliding indicator
          AnimatedAlign(
            duration: AppTheme.mediumDuration,
            curve: Curves.easeOutCubic,
            alignment: activeTab == MapScanTab.scan
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 40) / 2,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppTheme.softShadow(alpha: 0.08),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Scan Barang',
                  active: activeTab == MapScanTab.scan,
                  onTap: () => onChanged(MapScanTab.scan),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'Peta Lokasi',
                  active: activeTab == MapScanTab.map,
                  onTap: () => onChanged(MapScanTab.map),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 36,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Corner guides ──────────────────────────────────────────
enum CornerAlignment { topLeft, topRight, bottomLeft, bottomRight }

class _CornerGuide extends StatelessWidget {
  final CornerAlignment alignment;

  const _CornerGuide({required this.alignment});

  @override
  Widget build(BuildContext context) {
    BorderSide top = BorderSide.none;
    BorderSide right = BorderSide.none;
    BorderSide bottom = BorderSide.none;
    BorderSide left = BorderSide.none;

    final side = BorderSide(color: AppTheme.primaryColor, width: 4);

    switch (alignment) {
      case CornerAlignment.topLeft:
        top = side;
        left = side;
      case CornerAlignment.topRight:
        top = side;
        right = side;
      case CornerAlignment.bottomLeft:
        bottom = side;
        left = side;
      case CornerAlignment.bottomRight:
        bottom = side;
        right = side;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

// ── Dark overlay dengan cutout tengah ──────────────────────
class _ViewfinderOverlayPainter extends CustomPainter {
  final Rect holeRect;

  const _ViewfinderOverlayPainter({required this.holeRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF191C1E).withValues(alpha: 0.6);

    // Area gelap di sekitar lubang viewfinder (atas, bawah, kiri, kanan)
    final rects = [
      Rect.fromLTWH(0, 0, size.width, holeRect.top), // atas
      Rect.fromLTWH(0, holeRect.bottom, size.width,
          size.height - holeRect.bottom), // bawah
      Rect.fromLTWH(0, holeRect.top, holeRect.left, holeRect.height), // kiri
      Rect.fromLTWH(holeRect.right, holeRect.top,
          size.width - holeRect.right, holeRect.height), // kanan
    ];
    for (final r in rects) {
      canvas.drawRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(_ViewfinderOverlayPainter oldDelegate) =>
      oldDelegate.holeRect != holeRect;
}

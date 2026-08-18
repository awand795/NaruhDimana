import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/router.dart';
import '../../core/category_helper.dart';
import '../../data/models/item_model.dart';
import '../../providers/item_provider.dart';

/// Map Overview — lihat semua barang dengan GPS dalam satu peta
class MapOverviewScreen extends ConsumerWidget {
  const MapOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    final mergedAsync = ref.watch(mergedCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Barang'),
        centerTitle: false,
      ),
      body: itemsAsync.when(
        data: (items) {
          final allCategories = mergedAsync.valueOrNull ?? [];
          final itemsWithGps = items.where((i) => i.latitude != null && i.longitude != null).toList();

          if (itemsWithGps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Belum ada barang dengan lokasi GPS', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Tambahkan lokasi GPS saat menambahkan barang', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.addItem),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Barang'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Hitung center average
          double avgLat = itemsWithGps.fold(0.0, (sum, i) => sum + i.latitude!) / itemsWithGps.length;
          double avgLng = itemsWithGps.fold(0.0, (sum, i) => sum + i.longitude!) / itemsWithGps.length;

          // Hitung zoom level berdasarkan sebaran
          double maxLatDiff = itemsWithGps.map((i) => (i.latitude! - avgLat).abs()).reduce((a, b) => a > b ? a : b);
          double zoom = maxLatDiff < 0.01 ? 15 : maxLatDiff < 0.1 ? 13 : 11;

          return Stack(
            children: [
              // ── Map ──────────────────────────────────────
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
                      final cat = findCategoryBySlugOrFallback(allCategories, item.category);
                      final catColor = AppTheme.getCategoryColor(item.category, context);
                      return Marker(
                        point: LatLng(item.latitude!, item.longitude!),
                        width: 160,
                        height: 70,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pushNamed(context, AppRoutes.detailItem, arguments: item);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tooltip card
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                constraints: const BoxConstraints(maxWidth: 150),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(cat.icon, size: 12, color: catColor),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white : null),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.location_on, color: catColor, size: 32),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // ── Counter badge ────────────────────────────
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF0D7377)),
                      const SizedBox(width: 4),
                      Text(
                        '${itemsWithGps.length} barang',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Gagal memuat data')),
      ),
    );
  }
}

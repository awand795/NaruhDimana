import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../data/models/item_model.dart';
import '../../services/location_service.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/category_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FullMapScreen extends ConsumerWidget {
  final Item item;

  const FullMapScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationService = LocationService();
    final mergedAsync = ref.watch(mergedCategoriesProvider);
    final allCategories = mergedAsync.valueOrNull ?? [];
    final category =
        findCategoryBySlugOrFallback(allCategories, item.category);
    final catColor =
        AppTheme.getCategoryColor(item.category, context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(item.latitude!, item.longitude!),
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.mapTileUrl,
                userAgentPackageName:
                    'com.naruhdimana.naruh_dimana',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(item.latitude!, item.longitude!),
                    width: 180,
                    height: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tooltip card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          constraints:
                              const BoxConstraints(maxWidth: 170),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: catColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color:
                                      catColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(category.icon,
                                    size: 12, color: catColor),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : AppTheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: catColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow
                        Icon(Icons.location_on,
                            color: catColor, size: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Top bar (safe area) ────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F172A).withValues(alpha: 0.9),
                    const Color(0xFF0F172A).withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded,
                          color: Colors.white, size: 20),
                      tooltip: 'Buka di Maps',
                      onPressed: () {
                        locationService.openInMaps(
                          item.latitude!,
                          item.longitude!,
                          itemName: item.name,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom info card ───────────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.softShadow(alpha: 0.12),
              ),
              child: Row(
                children: [
                  // Photo or icon
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusS),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: item.photoPath != null
                          ? Image.file(
                              File(item.photoPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(category.icon,
                                      color: catColor, size: 24),
                            )
                          : Icon(category.icon,
                              color: catColor, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppTheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13, color: catColor),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                item.address ?? item.location,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (item.createdAt.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm', 'id')
                                .format(
                                    DateTime.parse(item.createdAt)),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Icon(category.icon,
                        size: 16, color: catColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

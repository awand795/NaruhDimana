import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/item_model.dart';
import '../../../providers/item_provider.dart';
import '../../../core/theme.dart';
import '../../../core/category_helper.dart';
import '../../../core/router.dart';

class RecentItems extends ConsumerWidget {
  const RecentItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(recentItemsProvider);
    final mergedAsync = ref.watch(mergedCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Baru Ditambahkan', style: Theme.of(context).textTheme.titleMedium),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pushNamed(context, AppRoutes.search);
                },
                child: Text(
                  'Lihat semua →',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        itemsAsync.when(
          data: (items) {
            final allCategories = mergedAsync.valueOrNull ?? [];
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Belum ada barang. Tambahkan barang pertamamu!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                ),
              );
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final cat = findCategoryBySlugOrFallback(allCategories, items[index].category);
                  return _RecentItemCard(item: items[index], category: cat, index: index);
                },
              ),
            );
          },
          loading: () => _buildShimmerLoading(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SizedBox(
      height: 200,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppTheme.radiusL)),
            );
          },
        ),
      ),
    );
  }
}

class _RecentItemCard extends StatefulWidget {
  final Item item;
  final MergedCategory category;
  final int index;

  const _RecentItemCard({required this.item, required this.category, required this.index});

  @override
  State<_RecentItemCard> createState() => _RecentItemCardState();
}

class _RecentItemCardState extends State<_RecentItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM').format(DateTime.parse(widget.item.createdAt));
    final catColor = AppTheme.getCategoryColor(widget.category.slug, context);
    final catGradient = AppTheme.getCategoryGradient(widget.category.slug);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.pushNamed(context, AppRoutes.detailItem, arguments: widget.item);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AppTheme.microDuration,
        curve: Curves.easeOut,
        child: Card(
          margin: const EdgeInsets.only(right: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusL)),
          child: SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Foto Area ────────────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
                  child: Hero(
                    tag: 'item_photo_${widget.item.id}',
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(gradient: catGradient),
                      child: Stack(
                        children: [
                          // Photo or icon
                          Center(
                            child: widget.item.photoPath != null
                                ? Image.file(
                                    File(widget.item.photoPath!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, __, ___) =>
                                        Icon(widget.category.icon, color: Colors.white, size: 36),
                                  )
                                : Icon(widget.category.icon, color: Colors.white, size: 36),
                          ),
                          // Category pill badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(widget.category.icon, size: 10, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.category.name,
                                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // ── Info ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.location,
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Spacer(),
                          Text(dateStr, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).applyBoxShadow(AppTheme.softShadow()),
      ),
    ).animate().fadeIn(
      duration: AppTheme.shortDuration,
      delay: (widget.index * 80).ms,
      curve: Curves.easeOut,
    ).slideX(begin: 0.1);
  }
}

extension _BoxShadowExt on Card {
  Widget applyBoxShadow(List<BoxShadow> shadows) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: shape is RoundedRectangleBorder
            ? (shape as RoundedRectangleBorder).borderRadius
            : BorderRadius.circular(16),
        boxShadow: shadows,
      ),
      child: this,
    );
  }
}

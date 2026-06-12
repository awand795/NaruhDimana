import 'dart:io';
import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Baru Ditambahkan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Lihat semua',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Belum ada barang. Tambahkan barang pertamamu!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              );
            }
            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final cat = findCategoryBySlugOrFallback(
                    allCategories, items[index].category,
                  );
                  return _RecentItemCard(
                    item: items[index],
                    category: cat,
                    index: index,
                  );
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
      height: 180,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
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

  const _RecentItemCard({
    required this.item,
    required this.category,
    required this.index,
  });

  @override
  State<_RecentItemCard> createState() => _RecentItemCardState();
}

class _RecentItemCardState extends State<_RecentItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM').format(
      DateTime.parse(widget.item.createdAt),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.pushNamed(
          context,
          AppRoutes.detailItem,
          arguments: widget.item,
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Hero(
                  tag: 'item_photo_${widget.item.id}',
                  child: Container(
                    height: 90,
                    width: double.infinity,
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: widget.item.photoPath != null
                        ? Image.file(
                            File(widget.item.photoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(widget.category.icon,
                                  color: AppTheme.primaryColor, size: 32),
                            ),
                          )
                        : Center(
                            child: Icon(widget.category.icon,
                                color: AppTheme.primaryColor, size: 32),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item.location,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(widget.category.icon,
                            size: 12, color: AppTheme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          widget.category.name,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 400.ms,
      delay: (widget.index * 100).ms,
      curve: Curves.easeOut,
    ).slideX(begin: 0.1);
  }
}

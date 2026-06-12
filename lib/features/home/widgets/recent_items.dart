import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/item_model.dart';
import '../../../providers/item_provider.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../../../core/router.dart';

class RecentItems extends ConsumerWidget {
  const RecentItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(recentItemsProvider);

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
                  return _RecentItemCard(item: items[index]);
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _RecentItemCard extends StatelessWidget {
  final Item item;

  const _RecentItemCard({required this.item});

  String get categoryIconName {
    final category = AppConstants.categories.where(
      (c) => c.slug == item.category,
    );
    return category.isNotEmpty ? item.category : 'lainnya';
  }

  @override
  Widget build(BuildContext context) {
    final category = AppConstants.categories.firstWhere(
      (c) => c.slug == item.category,
      orElse: () => AppConstants.categories.last,
    );
    final dateStr = DateFormat('dd MMM').format(
      DateTime.parse(item.createdAt),
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.detailItem,
          arguments: item,
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [              // Photo or category icon placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Hero(
                tag: 'item_photo_${item.id}',
                child: Container(
                  height: 90,
                  width: double.infinity,
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: item.photoPath != null
                      ? Image.file(
                          File(item.photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(category.icon,
                                color: AppTheme.primaryColor, size: 32),
                          ),
                        )
                      : Center(
                          child: Icon(category.icon,
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
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.location,
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
                      Icon(category.icon, size: 12, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/models/item_model.dart';
import '../../../providers/item_provider.dart';
import '../../../core/category_helper.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  final VoidCallback? onOpenFull;

  const QuickAddSheet({super.key, this.onOpenFull});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _nameCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  String _cat = 'lainnya';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _quickSave() async {
    if (_nameCtrl.text.trim().isEmpty || _locCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final now = DateTime.now().toIso8601String();
    await ref.read(itemsProvider.notifier).addItem(Item(
      name: _nameCtrl.text.trim(),
      location: _locCtrl.text.trim(),
      category: _cat,
      reminderRepeat: 'none',
      createdAt: now,
      updatedAt: now,
    ));
    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Simpan barang',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nama barang *',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    onSubmitted: (_) {},
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _locCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Disimpan di *',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category picker
                  Consumer(builder: (ctx, ref, _) {
                    final cats =
                        ref.watch(mergedCategoriesProvider).valueOrNull ?? [];
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cats.map((cat) {
                        final sel = _cat == cat.slug;
                        final color =
                            AppTheme.getCategoryColor(cat.slug, context);
                        return GestureDetector(
                          onTap: () {
                            setState(() => _cat = cat.slug);
                            HapticFeedback.selectionClick();
                          },
                          child: AnimatedContainer(
                            duration: AppTheme.microDuration,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? color.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel
                                    ? color
                                    : AppTheme.textSecondary
                                        .withValues(alpha: 0.25),
                                width: sel ? 1.5 : 0.5,
                              ),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(cat.icon,
                                  size: 14,
                                  color:
                                      sel ? color : AppTheme.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: sel
                                      ? color
                                      : AppTheme.textSecondary,
                                  fontWeight:
                                      sel ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ]),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _quickSave,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Simpan'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  // Link ke full form
                  Center(
                    child: TextButton.icon(
                      onPressed: widget.onOpenFull,
                      icon: const Icon(Icons.tune_rounded, size: 14),
                      label: const Text(
                          'Tambah foto, lokasi GPS, pengingat'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
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

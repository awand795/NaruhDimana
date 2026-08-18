import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme.dart';
import '../../core/router.dart';
import '../../data/models/item_model.dart';
import '../../providers/item_provider.dart';
import '../../services/notification_service.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final NotificationService _notificationService = NotificationService();
  MobileScannerController? _scannerController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  /// Handle detected barcode/QR
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
      // Parsing berhasil jadi Item → simpan
      final savedId = await ref.read(itemsProvider.notifier).addItem(result);
      if (result.reminderTime != null) {
        await _notificationService.scheduleNotification(result.copyWith(id: savedId));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil ditambahkan dari QR!'), backgroundColor: Color(0xFF059669)),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.detailItem, arguments: result.copyWith(id: savedId));
      }
    } else {
      // Data tidak dikenal → tampilkan hasil scan
      if (mounted) _showRawResult(raw);
    }
  }

  /// Proses hasil scan:
  /// JSON → pars ke Item atau null
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
          latitude: data['latitude'] is num ? (data['latitude'] as num).toDouble() : null,
          longitude: data['longitude'] is num ? (data['longitude'] as num).toDouble() : null,
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
            const Text('Data QR tidak dikenali:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
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
          TextButton(onPressed: () { Navigator.pop(ctx); setState(() => _isProcessing = false); }, child: const Text('Tutup')),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan QR / Barcode', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on, color: Colors.white),
            onPressed: () => _scannerController?.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Scanner ──────────────────────────────────────
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),

          // ── Scan area overlay ─────────────────────────────
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0D7377), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D7377).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // ── Instruction ──────────────────────────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white.withValues(alpha: 0.6), size: 32),
                const SizedBox(height: 8),
                Text(
                  'Arahkan kamera ke QR code atau barcode',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // ── Processing indicator ─────────────────────────
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0D7377)),
                    SizedBox(height: 16),
                    Text('Memproses...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

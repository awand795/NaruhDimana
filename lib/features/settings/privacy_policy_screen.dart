import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF0F172A) : AppTheme.surfaceContainerLow;
    final cardColor =
        isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Kebijakan Privasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PolicyCard(
            cardColor: cardColor,
            title: 'Pendahuluan',
            content:
                'Kebijakan privasi ini menjelaskan bagaimana NaruhDimana ("kami", "aplikasi") '
                'mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda saat '
                'menggunakan aplikasi kami.',
          ),
          const SizedBox(height: 12),
          _PolicyCard(
            cardColor: cardColor,
            title: 'Data yang Kami Kumpulkan',
            content:
                'Aplikasi ini menyimpan data yang Anda masukkan secara langsung, termasuk:\n\n'
                '• Nama dan deskripsi barang\n'
                '• Lokasi penyimpanan barang\n'
                '• Foto barang (disimpan di penyimpanan lokal perangkat)\n'
                '• Koordinat GPS lokasi barang\n'
                '• Pengingat dan catatan\n\n'
                'Semua data disimpan secara lokal di perangkat Anda dan tidak dikirimkan '
                'ke server kami.',
          ),
          const SizedBox(height: 12),
          _PolicyCard(
            cardColor: cardColor,
            title: 'Izin Perangkat',
            content:
                'Aplikasi ini memerlukan beberapa izin perangkat untuk berfungsi dengan baik:\n\n'
                '• Kamera: Untuk mengambil foto barang\n'
                '• Penyimpanan: Untuk menyimpan foto barang\n'
                '• Lokasi: Untuk merekam lokasi GPS barang\n'
                '• Notifikasi: Untuk mengirimkan pengingat\n\n'
                'Izin ini hanya digunakan untuk fitur-fitur yang disebutkan dan tidak '
                'untuk tujuan lain.',
          ),
          const SizedBox(height: 12),
          _PolicyCard(
            cardColor: cardColor,
            title: 'Keamanan Data',
            content:
                'Kami mengambil langkah-langkah keamanan yang wajar untuk melindungi data Anda. '
                'Karena semua data disimpan secara lokal di perangkat Anda, keamanan data '
                'juga bergantung pada keamanan perangkat Anda sendiri.',
          ),
          const SizedBox(height: 12),
          _PolicyCard(
            cardColor: cardColor,
            title: 'Perubahan Kebijakan',
            content:
                'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. '
                'Perubahan akan diinformasikan melalui pembaruan aplikasi.',
          ),
          const SizedBox(height: 12),
          _PolicyCard(
            cardColor: cardColor,
            title: 'Kontak',
            content:
                'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, '
                'silakan hubungi pengembang melalui halaman GitHub kami.',
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: const Text(
                'Terakhir diperbarui: Juni 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final Color cardColor;
  final String title;
  final String content;

  const _PolicyCard({
    required this.cardColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.softShadow(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

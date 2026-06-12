import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: 'Pendahuluan',
            content:
                'Kebijakan privasi ini menjelaskan bagaimana NaruhDimana ("kami", "aplikasi") '
                'mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda saat '
                'menggunakan aplikasi kami.',
          ),
          _Section(
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
          _Section(
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
          _Section(
            title: 'Keamanan Data',
            content:
                'Kami mengambil langkah-langkah keamanan yang wajar untuk melindungi data Anda. '
                'Karena semua data disimpan secara lokal di perangkat Anda, keamanan data '
                'juga bergantung pada keamanan perangkat Anda sendiri.',
          ),
          _Section(
            title: 'Perubahan Kebijakan',
            content:
                'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. '
                'Perubahan akan diinformasikan melalui pembaruan aplikasi.',
          ),
          _Section(
            title: 'Kontak',
            content:
                'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, '
                'silakan hubungi pengembang melalui halaman GitHub kami.',
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Terakhir diperbarui: Juni 2026',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

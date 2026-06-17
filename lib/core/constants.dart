import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'NaruhDimana';
  static const String tagline = 'Ingat semua, temukan segalanya';

  // Categories
  static const List<CategoryInfo> categories = [
    CategoryInfo('Dokumen', Icons.description, 'dokumen'),
    CategoryInfo('Kunci', Icons.vpn_key, 'kunci'),
    CategoryInfo('Obat', Icons.medication, 'obat'),
    CategoryInfo('Elektronik', Icons.devices, 'elektronik'),
    CategoryInfo('Pakaian', Icons.checkroom, 'pakaian'),
    CategoryInfo('Perkakas', Icons.build, 'perkakas'),
    CategoryInfo('Lainnya', Icons.category, 'lainnya'),
  ];

  // Reminder repeat options
  static const List<Map<String, String>> reminderRepeatOptions = [
    {'label': 'Tidak', 'value': 'none'},
    {'label': 'Setiap Hari', 'value': 'daily'},
    {'label': 'Setiap Minggu', 'value': 'weekly'},
  ];

  // Search sort options
  static const List<Map<String, String>> sortOptions = [
    {'label': 'Terbaru', 'value': 'newest'},
    {'label': 'A-Z', 'value': 'az'},
    {'label': 'Berkategori', 'value': 'category'},
  ];

  // Map tile URL
  static const String mapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Image compression
  static const int maxImageWidth = 800;
  static const int maxImageQuality = 85;

  // Database
  static const String databaseName = 'naruh_dimana.db';
  static const int databaseVersion = 3;

  // Shared Preferences keys
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefUserProfile = 'user_profile';
}

class CategoryInfo {
  final String name;
  final IconData icon;
  final String slug;

  const CategoryInfo(this.name, this.icon, this.slug);
}

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

  // Category icon lookup (codePoint -> IconData) for tree-shaking compatibility
  static final Map<int, IconData> categoryIconByCodePoint = {
    Icons.folder.codePoint: Icons.folder,
    Icons.book.codePoint: Icons.book,
    Icons.shopping_bag.codePoint: Icons.shopping_bag,
    Icons.sports_esports.codePoint: Icons.sports_esports,
    Icons.music_note.codePoint: Icons.music_note,
    Icons.camera_alt.codePoint: Icons.camera_alt,
    Icons.watch.codePoint: Icons.watch,
    Icons.wallet.codePoint: Icons.wallet,
    Icons.key.codePoint: Icons.key,
    Icons.phone_android.codePoint: Icons.phone_android,
    Icons.laptop.codePoint: Icons.laptop,
    Icons.headphones.codePoint: Icons.headphones,
    Icons.directions_car.codePoint: Icons.directions_car,
    Icons.pedal_bike.codePoint: Icons.pedal_bike,
    Icons.kitchen.codePoint: Icons.kitchen,
    Icons.chair.codePoint: Icons.chair,
    Icons.light.codePoint: Icons.light,
    Icons.pets.codePoint: Icons.pets,
    Icons.spa.codePoint: Icons.spa,
    Icons.card_giftcard.codePoint: Icons.card_giftcard,
    Icons.build.codePoint: Icons.build,
    Icons.brush.codePoint: Icons.brush,
    Icons.school.codePoint: Icons.school,
    Icons.favorite.codePoint: Icons.favorite,
    Icons.star.codePoint: Icons.star,
    Icons.home.codePoint: Icons.home,
    Icons.work.codePoint: Icons.work,
    Icons.flight.codePoint: Icons.flight,
    Icons.beach_access.codePoint: Icons.beach_access,
    Icons.restaurant.codePoint: Icons.restaurant,
  };
}

class CategoryInfo {
  final String name;
  final IconData icon;
  final String slug;

  const CategoryInfo(this.name, this.icon, this.slug);
}

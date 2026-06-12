# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-06-12

### Added
- **Fitur inti**: Tambah, edit, hapus barang dengan foto, GPS, kategori, tag, dan catatan
- **Pencarian**: Full-text search dengan filter (kategori, foto, GPS, pengingat) + sorting
- **Detail barang**: Peta OpenStreetMap (`flutter_map`) + buka di Google Maps
- **Pengingat**: Notifikasi satu kali, harian, dan mingguan dengan deep link
- **Onboarding**: 3-slide pengenalan aplikasi
- **Theme**: Material Design 3, light/dark mode, font Plus Jakarta Sans + Inter
- **State management**: Riverpod dengan SQLite lokal

### Fixed
- **Inisialisasi timezone**: Menambahkan `timezone` dan `flutter_timezone` untuk mencegah crash saat menjadwalkan notifikasi
- **Duplicate notifikasi init**: `FlutterLocalNotificationsPlugin` hanya diinisialisasi sekali melalui `NotificationService`
- **Security**: Keystore dan `key.properties` tidak lagi masuk version control
- **ProGuard/R8**: Menambahkan aturan `-dontwarn` untuk Play Core agar release APK bisa dibuild

### Changed
- **Dependency**: `flutter_local_notifications` diupgrade ke v22 (named-parameter API)
- **Dependency**: `timezone` diupgrade ke v0.11.0
- **Build config**: Menambahkan `isCoreLibraryDesugaringEnabled` dan `desugar_jdk_libs`
- **Signing**: Release APK ditandatangani dengan keystore NaruhDimana
- **Minifikasi**: R8/ProGuard diaktifkan dengan `isShrinkResources` untuk memperkecil APK

### Build
- **Debug APK**: ~152 MB
- **Release APK**: ~54 MB (dengan R8 + shrink resources)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.11+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Min%20SDK-26%20(Android%208.0)-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="License"/>
</p>

<div align="center">
  <h1>📦 NaruhDimana</h1>
  <h3><i>"Ingat semua, temukan segalanya"</i></h3>
  <p><b>Aplikasi pelacak barang berbasis Flutter — bantu kamu ingat di mana menyimpan barang-barangmu.</b></p>
  <br/>
  
  <p>
    <b>NaruhDimana</b> (B. Indonesia: "Di mana saya taruh?") adalah aplikasi Android untuk melacak dan mengingat 
    lokasi penyimpanan barang-barang pribadi. Dilengkapi GPS, foto, kategori, dan pengingat.
  </p>
</div>

<br/>

---

## ✨ Fitur Unggulan

<table>
  <tr>
    <td width="50%">
      <h3>📸 Foto + GPS</h3>
      <p>Abadikan barang dengan kamera atau galeri, simpan koordinat GPS beserta alamat lengkap untuk tahu persis di mana barang disimpan.</p>
    </td>
    <td width="50%">
      <h3>🔍 Pencarian Cerdas</h3>
      <p>Cari barang berdasarkan nama, lokasi, catatan, atau tag. Filter berdasarkan kategori, foto, GPS, dan pengingat.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🗂️ Kategori & Tag</h3>
      <p>7 kategori bawaan (Dokumen, Kunci, Obat, Elektronik, Pakaian, Perkakas, Lainnya) ditambah tag kustom untuk organisasi maksimal.</p>
    </td>
    <td width="50%">
      <h3>🔔 Pengingat Pintar</h3>
      <p>Atur pengingat satu kali, harian, atau mingguan. Notifikasi akan muncul dengan lokasi barang — <i>tap</i> untuk langsung ke detail.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🗺️ Peta Interaktif</h3>
      <p>Lihat preview lokasi di peta (OpenStreetMap) dari halaman detail, atau buka langsung di Google Maps dengan satu sentuhan.</p>
    </td>
    <td width="50%">
      <h3>🌙 Dark Mode</h3>
      <p>Dukungan tema gelap/terang penuh yang mengikuti pengaturan sistem perangkatmu.</p>
    </td>
  </tr>
</table>

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.41+ ([install guide](https://docs.flutter.dev/get-started/install))
- **Android Studio** atau **VS Code** dengan ekstensi Flutter
- Perangkat Android fisik atau emulator (API 26+)

### Instalasi

```bash
# Clone repositori
git clone https://github.com/awand795/NaruhDimana.git

# Masuk ke direktori project
cd NaruhDimana

# Install dependencies
flutter pub get

# Jalankan di perangkat/emulator
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (membutuhkan signing config)
flutter build apk --release
```

---

## 🧱 Tech Stack

| Teknologi | Kegunaan |
|-----------|----------|
| **[Flutter](https://flutter.dev)** | Framework UI cross-platform |
| **[Dart](https://dart.dev)** | Bahasa pemrograman |
| **[Riverpod](https://riverpod.dev)** | Manajemen state |
| **[sqflite](https://pub.dev/packages/sqflite)** | Database lokal SQLite |
| **[flutter_map](https://pub.dev/packages/flutter_map)** + **OpenStreetMap** | Peta tanpa API key |
| **[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)** | Notifikasi pengingat |
| **[geolocator](https://pub.dev/packages/geolocator)** + **[geocoding](https://pub.dev/packages/geocoding)** | GPS & reverse geocoding |
| **[image_picker](https://pub.dev/packages/image_picker)** + **[flutter_image_compress](https://pub.dev/packages/flutter_image_compress)** | Foto & kompresi |
| **[Google Fonts](https://pub.dev/packages/google_fonts)** | Plus Jakarta Sans + Inter |
| **Material Design 3 (Material You)** | Tema & komponen UI |

---

## 📁 Struktur Project

```
lib/
├── main.dart                    # Entry point + routing
├── app.dart                     # App shell dengan bottom nav
├── core/
│   ├── theme.dart               # Tema light/dark
│   ├── constants.dart           # Konstanta global
│   └── router.dart              # Named routes
├── data/
│   ├── database/
│   │   └── database_helper.dart # SQLite helper
│   ├── models/
│   │   └── item_model.dart      # Model data barang
│   └── repositories/
│       └── item_repository.dart  # Repository pattern
├── features/
│   ├── home/                    # Halaman utama
│   ├── add_item/                # Tambah barang
│   ├── search/                  # Pencarian
│   ├── detail/                  # Detail barang + peta
│   └── edit/                    # Edit barang
├── providers/
│   ├── item_provider.dart       # State provider barang
│   └── search_provider.dart     # State provider pencarian
└── services/
    ├── notification_service.dart # Notifikasi terjadwal
    ├── location_service.dart    # GPS & peta
    └── image_service.dart       # Kamera & galeri
```

---

## 📸 Screenshot

> _Coming soon — tangkapan layar akan ditambahkan setelah build pertama._

| Beranda | Tambah Barang | Cari | Detail |
|---------|--------------|------|--------|
| | | | |

---

## 🤝 Kontribusi

Kontribusi selalu diterima dengan senang hati! Berikut cara berkontribusi:

1. **Fork** repositori ini
2. Buat **branch** fitur baru: `git checkout -b fitur-keren`
3. **Commit** perubahan: `git commit -m 'feat: tambah fitur keren'`
4. **Push** ke branch: `git push origin fitur-keren`
5. Buat **Pull Request**

### Pedoman Commit

Kami menggunakan [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` — fitur baru
- `fix:` — perbaikan bug
- `docs:` — perubahan dokumentasi
- `style:` — perubahan format/rapi
- `refactor:` — refaktor kode
- `perf:` — optimasi performa

---

## 📄 Lisensi

Distributed under the **MIT License**. See `LICENSE` for more information.

---

<p align="center">
  Dibuat dengan ❤️ menggunakan Flutter & Dart<br/>
  <b>NaruhDimana</b> — <i>Ingat semua, temukan segalanya</i>
</p>

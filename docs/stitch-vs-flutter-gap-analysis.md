# Gap Analysis: Desain Stitch vs Screen Flutter

Perbandingan 5 desain Google Stitch ("NaruhDimana Redesign Modern UI")
dengan implementasi Flutter saat ini. Prioritas: **P0** = wajib agar
sesuai desain, **P1** = penting, **P2** = nice-to-have.
Status: **✓ Selesai** | **⏳ Belum** | **↔ Adaptasi** (disesuaikan data nyata).

> Update terakhir: Home Screen (Beranda V6) sudah dieksekusi — lihat
> bagian 1. Screen lain masih menunggu eksekusi.

---

## 1. Beranda — `beranda_v6.html` vs `HomeScreen` ✅ DIKERJAKAN

### Desain Stitch
- **Header glass** (blur 16px, putih 80%) ramping: judul + avatar.
- **Greeting hero**: `Halo, Awanda! 👋` (display 32px) + subtitle
  "Ringkasan inventaris Anda hari ini."
- **Hero card**: gradient ocean-indigo→primary, rounded 16px, shadow
  lembut, label "TOTAL ASET" uppercase, badge pill `+12 bulan ini`
  (blur), angka besar 48px, baris "Total nilai estimasi: Rp 1.4M",
  dekorasi gelombang SVG kanan-bawah.
- **Grid 2 kolom** kartu putih: "Kondisi Baik" (ikon check, bg
  secondary-fixed) & "Perlu Perbaikan" (ikon build, bg error-container).
- **Kartu status**: amber "Menunggu Persetujuan" & merah muda "Stok
  Menipis" + chevron.
- **Kategori Cepat**: scroll horizontal, ikon bulat putih 56px dengan
  ikon ocean-indigo, tombol "Lihat Semua".
- **Aktivitas Terbaru**: empty state berilustrasi.
- **Floating dock** pill glass 5 item (Home, Cari, FAB +, Riwayat, Opsi).

### Flutter Saat Ini
- Header glass + greeting display + hero indigo (badge tren bulan ini)
  + grid stat 2 kolom + kartu alert (amber/merah) + kategori cepat
  horizontal + aktivitas terbaru (empty state ilustrasi) + floating
  dock 5 slot.

### Status Perubahan
| # | Perubahan | Prioritas | Status |
|---|---|---|---|
| 1.1 | Greeting → `Halo, {nama}! 👋` display besar + subtitle ringkasan | P0 | ✓ |
| 1.2 | Hero card: label "Total Barang", badge pill tren, subtitle ringkasan, dekorasi gelombang | P0 | ✓ ↔ |
| 1.3 | Stat card 2-kolom di bawah hero (Total Tersimpan / Pengingat Aktif) | P1 | ✓ ↔ |
| 1.4 | Kartu alert amber (Pengingat) & merah (Perlu GPS) | P1 | ✓ ↔ |
| 1.5 | Kategori Cepat → scroll horizontal ikon bulat + "Lihat Semua" | P1 | ✓ |
| 1.6 | Empty state "Aktivitas Terbaru" berilustrasi | P2 | ✓ |
| 1.7 | Floating dock pill glass 5 item + FAB tengah (di `AppShell`) | P0 | ✓ ↔ |
| 1.8 | Header glass | P1 | ✓ (home saja; screen lain menyusul) |

**Catatan:** adaptasi karena desain memakai bahasa gudang — "Total Aset"→
"Total Barang", "Kondisi Baik"→"Total Tersimpan", "Stok Menipis"→"Perlu
GPS". Tab "Riwayat" & "Opsi" dipetakan ke Peta & Profil. Quick actions
dipertahankan agar Scan/Peta tetap bisa diakses.

---

## 2. Cari — `cari_v5.html` vs `SearchScreen`

### Desain Stitch
- **Search bar**: h-14, bg surface-container (abu), ikon search kiri,
  tombol `document_scanner` kanan (buka overlay scanner).
- **Filter pills** horizontal: "Terbaru" (aktif, filled), "Foto"
  (kamera), "Lokasi GPS", "Kategori", "Label" (sell).
- **Riwayat Pencarian**: kartu putih berisi baris ikon history + teks +
  panah rotate-45, tombol "Hapus".
- **Kategori Populer**: grid 2 kolom kartu putih, ikon bulat berwarna
  (key/dokumen/devices/inventory).
- **Rekomendasi**: chips kecil rounded-lg (Dompet Hitam, Obat-obatan,
  Tas Ransel, Buku Catatan, Payung Lipat).
- **Overlay scanner** full-screen gelap: viewfinder sudut + garis scan
  animasi, "Scan Barcode / Teks", tombol flash.

### Flutter Saat Ini
- SliverAppBar "Cari Barang".
- Search field putih ber-shadow + ikon clear.
- Filter chips: Foto, GPS, Pengingat, Kategori + sort via PopupMenu.
- Riwayat pencarian & kategori = chips wrap.
- Hasil pencarian list (card + thumbnail + kategori + waktu).
- Scan = route terpisah (`/scan`).

### Perubahan yang Dibutuhkan
| # | Perubahan | Prioritas | Status |
|---|---|---|---|
| 2.1 | Search bar → bg surface-container + tombol scanner kanan | P0 | ⏳ |
| 2.2 | Filter pill: tambah "Terbaru" (sort) sebagai pill pertama + ikon per filter; ganti PopupMenu sort | P1 | ⏳ |
| 2.3 | Riwayat → kartu putih baris (ikon history + panah) | P1 | ⏳ |
| 2.4 | "Kategori Populer" grid 2 kolom w/ ikon bulat berwarna | P1 | ⏳ |
| 2.5 | Section "Rekomendasi" (chips saran) — baru | P2 | ⏳ |
| 2.6 | Scanner overlay di dalam search (vs route terpisah) | P2 | ⏳ |
| 2.7 | Tampilkan section riwayat/kategori hanya saat belum mengetik | P1 | ⏳ |

---

## 3. Peta & Scan — `peta_scan_v4.html` vs `MapOverviewScreen` + `ScanScreen`

### Desain Stitch (satu screen, segmented tabs)
- **Tab segmented**: "Scan Barang" / "Peta Lokasi" dgn indikator geser.
- **Scan view**: viewfinder aspect 3:4 rounded-xl, overlay gelap
  berlubang, 4 sudut guide ocean-indigo, garis scan animasi, pill
  instruksi bawah ("Arahkan kamera ke barcode"), tombol **"Input Kode
  Manual"** (indigo, rounded-xl, ikon keyboard).
- **Map view**: peta + kartu overlay bawah ("Area Gudang Utama" /
  "Sektor B, Rak 04 - Lvl 2", tombol directions, legend: Jarak 25m /
  Akurasi Tinggi).

### Flutter Saat Ini
- **ScanScreen**: route full-screen hitam, AppBar (close/torch), scanner
  full-bleed, kotak viewfinder 260px border solid + glow, tanpa tombol
  input manual.
- **MapOverviewScreen**: route terpisah, AppBar "Peta Barang", FlutterMap
  + marker tooltip, badge counter, empty state.

### Perubahan yang Dibutuhkan
| # | Perubahan | Prioritas | Status |
|---|---|---|---|
| 3.1 | Gabung Scan + Peta dalam satu screen dgn segmented tabs | P0 | ⏳ |
| 3.2 | Viewfinder → rounded-xl + corner guides + garis scan animasi (bukan kotak solid) | P1 | ⏳ |
| 3.3 | Pill instruksi bawah + tombol "Input Kode Manual" | P1 | ⏳ |
| 3.4 | Map: kartu info overlay bawah + legend (jarak/akurasi) — adaptasi data item | P2 | ⏳ |

---

## 4. Profil — `profil_v5.html` vs `ProfileScreen`

### Desain Stitch
- **Header melengkung** (`rounded-b-[2rem]`) dgn gradient halus: avatar
  96px + badge "Pro Member", nama, email, tombol pill **"Edit Profil"**
  (putih, teks indigo).
- **Strip statistik** menimpa header (`-mt-8`): kartu putih 3 kolom
  (Tersimpan / Lokasi / Pengingat) + divider vertikal.
- **Menu berkelompok**: "Pengaturan Umum" (Akun, Keamanan, Notifikasi)
  & "Dukungan" (Pusat Bantuan, Tentang Aplikasi) — kartu putih rounded
  16px, ikon bulat `primary/10`, chevron.
- **Keluar**: tombol full-width border error-container.
- **Footer**: versi aplikasi.

### Flutter Saat Ini
- AppBar "Profil" + aksi edit.
- Avatar 120px + badge kamera, nama + subtitle.
- Kartu info profil (Umur, Jenis Kelamin, Alamat, Hobi).
- Menu ListTile polos + divider (Edit Profil, Kelola Kategori, Tentang,
  Privasi, Rating).

### Perubahan yang Dibutuhkan
| # | Perubahan | Prioritas | Status |
|---|---|---|---|
| 4.1 | Header rounded-bottom + gradient halus + avatar + badge + tombol "Edit Profil" pill | P0 | ⏳ |
| 4.2 | Strip statistik menimpa header (data nyata: total/GPS/pengingat) | P0 | ⏳ |
| 4.3 | Menu → kartu putih berkelompok + ikon bulat berwarna (bukan ListTile polos) | P1 | ⏳ |
| 4.4 | Tombol "Keluar" + footer versi | P2 | ⏳ |

---

## 5. Tambah Barang — `tambah_barang_v5.html` vs `AddItemScreen`/`QuickAddSheet`

### Desain Stitch (full screen)
- **Header**: back + "Tambah Barang".
- **Foto**: tile aspect 4:3 rounded-xl bg abu, ikon bulat + "Ambil Foto
  Barang" / "atau pilih dari galeri".
- **Input**: label di atas (outline → indigo saat fokus), field putih
  rounded-xl h-12; Lokasi punya tombol history kanan.
- **Kategori**: pill chips (aktif = indigo filled) + tombol bulat "+".
- **Toggle cards**: "Set Pengingat" & "Simpan Lokasi GPS" — kartu putih
  rounded-xl dgn ikon bulat + switch.
- **Simpan Barang**: full-width h-12 rounded-xl indigo + ikon save,
  state loading → "Menyimpan..." → "Tersimpan".

### Flutter Saat Ini
- Flow bertahap (step dots) dgn section header gradient.
- Photo upload tile dashed border.
- Field nama/lokasi/tags/catatan.
- Chip kategori + GPS & reminder sections.
- Tombol simpan.
- Home membuka **QuickAddSheet** (bottom sheet) bukan full screen.

### Perubahan yang Dibutuhkan
| # | Perubahan | Prioritas | Status |
|---|---|---|---|
| 5.1 | Form full-screen (atau pertahankan sheet, sesuaikan visual) | P0 | ⏳ |
| 5.2 | Tile foto aspect 4:3 + ikon bulat + teks "Ambil Foto Barang" | P1 | ⏳ |
| 5.3 | Label-above inputs, white h-12 rounded-xl; tombol history utk lokasi | P1 | ⏳ |
| 5.4 | Kategori pill + tombol "+" tambah kategori | P1 | ⏳ |
| 5.5 | Toggle card "Set Pengingat" & "Simpan Lokasi GPS" (switch) | P1 | ⏳ |
| 5.6 | Tombol simpan: full-width indigo + state loading/saved | P1 | ⏳ |
| 5.7 | Background form → surface-container-low | P2 | ⏳ |

---

## Perubahan Global / App-Level

| # | Perubahan | Prioritas | Status |
|---|---|---|---|
| G.1 | **Floating dock** pill glass (5 item + FAB tengah) menggantikan NavigationBar 3 tab — `app.dart` | P0 | ✓ ↔ |
| G.2 | Header glass (blur + border bawah) konsisten di semua screen | P1 | ⏳ (home saja) |
| G.3 | Empty state berilustrasi (SVG sederhana) | P2 | ✓ (home) |
| G.4 | Variabel `isDark`/`Colors.white` hardcoded → token `AppTheme` | P2 | ⏳ |

---

## Prioritas Eksekusi yang Disarankan (sisa)

1. **Wave 1 (P0 — kerangka):** 2.1 search bar + 3.1 tab Scan/Peta +
   4.1/4.2 header & statistik profil + 5.1 form full-screen.
2. **Wave 2 (P1 — detail):** filter pill sort, riwayat kartu, kategori
   populer, menu profil berkelompok, toggle card tambah barang.
3. **Wave 3 (P2 — polesan):** overlay scanner, rekomendasi, keluar/footer,
   header glass menyeluruh, bersihkan warna hardcoded.

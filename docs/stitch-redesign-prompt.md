# Prompt Google Stitch — Redesign NaruhDimana (Dribbble-style)

> Panduan penggunaan:
> 1. Buka [Google Stitch](https://stitch.withgoogle.com)
> 2. Upload screenshot dari folder `screenshots/` (utamakan `01_home`, `02_search`, `03_profile`, `06_add_item`)
> 3. Paste prompt di bawah ini
> 4. Salin hasil desainnya, lalu paste di chat untuk dieksekusi ke kode Flutter

---

## 📸 Screenshot yang di-upload

| File | Screen |
|---|---|
| `01_home.png` | Beranda (dashboard) |
| `02_search.png` | Cari Barang |
| `03_profile.png` | Profil |
| `04_scan.png` | Scan QR/Barcode (kamera) |
| `05_map.png` | Peta Barang (empty state) |
| `06_add_item.png` | Bottom sheet Tambah Barang |

---

## 📝 Prompt (Bahasa Indonesia)

```text
Redesign UI aplikasi mobile Flutter "NaruhDimana" — personal item tracker berbahasa Indonesia ("Ingat semua, temukan segalanya"). Pengguna menyimpan barang pribadi beserta lokasi penyimpanannya, foto, kategori, koordinat GPS, dan pengingat; lalu bisa mencarinya, melihatnya di peta, atau memindai QR/barcode.

Layar yang di-upload:
1. Beranda: header sapaan + avatar, kartu statistik hero, quick actions (Tambah/Scan/Cari/Peta), grid kategori, item terbaru, FAB tambah.
2. Cari: app bar + field pencarian, filter chip (foto/GPS/pengingat/kategori/urutan), riwayat pencarian, kategori.
3. Profil: identitas pengguna + menu pengaturan.
4. Bottom sheet tambah barang: nama, lokasi, kategori, tombol simpan.
5. Scan QR dan Peta Barang (empty state).

Arah desain: "Dribbble-style" modern premium — bersih, editorial, penuh karakter, bukan template Material default. Inspirasi: Notion, Locket, Linear, desain shot Dribbble 2025-2026 (large typography, generous whitespace, soft depth, glassmorphism halus, gradient accents halus, micro-interactions).

Wajib dipertahankan:
- Identitas warna teal laut (#0D7377) + aksen violet (#7C3AED) + amber (#D97706) — boleh disempurnakan tapi jangan diganti total.
- Semua fitur & konten tetap sama (quick actions, kategori, filter, statistik).
- Bahasa Indonesia di semua label.
- Layout mobile portrait, satu kolom.

Hasilkan: redesign tiap layar dengan visual konsisten, sistem tipografi (heading/body) yang tegas, spacing rhythm yang jelas, dan komponen reusable (card, chip, button, bottom sheet) yang bisa saya terjemahkan ke Flutter.
```

---

## 📝 Prompt (English version)

```text
Redesign the UI of "NaruhDimana", an Indonesian Flutter mobile app — a personal item tracker ("Remember everything, find anything"). Users store personal belongings together with their storage location, photo, category, GPS coordinates, and reminders; then search for them, view them on a map, or scan a QR/barcode.

Uploaded screens:
1. Home: greeting header + avatar, hero stats card, quick actions (Add/Scan/Search/Map), category grid, recent items, add FAB.
2. Search: app bar + search field, filter chips (photo/GPS/reminder/category/sort), search history, categories.
3. Profile: user identity + settings menu.
4. Add-item bottom sheet: name, location, category, save button.
5. QR scan and Items Map (empty state).

Design direction: modern premium "Dribbble-style" — clean, editorial, full of character, not a default Material template. Inspiration: Notion, Locket, Linear, 2025-2026 Dribbble shots (large typography, generous whitespace, soft depth, subtle glassmorphism, subtle gradient accents, micro-interactions).

Must keep:
- Brand identity: ocean teal (#0D7377) + violet accent (#7C3AED) + amber (#D97706) — may be refined, but not replaced entirely.
- All features & content stay the same (quick actions, categories, filters, stats).
- Indonesian language on all labels.
- Mobile portrait, single-column layout.

Deliver: a consistent redesign of every screen, a clear type system (heading/body), a defined spacing rhythm, and reusable components (card, chip, button, bottom sheet) that I can translate into Flutter.
```

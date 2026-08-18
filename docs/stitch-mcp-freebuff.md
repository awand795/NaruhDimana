# Google Stitch MCP di Freebuff

Integrasi Google Stitch (AI UI design) ke Freebuff lewat Model Context Protocol (MCP), sehingga agent Freebuff bisa generate, baca, dan eksekusi desain Stitch langsung dari project ini.

## Prasyarat

- **Node.js 18+** (sudah terpasang: `node --version`)
- **Stitch API Key** — buat di [stitch.withgoogle.com](https://stitch.withgoogle.com) → Profile → Settings → **API Key** → Create key

## Konfigurasi

File `.agents/mcp.json` sudah disiapkan:

```json
{
  "mcpServers": {
    "stitch": {
      "command": "npx",
      "args": ["-y", "stitch-mcp-stdio@1.0.0"],
      "env": {
        "STITCH_API_KEY": "$STITCH_API_KEY"
      }
    }
  }
}
```

Freebuff (Codebuff) membaca `.agents/mcp.json` dari working directory. Token TIDAK disimpan di file — diambil dari environment variable.

> Package `stitch-mcp-stdio` dipilih karena hanya butuh API key (tanpa gcloud), stabil di Windows. Server ini mengekspos semua 12 tool Stitch SDK (`list_projects`, `get_screen`, `generate_screen_from_text`, `edit_screens`, dll).

## Setup (sekali saja)

1. **Buat API key** di [stitch.withgoogle.com](https://stitch.withgoogle.com) → Profile → Settings → API Key
2. **Set environment variable** (Windows):

   ```powershell
   setx STITCH_API_KEY "isi-token-kamu"
   ```
   lalu tutup & buka ulang Freebuff agar env terbaca.
3. **Verifikasi**: di chat Freebuff minta agent menjalankan tool Stitch, misalnya *"List my Stitch projects"*.

## Catatan

- Token berlaku 90 hari — regenerate lewat Settings jika kedaluwarsa.
- Jangan commit token ke git; file `.agents/mcp.json` aman karena hanya memuat referensi env var.
- Kuota generasi Stitch: 350 generasi/bulan (free tier) — pemakaian MCP masuk ke kuota yang sama.

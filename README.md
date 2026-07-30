# Sparepart Management System

Sistem manajemen sparepart berbasis web dengan Golang, PostgreSQL, Tailwind CSS, Alpine.js, dan HTMX.

---

## Tech Stack

| Layer       | Library/Tool                        |
|-------------|-------------------------------------|
| Web Server  | Gin v1.10                           |
| Database    | PostgreSQL via pgx/v5               |
| Session     | gorilla/sessions (cookie-based)     |
| Templates   | html/template (Go standard library) |
| PDF         | chromedp (headless Chrome)          |
| CSS         | Tailwind CSS + daisyUI (npm build)  |
| JS          | Alpine.js + HTMX (npm build)        |

---

## Prasyarat

- Go 1.22+
- PostgreSQL 14+
- Node.js 18+ & npm
- Google Chrome / Chromium (untuk PDF generation via chromedp)

---

## Setup

### 1. Clone & masuk ke folder

```bash
git clone <repo-url>
cd sparepart-mgmt
```

### 2. Buat database PostgreSQL

```sql
CREATE DATABASE sparepart02;
```

Lalu jalankan skema (dari dokumen desain) dan seed data:

```bash
psql -U postgres -d sparepart02 -f schema.sql
psql -U postgres -d sparepart02 -f seed.sql
```

### 3. Build frontend assets (CSS + JS)

```bash
cd assets
npm install
npm run build
cd ..
```

File hasil build akan masuk ke `web/static/css/app.css` dan `web/static/js/app.js`.

### 4. Jalankan server

```bash
# Set environment variables
export DATABASE_URL="postgres://postgres:yourpassword@localhost:5432/sparepart02"
export SESSION_KEY="ganti-dengan-string-random-32-karakter"
export PORT=8080

# Jalankan
go run ./cmd/main.go
```

Buka browser: **http://localhost:8080**

---

## Akun Default (setelah seed)

| Username  | Password    | Role         | Divisi |
|-----------|-------------|--------------|--------|
| admin_sp  | password123 | Admin SP     | -      |
| spv_sp    | password123 | SPV SP       | -      |
| johnson   | password123 | SPV Pemohon  | MTC1   |
| rizky     | password123 | SPV Pemohon  | MTC2   |
| yogi      | password123 | SPV Pemohon  | UTL    |
| user1     | password123 | Pemohon      | MTC1   |
| user2     | password123 | Pemohon      | MTC2   |
| user3     | password123 | Pemohon      | UTL    |

> ⚠️ **Ganti semua password di production!**

---

## Alur Validasi Request

```
Pemohon
  └─ Submit Request
        │
        ▼ Stage 1
    Admin SP  ──(tolak)──► Rejected
        │ (setuju)
        ▼ Stage 2
    SPV Pemohon (sesuai divisi)  ──(tolak)──► Rejected
        │ (setuju)
        ▼ Stage 3
    SPV SP  ──(tolak)──► Rejected
        │ (setuju)
        ▼
    APPROVED → Stok dikurangi otomatis → PDF Struk tersedia
```

---

## Struktur Folder

```
sparepart-mgmt/
├── cmd/main.go              # Entry point, routes
├── internal/
│   ├── config/db.go         # PostgreSQL connection
│   ├── handler/             # HTTP handlers per feature
│   ├── model/models.go      # Go structs
│   ├── repository/          # DB query functions
│   └── service/             # Business logic
├── web/
│   ├── templates/           # HTML templates
│   └── static/              # Compiled CSS/JS (git-ignored)
├── assets/                  # npm source (Tailwind, Alpine, HTMX)
├── seed.sql                 # Sample data
└── README.md
```

---

## Development Workflow

```bash
# Watch CSS changes (terminal 1)
cd assets && npm run watch

# Run Go server with live reload (terminal 2)
# Install air: go install github.com/air-verse/air@latest
air
# or simply:
go run ./cmd/main.go
```

---

## Notes

- **PDF Generation**: Membutuhkan Google Chrome/Chromium ter-install. chromedp akan launch headless Chrome secara otomatis.
- **RFID Simulation**: Di development, ketik kode RFID di input field. Di production, hubungkan ke RFID reader yang mengisi input field.
- **ID Card Simulation**: Ketik nomor ID card di field scan. Di production, hubungkan ke card reader.
- **Session**: Defaultnya cookie-based, tidak perlu Redis/external store untuk setup awal.
Viewed pdf_service.go:135-175
Listed directory E-sparepart%20non%20inventory
Viewed .env:1-15
Viewed main.go:1-274
Viewed .gitignore:1-23
Listed directory db
Listed directory migrations
Searched for "fmt.Println"
Searched for "TEMPORARY"
Ran command: `ls web/static/css/ web/static/js/ 2>&1`
Ran command: `which chromium || which google-chrome || which chromium-browser || ls /Applications/ | grep -i chrome 2>&1; go version`

Berdasarkan analisis kode, berikut daftar hal yang perlu kamu lakukan sebelum deploy:

---

## 🚀 Checklist Sebelum Deploy

### 1. ✅ Siapkan File `.env` untuk Server Production

File `.env` di komputer kamu berisi kredensial lokal. Di server, buat file `.env` baru dengan konfigurasi production:

```env
DATABASE_URL=postgres://USER:PASSWORD@HOST:5432/e_sparepart
SESSION_KEY=<generate random key baru yang kuat>
GIN_MODE=release
PORT=8080
```

> **PENTING:** `SESSION_KEY` di production **wajib berbeda** dari yang di komputer kamu. Generate dengan perintah:
> ```bash
> openssl rand -base64 32
> ```

---

### 2. 🗄️ Jalankan Database Migrations di Server

Pastikan semua tabel sudah ada di database production dengan menjalankan migration SQL yang ada di folder `db/migrations/`:

```bash
psql -d e_sparepart -f db/migrations/create_non_inventory.sql
psql -d e_sparepart -f db/migrations/create_request_orders.sql
psql -d e_sparepart -f db/migrations/add_request_order_items.sql
```

---

### 3. 🌐 Pastikan Chrome/Chromium Terinstall di Server

Aplikasi ini menggunakan **headless Chrome** untuk generate PDF. Tanpa Chrome, semua fitur PDF (struk & BPJT) akan error.

```bash
# Ubuntu/Debian:
sudo apt-get install -y chromium-browser
# atau
sudo apt-get install -y google-chrome-stable
```

---

### 4. 🏗️ Build Binary untuk Server

```bash
go build -o main ./cmd/main.go
```

Kemudian salin binary `main` beserta folder `web/`, `uploads/`, dan file `.env` ke server.

---

### 5. 📁 Pastikan Folder `uploads/` Ada di Server

Folder ini digunakan untuk menyimpan file lampiran yang diupload. Buat jika belum ada:

```bash
mkdir -p uploads
chmod 755 uploads
```

---

### 6. 🔧 Rebuild CSS/JS (Assets)

File `app.css` dan `app.js` **tidak masuk Git** (ada di `.gitignore`). Jika deploy via Git, rebuild dulu di server:

```bash
cd assets
npm install
npm run build
```

---

### 7. ⚠️ Pertimbangkan: Hapus Kode TEMPORARY

Ada satu fitur sementara yang ditandai `TEMPORARY` — yaitu **"Input Manual" karyawan** di halaman pengambilan (sebagai fallback sebelum hardware X606-S aktif). Kamu perlu memutuskan:
- **Tetap dipertahankan** jika hardware belum siap → tidak perlu diubah.
- **Dihapus** jika hardware sudah aktif → hapus handler `SearchEmployee`, route `/api/employee/search`, dan tombol manual di form pengambilan.

---

### 8. ✅ Test Akhir Sebelum Live

Lakukan pengujian alur berikut sebelum memberi akses ke user:

| Alur | Cek |
|------|-----|
| Login semua role | pemohon, spv_pemohon, admin_sp, spv_sp |
| Pengambilan sparepart → validasi 3 tahap → PDF struk | ✓ |
| Permintaan non-inventory → validasi → PDF BPJT | ✓ |
| SPV Pemohon multi-divisi | Cek apakah request dari 2 divisi masuk semua |
| Upload lampiran | Cek file tersimpan di folder `uploads/` |

---

Apakah ada poin tertentu yang ingin kamu mulai sekarang?

I will search the web to see if the official Chainway Keyboard Emulator tool supports direct HTTP POST transmission, which would allow them to use Option 2 without writing custom code.

Searched web: "chainway keyboard emulator http post"

I will create a Python middleware script in the workspace called `rfid_middleware.py`. This script will connect to the Chainway R1's virtual COM port (serial port) over USB, listen for scanned tag events, and send them directly to the backend's `/api/rfid/scan` endpoint using the active Session ID. This fulfills Option 2.

I will create a Python middleware script in your project directory named `rfid_middleware.py`. This script will act as a bridge between the Chainway R1 scanner and your web server, using Option 2 (sending data directly to `/api/rfid/scan`). It will support both:
1. **Serial (Virtual COM Port) Mode**: Reading directly from the USB serial interface.
2. **Keyboard Wedge Interceptor Mode**: Capturing input globally (without needing to focus the browser input field) and posting it.

Let's write this script now.

Edited rfid_middleware.py

Tentu saja, Anda bisa menggunakan **Opsi ke-2 (API / Middleware)**. Bahkan, backend Go dan frontend Alpine.js Anda sudah siap untuk menerima scan dari luar melalui API `POST /api/rfid/scan` dan meneruskannya ke browser menggunakan Server-Sent Events (SSE).

Saya telah membuat file script Python middleware bernama **`rfid_middleware.py`** langsung di dalam folder project Anda untuk menghubungkan Chainway R1 ke sistem Anda menggunakan opsi ini.

### Cara Menjalankan & Menghubungkan:

#### 1. Persiapan Dependencies di Komputer/PC Scanner
Buka terminal/command prompt di komputer yang terhubung dengan Chainway R1, lalu install library Python yang dibutuhkan:
```bash
pip install requests pyserial pynput
```

#### 2. Dapatkan Session ID dari Halaman Web
1. Jalankan server Golang Anda seperti biasa.
2. Buka browser pada form pengambilan sparepart.
3. Di bagian **Tambah Sparepart**, pilih tab **Scan RFID**. Anda akan melihat teks hijau bertuliskan:
   `Chainway R1 siap — arahkan ke sparepart dan scan. Session: rfid-xxxxxx`
4. Salin kode session ID lengkap tersebut (misalnya `rfid-1718000000`).

#### 3. Jalankan Script Middleware
Di terminal Anda, jalankan file python yang baru dibuat:
```bash
python rfid_middleware.py
```

Script akan meminta input berikut:
* **Server URL**: Tekan `Enter` untuk default (`http://localhost:8080`), atau masukkan IP server jika dideploy di jaringan lain.
* **Session ID**: Masukkan Session ID yang Anda salin dari browser tadi.
* **Connection Mode**: 
  * **Pilih `1` (Keyboard Interceptor)** jika Chainway R1 Anda diset dalam mode Keyboard Wedge (default). Dengan mode ini, script akan memantau ketikan secara global di background. **User tidak perlu klik kotak input di browser**. Ketika R1 men-scan tag, script akan menangkap input secara otomatis dan mengirimkannya ke backend.
  * **Pilih `2` (Serial Port)** jika Chainway R1 diset dalam mode Virtual COM Port. Script akan membaca data stream mentah langsung dari USB Serial port.

Ketika scan berhasil dilakukan, script Python akan melakukan HTTP POST ke server, dan item sparepart akan langsung muncul secara *realtime* di daftar item pada halaman browser Anda.
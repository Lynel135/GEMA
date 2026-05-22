# Spesifikasi Proyek Backend & Admin Panel GEMA (Gerbang Masinis Virtual)

*Dokumen ini adalah rancangan arsitektur dan spesifikasi kebutuhan untuk agen AI yang akan membangun proyek ke-2 (Backend & Admin Panel berbasis Next.js).*

---

## 1. Deskripsi Proyek
Proyek ini adalah sistem backend dan dashboard admin berbasis web untuk aplikasi mobile **GEMA (Gerbang Masinis Virtual)**. Sistem ini akan menerima data lokasi *real-time* dari aplikasi mobile (masinis), memonitor pergerakan mereka secara *live* melalui peta di dashboard admin, dan mengelola data master (seperti titik perlintasan kereta api dan data masinis).

## 2. Tech Stack yang Digunakan
- **Framework:** Next.js (Disarankan menggunakan *App Router* versi terbaru).
- **Styling:** Tailwind CSS + Shadcn UI (untuk komponen UI admin yang modern dan rapi).
- **Database:** PostgreSQL (bisa menggunakan layanan seperti Supabase, Vercel Postgres, atau Neon).
- **ORM:** Prisma ORM atau Drizzle ORM.
- **Authentication:** NextAuth.js (untuk login khusus Admin).
- **Maps (Admin Dashboard):** Leaflet (via `react-leaflet`) atau Google Maps API.

## 3. Database Schema (Draft)

Sistem akan membutuhkan setidaknya 3 tabel utama:

1. **Admins (Admin Panel Users)**
   - `id` (UUID)
   - `username` (String)
   - `password_hash` (String)

2. **Masinis (Mobile App Users/Drivers)**
   - `id` (UUID)
   - `nama` (String)
   - `nomor_identitas` (String)
   - `status_aktif` (Boolean)
   - `last_latitude` (Float) - *Update real-time*
   - `last_longitude` (Float) - *Update real-time*
   - `last_updated` (DateTime)

3. **Perlintasan (Train Crossings)**
   - `id` (UUID)
   - `nama_perlintasan` (String)
   - `latitude` (Float)
   - `longitude` (Float)
   - `radius_bahaya_meter` (Integer) - *Default: 200m*

## 4. HTTP API Endpoints (Untuk Aplikasi Mobile)

Aplikasi mobile (Flutter) akan menembak endpoint HTTP berikut. **Catatan:** Endpoint ini tidak memerlukan login session yang kompleks karena aplikasi mobile berjalan di background, cukup menggunakan API Key statis atau JWT sederhana sebagai *Bearer Token* di Header untuk keamanan dasar.

### A. POST `/api/v1/location/update`
- **Fungsi:** Menerima koordinat GPS real-time dari aplikasi Flutter.
- **Headers:** `Authorization: Bearer <API_KEY>`
- **Body (JSON):**
  ```json
  {
    "masinis_id": "uuid-masinis",
    "latitude": -6.200000,
    "longitude": 106.816666,
    "timestamp": "2026-05-19T10:00:00Z"
  }
  ```
- **Response (200 OK):**
  ```json
  { "status": "success", "message": "Location updated" }
  ```

### B. GET `/api/v1/perlintasan`
- **Fungsi:** Mengirimkan daftar koordinat perlintasan kereta api ke aplikasi mobile agar aplikasi bisa melakukan kalkulasi jarak (Geofencing) secara lokal.
- **Headers:** `Authorization: Bearer <API_KEY>`
- **Response (200 OK):**
  ```json
  {
    "status": "success",
    "data": [
      {
        "id": "uuid-1",
        "nama": "Perlintasan A",
        "latitude": -6.205,
        "longitude": 106.820,
        "radius_bahaya_meter": 200
      }
    ]
  }
  ```

## 5. Fitur Admin Panel (Web Interface)

Halaman-halaman yang harus dibuat di Next.js:

1. **Halaman Login (`/login`)**
   - Form sederhana (Username & Password) khusus untuk Admin.

2. **Live Dashboard (`/dashboard`)**
   - Menampilkan peta besar (menggunakan Leaflet/Google Maps).
   - Menampilkan *marker* (titik lokasi) semua perlintasan kereta api.
   - Menampilkan *marker* (ikon kereta/masinis) yang bergerak secara *real-time* atau ter-update secara berkala (polling setiap 5 detik atau menggunakan WebSockets/Server-Sent Events) berdasarkan tabel Masinis.

3. **Manajemen Masinis (`/dashboard/masinis`)**
   - Tabel CRUD (Create, Read, Update, Delete) untuk menambahkan data masinis baru atau menonaktifkan masinis.

4. **Manajemen Perlintasan (`/dashboard/perlintasan`)**
   - Tabel CRUD untuk titik perlintasan. Admin bisa menambahkan perlintasan baru dengan memasukkan nama, latitude, dan longitude.

---

**Instruksi untuk AI Agent Selanjutnya:**
*Tolong buatkan proyek Next.js baru dengan spesifikasi di atas. Mulailah dari setup database schema, kemudian buatkan API Endpoints, dan terakhir bangun UI Admin Panel.*

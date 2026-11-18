# Dokumen Kebutuhan Produk (PRD): SIAGA-HADIR (Edisi Firebase & BNPB)

## 1. Ringkasan Produk
**SIAGA-HADIR** (Sistem Informasi Absensi Geolocation dan Aktivitas) adalah aplikasi presensi mobile dan pelaporan kesiapsiagaan personel BNPB (Badan Nasional Penanggulangan Bencana). Aplikasi ini mendukung operasional staf kantor (WFO), staf bekerja dari rumah (WFH), dan Tim Reaksi Cepat (TRC) penanggulangan bencana di zona terdampak.

## 2. Pengguna Sasaran dan Infrastruktur
* **Pengguna:** Pegawai WFO, Pegawai WFH, Personel Lapangan/TRC, dan Administrator Kepegawaian.
* **Infrastruktur Cloud:** Firebase Authentication, Cloud Firestore, Firebase Storage, dan Cloud Messaging.
* **Penyimpanan Lokal:** Hive Local Storage dengan pola Offline-First untuk keandalan pencatatan di daerah blank-spot bencana.

## 3. Kebutuhan Fungsional Utama

### 3.1 Otentikasi dan Keamanan Perangkat
* **Login NIP Pegawai:** Otentikasi aman terintegrasi dengan Firebase Authentication.
* **Pengikatan ID Perangkat (Device Binding):** Akun pegawai dikunci pada satu ID perangkat keras unik menggunakan paket `device_info_plus`. Akses dari gawai yang tidak terdaftar ditolak secara otomatis.
* **Pendeteksian Lokasi Palsu (Mock Location):** Pemeriksaan integritas GPS untuk mencegah penggunaan aplikasi Fake GPS atau spoofing lokasi.

### 3.2 Tiga Mode Presensi Operasional
* **Mode WFO (Kantor BNPB Pusat):**
  * Validasi geofencing menggunakan rumus matematis Haversine.
  * Membandingkan koordinat GPS perangkat terhadap titik koordinat Gedung Graha BNPB Jakarta Timur (-6.2575, 106.8702) dengan radius maksimum 100 meter.
* **Mode WFH (Rumah Terdaftar):**
  * Validasi koordinat GPS terhadap koordinat domisili pegawai yang terdaftar di basis data.
  * Dilengkapi pengisian catatan kegiatan harian.
* **Mode Penugasan Lapangan / Tanggap Darurat Bencana:**
  * Penonaktifan batasan radius kantor pusat.
  * Wajib mencantumkan nama operasi bencana atau lokasi posko lapangan.
  * Wajib melampirkan foto Surat Perintah Tugas (SPT) yang diunggah ke Firebase Storage.
  * Pencatatan koordinat GPS riil di lokasi bencana.

### 3.3 Kamera Swafoto dan Antrean Offline
* **Swafoto Langsung dan Watermark Koordinat:** Pengambilan foto wajah langsung melalui kamera perangkat dengan penambahan informasi koordinat lintang, bujur, dan stempel waktu.
* **Antrean Offline-First (Resiliensi Zona Bencana):**
  * Ketika koneksi internet terputus, data presensi disimpan ke dalam antrean lokal Hive dengan status `pending_sync`.
  * Saat perangkat kembali mendeteksi sinyal internet via `connectivity_plus`, sistem secara otomatis mengunggah data yang tertunda ke Cloud Firestore dan Firebase Storage.
  * Terdapat panel status sinkronisasi yang memungkinkan personel memantau dan memicu sinkronisasi manual.

## 4. Standar Kualitas Antarmuka (Antislop Compliance)
* **Keterbacaan dan Kontras:** Seluruh teks memenuhi rasio kontras WCAG AA minimal 4.5:1.
* **Ukuran Target Sentuh:** Semua tombol dan bidang masukan berukuran minimal 44 x 44 piksel agar mudah dioperasikan dengan satu tangan di lapangan.
* **Kelengkapan Status UI:** Setiap modul data wajib menyediakan status Lengkap, Memuat (Loading), Kosong (Empty), Galat (Error), dan Tertunda (Offline).
* **Bahasa dan Teks:** Menggunakan bahasa kedinasan formal Indonesia, bebas dari kata dengung generik (buzzwords) dan bebas dari karakter em dash.

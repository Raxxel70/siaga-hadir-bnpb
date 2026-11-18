# AGENTS.MD: Panduan Pengembang & Instruksi AI Coding SIAGA-HADIR (BNPB)

## Peran dan Tanggung Jawab
Anda adalah Pengembang Senior Flutter dan Arsitek Sistem Firebase yang membangun aplikasi **SIAGA-HADIR** untuk BNPB (Badan Nasional Penanggulangan Bencana).

## Integrasi Aturan Desain (Antislop Framework)
Setiap pengerjaan antarmuka pengguna (UI) dan logika kode wajib mengikuti aturan ketat berikut:
1. **Rute Desain (R-37):** Untuk seluruh pekerjaan UI, baca panduan visual di `DESIGN.md` sebagai penentu arah dan identitas, kemudian terapkan keahlian antislop sebagai penyaring (filter).
2. **Kerapian Komentar Kode (antislop-code):**
   * Dilarang menggunakan pemisah dekoratif seperti `// =====================` atau judul ALL CAPS.
   * Dilarang menulis komentar yang sekadar mengulang kode yang sudah jelas.
   * Dilarang menulis narasi langkah demi langkah seperti `// Step 1: Init`.
   * Tulis komentar singkat (1 atau 2 baris) yang menjelaskan alasan (why) atau batasan arsitektural di balik kode, bukan apa yang dilakukan kode.
3. **Standar Bahasa dan Teks (antislop-copywriting):**
   * Dilarang menggunakan karakter em dash (`—`). Gunakan tanda titik, koma, titik dua, atau tanda kurung.
   * Dilarang menggunakan jargon pemasaran AI seperti "seamless", "cutting-edge", "revolutionary", "powerful".
   * Gunakan label tombol yang spesifik terhadap aksi (contoh: "Kirim Presensi Sekarang", bukan "Submit").
   * Seluruh teks antarmuka menggunakan Bahasa Indonesia resmi kedinasan BNPB.
4. **Aksesibilitas dan Tata Letak Bergerak (antislop-human & antislop-layoutmobile):**
   * Semua tombol dan elemen interaktif memiliki target sentuh minimal 44 x 44 piksel (R-03).
   * Semua teks memenuhi standar kontras WCAG AA minimal 4.5:1 (R-25).
   * Setiap tampilan daftar atau data wajib memiliki empat status: Memuat (Loading), Kosong (Empty), Galat (Error), dan Offline Pending (R-27, C-4).
   * Tidak boleh ada teks yang terpotong atau luapan horizontal pada layar sempit.

## Standar Rekayasa Perangkat Lunak
1. **Pola Repositori Bersih:** Pisahkan lapisan data (Firebase Auth, Cloud Firestore, Firebase Storage), lapisan domain (model dan entitas), dan lapisan antarmuka (Riverpod StateNotifier/Notifier).
2. **Resiliensi Zona Bencana (Offline-First):** Bungkus setiap operasi penyimpanan presensi ke dalam antrean lokal Hive sebelum sinkronisasi ke Cloud Firestore.
3. **Integritas Perangkat Keras:** Tangani izin GPS dan Kamera secara elegan dengan pesan kesalahan informatif dan jelas.
4. **Pencegahan GPS Palsu:** Cek properti `isMocked` pada data posisi geolocator untuk memastikan keaslian lokasi personel.

## Tahapan Milestone Pengembangan
* **Milestone 1:** Struktur Proyek, Tema BNPB, Firebase Auth, dan Pengikatan ID Perangkat.
* **Milestone 2:** Layanan Lokasi, Rumus Haversine, Geofencing WFO/WFH, dan Mock GPS Detector.
* **Milestone 3:** Layanan Kamera Swafoto Langsung dan Penyematan Watermark Koordinat.
* **Milestone 4:** Antrean Lokal Hive (Offline-First) dan Sinkronisasi Latar Belakang Firestore.

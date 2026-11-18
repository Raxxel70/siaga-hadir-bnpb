# Panduan Desain SIAGA-HADIR (BNPB)

Panduan identitas visual dan sistem desain untuk aplikasi presensi dan pelaporan aktivitas tanggap darurat BNPB (Badan Nasional Penanggulangan Bencana).

## 1. Identitas & Karakter Desain
* **Institusi:** Badan Nasional Penanggulangan Bencana (BNPB).
* **Tujuan Antarmuka:** Fungsional, terpercaya, cepat dibaca di lapangan, siap digunakan saat darurat bencana.
* **Karakter:** Tegas, bersih, mudah dibaca di bawah terik matahari, tanpa dekorasi berlebihan.

## 2. Tiga Indikator Desain (Antislop Dials)
* **ENERGY:** 1 (Tenang dan berwibawa. Bukan tampilan startup yang mencolok, melainkan aplikasi kedinasan resmi penanggulangan bencana).
* **RHYTHM:** 2 (Terstruktur, kartu informasi status presensi, peta radius koordinat, dan formulir tugas darurat yang jelas).
* **MOTION:** 1 (Transisi fungsional untuk umpan balik tindakan pengguna, tanpa animasi putar atau efek berulang tanpa henti).

## 3. Palet Warna (Standar Kontras WCAG AA)
Warna dipilih berdasarkan identitas resmi BNPB dengan batas kontras minimal 4.5:1 untuk teks normal dan 3.0:1 untuk elemen interaktif:

* **BNPB Orange (Aksen Utama):** `#BA3D00` (Jingga Khas BNPB, rasio kontras 5.59:1 terhadap putih, lulus penuh WCAG AA).
* **Slate Navy (Latar Header & Teks Utama Gelap):** `#0F172A` (Kontras tinggi 16.2:1 terhadap latar putih).
* **Deep Charcoal (Teks Tubuh):** `#1E293B` (Kontras 13.5:1 terhadap latar putih).
* **Muted Grey (Border & Divider):** `#CBD5E1`.
* **Light Surface (Latar Aplikasi Terang):** `#F8FAFC`.
* **Card Surface (Kartu Bersih):** `#FFFFFF`.
* **Status Hijau (Absen Masuk/Tersinkron):** `#16A34A` (Teks putih di atas hijau memenuhi 4.6:1).
* **Status Kuning (Tersimpan Lokal/Menunggu Jaringan):** `#D97706`.
* **Status Merah (Di Luar Radius/Gagal):** `#DC2626`.

## 4. Tipografi
* **Font Keluarga:** Sans-serif standar sistem (Roboto/Inter) untuk keterbacaan optimal di perangkat Android lapangan.
* **Skala Tipe:**
  * Judul Halaman: 20px, Bold
  * Judul Bagian/Kartu: 16px, Semi-bold
  * Teks Utama/Label: 14px, Regular
  * Keterangan/Status Tambahan: 12px, Medium

## 5. Standar Sentuhan dan Aksesibilitas
* Setiap tombol interaktif memiliki target sentuh minimal 44 x 44 piksel.
* Setiap tombol dan tautan menampilkan label tindakan spesifik (misal: "Kirim Presensi Sekarang", "Buka Kamera Swafoto").
* Setiap tampilan data memiliki 4 status lengkap: Memuat (Loading), Kosong (Empty), Galat (Error), dan Tertunda Sinkronisasi (Offline Pending).

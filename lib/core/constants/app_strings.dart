class AppStrings {
  static const String appName = 'SIAGA-HADIR BNPB';
  static const String appTagline = 'Presensi dan Kesiapsiagaan Bencana';

  // Otentikasi
  static const String loginTitle = 'Masuk Akun Personel';
  static const String loginSubtitle = 'Gunakan NIP dan kata sandi terdaftar';
  static const String nipLabel = 'Nomor Induk Pegawai (NIP)';
  static const String nipHint = 'Contoh: 198501152010121001';
  static const String passwordLabel = 'Kata Sandi';
  static const String passwordHint = 'Masukkan kata sandi';
  static const String loginAction = 'Masuk ke Sistem';
  static const String deviceBoundNotice = 'Perangkat ini terdaftar untuk akun NIP Anda.';
  static const String deviceMismatchError = 'Akses ditolak: ID perangkat tidak sesuai dengan data terdaftar.';

  // Mode Presensi
  static const String modeWfo = 'WFO (Kantor Pusat BNPB)';
  static const String modeWfh = 'WFH (Tempat Tinggal Terdaftar)';
  static const String modeField = 'Tugas Lapangan / TRC Bencana';

  // Geofencing & Lokasi
  static const String locationActive = 'GPS Aktif dan Akurat';
  static const String locationChecking = 'Memverifikasi koordinat lokasi...';
  static const String mockLocationDetected = 'Peringatan: Terdeteksi penggunaan Fake GPS. Presensi dibatalkan.';
  static const String withinRadiusNotice = 'Anda berada di dalam radius presensi resmi.';
  static const String outsideRadiusWarning = 'Di luar radius presensi resmi.';

  // Aksi Presensi
  static const String takeSelfie = 'Ambil Foto Swafoto Lapangan';
  static const String recordAttendance = 'Kirim Presensi Sekarang';
  static const String dailyNotesLabel = 'Laporan Aktivitas Harian';
  static const String dailyNotesHint = 'Jelaskan ringkasan pekerjaan Anda hari ini';
  static const String disasterNameLabel = 'Nama Operasi Penanggulangan Bencana';
  static const String disasterNameHint = 'Contoh: Tanggap Darurat Erupsi Gunung Marapi';
  static const String sptUploadLabel = 'Lampiran Surat Perintah Tugas (SPT)';

  // Sinkronisasi Offline-First
  static const String offlineModeActive = 'Koneksi Terputus: Presensi tersimpan di memori perangkat.';
  static const String syncPendingTitle = 'Menunggu Sinkronisasi';
  static const String syncNowAction = 'Sinkronkan Sekarang';
  static const String syncSuccessMessage = 'Data presensi lokal berhasil disinkronkan ke server.';

  // Status Tampilan (R-27)
  static const String emptyHistory = 'Belum ada riwayat presensi tercatat.';
  static const String errorGeneral = 'Terjadi kendala teknis saat memproses data.';
  static const String retryAction = 'Coba Lagi';
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'core/database/hive_queue_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Penangkal Layar Hitam (Menampilkan pesan informatif jika terjadi galat runtime)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 64, color: Color(0xFFBA3D00)),
                  const SizedBox(height: 16),
                  const Text(
                    'SIAGA-HADIR BNPB',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Memuat sistem presensi dan kesiapsiagaan...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  // Inisialisasi penyimpanan lokal Hive untuk resiliensi zona bencana.
  try {
    await Hive.initFlutter();
    final queueService = HiveQueueService();
    await queueService.init();
  } catch (e) {
    debugPrint('Hive init: $e');
  }

  // Inisialisasi Firebase dengan konfigurasi resmi siaga-hadir-bnpb.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init: $e');
  }

  runApp(
    const ProviderScope(
      child: SiagaHadirApp(),
    ),
  );
}

class SiagaHadirApp extends StatelessWidget {
  const SiagaHadirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Default ke mode terang resmi BNPB agar teks selalu kontras tinggi di semua jenis layar ponsel
      themeMode: ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}

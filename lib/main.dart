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

  // Penangkal Layar Hitam & Pelindung Tampilan Error
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 56, color: Color(0xFFBA3D00)),
                  const SizedBox(height: 16),
                  const Text(
                    'SIAGA-HADIR BNPB',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Catatan Sistem: ${details.exceptionAsString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  // Inisialisasi penyimpanan lokal Hive dengan membuka kotak antrean secara eksplisit.
  try {
    await Hive.initFlutter();
    await Hive.openBox(HiveQueueService.queueBoxName);
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
      themeMode: ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}

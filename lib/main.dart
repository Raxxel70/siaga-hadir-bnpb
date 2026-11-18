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

  // Inisialisasi penyimpanan lokal Hive untuk resiliensi zona bencana.
  await Hive.initFlutter();
  final queueService = HiveQueueService();
  await queueService.init();

  // Inisialisasi Firebase dengan konfigurasi resmi siaga-hadir-bnpb.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Berjalan dalam mode mandiri/offline saat kredensial lokal belum terhubung.
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
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}

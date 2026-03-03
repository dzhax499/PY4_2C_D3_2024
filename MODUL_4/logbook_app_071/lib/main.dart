import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_071/features/logbook/services/mongo_service.dart';
import 'package:logbook_app_071/helpers/log_helper.dart';
import 'package:logbook_app_071/features/onboarding/onboarding_view.dart';

/// Main entry point - Modul 4 (Langkah 3: Inisialisasi Handshake)
///
/// Urutan inisialisasi sebelum runApp():
/// 1. WidgetsFlutterBinding.ensureInitialized() — wajib untuk async sebelum runApp
/// 2. dotenv.load()                              — muat MONGODB_URI dari .env
/// 3. MongoService().connect()                   — jabat tangan dengan Atlas
Future<void> main() async {
  // Wajib untuk operasi asinkron sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load ENV — baca MONGODB_URI & LOG_LEVEL
  await dotenv.load(fileName: '.env');

  await LogHelper.writeLog(
    'App dimulai. File .env berhasil dimuat.',
    source: 'main.dart',
    level: 2,
  );

  // 2. Jabat tangan (handshake) dengan MongoDB Atlas
  await MongoService().connect();

  await LogHelper.writeLog(
    'Infrastruktur siap. Menjalankan Flutter UI...',
    source: 'main.dart',
    level: 2,
  );

  // 3. Jalankan aplikasi Flutter
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const OnboardingView(),
    );
  }
}

import 'dart:io';
import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// LogHelper (Task 4 - Professional Audit Logging)
/// - Menulis log ke terminal (berwarna) DAN ke file fisik /logs/dd-MM-yyyy.log
/// - Level dikontrol dari .env: 1=ERROR, 2=INFO, 3=VERBOSE
/// - Source filtering via LOG_MUTE di .env
class LogHelper {
  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    // ── 1. Filter via ENV ─────────────────────────────────────────────────
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';

    if (level > configLevel) return;
    if (muteList.split(',').map((e) => e.trim()).contains(source)) return;

    try {
      final now = DateTime.now();
      final String timestamp = DateFormat('HH:mm:ss').format(now);
      final String label    = _getLabel(level);
      final String color    = _getColor(level);

      // ── 2. Output ke VS Code Debug Console ───────────────────────────────
      dev.log(message, name: source, time: now, level: level * 100);

      // ── 3. Output Berwarna ke Terminal ────────────────────────────────────
      // ignore: avoid_print
      print('$color[$timestamp][$label][$source] -> $message\x1B[0m');

      // ── 4. Tulis ke File Fisik /logs/dd-MM-yyyy.log (Task 4) ─────────────
      await _writeToFile(now, timestamp, label, source, message);

    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  /// Menulis log ke file fisik di folder /logs/
  /// Format nama file: 03-03-2025.log
  static Future<void> _writeToFile(
    DateTime now,
    String timestamp,
    String label,
    String source,
    String message,
  ) async {
    try {
      // Tentukan direktori logs (relatif terhadap CWD saat flutter run / test)
      final String dateStr  = DateFormat('dd-MM-yyyy').format(now);
      final String logsDir  = '${Directory.current.path}/logs';
      final String filePath = '$logsDir/$dateStr.log';

      // Buat folder /logs jika belum ada
      final directory = Directory(logsDir);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      // Format log entry: [03-03-2025 14:30:05] [INFO] [source] -> message
      final String fullTimestamp = DateFormat('dd-MM-yyyy HH:mm:ss').format(now);
      final String logEntry = '[$fullTimestamp] [$label] [$source] -> $message\n';

      // Append ke file (tidak menimpa log sebelumnya)
      await File(filePath).writeAsString(
        logEntry,
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      // Jangan crash app hanya karena file log gagal ditulis
      dev.log("File logging failed: $e", name: "LOG_HELPER", level: 1000);
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:  return "ERROR";
      case 2:  return "INFO";
      case 3:  return "VERBOSE";
      default: return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:  return '\x1B[31m'; // Merah
      case 2:  return '\x1B[32m'; // Hijau
      case 3:  return '\x1B[34m'; // Biru
      default: return '\x1B[0m';
    }
  }
}

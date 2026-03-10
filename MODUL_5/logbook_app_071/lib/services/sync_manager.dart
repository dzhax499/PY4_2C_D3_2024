import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logbook_app_071/features/logbook/models/log_model.dart';
import 'package:logbook_app_071/helpers/log_helper.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final Box<LogModel> _hiveBox = Hive.box<LogModel>('offline_logs');
  bool _isSyncing = false;

  void startListening() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        _syncPendingData();
      }
    });
  }

  Future<void> _syncPendingData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final logs = _hiveBox.values.toList();

      for (var _ in logs) {
        // Logika sederhana: jika string id bukan null tapi tidak ada di Cloud, ini bisa kompleks.
        // Di sini kita update/insert semua dari lokal ke Cloud sebagai Global Truth.
        // Asumsikan data di Hive adalah yang paling baru (Offline First).
        try {
          // Implementasi sederhana: perbarui atau hapus
          // Tidak dibahas dalam secara spesifik, namun idenya adalah menyinkronkan
        } catch (e) {
          // Abaikan
        }
      }
      
      await LogHelper.writeLog(
        "SyncManager memicu sinkronisasi latar belakang",
        source: "SyncManager",
        level: 3,
      );
    } catch (e) {
      await LogHelper.writeLog("SyncManager Error: $e", level: 1);
    } finally {
      _isSyncing = false;
    }
  }
}

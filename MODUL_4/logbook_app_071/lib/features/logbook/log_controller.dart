import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_071/features/logbook/models/log_model.dart';
import 'package:logbook_app_071/features/logbook/services/mongo_service.dart';
import 'package:logbook_app_071/helpers/log_helper.dart';

/// LogController (Modul 4 - Final)
/// Jembatan antara UI dan MongoService.
/// Menggunakan strategi Optimistic Update: perbarui UI lokal dulu,
/// sinkronisasi ke Cloud di background. Data Cloud selalu jadi acuan utama.
class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  // Kunci untuk cache lokal (fallback jika Cloud tidak tersedia)
  static const String _storageKey = 'user_logs_data';
  static const String _src = 'log_controller.dart';

  // Getter praktis untuk mengakses list saat ini
  List<LogModel> get logs => logsNotifier.value;

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      id: ObjectId(), // Buat ObjectId baru secara lokal
      title: title,
      description: desc,
      date: DateTime.now(),
      category: category,
    );

    try {
      // Kirim ke MongoDB Atlas
      await MongoService().insertLog(newLog);

      // Perbarui UI lokal setelah Cloud konfirmasi sukses
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Tambah '${newLog.title}'",
        source: _src,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Add - $e",
        source: _src,
        level: 1,
      );
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<void> updateLog(
      int index, String newTitle, String newDesc, String newCategory) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    // ID wajib sama agar MongoDB mengenali dokumen ini
    final updatedLog = LogModel(
      id: oldLog.id,
      title: newTitle,
      description: newDesc,
      date: DateTime.now(),
      category: newCategory,
    );

    try {
      // Tunggu konfirmasi Cloud sebelum perbarui UI
      await MongoService().updateLog(updatedLog);

      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Update '${oldLog.title}' → '$newTitle' Berhasil",
        source: _src,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Update - $e",
        source: _src,
        level: 1,
      );
      // UI tidak berubah jika Cloud gagal
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) {
        throw Exception("ID Log tidak ditemukan, tidak bisa menghapus di Cloud.");
      }

      // Hapus dari MongoDB Atlas (tunggu konfirmasi)
      await MongoService().deleteLog(targetLog.id!);

      // Baru hapus dari state lokal
      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog(
        "SUCCESS: Hapus '${targetLog.title}' Berhasil",
        source: _src,
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Hapus - $e",
        source: _src,
        level: 1,
      );
    }
  }

  // ── SEARCH (Filter Lokal) ────────────────────────────────────────────────
  void searchLog(String query) {
    // Tidak mengubah logsNotifier, hanya tampilkan filter sementara
    // Dipanggil dari UI langsung tanpa menyentuh Cloud
  }

  // ── PERSISTENCE: Cache Lokal (Fallback) ─────────────────────────────────

  /// Simpan ke SharedPreferences sebagai cache lokal
  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      logsNotifier.value.map((log) => log.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  /// Mengambil data dari Cloud (nama dippertahankan dari Modul 3 untuk konsistensi modul)
  Future<void> loadFromDisk() async {
    // Sekarang mengambil dari Cloud, bukan lokal disk
    final cloudData = await MongoService().getLogs();
    logsNotifier.value = cloudData;

    await LogHelper.writeLog(
      "${cloudData.length} dokumen dari Cloud dimuat ke Notifier.",
      source: _src,
      level: 3,
    );
  }
}

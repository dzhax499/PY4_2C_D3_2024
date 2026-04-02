// test/module4_cloud_test.dart
// Modul 4 - Save Data to Cloud Service (LogModel + Local Cache Fallback)
// Unit Testing: 3 Test Cases menggunakan pola AAA (Arrange-Act-Assert)
//
// Catatan: MongoService membutuhkan koneksi MongoDB Atlas (jaringan nyata).
// Untuk unit testing, kita menguji:
//   1. LogModel serialisasi (toMap / fromMap) - murni logika lokal
//   2. LogController.saveToDisk() - cache lokal (fallback) tanpa Cloud
//   3. LogModel integritas data (field wajib tidak boleh null/kosong)

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_071/features/logbook/models/log_model.dart';
import 'package:logbook_app_071/features/logbook/log_controller.dart';

void main() {
  var actual, expected;

  group('Module 4 - LogModel & LogController (Save Data to Cloud Service)', () {

    // TC01: LogModel.toMap() harus menghasilkan Map dengan semua field yang benar
    test('TC01 - LogModel.toMap() harus menghasilkan Map yang valid', () {
      // (1) Arrange
      final id = ObjectId();
      final date = DateTime(2025, 3, 31);
      final log = LogModel(
        id: id,
        title: 'Rapat Tim',
        description: 'Pembahasan sprint ke-4',
        date: date,
        category: 'Pekerjaan',
      );

      // (2) Act
      actual = log.toMap();
      expected = {
        '_id': id,
        'title': 'Rapat Tim',
        'description': 'Pembahasan sprint ke-4',
        'date': date.toIso8601String(),
        'category': 'Pekerjaan',
      };

      // (3) Assert
      expect(actual['title'], expected['title'],
          reason: 'Field title tidak sesuai');
      expect(actual['description'], expected['description'],
          reason: 'Field description tidak sesuai');
      expect(actual['category'], expected['category'],
          reason: 'Field category tidak sesuai');
      expect(actual['date'], expected['date'],
          reason: 'Field date tidak sesuai format ISO8601');
    });

    // TC02: LogModel.fromMap() harus merekonstruksi objek dari Map dengan benar
    test('TC02 - LogModel.fromMap() harus merekonstruksi objek LogModel yang valid', () {
      // (1) Arrange
      final id = ObjectId();
      final map = {
        '_id': id,
        'title': 'Belajar MongoDB',
        'description': 'Integrasi Flutter dengan Atlas',
        'date': '2025-03-31T00:00:00.000',
        'category': 'Pribadi',
      };

      // (2) Act
      final log = LogModel.fromMap(map);
      actual = log.title;
      expected = 'Belajar MongoDB';

      // (3) Assert
      expect(actual, expected, reason: 'Title tidak sesuai setelah fromMap()');
      expect(log.category, 'Pribadi',
          reason: 'Category tidak sesuai setelah fromMap()');
      expect(log.id, id, reason: 'ObjectId tidak sesuai setelah fromMap()');
    });

    // TC03: saveToDisk() harus menyimpan data logsNotifier ke SharedPreferences (cache fallback)
    test('TC03 - saveToDisk() harus menyimpan state logs ke cache lokal', () async {
      // (1) Arrange - mock SharedPreferences, tidak ada koneksi Cloud
      SharedPreferences.setMockInitialValues({});
      final controller = LogController();

      // Tambahkan data langsung ke logsNotifier (bypass MongoService)
      final testLog = LogModel(
        id: ObjectId(),
        title: 'Cache Fallback Test',
        description: 'Uji penyimpanan lokal',
        date: DateTime.now(),
        category: 'Urgent',
      );
      controller.logsNotifier.value = [testLog];

      // (2) Act - simpan ke disk lokal
      await controller.saveToDisk();

      // Verifikasi via SharedPreferences langsung
      final prefs = await SharedPreferences.getInstance();
      actual = prefs.containsKey('user_logs_data');
      expected = true;

      // (3) Assert
      expect(actual, expected,
          reason:
              'Data harus tersimpan di SharedPreferences dengan key "user_logs_data"');
    });
  });
}

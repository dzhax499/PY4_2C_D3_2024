// test/module3_disk_test.dart
// Modul 3 - Save Data to Disk (LogController + SharedPreferences)
// Unit Testing: 3 Test Cases menggunakan pola AAA (Arrange-Act-Assert)

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_071/features/logbook/log_controller.dart';

void main() {
  var actual, expected;

  group('Module 3 - LogController (Save Data to Disk)', () {
    late LogController controller;

    setUp(() async {
      // (1) setup (arrange, build) - mock SharedPreferences (tidak ada data awal)
      SharedPreferences.setMockInitialValues({});

      // Buat controller baru dan izinkan loadFromDisk() berjalan
      controller = LogController();
      // Tunggu inisialisasi loadFromDisk() yang dipanggil di constructor
      await Future.delayed(const Duration(milliseconds: 100));
    });

    // TC01: Menambah log baru harus bertambah di list dan tersimpan ke disk
    test('TC01 - addLog harus menambahkan entri ke list logsNotifier', () async {
      // (1) Arrange
      const title = 'Belajar Flutter';
      const desc = 'Mempelajari unit testing';
      const category = 'Pekerjaan';

      // (2) Act
      controller.addLog(title, desc, category);
      await Future.delayed(const Duration(milliseconds: 100)); // tunggu IO
      actual = controller.logsNotifier.value.length;
      expected = 1;

      // (3) Assert
      expect(actual, expected,
          reason: 'Expected $expected log item but got $actual');
    });

    // TC02: Data yang disimpan ke disk harus dapat dimuat kembali
    test('TC02 - loadFromDisk harus memuat data yang sudah disimpan', () async {
      // (1) Arrange
      controller.addLog('Test Entry', 'Deskripsi test', 'Pribadi');
      await Future.delayed(const Duration(milliseconds: 100));

      // Buat instance controller baru (simulasi restart aplikasi)
      final newController = LogController();

      // (2) Act
      await Future.delayed(const Duration(milliseconds: 200)); // tunggu load
      actual = newController.logsNotifier.value.length;
      expected = 1;

      // (3) Assert
      expect(actual, expected,
          reason:
              'Expected $expected log setelah reload, but got $actual');
    });

    // TC03: Menghapus log harus mengurangi jumlah item dalam list
    test('TC03 - removeLog harus menghapus entri dari list', () async {
      // (1) Arrange
      controller.addLog('Entry 1', 'Deskripsi 1', 'Pribadi');
      controller.addLog('Entry 2', 'Deskripsi 2', 'Pekerjaan');
      await Future.delayed(const Duration(milliseconds: 100));

      // (2) Act
      controller.removeLog(0); // hapus item pertama
      await Future.delayed(const Duration(milliseconds: 100));
      actual = controller.logsNotifier.value.length;
      expected = 1;

      // (3) Assert
      expect(actual, expected,
          reason: 'Expected $expected log setelah hapus, but got $actual');
    });
  });
}

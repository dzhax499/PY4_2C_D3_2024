// test/module2_auth_test.dart
// Modul 2 - Authentication (LoginController)
// Unit Testing: 3 Test Cases menggunakan pola AAA (Arrange-Act-Assert)

import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_071/features/auth/login_controller.dart';

void main() {
  var actual, expected;

  group('Module 2 - LoginController (Authentication)', () {
    late LoginController controller;

    setUp(() {
      // (1) setup (arrange, build) - buat instance baru setiap test
      controller = LoginController();
    });

    // TC01: Login dengan input kosong harus gagal
    test('TC01 - login dengan username dan password kosong harus gagal', () {
      // (1) Arrange
      const username = '';
      const password = '';

      // (2) Act
      actual = controller.login(username, password);
      expected = 'Username dan Password tidak boleh kosong!';

      // (3) Assert
      expect(actual, expected, reason: 'Expected "$expected" but got "$actual"');
    });

    // TC02: Login dengan password salah harus mengembalikan pesan error
    test('TC02 - login dengan password salah harus mengembalikan pesan error', () {
      // (1) Arrange
      const username = 'admin';
      const password = 'wrongpassword';

      // (2) Act
      actual = controller.login(username, password);
      expected = 'Password salah! Percobaan: 1/3';

      // (3) Assert
      expect(actual, expected, reason: 'Expected "$expected" but got "$actual"');
    });

    // TC03: Login dengan kredensial yang benar harus berhasil
    test('TC03 - login dengan kredensial yang benar harus berhasil', () {
      // (1) Arrange
      const username = 'admin';
      const password = '123';

      // (2) Act
      actual = controller.login(username, password);
      expected = 'OK';

      // (3) Assert
      expect(actual, expected, reason: 'Expected "$expected" but got "$actual"');
    });
  });
}

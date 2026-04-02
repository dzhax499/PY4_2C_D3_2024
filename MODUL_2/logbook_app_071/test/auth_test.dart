import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_071/features/auth/login_controller.dart';

void main() {
  group('Login Controller Tests', () {
    late LoginController controller;

    setUp(() {
      controller = LoginController();
    });

    // Flow 1: Normal/Positive (Success Login)
    test('TC01 - Normal Login should return OK and not be locked', () {
      final actual = controller.login('admin', '123');
      const expected = 'OK';
      expect(actual, expected, reason: 'Expected $expected but got $actual');
      expect(controller.isLocked, false);
    });

    // Flow 2: Negative/Edge (Empty Input)
    test('TC02 - Empty username or password should return error message', () {
      final actual = controller.login('', '123');
      const expected = 'Username dan Password tidak boleh kosong!';
      expect(actual, expected, reason: 'Expected $expected but got $actual');
    });

    // Flow 3: Negative (Lockout Mechanism)
    test('TC03 - Wrong password 3 times should lock the account', () {
      controller.login('admin', 'wrong'); // attempt 1
      controller.login('admin', 'wrong'); // attempt 2
      final actual = controller.login('admin', 'wrong'); // attempt 3

      const expected = 'Salah 3x. Akun terkunci selama 10 detik.';
      expect(actual, expected, reason: 'Expected $expected but got $actual');
      expect(controller.isLocked, true);
    });
  });
}

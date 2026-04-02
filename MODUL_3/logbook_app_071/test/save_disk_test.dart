import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logbook_app_071/features/logbook/log_controller.dart';

void main() {
  group('Log Controller Modul 3 Tests', () {
    late LogController controller;

    setUp(() {
      // Setup mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      controller = LogController();
    });

    // Flow 1: Negative / no match
    test('TC01 - searchLog with no match returns empty result', () {
      controller.addLog('Test1', 'desc1', 'cat1');
      controller.searchLog('xyz');
      expect(controller.filteredLogs.value.isEmpty, true, reason: 'Expected empty result');
    });

    // Flow 2: Positive / match found
    test('TC02 - searchLog with matching query returns filtered logs', () {
      controller.addLog('Test1', 'desc1', 'cat1');
      controller.addLog('Hello', 'desc2', 'cat2');
      controller.searchLog('Test');
      expect(controller.filteredLogs.value.length, 1, reason: 'Expected 1 matched log');
      expect(controller.filteredLogs.value.first.title, 'Test1');
    });

    // Flow 3: Normal / empty query
    test('TC03 - searchLog with empty query returns all logs', () {
      controller.addLog('Test1', 'desc1', 'cat1');
      controller.addLog('Hello', 'desc2', 'cat2');
      controller.searchLog(''); // empty query
      expect(controller.filteredLogs.value.length, 2, reason: 'Expected all logs');
    });
  });
}

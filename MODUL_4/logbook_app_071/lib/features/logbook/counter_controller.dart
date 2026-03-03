import 'package:shared_preferences/shared_preferences.dart';


class CounterController {
  int _counter = 0; // Variabel private (Enkapsulasi)
  int _step = 1; // Variabel step dengan default value 1
  final List<Map<String, String>> _history = []; // List untuk menyimpan riwayat aktivitas dengan tipe

  int get value => _counter; // Getter untuk nilai counter
  int get step => _step; // Getter untuk nilai step
  List<Map<String, String>> get history => _history; // Getter untuk riwayat

  // Fungsi untuk mendapatkan 5 aktivitas terakhir
  List<Map<String, String>> getLastFiveActivities() {
    if (_history.isEmpty) return [];
    // Ambil dari akhir list (aktivitas terakhir paling atas)
    return _history.reversed.take(5).toList().reversed.toList();
  }

  // Helper untuk mendapatkan waktu saat ini dalam format HH:mm
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // Fungsi untuk mengubah nilai step
  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  // Increment menggunakan nilai step
  void increment(String username) {
    _counter += _step;
    _history.add({
      'type': 'increment',
      'message': 'User adding value $_step at ${_getCurrentTime()}'
    });
    saveLastValue(username, _counter); // Simpan otomatis per user
  }

  // Decrement menggunakan nilai step
  void decrement(String username) {
    if (_counter >= _step) {
      _counter -= _step;
      _history.add({
        'type': 'decrement',
        'message': 'User reducing value $_step at ${_getCurrentTime()}'
      });
    } else {
      _counter = 0; // Reset ke 0 jika hasil negatif
      _history.add({
        'type': 'decrement',
        'message': 'User tried decrement, reset to 0 at ${_getCurrentTime()}'
      });
    }
    saveLastValue(username, _counter); // Simpan otomatis per user
  }

  void reset(String username) {
    _counter = 0;
    _history.add({
      'type': 'reset',
      'message': 'User reset counter at ${_getCurrentTime()}'
    });
    saveLastValue(username, _counter); // Simpan otomatis per user
  }
  
  // --- PERSISTENCE LOGIC (Task 3 & Homework) ---

  // Simpan nilai terakhir dengan Shared Preferences (User Specific)
  Future<void> saveLastValue(String username, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_counter_$username', value);
  }

  // Load nilai terakhir saat aplikasi mulai (User Specific)
  Future<void> loadLastValue(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('last_counter_$username') ?? 0;
  }
}

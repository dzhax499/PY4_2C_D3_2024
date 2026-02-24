class LoginController {
  // 1. Database Multiple Users (Map)
  // Format: key=username, value=password
  final Map<String, String> _users = {
    'admin': '123',
    'dzakir': 'dzakir123',
    'pengguna': 'pengguna123',
  };

  // State Keamanan
  int _attemptCount = 0;
  bool _isLocked = false;
  DateTime? _lockoutTime;

  // Getter
  bool get isLocked => _isLocked;

  // Fungsi Login dengan Return String (Pesan Error/Success)
  String login(String username, String password) {
    // 0. Cek apakah terkunci
    if (_isLocked) {
      if (DateTime.now().isAfter(_lockoutTime!)) {
        // Unlock jika waktu habis
        _isLocked = false;
        _attemptCount = 0;
      } else {
        final remaining = _lockoutTime!.difference(DateTime.now()).inSeconds;
        return "Akun terkunci. Tunggu $remaining detik lagi.";
      }
    }

    // 1. Validasi Input Kosong
    if (username.isEmpty || password.isEmpty) {
      return "Username dan Password tidak boleh kosong!";
    }

    // 2. Cek Username ada atau tidak
    if (!_users.containsKey(username)) {
      return "Username tidak ditemukan!";
    }

    // 3. Cek Password
    if (_users[username] == password) {
      // Login Sukses
      _attemptCount = 0; // Reset percobaan
      return "OK";
    } else {
      // Login Gagal (Password Salah)
      _attemptCount++;
      if (_attemptCount >= 3) {
        _isLocked = true;
        _lockoutTime = DateTime.now().add(const Duration(seconds: 10)); // Kunci 10 detik
        return "Salah 3x. Akun terkunci selama 10 detik.";
      }
      return "Password salah! Percobaan: $_attemptCount/3";
    }
  }
}

import 'package:flutter/material.dart';
// Import Controller milik sendiri (masih satu folder)
import 'package:logbook_app_071/features/auth/login_controller.dart';
// Import View dari fitur lain (Logbook) untuk navigasi
import 'package:logbook_app_071/features/logbook/log_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  
  // State untuk Show/Hide Password
  bool _isPasswordVisible = false;

  void _handleLogin() {
    String user = _userController.text;
    String pass = _passController.text;

    // Panggil fungsi login yang baru (return String)
    String result = _controller.login(user, pass);

    if (result == "OK") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LogView(username: user),
        ),
      );
    } else {
      // Tampilkan Pesan Error / Kunci
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.red,
        ),
      );
      
      if (_controller.isLocked) {
        setState(() {}); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Login Gatekeeper",
          style: TextStyle(color: Color(0xFFF5C400), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF000000),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: Colors.white,
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _controller.isLocked ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color(0xFFF5C400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  _controller.isLocked ? "Terkunci (Wait 10s)" : "Masuk",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

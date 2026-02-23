import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logbook_app_071/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _step = 1;

  void _nextStep() {
    if (_step < 3) {
      setState(() {
        _step++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow.shade700, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "Onboarding",
                  style: GoogleFonts.oswald(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gambar Onboarding
                    Expanded(
                      flex: 3,
                      child: Image.asset(
                        _getImage(_step),
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Judul dan Deskripsi (Homework)
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(
                            _getTitle(_step),
                            style: GoogleFonts.oswald(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getDescription(_step),
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    // Page Indicator (Homework)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _step == index + 1 ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _step == index + 1 ? Colors.indigo : Colors.indigo.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 40),
                    // Tombol Navigasi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Warna Hitam
                            foregroundColor: Colors.white, // Teks Putih
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Sudut Tumpul (Bulat)
                            ),
                          ),
                          child: Text(
                            _step < 3 ? "Lanjut" : "Mulai Sekarang",
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImage(int step) {
    switch (step) {
      case 1:
        return "assets/images/dzakirapps-logo.png";
      case 2:
        return "assets/images/welcome-bikers.png";
      case 3:
        return "assets/images/logbook-bikers.png";
      default:
        return "assets/images/dzakirapps-logo.png";
    }
  }

  String _getTitle(int step) {
    switch (step) {
      case 1:
        return "Selamat Datang di DzakirApps";
      case 2:
        return "Ini adalah aplikasi mobile pertama saya";
      case 3:
        return "Catatan Harian dan Pantau performamu disini";
      default:
        return "";
    }
  }

  String _getDescription(int step) {
    switch (step) {
      case 1:
        return "Aplikasi DzakirApps logbook membantu Anda mencatat setiap aktivitas harian dengan mudah dan cepat.";
      case 2:
        return "Setiap langkah kecil berarti. Simpan progresmu agar tidak pernah kehilangan jejak.";
      case 3:
        return "Analisis riwayat aktivitasmu dan tingkatkan produktivitas setiap hari.";
      default:
        return "";
    }
  }
}

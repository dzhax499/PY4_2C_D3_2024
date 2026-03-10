import 'package:flutter/material.dart';
import 'package:logbook_app_071/features/logbook/counter_controller.dart';
import 'package:logbook_app_071/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  final String username;
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  void initState() {
    super.initState();
    _loadData(); // Panggil fungsi load saat aplikasi dibuka
  }

  Future<void> _loadData() async {
    await _controller.loadLastValue(widget.username);
    setState(() {}); // Refresh UI setelah data dimuat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin? Data yang belum disimpan mungkin akan hilang."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); 
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const OnboardingView()),
                            (route) => false,
                          );
                        },
                        child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              // Welcome Banner (Homework: Time-based greeting)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Column(
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    Text(
                      widget.username,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text("Total Hitungan Anda:"),
              Text('${_controller.value}', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 40),
              // Section untuk Step Control
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const Text("Nilai Step:"),
                    Text('${_controller.step}', 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Slider(
                      value: _controller.step.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: _controller.step.toString(),
                      onChanged: (value) {
                        setState(() {
                          _controller.setStep(value.toInt());
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Tombol Reset
              ElevatedButton(
                onPressed: () => _showResetConfirmationDialog(),
                child: const Text("Reset"),
              ),
              const SizedBox(height: 40),
              // Section Riwayat Aktivitas (5 terakhir)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Riwayat Aktivitas (5 Terakhir):",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Buat container riwayat mengisi persentase tinggi layar (mis. 45%).
                  // Gunakan minHeight & maxHeight sama agar selalu tampil dengan tinggi tersebut.
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.45,
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: _controller.getLastFiveActivities().isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "Belum ada aktivitas",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _controller.getLastFiveActivities().length,
                          itemBuilder: (context, index) {
                            final activities = _controller.getLastFiveActivities();
                            final activity = activities[index];
                            final activityType = activity['type'] ?? '';

                          // Warna History berdasarkan tipe aktivitas
                            Color circleBgColor;
                            Color textColor;
                            switch (activityType) {
                              case 'increment':
                                circleBgColor = Colors.green;
                                textColor = Colors.white;
                                break;
                              case 'decrement':
                                circleBgColor = Colors.red;
                                textColor = Colors.white;
                                break;
                              case 'reset':
                                circleBgColor = const Color.fromARGB(255, 255, 193, 7);
                                textColor = Colors.black;
                                break;
                              default:
                                circleBgColor = Colors.grey;
                                textColor = Colors.white;
                            }
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: circleBgColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: _getActivityIcon(activityType, textColor),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      activity['message'] ?? '',
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "increment",
            onPressed: () => setState(() => _controller.increment(widget.username)),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "decrement",
            onPressed: () => setState(() => _controller.decrement(widget.username)),
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _getActivityIcon(String activityType, Color color) {
    switch (activityType) {
      case 'increment':
        return Icon(Icons.add, color: color, size: 18);
      case 'decrement':
        return Icon(Icons.remove, color: color, size: 18);
      case 'reset':
        return Icon(Icons.refresh, color: color, size: 18);
      default:
        return Icon(Icons.info, color: color, size: 18);
    }
  }

  // Helper Greeting (Homework)
  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour < 15) {
      return 'Selamat Siang,';
    } else if (hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Reset"),
          content: const Text("Apakah Anda yakin ingin mereset counter ke 0?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                setState(() => _controller.reset(widget.username));
                Navigator.of(context).pop();
              },
              child: const Text(
                "Reset",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

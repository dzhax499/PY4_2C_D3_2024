import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: Versi SRP")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text("Total Hitungan:"),
              Text('${_controller.value}', style: const TextStyle(fontSize: 40)),
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
            onPressed: () => setState(() => _controller.increment()),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "decrement",
            onPressed: () => setState(() => _controller.decrement()),
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
                setState(() => _controller.reset());
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

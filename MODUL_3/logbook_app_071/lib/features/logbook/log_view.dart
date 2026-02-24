import 'package:flutter/material.dart';
import 'package:logbook_app_071/features/logbook/log_controller.dart';
import 'package:logbook_app_071/features/logbook/models/log_model.dart';
import 'package:logbook_app_071/features/onboarding/onboarding_view.dart';

class LogView extends StatefulWidget {
  final String username;
  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Warna tema: Hitam, Putih, Kuning
  static const Color _black  = Color(0xFF000000);
  static const Color _accent = Color(0xFFF5C400);

  // Daftar kategori
  static const List<String> _categories = ['Pribadi', 'Pekerjaan', 'Urgent'];
  String _selectedCategory = 'Pribadi';

  // Warna per kategori
  Color _categoryColor(String category) {
    switch (category) {
      case 'Pekerjaan': return const Color(0xFFFFF9C4); // kuning muda
      case 'Urgent':    return const Color(0xFFFFEBEE); // merah muda
      default:          return Colors.white;             // Pribadi → putih
    }
  }

  // Ikon per kategori
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Pekerjaan': return Icons.work_outline;
      case 'Urgent':    return Icons.priority_high;
      default:          return Icons.person_outline;
    }
  }

  // Border kiri per kategori
  Color _categoryBorder(String category) {
    switch (category) {
      case 'Pekerjaan': return _accent;                  // kuning
      case 'Urgent':    return Colors.red.shade400;       // merah
      default:          return Colors.grey.shade400;      // abu-abu
    }
  }

  // Badge label per kategori
  Color _categoryBadgeBg(String category) {
    switch (category) {
      case 'Pekerjaan': return _accent;
      case 'Urgent':    return Colors.red.shade400;
      default:          return Colors.grey.shade300;
    }
  }

  Color _categoryBadgeFg(String category) {
    switch (category) {
      case 'Pribadi': return Colors.black87;
      default:        return Colors.white;
    }
  }

  // Dialog Tambah Catatan
  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    _selectedCategory = 'Pribadi';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.note_add, color: _black),
              const SizedBox(width: 8),
              const Text("Catatan Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Judul Catatan",
                  prefixIcon: Icon(Icons.title, color: _black),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _black),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Isi Deskripsi",
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description, color: Colors.black54),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _black),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Dropdown Kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(_categoryIcon(cat), size: 18, color: _black),
                      const SizedBox(width: 8),
                      Text(cat),
                    ],
                  ),
                )).toList(),
                onChanged: (val) => setDialogState(() => _selectedCategory = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _black,
                foregroundColor: _accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  _controller.addLog(
                    _titleController.text,
                    _contentController.text,
                    _selectedCategory,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Edit Catatan
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    _selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.black87),
              const SizedBox(width: 8),
              const Text("Edit Catatan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Judul Catatan",
                  prefixIcon: Icon(Icons.title, color: _black),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _black),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Isi Deskripsi",
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description, color: Colors.black54),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _black),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(_categoryIcon(cat), size: 18, color: _black),
                      const SizedBox(width: 8),
                      Text(cat),
                    ],
                  ),
                )).toList(),
                onChanged: (val) => setDialogState(() => _selectedCategory = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _black,
                foregroundColor: _accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                _controller.updateLog(
                  index,
                  _titleController.text,
                  _contentController.text,
                  _selectedCategory,
                );
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _accent,
              child: Text(
                widget.username[0].toUpperCase(),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Logbook", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(widget.username, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
        backgroundColor: _black,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin ingin keluar?"),
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
      body: ValueListenableBuilder<List<LogModel>>(
        valueListenable: _controller.filteredLogs,
        builder: (context, currentLogs, child) {
          return Column(
            children: [
              // ─── Search Bar ───────────────────────────────────────
              Container(
                color: _black,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: TextField(
                  onChanged: (value) => _controller.searchLog(value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari catatan...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: _accent),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // ─── Counter catatan ───────────────────────────────────
              if (currentLogs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        "${currentLogs.length} catatan",
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              // ─── List / Empty State ────────────────────────────────
              Expanded(
                child: currentLogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                color: _accent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.note_alt_outlined, size: 56, color: _accent),
                            ),
                            const SizedBox(height: 20),
                            const Text("Belum ada catatan",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 8),
                            const Text("Tap + untuk menambahkan catatan baru",
                                style: TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: currentLogs.length,
                        itemBuilder: (context, index) {
                          final log = currentLogs[index];

                          return Dismissible(
                            key: Key(log.date),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: const Icon(Icons.delete, color: Colors.white, size: 28),
                            ),
                            onDismissed: (direction) {
                              _controller.removeLog(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Catatan dihapus"),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: _categoryColor(log.category), // ← warna per kategori
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border(
                                  left: BorderSide(
                                    color: _categoryBorder(log.category), // ← border per kategori
                                    width: 4,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Icon kategori
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        color: _categoryBorder(log.category).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(_categoryIcon(log.category),
                                          color: _categoryBorder(log.category), size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    // Konten
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(log.title,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.black87)),
                                              ),
                                              // Badge kategori
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: _categoryBadgeBg(log.category),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(log.category,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: _categoryBadgeFg(log.category))),
                                              ),
                                            ],
                                          ),
                                          if (log.description.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(log.description,
                                                style: const TextStyle(
                                                    fontSize: 13, color: Colors.black54, height: 1.4),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis),
                                          ],
                                          const SizedBox(height: 6),
                                          Text(log.date.substring(0, 16),
                                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    // Tombol aksi
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
                                          onPressed: () => _showEditLogDialog(index, log),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(6),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                                          onPressed: () => _controller.removeLog(index),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(6),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLogDialog,
        backgroundColor: _black,
        foregroundColor: _accent,
        icon: const Icon(Icons.add),
        label: const Text("Tambah Catatan"),
        elevation: 4,
      ),
    );
  }
}

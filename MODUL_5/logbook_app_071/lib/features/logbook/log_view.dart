import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logbook_app_071/features/logbook/log_controller.dart';
import 'package:logbook_app_071/features/logbook/models/log_model.dart';
import 'package:logbook_app_071/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_071/features/logbook/services/mongo_service.dart';
import 'package:logbook_app_071/helpers/log_helper.dart';
import 'package:logbook_app_071/services/access_control_service.dart';
import 'package:logbook_app_071/features/logbook/log_editor_page.dart';
import 'package:lottie/lottie.dart';
class LogView extends StatefulWidget {
  final dynamic currentUser;

  const LogView({super.key, required this.currentUser});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  // ── Controller & State ───────────────────────────────────────────────────
  late LogController _controller;
  bool _isLoading = false;
  bool _isOffline = false; // ← HOMEWORK 1: Connection Guard

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ValueNotifier<String> _searchNotifier = ValueNotifier('');

  // ── Tema Warna ───────────────────────────────────────────────────────────
  static const Color _black  = Color(0xFF000000);
  static const Color _accent = Color(0xFFF5C400);

  // ── Kategori ─────────────────────────────────────────────────────────────
  static const List<String> _categories = ['Mechanical', 'Electronic', 'Software', 'Pribadi', 'Pekerjaan', 'Urgent'];
  String _selectedCategory = 'Mechanical';
  bool _isPublic = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _controller = LogController();
    Future.microtask(() => _initDatabase());
  }

  /// Inisialisasi koneksi + muat data dari Atlas
  Future<void> _initDatabase() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
    });
    try {
      await LogHelper.writeLog(
        "UI: Memulai inisialisasi database...",
        source: "log_view.dart",
      );

      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(
          "Koneksi Cloud Timeout. Periksa sinyal/IP Whitelist.",
        ),
      );

      await LogHelper.writeLog(
        "UI: Koneksi MongoService BERHASIL.",
        source: "log_view.dart",
      );

      await _controller.loadLogs(widget.currentUser['teamId']);

      await LogHelper.writeLog(
        "UI: Data berhasil dimuat ke Notifier.",
        source: "log_view.dart",
      );
    } catch (e) {
      // ── HOMEWORK 1: Connection Guard ──────────────────────────────────────
      await LogHelper.writeLog(
        "UI: Error (Offline Mode Aktif) - $e",
        source: "log_view.dart",
        level: 1,
      );
      if (mounted) {
        setState(() => _isOffline = true); // Tandai offline
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── HOMEWORK 2: Pull-to-Refresh Handler ────────────────────────────────
  Future<void> _onRefresh() async {
    try {
      setState(() => _isOffline = false); // Reset status offline
      await MongoService().connect().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Timeout saat refresh."),
      );
      await _controller.loadLogs(widget.currentUser['teamId']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text("Data berhasil diperbarui dari Cloud!"),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isOffline = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal refresh: $e"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── HOMEWORK 3: Format Waktu Relatif Indonesia ─────────────────────────
  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      // Lebih dari 7 hari → tampilkan format Indonesia
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
    }
  }

  // ── Helpers Kategori ──────────────────────────────────────────────────────
  Color _categoryColor(String category) {
    switch (category) {
      case 'Mechanical': return Colors.green.shade50;
      case 'Electronic': return Colors.blue.shade50;
      case 'Software':   return Colors.purple.shade50;
      case 'Pekerjaan': return const Color(0xFFFFF9C4);
      case 'Urgent':    return const Color(0xFFFFEBEE);
      default:          return Colors.white;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Mechanical': return Icons.precision_manufacturing;
      case 'Electronic': return Icons.electric_bolt;
      case 'Software':   return Icons.code;
      case 'Pekerjaan': return Icons.work_outline;
      case 'Urgent':    return Icons.priority_high;
      default:          return Icons.person_outline;
    }
  }

  Color _categoryBorder(String category) {
    switch (category) {
      case 'Mechanical': return Colors.green.shade400;
      case 'Electronic': return Colors.blue.shade400;
      case 'Software':   return Colors.purple.shade400;
      case 'Pekerjaan': return _accent;
      case 'Urgent':    return Colors.red.shade400;
      default:          return Colors.grey.shade400;
    }
  }

  Color _categoryBadgeBg(String category) {
    switch (category) {
      case 'Mechanical': return Colors.green.shade400;
      case 'Electronic': return Colors.blue.shade400;
      case 'Software':   return Colors.purple.shade400;
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

  // ── Dialog Tambah ─────────────────────────────────────────────────────────
  void _showAddLogDialog() {
    _titleController.clear();
    _contentController.clear();
    _selectedCategory = 'Pribadi';
    _isPublic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.note_add, color: _black),
              const SizedBox(width: 8),
              const Text("Catatan Baru",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_titleController, "Judul Catatan", Icons.title),
              const SizedBox(height: 12),
              _buildTextField(_contentController, "Isi Deskripsi",
                  Icons.description, maxLines: 3),
              const SizedBox(height: 12),
              _buildCategoryDropdown(setDialogState),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Buat Publik"),
                subtitle: const Text("Bisa dilihat anggota tim lain"),
                value: _isPublic,
                activeColor: _accent,
                onChanged: (val) {
                  setDialogState(() => _isPublic = val);
                },
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  _controller.addLog(
                    _titleController.text,
                    _contentController.text,
                    _selectedCategory,
                    widget.currentUser['uid'],
                    widget.currentUser['teamId'],
                    isPublic: _isPublic,
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

  // ── Dialog Edit ───────────────────────────────────────────────────────────
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text   = log.title;
    _contentController.text = log.description;
    _selectedCategory       = log.category;
    _isPublic               = log.isPublic;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.black87),
              const SizedBox(width: 8),
              const Text("Edit Catatan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_titleController, "Judul Catatan", Icons.title),
              const SizedBox(height: 12),
              _buildTextField(_contentController, "Isi Deskripsi",
                  Icons.description, maxLines: 3),
              const SizedBox(height: 12),
              _buildCategoryDropdown(setDialogState),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Buat Publik"),
                subtitle: const Text("Bisa dilihat anggota tim lain"),
                value: _isPublic,
                activeColor: _accent,
                onChanged: (val) {
                  setDialogState(() => _isPublic = val);
                },
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                _controller.updateLog(
                  index,
                  _titleController.text,
                  _contentController.text,
                  _selectedCategory,
                  isPublic: _isPublic,
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

  // ── Widget Helpers ────────────────────────────────────────────────────────
  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 40 : 0),
          child: Icon(icon, color: Colors.black54),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _black),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(StateSetter setDialogState) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: "Kategori",
        prefixIcon: const Icon(Icons.label_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _categories
          .map((cat) => DropdownMenuItem(
                value: cat,
                child: Row(children: [
                  Icon(_categoryIcon(cat), size: 18, color: _black),
                  const SizedBox(width: 8),
                  Text(cat),
                ]),
              ))
          .toList(),
      onChanged: (val) => setDialogState(() => _selectedCategory = val!),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
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
                widget.currentUser['username'][0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Logbook",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text("${widget.currentUser['username']} • ${widget.currentUser['role']}",
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
        backgroundColor: _black,
        elevation: 2,
        actions: [
          // Tombol Refresh manual
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _onRefresh,
            tooltip: "Refresh dari Cloud",
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text("Konfirmasi Logout"),
                content: const Text("Apakah Anda yakin ingin keluar?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Batal")),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OnboardingView()),
                        (route) => false,
                      );
                    },
                    child: const Text("Ya, Keluar",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── BODY ────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // ── HOMEWORK 1: Offline Warning Banner ────────────────────────────
          if (_isOffline)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              backgroundColor: Colors.orange.shade100,
              leading: Icon(Icons.wifi_off, color: Colors.orange.shade800),
              content: Text(
                "Koneksi terputus — data mungkin tidak terbaru. Tarik ke bawah untuk coba lagi.",
                style: TextStyle(
                    color: Colors.orange.shade900,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              actions: [
                TextButton(
                  onPressed: _onRefresh,
                  child: Text("COBA LAGI",
                      style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),

          // ── Content Area ───────────────────────────────────────────────────
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _searchNotifier,
              builder: (context, searchQuery, child) {
                return ValueListenableBuilder<List<LogModel>>(
                  valueListenable: _controller.logsNotifier,
                  builder: (context, currentLogs, child) {

                    // HOMEWORK 5: Filter Visibilitas Privat/Publik
                    final displayLogs = currentLogs.where((log) {
                      final isVisible = log.authorId == widget.currentUser['uid'] || log.isPublic == true;
                      if (searchQuery.isNotEmpty) {
                        final query = searchQuery.toLowerCase();
                        final matchesSearch = log.title.toLowerCase().contains(query) || 
                                              log.description.toLowerCase().contains(query);
                        return isVisible && matchesSearch;
                      }
                      return isVisible;
                    }).toList();

                // 1. Loading state
                if (_isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          "Menghubungkan ke MongoDB Atlas...",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                // 2. Data list — dibungkus RefreshIndicator (HOMEWORK 2)
                return Column(
                  children: [
                    // Search Bar (Selalu Tampil)
                    Container(
                      color: _black,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                      child: TextField(
                        onChanged: (value) {
                          _searchNotifier.value = value;
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Cari berdasarkan judul atau isi...",
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

                    // Counter + hint tarik
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_done, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            "${displayLogs.length} catatan dari Atlas",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const Spacer(),
                          const Text(
                            "↓ tarik untuk refresh",
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    // 3. Konten Utama (Empty State ATAU ListView)
                    Expanded(
                      child: displayLogs.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Lottie.network(
                                      'https://lottie.host/17e2c918-07d3-4674-814e-f8bc827bc582/KhyO51J8U6.json',
                                      width: 250,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 100, height: 100,
                                        decoration: BoxDecoration(
                                          color: _accent.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.description, size: 56, color: _accent),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      searchQuery.isNotEmpty 
                                        ? "Pencarian \"$searchQuery\" tidak ditemukan."
                                        : "Belum ada aktivitas hari ini? Mulai catat kemajuan proyek Anda!",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            color: Colors.black87)),
                                    const SizedBox(height: 8),
                                    if (searchQuery.isEmpty)
                                      ElevatedButton.icon(
                                        onPressed: () { 
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LogEditorPage(
                                                  controller: _controller,
                                                  currentUser: widget.currentUser,
                                                ),
                                              ),
                                            );
                                        },
                                        icon: const Icon(Icons.add),
                                        label: const Text("Buat Catatan Pertama"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _black,
                                          foregroundColor: _accent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _onRefresh,
                              color: _accent,
                              backgroundColor: _black,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                itemCount: displayLogs.length,
                                itemBuilder: (context, displayIndex) {
                                  final log = displayLogs[displayIndex];
                                  final int realIndex = currentLogs.indexOf(log);

                            // ── HOMEWORK 3: Timestamp Indonesia ────────────
                            final relativeTime = _formatRelativeTime(DateTime.parse(log.date));

                            // GATEKEEPER CHECK untuk fungsi SWIPE to Delete
                            final bool canDelete = AccessControlService.canPerform(
                              widget.currentUser['role'],
                              AccessControlService.actionDelete,
                              isOwner: log.authorId == widget.currentUser['uid'],
                            );

                            return Dismissible(
                              key: Key(log.id ?? log.date),
                              direction: canDelete ? DismissDirection.endToStart : DismissDirection.none, // Kunci Swipe Akses
                              background: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                child: const Icon(Icons.delete,
                                    color: Colors.white, size: 28),
                              ),
                              onDismissed: (_) {
                                if (canDelete) {
                                  _controller.removeLog(realIndex);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Catatan dihapus"),
                                      backgroundColor: Colors.red.shade400,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              },
                              // (Klik item -> muncul tulisan unauthorized bila tak punya hak hapus di console/log)
                              confirmDismiss: (direction) async {
                                if (!canDelete) {
                                   debugPrint("UNAUTHORIZED: Attempt to delete log denied for role ${widget.currentUser['role']}");
                                   return false;
                                }
                                return true;
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: _categoryColor(log.category),
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
                                      color: _categoryBorder(log.category),
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 12, 8, 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Icon kategori
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(
                                          color: _categoryBorder(log.category)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                            _categoryIcon(log.category),
                                            color:
                                                _categoryBorder(log.category),
                                            size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      // Konten
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(log.title,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                          color:
                                                              Colors.black87)),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: _categoryBadgeBg(
                                                        log.category),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(log.category,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              _categoryBadgeFg(
                                                                  log.category))),
                                                ),
                                              ],
                                            ),
                                            if (log.description
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(log.description,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54,
                                                      height: 1.4),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ],
                                            const SizedBox(height: 6),
                                            // ── HOMEWORK 3: Timestamp relatif ──
                                            Row(
                                              children: [
                                                const Icon(Icons.cloud_done,
                                                    size: 11,
                                                    color: Colors.green),
                                                const SizedBox(width: 3),
                                                Text(
                                                  relativeTime,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Tombol aksi (Gatekeeper RBAC)
                                      Column(
                                        children: [
                                          if (AccessControlService.canPerform(
                                              widget.currentUser['role'], 
                                              AccessControlService.actionUpdate, 
                                              isOwner: log.authorId == widget.currentUser['uid']))
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 20,
                                                  color: Colors.black54),
                                              onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => LogEditorPage(
                                                        log: log,
                                                        index: realIndex,
                                                        controller: _controller,
                                                        currentUser: widget.currentUser,
                                                      ),
                                                    ),
                                                  );
                                              },
                                              constraints:
                                                  const BoxConstraints(),
                                              padding:
                                                  const EdgeInsets.all(6),
                                            ),
                                          if (AccessControlService.canPerform(
                                              widget.currentUser['role'], 
                                              AccessControlService.actionDelete, 
                                              isOwner: log.authorId == widget.currentUser['uid']))
                                            IconButton(
                                              icon: Icon(
                                                  Icons.delete_outline,
                                                  size: 20,
                                                  color:
                                                      Colors.red.shade400),
                                              onPressed: () =>
                                                _controller
                                                      .removeLog(realIndex),
                                              constraints:
                                                  const BoxConstraints(),
                                              padding:
                                                  const EdgeInsets.all(6),
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
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
        ],
      ),

      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                if (widget.currentUser['role'] == 'Ketua' || widget.currentUser['role'] == 'Anggota') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogEditorPage(
                        controller: _controller,
                        currentUser: widget.currentUser,
                      ),
                    ),
                  );
                } else {
                  _showAddLogDialog();
                }
              },
              backgroundColor: _black,
              foregroundColor: _accent,
              icon: const Icon(Icons.add),
              label: const Text("Tambah Catatan"),
              elevation: 4,
            ),
    );
  }
}

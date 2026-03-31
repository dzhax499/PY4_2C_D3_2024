import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logbook_app_071/features/logbook/models/log_model.dart';
import 'package:logbook_app_071/features/logbook/log_controller.dart';

class LogEditorPage extends StatefulWidget {
  final LogModel? log;
  final int? index;
  final LogController controller;
  final dynamic currentUser;

  const LogEditorPage({
    super.key,
    this.log,
    this.index,
    required this.controller,
    required this.currentUser,
  });

  @override
  State<LogEditorPage> createState() => _LogEditorPageState();
}

class _LogEditorPageState extends State<LogEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isPublic = false;
  String _category = 'Mechanical';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.log?.title ?? '');
    _descController = TextEditingController(
      text: widget.log?.description ?? '',
    );
    _isPublic = widget.log?.isPublic ?? false;
    _category = ['Mechanical', 'Electronic', 'Software'].contains(widget.log?.category)
        ? widget.log!.category
        : 'Mechanical';

    // Listener agar Pratinjau terupdate otomatis
    _descController.addListener(() {
      setState(() {});
    });
  }

  void _save() {
    if (widget.log == null) {
      // Tambah Baru
      widget.controller.addLog(
        _titleController.text,
        _descController.text,
        _category,
        widget.currentUser['uid'],
        widget.currentUser['teamId'],
        isPublic: _isPublic,
      );
    } else {
      // Update
      widget.controller.updateLog(
        widget.index!,
        _titleController.text,
        _descController.text,
        _category,
        isPublic: _isPublic,
      );
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Membersihkan controller agar tidak memory leak
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.log == null ? "Catatan Baru" : "Edit Catatan"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Editor"),
              Tab(text: "Pratinjau"),
            ],
          ),
          actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Editor
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Judul"),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Tulis laporan dengan format Markdown...\n# Heading 1\n* Italic *\n** Bold **\n- List\n1. Numbered List\n> Blockquote\n[Link](https://example.com)",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: ['Mechanical', 'Electronic', 'Software'].map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _category = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text("Buat Publik"),
                    subtitle: const Text("Bisa dilihat anggota tim lain"),
                    value: _isPublic,
                    activeColor: const Color(0xFFF5C400),
                    onChanged: (val) {
                      setState(() => _isPublic = val);
                    },
                  ),
                ],
              ),
            ),
            // Tab 2: Markdown Preview
            MarkdownBody(data: _descController.text),
          ],
        ),
      ),
    );
  }
}

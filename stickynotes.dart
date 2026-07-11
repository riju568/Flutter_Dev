import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NoteStore.instance.load();
  runApp(const StickyNotesApp());
}

class AppStyles {
  static const List<Color> stickyColors = [
    Color(0xFFFFF2AB),
    Color(0xFFFFB3BA),
    Color(0xFFFFDFBA),
    Color(0xFFBAFFC9),
    Color(0xFFBAE1FF),
    Color(0xFFE8BAFF),
  ];
}

class StickyNotesApp extends StatelessWidget {
  const StickyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
      home: const NotesGridScreen(),
    );
  }
}

class NotesGridScreen extends StatefulWidget {
  const NotesGridScreen({super.key});

  @override
  State<NotesGridScreen> createState() => _NotesGridScreenState();
}

class _NotesGridScreenState extends State<NotesGridScreen> {
  @override
  Widget build(BuildContext context) {
    final notes = NoteStore.instance.notes;

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: notes.isEmpty
          ? const Center(
              child: Text(
                'No sticky notes yet.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return StickyNoteCard(note: note);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditNoteScreen()),
          );
          if (mounted) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class NoteModel {
  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.colorIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final int colorIndex;
  final int createdAt;
  final int updatedAt;

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      colorIndex: json['colorIndex'] as int? ?? 0,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'colorIndex': colorIndex,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class NoteStore {
  NoteStore._();

  static final NoteStore instance = NoteStore._();

  final List<NoteModel> _notes = [];

  List<NoteModel> get notes => List.unmodifiable(_notes);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedNotes = prefs.getStringList('sticky_notes') ?? <String>[];
    _notes
      ..clear()
      ..addAll(
        storedNotes
            .map((entry) => NoteModel.fromJson(jsonDecode(entry)))
            .toList(),
      );
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('sticky_notes', encoded);
  }

  Future<void> addOrUpdate(NoteModel note) async {
    final existingIndex = _notes.indexWhere((item) => item.id == note.id);
    if (existingIndex >= 0) {
      _notes[existingIndex] = note;
    } else {
      _notes.insert(0, note);
    }
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await save();
  }

  Future<void> delete(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await save();
  }
}

class StickyNoteCard extends StatelessWidget {
  const StickyNoteCard({super.key, required this.note});

  final NoteModel note;

  double _getRotationAngle() {
    final int hash = note.id.hashCode;
    final double normalized = (hash % 100) / 100.0;
    return (normalized - 0.5) * 0.08;
  }

  @override
  Widget build(BuildContext context) {
    final noteColor =
        AppStyles.stickyColors[note.colorIndex % AppStyles.stickyColors.length];

    return Transform.rotate(
      angle: _getRotationAngle(),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditNoteScreen(note: note)),
          );
          if (context.mounted) {
            (context as Element).markNeedsBuild();
          }
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: noteColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(16),
                  topRight: Radius.circular(4),
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (note.title.isNotEmpty) ...[
                    Text(
                      note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Expanded(
                    child: Text(
                      note.content,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 45,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key, this.note});

  final NoteModel? note;

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _selectedColorIndex;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _selectedColorIndex = widget.note?.colorIndex ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now().millisecondsSinceEpoch;
    final note = NoteModel(
      id: widget.note?.id ?? now.toString(),
      title: title,
      content: content,
      colorIndex: _selectedColorIndex,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await NoteStore.instance.addOrUpdate(note);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save note: $e')));
      }
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note == null) return;

    await NoteStore.instance.delete(widget.note!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = AppStyles.stickyColors[_selectedColorIndex];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
            ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveNote,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppStyles.stickyColors.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppStyles.stickyColors[index],
                          border: Border.all(
                            color: isSelected
                                ? Colors.black54
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black38),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Jot something down...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black38),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

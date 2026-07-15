// note_card.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../notesApiServices/Notes/note_local.dart';
import '../../notesApiServices/Notes/note_sync_service.dart';
import 'action_button.dart';

class NoteCard extends StatefulWidget {
  final NoteLocal note;
  final VoidCallback onDelete;

  const NoteCard({super.key, required this.note, required this.onDelete});

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late final TextEditingController _headingController;
  late final TextEditingController _contentController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _headingController = TextEditingController(text: widget.note.title ?? '');
    _contentController = TextEditingController(text: widget.note.content ?? '');
  }

  void _saveNote() async {
    widget.note.title = _headingController.text.trim();
    widget.note.content = _contentController.text.trim();

    if (widget.note.title!.isEmpty && widget.note.content!.isEmpty) {
      _deleteNote();
      return;
    }

    widget.note.isDirty = true;
    widget.note.isSyncing = false;

    final box = Hive.box<NoteLocal>('noteBox');
    await box.put(widget.note.localId, widget.note);

    setState(() => _editing = false);

    // Explicitly sync this note object instead of all
    try {
      await NoteSyncService().syncSingle(widget.note);
      print("✅ Synced note: ${widget.note.title}");
    } catch (e) {
      print("⚠️ Note sync failed: $e");
    }
  }

  // void _saveNote() async {
  //   widget.note.title = _headingController.text;
  //   widget.note.content = _contentController.text;
  //
  //   if (_headingController.text.trim().isEmpty &&
  //       _contentController.text.trim().isEmpty) {
  //     _deleteNote();
  //     return;
  //   }
  //
  //   widget.note.isDirty = true;
  //   widget.note.isSyncing = false;
  //
  //   final box = Hive.box<NoteLocal>('noteBox');
  //   await box.put(widget.note.localId, widget.note);
  //
  //   setState(() => _editing = false);
  //
  //   // Trigger sync
  //   NoteSyncService().syncNow().catchError((e) {
  //     print("⚠️ Note sync failed: $e");
  //   });
  // }


  void _cancelEdit() {
    _headingController.text = widget.note.title ?? '';
    _contentController.text = widget.note.content ?? '';
    if (_headingController.text.isEmpty && _contentController.text.isEmpty) {
      _deleteNote();
    } else {
      setState(() => _editing = false);
    }
  }

  void _deleteNote() async {
    widget.note.isDeleted = true;
    widget.note.isDirty = true;
    widget.note.isSyncing = false;

    final box = Hive.box<NoteLocal>('noteBox');
    await box.put(widget.note.localId, widget.note);

    widget.onDelete(); // update UI

    // This will retry automatically next sync if offline
    NoteSyncService().syncNow().catchError((e) {
      print("⚠️ Note delete sync failed: $e");
    });
  }


  @override
  void dispose() {
    _headingController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 4,
      shadowColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _editing
                ? TextField(
              controller: _headingController,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Heading (optional)',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            )
                : (widget.note.title == null || widget.note.title!.isEmpty
                ? const SizedBox.shrink()
                : Text(widget.note.title!,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white))),
            const SizedBox(height: 8),
            _editing
                ? TextField(
              controller: _contentController,
              maxLines: null,
              style: const TextStyle(color: Colors.white70),
              decoration: const InputDecoration(
                hintText: 'Note content',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            )
                : (widget.note.content == null || widget.note.content!.isEmpty
                ? const Text('Tap pen to edit this note...',
                style: TextStyle(
                    color: Colors.white54, fontStyle: FontStyle.italic))
                : Text(widget.note.content!,
                style: const TextStyle(color: Colors.white70, height: 1.4))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _editing
                  ? [
                ActionButton(
                    icon: Icons.close,
                    color: Colors.redAccent,
                    onPressed: _cancelEdit),
                ActionButton(
                    icon: Icons.save,
                    color: Colors.greenAccent,
                    onPressed: _saveNote),
              ]
                  : [
                ActionButton(
                    icon: Icons.edit,
                    color: Colors.blueAccent,
                    onPressed: () => setState(() => _editing = true)),
                ActionButton(
                    icon: Icons.delete,
                    color: Colors.redAccent,
                    onPressed: _deleteNote),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


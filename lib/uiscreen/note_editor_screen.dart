import 'package:aplikasi_buku_yni/helper/db_helper.dart';
import 'package:aplikasi_buku_yni/model/model_note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteEditor extends StatefulWidget {
  final Note? note;
  const NoteEditor({super.key, this.note});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  void saveNote() async {
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final note = Note(
      id: widget.note?.id,
      title: _titleController.text,
      content: _contentController.text,
      date: now,
    );

    if (widget.note == null) {
      await DatabaseHelper.instance.insertNote(note);
    } else {
      await DatabaseHelper.instance.updateNote(note);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catatan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(hintText: "Judul")),
            const SizedBox(height: 10),
            Expanded(child: TextField(controller: _contentController, maxLines: null, expands: true, decoration: const InputDecoration(hintText: "Isi catatan"))),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: saveNote, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
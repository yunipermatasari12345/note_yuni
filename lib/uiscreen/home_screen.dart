import 'package:aplikasi_buku_yni/helper/db_helper.dart';
import 'package:aplikasi_buku_yni/model/model_note.dart';
import 'package:aplikasi_buku_yni/uiscreen/note_editor_screen.dart';
import 'package:aplikasi_buku_yni/widget/note_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  void fetchNotes() async {
    final data = await DatabaseHelper.instance.getNotes();
    setState(() => notes = data);
  }

  void onSearch(String value) {
    setState(() => searchQuery = value.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes.where((note) {
      return note.title.toLowerCase().contains(searchQuery) ||
          note.content.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Yuni'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(context: context, delegate: NoteSearch(notes));
              if (result != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NoteEditor(note: result)),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: filteredNotes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (context, index) => NoteCard(
            note: filteredNotes[index],
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteEditor(note: filteredNotes[index])),
              );
              fetchNotes();
            },
            onDelete: () async {
              await DatabaseHelper.instance.deleteNote(filteredNotes[index].id!);
              fetchNotes();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const NoteEditor()));
          fetchNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteSearch extends SearchDelegate<Note?> {
  final List<Note> notes;
  NoteSearch(this.notes);

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));
  @override
  Widget buildResults(BuildContext context) {
    final result = notes.firstWhere((note) =>
    note.title.toLowerCase().contains(query.toLowerCase()) ||
        note.content.toLowerCase().contains(query.toLowerCase()), orElse: () => Note(id: -1, title: '', content: '', date: ''));
    return result.id == -1 ? const Center(child: Text("Tidak ditemukan")) : ListTile(title: Text(result.title), onTap: () => close(context, result));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = notes.where((note) =>
    note.title.toLowerCase().contains(query.toLowerCase()) ||
        note.content.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestions[index].title),
        onTap: () => close(context, suggestions[index]),
      ),
    );
  }
}
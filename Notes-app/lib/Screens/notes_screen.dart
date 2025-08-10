import 'package:flutter/material.dart';
import '../Database/notes_database.dart';
import 'notes_card.dart';
import 'notes_dialogue.dart';

class NotesScreenState extends StatefulWidget {
  const NotesScreenState({super.key});

  @override
  State<NotesScreenState> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreenState> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final data = await NotesDatabase.instance.getNotes(); // ✅ fixed
    setState(() {
      _notes = data;
    });
  }

  void _deleteNote(int id) async {
    await NotesDatabase.instance.deleteNote(id); // ✅ fixed
    _loadNotes();
  }

  void _openNoteEditor({Map<String, dynamic>? note}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDialogue(
          noteid: note?['id'],
          title: note?['title'],
          content: note?['description'], // ✅ match DB column name
          onSave: (title, description) async {
            if (note == null) {
              await NotesDatabase.instance.addNote(
                title,
                description,
                DateTime.now().toIso8601String(),
                0, // default color
              );
            } else {
              await NotesDatabase.instance.updateNote(
                note['id'],
                title,
                description,
                note['date'],
                note['color'],
              );
            }
            _loadNotes();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      body: _notes.isEmpty
          ? const Center(child: Text("No notes yet"))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return NoteCard(
                  note: note,
                  onDelete: () => _deleteNote(note['id']),
                  onTap: () => _openNoteEditor(note: note),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

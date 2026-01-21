import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../widgets/note_item.dart';
import 'login_screen.dart';
import 'note_form_dialog.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _db = DatabaseHelper.instance;

  final _addController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<Note> _notes = const [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final notes = await _db.getNotes();
      if (!mounted) return;
      setState(() {
        _notes = notes;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (e is UnsupportedError) {
          _error = e.message;
        } else {
          _error = "Erreur lors du chargement des notes.";
        }
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _addNote() async {
    final value = _addController.text.trim();
    if (value.isEmpty) return;
    _addController.clear();

    try {
      await _db.insertNote(Note(contenu: value));
      await _loadNotes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'ajout.")),
      );
    }
  }

  Future<void> _editNote(Note note) async {
    final value = await showDialog<String?>(
      context: context,
      builder: (_) => NoteFormDialog(
        title: 'Modifier la note',
        initialValue: note.contenu,
      ),
    );

    if (value == null) return;

    try {
      await _db.updateNote(note.copyWith(contenu: value));
      await _loadNotes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la modification.')),
      );
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Suppression'),
        content: const Text('Voulez-vous supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final id = note.id;
    if (id == null) return;

    try {
      await _db.deleteNote(id);
      await _loadNotes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To do list'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addController,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter une note',
                        border: UnderlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addNote(),
                    ),
                  ),
                  IconButton(
                    onPressed: _addNote,
                    icon: const Icon(Icons.add),
                    tooltip: 'Ajouter',
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _notes.isEmpty
                          ? const Center(
                              child: Text('Aucune note pour le moment.'),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadNotes,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 6, 12, 12),
                                itemCount: _notes.length,
                                itemBuilder: (context, index) {
                                  final note = _notes[index];
                                  return NoteItem(
                                    note: note,
                                    onEdit: () => _editNote(note),
                                    onDelete: () => _deleteNote(note),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

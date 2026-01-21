import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'notes.db';
  static const _databaseVersion = 1;

  static const tableNotes = 'notes';
  static const _webNotesKey = 'notes_web_storage';

  Database? _database;

  Future<Database> get database async {
    final db = _database;
    if (db != null) return db;

    _database = await initDatabase();
    return _database!;
  }

  Future<List<Note>> _getNotesWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_webNotesKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .map((m) => Note.fromMap(m))
        .toList();
  }

  Future<void> _saveNotesWeb(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notes.map((n) => n.toMap()).toList());
    await prefs.setString(_webNotesKey, encoded);
  }

  int _nextWebId(List<Note> notes) {
    var maxId = 0;
    for (final n in notes) {
      final id = n.id ?? 0;
      if (id > maxId) maxId = id;
    }
    return maxId + 1;
  }

  Future<Database> initDatabase() async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('SQLite non utilisé sur le Web');
      }

      final directory = await getApplicationDocumentsDirectory();
      final dbPath = '${directory.path}${Platform.pathSeparator}$_databaseName';

      return await openDatabase(
        dbPath,
        version: _databaseVersion,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE $tableNotes('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'contenu TEXT'
            ')',
          );
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> insertNote(Note note) async {
    try {
      if (kIsWeb) {
        final notes = await _getNotesWeb();
        final newId = _nextWebId(notes);
        final updated = [note.copyWith(id: newId), ...notes];
        await _saveNotesWeb(updated);
        return newId;
      }

      final db = await database;
      return await db.insert(
        tableNotes,
        note.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Note>> getNotes() async {
    try {
      if (kIsWeb) {
        return await _getNotesWeb();
      }

      final db = await database;
      final maps = await db.query(tableNotes, orderBy: 'id DESC');
      return maps.map(Note.fromMap).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateNote(Note note) async {
    try {
      final id = note.id;
      if (id == null) {
        throw StateError('Impossible de mettre à jour une note sans id');
      }

      if (kIsWeb) {
        final notes = await _getNotesWeb();
        final idx = notes.indexWhere((n) => n.id == id);
        if (idx == -1) return 0;
        final updated = [...notes];
        updated[idx] = note;
        await _saveNotesWeb(updated);
        return 1;
      }

      final db = await database;
      return await db.update(
        tableNotes,
        note.toMap()..remove('id'),
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteNote(int id) async {
    try {
      if (kIsWeb) {
        final notes = await _getNotesWeb();
        final before = notes.length;
        final updated = notes.where((n) => n.id != id).toList();
        await _saveNotesWeb(updated);
        return before - updated.length;
      }

      final db = await database;
      return await db.delete(
        tableNotes,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }
}

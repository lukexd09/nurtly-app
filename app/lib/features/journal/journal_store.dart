import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'journal_entry.dart';

abstract interface class JournalStore {
  Future<List<JournalEntry>> loadEntries();

  Future<void> saveEntries(List<JournalEntry> entries);

  Future<void> deleteAllEntries();
}

class SharedPreferencesJournalStore implements JournalStore {
  const SharedPreferencesJournalStore();

  static const String key = 'nurtly_journal_entries_v1';

  @override
  Future<List<JournalEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return const <JournalEntry>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <JournalEntry>[];
    }

    final entries = decoded
        .whereType<Map>()
        .map((item) => JournalEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
    final activeEntries =
        entries.where((entry) => !entry.isDeleted).toList(growable: false);
    if (activeEntries.length != entries.length) {
      final payload =
          jsonEncode(activeEntries.map((entry) => entry.toJson()).toList());
      final success = await prefs.setString(key, payload);
      if (!success) {
        throw StateError('journal write failed');
      }
    }
    return activeEntries;
  }

  @override
  Future<void> saveEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    final success = await prefs.setString(key, payload);
    if (!success) {
      throw StateError('journal write failed');
    }
  }

  @override
  Future<void> deleteAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.remove(key);
    if (!success) {
      throw StateError('journal delete failed');
    }
  }
}

class InMemoryJournalStore implements JournalStore {
  InMemoryJournalStore({
    List<JournalEntry>? entries,
    this.failOnSave = false,
    this.failOnDelete = false,
  }) : _entries = List<JournalEntry>.from(entries ?? const <JournalEntry>[]);

  List<JournalEntry> _entries;
  final bool failOnSave;
  final bool failOnDelete;
  int loadCalls = 0;
  int saveCalls = 0;

  @override
  Future<List<JournalEntry>> loadEntries() async {
    loadCalls++;
    return List<JournalEntry>.from(_entries);
  }

  @override
  Future<void> saveEntries(List<JournalEntry> entries) async {
    saveCalls++;
    if (failOnSave) {
      throw StateError('save failed');
    }
    _entries = List<JournalEntry>.from(entries);
  }

  @override
  Future<void> deleteAllEntries() async {
    saveCalls++;
    if (failOnDelete) {
      throw StateError('delete failed');
    }
    _entries = <JournalEntry>[];
  }

  List<JournalEntry> get entries => List<JournalEntry>.unmodifiable(_entries);
}

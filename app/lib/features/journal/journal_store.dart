import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'journal_entry.dart';

abstract interface class JournalStore {
  Future<List<JournalEntry>> loadEntries();

  Future<void> saveEntries(List<JournalEntry> entries);
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

    return decoded
        .whereType<Map>()
        .map((item) => JournalEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> saveEntries(List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    await prefs.setString(key, payload);
  }
}

class InMemoryJournalStore implements JournalStore {
  InMemoryJournalStore({
    List<JournalEntry>? entries,
  }) : _entries = List<JournalEntry>.from(entries ?? const <JournalEntry>[]);

  List<JournalEntry> _entries;
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
    _entries = List<JournalEntry>.from(entries);
  }

  List<JournalEntry> get entries => List<JournalEntry>.unmodifiable(_entries);
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'journal_entry.dart';
import 'journal_entry_type.dart';
import 'journal_store.dart';
import 'journal_summary.dart';

class JournalController extends ChangeNotifier {
  JournalController({
    required JournalStore store,
    DateTime Function()? now,
  })  : _store = store,
        _now = now ?? DateTime.now;

  final JournalStore _store;
  final DateTime Function() _now;

  final List<JournalEntry> _entries = [];
  bool _hasLoaded = false;
  DateTime _selectedDay = DateTime.now();
  Future<void>? _deleteAllEntriesFuture;

  bool get hasLoaded => _hasLoaded;

  DateTime get selectedDay =>
      DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

  List<JournalEntry> get entries {
    final day = selectedDay;
    return _entries
        .where(
            (entry) => !entry.isDeleted && _isSameDay(entry.effectiveAt, day))
        .toList()
      ..sort((a, b) => _sortKey(b).compareTo(_sortKey(a)));
  }

  JournalEntry? get activeSleep {
    final nowActive = _entries
        .where((entry) =>
            entry.type == JournalEntryType.sleep &&
            entry.isActiveSleep &&
            !entry.isDeleted)
        .toList();
    if (nowActive.isEmpty) {
      return null;
    }
    nowActive.sort((a, b) => a.startAt!.compareTo(b.startAt!));
    return nowActive.last;
  }

  JournalSummary get summary =>
      JournalSummary.fromEntries(_entries, selectedDay, now: _now());

  Future<void> load() async {
    try {
      _entries
        ..clear()
        ..addAll(await _store.loadEntries());
    } catch (_) {
      _entries.clear();
    }
    _selectedDay = DateTime(_now().year, _now().month, _now().day);
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    _entries.add(entry);
    await _persist();
  }

  Future<void> updateEntry(JournalEntry updated) async {
    final index = _entries.indexWhere((entry) => entry.id == updated.id);
    if (index == -1) {
      return;
    }
    _entries[index] = updated.copyWith(updatedAt: _now());
    await _persist();
  }

  Future<void> deleteEntry(String id) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return;
    }
    final removed = _entries.removeAt(index);
    notifyListeners();
    try {
      await _store.saveEntries(_entries);
    } catch (_) {
      _entries.insert(index, removed);
      notifyListeners();
    }
  }

  Future<bool> startSleep({
    String? note,
    String? childId,
  }) async {
    if (activeSleep != null) {
      return false;
    }
    final startAt = _now();
    _entries.add(
      JournalEntry.sleep(
        id: _newId(),
        startAt: startAt,
        note: note,
        childId: childId,
      ),
    );
    await _persist();
    return true;
  }

  Future<bool> stopSleep() async {
    final active = activeSleep;
    if (active == null) {
      return false;
    }
    final now = _now();
    if (!now.isAfter(active.startAt!)) {
      return false;
    }
    final index = _entries.indexWhere((entry) => entry.id == active.id);
    if (index == -1) {
      return false;
    }
    _entries[index] = active.copyWith(
      endAt: now,
      updatedAt: now,
    );
    await _persist();
    return true;
  }

  void goToToday() {
    _selectedDay = DateTime(_now().year, _now().month, _now().day);
    notifyListeners();
  }

  void goToPreviousDay() {
    _selectedDay = selectedDay.subtract(const Duration(days: 1));
    notifyListeners();
  }

  void goToNextDay() {
    _selectedDay = selectedDay.add(const Duration(days: 1));
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = DateTime(day.year, day.month, day.day);
    notifyListeners();
  }

  Future<void> replaceAll(List<JournalEntry> entries) async {
    _entries
      ..clear()
      ..addAll(entries);
    await _persist();
  }

  Future<void> deleteAllEntries() {
    return _deleteAllEntriesFuture ??=
        _deleteAllEntries().whenComplete(() => _deleteAllEntriesFuture = null);
  }

  Future<void> _deleteAllEntries() async {
    await _store.deleteAllEntries();
    _entries.clear();
    _selectedDay = DateTime(_now().year, _now().month, _now().day);
    notifyListeners();
  }

  Future<void> _persist() async {
    notifyListeners();
    try {
      await _store.saveEntries(_entries);
    } catch (_) {}
  }

  int _sortKey(JournalEntry entry) {
    return _sortDate(entry).microsecondsSinceEpoch;
  }

  DateTime _sortDate(JournalEntry entry) {
    return entry.effectiveAt;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _newId() {
    return 'journal_${_now().microsecondsSinceEpoch}_${_entries.length}';
  }
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/features/journal/journal_controller.dart';
import 'package:nurtly/features/journal/journal_entry.dart';
import 'package:nurtly/features/journal/journal_entry_type.dart';
import 'package:nurtly/features/journal/journal_store.dart';

void main() {
  test('controller adds, edits, deletes and summarizes journal entries',
      () async {
    final store = InMemoryJournalStore();
    final controller = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 9, 30),
    );
    await controller.load();

    await controller.addEntry(
      JournalEntry.note(
        id: 'note-1',
        eventAt: DateTime(2026, 5, 19, 9, 30),
        note: 'Morning note',
      ),
    );
    await controller.addEntry(
      JournalEntry.feeding(
        id: 'feeding-1',
        eventAt: DateTime(2026, 5, 19, 10, 0),
        feedingType: JournalFeedingType.food,
      ),
    );
    await controller.addEntry(
      JournalEntry.diaper(
        id: 'diaper-1',
        eventAt: DateTime(2026, 5, 19, 10, 30),
        diaperType: JournalDiaperType.dry,
      ),
    );
    await controller.addEntry(
      JournalEntry.sleep(
        id: 'sleep-1',
        startAt: DateTime(2026, 5, 19, 7, 0),
        endAt: DateTime(2026, 5, 19, 8, 15),
      ),
    );

    expect(controller.entries, hasLength(4));
    expect(controller.summary.notesCount, 1);
    expect(controller.summary.feedingsCount, 1);
    expect(controller.summary.diapersCount, 1);
    expect(
        controller.summary.totalSleep, const Duration(hours: 1, minutes: 15));

    final updatedNote = controller.entries
        .firstWhere((entry) => entry.id == 'note-1')
        .copyWith(note: 'Morning note updated');
    await controller.updateEntry(updatedNote);
    expect(
      controller.entries.firstWhere((entry) => entry.id == 'note-1').note,
      'Morning note updated',
    );

    await controller.deleteEntry('diaper-1');
    expect(controller.entries.any((entry) => entry.id == 'diaper-1'), isFalse);
  });

  test('controller filters entries by selected day', () async {
    final controller = JournalController(
      store: InMemoryJournalStore(
        entries: [
          JournalEntry.note(
            id: 'yesterday',
            eventAt: DateTime(2026, 5, 18, 18, 0),
            note: 'Yesterday note',
          ),
          JournalEntry.note(
            id: 'today',
            eventAt: DateTime(2026, 5, 19, 8, 0),
            note: 'Today note',
          ),
        ],
      ),
      now: () => DateTime(2026, 5, 19, 9, 30),
    );
    await controller.load();

    expect(controller.entries, hasLength(1));
    expect(controller.entries.single.id, 'today');

    controller.goToPreviousDay();
    expect(controller.entries, hasLength(1));
    expect(controller.entries.single.id, 'yesterday');

    controller.goToToday();
    expect(controller.entries.single.id, 'today');
  });

  test('controller selectDay normalizes to date-only and notifies listeners',
      () async {
    var notifyCount = 0;
    final controller = JournalController(
      store: InMemoryJournalStore(),
      now: () => DateTime(2026, 5, 19, 9, 30),
    );
    controller.addListener(() {
      notifyCount++;
    });
    await controller.load();

    controller.selectDay(DateTime(2026, 5, 26, 14, 7));

    expect(controller.selectedDay, DateTime(2026, 5, 26));
    expect(controller.selectedDay.hour, 0);
    expect(controller.selectedDay.minute, 0);
    expect(notifyCount, greaterThan(0));
  });

  test('controller edits sleep entries without changing their type', () async {
    final controller = JournalController(
      store: InMemoryJournalStore(
        entries: [
          JournalEntry.sleep(
            id: 'sleep-1',
            startAt: DateTime(2026, 5, 19, 7, 0),
            endAt: DateTime(2026, 5, 19, 8, 15),
            note: 'Morning nap',
          ),
        ],
      ),
      now: () => DateTime(2026, 5, 19, 9, 30),
    );
    await controller.load();

    final updated = controller.entries.single.copyWith(
      note: 'Morning nap updated',
      endAt: DateTime(2026, 5, 19, 8, 25),
    );
    await controller.updateEntry(updated);

    final entry = controller.entries.single;
    expect(entry.type, JournalEntryType.sleep);
    expect(entry.note, 'Morning nap updated');
    expect(entry.endAt, DateTime(2026, 5, 19, 8, 25));
  });

  test('controller edits feeding entries without changing their type',
      () async {
    final controller = JournalController(
      store: InMemoryJournalStore(
        entries: [
          JournalEntry.feeding(
            id: 'feeding-1',
            eventAt: DateTime(2026, 5, 19, 10, 0),
            feedingType: JournalFeedingType.bottle,
            amountText: '180 ml',
            note: 'After the walk',
          ),
        ],
      ),
      now: () => DateTime(2026, 5, 19, 10, 30),
    );
    await controller.load();

    final updated = controller.entries.single.copyWith(
      amountText: '200 ml',
      note: 'After the walk updated',
    );
    await controller.updateEntry(updated);

    final entry = controller.entries.single;
    expect(entry.type, JournalEntryType.feeding);
    expect(entry.feedingType, JournalFeedingType.bottle);
    expect(entry.amountText, '200 ml');
    expect(entry.note, 'After the walk updated');
  });

  test('controller edits diaper entries without changing their type', () async {
    final controller = JournalController(
      store: InMemoryJournalStore(
        entries: [
          JournalEntry.diaper(
            id: 'diaper-1',
            eventAt: DateTime(2026, 5, 19, 11, 0),
            diaperType: JournalDiaperType.both,
            note: 'Changed quickly',
          ),
        ],
      ),
      now: () => DateTime(2026, 5, 19, 11, 30),
    );
    await controller.load();

    final updated = controller.entries.single.copyWith(
      note: 'Changed quickly updated',
    );
    await controller.updateEntry(updated);

    final entry = controller.entries.single;
    expect(entry.type, JournalEntryType.diaper);
    expect(entry.diaperType, JournalDiaperType.both);
    expect(entry.note, 'Changed quickly updated');
  });

  test('controller edits note entries without changing their type', () async {
    final controller = JournalController(
      store: InMemoryJournalStore(
        entries: [
          JournalEntry.note(
            id: 'note-1',
            eventAt: DateTime(2026, 5, 19, 12, 0),
            note: 'A quiet evening.',
          ),
        ],
      ),
      now: () => DateTime(2026, 5, 19, 12, 30),
    );
    await controller.load();

    final updated = controller.entries.single.copyWith(
      note: 'A quiet evening updated.',
    );
    await controller.updateEntry(updated);

    final entry = controller.entries.single;
    expect(entry.type, JournalEntryType.note);
    expect(entry.note, 'A quiet evening updated.');
  });

  test('controller deletes sleep feeding diaper and note entries', () async {
    final controller = JournalController(
      store: InMemoryJournalStore(
        entries: [
          JournalEntry.sleep(
            id: 'sleep-1',
            startAt: DateTime(2026, 5, 19, 7, 0),
            endAt: DateTime(2026, 5, 19, 8, 15),
          ),
          JournalEntry.feeding(
            id: 'feeding-1',
            eventAt: DateTime(2026, 5, 19, 10, 0),
            feedingType: JournalFeedingType.bottle,
          ),
          JournalEntry.diaper(
            id: 'diaper-1',
            eventAt: DateTime(2026, 5, 19, 11, 0),
            diaperType: JournalDiaperType.pee,
          ),
          JournalEntry.note(
            id: 'note-1',
            eventAt: DateTime(2026, 5, 19, 12, 0),
            note: 'A quiet evening.',
          ),
        ],
      ),
      now: () => DateTime(2026, 5, 19, 12, 30),
    );
    await controller.load();

    await controller.deleteEntry('sleep-1');
    await controller.deleteEntry('feeding-1');
    await controller.deleteEntry('diaper-1');
    await controller.deleteEntry('note-1');

    expect(controller.entries, isEmpty);
  });

  test('individual deletion physically removes the entry and its note',
      () async {
    final store = InMemoryJournalStore(
      entries: [
        JournalEntry.note(
          id: 'note-1',
          eventAt: DateTime(2026, 5, 19, 12, 0),
          note: 'Remove this private note',
        ),
        JournalEntry.note(
          id: 'note-2',
          eventAt: DateTime(2026, 5, 19, 13, 0),
          note: 'Keep this note',
        ),
      ],
    );
    final controller = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 14),
    );
    await controller.load();

    await controller.deleteEntry('note-1');

    expect(controller.entries.map((entry) => entry.id), ['note-2']);
    expect(store.entries.map((entry) => entry.id), ['note-2']);
    expect(
      store.entries.any((entry) => entry.note == 'Remove this private note'),
      isFalse,
    );
    expect(store.entries.any((entry) => entry.isDeleted), isFalse);
  });

  test('unknown and repeated individual deletion are safe', () async {
    final store = InMemoryJournalStore(
      entries: [
        JournalEntry.note(
          id: 'note-1',
          eventAt: DateTime(2026, 5, 19, 12),
          note: 'A note',
        ),
      ],
    );
    final controller = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 14),
    );
    await controller.load();

    await controller.deleteEntry('unknown');
    await controller.deleteEntry('note-1');
    await controller.deleteEntry('note-1');

    expect(controller.entries, isEmpty);
    expect(store.entries, isEmpty);
  });

  test('delete all clears loaded journal state and is safe to repeat',
      () async {
    final store = InMemoryJournalStore(
      entries: [
        JournalEntry.sleep(
          id: 'sleep-1',
          startAt: DateTime(2026, 5, 18, 22),
        ),
        JournalEntry.note(
          id: 'note-1',
          eventAt: DateTime(2026, 5, 19, 12),
          note: 'Remove this note',
        ),
      ],
    );
    final controller = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 14),
    );
    await controller.load();

    await controller.deleteAllEntries();

    expect(controller.hasLoaded, isTrue);
    expect(controller.entries, isEmpty);
    expect(controller.activeSleep, isNull);
    expect(controller.summary.notesCount, 0);
    expect(controller.summary.totalSleep, Duration.zero);
    expect(store.entries, isEmpty);

    await controller.deleteAllEntries();
    expect(store.entries, isEmpty);
  });

  test('delete all ignores an in-flight stale load', () async {
    final store = _DelayedLoadJournalStore(
      initialEntries: [
        JournalEntry.note(
          id: 'note-1',
          eventAt: DateTime(2026, 5, 19, 12),
          note: 'Stale note',
        ),
      ],
    );
    final controller = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 14),
    );

    await controller.load();
    expect(controller.entries, hasLength(1));

    final staleReload = controller.load();
    await controller.deleteAllEntries();
    await store.releaseStaleLoad();
    await staleReload;

    expect(controller.entries, isEmpty);
    expect(controller.summary.notesCount, 0);
    expect(store.entries, isEmpty);
  });

  test('concurrent delete all requests share the same deletion', () async {
    final store = InMemoryJournalStore(
      entries: [
        JournalEntry.note(
          id: 'note-1',
          eventAt: DateTime(2026, 5, 19, 12),
          note: 'Remove this note',
        ),
      ],
    );
    final controller = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 14),
    );
    await controller.load();

    await Future.wait([
      controller.deleteAllEntries(),
      controller.deleteAllEntries(),
    ]);

    expect(store.saveCalls, 1);
    expect(controller.entries, isEmpty);
  });

  test('deleting an active sleep removes active sleep state', () async {
    final store = InMemoryJournalStore(
      entries: [
        JournalEntry.sleep(
          id: 'sleep-1',
          startAt: DateTime(2026, 5, 19, 12),
        ),
      ],
    );
    final controller = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 14),
    );
    await controller.load();
    expect(controller.activeSleep, isNotNull);

    await controller.deleteEntry('sleep-1');

    expect(controller.activeSleep, isNull);
    expect(controller.summary.totalSleep, Duration.zero);
    expect(store.entries, isEmpty);
  });

  test('individual deletion restores active state when persistence fails',
      () async {
    final store = InMemoryJournalStore(
      entries: [
        JournalEntry.note(
          id: 'note-1',
          eventAt: DateTime(2026, 5, 19, 12),
          note: 'Keep after failed delete',
        ),
      ],
      failOnSave: true,
    );
    final controller = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 14),
    );
    await controller.load();

    await controller.deleteEntry('note-1');

    expect(controller.entries.single.note, 'Keep after failed delete');
    expect(store.entries.single.note, 'Keep after failed delete');
  });

  test('controller prevents duplicate active sleep and supports stop flow',
      () async {
    var currentTime = DateTime(2026, 5, 19, 9, 30);
    final controller = JournalController(
      store: InMemoryJournalStore(),
      now: () => currentTime,
    );
    await controller.load();

    expect(await controller.startSleep(), isTrue);
    expect(await controller.startSleep(), isFalse);
    expect(controller.activeSleep, isNotNull);
    currentTime = currentTime.add(const Duration(minutes: 30));
    expect(await controller.stopSleep(), isTrue);
    expect(controller.activeSleep, isNull);
    expect(controller.entries.single.endAt, DateTime(2026, 5, 19, 10, 0));
  });
}

class _DelayedLoadJournalStore implements JournalStore {
  _DelayedLoadJournalStore({
    required List<JournalEntry> initialEntries,
  }) : _initialEntries = List<JournalEntry>.from(initialEntries);

  final List<JournalEntry> _initialEntries;
  List<JournalEntry> _entries = <JournalEntry>[];
  var _loadCount = 0;
  Completer<List<JournalEntry>>? _staleLoadCompleter;

  List<JournalEntry> get entries => List<JournalEntry>.unmodifiable(_entries);

  Future<void> releaseStaleLoad() async {
    _staleLoadCompleter?.complete(List<JournalEntry>.from(_initialEntries));
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<List<JournalEntry>> loadEntries() {
    _loadCount++;
    if (_loadCount == 1) {
      return Future<List<JournalEntry>>.value(
        List<JournalEntry>.from(_initialEntries),
      );
    }
    _staleLoadCompleter = Completer<List<JournalEntry>>();
    return _staleLoadCompleter!.future;
  }

  @override
  Future<void> saveEntries(List<JournalEntry> entries) async {
    _entries = List<JournalEntry>.from(entries);
  }

  @override
  Future<void> deleteAllEntries() async {
    _entries = <JournalEntry>[];
  }
}

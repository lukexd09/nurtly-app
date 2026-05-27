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

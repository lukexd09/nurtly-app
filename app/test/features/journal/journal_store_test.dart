import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/features/journal/journal_controller.dart';
import 'package:nurtly/features/journal/journal_entry.dart';
import 'package:nurtly/features/journal/journal_entry_type.dart';
import 'package:nurtly/features/journal/journal_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shared preferences store saves and loads entries', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = SharedPreferencesJournalStore();
    final entry = JournalEntry.note(
      id: 'note-1',
      eventAt: DateTime(2026, 5, 19, 8, 0),
      note: 'Breakfast note',
    );

    await store.saveEntries([entry]);
    final loaded = await store.loadEntries();

    expect(loaded, hasLength(1));
    expect(loaded.single.note, 'Breakfast note');
    expect(loaded.single.type, JournalEntryType.note);
  });

  test('shared preferences store handles empty data', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = SharedPreferencesJournalStore();

    final loaded = await store.loadEntries();

    expect(loaded, isEmpty);
  });

  test(
    'shared preferences payload no longer contains a deleted note',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = SharedPreferencesJournalStore();
      final controller = JournalController(
        store: store,
        now: () => DateTime(2026, 5, 19, 14),
      );
      await controller.load();
      await controller.addEntry(
        JournalEntry.note(
          id: 'note-1',
          eventAt: DateTime(2026, 5, 19, 12),
          note: 'Private note to remove',
        ),
      );

      await controller.deleteEntry('note-1');

      final prefs = await SharedPreferences.getInstance();
      final payload = prefs.getString(SharedPreferencesJournalStore.key);
      expect(payload, '[]');
      expect(payload, isNot(contains('Private note to remove')));
      expect((await store.loadEntries()), isEmpty);
    },
  );

  test('in-memory store keeps active sleep state in saved entries', () async {
    final store = InMemoryJournalStore();
    final controller = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 9, 0),
    );
    await controller.load();

    final started = await controller.startSleep();
    expect(started, isTrue);
    expect(store.entries, hasLength(1));
    expect(store.entries.single.isActiveSleep, isTrue);

    final reloadedController = JournalController(
      store: store,
      now: () => DateTime(2026, 5, 19, 9, 15),
    );
    await reloadedController.load();
    expect(reloadedController.activeSleep, isNotNull);

    final stopped = await reloadedController.stopSleep();
    expect(stopped, isTrue);
    expect(reloadedController.activeSleep, isNull);
    expect(
      reloadedController.entries.single.endAt,
      DateTime(2026, 5, 19, 9, 15),
    );
  });
}

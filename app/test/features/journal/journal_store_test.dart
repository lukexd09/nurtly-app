import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/features/journal/journal_controller.dart';
import 'package:nurtly/features/journal/journal_entry.dart';
import 'package:nurtly/features/journal/journal_entry_type.dart';
import 'package:nurtly/features/journal/journal_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_fakes/fake_shared_preferences_store_platform.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

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
    'shared preferences migration removes legacy deleted entries',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        SharedPreferencesJournalStore.key: '''
[
  {
    "id": "active-1",
    "type": "note",
    "createdAt": "2026-05-19T08:00:00.000",
    "updatedAt": "2026-05-19T08:00:00.000",
    "eventAt": "2026-05-19T08:00:00.000",
    "note": "Keep this note",
    "isDeleted": false
  },
  {
    "id": "deleted-1",
    "type": "note",
    "createdAt": "2026-05-19T09:00:00.000",
    "updatedAt": "2026-05-19T09:00:00.000",
    "eventAt": "2026-05-19T09:00:00.000",
    "note": "Private note to remove",
    "isDeleted": true
  }
]
''',
      });
      final store = SharedPreferencesJournalStore();

      final loaded = await store.loadEntries();
      expect(loaded, hasLength(1));
      expect(loaded.single.id, 'active-1');
      expect(loaded.single.note, 'Keep this note');
      expect(loaded.single.isDeleted, isFalse);

      final controller = JournalController(
        store: store,
        now: () => DateTime(2026, 5, 19, 14),
      );
      await controller.load();
      expect(controller.entries, hasLength(1));
      expect(controller.entries.single.id, 'active-1');

      final prefs = await SharedPreferences.getInstance();
      final payload = prefs.getString(SharedPreferencesJournalStore.key);
      expect(payload, isNotNull);
      expect(payload!, isNot(contains('deleted-1')));
      expect(payload, isNot(contains('Private note to remove')));
      expect(payload, contains('active-1'));
      expect(await store.loadEntries(), hasLength(1));
    },
  );

  test('shared preferences write failures surface as errors', () async {
    final previous = SharedPreferencesStorePlatform.instance;
    final platform = FakeSharedPreferencesStorePlatform(
      falseOnSetKeys: {SharedPreferencesJournalStore.key},
    );
    SharedPreferencesStorePlatform.instance = platform;
    addTearDown(() => SharedPreferencesStorePlatform.instance = previous);
    final store = SharedPreferencesJournalStore();

    await expectLater(
      store.saveEntries(
        [
          JournalEntry.note(
            id: 'note-1',
            eventAt: DateTime(2026, 5, 19, 8, 0),
            note: 'Breakfast note',
          ),
        ],
      ),
      throwsStateError,
    );
  });

  test('shared preferences delete failures surface as errors', () async {
    final previous = SharedPreferencesStorePlatform.instance;
    final platform = FakeSharedPreferencesStorePlatform(
      falseOnRemoveKeys: {SharedPreferencesJournalStore.key},
    );
    SharedPreferencesStorePlatform.instance = platform;
    addTearDown(() => SharedPreferencesStorePlatform.instance = previous);
    final store = SharedPreferencesJournalStore();

    await expectLater(store.deleteAllEntries(), throwsStateError);
  });

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

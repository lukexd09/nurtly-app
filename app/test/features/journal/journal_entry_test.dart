import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/features/journal/journal_entry.dart';
import 'package:nurtly/features/journal/journal_entry_type.dart';

void main() {
  test('sleep entry roundtrips through JSON', () {
    final entry = JournalEntry.sleep(
      id: 'sleep-1',
      startAt: DateTime(2026, 5, 19, 8, 0),
      endAt: DateTime(2026, 5, 19, 9, 15),
      note: 'Morning nap',
      createdAt: DateTime(2026, 5, 19, 8, 0),
      updatedAt: DateTime(2026, 5, 19, 9, 15),
      childId: 'default-child',
    );

    final roundTrip = JournalEntry.fromJson(entry.toJson());

    expect(roundTrip.id, entry.id);
    expect(roundTrip.type, JournalEntryType.sleep);
    expect(roundTrip.startAt, entry.startAt);
    expect(roundTrip.endAt, entry.endAt);
    expect(roundTrip.note, 'Morning nap');
    expect(roundTrip.childId, 'default-child');
    expect(roundTrip.duration, const Duration(hours: 1, minutes: 15));
  });

  test('feeding entry roundtrips through JSON', () {
    final entry = JournalEntry.feeding(
      id: 'feeding-1',
      eventAt: DateTime(2026, 5, 19, 11, 20),
      feedingType: JournalFeedingType.bottle,
      amountText: '180 ml',
      note: 'After the walk',
      createdAt: DateTime(2026, 5, 19, 11, 20),
      updatedAt: DateTime(2026, 5, 19, 11, 25),
    );

    final roundTrip = JournalEntry.fromJson(entry.toJson());

    expect(roundTrip.type, JournalEntryType.feeding);
    expect(roundTrip.feedingType, JournalFeedingType.bottle);
    expect(roundTrip.amountText, '180 ml');
    expect(roundTrip.note, 'After the walk');
    expect(roundTrip.effectiveAt, entry.effectiveAt);
  });

  test('diaper entry roundtrips through JSON', () {
    final entry = JournalEntry.diaper(
      id: 'diaper-1',
      eventAt: DateTime(2026, 5, 19, 13, 5),
      diaperType: JournalDiaperType.both,
      note: 'Changed quickly',
    );

    final roundTrip = JournalEntry.fromJson(entry.toJson());

    expect(roundTrip.type, JournalEntryType.diaper);
    expect(roundTrip.diaperType, JournalDiaperType.both);
    expect(roundTrip.note, 'Changed quickly');
    expect(roundTrip.effectiveAt, entry.effectiveAt);
  });

  test('note entry roundtrips through JSON', () {
    final entry = JournalEntry.note(
      id: 'note-1',
      eventAt: DateTime(2026, 5, 19, 18, 45),
      note: 'A quiet evening.',
    );

    final roundTrip = JournalEntry.fromJson(entry.toJson());

    expect(roundTrip.type, JournalEntryType.note);
    expect(roundTrip.note, 'A quiet evening.');
    expect(roundTrip.effectiveAt, entry.effectiveAt);
  });
}

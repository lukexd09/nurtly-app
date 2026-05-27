import 'journal_entry.dart';
import 'journal_entry_type.dart';

class JournalSummary {
  const JournalSummary({
    required this.totalSleep,
    required this.feedingsCount,
    required this.diapersCount,
    required this.notesCount,
    required this.lastSleep,
    required this.lastFeeding,
    required this.lastDiaper,
    required this.latestNote,
  });

  factory JournalSummary.empty() {
    return const JournalSummary(
      totalSleep: Duration.zero,
      feedingsCount: 0,
      diapersCount: 0,
      notesCount: 0,
      lastSleep: null,
      lastFeeding: null,
      lastDiaper: null,
      latestNote: null,
    );
  }

  final Duration totalSleep;
  final int feedingsCount;
  final int diapersCount;
  final int notesCount;
  final JournalEntry? lastSleep;
  final JournalEntry? lastFeeding;
  final JournalEntry? lastDiaper;
  final JournalEntry? latestNote;

  factory JournalSummary.fromEntries(
    List<JournalEntry> entries,
    DateTime day, {
    required DateTime now,
  }) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final dayEntries = entries
        .where(
          (entry) =>
              !entry.isDeleted &&
              _eventDate(entry)
                  .isAfter(start.subtract(const Duration(microseconds: 1))) &&
              _eventDate(entry).isBefore(end),
        )
        .toList()
      ..sort((a, b) => _eventDate(b).compareTo(_eventDate(a)));

    final sleepEntries =
        dayEntries.where((entry) => entry.type == JournalEntryType.sleep);
    final lastSleep = dayEntries.cast<JournalEntry?>().firstWhere(
          (entry) => entry?.type == JournalEntryType.sleep,
          orElse: () => null,
        );
    final lastFeeding = dayEntries.cast<JournalEntry?>().firstWhere(
          (entry) => entry?.type == JournalEntryType.feeding,
          orElse: () => null,
        );
    final lastDiaper = dayEntries.cast<JournalEntry?>().firstWhere(
          (entry) => entry?.type == JournalEntryType.diaper,
          orElse: () => null,
        );
    final latestNote = dayEntries.cast<JournalEntry?>().firstWhere(
          (entry) => entry?.type == JournalEntryType.note,
          orElse: () => null,
        );

    return JournalSummary(
      totalSleep: sleepEntries.fold<Duration>(
        Duration.zero,
        (total, entry) {
          final duration = entry.duration;
          if (duration != null) {
            return total + duration;
          }
          if (entry.isActiveSleep) {
            return total + now.difference(entry.startAt!);
          }
          return total;
        },
      ),
      feedingsCount: dayEntries
          .where((entry) => entry.type == JournalEntryType.feeding)
          .length,
      diapersCount: dayEntries
          .where((entry) => entry.type == JournalEntryType.diaper)
          .length,
      notesCount: dayEntries
          .where((entry) => entry.type == JournalEntryType.note)
          .length,
      lastSleep: lastSleep,
      lastFeeding: lastFeeding,
      lastDiaper: lastDiaper,
      latestNote: latestNote,
    );
  }

  static DateTime _eventDate(JournalEntry entry) {
    return entry.effectiveAt;
  }
}

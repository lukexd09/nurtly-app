class JournalEntry {
  const JournalEntry({
    required this.note,
    required this.createdAt,
    this.moodLabel,
  });

  final String note;
  final DateTime createdAt;
  final String? moodLabel;

  String get readableTimestamp {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return 'Today $hour:$minute';
  }
}

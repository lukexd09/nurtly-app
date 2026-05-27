enum JournalEntryType {
  sleep('sleep'),
  feeding('feeding'),
  diaper('diaper'),
  note('note');

  const JournalEntryType(this.code);

  final String code;

  static JournalEntryType fromCode(String code) {
    return switch (code) {
      'sleep' => JournalEntryType.sleep,
      'feeding' => JournalEntryType.feeding,
      'diaper' => JournalEntryType.diaper,
      'note' => JournalEntryType.note,
      _ => throw FormatException('Unsupported journal entry type: $code'),
    };
  }
}

enum JournalFeedingType {
  breast('breast'),
  bottle('bottle'),
  food('food'),
  other('other');

  const JournalFeedingType(this.code);

  final String code;

  static JournalFeedingType fromCode(String code) {
    return switch (code) {
      'breast' => JournalFeedingType.breast,
      'bottle' => JournalFeedingType.bottle,
      'food' => JournalFeedingType.food,
      'other' => JournalFeedingType.other,
      _ => throw FormatException('Unsupported feeding type: $code'),
    };
  }
}

enum JournalDiaperType {
  pee('pee'),
  poop('poop'),
  both('both'),
  dry('dry');

  const JournalDiaperType(this.code);

  final String code;

  static JournalDiaperType fromCode(String code) {
    return switch (code) {
      'pee' => JournalDiaperType.pee,
      'poop' => JournalDiaperType.poop,
      'both' => JournalDiaperType.both,
      'dry' => JournalDiaperType.dry,
      _ => throw FormatException('Unsupported diaper type: $code'),
    };
  }
}

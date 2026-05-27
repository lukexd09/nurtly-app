import 'journal_entry_type.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.eventAt,
    this.startAt,
    this.endAt,
    this.note,
    this.isDeleted = false,
    this.childId,
    this.feedingType,
    this.amountText,
    this.amountMl,
    this.diaperType,
  });

  factory JournalEntry.note({
    required String id,
    required DateTime eventAt,
    required String note,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? childId,
  }) {
    final now = createdAt ?? eventAt;
    return JournalEntry(
      id: id,
      type: JournalEntryType.note,
      createdAt: now,
      updatedAt: updatedAt ?? now,
      eventAt: eventAt,
      note: note,
      childId: childId,
    );
  }

  factory JournalEntry.feeding({
    required String id,
    required DateTime eventAt,
    required JournalFeedingType feedingType,
    String? amountText,
    int? amountMl,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? childId,
  }) {
    final now = createdAt ?? eventAt;
    return JournalEntry(
      id: id,
      type: JournalEntryType.feeding,
      createdAt: now,
      updatedAt: updatedAt ?? now,
      eventAt: eventAt,
      note: note,
      childId: childId,
      feedingType: feedingType,
      amountText: amountText,
      amountMl: amountMl,
    );
  }

  factory JournalEntry.diaper({
    required String id,
    required DateTime eventAt,
    required JournalDiaperType diaperType,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? childId,
  }) {
    final now = createdAt ?? eventAt;
    return JournalEntry(
      id: id,
      type: JournalEntryType.diaper,
      createdAt: now,
      updatedAt: updatedAt ?? now,
      eventAt: eventAt,
      note: note,
      childId: childId,
      diaperType: diaperType,
    );
  }

  factory JournalEntry.sleep({
    required String id,
    required DateTime startAt,
    DateTime? endAt,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? childId,
  }) {
    final now = createdAt ?? startAt;
    return JournalEntry(
      id: id,
      type: JournalEntryType.sleep,
      createdAt: now,
      updatedAt: updatedAt ?? now,
      startAt: startAt,
      endAt: endAt,
      note: note,
      childId: childId,
    );
  }

  final String id;
  final JournalEntryType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? eventAt;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? note;
  final bool isDeleted;
  final String? childId;
  final JournalFeedingType? feedingType;
  final String? amountText;
  final int? amountMl;
  final JournalDiaperType? diaperType;

  DateTime get effectiveAt => eventAt ?? startAt ?? createdAt;

  bool get isActiveSleep =>
      type == JournalEntryType.sleep &&
      startAt != null &&
      endAt == null &&
      !isDeleted;

  Duration? get duration {
    if (startAt == null || endAt == null) {
      return null;
    }
    return endAt!.difference(startAt!);
  }

  JournalEntry copyWith({
    String? id,
    JournalEntryType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? eventAt,
    DateTime? startAt,
    DateTime? endAt,
    String? note,
    bool? isDeleted,
    String? childId,
    JournalFeedingType? feedingType,
    String? amountText,
    int? amountMl,
    JournalDiaperType? diaperType,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eventAt: eventAt ?? this.eventAt,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      note: note ?? this.note,
      isDeleted: isDeleted ?? this.isDeleted,
      childId: childId ?? this.childId,
      feedingType: feedingType ?? this.feedingType,
      amountText: amountText ?? this.amountText,
      amountMl: amountMl ?? this.amountMl,
      diaperType: diaperType ?? this.diaperType,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.code,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (eventAt != null) 'eventAt': eventAt!.toIso8601String(),
      if (startAt != null) 'startAt': startAt!.toIso8601String(),
      if (endAt != null) 'endAt': endAt!.toIso8601String(),
      if (note != null) 'note': note,
      'isDeleted': isDeleted,
      if (childId != null) 'childId': childId,
      if (feedingType != null) 'feedingType': feedingType!.code,
      if (amountText != null) 'amountText': amountText,
      if (amountMl != null) 'amountMl': amountMl,
      if (diaperType != null) 'diaperType': diaperType!.code,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      type: JournalEntryType.fromCode(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      eventAt: _parseDateTime(json['eventAt']),
      startAt: _parseDateTime(json['startAt']),
      endAt: _parseDateTime(json['endAt']),
      note: json['note'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      childId: json['childId'] as String?,
      feedingType: _parseFeedingType(json['feedingType'] as String?),
      amountText: json['amountText'] as String?,
      amountMl: json['amountMl'] as int?,
      diaperType: _parseDiaperType(json['diaperType'] as String?),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.parse(value as String);
  }

  static JournalFeedingType? _parseFeedingType(String? code) {
    if (code == null) {
      return null;
    }
    return JournalFeedingType.fromCode(code);
  }

  static JournalDiaperType? _parseDiaperType(String? code) {
    if (code == null) {
      return null;
    }
    return JournalDiaperType.fromCode(code);
  }
}

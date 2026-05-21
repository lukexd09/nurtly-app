import 'json_readers.dart';

class AgeRangeMonths {
  const AgeRangeMonths({
    required this.min,
    required this.max,
  });

  final int min;
  final int max;

  factory AgeRangeMonths.fromJson(Map<String, Object?> json) {
    final min = readInt(json, 'min');
    final max = readInt(json, 'max');
    if (min < 0) {
      throw FormatException("Invalid 'ageRangeMonths.min'. Expected >= 0.");
    }
    if (max < min) {
      throw FormatException(
        "Invalid 'ageRangeMonths.max'. Expected >= 'min'.",
      );
    }
    if (max > 96) {
      throw FormatException("Invalid 'ageRangeMonths.max'. Expected <= 96.");
    }
    return AgeRangeMonths(min: min, max: max);
  }
}

class PlayIdea {
  const PlayIdea({
    required this.id,
    required this.title,
    required this.summary,
    required this.ageGroup,
    required this.ageRangeMonths,
    required this.place,
    required this.messLevel,
    required this.childEngagement,
    required this.parentInvolvement,
    required this.activityType,
    required this.contexts,
    required this.neededItems,
    required this.steps,
    required this.whatToExpect,
    this.suggestedSoundId,
    required this.parentNote,
    required this.safetyNote,
  });

  final String id;
  final String title;
  final String summary;
  final String ageGroup;
  final AgeRangeMonths ageRangeMonths;
  final String place;
  final String messLevel;
  final String childEngagement;
  final String parentInvolvement;
  final String activityType;
  final List<String> contexts;
  final List<String> neededItems;
  final List<String> steps;
  final String whatToExpect;
  final String? suggestedSoundId;
  final String parentNote;
  final String safetyNote;

  factory PlayIdea.fromJson(Map<String, Object?> json) {
    return PlayIdea(
      id: readString(json, 'id'),
      title: readString(json, 'title'),
      summary: readString(json, 'summary'),
      ageGroup: readString(json, 'ageGroup'),
      ageRangeMonths: AgeRangeMonths.fromJson(readMap(json, 'ageRangeMonths')),
      place: readString(json, 'place'),
      messLevel: readString(json, 'messLevel'),
      childEngagement: readString(json, 'childEngagement'),
      parentInvolvement: readString(json, 'parentInvolvement'),
      activityType: readString(json, 'activityType'),
      contexts: json.containsKey('contexts')
          ? readStringList(json, 'contexts')
          : const <String>[],
      neededItems: readStringList(json, 'neededItems'),
      steps: readStringList(json, 'steps'),
      whatToExpect: readString(json, 'whatToExpect'),
      suggestedSoundId: json.containsKey('suggestedSoundId')
          ? readString(json, 'suggestedSoundId')
          : null,
      parentNote: readString(json, 'parentNote'),
      safetyNote: readString(json, 'safetyNote'),
    );
  }
}

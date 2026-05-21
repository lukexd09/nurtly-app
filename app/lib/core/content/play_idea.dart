import 'json_readers.dart';

class AgeRangeMonths {
  const AgeRangeMonths({
    required this.min,
    required this.max,
  });

  final int min;
  final int max;

  factory AgeRangeMonths.fromJson(Map<String, Object?> json) {
    return AgeRangeMonths(
      min: readInt(json, 'min'),
      max: readInt(json, 'max'),
    );
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
  final String parentNote;
  final String safetyNote;

  factory PlayIdea.fromJson(Map<String, Object?> json) {
    return PlayIdea(
      id: readString(json, 'id'),
      title: readString(json, 'title'),
      summary: readString(json, 'summary'),
      ageGroup: readString(json, 'ageGroup'),
      ageRangeMonths: json.containsKey('ageRangeMonths')
          ? AgeRangeMonths.fromJson(readMap(json, 'ageRangeMonths'))
          : const AgeRangeMonths(min: 0, max: 96),
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
      parentNote: readString(json, 'parentNote'),
      safetyNote: readString(json, 'safetyNote'),
    );
  }
}

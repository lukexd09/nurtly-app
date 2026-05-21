import 'json_readers.dart';

class PlayIdea {
  const PlayIdea({
    required this.id,
    required this.title,
    required this.summary,
    required this.ageGroup,
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

import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_taxonomy.dart';

void main() {
  test('parses taxonomy terms from JSON', () {
    final taxonomy = ContentTaxonomy.fromJson(_taxonomyJson);

    expect(taxonomy.places, hasLength(2));
    expect(taxonomy.places.first.id, 'place_home');
    expect(taxonomy.places.first.label, 'Home');
    expect(taxonomy.soundCategories.single.label, 'Nature');
  });

  test('trims taxonomy term ids and labels', () {
    final taxonomy = ContentTaxonomy.fromJson(_taxonomyJsonWithWhitespaceTrim);

    expect(taxonomy.places.single.id, 'place_home');
    expect(taxonomy.places.single.label, 'Home');
  });

  test('rejects duplicate taxonomy term ids within a list', () {
    expect(
      () => ContentTaxonomy.fromJson(_taxonomyJsonWithDuplicateIds),
      throwsFormatException,
    );
  });

  test('rejects empty taxonomy labels', () {
    expect(
      () => ContentTaxonomy.fromJson(_taxonomyJsonWithEmptyLabel),
      throwsFormatException,
    );
  });

  test('rejects whitespace taxonomy term ids', () {
    expect(
      () => ContentTaxonomy.fromJson(_taxonomyJsonWithWhitespaceId),
      throwsFormatException,
    );
  });

  test('rejects whitespace taxonomy labels', () {
    expect(
      () => ContentTaxonomy.fromJson(_taxonomyJsonWithWhitespaceLabel),
      throwsFormatException,
    );
  });

  test('requires all taxonomy lists', () {
    expect(
      () => ContentTaxonomy.fromJson(const <String, Object?>{}),
      throwsFormatException,
    );
  });
}

const Map<String, Object?> _taxonomyJson = {
  'places': [
    {'id': 'place_home', 'label': 'Home'},
    {'id': 'place_outside', 'label': 'Outside'},
  ],
  'messLevels': [
    {'id': 'mess_low', 'label': 'Low'},
  ],
  'childEngagementLevels': [
    {'id': 'child_engagement_low', 'label': 'Low'},
  ],
  'parentInvolvementLevels': [
    {'id': 'parent_involvement_low', 'label': 'Low'},
  ],
  'activityTypes': [
    {'id': 'activity_quiet_time', 'label': 'Quiet time'},
  ],
  'contexts': [
    {'id': 'context_home', 'label': 'home'},
  ],
  'soundCategories': [
    {'id': 'sound_category_nature', 'label': 'Nature'},
  ],
};

const Map<String, Object?> _taxonomyJsonWithDuplicateIds = {
  'places': [
    {'id': 'place_home', 'label': 'Home'},
    {'id': 'place_home', 'label': 'Outside'},
  ],
  'messLevels': [
    {'id': 'mess_low', 'label': 'Low'},
  ],
  'childEngagementLevels': [
    {'id': 'child_engagement_low', 'label': 'Low'},
  ],
  'parentInvolvementLevels': [
    {'id': 'parent_involvement_low', 'label': 'Low'},
  ],
  'activityTypes': [
    {'id': 'activity_quiet_time', 'label': 'Quiet time'},
  ],
  'contexts': [
    {'id': 'context_home', 'label': 'home'},
  ],
  'soundCategories': [
    {'id': 'sound_category_nature', 'label': 'Nature'},
  ],
};

const Map<String, Object?> _taxonomyJsonWithEmptyLabel = {
  'places': [
    {'id': 'place_home', 'label': 'Home'},
  ],
  'messLevels': [
    {'id': 'mess_low', 'label': ''},
  ],
  'childEngagementLevels': [
    {'id': 'child_engagement_low', 'label': 'Low'},
  ],
  'parentInvolvementLevels': [
    {'id': 'parent_involvement_low', 'label': 'Low'},
  ],
  'activityTypes': [
    {'id': 'activity_quiet_time', 'label': 'Quiet time'},
  ],
  'contexts': [
    {'id': 'context_home', 'label': 'home'},
  ],
  'soundCategories': [
    {'id': 'sound_category_nature', 'label': 'Nature'},
  ],
};

const Map<String, Object?> _taxonomyJsonWithWhitespaceId = {
  'places': [
    {'id': '   ', 'label': 'Home'},
  ],
  'messLevels': [
    {'id': 'mess_low', 'label': 'Low'},
  ],
  'childEngagementLevels': [
    {'id': 'child_engagement_low', 'label': 'Low'},
  ],
  'parentInvolvementLevels': [
    {'id': 'parent_involvement_low', 'label': 'Low'},
  ],
  'activityTypes': [
    {'id': 'activity_quiet_time', 'label': 'Quiet time'},
  ],
  'contexts': [
    {'id': 'context_home', 'label': 'home'},
  ],
  'soundCategories': [
    {'id': 'sound_category_nature', 'label': 'Nature'},
  ],
};

const Map<String, Object?> _taxonomyJsonWithWhitespaceLabel = {
  'places': [
    {'id': 'place_home', 'label': 'Home'},
  ],
  'messLevels': [
    {'id': 'mess_low', 'label': '   '},
  ],
  'childEngagementLevels': [
    {'id': 'child_engagement_low', 'label': 'Low'},
  ],
  'parentInvolvementLevels': [
    {'id': 'parent_involvement_low', 'label': 'Low'},
  ],
  'activityTypes': [
    {'id': 'activity_quiet_time', 'label': 'Quiet time'},
  ],
  'contexts': [
    {'id': 'context_home', 'label': 'home'},
  ],
  'soundCategories': [
    {'id': 'sound_category_nature', 'label': 'Nature'},
  ],
};

const Map<String, Object?> _taxonomyJsonWithWhitespaceTrim = {
  'places': [
    {'id': ' place_home ', 'label': ' Home '},
  ],
  'messLevels': [
    {'id': 'mess_low', 'label': 'Low'},
  ],
  'childEngagementLevels': [
    {'id': 'child_engagement_low', 'label': 'Low'},
  ],
  'parentInvolvementLevels': [
    {'id': 'parent_involvement_low', 'label': 'Low'},
  ],
  'activityTypes': [
    {'id': 'activity_quiet_time', 'label': 'Quiet time'},
  ],
  'contexts': [
    {'id': 'context_home', 'label': 'home'},
  ],
  'soundCategories': [
    {'id': 'sound_category_nature', 'label': 'Nature'},
  ],
};

import 'json_readers.dart';

class TaxonomyTerm {
  const TaxonomyTerm({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;

  factory TaxonomyTerm.fromJson(Map<String, Object?> json) {
    return TaxonomyTerm(
      id: readString(json, 'id'),
      label: readString(json, 'label'),
    );
  }
}

class ContentTaxonomy {
  const ContentTaxonomy({
    required this.places,
    required this.messLevels,
    required this.childEngagementLevels,
    required this.parentInvolvementLevels,
    required this.activityTypes,
    required this.contexts,
    required this.soundCategories,
  });

  final List<TaxonomyTerm> places;
  final List<TaxonomyTerm> messLevels;
  final List<TaxonomyTerm> childEngagementLevels;
  final List<TaxonomyTerm> parentInvolvementLevels;
  final List<TaxonomyTerm> activityTypes;
  final List<TaxonomyTerm> contexts;
  final List<TaxonomyTerm> soundCategories;

  factory ContentTaxonomy.fromJson(Map<String, Object?> json) {
    return ContentTaxonomy(
      places: _readTerms(json, 'places'),
      messLevels: _readTerms(json, 'messLevels'),
      childEngagementLevels: _readTerms(json, 'childEngagementLevels'),
      parentInvolvementLevels: _readTerms(json, 'parentInvolvementLevels'),
      activityTypes: _readTerms(json, 'activityTypes'),
      contexts: _readTerms(json, 'contexts'),
      soundCategories: _readTerms(json, 'soundCategories'),
    );
  }
}

List<TaxonomyTerm> _readTerms(Map<String, Object?> json, String key) {
  final terms = readItems(json, key, TaxonomyTerm.fromJson);
  final seenIds = <String>{};

  for (final term in terms) {
    if (!seenIds.add(term.id)) {
      throw FormatException(
        "Duplicate taxonomy term id '${term.id}' in '$key'.",
      );
    }
  }

  return terms;
}

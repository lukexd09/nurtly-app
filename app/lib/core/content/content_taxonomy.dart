import 'json_readers.dart';
import 'play_filter.dart';
import 'play_idea.dart';

class TaxonomyTerm {
  const TaxonomyTerm({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;

  factory TaxonomyTerm.fromJson(Map<String, Object?> json) {
    return TaxonomyTerm(
      id: _readTaxonomyString(json, 'id'),
      label: _readTaxonomyString(json, 'label'),
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

  String labelForPlace(String id) => _labelFor(places, id);

  String labelForMessLevel(String id) => _labelFor(messLevels, id);

  String labelForChildEngagement(String id) =>
      _labelFor(childEngagementLevels, id);

  String labelForParentInvolvement(String id) =>
      _labelFor(parentInvolvementLevels, id);

  String labelForActivityType(String id) => _labelFor(activityTypes, id);

  String labelForContext(String id) => _labelFor(contexts, id);

  String labelForSoundCategory(String id) => _labelFor(soundCategories, id);

  void validatePlayIdeasAndFilters({
    required List<PlayIdea> playIdeas,
    required List<PlayFilter> playFilters,
  }) {
    for (final idea in playIdeas) {
      _requireKnownId(places, idea.place, 'playIdeas.${idea.id}.place');
      _requireKnownId(
        messLevels,
        idea.messLevel,
        'playIdeas.${idea.id}.messLevel',
      );
      _requireKnownId(
        childEngagementLevels,
        idea.childEngagement,
        'playIdeas.${idea.id}.childEngagement',
      );
      _requireKnownId(
        parentInvolvementLevels,
        idea.parentInvolvement,
        'playIdeas.${idea.id}.parentInvolvement',
      );
      _requireKnownId(
        activityTypes,
        idea.activityType,
        'playIdeas.${idea.id}.activityType',
      );
      for (final context in idea.contexts) {
        _requireKnownId(
          contexts,
          context,
          'playIdeas.${idea.id}.contexts',
        );
      }
    }

    for (final filter in playFilters) {
      for (final rule in filter.rules) {
        switch (rule.field) {
          case 'place':
            _validateRuleValue(places, rule, filter.id);
          case 'messLevel':
            _validateRuleValue(messLevels, rule, filter.id);
          case 'childEngagement':
            _validateRuleValue(childEngagementLevels, rule, filter.id);
          case 'parentInvolvement':
            _validateRuleValue(parentInvolvementLevels, rule, filter.id);
          case 'activityType':
            _validateRuleValue(activityTypes, rule, filter.id);
          case 'contexts':
            _validateRuleValue(contexts, rule, filter.id);
          case 'ageRangeMonths':
            continue;
        }
      }
    }
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

String _readTaxonomyString(Map<String, Object?> json, String key) {
  final value = readString(json, key).trim();
  if (value.isEmpty) {
    throw FormatException("Expected non-blank taxonomy '$key'.");
  }
  return value;
}

String _labelFor(List<TaxonomyTerm> terms, String id) {
  for (final term in terms) {
    if (term.id == id) {
      return term.label;
    }
  }
  return id;
}

void _requireKnownId(
  List<TaxonomyTerm> terms,
  String id,
  String fieldPath,
) {
  if (_containsId(terms, id)) {
    return;
  }
  throw FormatException("Unknown taxonomy id '$id' in '$fieldPath'.");
}

void _validateRuleValue(
  List<TaxonomyTerm> terms,
  PlayFilterRule rule,
  String filterId,
) {
  if (rule.value == null || !_containsId(terms, rule.value!)) {
    throw FormatException(
      "Unknown taxonomy id '${rule.value}' in play filter '$filterId'.",
    );
  }
}

bool _containsId(List<TaxonomyTerm> terms, String id) {
  return terms.any((term) => term.id == id);
}

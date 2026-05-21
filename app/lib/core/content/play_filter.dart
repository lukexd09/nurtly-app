import 'json_readers.dart';
import 'play_idea.dart';

class PlayFilter {
  const PlayFilter({
    required this.id,
    required this.label,
    required this.matchMode,
    required this.rules,
  });

  final String id;
  final String label;
  final PlayFilterMatchMode matchMode;
  final List<PlayFilterRule> rules;

  factory PlayFilter.fromJson(Map<String, Object?> json) {
    final matchModeValue =
        (json['matchMode'] as String?)?.trim().toLowerCase() ?? 'all';
    return PlayFilter(
      id: readString(json, 'id'),
      label: readString(json, 'label'),
      matchMode: PlayFilterMatchMode.fromJsonValue(matchModeValue),
      rules: readItems(json, 'rules', PlayFilterRule.fromJson),
    );
  }

  bool matches(PlayIdea idea) {
    if (rules.isEmpty) {
      return false;
    }
    return switch (matchMode) {
      PlayFilterMatchMode.all => rules.every((rule) => rule.matches(idea)),
      PlayFilterMatchMode.any => rules.any((rule) => rule.matches(idea)),
    };
  }
}

enum PlayFilterMatchMode {
  all,
  any;

  static PlayFilterMatchMode fromJsonValue(String value) {
    return switch (value) {
      'all' => PlayFilterMatchMode.all,
      'any' => PlayFilterMatchMode.any,
      _ => throw FormatException(
          "Invalid 'matchMode'. Expected 'all' or 'any', got '$value'.",
        ),
    };
  }
}

class PlayFilterRule {
  const PlayFilterRule({
    required this.field,
    required this.operator,
    this.value,
    this.min,
    this.max,
  });

  final String field;
  final String operator;
  final String? value;
  final int? min;
  final int? max;

  factory PlayFilterRule.fromJson(Map<String, Object?> json) {
    final field = readString(json, 'field');
    final operator = readString(json, 'operator');
    final value = json.containsKey('value') ? readString(json, 'value') : null;
    final min = json.containsKey('min') ? readInt(json, 'min') : null;
    final max = json.containsKey('max') ? readInt(json, 'max') : null;

    _validateRule(field, operator, value: value, min: min, max: max);

    return PlayFilterRule(
      field: field,
      operator: operator,
      value: value,
      min: min,
      max: max,
    );
  }

  static void _validateRule(
    String field,
    String operator, {
    String? value,
    int? min,
    int? max,
  }) {
    if (field == 'ageRangeMonths') {
      if (operator != 'overlaps') {
        throw FormatException(
          "Invalid 'operator' for field 'ageRangeMonths'. Expected 'overlaps'.",
        );
      }
      if (min == null || max == null) {
        throw FormatException(
          "Invalid 'ageRangeMonths' rule. Expected 'min' and 'max'.",
        );
      }
      if (min < 0) {
        throw FormatException("Invalid 'min'. Expected >= 0.");
      }
      if (max < min) {
        throw FormatException("Invalid 'max'. Expected >= 'min'.");
      }
      if (max > 96) {
        throw FormatException("Invalid 'max'. Expected <= 96.");
      }
      return;
    }

    if (field == 'contexts') {
      if (operator != 'contains') {
        throw FormatException(
          "Invalid 'operator' for field 'contexts'. Expected 'contains'.",
        );
      }
      if (value == null) {
        throw FormatException(
            "Expected non-empty 'value' for field 'contexts'.");
      }
      return;
    }

    if (operator == 'equals' || operator == 'contains') {
      if (value == null) {
        throw FormatException('Expected non-empty value for rule.');
      }
      return;
    }

    throw FormatException("Invalid 'operator'.");
  }

  bool matches(PlayIdea idea) {
    if (field == 'contexts') {
      return switch (operator) {
        'contains' => value != null && idea.contexts.contains(value),
        _ => false,
      };
    }
    if (field == 'ageRangeMonths') {
      return switch (operator) {
        'overlaps' => min != null &&
            max != null &&
            idea.ageRangeMonths.min <= max! &&
            idea.ageRangeMonths.max >= min!,
        _ => false,
      };
    }

    final source = _readFieldValue(idea, field);
    final ruleValue = value;
    if (source == null) {
      return false;
    }
    if (ruleValue == null) {
      return false;
    }
    return switch (operator) {
      'equals' => source == ruleValue,
      'contains' => source.contains(ruleValue),
      _ => false,
    };
  }
}

String? _readFieldValue(PlayIdea idea, String field) {
  return switch (field) {
    'parentInvolvement' => idea.parentInvolvement,
    'messLevel' => idea.messLevel,
    'ageGroup' => idea.ageGroup,
    'activityType' => idea.activityType,
    'childEngagement' => idea.childEngagement,
    'place' => idea.place,
    _ => null,
  };
}

import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/bundled_content_source.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
import 'package:nurtly/core/content/content_source.dart';
import 'package:nurtly/core/content/content_taxonomy.dart';
import 'package:nurtly/core/content/play_idea.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/core/localization/app_language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads production content package from default asset path', () async {
    final package = await const ContentLoader().load();

    expect(package.metadata.packageId, 'nurtly-core-en');
    expect(package.metadata.schemaVersion, 1);
    expect(package.metadata.version, '1.7.0');
    expect(package.metadata.locale, 'en');
    expect(_isNotBlank(package.metadata.publishedAt), isTrue);
    expect(DateTime.tryParse(package.metadata.publishedAt), isNotNull);
    expect(_isNotBlank(package.metadata.minAppVersion), isTrue);
    expect(package.playIdeas, hasLength(50));
    expect(package.playFilters, hasLength(7));
    expect(package.sounds, hasLength(6));
    expect(package.taxonomy.places, hasLength(12));
    expect(package.taxonomy.soundCategories, hasLength(4));
    expect(package.playIdeas.first.neededItems, contains('Soft cloth'));
    expect(package.playIdeas.first.steps, hasLength(3));
  });

  test('bundled content asset path resolves English and Polish assets', () {
    expect(
      bundledContentAssetPathFor(AppLanguage.english),
      'assets/content/nurtly_content_en_v1.json',
    );
    expect(
      bundledContentAssetPathFor(AppLanguage.polish),
      'assets/content/nurtly_content_pl_v1.json',
    );
  });

  test('bundled content source loads English and Polish packages', () async {
    final english = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.english),
    ).load();
    final polish = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.polish),
    ).load();

    expect(english.metadata.packageId, 'nurtly-core-en');
    expect(english.metadata.locale, 'en');
    expect(polish.metadata.packageId, 'nurtly-core-pl');
    expect(polish.metadata.locale, 'pl');
  });

  test('taxonomy term parses optional chipLabel and trims it', () {
    final term = TaxonomyTerm.fromJson({
      'id': 'mess_low',
      'label': 'Low',
      'chipLabel': '  Low mess  ',
    });

    expect(term.id, 'mess_low');
    expect(term.label, 'Low');
    expect(term.chipLabel, 'Low mess');
  });

  test('taxonomy helper falls back to label when chipLabel is missing', () {
    const taxonomy = ContentTaxonomy(
      places: [
        TaxonomyTerm(id: 'place_home', label: 'Home'),
      ],
      messLevels: [
        TaxonomyTerm(id: 'mess_low', label: 'Low'),
      ],
      childEngagementLevels: [
        TaxonomyTerm(id: 'child_engagement_low', label: 'Low'),
      ],
      parentInvolvementLevels: [
        TaxonomyTerm(id: 'parent_involvement_low', label: 'Low'),
      ],
      activityTypes: [
        TaxonomyTerm(id: 'activity_quiet_time', label: 'Quiet time'),
      ],
      contexts: [
        TaxonomyTerm(id: 'context_home', label: 'home'),
      ],
      soundCategories: [
        TaxonomyTerm(id: 'sound_category_calm', label: 'Calm'),
      ],
    );

    expect(taxonomy.chipLabelForMessLevel('mess_low'), 'Low');
    expect(taxonomy.chipLabelForChildEngagement('child_engagement_low'), 'Low');
    expect(
      taxonomy.chipLabelForParentInvolvement('parent_involvement_low'),
      'Low',
    );
  });

  test('blank taxonomy chipLabel throws FormatException', () {
    expect(
      () => TaxonomyTerm.fromJson({
        'id': 'mess_low',
        'label': 'Low',
        'chipLabel': '   ',
      }),
      throwsFormatException,
    );
  });

  test('English and Polish bundled packages keep stable IDs aligned', () async {
    final english = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.english),
    ).load();
    final polish = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.polish),
    ).load();

    expect(english.playIdeas.length, polish.playIdeas.length);
    expect(
      _ids(english.playIdeas.map((idea) => idea.id)),
      _ids(polish.playIdeas.map((idea) => idea.id)),
    );
    expect(english.sounds.length, polish.sounds.length);
    expect(
      _ids(english.sounds.map((sound) => sound.id)),
      _ids(polish.sounds.map((sound) => sound.id)),
    );
    expect(
      _taxonomyIds(english.taxonomy),
      _taxonomyIds(polish.taxonomy),
    );
    expect(
      _suggestedSoundIds(english.playIdeas),
      _suggestedSoundIds(polish.playIdeas),
    );
    expect(
      _soundAssetMap(english.sounds),
      _soundAssetMap(polish.sounds),
    );
    expect(
      _unlockTypeMap(english.playIdeas),
      _unlockTypeMap(polish.playIdeas),
    );
    expect(
      _soundUnlockTypeMap(english.sounds),
      _soundUnlockTypeMap(polish.sounds),
    );
  });

  test('bundled premium content ratio stays within MVP guardrails', () async {
    final package = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.english),
    ).load();

    final playPremiumRatio = _premiumRatio(package.playIdeas);
    final soundPremiumRatio = _premiumRatio(package.sounds);

    expect(playPremiumRatio, greaterThan(0.3));
    expect(playPremiumRatio, lessThan(0.7));
    expect(soundPremiumRatio, greaterThan(0.2));
    expect(soundPremiumRatio, lessThan(0.8));
  });

  test('Polish taxonomy labels are localized while IDs stay stable', () async {
    final english = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.english),
    ).load();
    final polish = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.polish),
    ).load();

    expect(
      _labels(english.taxonomy.places),
      isNot(equals(_labels(polish.taxonomy.places))),
    );
    expect(
      _labels(english.taxonomy.messLevels),
      isNot(equals(_labels(polish.taxonomy.messLevels))),
    );
    expect(
      _labels(english.taxonomy.activityTypes),
      isNot(equals(_labels(polish.taxonomy.activityTypes))),
    );
    expect(
      _labels(english.taxonomy.soundCategories),
      isNot(equals(_labels(polish.taxonomy.soundCategories))),
    );

    final englishChipLabels = [
      ..._chipLabels(english.taxonomy.messLevels),
      ..._chipLabels(english.taxonomy.childEngagementLevels),
      ..._chipLabels(english.taxonomy.parentInvolvementLevels),
    ];
    expect(englishChipLabels, contains('Mess: low'));
    expect(englishChipLabels, contains('Mess: medium'));
    expect(englishChipLabels, contains('Child: low'));
    expect(englishChipLabels, contains('Child: medium'));
    expect(englishChipLabels, contains('Child: high'));
    expect(englishChipLabels, contains('Parent: low'));
    expect(englishChipLabels, contains('Parent: medium'));
    expect(englishChipLabels, contains('Parent: high'));
    expect(englishChipLabels.any((label) => label.contains('?')), isFalse);
    expect(englishChipLabels, isNot(contains('Low mess')));
    expect(englishChipLabels, isNot(contains('Medium mess')));

    final polishLabels = [
      ..._labels(polish.taxonomy.places),
      ..._labels(polish.taxonomy.messLevels),
      ..._labels(polish.taxonomy.activityTypes),
      ..._labels(polish.taxonomy.contexts),
      ..._labels(polish.taxonomy.soundCategories),
    ];
    expect(polishLabels.any((label) => label.contains('?')), isFalse);
    expect(polishLabels, contains('Łazienka'));
    expect(polishLabels, contains('Podłoga'));
    expect(polishLabels, contains('Średni bałagan'));
    expect(polishLabels, contains('Bliskość'));
    expect(polishLabels, contains('Język'));
    expect(polishLabels, contains('Codzienność'));
    expect(polishLabels, contains('niemowlę'));
    expect(polishLabels, contains('mało przygotowań'));

    final polishChipLabels = [
      ..._chipLabels(polish.taxonomy.messLevels),
      ..._chipLabels(polish.taxonomy.childEngagementLevels),
      ..._chipLabels(polish.taxonomy.parentInvolvementLevels),
    ];
    expect(polishChipLabels.any((label) => label.contains('?')), isFalse);
    expect(polishChipLabels, contains('Bałagan: mały'));
    expect(polishChipLabels, contains('Bałagan: średni'));
    expect(polishChipLabels, contains('Dziecko: mało'));
    expect(polishChipLabels, contains('Dziecko: średnio'));
    expect(polishChipLabels, contains('Dziecko: dużo'));
    expect(polishChipLabels, contains('Rodzic: mało'));
    expect(polishChipLabels, contains('Rodzic: średnio'));
    expect(polishChipLabels, contains('Rodzic: dużo'));
    expect(polishChipLabels, isNot(contains('Mały bałagan')));
    expect(polishChipLabels, isNot(contains('Średni bałagan')));
    expect(polishChipLabels, isNot(contains('Dziecko: niskie')));
    expect(polishChipLabels, isNot(contains('Rodzic: niskie')));
    expect(polishChipLabels, isNot(contains('Ba?agan')));
    expect(polishChipLabels, isNot(contains('?rednio')));
  });

  test('Polish bundled content stays free of corrupted user-facing strings',
      () async {
    final package = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.polish),
    ).load();
    final strings = _collectPolishUserFacingStrings(package).toList();
    final joined = strings.join('\n');

    expect(strings, isNotEmpty);
    for (final value in strings) {
      expect(value.contains('?'), isFalse, reason: value);
      for (final fragment in [
        'mi?',
        '?ciere',
        '?y?',
        '??',
        'P??',
        '?cie',
        'ksi??',
        'cze??',
      ]) {
        expect(value.contains(fragment), isFalse, reason: value);
      }
    }

    for (final phrase in [
      'Koszyk miękkich skarbów',
      'Miękka ściereczka',
      'Drewniana łyżka',
      'Umieść',
      'Usiądź',
      'Ścieżka z poduszek',
      'Cichy kosz z książkami',
      'Droga z ręcznika',
      'Skarpetkowa pacynka mówi cześć',
      'Tunel z poduszek',
      'Obserwowanie pogody przez okno',
      'Ratowanie naklejek',
      'Przekładanie łyżką do kubka',
      'Nazywanie faktur prania',
      'Obserwowanie cieni',
      'Ratowanie zabawki spod koca',
    ]) {
      expect(joined, contains(phrase), reason: phrase);
    }

    for (final phrase in [
      'zapałek',
      'tabela wymaga',
      'Ręcznik do herbaty',
      'Okno zegarka',
      'Oferuj udane',
      'Obserwuje cień',
      'małą ilością ustawień',
    ]) {
      expect(joined, isNot(contains(phrase)), reason: phrase);
    }
  });

  test('bundled content asset path resolves English content for English', () {
    expect(
      bundledContentAssetPathFor(AppLanguage.english),
      'assets/content/nurtly_content_en_v1.json',
    );
  });

  test('bundled content asset path resolves Polish content to the PL asset',
      () {
    expect(
      bundledContentAssetPathFor(AppLanguage.polish),
      'assets/content/nurtly_content_pl_v1.json',
    );
  });

  test('bundled content source loads English content for English', () async {
    final package = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.english),
    ).load();

    expect(package.metadata.locale, 'en');
    expect(package.metadata.packageId, 'nurtly-core-en');
  });

  test('bundled content source loads Polish content for Polish', () async {
    final package = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.polish),
    ).load();

    expect(package.metadata.locale, 'pl');
    expect(package.metadata.packageId, 'nurtly-core-pl');
  });

  test('content metadata fields are production ready', () async {
    final package = await const ContentLoader().load();
    final metadata = package.metadata;

    expect(_isNotBlank(metadata.packageId), isTrue);
    expect(metadata.schemaVersion, 1);
    expect(_isNotBlank(metadata.version), isTrue);
    expect(_isNotBlank(metadata.locale), isTrue);
    expect(_isNotBlank(metadata.publishedAt), isTrue);
    expect(DateTime.tryParse(metadata.publishedAt), isNotNull);
    expect(_isNotBlank(metadata.minAppVersion), isTrue);
    expect(metadata.locale, 'en');
  });

  test('loads content from a custom content source', () async {
    final package = await const ContentLoader(
      source: _RawContentSource(_minimalContentPackageJson),
    ).load();

    expect(package.metadata.packageId, 'test-package');
    expect(package.playIdeas.single.id, 'play_test_idea');
    expect(package.playFilters.single.id, 'low_effort');
    expect(package.sounds.single.id, 'sound_test_sound');
    expect(package.sounds.single.artworkAssetPath,
        'assets/images/sounds/test_sound.webp');
  });

  test('missing sound artworkAssetPath parses as null', () async {
    final package = await const ContentLoader(
      source: _RawContentSource(_minimalContentPackageWithoutFiltersJson),
    ).load();

    expect(package.sounds.single.artworkAssetPath, isNull);
  });

  test('missing contexts parses as an empty list', () async {
    final package = await const ContentLoader(
      source: _RawContentSource(_minimalContentPackageWithoutContextsJson),
    ).load();

    expect(package.playIdeas.single.contexts, isEmpty);
  });

  test('missing suggestedSoundId parses as null', () async {
    final package = await const ContentLoader(
      source:
          _RawContentSource(_minimalContentPackageWithoutSuggestedSoundJson),
    ).load();

    expect(package.playIdeas.single.suggestedSoundId, isNull);
  });

  test('missing taxonomy throws FormatException', () async {
    final loader = ContentLoader(
      source: _RawContentSource(_minimalContentPackageWithoutTaxonomyJson),
    );

    await expectLater(loader.load(), throwsFormatException);
  });

  test('missing ageRangeMonths throws FormatException', () async {
    final loader = ContentLoader(
      source:
          _RawContentSource(_minimalContentPackageWithoutAgeRangeMonthsJson),
    );

    await expectLater(loader.load(), throwsFormatException);
  });

  test('invalid ageRangeMonths throws FormatException', () async {
    final loader = ContentLoader(
      source: _RawContentSource(_minimalContentPackageWithInvalidAgeRangeJson),
    );

    await expectLater(loader.load(), throwsFormatException);
  });

  test('missing playFilters parses as an empty list', () async {
    final package = await const ContentLoader(
      source: _RawContentSource(_minimalContentPackageWithoutFiltersJson),
    ).load();

    expect(package.playFilters, isEmpty);
  });

  test('malformed custom content source throws FormatException', () async {
    const loader = ContentLoader(
      source: _RawContentSource('{not-json'),
    );

    await expectLater(loader.load(), throwsFormatException);
  });

  test('play idea ids and titles are unique and well formed', () async {
    final package = await const ContentLoader().load();
    final ids = package.playIdeas.map((idea) => idea.id).toList();
    final titles = package.playIdeas
        .map((idea) => idea.title.trim().toLowerCase())
        .toList();

    expect(ids.toSet(), hasLength(ids.length));
    expect(titles.toSet(), hasLength(titles.length));
    for (final id in ids) {
      expect(id, startsWith('play_'));
      expect(id, id.toLowerCase());
    }
  });

  test('play filters are valid and include expected labels', () async {
    final package = await const ContentLoader().load();
    const supportedFields = {
      'parentInvolvement',
      'messLevel',
      'ageRangeMonths',
      'activityType',
      'childEngagement',
      'place',
      'contexts',
    };
    const taxonomyFields = {
      'parentInvolvement',
      'messLevel',
      'activityType',
      'childEngagement',
      'place',
      'contexts',
    };
    const supportedOperators = {'equals', 'contains', 'overlaps'};
    const expectedLabels = {
      'Low effort',
      'Low mess',
      'For babies',
      'Toddlers',
      'Preschool',
      'Movement',
      'Quiet',
    };

    expect(package.playFilters, isNotEmpty);

    final ids = package.playFilters.map((filter) => filter.id).toList();
    final labels = package.playFilters.map((filter) => filter.label).toSet();

    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, id.toLowerCase());
      expect(id, matches(r'^[a-z0-9_]+$'));
    }
    expect(labels, containsAll(expectedLabels));

    for (final filter in package.playFilters) {
      expect(_isNotBlank(filter.label), isTrue, reason: '${filter.id} label');
      expect(filter.rules, isNotEmpty, reason: '${filter.id} rules');
      expect(filter.matchMode.name, anyOf('all', 'any'));
      for (final rule in filter.rules) {
        expect(supportedFields, contains(rule.field),
            reason: '${filter.id} field');
        expect(supportedOperators, contains(rule.operator),
            reason: '${filter.id} operator');
        if (rule.operator == 'overlaps') {
          expect(rule.min, isNotNull, reason: '${filter.id} overlaps min');
          expect(rule.max, isNotNull, reason: '${filter.id} overlaps max');
        } else {
          expect(_isNotBlank(rule.value ?? ''), isTrue,
              reason: '${filter.id} value');
          if (taxonomyFields.contains(rule.field)) {
            expect(rule.value, isNotNull,
                reason: '${filter.id} taxonomy value');
            expect(rule.value, matches(r'^[a-z0-9_]+$'),
                reason: '${filter.id} taxonomy id');
          }
        }
      }
    }
  });

  test('sound ids are unique and well formed', () async {
    final package = await const ContentLoader().load();
    final ids = package.sounds.map((sound) => sound.id).toList();

    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, startsWith('sound_'));
      expect(id, id.toLowerCase());
    }
  });

  test('play ideas have required content fields', () async {
    final package = await const ContentLoader().load();
    final soundIds = package.sounds.map((sound) => sound.id).toSet();

    for (final idea in package.playIdeas) {
      expect(_isNotBlank(idea.id), isTrue, reason: '${idea.id} id');
      expect(_isNotBlank(idea.title), isTrue, reason: '${idea.id} title');
      expect(_isNotBlank(idea.summary), isTrue, reason: '${idea.id} summary');
      expect(_isNotBlank(idea.ageGroup), isTrue, reason: '${idea.id} ageGroup');
      expect(idea.ageRangeMonths.min, greaterThanOrEqualTo(0),
          reason: '${idea.id} ageRangeMonths min');
      expect(idea.ageRangeMonths.max,
          greaterThanOrEqualTo(idea.ageRangeMonths.min),
          reason: '${idea.id} ageRangeMonths max>=min');
      expect(idea.ageRangeMonths.max, lessThanOrEqualTo(96),
          reason: '${idea.id} ageRangeMonths max');
      expect(_isNotBlank(idea.place), isTrue, reason: '${idea.id} place');
      expect(_isNotBlank(idea.messLevel), isTrue,
          reason: '${idea.id} messLevel');
      expect(
        _isNotBlank(idea.childEngagement),
        isTrue,
        reason: '${idea.id} childEngagement',
      );
      expect(
        _isNotBlank(idea.parentInvolvement),
        isTrue,
        reason: '${idea.id} parentInvolvement',
      );
      expect(
        _isNotBlank(idea.activityType),
        isTrue,
        reason: '${idea.id} activityType',
      );
      expect(idea.contexts, isNotEmpty, reason: '${idea.id} contexts');
      expect(idea.neededItems, isNotEmpty, reason: '${idea.id} neededItems');
      expect(idea.steps, isNotEmpty, reason: '${idea.id} steps');
      expect(
        _isNotBlank(idea.whatToExpect),
        isTrue,
        reason: '${idea.id} whatToExpect',
      );
      expect(
        idea.whatToExpect.length,
        lessThanOrEqualTo(260),
        reason: '${idea.id} whatToExpect length',
      );
      expect(
        _isNotBlank(idea.parentNote),
        isTrue,
        reason: '${idea.id} parentNote',
      );
      expect(
        _isNotBlank(idea.safetyNote),
        isTrue,
        reason: '${idea.id} safetyNote',
      );
      expect(
        _isNotBlank(idea.unlockType),
        isTrue,
        reason: '${idea.id} unlockType',
      );
      expect(
        _isNotBlank(idea.suggestedSoundId ?? ''),
        isTrue,
        reason: '${idea.id} suggestedSoundId required',
      );
      expect(
        soundIds,
        contains(idea.suggestedSoundId),
        reason: '${idea.id} suggestedSoundId exists',
      );
    }
  });

  test('Polish play ageGroup labels match ageRangeMonths', () async {
    final package = await const ContentLoader(
      source: BundledContentSource(language: AppLanguage.polish),
    ).load();

    for (final idea in package.playIdeas) {
      expect(
        idea.ageGroup,
        _expectedPolishAgeGroupFor(idea),
        reason: '${idea.id} ageGroup',
      );
    }
  });

  test('play idea engagement values are controlled', () async {
    final package = await const ContentLoader().load();
    const allowedLevels = {
      'mess_low',
      'mess_medium',
      'child_engagement_low',
      'child_engagement_medium',
      'child_engagement_high',
      'parent_involvement_low',
      'parent_involvement_medium',
      'parent_involvement_high'
    };

    for (final idea in package.playIdeas) {
      expect(allowedLevels, contains(idea.messLevel),
          reason: '${idea.id} messLevel');
      expect(allowedLevels, contains(idea.childEngagement),
          reason: '${idea.id} childEngagement');
      expect(allowedLevels, contains(idea.parentInvolvement),
          reason: '${idea.id} parentInvolvement');
    }
  });

  test('play idea contexts are controlled and well formed', () async {
    final package = await const ContentLoader().load();
    const allowedContexts = {
      'context_home',
      'context_baby',
      'context_toddler',
      'context_preschool',
      'context_low_setup',
      'context_quiet',
      'context_movement',
      'context_sensory',
      'context_connection',
      'context_practical_life',
      'context_outside',
      'context_bathroom',
      'context_kitchen',
      'context_transition',
      'context_pretend',
    };

    for (final idea in package.playIdeas) {
      expect(idea.contexts.length, lessThanOrEqualTo(5),
          reason: '${idea.id} contexts length');
      expect(idea.contexts.toSet(), hasLength(idea.contexts.length),
          reason: '${idea.id} duplicate contexts');
      for (final context in idea.contexts) {
        expect(context, context.toLowerCase(),
            reason: '${idea.id} context lowercase');
        expect(context, matches(r'^[a-z0-9_]+$'),
            reason: '${idea.id} context snake_case');
        expect(allowedContexts, contains(context),
            reason: '${idea.id} allowed context');
      }
    }
  });

  test('play ideas avoid banned language', () async {
    final package = await const ContentLoader().load();
    const bannedTerms = [
      'diagnose',
      'treat',
      'therapy',
      'cure',
      'guaranteed',
      'milestone guarantee',
      'optimize development',
      'fix development',
      'delayed development',
      'autism',
      'ADHD',
      'medical',
    ];

    for (final idea in package.playIdeas) {
      final searchableText = [
        idea.title,
        idea.summary,
        ...idea.steps,
        idea.whatToExpect,
        idea.parentNote,
        idea.safetyNote,
      ].join(' ').toLowerCase();

      for (final term in bannedTerms) {
        expect(
          searchableText,
          isNot(contains(term.toLowerCase())),
          reason: '${idea.id} contains "$term"',
        );
      }
    }
  });

  test('play idea whatToExpect values are distinct', () async {
    final package = await const ContentLoader().load();
    final values = package.playIdeas
        .map((idea) => idea.whatToExpect.trim().toLowerCase())
        .toList();

    expect(values.toSet(), hasLength(values.length));
  });

  test('sounds have local audio assets and non-placeholder copy', () async {
    final package = await const ContentLoader().load();
    const expectedArtworkPathsById = {
      'sound_soft_rain': 'assets/images/sounds/soft_rain.webp',
      'sound_warm_noise': 'assets/images/sounds/warm_noise.webp',
      'sound_quiet_stream': 'assets/images/sounds/quiet_stream.webp',
      'sound_evening_crickets': 'assets/images/sounds/evening_crickets.webp',
      'sound_room_fan': 'assets/images/sounds/room_fan.webp',
      'sound_dishwasher_hum': 'assets/images/sounds/dishwasher_hum.webp',
    };

    expect(package.sounds, isNotEmpty);
    for (final sound in package.sounds) {
      expect(_isNotBlank(sound.title), isTrue, reason: '${sound.id} title');
      expect(_isNotBlank(sound.category), isTrue,
          reason: '${sound.id} category');
      expect(_isNotBlank(sound.summary), isTrue, reason: '${sound.id} summary');
      expect(_isNotBlank(sound.assetPath), isTrue,
          reason: '${sound.id} assetPath');
      expect(_isNotBlank(sound.unlockType), isTrue,
          reason: '${sound.id} unlockType');
      expect(sound.assetPath, startsWith('assets/audio/'));
      if (sound.id == 'sound_soft_rain') {
        expect(sound.assetPath, endsWith('.ogg'));
      } else {
        expect(sound.assetPath, endsWith('.mp3'));
      }
      expect(sound.artworkAssetPath, isNotNull,
          reason: '${sound.id} artworkAssetPath');
      expect(sound.artworkAssetPath, startsWith('assets/images/sounds/'));
      expect(sound.artworkAssetPath, endsWith('.webp'));
      expect(sound.artworkAssetPath, expectedArtworkPathsById[sound.id]);
      expect(sound.summary.toLowerCase(), isNot(contains('placeholder')));
      expect(sound.summary.toLowerCase(), isNot(contains('future')));
      expect(
        {'free', 'premium'},
        contains(sound.unlockType),
        reason: '${sound.id} unlockType',
      );
    }
  });

  test('bundled content includes premium play and sound items', () async {
    final packages = await Future.wait([
      const ContentLoader(
        source: BundledContentSource(language: AppLanguage.english),
      ).load(),
      const ContentLoader(
        source: BundledContentSource(language: AppLanguage.polish),
      ).load(),
    ]);

    for (final package in packages) {
      expect(
        package.playIdeas.any((idea) => idea.unlockType == 'premium'),
        isTrue,
      );
      expect(
        package.sounds.any((sound) => sound.unlockType == 'premium'),
        isTrue,
      );

      final soundsById = {
        for (final sound in package.sounds) sound.id: sound,
      };
      for (final idea in package.playIdeas) {
        if (idea.unlockType == 'free' && idea.suggestedSoundId != null) {
          final suggestedSound = soundsById[idea.suggestedSoundId];
          expect(
            suggestedSound,
            isNotNull,
            reason: idea.id,
          );
          expect(
            suggestedSound!.unlockType,
            'free',
            reason: idea.id,
          );
        }
      }
    }
  });

  test('taxonomy covers current play and sound labels', () async {
    final package = await const ContentLoader().load();
    final taxonomy = package.taxonomy;

    final placeIds = taxonomy.places.map((term) => term.id).toSet();
    final messIds = taxonomy.messLevels.map((term) => term.id).toSet();
    final childEngagementIds =
        taxonomy.childEngagementLevels.map((term) => term.id).toSet();
    final parentInvolvementIds =
        taxonomy.parentInvolvementLevels.map((term) => term.id).toSet();
    final activityTypeIds =
        taxonomy.activityTypes.map((term) => term.id).toSet();
    final contextIds = taxonomy.contexts.map((term) => term.id).toSet();
    final soundCategoryLabels =
        taxonomy.soundCategories.map((term) => term.label).toSet();

    for (final idea in package.playIdeas) {
      expect(placeIds, contains(idea.place), reason: '${idea.id} place');
      expect(messIds, contains(idea.messLevel), reason: '${idea.id} messLevel');
      expect(childEngagementIds, contains(idea.childEngagement),
          reason: '${idea.id} childEngagement');
      expect(parentInvolvementIds, contains(idea.parentInvolvement),
          reason: '${idea.id} parentInvolvement');
      expect(activityTypeIds, contains(idea.activityType),
          reason: '${idea.id} activityType');
      for (final context in idea.contexts) {
        expect(contextIds, contains(context), reason: '${idea.id} context');
      }
    }

    for (final sound in package.sounds) {
      expect(soundCategoryLabels, contains(sound.category),
          reason: '${sound.id} category');
    }
  });
}

bool _isNotBlank(String value) => value.trim().isNotEmpty;

List<String> _ids(Iterable<String> values) => values.toList();

List<String> _labels(Iterable<TaxonomyTerm> terms) =>
    terms.map((term) => term.label).toList();

List<String> _chipLabels(Iterable<TaxonomyTerm> terms) =>
    terms.map((term) => term.chipLabel ?? term.label).toList();

List<String> _taxonomyIds(ContentTaxonomy taxonomy) => [
      ..._ids(taxonomy.places.map((term) => term.id)),
      ..._ids(taxonomy.messLevels.map((term) => term.id)),
      ..._ids(taxonomy.childEngagementLevels.map((term) => term.id)),
      ..._ids(taxonomy.parentInvolvementLevels.map((term) => term.id)),
      ..._ids(taxonomy.activityTypes.map((term) => term.id)),
      ..._ids(taxonomy.contexts.map((term) => term.id)),
      ..._ids(taxonomy.soundCategories.map((term) => term.id)),
    ];

List<String?> _suggestedSoundIds(Iterable<PlayIdea> ideas) =>
    ideas.map((idea) => idea.suggestedSoundId).toList();

Map<String, String> _soundAssetMap(Iterable<SoundItem> sounds) => {
      for (final sound in sounds)
        sound.id: '${sound.assetPath}|${sound.artworkAssetPath ?? ''}'
    };

Map<String, String> _unlockTypeMap(Iterable<PlayIdea> ideas) => {
      for (final idea in ideas) idea.id: idea.unlockType,
    };

Map<String, String> _soundUnlockTypeMap(Iterable<SoundItem> sounds) => {
      for (final sound in sounds) sound.id: sound.unlockType,
    };

double _premiumRatio(Iterable<Object> items) {
  final values = items.toList();
  if (values.isEmpty) {
    return 0;
  }

  final premiumCount = values.where((item) {
    final unlockType = item is PlayIdea
        ? item.unlockType
        : item is SoundItem
            ? item.unlockType
            : '';
    return unlockType.trim().toLowerCase() == 'premium';
  }).length;
  return premiumCount / values.length;
}

String _expectedPolishAgeGroupFor(PlayIdea idea) {
  final min = idea.ageRangeMonths.min;
  final max = idea.ageRangeMonths.max;

  return switch ((min, max)) {
    (0, 12) => '0–12 miesięcy',
    (0, 60) => '0–5 lat',
    (6, 18) => '6–18 miesięcy',
    (12, 36) => '12 miesięcy–3 lata',
    (18, 36) => '18 miesięcy–3 lata',
    (18, 48) => '18 miesięcy–4 lata',
    (18, 60) => '18 miesięcy–5 lat',
    (24, 48) => '2–4 lata',
    (24, 60) => '2–5 lat',
    (36, 72) => '3–6 lat',
    _ => throw StateError(
        'Unsupported Polish age range for ${idea.id}: $min–$max',
      ),
  };
}

Iterable<String> _collectPolishUserFacingStrings(ContentPackage package) sync* {
  for (final term in package.taxonomy.places) {
    yield term.label;
    if (term.chipLabel != null) {
      yield term.chipLabel!;
    }
  }
  for (final term in package.taxonomy.messLevels) {
    yield term.label;
    if (term.chipLabel != null) {
      yield term.chipLabel!;
    }
  }
  for (final term in package.taxonomy.childEngagementLevels) {
    yield term.label;
    if (term.chipLabel != null) {
      yield term.chipLabel!;
    }
  }
  for (final term in package.taxonomy.parentInvolvementLevels) {
    yield term.label;
    if (term.chipLabel != null) {
      yield term.chipLabel!;
    }
  }
  for (final term in package.taxonomy.activityTypes) {
    yield term.label;
    if (term.chipLabel != null) {
      yield term.chipLabel!;
    }
  }
  for (final term in package.taxonomy.contexts) {
    yield term.label;
    if (term.chipLabel != null) {
      yield term.chipLabel!;
    }
  }
  for (final term in package.taxonomy.soundCategories) {
    yield term.label;
    if (term.chipLabel != null) {
      yield term.chipLabel!;
    }
  }
  for (final filter in package.playFilters) {
    yield filter.label;
  }
  for (final idea in package.playIdeas) {
    yield idea.title;
    yield idea.summary;
    yield idea.ageGroup;
    for (final item in idea.neededItems) {
      yield item;
    }
    for (final item in idea.steps) {
      yield item;
    }
    yield idea.whatToExpect;
    yield idea.parentNote;
    yield idea.safetyNote;
  }
  for (final sound in package.sounds) {
    yield sound.title;
    yield sound.summary;
  }
}

class _RawContentSource implements ContentSource {
  const _RawContentSource(this.content);

  final String content;

  @override
  Future<String> loadRawContent() async => content;
}

const _minimalContentPackageJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "taxonomy": $_taxonomyJson,
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 24,
        "max": 60
      },
      "place": "place_home",
      "messLevel": "mess_low",
      "childEngagement": "child_engagement_low",
      "parentInvolvement": "parent_involvement_low",
      "activityType": "activity_quiet_time",
      "contexts": ["context_home", "context_quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "parent_involvement_low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "artworkAssetPath": "assets/images/sounds/test_sound.webp",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithoutFiltersJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "taxonomy": $_taxonomyJson,
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 24,
        "max": 60
      },
      "place": "place_home",
      "messLevel": "mess_low",
      "childEngagement": "child_engagement_low",
      "parentInvolvement": "parent_involvement_low",
      "activityType": "activity_quiet_time",
      "contexts": ["context_home", "context_quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithoutContextsJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "taxonomy": $_taxonomyJson,
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 24,
        "max": 60
      },
      "place": "place_home",
      "messLevel": "mess_low",
      "childEngagement": "child_engagement_low",
      "parentInvolvement": "parent_involvement_low",
      "activityType": "activity_quiet_time",
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "parent_involvement_low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithoutAgeRangeMonthsJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "taxonomy": $_taxonomyJson,
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "place": "place_home",
      "messLevel": "mess_low",
      "childEngagement": "child_engagement_low",
      "parentInvolvement": "parent_involvement_low",
      "activityType": "activity_quiet_time",
      "contexts": ["context_home", "context_quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "parent_involvement_low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithoutSuggestedSoundJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "taxonomy": $_taxonomyJson,
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 24,
        "max": 60
      },
      "place": "place_home",
      "messLevel": "mess_low",
      "childEngagement": "child_engagement_low",
      "parentInvolvement": "parent_involvement_low",
      "activityType": "activity_quiet_time",
      "contexts": ["context_home", "context_quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "parent_involvement_low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithoutTaxonomyJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 24,
        "max": 60
      },
      "place": "place_home",
      "messLevel": "mess_low",
      "childEngagement": "child_engagement_low",
      "parentInvolvement": "parent_involvement_low",
      "activityType": "activity_quiet_time",
      "contexts": ["context_home", "context_quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "parent_involvement_low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _minimalContentPackageWithInvalidAgeRangeJson = '''
{
  "metadata": {
    "packageId": "test-package",
    "schemaVersion": 1,
    "version": "1.0.0",
    "locale": "en",
    "publishedAt": "2026-05-18",
    "minAppVersion": "0.1.0"
  },
  "taxonomy": $_taxonomyJson,
  "playIdeas": [
    {
      "id": "play_test_idea",
      "title": "Test idea",
      "summary": "A calm test idea.",
      "ageGroup": "2-5 years",
      "ageRangeMonths": {
        "min": 36,
        "max": 24
      },
      "place": "place_home",
      "messLevel": "mess_low",
      "childEngagement": "child_engagement_low",
      "parentInvolvement": "parent_involvement_low",
      "activityType": "activity_quiet_time",
      "contexts": ["context_home", "context_quiet"],
      "neededItems": ["Soft cloth"],
      "steps": ["Place the item nearby."],
      "whatToExpect": "A simple test note for content loading.",
      "parentNote": "Keep it simple.",
      "safetyNote": "Use safe items."
    }
  ],
  "playFilters": [
    {
      "id": "low_effort",
      "label": "Low effort",
      "matchMode": "all",
      "rules": [
        {
          "field": "parentInvolvement",
          "operator": "equals",
          "value": "parent_involvement_low"
        }
      ]
    }
  ],
  "sounds": [
    {
      "id": "sound_test_sound",
      "title": "Test sound",
      "category": "Calm",
      "summary": "A placeholder sound.",
      "assetPath": "placeholder://sounds/test_sound",
      "unlockType": "free"
    }
  ]
}
''';

const _taxonomyJson = '''
{
  "places": [
    { "id": "place_home", "label": "Home" },
    { "id": "place_floor", "label": "Floor" },
    { "id": "place_kitchen", "label": "Kitchen" },
    { "id": "place_living_room", "label": "Living room" },
    { "id": "place_bedroom", "label": "Bedroom" },
    { "id": "place_outside", "label": "Outside" },
    { "id": "place_bathroom", "label": "Bathroom" },
    { "id": "place_table", "label": "Table" },
    { "id": "place_sofa", "label": "Sofa" },
    { "id": "place_window", "label": "Window" },
    { "id": "place_any_quiet_spot", "label": "Any quiet spot" },
    { "id": "place_hallway", "label": "Hallway" }
  ],
  "messLevels": [
    { "id": "mess_low", "label": "Low" },
    { "id": "mess_medium", "label": "Medium" }
  ],
  "childEngagementLevels": [
    { "id": "child_engagement_low", "label": "Low" },
    { "id": "child_engagement_medium", "label": "Medium" },
    { "id": "child_engagement_high", "label": "High" }
  ],
  "parentInvolvementLevels": [
    { "id": "parent_involvement_low", "label": "Low" },
    { "id": "parent_involvement_medium", "label": "Medium" },
    { "id": "parent_involvement_high", "label": "High" }
  ],
  "activityTypes": [
    { "id": "activity_connection", "label": "Connection" },
    { "id": "activity_fine_motor", "label": "Fine motor" },
    { "id": "activity_imaginative_play", "label": "Imaginative play" },
    { "id": "activity_language", "label": "Language" },
    { "id": "activity_movement", "label": "Movement" },
    { "id": "activity_music", "label": "Music" },
    { "id": "activity_observation", "label": "Observation" },
    { "id": "activity_practical_life", "label": "Practical life" },
    { "id": "activity_quiet_time", "label": "Quiet time" },
    { "id": "activity_sensory", "label": "Sensory" },
    { "id": "activity_sorting", "label": "Sorting" }
  ],
  "contexts": [
    { "id": "context_home", "label": "home" },
    { "id": "context_baby", "label": "baby" },
    { "id": "context_sensory", "label": "sensory" },
    { "id": "context_low_setup", "label": "low_setup" },
    { "id": "context_toddler", "label": "toddler" },
    { "id": "context_movement", "label": "movement" },
    { "id": "context_kitchen", "label": "kitchen" },
    { "id": "context_practical_life", "label": "practical_life" },
    { "id": "context_quiet", "label": "quiet" },
    { "id": "context_transition", "label": "transition" },
    { "id": "context_preschool", "label": "preschool" },
    { "id": "context_pretend", "label": "pretend" },
    { "id": "context_connection", "label": "connection" },
    { "id": "context_outside", "label": "outside" },
    { "id": "context_bathroom", "label": "bathroom" }
  ],
  "soundCategories": [
    { "id": "sound_category_calm", "label": "Calm" },
    { "id": "sound_category_home", "label": "Home" },
    { "id": "sound_category_nature", "label": "Nature" },
    { "id": "sound_category_white_noise", "label": "White noise" }
  ]
}
''';

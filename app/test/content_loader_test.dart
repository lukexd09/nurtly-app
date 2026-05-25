import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/bundled_content_source.dart';
import 'package:nurtly/core/content/content_loader.dart';
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

    final polishLabels = [
      ..._labels(polish.taxonomy.places),
      ..._labels(polish.taxonomy.messLevels),
      ..._labels(polish.taxonomy.activityTypes),
      ..._labels(polish.taxonomy.contexts),
      ..._labels(polish.taxonomy.soundCategories),
    ];
    expect(polishLabels.any((label) => label.contains('?')), isFalse);
    expect(polishLabels, contains('\u0141azienka'));
    expect(polishLabels, contains('Pod\u0142oga'));
    expect(polishLabels, contains('\u015aredni ba\u0142agan'));
    expect(polishLabels, contains('Blisko\u015b\u0107'));
    expect(polishLabels, contains('J\u0119zyk'));
    expect(polishLabels, contains('Codzienno\u015b\u0107'));
    expect(polishLabels, contains('niemowl\u0119'));
    expect(polishLabels, contains('ma\u0142o przygotowa\u0144'));

    final polishChipLabels = [
      ..._chipLabels(polish.taxonomy.messLevels),
      ..._chipLabels(polish.taxonomy.childEngagementLevels),
      ..._chipLabels(polish.taxonomy.parentInvolvementLevels),
    ];
    expect(polishChipLabels.any((label) => label.contains('?')), isFalse);
    expect(polishChipLabels, contains('Mały bałagan'));
    expect(polishChipLabels, contains('Średni bałagan'));
    expect(polishChipLabels, contains('Dziecko: średnie'));
    expect(polishChipLabels, contains('Rodzic: średnie'));
  });
}

List<String> _ids(Iterable<String> values) => values.toList();

List<String> _taxonomyIds(ContentTaxonomy taxonomy) => [
      for (final term in [
        ...taxonomy.places,
        ...taxonomy.messLevels,
        ...taxonomy.childEngagementLevels,
        ...taxonomy.parentInvolvementLevels,
        ...taxonomy.activityTypes,
        ...taxonomy.contexts,
        ...taxonomy.soundCategories,
      ])
        term.id,
    ];

List<String> _labels(Iterable<TaxonomyTerm> terms) =>
    terms.map((term) => term.label).toList();

List<String> _chipLabels(Iterable<TaxonomyTerm> terms) =>
    terms.map((term) => term.chipLabel ?? term.label).toList();

List<String?> _suggestedSoundIds(Iterable<PlayIdea> playIdeas) =>
    playIdeas.map((idea) => idea.suggestedSoundId).toList();

Map<String, String?> _soundAssetMap(Iterable<SoundItem> sounds) => {
      for (final sound in sounds) sound.id: sound.artworkAssetPath,
    };

bool _isNotBlank(String value) => value.trim().isNotEmpty;

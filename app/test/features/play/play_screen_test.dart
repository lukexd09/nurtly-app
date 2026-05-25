import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
import 'package:nurtly/core/content/content_taxonomy.dart';
import 'package:nurtly/core/content/play_filter.dart';
import 'package:nurtly/core/content/play_idea.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/features/play/play_screen.dart';

import '../../test_fakes/fake_content_loader.dart';

void main() {
  test('selectDailyPlayIdea is deterministic for a given day', () {
    const ideas = [
      PlayIdea(
        id: 'play_a',
        title: 'A',
        summary: 'A',
        ageGroup: '0-5 years',
        ageRangeMonths: AgeRangeMonths(min: 0, max: 60),
        place: 'place_home',
        messLevel: 'mess_low',
        childEngagement: 'child_engagement_low',
        parentInvolvement: 'parent_involvement_low',
        activityType: 'activity_quiet_time',
        contexts: ['context_home'],
        neededItems: ['A'],
        steps: ['A'],
        whatToExpect: 'A',
        parentNote: 'A',
        safetyNote: 'A',
      ),
      PlayIdea(
        id: 'play_b',
        title: 'B',
        summary: 'B',
        ageGroup: '0-5 years',
        ageRangeMonths: AgeRangeMonths(min: 0, max: 60),
        place: 'place_home',
        messLevel: 'mess_low',
        childEngagement: 'child_engagement_low',
        parentInvolvement: 'parent_involvement_low',
        activityType: 'activity_quiet_time',
        contexts: ['context_home'],
        neededItems: ['B'],
        steps: ['B'],
        whatToExpect: 'B',
        parentNote: 'B',
        safetyNote: 'B',
      ),
    ];

    final first = selectDailyPlayIdea(ideas, DateTime(2026, 5, 21));
    final second = selectDailyPlayIdea(ideas, DateTime(2026, 5, 21));

    expect(first.id, second.id);
  });

  testWidgets('filters are collapsed by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
      ),
    );
    await tester.pump();

    expect(find.text('Find the right fit'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Low effort'), findsNothing);
    expect(find.text('Soft treasure basket'), findsOneWidget);
    expect(find.text('Couch cushion tunnel'), findsOneWidget);
  });

  testWidgets('no selected filters shows all ideas after expanding', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Find the right fit'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilterChip, 'Low effort'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Low mess'), findsOneWidget);
    expect(find.text('Soft treasure basket'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Couch cushion tunnel'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Couch cushion tunnel'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Indoor march'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Indoor march'), findsOneWidget);
  });

  testWidgets('low mess filter narrows results', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Find the right fit'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Low mess'));
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Quiet book basket'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quiet book basket'), findsOneWidget);
    expect(find.text('Couch cushion tunnel'), findsNothing);
    expect(find.text('Indoor march'), findsNothing);
    expect(find.text('2 gentle ideas'), findsOneWidget);
  });

  testWidgets('low mess and for babies use AND logic', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Find the right fit'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Low mess'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'For babies'));
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
    expect(find.text('Couch cushion tunnel'), findsNothing);
    expect(find.text('2 gentle ideas'), findsOneWidget);
  });

  testWidgets('toggling a selected chip off updates results', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Find the right fit'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Low mess'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'For babies'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'For babies'));
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Quiet book basket'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quiet book basket'), findsOneWidget);
    expect(find.text('2 gentle ideas'), findsOneWidget);
  });

  testWidgets(
    'clear action appears only when active and restores all ideas',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(TextButton, 'Find the right fit'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, 'Clear'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'Low effort'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, 'Clear'), findsOneWidget);
      expect(find.text('Soft treasure basket'), findsOneWidget);
      expect(find.text('Couch cushion tunnel'), findsNothing);

      await tester.tap(find.widgetWithText(TextButton, 'Clear'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, 'Clear'), findsNothing);
      expect(find.text('Soft treasure basket'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Couch cushion tunnel'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Couch cushion tunnel'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Indoor march'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Indoor march'), findsOneWidget);
    },
  );

  testWidgets('detail navigation still works after filtering', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Find the right fit'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Low effort'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soft treasure basket'));
    await tester.pumpAndSettle();

    expect(find.text('What to expect'), findsOneWidget);
    expect(
      find.textContaining('low-mess, gently engaging activity'),
      findsOneWidget,
    );
  });

  testWidgets('opens play activity detail from the play list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: FakeContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Soft treasure basket'));
    await tester.pumpAndSettle();

    expect(find.text('What to expect'), findsOneWidget);
    expect(
      find.text(
        'This is a low-mess, gently engaging activity with very little setup. Stay nearby, offer simple guidance, and let your child explore at their own pace.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
  });

  testWidgets('renders English metadata chips without mixed fragments', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(
          contentLoader: _LocalizedMetadataContentLoader(
            taxonomy: _englishMetadataTaxonomy,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Mess: low'), findsOneWidget);
    expect(find.text('Child: medium'), findsOneWidget);
    expect(find.text('Parent: low'), findsOneWidget);
    expect(find.text('Low mess'), findsNothing);
    expect(find.text('Medium mess'), findsNothing);
    expect(find.text('Child: low'), findsNothing);
    expect(find.text('Parent: medium'), findsNothing);
  });

  testWidgets('renders Polish metadata chips without mixed fragments', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(
          contentLoader: _LocalizedMetadataContentLoader(
            taxonomy: _polishMetadataTaxonomy,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Bałagan: mały'), findsOneWidget);
    expect(find.text('Dziecko: średnio'), findsOneWidget);
    expect(find.text('Rodzic: mało'), findsOneWidget);
    expect(find.text('Mały bałagan'), findsNothing);
    expect(find.text('Średni bałagan'), findsNothing);
    expect(find.text('Dziecko: niskie'), findsNothing);
    expect(find.text('Rodzic: niskie'), findsNothing);
  });

  testWidgets('renders play detail content and hero hierarchy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayActivityDetailScreen(
          strings: AppStrings.english,
          idea: PlayIdea(
            id: 'play_artwork_test',
            title: 'Artwork idea',
            summary: 'A gentle play idea with rich hierarchy.',
            ageGroup: '2-5 years',
            ageRangeMonths: AgeRangeMonths(min: 24, max: 60),
            place: 'place_home',
            messLevel: 'mess_low',
            childEngagement: 'child_engagement_low',
            parentInvolvement: 'parent_involvement_low',
            activityType: 'activity_quiet_time',
            contexts: ['context_home', 'context_quiet'],
            neededItems: ['Soft cloth'],
            steps: ['Place the item nearby.'],
            whatToExpect: 'A calm test note for content loading.',
            parentNote: 'Keep it simple.',
            safetyNote: 'Use safe items.',
          ),
          taxonomy: _testTaxonomy,
        ),
      ),
    );

    expect(find.text('Artwork idea'), findsOneWidget);
    expect(
        find.text('A gentle play idea with rich hierarchy.'), findsOneWidget);
    expect(find.text('What to expect'), findsOneWidget);
    expect(find.text('What you\'ll need'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Parent note'), 120);
    await tester.pump();

    expect(find.text('Parent note'), findsOneWidget);
    expect(find.text('Safety note'), findsOneWidget);
  });

  testWidgets('uses taxonomy labels in fallback expectation summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlayActivityDetailScreen(
          strings: AppStrings.english,
          idea: PlayIdea(
            id: 'play_fallback_expectation',
            title: 'Fallback expectation idea',
            summary: 'A gentle play idea with taxonomy-driven fallback copy.',
            ageGroup: '2-5 years',
            ageRangeMonths: AgeRangeMonths(min: 24, max: 60),
            place: 'place_home',
            messLevel: 'mess_low',
            childEngagement: 'child_engagement_low',
            parentInvolvement: 'parent_involvement_low',
            activityType: 'activity_quiet_time',
            contexts: ['context_home', 'context_quiet'],
            neededItems: ['Soft cloth'],
            steps: ['Place the item nearby.'],
            whatToExpect: '',
            parentNote: 'Keep it simple.',
            safetyNote: 'Use safe items.',
          ),
          taxonomy: _testTaxonomy,
        ),
      ),
    );

    expect(find.text('What to expect'), findsOneWidget);
    expect(
      find.text(
        'A quiet, low-mess activity that does not need much setup. Stay nearby, offer gentle guidance, and let your child explore at their own pace.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('mess_low'), findsNothing);
    expect(find.textContaining('child_engagement_low'), findsNothing);
    expect(find.textContaining('parent_involvement_low'), findsNothing);
    expect(find.textContaining('place_home'), findsNothing);
    expect(find.textContaining('activity_quiet_time'), findsNothing);
    expect(find.textContaining('context_quiet'), findsNothing);
  });

  testWidgets(
    'renders suggested sound mini player with artwork when available',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayActivityDetailScreen(
            strings: AppStrings.english,
            idea: PlayIdea(
              id: 'play_artwork_test',
              title: 'Artwork idea',
              summary: 'A gentle play idea with rich hierarchy.',
              ageGroup: '2-5 years',
              ageRangeMonths: AgeRangeMonths(min: 24, max: 60),
              place: 'place_home',
              messLevel: 'mess_low',
              childEngagement: 'child_engagement_low',
              parentInvolvement: 'parent_involvement_low',
              activityType: 'activity_quiet_time',
              contexts: ['context_home', 'context_quiet'],
              neededItems: ['Soft cloth'],
              steps: ['Place the item nearby.'],
              whatToExpect: 'A calm test note for content loading.',
              suggestedSoundId: 'sound_soft_rain',
              parentNote: 'Keep it simple.',
              safetyNote: 'Use safe items.',
            ),
            suggestedSound: SoundItem(
              id: 'sound_soft_rain',
              title: 'Soft rain',
              category: 'Nature',
              summary: 'Gentle rain for a calmer background.',
              assetPath: 'assets/audio/soft_rain.mp3',
              artworkAssetPath: 'assets/images/sounds/soft_rain.webp',
              unlockType: 'free',
            ),
            taxonomy: _testTaxonomy,
          ),
        ),
      );

      expect(
          find.byKey(const ValueKey('play-suggested-sound')), findsOneWidget);
      expect(find.text('Suggested sound'), findsOneWidget);
      expect(find.text('Soft rain'), findsOneWidget);
      expect(find.byKey(const ValueKey('play-suggested-sound-control')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('play-suggested-sound-artwork')),
          findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) {
          final image = widget is Image ? widget.image : null;
          return image is AssetImage &&
              image.assetName == 'assets/images/sounds/soft_rain.webp';
        }),
        findsOneWidget,
      );
      expect(find.byTooltip('Back'), findsOneWidget);
    },
  );

  testWidgets(
    'hides suggested sound mini player when no matching sound exists',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayScreen(contentLoader: _MissingSuggestedSoundLoader()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Suggested soundless play'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('play-suggested-sound')), findsNothing);
      expect(find.text('Suggested sound'), findsNothing);
      expect(find.text('What to expect'), findsOneWidget);
    },
  );

  testWidgets(
    'hides suggested sound mini player when suggested sound is absent',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayActivityDetailScreen(
            strings: AppStrings.english,
            idea: PlayIdea(
              id: 'play_without_sound',
              title: 'Soundless play',
              summary: 'A gentle play idea without a suggested sound.',
              ageGroup: '2-5 years',
              ageRangeMonths: AgeRangeMonths(min: 24, max: 60),
              place: 'place_home',
              messLevel: 'mess_low',
              childEngagement: 'child_engagement_low',
              parentInvolvement: 'parent_involvement_low',
              activityType: 'activity_quiet_time',
              contexts: ['context_home', 'context_quiet'],
              neededItems: ['Soft cloth'],
              steps: ['Place the item nearby.'],
              whatToExpect: 'A calm test note for content loading.',
              parentNote: 'Keep it simple.',
              safetyNote: 'Use safe items.',
            ),
            taxonomy: _testTaxonomy,
          ),
        ),
      );

      expect(find.byKey(const ValueKey('play-suggested-sound')), findsNothing);
      expect(find.text('Suggested sound'), findsNothing);
      expect(find.text('What to expect'), findsOneWidget);
    },
  );

  testWidgets(
    'renders suggested sound fallback artwork when artwork is missing',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PlayActivityDetailScreen(
            strings: AppStrings.english,
            idea: PlayIdea(
              id: 'play_fallback_test',
              title: 'Fallback idea',
              summary: 'A gentle play idea with fallback artwork.',
              ageGroup: '2-5 years',
              ageRangeMonths: AgeRangeMonths(min: 24, max: 60),
              place: 'place_home',
              messLevel: 'mess_low',
              childEngagement: 'child_engagement_low',
              parentInvolvement: 'parent_involvement_low',
              activityType: 'activity_quiet_time',
              contexts: ['context_home', 'context_quiet'],
              neededItems: ['Soft cloth'],
              steps: ['Place the item nearby.'],
              whatToExpect: 'A calm test note for content loading.',
              parentNote: 'Keep it simple.',
              safetyNote: 'Use safe items.',
            ),
            suggestedSound: SoundItem(
              id: 'sound_soft_rain',
              title: 'Soft rain',
              category: 'Nature',
              summary: 'Gentle rain for a calmer background.',
              assetPath: 'assets/audio/soft_rain.mp3',
              unlockType: 'free',
            ),
            taxonomy: _testTaxonomy,
          ),
        ),
      );

      expect(find.byKey(const ValueKey('play-suggested-sound-artwork')),
          findsOneWidget);
      expect(find.byIcon(Icons.waves_rounded), findsOneWidget);
    },
  );
}

class _PlayFilterContentLoader extends ContentLoader {
  const _PlayFilterContentLoader();

  @override
  Future<ContentPackage> load() async {
    return const ContentPackage(
      metadata: ContentMetadata(
        packageId: 'test',
        schemaVersion: 1,
        version: '1.1.0',
        locale: 'en',
        publishedAt: '2026-05-18',
        minAppVersion: '0.1.0',
      ),
      taxonomy: _testTaxonomy,
      playFilters: [
        PlayFilter(
          id: 'low_effort',
          label: 'Low effort',
          matchMode: PlayFilterMatchMode.all,
          rules: [
            PlayFilterRule(
              field: 'parentInvolvement',
              operator: 'equals',
              value: 'parent_involvement_low',
            ),
          ],
        ),
        PlayFilter(
          id: 'low_mess',
          label: 'Low mess',
          matchMode: PlayFilterMatchMode.all,
          rules: [
            PlayFilterRule(
              field: 'messLevel',
              operator: 'equals',
              value: 'mess_low',
            ),
          ],
        ),
        PlayFilter(
          id: 'for_babies',
          label: 'For babies',
          matchMode: PlayFilterMatchMode.all,
          rules: [
            PlayFilterRule(
              field: 'ageRangeMonths',
              operator: 'overlaps',
              min: 0,
              max: 18,
            ),
          ],
        ),
        PlayFilter(
          id: 'toddlers',
          label: 'Toddlers',
          matchMode: PlayFilterMatchMode.all,
          rules: [
            PlayFilterRule(
              field: 'ageRangeMonths',
              operator: 'overlaps',
              min: 12,
              max: 36,
            ),
          ],
        ),
        PlayFilter(
          id: 'preschool',
          label: 'Preschool',
          matchMode: PlayFilterMatchMode.all,
          rules: [
            PlayFilterRule(
              field: 'ageRangeMonths',
              operator: 'overlaps',
              min: 36,
              max: 72,
            ),
          ],
        ),
        PlayFilter(
          id: 'movement',
          label: 'Movement',
          matchMode: PlayFilterMatchMode.all,
          rules: [
            PlayFilterRule(
              field: 'contexts',
              operator: 'contains',
              value: 'context_movement',
            ),
          ],
        ),
        PlayFilter(
          id: 'quiet',
          label: 'Quiet',
          matchMode: PlayFilterMatchMode.all,
          rules: [
            PlayFilterRule(
              field: 'contexts',
              operator: 'contains',
              value: 'context_quiet',
            ),
          ],
        ),
      ],
      playIdeas: [
        PlayIdea(
          id: 'play_soft_treasure_basket',
          title: 'Soft treasure basket',
          summary: 'Offer a few safe household textures to explore together.',
          ageGroup: '6-18 months',
          ageRangeMonths: AgeRangeMonths(min: 6, max: 18),
          place: 'place_home',
          messLevel: 'mess_low',
          childEngagement: 'child_engagement_medium',
          parentInvolvement: 'parent_involvement_low',
          activityType: 'activity_sensory',
          contexts: [
            'context_home',
            'context_baby',
            'context_sensory',
            'context_low_setup'
          ],
          neededItems: ['Soft cloth'],
          steps: ['Place the items in the container.'],
          whatToExpect:
              'A low-mess, gently engaging activity with very little setup. Stay nearby, offer simple guidance, and let your child explore at their own pace.',
          suggestedSoundId: 'sound_soft_rain',
          parentNote: 'Choose what fits the moment and keep it simple.',
          safetyNote: 'Use only large, clean items that cannot be swallowed.',
        ),
        PlayIdea(
          id: 'play_couch_cushion_tunnel',
          title: 'Couch cushion tunnel',
          summary:
              'Make a small tunnel for crawling, peeking, or passing a toy.',
          ageGroup: '18 months-3 years',
          ageRangeMonths: AgeRangeMonths(min: 18, max: 36),
          place: 'place_floor',
          messLevel: 'mess_medium',
          childEngagement: 'child_engagement_high',
          parentInvolvement: 'parent_involvement_medium',
          activityType: 'activity_movement',
          contexts: ['context_home', 'context_toddler', 'context_movement'],
          neededItems: ['Couch cushions'],
          steps: ['Place cushions on the floor with a low open space.'],
          whatToExpect:
              'Expect more movement and a little room reset afterward. Join for a few minutes, then keep the tunnel simple.',
          suggestedSoundId: 'sound_warm_noise',
          parentNote: 'A short setup can be enough.',
          safetyNote: 'Keep the tunnel low and stable.',
        ),
        PlayIdea(
          id: 'play_quiet_book_basket',
          title: 'Quiet book basket',
          summary: 'Set out a small basket of books for a calm shared pause.',
          ageGroup: '0-5 years',
          ageRangeMonths: AgeRangeMonths(min: 0, max: 60),
          place: 'place_any_quiet_spot',
          messLevel: 'mess_low',
          childEngagement: 'child_engagement_low',
          parentInvolvement: 'parent_involvement_low',
          activityType: 'activity_quiet_time',
          contexts: ['context_home', 'context_quiet', 'context_low_setup'],
          neededItems: ['Two sturdy books'],
          steps: ['Place a few books in a basket within easy reach.'],
          whatToExpect:
              'A low-effort, low-mess pause when everyone needs something softer. Let your child choose the pace.',
          suggestedSoundId: 'sound_quiet_stream',
          parentNote: 'This can be a calm pause, not a full reading session.',
          safetyNote: 'Use sturdy books without loose pieces.',
        ),
        PlayIdea(
          id: 'play_indoor_march',
          title: 'Indoor march',
          summary: 'March around the room together in a gentle rhythm.',
          ageGroup: '2-5 years',
          ageRangeMonths: AgeRangeMonths(min: 24, max: 60),
          place: 'place_home',
          messLevel: 'mess_medium',
          childEngagement: 'child_engagement_medium',
          parentInvolvement: 'parent_involvement_low',
          activityType: 'activity_movement',
          contexts: ['context_home', 'context_preschool', 'context_movement'],
          neededItems: ['Clear floor space'],
          steps: ['Take slow steps around the room together.'],
          whatToExpect:
              'A simple movement break with no special setup. Keep the pace easy and pause when the room feels settled.',
          suggestedSoundId: 'sound_evening_crickets',
          parentNote: 'A short march can be enough.',
          safetyNote: 'Keep walkways clear and avoid slippery spots.',
        ),
      ],
      sounds: [
        SoundItem(
          id: 'sound_soft_rain',
          title: 'Soft rain',
          category: 'Nature',
          summary: 'A calm rain placeholder for future sound content.',
          assetPath: 'placeholder://sounds/soft_rain',
          unlockType: 'free',
        ),
      ],
    );
  }
}

class _MissingSuggestedSoundLoader extends ContentLoader {
  const _MissingSuggestedSoundLoader();

  @override
  Future<ContentPackage> load() async {
    return const ContentPackage(
      metadata: ContentMetadata(
        packageId: 'test',
        schemaVersion: 1,
        version: '1.1.0',
        locale: 'en',
        publishedAt: '2026-05-18',
        minAppVersion: '0.1.0',
      ),
      taxonomy: _testTaxonomy,
      playFilters: [],
      playIdeas: [
        PlayIdea(
          id: 'play_missing_sound',
          title: 'Suggested soundless play',
          summary: 'A play idea whose sound is not available in content.',
          ageGroup: '2-5 years',
          ageRangeMonths: AgeRangeMonths(min: 24, max: 60),
          place: 'place_home',
          messLevel: 'mess_low',
          childEngagement: 'child_engagement_low',
          parentInvolvement: 'parent_involvement_low',
          activityType: 'activity_quiet_time',
          contexts: ['context_home', 'context_quiet'],
          neededItems: ['Soft cloth'],
          steps: ['Place the item nearby.'],
          whatToExpect: 'A calm test note for content loading.',
          suggestedSoundId: 'missing_sound',
          parentNote: 'Keep it simple.',
          safetyNote: 'Use safe items.',
        ),
      ],
      sounds: [
        SoundItem(
          id: 'sound_soft_rain',
          title: 'Soft rain',
          category: 'Nature',
          summary: 'Gentle rain for a calmer background.',
          assetPath: 'assets/audio/soft_rain.mp3',
          unlockType: 'free',
        ),
      ],
    );
  }
}

const _testTaxonomy = ContentTaxonomy(
  places: [
    TaxonomyTerm(id: 'place_home', label: 'Home'),
    TaxonomyTerm(id: 'place_floor', label: 'Floor'),
    TaxonomyTerm(id: 'place_kitchen', label: 'Kitchen'),
    TaxonomyTerm(id: 'place_living_room', label: 'Living room'),
    TaxonomyTerm(id: 'place_bedroom', label: 'Bedroom'),
    TaxonomyTerm(id: 'place_outside', label: 'Outside'),
    TaxonomyTerm(id: 'place_bathroom', label: 'Bathroom'),
    TaxonomyTerm(id: 'place_table', label: 'Table'),
    TaxonomyTerm(id: 'place_sofa', label: 'Sofa'),
    TaxonomyTerm(id: 'place_window', label: 'Window'),
    TaxonomyTerm(id: 'place_any_quiet_spot', label: 'Any quiet spot'),
    TaxonomyTerm(id: 'place_hallway', label: 'Hallway'),
  ],
  messLevels: [
    TaxonomyTerm(id: 'mess_low', label: 'Low'),
    TaxonomyTerm(id: 'mess_medium', label: 'Medium'),
  ],
  childEngagementLevels: [
    TaxonomyTerm(id: 'child_engagement_low', label: 'Low'),
    TaxonomyTerm(id: 'child_engagement_medium', label: 'Medium'),
    TaxonomyTerm(id: 'child_engagement_high', label: 'High'),
  ],
  parentInvolvementLevels: [
    TaxonomyTerm(id: 'parent_involvement_low', label: 'Low'),
    TaxonomyTerm(id: 'parent_involvement_medium', label: 'Medium'),
    TaxonomyTerm(id: 'parent_involvement_high', label: 'High'),
  ],
  activityTypes: [
    TaxonomyTerm(id: 'activity_connection', label: 'Connection'),
    TaxonomyTerm(id: 'activity_fine_motor', label: 'Fine motor'),
    TaxonomyTerm(id: 'activity_imaginative_play', label: 'Imaginative play'),
    TaxonomyTerm(id: 'activity_language', label: 'Language'),
    TaxonomyTerm(id: 'activity_movement', label: 'Movement'),
    TaxonomyTerm(id: 'activity_music', label: 'Music'),
    TaxonomyTerm(id: 'activity_observation', label: 'Observation'),
    TaxonomyTerm(id: 'activity_practical_life', label: 'Practical life'),
    TaxonomyTerm(id: 'activity_quiet_time', label: 'Quiet time'),
    TaxonomyTerm(id: 'activity_sensory', label: 'Sensory'),
    TaxonomyTerm(id: 'activity_sorting', label: 'Sorting'),
  ],
  contexts: [
    TaxonomyTerm(id: 'context_home', label: 'home'),
    TaxonomyTerm(id: 'context_baby', label: 'baby'),
    TaxonomyTerm(id: 'context_sensory', label: 'sensory'),
    TaxonomyTerm(id: 'context_low_setup', label: 'low_setup'),
    TaxonomyTerm(id: 'context_toddler', label: 'toddler'),
    TaxonomyTerm(id: 'context_movement', label: 'movement'),
    TaxonomyTerm(id: 'context_kitchen', label: 'kitchen'),
    TaxonomyTerm(id: 'context_practical_life', label: 'practical_life'),
    TaxonomyTerm(id: 'context_quiet', label: 'quiet'),
    TaxonomyTerm(id: 'context_transition', label: 'transition'),
    TaxonomyTerm(id: 'context_preschool', label: 'preschool'),
    TaxonomyTerm(id: 'context_pretend', label: 'pretend'),
    TaxonomyTerm(id: 'context_connection', label: 'connection'),
    TaxonomyTerm(id: 'context_outside', label: 'outside'),
    TaxonomyTerm(id: 'context_bathroom', label: 'bathroom'),
  ],
  soundCategories: [
    TaxonomyTerm(id: 'sound_category_calm', label: 'Calm'),
    TaxonomyTerm(id: 'sound_category_home', label: 'Home'),
    TaxonomyTerm(id: 'sound_category_nature', label: 'Nature'),
    TaxonomyTerm(id: 'sound_category_white_noise', label: 'White noise'),
  ],
);

const _englishMetadataTaxonomy = ContentTaxonomy(
  places: [
    TaxonomyTerm(id: 'place_home', label: 'Home'),
  ],
  messLevels: [
    TaxonomyTerm(
      id: 'mess_low',
      label: 'Low',
      chipLabel: 'Mess: low',
    ),
    TaxonomyTerm(
      id: 'mess_medium',
      label: 'Medium',
      chipLabel: 'Mess: medium',
    ),
  ],
  childEngagementLevels: [
    TaxonomyTerm(
      id: 'child_engagement_medium',
      label: 'Medium',
      chipLabel: 'Child: medium',
    ),
    TaxonomyTerm(
      id: 'child_engagement_low',
      label: 'Low',
      chipLabel: 'Child: low',
    ),
    TaxonomyTerm(
      id: 'child_engagement_high',
      label: 'High',
      chipLabel: 'Child: high',
    ),
  ],
  parentInvolvementLevels: [
    TaxonomyTerm(
      id: 'parent_involvement_low',
      label: 'Low',
      chipLabel: 'Parent: low',
    ),
    TaxonomyTerm(
      id: 'parent_involvement_medium',
      label: 'Medium',
      chipLabel: 'Parent: medium',
    ),
    TaxonomyTerm(
      id: 'parent_involvement_high',
      label: 'High',
      chipLabel: 'Parent: high',
    ),
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

const _polishMetadataTaxonomy = ContentTaxonomy(
  places: [
    TaxonomyTerm(id: 'place_home', label: 'Dom'),
  ],
  messLevels: [
    TaxonomyTerm(
      id: 'mess_low',
      label: 'Mały bałagan',
      chipLabel: 'Bałagan: mały',
    ),
    TaxonomyTerm(
      id: 'mess_medium',
      label: 'Średni bałagan',
      chipLabel: 'Bałagan: średni',
    ),
  ],
  childEngagementLevels: [
    TaxonomyTerm(
      id: 'child_engagement_medium',
      label: 'Średnie',
      chipLabel: 'Dziecko: średnio',
    ),
    TaxonomyTerm(
      id: 'child_engagement_low',
      label: 'Niskie',
      chipLabel: 'Dziecko: mało',
    ),
    TaxonomyTerm(
      id: 'child_engagement_high',
      label: 'Wysokie',
      chipLabel: 'Dziecko: dużo',
    ),
  ],
  parentInvolvementLevels: [
    TaxonomyTerm(
      id: 'parent_involvement_low',
      label: 'Niskie',
      chipLabel: 'Rodzic: mało',
    ),
    TaxonomyTerm(
      id: 'parent_involvement_medium',
      label: 'Średnie',
      chipLabel: 'Rodzic: średnio',
    ),
    TaxonomyTerm(
      id: 'parent_involvement_high',
      label: 'Wysokie',
      chipLabel: 'Rodzic: dużo',
    ),
  ],
  activityTypes: [
    TaxonomyTerm(id: 'activity_quiet_time', label: 'Wyciszenie'),
  ],
  contexts: [
    TaxonomyTerm(id: 'context_home', label: 'dom'),
  ],
  soundCategories: [
    TaxonomyTerm(id: 'sound_category_calm', label: 'Wyciszenie'),
  ],
);

class _LocalizedMetadataContentLoader extends ContentLoader {
  const _LocalizedMetadataContentLoader({
    required this.taxonomy,
  });

  final ContentTaxonomy taxonomy;

  @override
  Future<ContentPackage> load() async {
    return ContentPackage(
      metadata: const ContentMetadata(
        packageId: 'localized-test',
        schemaVersion: 1,
        version: '1.0.0',
        locale: 'en',
        publishedAt: '2026-05-18',
        minAppVersion: '0.1.0',
      ),
      taxonomy: taxonomy,
      playFilters: const [],
      playIdeas: const [
        PlayIdea(
          id: 'play_metadata_test',
          title: 'Soft treasure basket',
          summary: 'Offer a few safe household textures to explore together.',
          ageGroup: '6-18 months',
          ageRangeMonths: AgeRangeMonths(min: 6, max: 18),
          place: 'place_home',
          messLevel: 'mess_low',
          childEngagement: 'child_engagement_medium',
          parentInvolvement: 'parent_involvement_low',
          activityType: 'activity_quiet_time',
          contexts: ['context_home'],
          neededItems: ['Soft cloth'],
          steps: ['Offer a few safe household textures to explore together.'],
          whatToExpect: 'A calm, simple activity.',
          parentNote: 'Stay nearby.',
          safetyNote: 'Keep items safe.',
        ),
      ],
      sounds: const [],
    );
  }
}

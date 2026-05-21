import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
import 'package:nurtly/core/content/play_filter.dart';
import 'package:nurtly/core/content/play_idea.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/features/play/play_screen.dart';

import '../../test_fakes/fake_content_loader.dart';

void main() {
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
  });
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
      playFilters: [
        PlayFilter(
          id: 'low_effort',
          label: 'Low effort',
          matchMode: PlayFilterMatchMode.all,
          rules: [
            PlayFilterRule(
              field: 'parentInvolvement',
              operator: 'equals',
              value: 'Low',
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
              value: 'Low',
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
              value: 'movement',
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
              value: 'quiet',
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
          place: 'Home',
          messLevel: 'Low',
          childEngagement: 'Medium',
          parentInvolvement: 'Low',
          activityType: 'Sensory',
          contexts: ['home', 'baby', 'sensory', 'low_setup'],
          neededItems: ['Soft cloth'],
          steps: ['Place the items in the container.'],
          whatToExpect:
              'A low-mess, gently engaging activity with very little setup. Stay nearby, offer simple guidance, and let your child explore at their own pace.',
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
          place: 'Floor',
          messLevel: 'Medium',
          childEngagement: 'High',
          parentInvolvement: 'Medium',
          activityType: 'Movement',
          contexts: ['home', 'toddler', 'movement'],
          neededItems: ['Couch cushions'],
          steps: ['Place cushions on the floor with a low open space.'],
          whatToExpect:
              'Expect more movement and a little room reset afterward. Join for a few minutes, then keep the tunnel simple.',
          parentNote: 'A short setup can be enough.',
          safetyNote: 'Keep the tunnel low and stable.',
        ),
        PlayIdea(
          id: 'play_quiet_book_basket',
          title: 'Quiet book basket',
          summary: 'Set out a small basket of books for a calm shared pause.',
          ageGroup: '0-5 years',
          ageRangeMonths: AgeRangeMonths(min: 0, max: 60),
          place: 'Any quiet spot',
          messLevel: 'Low',
          childEngagement: 'Low',
          parentInvolvement: 'Low',
          activityType: 'Quiet time',
          contexts: ['home', 'quiet', 'low_setup'],
          neededItems: ['Two sturdy books'],
          steps: ['Place a few books in a basket within easy reach.'],
          whatToExpect:
              'A low-effort, low-mess pause when everyone needs something softer. Let your child choose the pace.',
          parentNote: 'This can be a calm pause, not a full reading session.',
          safetyNote: 'Use sturdy books without loose pieces.',
        ),
        PlayIdea(
          id: 'play_indoor_march',
          title: 'Indoor march',
          summary: 'March around the room together in a gentle rhythm.',
          ageGroup: '2-5 years',
          ageRangeMonths: AgeRangeMonths(min: 24, max: 60),
          place: 'Home',
          messLevel: 'Medium',
          childEngagement: 'Medium',
          parentInvolvement: 'Low',
          activityType: 'Movement',
          contexts: ['home', 'preschool', 'movement'],
          neededItems: ['Clear floor space'],
          steps: ['Take slow steps around the room together.'],
          whatToExpect:
              'A simple movement break with no special setup. Keep the pace easy and pause when the room feels settled.',
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

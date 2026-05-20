import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
import 'package:nurtly/core/content/play_idea.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/features/play/play_screen.dart';

import '../../test_fakes/fake_content_loader.dart';

void main() {
  testWidgets('shows all ideas by default and restores all after filtering', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
      ),
    );
    await tester.pump();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Soft treasure basket'), findsOneWidget);
    expect(find.text('Couch cushion tunnel'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Quiet book basket'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quiet book basket'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Low mess'));
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
    expect(find.text('Couch cushion tunnel'), findsNothing);
    expect(find.text('Quiet book basket'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
    expect(find.text('Couch cushion tunnel'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Quiet book basket'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quiet book basket'), findsOneWidget);
  });

  testWidgets('low effort filter shows only low parent involvement ideas', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Low effort'));
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
    expect(find.text('Quiet book basket'), findsOneWidget);
    expect(find.text('Couch cushion tunnel'), findsNothing);
  });

  testWidgets('detail navigation still works after filtering', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _PlayFilterContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Low effort'));
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
    expect(find.text('Medium child energy'), findsNothing);
    expect(find.text('Low parent effort'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('What you\'ll need'),
      120,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('What you\'ll need'), findsOneWidget);
    expect(find.text('- Soft cloth'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Steps'),
      120,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('1. Place the items in the container.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Parent note'),
      120,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Parent note'), findsOneWidget);
    expect(
      find.text('Choose what fits the moment and keep it simple.'),
      findsOneWidget,
    );
    expect(find.text('Safety note'), findsOneWidget);
    expect(
      find.text('Use only large, clean items that cannot be swallowed.'),
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
      playIdeas: [
        PlayIdea(
          id: 'play_soft_treasure_basket',
          title: 'Soft treasure basket',
          summary: 'Offer a few safe household textures to explore together.',
          ageGroup: '6-18 months',
          place: 'Home',
          messLevel: 'Low',
          childEngagement: 'Medium',
          parentInvolvement: 'Low',
          activityType: 'Sensory',
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
          place: 'Floor',
          messLevel: 'Medium',
          childEngagement: 'High',
          parentInvolvement: 'Medium',
          activityType: 'Movement',
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
          place: 'Any quiet spot',
          messLevel: 'Low',
          childEngagement: 'Low',
          parentInvolvement: 'Low',
          activityType: 'Quiet time',
          neededItems: ['Two sturdy books'],
          steps: ['Place a few books in a basket within easy reach.'],
          whatToExpect:
              'A low-effort, low-mess pause when everyone needs something softer. Let your child choose the pace.',
          parentNote: 'This can be a calm pause, not a full reading session.',
          safetyNote: 'Use sturdy books without loose pieces.',
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

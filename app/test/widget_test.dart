import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
import 'package:nurtly/core/content/play_idea.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/features/play/play_screen.dart';
import 'package:nurtly/features/sounds/sounds_screen.dart';
import 'package:nurtly/main.dart';

void main() {
  testWidgets('shows app shell tabs', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    expect(find.text('Play'), findsWidgets);
    expect(find.text('Journal'), findsWidgets);
    expect(find.text('Sounds'), findsWidgets);
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
  });

  testWidgets('opens play activity detail from the play list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _FakeContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Soft treasure basket'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('What you\'ll need'), findsOneWidget);
    expect(find.text('- Soft cloth'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('1. Place the items in the container.'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pump();

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

  testWidgets('shows sounds from bundled-style content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundsScreen(contentLoader: _FakeContentLoader()),
      ),
    );
    await tester.pump();

    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('A calm rain placeholder for future sound content.'),
        findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('free'), findsOneWidget);
  });

  testWidgets('opens sound detail from the sounds list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundsScreen(contentLoader: _FakeContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Soft rain'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Player placeholder'), findsOneWidget);
    expect(
      find.text('Real audio playback will be added in a later task.'),
      findsOneWidget,
    );
    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('free'), findsOneWidget);
  });
}

class _FakeContentLoader extends ContentLoader {
  const _FakeContentLoader();

  @override
  Future<ContentPackage> load() async {
    return const ContentPackage(
      metadata: ContentMetadata(
        packageId: 'test',
        version: '1.0.0',
        locale: 'en',
        publishedAt: '2026-05-18',
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
          neededItems: [
            'Soft cloth',
            'Wooden spoon',
          ],
          steps: [
            'Place the items in the container.',
            'Sit nearby and let your child choose what to touch.',
          ],
          parentNote: 'Choose what fits the moment and keep it simple.',
          safetyNote: 'Use only large, clean items that cannot be swallowed.',
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

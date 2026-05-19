import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
import 'package:nurtly/core/content/play_idea.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/features/journal/journal_screen.dart';
import 'package:nurtly/features/play/play_screen.dart';
import 'package:nurtly/features/sounds/sounds_screen.dart';
import 'package:nurtly/main.dart';

void main() {
  testWidgets('shows app shell tabs', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    expect(find.text('Play'), findsWidgets);
    expect(find.text('Journal'), findsWidgets);
    expect(find.text('Sounds'), findsWidgets);
    expect(find.byTooltip('Privacy & Data'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
  });

  testWidgets('opens Privacy & Data from the app shell', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    await tester.tap(find.byTooltip('Privacy & Data'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy & Data'), findsOneWidget);
    expect(find.text('- No account is used.'), findsOneWidget);
    expect(find.text('- No cloud sync is currently enabled.'), findsOneWidget);
    expect(find.text('- No analytics are currently enabled.'), findsOneWidget);
    expect(find.text('- No ads are currently enabled.'), findsOneWidget);
    expect(
      find.text('- Bundled sample content is included in the app.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Future data-related changes should be introduced clearly before they are enabled.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('opens play activity detail from the play list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlayScreen(contentLoader: _FakeContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Soft treasure basket'));
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    expect(find.text('Player placeholder'), findsOneWidget);
    expect(
      find.text('Real sound playback will be added in a later task.'),
      findsOneWidget,
    );
    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('free'), findsOneWidget);
  });

  testWidgets('shows empty journal state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: JournalScreen()));

    expect(find.text('No journal notes yet.'), findsOneWidget);
    expect(find.text('Add a short note when you are ready.'), findsOneWidget);
  });

  testWidgets('add note flow creates a journal entry with mood',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JournalScreen(now: () => DateTime(2026, 5, 19, 9, 30)),
      ),
    );

    await tester.tap(find.text('Add note'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'A quiet breakfast together.',
    );
    await tester.tap(find.text('Good moment'));
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();

    expect(find.text('A quiet breakfast together.'), findsOneWidget);
    expect(find.text('Good moment'), findsOneWidget);
    expect(find.text('Today 09:30'), findsOneWidget);
  });

  testWidgets('empty journal note shows validation message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AddJournalEntryScreen(now: () => DateTime(2026, 5, 19, 9, 30)),
      ),
    );

    await tester.tap(find.text('Save note'));
    await tester.pump();

    expect(find.text('Please add a short note first.'), findsOneWidget);
    expect(find.text('Add note'), findsOneWidget);
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

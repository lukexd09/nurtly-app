import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/features/sounds/sounds_screen.dart';

import '../../test_fakes/fake_content_loader.dart';

void main() {
  testWidgets('shows sounds from bundled-style content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundsScreen(contentLoader: FakeContentLoader()),
      ),
    );
    await tester.pump();

    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('Gentle rain for a calmer background.'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sound-card-artwork-sound_soft_rain')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.waves_rounded), findsOneWidget);
  });

  testWidgets('opens sound detail from the sounds list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundsScreen(contentLoader: FakeContentLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Soft rain'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('sound-detail-back-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-status')), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-artwork')), findsOneWidget);
    expect(find.byIcon(Icons.waves_rounded), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-progress')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-session-options')),
        findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('Continuous play'), findsNothing);
    expect(find.byKey(const ValueKey('sound-player-timer-infinity')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('sound-player-auto-fade')), findsOneWidget);
    expect(find.text('Auto-fade available with timer'), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-controls')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-primary-control')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('sound-player-stop-control')), findsNothing);
    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('Gentle rain for a calmer background.'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('Free'), findsNothing);
    expect(find.text('free'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Keep volume comfortable and device away from child.'),
      120,
    );
    await tester.pump();

    expect(find.text('Keep volume comfortable and device away from child.'),
        findsOneWidget);
    expect(find.textContaining('placeholder'), findsNothing);
    expect(find.textContaining('future'), findsNothing);
  });

  testWidgets('renders configured sound artwork asset when present',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundDetailScreen(
          sound: SoundItem(
            id: 'sound_artwork_test',
            title: 'Artwork sound',
            category: 'Nature',
            summary: 'A sound with artwork.',
            assetPath: 'assets/audio/soft_rain.mp3',
            artworkAssetPath: 'assets/images/sounds/artwork_test.webp',
            unlockType: 'free',
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('sound-player-artwork')), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) {
        final image = widget is Image ? widget.image : null;
        return image is AssetImage &&
            image.assetName == 'assets/images/sounds/artwork_test.webp';
      }),
      findsOneWidget,
    );
  });
}

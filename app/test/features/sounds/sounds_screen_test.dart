import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('free'), findsOneWidget);
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
    expect(find.byKey(const ValueKey('sound-player-progress')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-session-options')),
        findsOneWidget);
    expect(find.text('15 min'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('60 min'), findsOneWidget);
    expect(find.text('Infinity'), findsWidgets);
    expect(
        find.byKey(const ValueKey('sound-player-auto-fade')), findsOneWidget);
    expect(find.text('Auto-fade for timed sessions'), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-controls')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-primary-control')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('sound-player-stop-control')), findsNothing);
    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('Gentle rain for a calmer background.'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
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
}

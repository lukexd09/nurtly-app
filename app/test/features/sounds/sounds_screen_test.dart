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
    expect(find.text('A calm rain placeholder for future sound content.'),
        findsOneWidget);
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

    expect(find.text('Player placeholder'), findsOneWidget);
    expect(
      find.text('Real sound playback will be added in a later task.'),
      findsOneWidget,
    );
    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('free'), findsOneWidget);
  });
}

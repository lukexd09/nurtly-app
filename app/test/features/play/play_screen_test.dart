import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/features/play/play_screen.dart';

import '../../test_fakes/fake_content_loader.dart';

void main() {
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
    expect(find.text('Low mess'), findsWidgets);
    expect(find.text('Medium child energy'), findsOneWidget);
    expect(find.text('Low parent effort'), findsOneWidget);

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

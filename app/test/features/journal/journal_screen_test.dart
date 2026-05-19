import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/features/journal/journal_screen.dart';

void main() {
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

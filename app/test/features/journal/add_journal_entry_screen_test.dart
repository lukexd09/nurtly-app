import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/core/theme/app_theme.dart';
import 'package:nurtly/features/journal/add_journal_entry_screen.dart';
import 'package:nurtly/features/journal/journal_entry.dart';
import 'package:nurtly/features/journal/journal_entry_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('feeding form shows readable selected chip labels',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddJournalEntryScreen(
          strings: AppStrings.polish,
          entryType: JournalEntryType.feeding,
          now: () => DateTime(2026, 5, 27, 14, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pierś'), findsOneWidget);
    expect(find.text('Butelka'), findsOneWidget);
    expect(find.text('Jedzenie'), findsOneWidget);
    expect(find.text('Inne'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsWidgets);

    await tester.tap(find.text('Pierś'));
    await tester.pumpAndSettle();

    expect(find.text('Pierś'), findsOneWidget);
  });

  testWidgets('feeding form uses user-friendly time and amount copy',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddJournalEntryScreen(
          strings: AppStrings.polish,
          entryType: JournalEntryType.feeding,
          initialEntry: JournalEntry.feeding(
            id: 'feeding-1',
            eventAt: DateTime(2026, 5, 26, 14, 7),
            feedingType: JournalFeedingType.bottle,
            createdAt: DateTime(2026, 5, 26, 14, 7),
            updatedAt: DateTime(2026, 5, 26, 14, 7),
          ),
          now: () => DateTime(2026, 5, 27, 14, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('26.05.2026, 14:07'), findsOneWidget);
    expect(find.textContaining('2026-05-26 14:07:00'), findsNothing);
    expect(find.text('Ilość / opis, opcjonalnie'), findsOneWidget);
  });
}

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
            eventAt: DateTime(2026, 5, 25, 14, 7),
            feedingType: JournalFeedingType.bottle,
            createdAt: DateTime(2026, 5, 25, 14, 7),
            updatedAt: DateTime(2026, 5, 25, 14, 7),
          ),
          now: () => DateTime(2026, 5, 27, 14, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('25.05.2026, 14:07'), findsOneWidget);
    expect(find.textContaining('2026-05-25 14:07:00'), findsNothing);
    expect(find.text('Ilość / opis, opcjonalnie'), findsOneWidget);
  });

  testWidgets('feeding form starts on selected day context', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddJournalEntryScreen(
          strings: AppStrings.polish,
          entryType: JournalEntryType.feeding,
          initialDay: DateTime(2026, 5, 26),
          now: () => DateTime(2026, 5, 27, 14, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wczoraj, 14:07'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('journal-change-event-day')),
      findsOneWidget,
    );
    expect(find.text('Zmień dzień'), findsOneWidget);
    expect(find.textContaining('Dzisiaj, 14:07'), findsNothing);
  });

  testWidgets('feeding form shows today label for current day context',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddJournalEntryScreen(
          strings: AppStrings.polish,
          entryType: JournalEntryType.feeding,
          initialDay: DateTime(2026, 5, 27),
          now: () => DateTime(2026, 5, 27, 14, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dzisiaj, 14:07'), findsOneWidget);
  });

  testWidgets('sleep form exposes change day actions for both times',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddJournalEntryScreen(
          strings: AppStrings.polish,
          entryType: JournalEntryType.sleep,
          initialDay: DateTime(2026, 5, 26),
          now: () => DateTime(2026, 5, 27, 14, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('journal-change-start-day')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('journal-change-end-day')),
      findsOneWidget,
    );
  });

  testWidgets('diaper form shows readable selected chip labels',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddJournalEntryScreen(
          strings: AppStrings.polish,
          entryType: JournalEntryType.diaper,
          now: () => DateTime(2026, 5, 27, 14, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siusiu'), findsOneWidget);
    expect(find.text('Kupka'), findsOneWidget);
    expect(find.text('Oba'), findsOneWidget);
    expect(find.text('Sucha'), findsOneWidget);

    await tester.tap(find.text('Siusiu'));
    await tester.pumpAndSettle();

    expect(find.text('Siusiu'), findsOneWidget);
  });
}

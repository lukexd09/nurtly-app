import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/core/theme/app_theme.dart';
import 'package:nurtly/features/journal/add_journal_entry_screen.dart';
import 'package:nurtly/features/journal/journal_entry.dart';
import 'package:nurtly/features/journal/journal_entry_type.dart';
import 'package:nurtly/features/journal/widgets/journal_day_picker_sheet.dart';
import 'package:nurtly/features/journal/widgets/journal_time_picker_sheet.dart';

Widget _localizedTestApp(
    {required Widget child, Locale locale = const Locale('pl')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('pl')],
    theme: AppTheme.light,
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('feeding form shows readable selected chip labels',
      (tester) async {
    await tester.pumpWidget(
      _localizedTestApp(
        child: AddJournalEntryScreen(
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
      _localizedTestApp(
        child: AddJournalEntryScreen(
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
      _localizedTestApp(
        child: AddJournalEntryScreen(
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
      _localizedTestApp(
        child: AddJournalEntryScreen(
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
      _localizedTestApp(
        child: AddJournalEntryScreen(
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
      _localizedTestApp(
        child: AddJournalEntryScreen(
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

  testWidgets('polish journal day picker uses custom sheet labels',
      (tester) async {
    await tester.pumpWidget(
      _localizedTestApp(
        child: AddJournalEntryScreen(
          strings: AppStrings.polish,
          entryType: JournalEntryType.feeding,
          initialDay: DateTime(2026, 5, 26),
          now: () => DateTime(2026, 5, 27, 14, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('journal-change-event-day')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('journal-day-picker-title')), findsOneWidget);
    expect(find.text('Wczoraj'), findsWidgets);
    expect(find.text('Dzisiaj'), findsWidgets);
    expect(find.text('Jutro'), findsWidgets);
    expect(find.text('Select date'), findsNothing);
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('polish journal time picker uses custom sheet labels',
      (tester) async {
    await tester.pumpWidget(
      _localizedTestApp(
        child: AddJournalEntryScreen(
          strings: AppStrings.polish,
          entryType: JournalEntryType.feeding,
          initialDay: DateTime(2026, 5, 26),
          now: () => DateTime(2026, 5, 27, 14, 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('journal-event-time-row')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('journal-time-picker-title')),
      findsOneWidget,
    );
    expect(find.text('Wybierz godzinę'), findsOneWidget);
    expect(find.text('Select time'), findsNothing);
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);
    expect(find.text('Anuluj'), findsWidgets);
    expect(find.text('Zapisz'), findsWidgets);
  });

  testWidgets('time picker sheet changes time', (tester) async {
    TimeOfDay? selectedTime;
    await tester.pumpWidget(
      _localizedTestApp(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                selectedTime = await showJournalTimePickerSheet(
                  context: context,
                  strings: AppStrings.polish,
                  initialTime: const TimeOfDay(hour: 8, minute: 43),
                  now: () => DateTime(2026, 5, 27, 20, 20),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Teraz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zapisz'));
    await tester.pumpAndSettle();

    expect(selectedTime, const TimeOfDay(hour: 20, minute: 20));
  });

  testWidgets('day picker sheet changes day', (tester) async {
    DateTime? selectedDay;
    await tester.pumpWidget(
      _localizedTestApp(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                selectedDay = await showJournalDayPickerSheet(
                  context: context,
                  strings: AppStrings.polish,
                  initialDay: DateTime(2026, 5, 27),
                  now: DateTime(2026, 5, 27, 14, 7),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('journal-day-picker-title')), findsOneWidget);
    await tester.tap(find.text('Wczoraj').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zapisz'));
    await tester.pumpAndSettle();

    expect(selectedDay, DateTime(2026, 5, 26));
  });
}

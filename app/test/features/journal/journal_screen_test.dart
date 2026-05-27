import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/core/theme/app_theme.dart';
import 'package:nurtly/features/journal/journal_controller.dart';
import 'package:nurtly/features/journal/journal_entry.dart';
import 'package:nurtly/features/journal/journal_screen.dart';
import 'package:nurtly/features/journal/journal_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows journal header and privacy hint', (tester) async {
    final controller = JournalController(
      store: InMemoryJournalStore(),
      now: () => DateTime(2026, 5, 19, 9, 30),
    );
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: JournalScreen(
          strings: AppStrings.english,
          controller: controller,
          now: () => DateTime(2026, 5, 19, 9, 30),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('journal-header')), findsOneWidget);
    expect(find.text(AppStrings.english.journalTitle), findsOneWidget);
    expect(find.text(AppStrings.english.journalSubtitle), findsOneWidget);
    expect(find.text(AppStrings.english.journalLocalOnlyHint), findsOneWidget);
    expect(find.byKey(const ValueKey('journal-scroll-view')), findsOneWidget);
    expect(find.text('Sponsored space'), findsNothing);
  });

  testWidgets('active sleep duration updates while the screen is visible',
      (tester) async {
    var currentTime = DateTime(2026, 5, 19, 9, 30);
    final controller = JournalController(
      store: InMemoryJournalStore(),
      now: () => currentTime,
    );
    await controller.load();
    await controller.startSleep();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: JournalScreen(
          strings: AppStrings.english,
          controller: controller,
          now: () => currentTime,
          activeSleepTickerInterval: const Duration(seconds: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('journal-active-sleep-card')),
        findsOneWidget);
    expect(find.text('Duration: 0 h 00m'), findsOneWidget);

    currentTime = currentTime.add(const Duration(minutes: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Duration: 0 h 01m'), findsOneWidget);
  });

  testWidgets('compact empty Journal renders without overflow on Polish',
      (tester) async {
    final controller = JournalController(
      store: InMemoryJournalStore(),
      now: () => DateTime(2026, 5, 19, 9, 30),
    );
    await controller.load();

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: JournalScreen(
          strings: AppStrings.polish,
          controller: controller,
          now: () => DateTime(2026, 5, 19, 9, 30),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('journal-day-navigation')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('journal-compact-summary-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('journal-last-moments-section')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('journal-start-sleep')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('journal-quick-action-chip-grid')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('journal-quick-action-add-sleep')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('journal-quick-action-feeding')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('journal-quick-action-diaper')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('journal-quick-action-note')),
        findsOneWidget);
    expect(find.text('0 min'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('journal-scroll-view')),
      const Offset(0, -800),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('journal-empty-state')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Journal with an entry shows last moments section',
      (tester) async {
    final controller = JournalController(
      store: InMemoryJournalStore(),
      now: () => DateTime(2026, 5, 19, 9, 30),
    );
    await controller.load();
    await controller.addEntry(
      JournalEntry.note(
        id: 'note-1',
        eventAt: DateTime(2026, 5, 19, 8, 45),
        note: 'hello',
      ),
    );

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: JournalScreen(
          strings: AppStrings.polish,
          controller: controller,
          now: () => DateTime(2026, 5, 19, 9, 30),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('journal-compact-summary-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('journal-last-moments-section')),
      findsOneWidget,
    );
    expect(
        find.text(AppStrings.polish.journalLastMomentsTitle), findsOneWidget);
    expect(find.text(AppStrings.polish.journalNoEntryShort), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

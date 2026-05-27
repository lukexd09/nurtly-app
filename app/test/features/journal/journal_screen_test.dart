import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/core/theme/app_theme.dart';
import 'package:nurtly/features/journal/journal_controller.dart';
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

  testWidgets('summary cards do not overflow on a narrow Polish screen',
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

    expect(find.byKey(const ValueKey('journal-summary-grid')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

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
}

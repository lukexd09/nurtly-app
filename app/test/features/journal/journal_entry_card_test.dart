import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/core/theme/app_theme.dart';
import 'package:nurtly/features/journal/journal_entry.dart';
import 'package:nurtly/features/journal/journal_entry_card.dart';

void main() {
  testWidgets('note entry text appears only once', (tester) async {
    final entry = JournalEntry.note(
      id: 'note-1',
      eventAt: DateTime(2026, 5, 19, 18, 45),
      note: 'A quiet evening.',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: JournalEntryCard(
            entry: entry,
            strings: AppStrings.english,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('A quiet evening.'), findsOneWidget);
  });
}

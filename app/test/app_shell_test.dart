import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/widgets/tappable_nurtly_card.dart';
import 'package:nurtly/main.dart';

void main() {
  testWidgets('shows Home as the initial app shell tab', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Play'), findsWidgets);
    expect(find.text('Journal'), findsWidgets);
    expect(find.text('Sounds'), findsWidgets);
    expect(find.byTooltip('Privacy & Data'), findsOneWidget);

    expect(find.text('Small moments, calmly planned'), findsOneWidget);
    expect(find.text('Soft treasure basket'), findsNothing);
  });

  testWidgets('Home quick link navigates to Play', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    await tester.tap(find.widgetWithText(TappableNurtlyCard, 'Play ideas'));
    await _pumpTabChange(tester);
    expect(find.text('Small moments, calmly planned'), findsNothing);
    expect(
      _hasText(tester, 'Soft treasure basket') ||
          _hasText(tester, 'Loading play ideas...'),
      isTrue,
    );
  });

  testWidgets('Home quick link navigates to Journal', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    final journalCard = find.widgetWithText(TappableNurtlyCard, 'Journal');
    await tester.scrollUntilVisible(journalCard, 120);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
    await tester.pump();
    await tester.tap(journalCard);
    await _pumpTabChange(tester);
    expect(find.text('No journal notes yet.'), findsOneWidget);
  });

  testWidgets('Home quick link navigates to Sounds', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    final soundsCard = find.widgetWithText(TappableNurtlyCard, 'Sounds');
    await tester.scrollUntilVisible(soundsCard, 120);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
    await tester.pump();
    await tester.tap(soundsCard);
    await _pumpTabChange(tester);
    expect(
      _hasText(tester, 'Soft rain') || _hasText(tester, 'Loading sounds...'),
      isTrue,
    );
  });
}

bool _hasText(WidgetTester tester, String text) {
  return find.text(text).evaluate().isNotEmpty;
}

Future<void> _pumpTabChange(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

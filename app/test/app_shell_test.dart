import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/navigation/app_shell.dart';
import 'package:nurtly/core/theme/app_theme.dart';

import 'test_fakes/fake_content_loader.dart';

void main() {
  testWidgets('shows Home as the initial app shell tab', (tester) async {
    await _pumpNurtlyApp(tester);

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Play'), findsWidgets);
    expect(find.text('Journal'), findsWidgets);
    expect(find.text('Sounds'), findsWidgets);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('Privacy & Data'), findsNothing);

    expect(find.text('Start with one small moment'), findsOneWidget);
    expect(find.text('Soft treasure basket'), findsNothing);
  });

  testWidgets('Home adapts on compact phone height', (tester) async {
    await _pumpNurtlyApp(tester, size: const Size(375, 667));

    expect(find.text('Start with one small moment'), findsOneWidget);
    expect(find.text('Find a play idea'), findsOneWidget);

    final journalAction = find.text('Save a small note');
    await tester.scrollUntilVisible(journalAction, 80);
    expect(journalAction, findsOneWidget);

    final soundsAction = find.text('Start a calming sound');
    await tester.scrollUntilVisible(soundsAction, 80);
    expect(soundsAction, findsOneWidget);
  });

  testWidgets('Home quick link navigates to Play', (tester) async {
    await _pumpNurtlyApp(tester);

    await tester.tap(find.text('Find a play idea'));
    await _pumpTabChange(tester);
    expect(find.text('Start with one small moment'), findsNothing);
    expect(
      _hasText(tester, 'Soft treasure basket') ||
          _hasText(tester, 'Loading play ideas...'),
      isTrue,
    );
  });

  testWidgets('Home gentle start opens today idea detail', (tester) async {
    await _pumpNurtlyApp(tester);

    await tester.scrollUntilVisible(find.text("Open today's idea"), 80);
    await tester.tap(find.text("Open today's idea"));
    await _pumpUntilAnyText(
      tester,
      ['What to expect', "What you'll need"],
    );

    expect(find.byKey(const ValueKey('play-suggested-sound')), findsOneWidget);
    expect(find.text('Suggested sound'), findsOneWidget);
    expect(find.text('Soft rain'), findsOneWidget);

    expect(find.text('What to expect'), findsOneWidget);
    expect(find.text("What you'll need"), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Start with one small moment'), findsOneWidget);
  });

  testWidgets('Settings sheet shows language options and privacy entry',
      (tester) async {
    await _pumpNurtlyApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Use phone language'), findsOneWidget);
    expect(find.text('Polski'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Privacy & Data'), findsOneWidget);
  });

  testWidgets('Settings language selection updates the in-session preference',
      (tester) async {
    await _pumpNurtlyApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Polski'));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('language-choice-polish')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('English'));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('language-choice-english')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Use phone language'));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('language-choice-system')),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Settings Privacy & Data opens the privacy screen',
      (tester) async {
    await _pumpNurtlyApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy & Data'));
    await tester.pumpAndSettle();

    expect(
        find.text('What Nurtly does with data in this MVP.'), findsOneWidget);
    expect(find.text('Current MVP behavior'), findsOneWidget);
  });

  testWidgets('Home quick link navigates to Journal', (tester) async {
    await _pumpNurtlyApp(tester);

    final journalAction = find.text('Save a small note');
    await tester.scrollUntilVisible(journalAction, 80);
    await tester.tap(journalAction);
    await _pumpTabChange(tester);
    expect(find.text('No journal notes yet.'), findsOneWidget);
  });

  testWidgets('Home quick link navigates to Sounds', (tester) async {
    await _pumpNurtlyApp(tester);

    final soundsAction = find.text('Start a calming sound');
    await tester.scrollUntilVisible(soundsAction, 80);
    await tester.tap(soundsAction);
    await _pumpTabChange(tester);
    expect(
      _hasText(tester, 'Soft rain') || _hasText(tester, 'Loading sounds...'),
      isTrue,
    );
  });
}

Future<void> _pumpUntilAnyText(
  WidgetTester tester,
  List<String> texts, {
  int maxTicks = 30,
}) async {
  for (var tick = 0; tick < maxTicks; tick++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (texts.any((text) => _hasText(tester, text))) {
      return;
    }
  }
}

Future<void> _pumpNurtlyApp(
  WidgetTester tester, {
  Size size = const Size(600, 1200),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(contentLoader: FakeContentLoader()),
    ),
  );
}

bool _hasText(WidgetTester tester, String text) {
  return find.text(text).evaluate().isNotEmpty;
}

Future<void> _pumpTabChange(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

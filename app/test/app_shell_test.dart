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
    expect(find.byTooltip('Privacy & Data'), findsOneWidget);

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

    expect(find.text('What to expect'), findsOneWidget);
    expect(find.text("What you'll need"), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Start with one small moment'), findsOneWidget);
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_language.dart';
import 'package:nurtly/core/content/bundled_content_source.dart';
import 'package:nurtly/core/navigation/app_shell.dart';
import 'package:nurtly/core/localization/language_preference_store.dart';
import 'package:nurtly/core/theme/app_theme.dart';
import 'package:nurtly/features/play/play_screen.dart';

import 'test_fakes/fake_content_loader.dart';
import 'test_fakes/fake_language_preference_store.dart';

void main() {
  testWidgets('shows Home as the initial app shell tab', (tester) async {
    await _pumpNurtlyApp(tester);

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Play'), findsWidgets);
    expect(find.text('Journal'), findsWidgets);
    expect(find.text('Sounds'), findsWidgets);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('Privacy & Data'), findsNothing);
    expect(find.byKey(const ValueKey('settings-language-row')), findsNothing);

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

  testWidgets('Settings sheet shows language row and privacy entry',
      (tester) async {
    await _pumpNurtlyApp(tester, size: const Size(600, 4000));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('settings-language-row')),
        matching: find.text('English'),
      ),
      findsOneWidget,
    );
    expect(find.text('Use phone language'), findsNothing);
    expect(find.text('Polski'), findsNothing);
    expect(find.text('Privacy & Data'), findsOneWidget);
  });

  testWidgets('Tapping Language opens language selector and updates row',
      (tester) async {
    await _pumpNurtlyApp(tester, size: const Size(600, 4000));

    await tester.tap(find.byTooltip('Settings'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.ensureVisible(
      find.byKey(const ValueKey('settings-language-row')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-language-row')));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsWidgets);
    expect(
        find.byKey(const ValueKey('language-choice-polish')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('language-choice-english')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('language-choice-polish')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('settings-language-row')),
        matching: find.text('Polski'),
      ),
      findsOneWidget,
    );
    expect(find.text('Ustawienia'), findsOneWidget);
    expect(find.text('Ogólne'), findsOneWidget);
    expect(find.text('Język'), findsWidgets);
    expect(find.text('Prywatność i dane'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('settings-language-row')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language-choice-english')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('settings-language-row')),
        matching: find.text('English'),
      ),
      findsOneWidget,
    );
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Language'), findsWidgets);
    expect(find.text('Privacy & Data'), findsOneWidget);
  });

  testWidgets('Settings Privacy & Data opens the privacy screen',
      (tester) async {
    await _pumpNurtlyApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('settings-privacy-data')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pumpAndSettle();

    expect(
      find.text('What Nurtly does with data in this MVP.'),
      findsOneWidget,
    );
    expect(find.text('Current MVP behavior'), findsOneWidget);
  });

  testWidgets('saved Polish language overrides system locale on startup',
      (tester) async {
    await _pumpNurtlyApp(
      tester,
      systemLocale: const Locale('en'),
      languagePreferenceStore: FakeLanguagePreferenceStore(
        saved: AppLanguage.polish,
      ),
    );

    expect(find.text('Spokojniejszy start'), findsOneWidget);
    expect(find.text('Dźwięki'), findsOneWidget);
  });

  testWidgets('saved English language overrides system locale on startup',
      (tester) async {
    await _pumpNurtlyApp(
      tester,
      systemLocale: const Locale('pl'),
      languagePreferenceStore: FakeLanguagePreferenceStore(
        saved: AppLanguage.english,
      ),
    );

    expect(find.text('A quieter start'), findsOneWidget);
    expect(find.text('Sounds'), findsOneWidget);
  });

  testWidgets('load errors fall back to system locale', (tester) async {
    await _pumpNurtlyApp(
      tester,
      systemLocale: const Locale('pl'),
      languagePreferenceStore: _ThrowingLanguagePreferenceStore(
        failOnLoad: true,
      ),
    );

    expect(find.text('Spokojniejszy start'), findsOneWidget);
  });

  testWidgets('Switching language reloads bundled content', (tester) async {
    final store = FakeLanguagePreferenceStore();
    await _pumpRealNurtlyApp(
      tester,
      size: const Size(600, 4000),
      languagePreferenceStore: store,
    );

    await _selectLanguageFromSettings(
      tester,
      choiceKey: const ValueKey('language-choice-polish'),
      expectedLabel: 'Polski',
    );
    expect(store.savedValues, contains(AppLanguage.polish));
    final polishPlayScreen = tester.widget<PlayScreen>(
      find.byType(PlayScreen, skipOffstage: false),
    );
    final polishSource =
        polishPlayScreen.contentLoader.source as BundledContentSource;
    expect(polishSource.language, AppLanguage.polish);

    await _selectLanguageFromSettings(
      tester,
      choiceKey: const ValueKey('language-choice-english'),
      expectedLabel: 'English',
    );
    expect(store.savedValues, contains(AppLanguage.english));
    final englishPlayScreen = tester.widget<PlayScreen>(
      find.byType(PlayScreen, skipOffstage: false),
    );
    final englishSource =
        englishPlayScreen.contentLoader.source as BundledContentSource;
    expect(englishSource.language, AppLanguage.english);
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

  testWidgets('language selection persists through store save', (tester) async {
    final store = FakeLanguagePreferenceStore();
    await _pumpNurtlyApp(
      tester,
      size: const Size(600, 4000),
      languagePreferenceStore: store,
    );

    await _selectLanguageFromSettings(
      tester,
      choiceKey: const ValueKey('language-choice-polish'),
      expectedLabel: 'Polski',
    );
    expect(store.saved, AppLanguage.polish);
    expect(store.savedValues.last, AppLanguage.polish);
  });

  testWidgets('save errors do not block in-session language updates',
      (tester) async {
    final store = _ThrowingLanguagePreferenceStore(failOnSave: true);
    await _pumpNurtlyApp(
      tester,
      size: const Size(600, 4000),
      languagePreferenceStore: store,
    );

    await _selectLanguageFromSettings(
      tester,
      choiceKey: const ValueKey('language-choice-polish'),
      expectedLabel: 'Polski',
    );

    expect(find.text('Spokojniejszy start'), findsOneWidget);
    expect(store.savedValues, contains(AppLanguage.polish));
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
  Locale? systemLocale,
  LanguagePreferenceStore? languagePreferenceStore,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  if (systemLocale != null) {
    tester.binding.platformDispatcher.localeTestValue = systemLocale;
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
  }

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppShell(
        contentLoader: const FakeContentLoader(),
        languagePreferenceStore:
            languagePreferenceStore ?? FakeLanguagePreferenceStore(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _selectLanguageFromSettings(
  WidgetTester tester, {
  required ValueKey<String> choiceKey,
  required String expectedLabel,
}) async {
  if (find.byKey(const ValueKey('settings-language-row')).evaluate().isEmpty) {
    await tester.tap(find.byTooltip('Settings'));
    await tester.pump(const Duration(milliseconds: 600));
  }
  await tester.ensureVisible(
    find.byKey(const ValueKey('settings-language-row')),
  );
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(find.byKey(const ValueKey('settings-language-row')));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.ensureVisible(find.byKey(choiceKey));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(find.byKey(choiceKey));
  await tester.pump(const Duration(milliseconds: 600));

  expect(
    find.descendant(
      of: find.byKey(const ValueKey('settings-language-row')),
      matching: find.text(expectedLabel),
    ),
    findsOneWidget,
  );
}

Future<void> _pumpRealNurtlyApp(
  WidgetTester tester, {
  Size size = const Size(600, 1200),
  LanguagePreferenceStore? languagePreferenceStore,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppShell(
        languagePreferenceStore:
            languagePreferenceStore ?? FakeLanguagePreferenceStore(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

bool _hasText(WidgetTester tester, String text) {
  return find.text(text).evaluate().isNotEmpty;
}

Future<void> _pumpTabChange(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

class _ThrowingLanguagePreferenceStore implements LanguagePreferenceStore {
  _ThrowingLanguagePreferenceStore({
    this.failOnLoad = false,
    this.failOnSave = false,
  });

  final bool failOnLoad;
  final bool failOnSave;
  final List<AppLanguage> savedValues = [];

  @override
  Future<AppLanguage?> load() async {
    if (failOnLoad) {
      throw StateError('load failed');
    }
    return null;
  }

  @override
  Future<void> save(AppLanguage language) async {
    savedValues.add(language);
    if (failOnSave) {
      throw StateError('save failed');
    }
  }
}

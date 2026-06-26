import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/ads/consent_flow_controller.dart';
import 'package:nurtly/core/localization/app_language.dart';
import 'package:nurtly/core/content/bundled_content_source.dart';
import 'package:nurtly/core/navigation/app_shell.dart';
import 'package:nurtly/core/localization/language_preference_store.dart';
import 'package:nurtly/core/theme/app_theme.dart';
import 'package:nurtly/features/play/play_screen.dart';
import 'package:nurtly/features/journal/journal_controller.dart';
import 'package:nurtly/features/journal/journal_entry.dart';
import 'package:nurtly/features/journal/journal_store.dart';
import 'package:nurtly/main.dart';

import 'test_fakes/fake_content_loader.dart';
import 'test_fakes/fake_premium_entitlement_provider.dart';
import 'test_fakes/fake_language_preference_store.dart';
import 'test_fakes/fake_reviewer_access_store.dart';

void main() {
  testWidgets('AppShell bootstrap notifies parent about saved language',
      (tester) async {
    AppLanguage? capturedLanguage;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppShell(
          contentLoader: const FakeContentLoader(),
          languagePreferenceStore: FakeLanguagePreferenceStore(
            saved: AppLanguage.polish,
          ),
          reviewerAccessStore: FakeReviewerAccessStore(),
          premiumEntitlementProvider: FakePremiumEntitlementProvider(),
          onLanguageChanged: (language) => capturedLanguage = language,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(capturedLanguage, AppLanguage.polish);
  });

  testWidgets('NurtlyApp wires MaterialApp localization for Polish',
      (tester) async {
    await tester.pumpWidget(
      NurtlyApp(
        languagePreferenceStore: FakeLanguagePreferenceStore(
          saved: AppLanguage.polish,
        ),
        reviewerAccessStore: FakeReviewerAccessStore(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(materialApp.locale, const Locale('pl'));
    expect(materialApp.localizationsDelegates, isNotEmpty);
    expect(materialApp.supportedLocales, contains(const Locale('pl')));
  });

  testWidgets('shows Home as the initial app shell tab', (tester) async {
    await _pumpNurtlyApp(tester);

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Play'), findsWidgets);
    expect(find.text('Journal'), findsWidgets);
    expect(find.text('Sounds'), findsWidgets);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('Privacy & Data'), findsNothing);
    expect(
        find.byKey(const ValueKey('settings-reviewer-access')), findsNothing);
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

    await _tapSettings(tester);
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

  testWidgets('Settings sheet shows premium section and opens paywall',
      (tester) async {
    await _pumpNurtlyApp(tester, size: const Size(600, 4000));

    await _tapSettings(tester);
    await tester.pumpAndSettle();

    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Upgrade to Premium'), findsOneWidget);
    expect(find.text('Restore Premium access'), findsOneWidget);

    await tester.tap(find.text('Upgrade to Premium'));
    await tester.pumpAndSettle();

    expect(find.text('Nurtly Premium'), findsOneWidget);
    expect(find.text('Launch offer -50%'), findsOneWidget);
    expect(find.text('Remove ads'), findsOneWidget);
    expect(find.text('Unlock premium play ideas'), findsOneWidget);
    expect(find.text('Unlock premium sounds'), findsOneWidget);
    expect(find.text('Premium Yearly'), findsWidgets);
    expect(find.text('Premium Monthly'), findsWidgets);
    expect(find.text('7.49 PLN / month'), findsOneWidget);
    expect(find.text('64.99 PLN / year'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Not now'), findsWidgets);
    expect(find.text('Already Premium? Restore access'), findsWidgets);

    await tester.tap(find.text('Not now').first);
    await tester.pumpAndSettle();

    expect(find.text('Nurtly Premium'), findsNothing);
  });

  testWidgets('Hidden About gesture opens reviewer access dialog',
      (tester) async {
    await _pumpNurtlyApp(tester, size: const Size(600, 4000));

    await _openReviewerAccessDialog(tester);

    expect(find.text('Reviewer access'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Activate reviewer access'), findsOneWidget);
  });

  testWidgets('Reviewer access accepts valid code and enables premium',
      (tester) async {
    final reviewerStore = FakeReviewerAccessStore();
    final premiumProvider = FakePremiumEntitlementProvider();
    await _pumpNurtlyApp(
      tester,
      size: const Size(600, 4000),
      premiumEntitlementProvider: premiumProvider,
      reviewerAccessStore: reviewerStore,
    );

    await _openReviewerAccessDialog(tester);
    await tester.enterText(
      find.byKey(const ValueKey('reviewer-access-code-field')),
      'NURTLY-REVIEWER-162',
    );
    await tester.tap(find.byKey(const ValueKey('reviewer-access-activate')));
    await tester.pumpAndSettle();

    expect(find.text('Reviewer access'), findsNothing);
    expect(find.text('Reviewer access is active on this installation.'),
        findsOneWidget);
    expect(reviewerStore.saved, isTrue);
  });

  testWidgets('Reviewer access rejects invalid code and stays open',
      (tester) async {
    await _pumpNurtlyApp(tester, size: const Size(600, 4000));

    await _openReviewerAccessDialog(tester);
    await tester.enterText(
      find.byKey(const ValueKey('reviewer-access-code-field')),
      'wrong-code',
    );
    await tester.tap(find.byKey(const ValueKey('reviewer-access-activate')));
    await tester.pumpAndSettle();

    expect(find.text('That reviewer code is not valid.'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Reviewer access reset clears local access only', (tester) async {
    final reviewerStore = FakeReviewerAccessStore(saved: true);
    await _pumpNurtlyApp(
      tester,
      size: const Size(600, 4000),
      reviewerAccessStore: reviewerStore,
    );

    await _openReviewerAccessDialog(tester);
    expect(find.byKey(const ValueKey('reviewer-access-reset')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('reviewer-access-code-field')),
          )
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('reviewer-access-activate')),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const ValueKey('reviewer-access-reset')));
    await tester.pumpAndSettle();

    expect(reviewerStore.saved, isFalse);

    await _tapAboutFiveTimes(tester);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('reviewer-access-code-field')),
          )
          .enabled,
      isTrue,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('reviewer-access-activate')),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('Reviewer access save errors keep dialog interactive',
      (tester) async {
    final reviewerStore = FakeReviewerAccessStore(failOnSave: true);
    await _pumpNurtlyApp(
      tester,
      size: const Size(600, 4000),
      reviewerAccessStore: reviewerStore,
    );

    await _openReviewerAccessDialog(tester);
    await tester.enterText(
      find.byKey(const ValueKey('reviewer-access-code-field')),
      'NURTLY-REVIEWER-162',
    );
    await tester.tap(find.byKey(const ValueKey('reviewer-access-activate')));
    await tester.pumpAndSettle();

    expect(
      find.text('Reviewer access could not be updated. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(reviewerStore.savedValues, isEmpty);
  });

  testWidgets('Reviewer access delete errors keep dialog interactive',
      (tester) async {
    final reviewerStore = FakeReviewerAccessStore(
      saved: true,
      failOnDelete: true,
    );
    await _pumpNurtlyApp(
      tester,
      size: const Size(600, 4000),
      reviewerAccessStore: reviewerStore,
    );

    await _openReviewerAccessDialog(tester);
    await tester.tap(find.byKey(const ValueKey('reviewer-access-reset')));
    await tester.pumpAndSettle();

    expect(
      find.text('Reviewer access could not be updated. Please try again.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('reviewer-access-code-field')),
          )
          .enabled,
      isFalse,
    );
    expect(reviewerStore.saved, isTrue);
  });

  testWidgets('Reviewer access stays open while save is in progress',
      (tester) async {
    final saveCompleter = Completer<void>();
    final reviewerStore = FakeReviewerAccessStore(saveCompleter: saveCompleter);
    await _pumpNurtlyApp(
      tester,
      size: const Size(600, 4000),
      reviewerAccessStore: reviewerStore,
    );

    await _openReviewerAccessDialog(tester);
    await tester.enterText(
      find.byKey(const ValueKey('reviewer-access-code-field')),
      'NURTLY-REVIEWER-162',
    );
    await tester.tap(find.byKey(const ValueKey('reviewer-access-activate')));
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byKey(const ValueKey('reviewer-access-code-field')),
        findsOneWidget);

    saveCompleter.complete();
    await tester.pumpAndSettle();

    expect(find.text('Reviewer access is active on this installation.'),
        findsOneWidget);
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
      find.byKey(const ValueKey('language-choice-polish')),
      findsOneWidget,
    );
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

    await tester.ensureVisible(find.text('Przejd\u017a na Premium').first);
    await tester.tap(find.text('Przejd\u017a na Premium').first);
    await tester.pumpAndSettle();
    expect(find.text('Nie teraz'), findsWidgets);
    expect(
      find.text('Masz ju\u017c Premium? Odzyskaj dost\u0119p'),
      findsWidgets,
    );
    await tester.tap(find.text('Nie teraz').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ustawienia'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.ensureVisible(
      find.byKey(const ValueKey('settings-language-row')),
    );
    await tester.pumpAndSettle();
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

  testWidgets('Delete all local data clears journal and preferences',
      (tester) async {
    final journalStore = InMemoryJournalStore(
      entries: [
        JournalEntry.note(
          id: 'entry-1',
          createdAt: DateTime(2026, 6, 25, 10),
          eventAt: DateTime(2026, 6, 25, 10),
          note: 'Test note',
        ),
      ],
    );
    final journalController = JournalController(store: journalStore);
    await journalController.load();
    final languageStore = FakeLanguagePreferenceStore(
      saved: AppLanguage.polish,
    );
    await _pumpNurtlyApp(
      tester,
      journalController: journalController,
      languagePreferenceStore: languageStore,
    );

    expect(find.text('Brak wpisu'), findsNothing);
    await _tapSettings(tester);
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usuń wszystkie dane lokalne').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usuń wszystkie dane lokalne').last);
    await tester.pumpAndSettle();

    expect(journalStore.entries, isEmpty);
    expect(languageStore.saved, isNull);
    await _tapBack(tester);
    await tester.pumpAndSettle();
    await _tapJournalTab(tester);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('journal-empty-state')), findsOneWidget);
  });

  testWidgets('Delete all local data surfaces preference delete failures',
      (tester) async {
    final journalStore = InMemoryJournalStore();
    final journalController = JournalController(store: journalStore);
    await journalController.load();
    final languageStore = _ThrowingLanguagePreferenceStore(failOnDelete: true);
    await _pumpNurtlyApp(
      tester,
      journalController: journalController,
      languagePreferenceStore: languageStore,
    );

    await _tapSettings(tester);
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete all local data').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete all local data').last);
    await tester.pumpAndSettle();

    expect(find.text('Could not delete local data.'), findsOneWidget);
    expect(journalStore.entries, isEmpty);
  });

  testWidgets('Privacy choices only appear when required', (tester) async {
    final consentFlow = _FakeConsentFlow(privacyRequired: true);
    await _pumpNurtlyApp(
      tester,
      consentFlow: consentFlow,
    );

    await _tapSettings(tester);
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pumpAndSettle();

    expect(find.text('Privacy choices'), findsOneWidget);
  });

  testWidgets('Privacy choices hide again when consent state changes',
      (tester) async {
    final consentFlow = _FakeConsentFlow(
      privacyRequired: true,
      canRequestAdsValue: true,
    );
    await _pumpNurtlyApp(
      tester,
      consentFlow: consentFlow,
    );

    await _tapSettings(tester);
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pumpAndSettle();

    expect(find.text('Privacy choices'), findsOneWidget);

    consentFlow.privacyRequired = false;
    consentFlow.notifyListeners();
    await tester.pumpAndSettle();

    expect(find.text('Privacy choices'), findsNothing);
  });

  testWidgets('saved Polish language overrides system locale on startup',
      (tester) async {
    await _pumpNurtlyApp(
      tester,
      systemLocale: const Locale('en'),
      languagePreferenceStore: FakeLanguagePreferenceStore(
        saved: AppLanguage.polish,
      ),
      reviewerAccessStore: FakeReviewerAccessStore(),
    );
    expect(find.text('D\u017awi\u0119ki'), findsOneWidget);
    expect(find.text('Spokojniejszy start'), findsOneWidget);
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
    await tester.tap(journalAction.first);
    await _pumpTabChange(tester);
    expect(find.byKey(const ValueKey('journal-scroll-view')), findsOneWidget);
    expect(find.byKey(const ValueKey('journal-header')), findsOneWidget);
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

Future<void> _tapSettings(WidgetTester tester) async {
  final settingsIcon = find.byIcon(Icons.settings_outlined);
  if (settingsIcon.evaluate().isNotEmpty) {
    await tester.tap(settingsIcon.first, warnIfMissed: false);
    return;
  }
  final english = find.byTooltip('Settings');
  final polish = find.byTooltip('Ustawienia');
  if (english.evaluate().isNotEmpty) {
    await tester.tap(english.first, warnIfMissed: false);
    return;
  }
  await tester.tap(polish.first, warnIfMissed: false);
}

Future<void> _openReviewerAccessDialog(WidgetTester tester) async {
  await _tapSettings(tester);
  await tester.pumpAndSettle();
  await _tapAboutFiveTimes(tester);
}

Future<void> _tapAboutFiveTimes(WidgetTester tester) async {
  await tester.ensureVisible(
    find.byKey(const ValueKey('settings-about-title')),
  );
  await tester.pumpAndSettle();
  final about = find.byKey(const ValueKey('settings-about-title'));
  for (var index = 0; index < 5; index++) {
    await tester.tap(about, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 120));
  }
  await tester.pumpAndSettle();
}

Future<void> _tapJournalTab(WidgetTester tester) async {
  final english = find.text('Journal');
  final polish = find.text('Dziennik');
  if (english.evaluate().isNotEmpty) {
    await tester.tap(english.first);
    return;
  }
  await tester.tap(polish.first);
}

Future<void> _tapBack(WidgetTester tester) async {
  final english = find.byTooltip('Back');
  final polish = find.byTooltip('Wstecz');
  if (english.evaluate().isNotEmpty) {
    await tester.tap(english.first);
    return;
  }
  await tester.tap(polish.first);
}

Future<void> _pumpNurtlyApp(
  WidgetTester tester, {
  Size size = const Size(600, 1200),
  Locale? systemLocale,
  LanguagePreferenceStore? languagePreferenceStore,
  FakePremiumEntitlementProvider? premiumEntitlementProvider,
  FakeReviewerAccessStore? reviewerAccessStore,
  ConsentFlow? consentFlow,
  JournalController? journalController,
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
        premiumEntitlementProvider:
            premiumEntitlementProvider ?? FakePremiumEntitlementProvider(),
        reviewerAccessStore: reviewerAccessStore ?? FakeReviewerAccessStore(),
        consentFlow: consentFlow,
        journalController: journalController,
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
  FakePremiumEntitlementProvider? premiumEntitlementProvider,
  FakeReviewerAccessStore? reviewerAccessStore,
  ConsentFlow? consentFlow,
  JournalController? journalController,
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
        premiumEntitlementProvider:
            premiumEntitlementProvider ?? FakePremiumEntitlementProvider(),
        reviewerAccessStore: reviewerAccessStore ?? FakeReviewerAccessStore(),
        consentFlow: consentFlow,
        journalController: journalController,
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
    this.failOnDelete = false,
  });

  final bool failOnLoad;
  final bool failOnSave;
  final bool failOnDelete;
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

  @override
  Future<void> delete() async {
    if (failOnDelete) {
      throw StateError('delete failed');
    }
  }
}

class _FakeConsentFlow extends ChangeNotifier implements ConsentFlow {
  _FakeConsentFlow({
    this.canRequestAdsValue = false,
    this.privacyRequired = false,
  });

  bool canRequestAdsValue;
  bool privacyRequired;
  int initializeCalls = 0;
  int showPrivacyOptionsCalls = 0;

  @override
  bool get canRequestAds => canRequestAdsValue;

  @override
  bool get privacyOptionsRequired => privacyRequired;

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<void> showPrivacyOptions() async {
    showPrivacyOptionsCalls++;
  }
}

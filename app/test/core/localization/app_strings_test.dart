import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_language.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/core/navigation/app_tab.dart';

void main() {
  test('English app strings expose the expected UI chrome', () {
    const strings = AppStrings.english;

    expect(strings.settings, 'Settings');
    expect(strings.general, 'General');
    expect(strings.languageLabel, 'Language');
    expect(strings.privacyData, 'Privacy & Data');
    expect(strings.premiumSectionTitle, 'Premium');
    expect(strings.premiumStatusLabel, 'Status');
    expect(strings.premiumStatusFree, 'Free plan');
    expect(strings.premiumStatusLifetimeActive, 'Lifetime Premium active');
    expect(strings.premiumUpgrade, 'Upgrade to Premium');
    expect(strings.restorePurchases, 'Restore Premium access');
    expect(strings.premiumRemovesAdsInFreePlan, 'Premium removes ads.');
    expect(
      strings.freePlanMayShowAdsInPassiveSlots,
      'Free plan may show ads in passive list slots.',
    );
    expect(
      strings.purchasesGoThroughGooglePlay,
      'Purchases on Android go through Google Play.',
    );
    expect(
      strings.journalContentNotUsedForAds,
      'Journal note content is not used for ads.',
    );
    expect(
      strings.premiumStateMayBeStoredLocally,
      'Premium state may be stored locally to keep access working.',
    );
    expect(strings.premiumNotNow, 'Not now');
    expect(
      strings.premiumRestoreAccessLink,
      'Already Premium? Restore access',
    );
    expect(
      strings.premiumRestoreUnavailableTitle,
      'Purchases are temporarily unavailable',
    );
    expect(
      strings.premiumRestoreUnavailableBody,
      'Please try again later.',
    );
    expect(strings.premiumRestoreNoPurchaseTitle,
        'No active Premium purchase was found');
    expect(strings.premiumRestoreNoPurchaseBody,
        'This Google Play account does not currently have Premium access.');
    expect(strings.premiumPurchasePending, 'Your purchase is pending.');
    expect(
      strings.premiumPurchaseUnavailable,
      'Purchases are temporarily unavailable. Please try again later.',
    );
    expect(strings.premiumTitle, 'Nurtly Premium');
    expect(strings.premiumRemoveAds, 'Remove ads');
    expect(strings.adPlaceholderTitle, 'Sponsored space');
    expect(strings.playTitle, 'Play');
    expect(strings.soundsTitle, 'Sounds');
    expect(strings.tabLabel(AppTab.journal), 'Journal');
    expect(strings.quickIdeasCount(2), '2 gentle ideas');
  });

  test('Polish app strings expose the expected UI chrome', () {
    const strings = AppStrings.polish;

    expect(strings.settings, 'Ustawienia');
    expect(strings.general, 'Ogólne');
    expect(strings.languageLabel, 'Język');
    expect(strings.privacyData, 'Prywatność i dane');
    expect(strings.premiumSectionTitle, 'Premium');
    expect(strings.premiumStatusLabel, 'Status');
    expect(strings.premiumStatusFree, 'Darmowy plan');
    expect(strings.premiumStatusLifetimeActive, 'Premium na stałe aktywne');
    expect(strings.premiumUpgrade, 'Przejdź na Premium');
    expect(strings.restorePurchases, 'Odzyskaj dostęp Premium');
    expect(strings.premiumRemovesAdsInFreePlan, 'Premium usuwa reklamy.');
    expect(
      strings.freePlanMayShowAdsInPassiveSlots,
      'Plan darmowy może wyświetlać reklamy w spokojnych miejscach list.',
    );
    expect(
      strings.purchasesGoThroughGooglePlay,
      'Zakupy na Androidzie odbywają się przez Google Play.',
    );
    expect(
      strings.journalContentNotUsedForAds,
      'Treści notatek z dziennika nie są używane do reklam.',
    );
    expect(
      strings.premiumStateMayBeStoredLocally,
      'Stan Premium może być przechowywany lokalnie, aby dostęp działał.',
    );
    expect(strings.premiumNotNow, 'Nie teraz');
    expect(
      strings.premiumRestoreAccessLink,
      'Masz już Premium? Odzyskaj dostęp',
    );
    expect(
      strings.premiumRestoreUnavailableTitle,
      'Zakupy nie są jeszcze dostępne',
    );
    expect(
      strings.premiumRestoreUnavailableBody,
      'Spróbuj ponownie później.',
    );
    expect(strings.premiumRestoreNoPurchaseTitle,
        'Nie znaleziono aktywnego dostępu Premium');
    expect(strings.premiumRestoreNoPurchaseBody,
        'To konto Google Play nie ma obecnie aktywnego dostępu Premium.');
    expect(strings.premiumPurchasePending, 'Zakup oczekuje na potwierdzenie.');
    expect(strings.premiumPurchaseUnavailable,
        'Zakupy są chwilowo niedostępne. Spróbuj ponownie później.');
    expect(strings.premiumTitle, 'Nurtly Premium');
    expect(strings.premiumRemoveAds, 'Usuń reklamy');
    expect(strings.adPlaceholderTitle, 'Miejsce sponsorowane');
    expect(strings.playTitle, 'Zabawy');
    expect(strings.soundsTitle, 'Dźwięki');
    expect(strings.tabLabel(AppTab.journal), 'Dziennik');
    expect(strings.quickIdeasCount(2), '2 łagodnych pomysłów');
    expect(
        strings.noPressureNoStreaksNoGoals, 'BEZ PRESJI, BEZ SERII, BEZ CELÓW');
  });

  test('AppStrings.forLanguage resolves the right bundle', () {
    expect(AppStrings.forLanguage(AppLanguage.english), AppStrings.english);
    expect(AppStrings.forLanguage(AppLanguage.polish), AppStrings.polish);
  });
}

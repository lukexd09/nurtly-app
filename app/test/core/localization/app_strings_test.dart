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
    expect(strings.premiumNotNow, 'Not now');
    expect(
      strings.premiumRestoreAccessLink,
      'Already Premium? Restore access',
    );
    expect(
      strings.premiumRestoreUnavailableTitle,
      'Purchases are not available in this MVP build yet',
    );
    expect(
      strings.premiumRestoreUnavailableBody,
      'Restore purchases will be enabled with Google Play Billing.',
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
      'Odzyskiwanie dostępu Premium zostanie włączone razem z Google Play Billing.',
    );
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

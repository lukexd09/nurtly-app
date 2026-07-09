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
    expect(strings.about, 'About');
    expect(strings.reviewerAccessTitle, 'Reviewer access');
    expect(strings.reviewerAccessSubtitle, 'Local only');
    expect(strings.reviewerAccessDialogTitle, 'Reviewer access');
    expect(strings.reviewerAccessActivate, 'Activate reviewer access');
    expect(strings.reviewerAccessEnabledStatus, 'On');
    expect(
      strings.reviewerAccessInvalidCode,
      'That reviewer code is not valid.',
    );
    expect(
      strings.reviewerAccessActionFailed,
      'Reviewer access could not be updated. Please try again.',
    );
    expect(
      strings.privacyChoicesFailed,
      'Could not open privacy choices. Please try again.',
    );
    expect(strings.premiumSectionTitle, 'Premium');
    expect(strings.premiumStatusLabel, 'Status');
    expect(strings.premiumStatusFree, 'Free plan');
    expect(strings.premiumStatusYearlyActive, 'Yearly Premium active');
    expect(strings.premiumUpgrade, 'Upgrade to Premium');
    expect(strings.restorePurchases, 'Restore Premium access');
    expect(strings.premiumRemovesAdsInFreePlan, 'Premium removes ads.');
    expect(strings.premiumLaunchOfferTitle, 'Launch offer -50%');
    expect(
      strings.premiumLaunchOfferDescription,
      'Premium library is still growing, so Premium starts at a lower price.',
    );
    expect(strings.premiumYearlyPlan, 'Premium Yearly');
    expect(strings.premiumYearlyPrice, '64.99 PLN / year');
    expect(
      strings.premiumYearlyRegularPrice,
      'Launch price, regular price 129.99 PLN / year',
    );
    expect(strings.premiumBestValue, 'Best value');
    expect(strings.premiumMonthlyPlan, 'Premium Monthly');
    expect(strings.premiumMonthlyPrice, '7.49 PLN / month');
    expect(
      strings.premiumMonthlyRegularPrice,
      'Launch price, regular price 14.99 PLN / month',
    );
    expect(strings.premiumUnlockPlayIdeas, 'Unlock premium play ideas');
    expect(strings.premiumUnlockSounds, 'Unlock premium sounds');
    expect(
      strings.premiumFuturePremiumContent,
      'New premium content in future updates',
    );
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
    expect(
      strings.premiumRestoreNoPurchaseTitle,
      'No active Premium purchase was found',
    );
    expect(
      strings.premiumRestoreNoPurchaseBody,
      'This Google Play account does not currently have Premium access.',
    );
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
    expect(strings.about, 'Informacje');
    expect(strings.reviewerAccessTitle, 'Dostęp recenzencki');
    expect(
      strings.reviewerAccessSubtitle,
      'Lokalny',
    );
    expect(strings.reviewerAccessDialogTitle, 'Dostęp recenzencki');
    expect(strings.reviewerAccessActivate, 'Aktywuj dostęp recenzencki');
    expect(strings.reviewerAccessEnabledStatus, 'Tak');
    expect(
      strings.reviewerAccessInvalidCode,
      'Kod recenzencki jest nieprawidłowy.',
    );
    expect(
      strings.reviewerAccessActionFailed,
      'Nie udało się zaktualizować dostępu recenzenckiego. Spróbuj ponownie.',
    );
    expect(strings.premiumSectionTitle, 'Premium');
    expect(strings.premiumStatusLabel, 'Status');
    expect(strings.premiumStatusFree, 'Darmowy plan');
    expect(strings.premiumStatusYearlyActive, 'Premium roczne aktywne');
    expect(strings.premiumUpgrade, 'Przejdź na Premium');
    expect(strings.restorePurchases, 'Odzyskaj dostęp Premium');
    expect(strings.premiumRemovesAdsInFreePlan, 'Premium usuwa reklamy.');
    expect(strings.premiumLaunchOfferTitle, 'Oferta startowa -50%');
    expect(
      strings.premiumLaunchOfferDescription,
      'Biblioteka premium będzie się rozwijać, dlatego na start Premium jest dostępne w niższej cenie.',
    );
    expect(strings.premiumYearlyPlan, 'Premium rocznie');
    expect(strings.premiumYearlyPrice, '64,99 PLN / rok');
    expect(
      strings.premiumYearlyRegularPrice,
      'Cena startowa, cena docelowa 129,99 PLN / rok',
    );
    expect(strings.premiumBestValue, 'Najlepsza wartość');
    expect(strings.premiumMonthlyPlan, 'Premium miesięcznie');
    expect(strings.premiumMonthlyPrice, '7,49 PLN / miesiąc');
    expect(
      strings.premiumMonthlyRegularPrice,
      'Cena startowa, cena docelowa 14,99 PLN / miesiąc',
    );
    expect(strings.premiumUnlockPlayIdeas, 'Odblokuj premium zabawy');
    expect(strings.premiumUnlockSounds, 'Odblokuj premium dźwięki');
    expect(
      strings.premiumFuturePremiumContent,
      'Nowe treści premium w kolejnych aktualizacjach',
    );
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
    expect(
      strings.premiumRestoreNoPurchaseTitle,
      'Nie znaleziono aktywnego dostępu Premium',
    );
    expect(
      strings.premiumRestoreNoPurchaseBody,
      'To konto Google Play nie ma obecnie aktywnego dostępu Premium.',
    );
    expect(strings.premiumPurchasePending, 'Zakup oczekuje na potwierdzenie.');
    expect(
      strings.premiumPurchaseUnavailable,
      'Zakupy są chwilowo niedostępne. Spróbuj ponownie później.',
    );
    expect(strings.premiumTitle, 'Nurtly Premium');
    expect(strings.premiumRemoveAds, 'Usuń reklamy');
    expect(strings.adPlaceholderTitle, 'Miejsce sponsorowane');
    expect(strings.playTitle, 'Zabawy');
    expect(strings.soundsTitle, 'Dźwięki');
    expect(strings.tabLabel(AppTab.journal), 'Dziennik');
    expect(strings.quickIdeasCount(2), '2 łagodnych pomysłów');
    expect(
      strings.noPressureNoStreaksNoGoals,
      'BEZ PRESJI, BEZ SERII, BEZ CELÓW',
    );
  });

  test('AppStrings.forLanguage resolves the right bundle', () {
    expect(AppStrings.forLanguage(AppLanguage.english), AppStrings.english);
    expect(AppStrings.forLanguage(AppLanguage.polish), AppStrings.polish);
  });

  test('Journal app strings expose the expected copy', () {
    expect(AppStrings.english.journalTitle, 'Journal');
    expect(
      AppStrings.english.journalEmptyStateTitle,
      'No care moments logged for this day yet.',
    );
    expect(AppStrings.english.journalNoEntryShort, 'No entry');
    expect(AppStrings.english.journalYesterdayLabel, 'Yesterday');
    expect(AppStrings.english.journalTomorrowLabel, 'Tomorrow');
    expect(AppStrings.english.journalGoToToday, 'Go to today');
    expect(AppStrings.english.journalChangeDay, 'Change day');
    expect(AppStrings.english.journalChooseTimeTitle, 'Choose time');
    expect(AppStrings.english.journalSavePicker, 'Save');
    expect(AppStrings.english.journalPickerNow, 'Now');
    expect(AppStrings.english.journalPickerMinus15, '-15 min');
    expect(AppStrings.english.journalPickerPlus15, '+15 min');
    expect(AppStrings.english.journalPickerHourLabel, 'Hour');
    expect(AppStrings.english.journalPickerMinuteLabel, 'Minutes');
    expect(AppStrings.english.journalQuickActionsTitle, 'Quick actions');
    expect(AppStrings.english.journalStartSleep, 'Start sleep');
    expect(AppStrings.english.journalStopSleep, 'Stop sleep');
    expect(AppStrings.english.journalLastMomentsTitle, 'Latest entries');
    expect(AppStrings.english.journalAmountLabel, 'Amount / note, optional');
    expect(AppStrings.english.journalQuickActionSleep, 'Sleep');
    expect(AppStrings.english.journalQuickActionFeeding, 'Feeding');
    expect(AppStrings.english.journalQuickActionDiaper, 'Diaper');
    expect(AppStrings.english.journalQuickActionNote, 'Note');
    expect(AppStrings.english.journalFeedingTypeBottle, 'Bottle');
    expect(AppStrings.english.journalDiaperTypeBoth, 'Both');

    expect(AppStrings.polish.journalTitle, 'Dziennik');
    expect(
      AppStrings.polish.journalEmptyStateTitle,
      'Nie zapisano jeszcze momentów opieki dla tego dnia.',
    );
    expect(
      AppStrings.polish.journalEmptyStateMessage,
      'Dodaj pierwszy wpis, gdy będziesz mieć chwilę.',
    );
    expect(AppStrings.polish.journalNoEntryShort, 'Brak wpisu');
    expect(AppStrings.polish.journalYesterdayLabel, 'Wczoraj');
    expect(AppStrings.polish.journalTomorrowLabel, 'Jutro');
    expect(AppStrings.polish.journalGoToToday, 'Przejdź do dziś');
    expect(AppStrings.polish.journalChangeDay, 'Zmień dzień');
    expect(AppStrings.polish.journalChooseTimeTitle, 'Wybierz godzinę');
    expect(AppStrings.polish.journalSavePicker, 'Zapisz');
    expect(AppStrings.polish.journalPickerNow, 'Teraz');
    expect(AppStrings.polish.journalPickerMinus15, '-15 min');
    expect(AppStrings.polish.journalPickerPlus15, '+15 min');
    expect(AppStrings.polish.journalPickerHourLabel, 'Godzina');
    expect(AppStrings.polish.journalPickerMinuteLabel, 'Minuty');
    expect(AppStrings.polish.journalQuickActionsTitle, 'Szybkie akcje');
    expect(AppStrings.polish.journalStartSleep, 'Rozpocznij sen');
    expect(AppStrings.polish.journalStopSleep, 'Zakończ sen');
    expect(AppStrings.polish.journalLastMomentsTitle, 'Ostatnie wpisy');
    expect(
      AppStrings.polish.journalAmountLabel,
      'Ilość / opis, opcjonalnie',
    );
    expect(AppStrings.polish.journalQuickActionSleep, 'Sen');
    expect(AppStrings.polish.journalQuickActionFeeding, 'Karmienie');
    expect(AppStrings.polish.journalQuickActionDiaper, 'Pielucha');
    expect(AppStrings.polish.journalQuickActionNote, 'Notatka');
    expect(AppStrings.polish.journalFeedingTypeBottle, 'Butelka');
    expect(AppStrings.polish.journalDiaperTypeBoth, 'Oba');
  });
}

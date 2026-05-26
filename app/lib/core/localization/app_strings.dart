import '../navigation/app_tab.dart';
import 'app_language.dart';

class AppStrings {
  const AppStrings._({
    required this.language,
    required this.settings,
    required this.general,
    required this.languageLabel,
    required this.privacy,
    required this.privacyData,
    required this.homeShellSubtitle,
    required this.homeTitle,
    required this.homeSubtitle,
    required this.homeHeroSubtitle,
    required this.homeStartTitle,
    required this.homeStartDescription,
    required this.noPressureNoStreaksNoGoals,
    required this.todaysIdea,
    required this.openTodaysIdea,
    required this.startWithOneSmallMoment,
    required this.findAPlayIdea,
    required this.saveSmallNote,
    required this.saveSmallNoteSubtitle,
    required this.startCalmingSound,
    required this.startCalmingSoundSubtitle,
    required this.todaysIdeaUnavailable,
    required this.playTitle,
    required this.playSubtitle,
    required this.chooseGentlePlayIdea,
    required this.findTheRightFit,
    required this.clearFilters,
    required this.loadingPlayIdeas,
    required this.playIdeasCouldNotBeLoaded,
    required this.noPlayIdeasTitle,
    required this.noPlayIdeasMessage,
    required this.nothingHereYetTitle,
    required this.nothingHereYetMessage,
    required this.pleaseTryAgain,
    required this.whatYouNeed,
    required this.steps,
    required this.whatToExpect,
    required this.parentNote,
    required this.safetyNote,
    required this.suggestedSound,
    required this.soundsTitle,
    required this.soundsSubtitle,
    required this.loadingSounds,
    required this.soundsCouldNotBeLoaded,
    required this.noSoundsTitle,
    required this.noSoundsMessage,
    required this.loading,
    required this.ready,
    required this.playing,
    required this.paused,
    required this.play,
    required this.pause,
    required this.couldNotPlay,
    required this.couldNotPlaySound,
    required this.soundSafetyNote,
    required this.autoFadeEnabled,
    required this.autoFadeAvailableWithTimer,
    required this.continuousPlay,
    required this.left,
    required this.free,
    required this.premium,
    required this.privacyTitle,
    required this.privacySubtitle,
    required this.currentMvpBehavior,
    required this.noAccount,
    required this.noJournalCloudSync,
    required this.noCloudSync,
    required this.noAnalytics,
    required this.noAds,
    required this.bundledSampleContent,
    required this.futureChangesTitle,
    required this.futureChanges,
    required this.back,
    required this.settingsTooltip,
    required this.premiumSectionTitle,
    required this.premiumStatusLabel,
    required this.premiumStatusFree,
    required this.premiumStatusActive,
    required this.premiumStatusLifetimeActive,
    required this.premiumStatusPending,
    required this.premiumStatusPaymentIssue,
    required this.premiumUpgrade,
    required this.premiumManage,
    required this.restorePurchases,
    required this.premiumTitle,
    required this.premiumPaywallSubtitle,
    required this.premiumRemoveAds,
    required this.premiumUnlockContent,
    required this.premiumMonthlyPlan,
    required this.premiumLifetimePlan,
    required this.premiumMonthlyPrice,
    required this.premiumLifetimePrice,
    required this.premiumBillingComingSoon,
    required this.adPlaceholderTitle,
    required this.adPlaceholderSubtitle,
  });

  final AppLanguage language;
  final String settings;
  final String general;
  final String languageLabel;
  final String privacy;
  final String privacyData;
  final String homeShellSubtitle;
  final String homeTitle;
  final String homeSubtitle;
  final String homeHeroSubtitle;
  final String homeStartTitle;
  final String homeStartDescription;
  final String noPressureNoStreaksNoGoals;
  final String todaysIdea;
  final String openTodaysIdea;
  final String startWithOneSmallMoment;
  final String findAPlayIdea;
  final String saveSmallNote;
  final String saveSmallNoteSubtitle;
  final String startCalmingSound;
  final String startCalmingSoundSubtitle;
  final String todaysIdeaUnavailable;
  final String playTitle;
  final String playSubtitle;
  final String chooseGentlePlayIdea;
  final String findTheRightFit;
  final String clearFilters;
  final String loadingPlayIdeas;
  final String playIdeasCouldNotBeLoaded;
  final String noPlayIdeasTitle;
  final String noPlayIdeasMessage;
  final String nothingHereYetTitle;
  final String nothingHereYetMessage;
  final String pleaseTryAgain;
  final String whatYouNeed;
  final String steps;
  final String whatToExpect;
  final String parentNote;
  final String safetyNote;
  final String suggestedSound;
  final String soundsTitle;
  final String soundsSubtitle;
  final String loadingSounds;
  final String soundsCouldNotBeLoaded;
  final String noSoundsTitle;
  final String noSoundsMessage;
  final String loading;
  final String ready;
  final String playing;
  final String paused;
  final String play;
  final String pause;
  final String couldNotPlay;
  final String couldNotPlaySound;
  final String soundSafetyNote;
  final String autoFadeEnabled;
  final String autoFadeAvailableWithTimer;
  final String continuousPlay;
  final String left;
  final String free;
  final String premium;
  final String privacyTitle;
  final String privacySubtitle;
  final String currentMvpBehavior;
  final String noAccount;
  final String noJournalCloudSync;
  final String noCloudSync;
  final String noAnalytics;
  final String noAds;
  final String bundledSampleContent;
  final String futureChangesTitle;
  final String futureChanges;
  final String back;
  final String settingsTooltip;
  final String premiumSectionTitle;
  final String premiumStatusLabel;
  final String premiumStatusFree;
  final String premiumStatusActive;
  final String premiumStatusLifetimeActive;
  final String premiumStatusPending;
  final String premiumStatusPaymentIssue;
  final String premiumUpgrade;
  final String premiumManage;
  final String restorePurchases;
  final String premiumTitle;
  final String premiumPaywallSubtitle;
  final String premiumRemoveAds;
  final String premiumUnlockContent;
  final String premiumMonthlyPlan;
  final String premiumLifetimePlan;
  final String premiumMonthlyPrice;
  final String premiumLifetimePrice;
  final String premiumBillingComingSoon;
  final String adPlaceholderTitle;
  final String adPlaceholderSubtitle;

  static const english = AppStrings._(
    language: AppLanguage.english,
    settings: 'Settings',
    general: 'General',
    languageLabel: 'Language',
    privacy: 'Privacy',
    privacyData: 'Privacy & Data',
    homeShellSubtitle: 'A quieter start',
    homeTitle: 'Start',
    homeSubtitle: 'Start with one small moment',
    homeHeroSubtitle:
        'Choose a gentle idea, save a quiet note, or add a calming sound when the day feels full.',
    homeStartTitle: 'A gentle start for now',
    homeStartDescription:
        'Try one simple, screen-free moment before the day gets louder.',
    noPressureNoStreaksNoGoals: 'NO PRESSURE, NO STREAKS, NO GOALS',
    todaysIdea: "Today's idea",
    openTodaysIdea: "Open today's idea",
    startWithOneSmallMoment: 'Start with one small moment',
    findAPlayIdea: 'Find a play idea',
    saveSmallNote: 'Save a small note',
    saveSmallNoteSubtitle: 'Keep the moment without overthinking it.',
    startCalmingSound: 'Start a calming sound',
    startCalmingSoundSubtitle: 'A quiet background for a softer pause.',
    todaysIdeaUnavailable: "Today's idea is not available yet.",
    playTitle: 'Play',
    playSubtitle:
        'Simple screen-free moments for connection, calm, and everyday family rhythm.',
    chooseGentlePlayIdea: 'Choose a gentle play idea',
    findTheRightFit: 'Find the right fit',
    clearFilters: 'Clear',
    loadingPlayIdeas: 'Loading play ideas...',
    playIdeasCouldNotBeLoaded: 'Play ideas could not be loaded.',
    noPlayIdeasTitle: 'No play ideas available yet.',
    noPlayIdeasMessage: 'More simple ideas will appear here later.',
    nothingHereYetTitle: 'Nothing here yet',
    nothingHereYetMessage:
        'Try removing one filter for now. More gentle ideas are coming.',
    pleaseTryAgain: 'Please try again in a moment.',
    whatYouNeed: "What you'll need",
    steps: 'Steps',
    whatToExpect: 'What to expect',
    parentNote: 'Parent note',
    safetyNote: 'Safety note',
    suggestedSound: 'Suggested sound',
    soundsTitle: 'Sounds',
    soundsSubtitle: 'Choose a sound for a quiet moment.',
    loadingSounds: 'Loading sounds...',
    soundsCouldNotBeLoaded: 'Sounds could not be loaded.',
    noSoundsTitle: 'No sounds available yet.',
    noSoundsMessage: 'Quiet sound options will appear here later.',
    loading: 'Loading',
    ready: 'Ready',
    playing: 'Playing',
    paused: 'Paused',
    play: 'Play',
    pause: 'Pause',
    couldNotPlay: 'Could not play',
    couldNotPlaySound: 'Could not play this sound.',
    soundSafetyNote: 'Keep volume comfortable and device away from child.',
    autoFadeEnabled: 'Auto-fade enabled',
    autoFadeAvailableWithTimer: 'Auto-fade available with timer',
    continuousPlay: 'Continuous play',
    left: 'left',
    free: 'Free',
    premium: 'Premium',
    privacyTitle: 'Privacy & Data',
    privacySubtitle: 'What Nurtly does with data in this MVP.',
    currentMvpBehavior: 'Current MVP behavior',
    noAccount: 'No account is used.',
    noJournalCloudSync: 'Journal notes stay on this device only.',
    noCloudSync: 'No cloud sync is currently enabled.',
    noAnalytics: 'No analytics are currently enabled.',
    noAds: 'No ads are currently enabled.',
    bundledSampleContent: 'Bundled sample content is included in the app.',
    futureChangesTitle: 'Future changes',
    futureChanges:
        'Future data-related changes should be introduced clearly before they are enabled.',
    back: 'Back',
    settingsTooltip: 'Settings',
    premiumSectionTitle: 'Premium',
    premiumStatusLabel: 'Status',
    premiumStatusFree: 'Free plan',
    premiumStatusActive: 'Premium active',
    premiumStatusLifetimeActive: 'Lifetime Premium active',
    premiumStatusPending: 'Purchase pending',
    premiumStatusPaymentIssue: 'Payment issue',
    premiumUpgrade: 'Upgrade to Premium',
    premiumManage: 'Manage Premium',
    restorePurchases: 'Restore purchases',
    premiumTitle: 'Nurtly Premium',
    premiumPaywallSubtitle:
        'Remove ads and unlock premium play ideas and sounds.',
    premiumRemoveAds: 'Remove ads',
    premiumUnlockContent: 'Unlock premium play ideas and sounds',
    premiumMonthlyPlan: 'Premium Monthly',
    premiumLifetimePlan: 'Premium Lifetime',
    premiumMonthlyPrice: '14.99 PLN / month',
    premiumLifetimePrice: '129.99 PLN once',
    premiumBillingComingSoon: 'Billing coming soon',
    adPlaceholderTitle: 'Sponsored space',
    adPlaceholderSubtitle: 'Shown only in passive free-plan slots.',
  );

  static const polish = AppStrings._(
    language: AppLanguage.polish,
    settings: 'Ustawienia',
    general: 'Ogólne',
    languageLabel: 'Język',
    privacy: 'Prywatność',
    privacyData: 'Prywatność i dane',
    homeShellSubtitle: 'Spokojniejszy start',
    homeTitle: 'Start',
    homeSubtitle: 'Zacznij od jednej małej chwili',
    homeHeroSubtitle:
        'Wybierz łagodny pomysł, zapisz krótką notatkę albo włącz wyciszający dźwięk, gdy dzień robi się pełniejszy.',
    homeStartTitle: 'Łagodny początek na teraz',
    homeStartDescription:
        'Spróbuj jednej prostej chwili bez ekranu, zanim dzień zrobi się głośniejszy.',
    noPressureNoStreaksNoGoals: 'BEZ PRESJI, BEZ SERII, BEZ CELÓW',
    todaysIdea: 'Dzisiejszy pomysł',
    openTodaysIdea: 'Otwórz dzisiejszy pomysł',
    startWithOneSmallMoment: 'Zacznij od jednej małej chwili',
    findAPlayIdea: 'Znajdź odpowiednią zabawę',
    saveSmallNote: 'Zapisz krótką notatkę',
    saveSmallNoteSubtitle: 'Zachowaj tę chwilę bez zbędnego zastanawiania się.',
    startCalmingSound: 'Włącz wyciszający dźwięk',
    startCalmingSoundSubtitle: 'Spokojne tło dla łagodniejszej chwili.',
    todaysIdeaUnavailable: 'Dzisiejszy pomysł nie jest jeszcze dostępny.',
    playTitle: 'Zabawy',
    playSubtitle:
        'Proste chwile bez ekranu dla bliskości, spokoju i codziennego rytmu rodziny.',
    chooseGentlePlayIdea: 'Wybierz łagodny pomysł na zabawę',
    findTheRightFit: 'Znajdź odpowiednią zabawę',
    clearFilters: 'Wyczyść',
    loadingPlayIdeas: 'Ładowanie pomysłów na zabawę...',
    playIdeasCouldNotBeLoaded: 'Nie udało się wczytać pomysłów na zabawę.',
    noPlayIdeasTitle: 'Brak pomysłów na zabawę.',
    noPlayIdeasMessage: 'Wkrótce pojawi się tu więcej prostych pomysłów.',
    nothingHereYetTitle: 'Nic tu jeszcze nie ma',
    nothingHereYetMessage:
        'Spróbuj na razie usunąć jeden filtr. Wkrótce pojawi się więcej łagodnych pomysłów.',
    pleaseTryAgain: 'Spróbuj ponownie za chwilę.',
    whatYouNeed: 'Co będzie potrzebne',
    steps: 'Kroki',
    whatToExpect: 'Czego możesz się spodziewać',
    parentNote: 'Wskazówka dla rodzica',
    safetyNote: 'Bezpieczeństwo',
    suggestedSound: 'Sugerowany dźwięk',
    soundsTitle: 'Dźwięki',
    soundsSubtitle: 'Wybierz dźwięk na spokojną chwilę.',
    loadingSounds: 'Ładowanie dźwięków...',
    soundsCouldNotBeLoaded: 'Nie udało się wczytać dźwięków.',
    noSoundsTitle: 'Brak dźwięków.',
    noSoundsMessage: 'Wkrótce pojawią się tu kolejne spokojne dźwięki.',
    loading: 'Ładowanie',
    ready: 'Gotowe',
    playing: 'Odtwarzanie',
    paused: 'Wstrzymano',
    play: 'Odtwórz',
    pause: 'Wstrzymaj',
    couldNotPlay: 'Nie udało się odtworzyć',
    couldNotPlaySound: 'Nie udało się odtworzyć tego dźwięku.',
    soundSafetyNote:
        'Utrzymuj głośność na komfortowym poziomie i trzymaj urządzenie z dala od dziecka.',
    autoFadeEnabled: 'Wygaszanie włączone',
    autoFadeAvailableWithTimer: 'Wygaszanie dostępne z czasomierzem',
    continuousPlay: 'Ciągłe odtwarzanie',
    left: 'pozostało',
    free: 'Darmowe',
    premium: 'Premium',
    privacyTitle: 'Prywatność i dane',
    privacySubtitle: 'Jak Nurtly używa danych w tym MVP.',
    currentMvpBehavior: 'Obecne działanie MVP',
    noAccount: 'Nie używamy konta.',
    noJournalCloudSync:
        'Notatki z dziennika pozostają tylko na tym urządzeniu.',
    noCloudSync: 'Obecnie nie ma synchronizacji z chmurą.',
    noAnalytics: 'Obecnie nie ma analityki.',
    noAds: 'Obecnie nie ma reklam.',
    bundledSampleContent:
        'W aplikacji znajdują się przykładowe treści wbudowane.',
    futureChangesTitle: 'Przyszłe zmiany',
    futureChanges:
        'Przyszłe zmiany związane z danymi powinny być jasno opisane przed włączeniem.',
    back: 'Wstecz',
    settingsTooltip: 'Ustawienia',
    premiumSectionTitle: 'Premium',
    premiumStatusLabel: 'Status',
    premiumStatusFree: 'Darmowy plan',
    premiumStatusActive: 'Premium aktywne',
    premiumStatusLifetimeActive: 'Premium na stałe aktywne',
    premiumStatusPending: 'Zakup oczekuje na potwierdzenie',
    premiumStatusPaymentIssue: 'Problem z płatnością',
    premiumUpgrade: 'Przejdź na Premium',
    premiumManage: 'Zarządzaj Premium',
    restorePurchases: 'Przywróć zakupy',
    premiumTitle: 'Nurtly Premium',
    premiumPaywallSubtitle: 'Usuń reklamy i odblokuj premium zabawy i dźwięki.',
    premiumRemoveAds: 'Usuń reklamy',
    premiumUnlockContent: 'Odblokuj premium zabawy i dźwięki',
    premiumMonthlyPlan: 'Premium miesięcznie',
    premiumLifetimePlan: 'Premium na stałe',
    premiumMonthlyPrice: '14,99 PLN / miesiąc',
    premiumLifetimePrice: '129,99 PLN jednorazowo',
    premiumBillingComingSoon: 'Płatności będą dostępne w kolejnej wersji MVP',
    adPlaceholderTitle: 'Miejsce sponsorowane',
    adPlaceholderSubtitle: 'Widoczne tylko w spokojnych miejscach planu Free.',
  );

  static AppStrings forLanguage(AppLanguage language) {
    return switch (language) {
      AppLanguage.english => english,
      AppLanguage.polish => polish,
    };
  }

  String tabLabel(AppTab tab) {
    return switch (tab) {
      AppTab.home => language == AppLanguage.english ? 'Home' : 'Start',
      AppTab.play => playTitle,
      AppTab.journal =>
        language == AppLanguage.english ? 'Journal' : 'Dziennik',
      AppTab.sounds => soundsTitle,
    };
  }

  String quickIdeasCount(int count) {
    return switch (language) {
      AppLanguage.english => '$count gentle ideas',
      AppLanguage.polish => '$count łagodnych pomysłów',
    };
  }

  String premiumStatusActiveUntil(String value) {
    return switch (language) {
      AppLanguage.english => 'Premium active until $value',
      AppLanguage.polish => 'Premium aktywne do $value',
    };
  }

  String expectationMess(String id) {
    return switch (language) {
      AppLanguage.english => switch (id) {
          'mess_low' => 'low-mess',
          'mess_medium' => 'slightly messy',
          'mess_high' => 'more cleanup',
          _ => '',
        },
      AppLanguage.polish => switch (id) {
          'mess_low' => 'mało bałaganu',
          'mess_medium' => 'trochę bałaganu',
          'mess_high' => 'więcej sprzątania',
          _ => '',
        },
    };
  }

  String expectationChildEnergy(String id) {
    return switch (language) {
      AppLanguage.english => switch (id) {
          'child_engagement_low' => 'quiet',
          'child_engagement_medium' => 'gently engaging',
          'child_engagement_high' => 'more active',
          _ => '',
        },
      AppLanguage.polish => switch (id) {
          'child_engagement_low' => 'spokojna',
          'child_engagement_medium' => 'łagodnie angażująca',
          'child_engagement_high' => 'bardziej aktywna',
          _ => '',
        },
    };
  }

  String expectationParentEffort(String id) {
    return switch (language) {
      AppLanguage.english => switch (id) {
          'parent_involvement_low' => 'does not need much setup',
          'parent_involvement_medium' =>
            'works best with a little shared attention',
          'parent_involvement_high' =>
            'works best when you have energy to join in',
          _ => '',
        },
      AppLanguage.polish => switch (id) {
          'parent_involvement_low' => 'nie wymaga wielu przygotowań',
          'parent_involvement_medium' =>
            'najlepiej działa przy odrobinie wspólnej uwagi',
          'parent_involvement_high' =>
            'najlepiej działa, gdy masz siłę do wspólnego udziału',
          _ => '',
        },
    };
  }

  String expectationGuidance(String id) {
    return switch (language) {
      AppLanguage.english => switch (id) {
          'parent_involvement_low' =>
            'Stay nearby, offer gentle guidance, and let your child explore at their own pace.',
          'parent_involvement_medium' =>
            'Join in for a few moments and keep the play easy.',
          'parent_involvement_high' =>
            'Choose it when active participation feels available.',
          _ => '',
        },
      AppLanguage.polish => switch (id) {
          'parent_involvement_low' =>
            'Bądź obok, dawaj delikatne wskazówki i pozwól dziecku odkrywać we własnym tempie.',
          'parent_involvement_medium' =>
            'Dołącz na chwilę i zadbaj, by zabawa była prosta.',
          'parent_involvement_high' =>
            'Wybierz ją, gdy masz przestrzeń na aktywny udział.',
          _ => '',
        },
    };
  }

  String expectationFallback({
    required String messId,
    required String childId,
    required String parentId,
  }) {
    final mess = expectationMess(messId);
    final child = expectationChildEnergy(childId);
    final parent = expectationParentEffort(parentId);
    final guidance = expectationGuidance(parentId);
    if (mess.isEmpty || child.isEmpty || parent.isEmpty || guidance.isEmpty) {
      return switch (language) {
        AppLanguage.english =>
          'Choose this when it feels like a good fit for your space, your child, and the energy you have available.',
        AppLanguage.polish =>
          'Wybierz to, gdy pasuje do waszej przestrzeni, dziecka i energii, którą masz dziś do dyspozycji.',
      };
    }
    return switch (language) {
      AppLanguage.english => 'A $child, $mess activity that $parent. $guidance',
      AppLanguage.polish =>
        'To $child, $mess aktywność, która $parent. $guidance',
    };
  }
}

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
    required this.about,
    required this.reviewerAccess,
    required this.reviewerAccessTitle,
    required this.reviewerAccessSubtitle,
    required this.reviewerAccessDialogTitle,
    required this.reviewerAccessDialogBody,
    required this.reviewerAccessCodeLabel,
    required this.reviewerAccessActivate,
    required this.reviewerAccessReset,
    required this.reviewerAccessEnabledStatus,
    required this.reviewerAccessEnabledMessage,
    required this.reviewerAccessInvalidCode,
    required this.reviewerAccessActionFailed,
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
    required this.journalTitle,
    required this.journalSubtitle,
    required this.journalLocalOnlyHint,
    required this.journalTodayLabel,
    required this.journalYesterdayLabel,
    required this.journalTomorrowLabel,
    required this.journalPreviousDay,
    required this.journalNextDay,
    required this.journalGoToToday,
    required this.journalChangeDay,
    required this.journalChooseTimeTitle,
    required this.journalSavePicker,
    required this.journalPickerNow,
    required this.journalPickerMinus15,
    required this.journalPickerPlus15,
    required this.journalPickerPreviousDay,
    required this.journalPickerNextDay,
    required this.journalPickerHourLabel,
    required this.journalPickerMinuteLabel,
    required this.journalQuickActionsTitle,
    required this.journalEmptyStateTitle,
    required this.journalEmptyStateMessage,
    required this.journalNoEntryShort,
    required this.journalAddSleep,
    required this.journalAddFeeding,
    required this.journalAddDiaper,
    required this.journalAddNote,
    required this.journalQuickActionSleep,
    required this.journalQuickActionFeeding,
    required this.journalQuickActionDiaper,
    required this.journalQuickActionNote,
    required this.journalStartSleep,
    required this.journalStopSleep,
    required this.journalActiveSleepTitle,
    required this.journalActiveSleepStartedLabel,
    required this.journalActiveSleepDurationLabel,
    required this.journalDashboardTitle,
    required this.journalLastSleep,
    required this.journalLastFeeding,
    required this.journalLastDiaper,
    required this.journalNotesToday,
    required this.journalTotalSleep,
    required this.journalFeedingsCount,
    required this.journalDiapersCount,
    required this.journalNotesCount,
    required this.journalLastMomentsTitle,
    required this.journalNoSleepToday,
    required this.journalNoFeedingToday,
    required this.journalNoDiaperToday,
    required this.journalNoNotesToday,
    required this.journalEditEntry,
    required this.journalDeleteEntry,
    required this.journalDeleteEntryTitle,
    required this.journalDeleteEntryBody,
    required this.journalSaveEntry,
    required this.journalCancelEntry,
    required this.journalNoteLabel,
    required this.journalNoteHint,
    required this.journalEventTimeLabel,
    required this.journalSleepStartLabel,
    required this.journalSleepEndLabel,
    required this.journalFeedingTypeLabel,
    required this.journalAmountLabel,
    required this.journalDiaperTypeLabel,
    required this.journalNoteRequired,
    required this.journalSleepInvalidRange,
    required this.journalEntryTypeSleep,
    required this.journalEntryTypeFeeding,
    required this.journalEntryTypeDiaper,
    required this.journalEntryTypeNote,
    required this.journalFeedingTypeBreast,
    required this.journalFeedingTypeBottle,
    required this.journalFeedingTypeFood,
    required this.journalFeedingTypeOther,
    required this.journalDiaperTypePee,
    required this.journalDiaperTypePoop,
    required this.journalDiaperTypeBoth,
    required this.journalDiaperTypeDry,
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
    required this.privacyChoices,
    required this.deleteAllLocalData,
    required this.deleteAllLocalDataTitle,
    required this.deleteAllLocalDataBody,
    required this.deleteAllLocalDataSuccess,
    required this.deleteAllLocalDataFailed,
    required this.currentMvpBehavior,
    required this.parentFirstAudience,
    required this.childNameNotRequired,
    required this.birthdateNotRequired,
    required this.noAccount,
    required this.noJournalCloudSync,
    required this.noCloudSync,
    required this.noAnalytics,
    required this.analyticsScopeMayInclude,
    required this.noAds,
    required this.premiumRemovesAdsInFreePlan,
    required this.freePlanMayShowAdsInPassiveSlots,
    required this.purchasesGoThroughGooglePlay,
    required this.journalContentNotUsedForAds,
    required this.premiumStateMayBeStoredLocally,
    required this.bundledSampleContent,
    required this.futureChangesTitle,
    required this.futureChanges,
    required this.back,
    required this.settingsTooltip,
    required this.premiumSectionTitle,
    required this.premiumStatusLabel,
    required this.premiumStatusFree,
    required this.premiumStatusActive,
    required this.premiumStatusYearlyActive,
    required this.premiumStatusPending,
    required this.premiumStatusPaymentIssue,
    required this.premiumUpgrade,
    required this.premiumManage,
    required this.restorePurchases,
    required this.premiumNotNow,
    required this.premiumRestoreAccessLink,
    required this.premiumTitle,
    required this.premiumPaywallSubtitle,
    required this.premiumLaunchOfferTitle,
    required this.premiumLaunchOfferDescription,
    required this.premiumYearlyPlan,
    required this.premiumYearlyPrice,
    required this.premiumYearlyRegularPrice,
    required this.premiumBestValue,
    required this.premiumMonthlyPlan,
    required this.premiumMonthlyPrice,
    required this.premiumMonthlyRegularPrice,
    required this.premiumRemoveAds,
    required this.premiumUnlockPlayIdeas,
    required this.premiumUnlockSounds,
    required this.premiumFuturePremiumContent,
    required this.premiumRestoreUnavailableTitle,
    required this.premiumRestoreUnavailableBody,
    required this.premiumRestoreNoPurchaseTitle,
    required this.premiumRestoreNoPurchaseBody,
    required this.premiumPurchasePending,
    required this.premiumPurchaseUnavailable,
    required this.adPlaceholderTitle,
    required this.adPlaceholderSubtitle,
  });

  final AppLanguage language;
  final String settings;
  final String general;
  final String languageLabel;
  final String privacy;
  final String privacyData;
  final String about;
  final String reviewerAccess;
  final String reviewerAccessTitle;
  final String reviewerAccessSubtitle;
  final String reviewerAccessDialogTitle;
  final String reviewerAccessDialogBody;
  final String reviewerAccessCodeLabel;
  final String reviewerAccessActivate;
  final String reviewerAccessReset;
  final String reviewerAccessEnabledStatus;
  final String reviewerAccessEnabledMessage;
  final String reviewerAccessInvalidCode;
  final String reviewerAccessActionFailed;
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
  final String journalTitle;
  final String journalSubtitle;
  final String journalLocalOnlyHint;
  final String journalTodayLabel;
  final String journalYesterdayLabel;
  final String journalTomorrowLabel;
  final String journalPreviousDay;
  final String journalNextDay;
  final String journalGoToToday;
  final String journalChangeDay;
  final String journalChooseTimeTitle;
  final String journalSavePicker;
  final String journalPickerNow;
  final String journalPickerMinus15;
  final String journalPickerPlus15;
  final String journalPickerPreviousDay;
  final String journalPickerNextDay;
  final String journalPickerHourLabel;
  final String journalPickerMinuteLabel;
  final String journalQuickActionsTitle;
  final String journalEmptyStateTitle;
  final String journalEmptyStateMessage;
  final String journalNoEntryShort;
  final String journalAddSleep;
  final String journalAddFeeding;
  final String journalAddDiaper;
  final String journalAddNote;
  final String journalQuickActionSleep;
  final String journalQuickActionFeeding;
  final String journalQuickActionDiaper;
  final String journalQuickActionNote;
  final String journalStartSleep;
  final String journalStopSleep;
  final String journalActiveSleepTitle;
  final String journalActiveSleepStartedLabel;
  final String journalActiveSleepDurationLabel;
  final String journalDashboardTitle;
  final String journalLastSleep;
  final String journalLastFeeding;
  final String journalLastDiaper;
  final String journalNotesToday;
  final String journalTotalSleep;
  final String journalFeedingsCount;
  final String journalDiapersCount;
  final String journalNotesCount;
  final String journalLastMomentsTitle;
  final String journalNoSleepToday;
  final String journalNoFeedingToday;
  final String journalNoDiaperToday;
  final String journalNoNotesToday;
  final String journalEditEntry;
  final String journalDeleteEntry;
  final String journalDeleteEntryTitle;
  final String journalDeleteEntryBody;
  final String journalSaveEntry;
  final String journalCancelEntry;
  final String journalNoteLabel;
  final String journalNoteHint;
  final String journalEventTimeLabel;
  final String journalSleepStartLabel;
  final String journalSleepEndLabel;
  final String journalFeedingTypeLabel;
  final String journalAmountLabel;
  final String journalDiaperTypeLabel;
  final String journalNoteRequired;
  final String journalSleepInvalidRange;
  final String journalEntryTypeSleep;
  final String journalEntryTypeFeeding;
  final String journalEntryTypeDiaper;
  final String journalEntryTypeNote;
  final String journalFeedingTypeBreast;
  final String journalFeedingTypeBottle;
  final String journalFeedingTypeFood;
  final String journalFeedingTypeOther;
  final String journalDiaperTypePee;
  final String journalDiaperTypePoop;
  final String journalDiaperTypeBoth;
  final String journalDiaperTypeDry;
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
  final String privacyChoices;
  final String deleteAllLocalData;
  final String deleteAllLocalDataTitle;
  final String deleteAllLocalDataBody;
  final String deleteAllLocalDataSuccess;
  final String deleteAllLocalDataFailed;
  final String currentMvpBehavior;
  final String parentFirstAudience;
  final String childNameNotRequired;
  final String birthdateNotRequired;
  final String noAccount;
  final String noJournalCloudSync;
  final String noCloudSync;
  final String noAnalytics;
  final String analyticsScopeMayInclude;
  final String noAds;
  final String premiumRemovesAdsInFreePlan;
  final String freePlanMayShowAdsInPassiveSlots;
  final String purchasesGoThroughGooglePlay;
  final String journalContentNotUsedForAds;
  final String premiumStateMayBeStoredLocally;
  final String bundledSampleContent;
  final String futureChangesTitle;
  final String futureChanges;
  final String back;
  final String settingsTooltip;
  final String premiumSectionTitle;
  final String premiumStatusLabel;
  final String premiumStatusFree;
  final String premiumStatusActive;
  final String premiumStatusYearlyActive;
  final String premiumStatusPending;
  final String premiumStatusPaymentIssue;
  final String premiumUpgrade;
  final String premiumManage;
  final String restorePurchases;
  final String premiumNotNow;
  final String premiumRestoreAccessLink;
  final String premiumTitle;
  final String premiumPaywallSubtitle;
  final String premiumLaunchOfferTitle;
  final String premiumLaunchOfferDescription;
  final String premiumYearlyPlan;
  final String premiumYearlyPrice;
  final String premiumYearlyRegularPrice;
  final String premiumBestValue;
  final String premiumMonthlyPlan;
  final String premiumMonthlyPrice;
  final String premiumMonthlyRegularPrice;
  final String premiumRemoveAds;
  final String premiumUnlockPlayIdeas;
  final String premiumUnlockSounds;
  final String premiumFuturePremiumContent;
  final String premiumRestoreUnavailableTitle;
  final String premiumRestoreUnavailableBody;
  final String premiumRestoreNoPurchaseTitle;
  final String premiumRestoreNoPurchaseBody;
  final String premiumPurchasePending;
  final String premiumPurchaseUnavailable;
  final String adPlaceholderTitle;
  final String adPlaceholderSubtitle;

  static const english = AppStrings._(
    language: AppLanguage.english,
    settings: 'Settings',
    general: 'General',
    languageLabel: 'Language',
    privacy: 'Privacy',
    privacyData: 'Privacy & Data',
    about: 'About',
    reviewerAccess: 'Reviewer access',
    reviewerAccessTitle: 'Reviewer access',
    reviewerAccessSubtitle: 'Local only',
    reviewerAccessDialogTitle: 'Reviewer access',
    reviewerAccessDialogBody:
        'Enter the Play Console reviewer code to unlock all restricted areas on this installation.',
    reviewerAccessCodeLabel: 'Reviewer code',
    reviewerAccessActivate: 'Activate reviewer access',
    reviewerAccessReset: 'Reset reviewer access',
    reviewerAccessEnabledStatus: 'On',
    reviewerAccessEnabledMessage:
        'Reviewer access is active on this installation.',
    reviewerAccessInvalidCode: 'That reviewer code is not valid.',
    reviewerAccessActionFailed:
        'Reviewer access could not be updated. Please try again.',
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
    journalTitle: 'Journal',
    journalSubtitle: 'A calm log for today’s care moments.',
    journalLocalOnlyHint: 'Saved on this device only.',
    journalTodayLabel: 'Today',
    journalYesterdayLabel: 'Yesterday',
    journalTomorrowLabel: 'Tomorrow',
    journalPreviousDay: 'Previous day',
    journalNextDay: 'Next day',
    journalGoToToday: 'Go to today',
    journalChangeDay: 'Change day',
    journalChooseTimeTitle: 'Choose time',
    journalSavePicker: 'Save',
    journalPickerNow: 'Now',
    journalPickerMinus15: '-15 min',
    journalPickerPlus15: '+15 min',
    journalPickerPreviousDay: 'Previous day',
    journalPickerNextDay: 'Next day',
    journalPickerHourLabel: 'Hour',
    journalPickerMinuteLabel: 'Minutes',
    journalQuickActionsTitle: 'Quick actions',
    journalEmptyStateTitle: 'No care moments logged for this day yet.',
    journalEmptyStateMessage: 'Add the first entry when you are ready.',
    journalNoEntryShort: 'No entry',
    journalAddSleep: 'Add sleep',
    journalAddFeeding: 'Add feeding',
    journalAddDiaper: 'Add diaper',
    journalAddNote: 'Add note',
    journalQuickActionSleep: 'Sleep',
    journalQuickActionFeeding: 'Feeding',
    journalQuickActionDiaper: 'Diaper',
    journalQuickActionNote: 'Note',
    journalStartSleep: 'Start sleep',
    journalStopSleep: 'Stop sleep',
    journalActiveSleepTitle: 'Sleep in progress',
    journalActiveSleepStartedLabel: 'Started',
    journalActiveSleepDurationLabel: 'Duration',
    journalDashboardTitle: 'Today',
    journalLastSleep: 'Last sleep',
    journalLastFeeding: 'Last feeding',
    journalLastDiaper: 'Last diaper',
    journalNotesToday: 'Notes today',
    journalTotalSleep: 'Total sleep',
    journalFeedingsCount: 'Feedings',
    journalDiapersCount: 'Diapers',
    journalNotesCount: 'Notes',
    journalLastMomentsTitle: 'Latest entries',
    journalNoSleepToday: 'No sleep logged today.',
    journalNoFeedingToday: 'No feeding logged today.',
    journalNoDiaperToday: 'No diaper logged today.',
    journalNoNotesToday: 'No notes today.',
    journalEditEntry: 'Edit',
    journalDeleteEntry: 'Delete',
    journalDeleteEntryTitle: 'Delete entry?',
    journalDeleteEntryBody: 'This will remove the entry from this day.',
    journalSaveEntry: 'Save entry',
    journalCancelEntry: 'Cancel',
    journalNoteLabel: 'Note',
    journalNoteHint: 'Write a few words...',
    journalEventTimeLabel: 'Time',
    journalSleepStartLabel: 'Start time',
    journalSleepEndLabel: 'End time',
    journalFeedingTypeLabel: 'Feeding type',
    journalAmountLabel: 'Amount / note, optional',
    journalDiaperTypeLabel: 'Diaper type',
    journalNoteRequired: 'Please add a note first.',
    journalSleepInvalidRange: 'End time must be after start time.',
    journalEntryTypeSleep: 'Sleep',
    journalEntryTypeFeeding: 'Feeding',
    journalEntryTypeDiaper: 'Diaper',
    journalEntryTypeNote: 'Note',
    journalFeedingTypeBreast: 'Breast',
    journalFeedingTypeBottle: 'Bottle',
    journalFeedingTypeFood: 'Food',
    journalFeedingTypeOther: 'Other',
    journalDiaperTypePee: 'Pee',
    journalDiaperTypePoop: 'Poop',
    journalDiaperTypeBoth: 'Both',
    journalDiaperTypeDry: 'Dry',
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
    privacyChoices: 'Privacy choices',
    deleteAllLocalData: 'Delete all local data',
    deleteAllLocalDataTitle: 'Delete all local data?',
    deleteAllLocalDataBody:
        'This removes local journal entries and resettable app preferences from this device.',
    deleteAllLocalDataSuccess: 'Local data deleted.',
    deleteAllLocalDataFailed: 'Could not delete local data.',
    currentMvpBehavior: 'Current MVP behavior',
    parentFirstAudience:
        'Nurtly is for parents and caregivers, not for children.',
    childNameNotRequired: 'A child name is not required to use the MVP.',
    birthdateNotRequired:
        'An exact child birthdate is not required in the MVP.',
    noAccount: 'No account is used.',
    noJournalCloudSync: 'Journal notes stay on this device only.',
    noCloudSync: 'No cloud sync is currently enabled.',
    noAnalytics: 'No analytics are currently enabled.',
    analyticsScopeMayInclude:
        'If analytics is added later, it should stay limited to app quality, module usage, retention, ads, and errors.',
    noAds: 'No ads are currently enabled.',
    premiumRemovesAdsInFreePlan: 'Premium removes ads.',
    freePlanMayShowAdsInPassiveSlots:
        'Free plan may show ads in passive list slots.',
    purchasesGoThroughGooglePlay:
        'Purchases on Android go through Google Play.',
    journalContentNotUsedForAds: 'Journal note content is not used for ads.',
    premiumStateMayBeStoredLocally:
        'Premium state may be stored locally to keep access working.',
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
    premiumStatusYearlyActive: 'Yearly Premium active',
    premiumStatusPending: 'Purchase pending',
    premiumStatusPaymentIssue: 'Payment issue',
    premiumUpgrade: 'Upgrade to Premium',
    premiumManage: 'Manage Premium',
    restorePurchases: 'Restore Premium access',
    premiumNotNow: 'Not now',
    premiumRestoreAccessLink: 'Already Premium? Restore access',
    premiumTitle: 'Nurtly Premium',
    premiumPaywallSubtitle:
        'A calmer Nurtly, without ads and with premium play ideas and sounds.',
    premiumLaunchOfferTitle: 'Launch offer -50%',
    premiumLaunchOfferDescription:
        'Premium library is still growing, so Premium starts at a lower price.',
    premiumYearlyPlan: 'Premium Yearly',
    premiumYearlyPrice: '64.99 PLN / year',
    premiumYearlyRegularPrice: 'Launch price, regular price 129.99 PLN / year',
    premiumBestValue: 'Best value',
    premiumRemoveAds: 'Remove ads',
    premiumMonthlyPlan: 'Premium Monthly',
    premiumMonthlyPrice: '7.49 PLN / month',
    premiumMonthlyRegularPrice: 'Launch price, regular price 14.99 PLN / month',
    premiumUnlockPlayIdeas: 'Unlock premium play ideas',
    premiumUnlockSounds: 'Unlock premium sounds',
    premiumFuturePremiumContent: 'New premium content in future updates',
    premiumRestoreUnavailableTitle: 'Purchases are temporarily unavailable',
    premiumRestoreUnavailableBody: 'Please try again later.',
    premiumRestoreNoPurchaseTitle: 'No active Premium purchase was found',
    premiumRestoreNoPurchaseBody:
        'This Google Play account does not currently have Premium access.',
    premiumPurchasePending: 'Your purchase is pending.',
    premiumPurchaseUnavailable:
        'Purchases are temporarily unavailable. Please try again later.',
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
    about: 'Informacje',
    reviewerAccess: 'Dostęp recenzencki',
    reviewerAccessTitle: 'Dostęp recenzencki',
    reviewerAccessSubtitle: 'Lokalny',
    reviewerAccessDialogTitle: 'Dostęp recenzencki',
    reviewerAccessDialogBody:
        'Wpisz kod recenzencki z Play Console, aby odblokować wszystkie ograniczone obszary na tej instalacji.',
    reviewerAccessCodeLabel: 'Kod recenzencki',
    reviewerAccessActivate: 'Aktywuj dostęp recenzencki',
    reviewerAccessReset: 'Wyłącz dostęp recenzencki',
    reviewerAccessEnabledStatus: 'Tak',
    reviewerAccessEnabledMessage:
        'Dostęp recenzencki jest aktywny na tej instalacji.',
    reviewerAccessInvalidCode: 'Kod recenzencki jest nieprawidłowy.',
    reviewerAccessActionFailed:
        'Nie udało się zaktualizować dostępu recenzenckiego. Spróbuj ponownie.',
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
    journalTitle: 'Dziennik',
    journalSubtitle: 'Spokojny zapis dzisiejszych momentów opieki.',
    journalLocalOnlyHint: 'Zapisywane tylko na tym urządzeniu.',
    journalTodayLabel: 'Dzisiaj',
    journalYesterdayLabel: 'Wczoraj',
    journalTomorrowLabel: 'Jutro',
    journalPreviousDay: 'Poprzedni dzień',
    journalNextDay: 'Następny dzień',
    journalGoToToday: 'Przejdź do dziś',
    journalChangeDay: 'Zmień dzień',
    journalChooseTimeTitle: 'Wybierz godzinę',
    journalSavePicker: 'Zapisz',
    journalPickerNow: 'Teraz',
    journalPickerMinus15: '-15 min',
    journalPickerPlus15: '+15 min',
    journalPickerPreviousDay: 'Poprzedni dzień',
    journalPickerNextDay: 'Następny dzień',
    journalPickerHourLabel: 'Godzina',
    journalPickerMinuteLabel: 'Minuty',
    journalQuickActionsTitle: 'Szybkie akcje',
    journalEmptyStateTitle:
        'Nie zapisano jeszcze momentów opieki dla tego dnia.',
    journalEmptyStateMessage: 'Dodaj pierwszy wpis, gdy będziesz mieć chwilę.',
    journalNoEntryShort: 'Brak wpisu',
    journalAddSleep: 'Dodaj sen',
    journalAddFeeding: 'Dodaj karmienie',
    journalAddDiaper: 'Dodaj pieluchę',
    journalAddNote: 'Dodaj notatkę',
    journalQuickActionSleep: 'Sen',
    journalQuickActionFeeding: 'Karmienie',
    journalQuickActionDiaper: 'Pielucha',
    journalQuickActionNote: 'Notatka',
    journalStartSleep: 'Rozpocznij sen',
    journalStopSleep: 'Zakończ sen',
    journalActiveSleepTitle: 'Sen trwa',
    journalActiveSleepStartedLabel: 'Rozpoczęto',
    journalActiveSleepDurationLabel: 'Czas trwania',
    journalDashboardTitle: 'Dzisiaj',
    journalLastSleep: 'Ostatni sen',
    journalLastFeeding: 'Ostatnie karmienie',
    journalLastDiaper: 'Ostatnia pielucha',
    journalNotesToday: 'Notatki dzisiaj',
    journalTotalSleep: 'Suma snu',
    journalFeedingsCount: 'Karmienia',
    journalDiapersCount: 'Pieluchy',
    journalNotesCount: 'Notatki',
    journalLastMomentsTitle: 'Ostatnie wpisy',
    journalNoSleepToday: 'Brak snu dzisiaj.',
    journalNoFeedingToday: 'Brak karmienia dzisiaj.',
    journalNoDiaperToday: 'Brak pieluchy dzisiaj.',
    journalNoNotesToday: 'Brak notatek dzisiaj.',
    journalEditEntry: 'Edytuj',
    journalDeleteEntry: 'Usuń',
    journalDeleteEntryTitle: 'Usunąć wpis?',
    journalDeleteEntryBody: 'Ten wpis zniknie z wybranego dnia.',
    journalSaveEntry: 'Zapisz wpis',
    journalCancelEntry: 'Anuluj',
    journalNoteLabel: 'Notatka',
    journalNoteHint: 'Napisz kilka słów...',
    journalEventTimeLabel: 'Godzina',
    journalSleepStartLabel: 'Godzina rozpoczęcia',
    journalSleepEndLabel: 'Godzina zakończenia',
    journalFeedingTypeLabel: 'Rodzaj karmienia',
    journalAmountLabel: 'Ilość / opis, opcjonalnie',
    journalDiaperTypeLabel: 'Rodzaj pieluchy',
    journalNoteRequired: 'Dodaj najpierw notatkę.',
    journalSleepInvalidRange:
        'Godzina zakończenia musi być po godzinie rozpoczęcia.',
    journalEntryTypeSleep: 'Sen',
    journalEntryTypeFeeding: 'Karmienie',
    journalEntryTypeDiaper: 'Pielucha',
    journalEntryTypeNote: 'Notatka',
    journalFeedingTypeBreast: 'Pierś',
    journalFeedingTypeBottle: 'Butelka',
    journalFeedingTypeFood: 'Jedzenie',
    journalFeedingTypeOther: 'Inne',
    journalDiaperTypePee: 'Siusiu',
    journalDiaperTypePoop: 'Kupka',
    journalDiaperTypeBoth: 'Oba',
    journalDiaperTypeDry: 'Sucha',
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
    privacyChoices: 'Ustawienia prywatności reklam',
    deleteAllLocalData: 'Usuń wszystkie dane lokalne',
    deleteAllLocalDataTitle: 'Usunąć wszystkie dane lokalne?',
    deleteAllLocalDataBody:
        'To usunie lokalne wpisy dziennika i możliwe do resetu preferencje aplikacji z tego urządzenia.',
    deleteAllLocalDataSuccess: 'Dane lokalne usunięte.',
    deleteAllLocalDataFailed: 'Nie udało się usunąć danych lokalnych.',
    currentMvpBehavior: 'Obecne działanie MVP',
    parentFirstAudience:
        'Nurtly jest dla rodziców i opiekunów, nie dla dzieci.',
    childNameNotRequired:
        'Imię dziecka nie jest wymagane do korzystania z MVP.',
    birthdateNotRequired:
        'Dokładna data urodzenia dziecka nie jest wymagana w MVP.',
    noAccount: 'Nie używamy konta.',
    noJournalCloudSync:
        'Notatki z dziennika pozostają tylko na tym urządzeniu.',
    noCloudSync: 'Obecnie nie ma synchronizacji z chmurą.',
    noAnalytics: 'Obecnie nie ma analityki.',
    analyticsScopeMayInclude:
        'Jeśli analityka zostanie dodana później, powinna ograniczać się do jakości aplikacji, użycia modułów, retencji, reklam i błędów.',
    noAds: 'Obecnie nie ma reklam.',
    premiumRemovesAdsInFreePlan: 'Premium usuwa reklamy.',
    freePlanMayShowAdsInPassiveSlots:
        'Plan darmowy może wyświetlać reklamy w spokojnych miejscach list.',
    purchasesGoThroughGooglePlay:
        'Zakupy na Androidzie odbywają się przez Google Play.',
    journalContentNotUsedForAds:
        'Treści notatek z dziennika nie są używane do reklam.',
    premiumStateMayBeStoredLocally:
        'Stan Premium może być przechowywany lokalnie, aby dostęp działał.',
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
    premiumStatusYearlyActive: 'Premium roczne aktywne',
    premiumStatusPending: 'Zakup oczekuje na potwierdzenie',
    premiumStatusPaymentIssue: 'Problem z płatnością',
    premiumUpgrade: 'Przejdź na Premium',
    premiumManage: 'Zarządzaj Premium',
    restorePurchases: 'Odzyskaj dostęp Premium',
    premiumNotNow: 'Nie teraz',
    premiumRestoreAccessLink: 'Masz już Premium? Odzyskaj dostęp',
    premiumTitle: 'Nurtly Premium',
    premiumPaywallSubtitle:
        'Spokojniejsze Nurtly bez reklam oraz z dostępem do premium zabaw i dźwięków.',
    premiumLaunchOfferTitle: 'Oferta startowa -50%',
    premiumLaunchOfferDescription:
        'Biblioteka premium będzie się rozwijać, dlatego na start Premium jest dostępne w niższej cenie.',
    premiumYearlyPlan: 'Premium rocznie',
    premiumYearlyPrice: '64,99 PLN / rok',
    premiumYearlyRegularPrice: 'Cena startowa, cena docelowa 129,99 PLN / rok',
    premiumBestValue: 'Najlepsza wartość',
    premiumRemoveAds: 'Usuń reklamy',
    premiumMonthlyPlan: 'Premium miesięcznie',
    premiumMonthlyPrice: '7,49 PLN / miesiąc',
    premiumMonthlyRegularPrice:
        'Cena startowa, cena docelowa 14,99 PLN / miesiąc',
    premiumUnlockPlayIdeas: 'Odblokuj premium zabawy',
    premiumUnlockSounds: 'Odblokuj premium dźwięki',
    premiumFuturePremiumContent:
        'Nowe treści premium w kolejnych aktualizacjach',
    premiumRestoreUnavailableTitle: 'Zakupy nie są jeszcze dostępne',
    premiumRestoreUnavailableBody: 'Spróbuj ponownie później.',
    premiumRestoreNoPurchaseTitle: 'Nie znaleziono aktywnego dostępu Premium',
    premiumRestoreNoPurchaseBody:
        'To konto Google Play nie ma obecnie aktywnego dostępu Premium.',
    premiumPurchasePending: 'Zakup oczekuje na potwierdzenie.',
    premiumPurchaseUnavailable:
        'Zakupy są chwilowo niedostępne. Spróbuj ponownie później.',
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

  String journalDayLabel(DateTime date, DateTime now) {
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    if (day == today) {
      return journalTodayLabel;
    }
    if (day == yesterday) {
      return journalYesterdayLabel;
    }
    if (day == tomorrow) {
      return switch (language) {
        AppLanguage.english => 'Tomorrow',
        AppLanguage.polish => 'Jutro',
      };
    }
    return switch (language) {
      AppLanguage.english =>
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
      AppLanguage.polish =>
        '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year.toString().padLeft(4, '0')}',
    };
  }

  String journalTimeLabel(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String formatJournalDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return switch (language) {
      AppLanguage.english => '$hours h ${minutes.toString().padLeft(2, '0')}m',
      AppLanguage.polish =>
        '$hours godz. ${minutes.toString().padLeft(2, '0')} min',
    };
  }

  String journalEntryTypeLabel(String code) {
    return switch (code) {
      'sleep' => journalEntryTypeSleep,
      'feeding' => journalEntryTypeFeeding,
      'diaper' => journalEntryTypeDiaper,
      'note' => journalEntryTypeNote,
      _ => code,
    };
  }

  String journalFeedingTypeChoiceLabel(String code) {
    return switch (code) {
      'breast' => journalFeedingTypeBreast,
      'bottle' => journalFeedingTypeBottle,
      'food' => journalFeedingTypeFood,
      'other' => journalFeedingTypeOther,
      _ => code,
    };
  }

  String journalDiaperTypeChoiceLabel(String code) {
    return switch (code) {
      'pee' => journalDiaperTypePee,
      'poop' => journalDiaperTypePoop,
      'both' => journalDiaperTypeBoth,
      'dry' => journalDiaperTypeDry,
      _ => code,
    };
  }
}

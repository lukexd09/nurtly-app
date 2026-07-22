import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../ads/consent_flow_controller.dart';
import '../ads/ad_widget_factory.dart';
import '../content/bundled_content_source.dart';
import '../content/content_loader.dart';
import '../localization/app_language.dart';
import '../monetization/ad_policy.dart';
import '../monetization/premium_access_controller.dart';
import '../monetization/premium_entitlement.dart';
import '../monetization/premium_entitlement_provider.dart';
import '../monetization/purchase_result.dart';
import '../monetization/premium_purchase_provider.dart';
import '../monetization/premium_paywall_sheet.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal/journal_controller.dart';
import '../../features/journal/journal_store.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/play/play_screen.dart';
import '../../features/privacy/privacy_data_screen.dart';
import '../../features/sounds/sounds_screen.dart';
import '../content/suggested_sound_resolver.dart';
import '../localization/app_strings.dart';
import '../localization/language_preference_store.dart';
import '../privacy/local_data_deletion.dart';
import '../platform/package_metadata.dart';
import '../platform/external_url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_tab.dart';
import '../monetization/reviewer_access_store.dart';

class AppShell extends StatefulWidget {
  AppShell({
    this.contentLoader,
    LanguagePreferenceStore? languagePreferenceStore,
    PremiumEntitlementProvider? premiumEntitlementProvider,
    PremiumPurchaseProvider? premiumPurchaseProvider,
    ReviewerAccessStore? reviewerAccessStore,
    AdWidgetFactory? adWidgetFactory,
    ConsentFlow? consentFlow,
    JournalController? journalController,
    this.onLanguageChanged,
    this.externalUrlLauncher,
    super.key,
  })  : languagePreferenceStore = languagePreferenceStore ??
            const SharedPreferencesLanguagePreferenceStore(),
        premiumEntitlementProvider =
            premiumEntitlementProvider ?? LocalPremiumEntitlementProvider(),
        premiumPurchaseProvider =
            premiumPurchaseProvider ?? const LocalPremiumPurchaseProvider(),
        reviewerAccessStore =
            reviewerAccessStore ?? const SharedPreferencesReviewerAccessStore(),
        _ownsJournalController = journalController == null,
        consentFlow = consentFlow ?? const NoopConsentFlow(),
        journalController = journalController ??
            JournalController(
              store: const SharedPreferencesJournalStore(),
            ),
        adWidgetFactory = adWidgetFactory ?? const FakeAdWidgetFactory();

  final ContentLoader? contentLoader;
  final LanguagePreferenceStore languagePreferenceStore;
  final PremiumEntitlementProvider premiumEntitlementProvider;
  final PremiumPurchaseProvider premiumPurchaseProvider;
  final ReviewerAccessStore reviewerAccessStore;
  final bool _ownsJournalController;
  final ConsentFlow consentFlow;
  final JournalController journalController;
  final AdWidgetFactory adWidgetFactory;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final ExternalUrlLauncher? externalUrlLauncher;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  var _currentIndex = 0;
  late AppLanguage _selectedLanguage;
  late final PremiumAccessController _premiumController;
  var _isReady = false;
  var _aboutTapCount = 0;
  late final Future<PackageMetadata> _packageMetadataFuture;
  ContentLoader? _localizedContentLoader;
  AppLanguage? _localizedContentLoaderLanguage;
  PackageMetadata? _packageMetadata;
  String? _packageMetadataError;

  AppStrings get _strings => AppStrings.forLanguage(_selectedLanguage);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _premiumController = PremiumAccessController(
      provider: widget.premiumEntitlementProvider,
      purchaseProvider: widget.premiumPurchaseProvider,
      reviewerAccessStore: widget.reviewerAccessStore,
    );
    if (widget.consentFlow is Listenable) {
      (widget.consentFlow as Listenable).addListener(_handleConsentChanged);
    }
    unawaited(
      Future<void>.sync(widget.consentFlow.initialize).catchError((_) {}),
    );
    widget.journalController.addListener(_handleJournalChanged);
    _premiumController.addListener(_handlePremiumChanged);
    _selectedLanguage = const AppLocaleResolver().resolve(
      preference: AppLanguagePreference.system,
      systemLocale: WidgetsBinding.instance.platformDispatcher.locale,
    );
    _packageMetadataFuture = PackageMetadata.fromPlatform();
    unawaited(_loadPackageMetadata());
    unawaited(_bootstrapAppState());
  }

  Future<void> _loadPackageMetadata() async {
    try {
      final metadata = await _packageMetadataFuture;
      if (!mounted) {
        return;
      }
      setState(() {
        _packageMetadata = metadata;
        _packageMetadataError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _packageMetadataError = 'Unavailable';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.consentFlow is Listenable) {
      (widget.consentFlow as Listenable).removeListener(_handleConsentChanged);
    }
    widget.journalController.removeListener(_handleJournalChanged);
    _premiumController.removeListener(_handlePremiumChanged);
    _premiumController.dispose();
    if (widget._ownsJournalController) {
      widget.journalController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_premiumController.refresh());
    }
  }

  void _handlePremiumChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _handleJournalChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _handleConsentChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _showPrivacyChoices() async {
    try {
      await widget.consentFlow.showPrivacyOptions();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.privacyChoicesFailed)),
      );
    }
  }

  Future<LocalDataDeletionResult> _deleteAllLocalData() async {
    final result = await const LocalDataDeletionCoordinator().deleteAll(
      deleteJournal: widget.journalController.deleteAllEntries,
      deleteLanguage: widget.languagePreferenceStore.delete,
      deleteReviewerAccess: _premiumController.disableReviewerAccess,
    );

    if (result.succeeded.contains(LocalDataComponent.language)) {
      final resolvedLanguage = const AppLocaleResolver().resolve(
        preference: AppLanguagePreference.system,
        systemLocale: WidgetsBinding.instance.platformDispatcher.locale,
      );
      if (mounted) {
        setState(() {
          _selectedLanguage = resolvedLanguage;
          _localizedContentLoader = null;
          _localizedContentLoaderLanguage = null;
        });
        widget.onLanguageChanged?.call(resolvedLanguage);
      }
    }

    return result;
  }

  Future<void> _bootstrapAppState() async {
    var language = _selectedLanguage;
    try {
      final savedLanguage = await widget.languagePreferenceStore.load();
      if (savedLanguage != null) {
        language = savedLanguage;
      }
    } catch (_) {
      language = _selectedLanguage;
    }

    if (!mounted) {
      return;
    }

    await _premiumController.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedLanguage = language;
      _localizedContentLoader = null;
      _localizedContentLoaderLanguage = null;
      _isReady = true;
    });
    widget.onLanguageChanged?.call(language);
  }

  ContentLoader _contentLoaderForCurrentLanguage() {
    // Polish copy and app chrome localization are still in progress.
    // Runtime switching is enabled intentionally to support early localization QA.
    final loader = widget.contentLoader;
    if (loader != null) {
      return loader;
    }

    if (_localizedContentLoader == null ||
        _localizedContentLoaderLanguage != _selectedLanguage) {
      _localizedContentLoaderLanguage = _selectedLanguage;
      _localizedContentLoader = ContentLoader(
        source: BundledContentSource(language: _selectedLanguage),
      );
    }

    return _localizedContentLoader!;
  }

  void _selectTab(AppTab tab) {
    setState(() => _currentIndex = AppTab.values.indexOf(tab));
  }

  void selectLanguage(AppLanguage language) {
    setState(() {
      _selectedLanguage = language;
      _localizedContentLoader = null;
    });
    widget.onLanguageChanged?.call(language);
    unawaited(() async {
      try {
        await widget.languagePreferenceStore.save(language);
      } catch (_) {}
    }());
  }

  Future<void> _openTodaysIdea() async {
    try {
      final package = await _contentLoaderForCurrentLanguage().load();
      if (!mounted) {
        return;
      }
      final idea = selectAccessibleDailyPlayIdea(
        package.playIdeas,
        DateTime.now(),
        canAccessPremiumContent: _premiumController.canAccessPremiumContent,
      );
      if (idea == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_strings.todaysIdeaUnavailable)),
        );
        return;
      }
      final suggestedSound = resolveSuggestedSound(idea, package.sounds);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PlayActivityDetailScreen(
            idea: idea,
            taxonomy: package.taxonomy,
            suggestedSound: suggestedSound,
            strings: _strings,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.todaysIdeaUnavailable)),
      );
    }
  }

  Future<void> _openPremiumPaywall() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return PremiumPaywallScreen(
            strings: _strings,
            controller: _premiumController,
            onRestoreAccess: _restorePremiumAccess,
          );
        },
      ),
    );
  }

  Future<void> _manageSubscription() async {
    var opened = false;
    try {
      opened = await (widget.externalUrlLauncher ?? launchExternalUrl)(
        _premiumController.entitlement.subscriptionManagementUri,
      );
    } catch (_) {}
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_strings.premiumManageSubscriptionFailed)),
    );
  }

  Future<void> _restorePremiumAccess() async {
    final result = await _premiumController.restorePurchases();
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      constraints: const BoxConstraints(maxHeight: 280),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Builder(
            builder: (messageContext) {
              final title = _restoreMessageTitle(_strings, result);
              final body = _restoreMessageBody(_strings, result);
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      body,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(messageContext).pop(),
                        child: Text(_strings.back),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openReviewerAccessDialog() async {
    final codeController = TextEditingController();
    var statusMessage = '';
    var isProcessing = false;
    await showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return PopScope(
              canPop: !isProcessing,
              child: Builder(
                builder: (context) {
                  final strings = _strings;
                  final isEnabled = _premiumController.reviewerAccessEnabled;
                  Future<void> submitCode() async {
                    final messenger = ScaffoldMessenger.of(context);
                    final dialogNavigator = Navigator.of(dialogContext);
                    final code = codeController.text;
                    setDialogState(() {
                      isProcessing = true;
                      statusMessage = '';
                    });
                    try {
                      await _premiumController.enableReviewerAccess(code);
                    } catch (_) {
                      if (!context.mounted || !dialogContext.mounted) {
                        return;
                      }
                      setDialogState(() {
                        isProcessing = false;
                        statusMessage = strings.reviewerAccessActionFailed;
                      });
                      return;
                    }
                    if (!context.mounted || !dialogContext.mounted) {
                      return;
                    }
                    if (_premiumController.reviewerAccessEnabled) {
                      dialogNavigator.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(strings.reviewerAccessEnabledMessage),
                        ),
                      );
                      return;
                    }
                    setDialogState(() {
                      isProcessing = false;
                      statusMessage = strings.reviewerAccessInvalidCode;
                    });
                  }

                  Future<void> resetAccess() async {
                    final messenger = ScaffoldMessenger.of(context);
                    final dialogNavigator = Navigator.of(dialogContext);
                    setDialogState(() {
                      isProcessing = true;
                      statusMessage = '';
                    });
                    try {
                      await _premiumController.disableReviewerAccess();
                    } catch (_) {
                      if (!context.mounted || !dialogContext.mounted) {
                        return;
                      }
                      setDialogState(() {
                        isProcessing = false;
                        statusMessage = strings.reviewerAccessActionFailed;
                      });
                      return;
                    }
                    if (!context.mounted || !dialogContext.mounted) {
                      return;
                    }
                    dialogNavigator.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text(strings.reviewerAccessReset)),
                    );
                  }

                  return AlertDialog(
                    title: Text(strings.reviewerAccessDialogTitle),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(strings.reviewerAccessDialogBody),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          key: const ValueKey('reviewer-access-code-field'),
                          controller: codeController,
                          enabled: !isEnabled && !isProcessing,
                          decoration: InputDecoration(
                            labelText: strings.reviewerAccessCodeLabel,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (!isEnabled && !isProcessing) {
                              unawaited(submitCode());
                            }
                          },
                        ),
                        if (statusMessage.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            statusMessage,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        key: const ValueKey('reviewer-access-back'),
                        onPressed: isProcessing
                            ? null
                            : () => Navigator.of(dialogContext).pop(),
                        child: Text(strings.back),
                      ),
                      TextButton(
                        key: const ValueKey('reviewer-access-reset'),
                        onPressed:
                            isProcessing || !isEnabled ? null : resetAccess,
                        child: Text(strings.reviewerAccessReset),
                      ),
                      FilledButton(
                        key: const ValueKey('reviewer-access-activate'),
                        onPressed:
                            isProcessing || isEnabled ? null : submitCode,
                        child: Text(strings.reviewerAccessActivate),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String _restoreMessageTitle(
    AppStrings strings,
    PurchaseActionResult result,
  ) {
    return switch (result.status) {
      PurchaseActionStatus.success => strings.premiumStatusActive,
      PurchaseActionStatus.noPurchaseFound =>
        strings.premiumRestoreNoPurchaseTitle,
      PurchaseActionStatus.unavailable ||
      PurchaseActionStatus.error ||
      PurchaseActionStatus.canceled ||
      PurchaseActionStatus.pending =>
        strings.premiumRestoreUnavailableTitle,
    };
  }

  String _restoreMessageBody(
    AppStrings strings,
    PurchaseActionResult result,
  ) {
    return switch (result.status) {
      PurchaseActionStatus.success => strings.premiumStatusActive,
      PurchaseActionStatus.noPurchaseFound =>
        strings.premiumRestoreNoPurchaseBody,
      PurchaseActionStatus.unavailable ||
      PurchaseActionStatus.error ||
      PurchaseActionStatus.canceled ||
      PurchaseActionStatus.pending =>
        strings.premiumRestoreUnavailableBody,
    };
  }

  void _openSettings() {
    final navigator = Navigator.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      constraints: const BoxConstraints(maxHeight: 420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final strings = AppStrings.forLanguage(_selectedLanguage);
            final entitlement = _premiumController.entitlement;
            return SafeArea(
              child: ListView(
                key: const ValueKey('settings-sheet-scroll'),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                children: [
                  Text(
                    strings.settings,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    strings.premiumSectionTitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _SettingsRow(
                    key: const ValueKey('settings-premium-status'),
                    title: strings.premiumStatusLabel,
                    value: _premiumStatusText(strings, entitlement),
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _SettingsRow(
                    key: const ValueKey('settings-premium-upgrade'),
                    title: _premiumActionLabel(strings, entitlement),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      unawaited(_openPremiumPaywall());
                    },
                  ),
                  if (entitlement.isPaidSubscription) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _SettingsRow(
                      key: const ValueKey('settings-premium-manage-subscription'),
                      title: strings.premiumManageSubscription,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        unawaited(_manageSubscription());
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      strings.premiumManageSubscriptionInfo,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  _SettingsRow(
                    key: const ValueKey('settings-premium-restore'),
                    title: strings.restorePurchases,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      unawaited(_restorePremiumAccess());
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    strings.general,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _SettingsRow(
                    key: const ValueKey('settings-language-row'),
                    title: strings.languageLabel,
                    value: _selectedLanguage.displayName,
                    onTap: () async {
                      final selected = await _openLanguageSheet(
                        sheetContext,
                      );
                      if (selected == null) {
                        return;
                      }
                      selectLanguage(selected);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    strings.privacy,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _SettingsRow(
                    key: const ValueKey('settings-privacy-data'),
                    title: strings.privacyData,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      navigator.push(
                        MaterialPageRoute<void>(
                          builder: (_) => PrivacyDataScreen(
                            strings: AppStrings.forLanguage(_selectedLanguage),
                            refreshListenable: widget.consentFlow is Listenable
                                ? widget.consentFlow as Listenable
                                : null,
                            consentFlow: widget.consentFlow,
                            onOpenPrivacyChoices:
                                widget.consentFlow.privacyOptionsRequired
                                    ? () => unawaited(_showPrivacyChoices())
                                    : null,
                            onDeleteAllLocalData: _deleteAllLocalData,
                            externalUrlLauncher:
                                widget.externalUrlLauncher ?? launchExternalUrl,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    key: const ValueKey('settings-about-title'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _handleAboutTap,
                    child: Text(
                      strings.about,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _SettingsRow(
                    key: const ValueKey('settings-app-version'),
                    title: strings.appVersionLabel,
                    value: _packageMetadataLabel(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleAboutTap() {
    _aboutTapCount += 1;
    if (_aboutTapCount < 5) {
      return;
    }
    _aboutTapCount = 0;
    unawaited(_openReviewerAccessDialog());
  }

  Future<AppLanguage?> _openLanguageSheet(
    BuildContext settingsSheetContext,
  ) {
    final strings = _strings;
    return showModalBottomSheet<AppLanguage>(
      context: settingsSheetContext,
      backgroundColor: AppColors.surface,
      constraints: const BoxConstraints(maxHeight: 360),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (languageSheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            key: const ValueKey('language-sheet-scroll'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.languageLabel,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _LanguageChoiceRow(
                    key: const ValueKey('language-choice-polish'),
                    title: 'Polski',
                    selected: _selectedLanguage == AppLanguage.polish,
                    onTap: () {
                      Navigator.of(languageSheetContext)
                          .pop(AppLanguage.polish);
                    },
                  ),
                  _LanguageChoiceRow(
                    key: const ValueKey('language-choice-english'),
                    title: 'English',
                    selected: _selectedLanguage == AppLanguage.english,
                    onTap: () {
                      Navigator.of(languageSheetContext)
                          .pop(AppLanguage.english);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final adPolicy = AdPolicy(_premiumController.entitlement);
    final screens = [
      HomeScreen(
        strings: _strings,
        onSelectTab: _selectTab,
        onOpenTodaysIdea: _openTodaysIdea,
        showAdPlaceholder: adPolicy.allows(AdPlacement.homePassiveSlot),
        adWidgetFactory: widget.adWidgetFactory,
      ),
      PlayScreen(
        strings: _strings,
        contentLoader: _contentLoaderForCurrentLanguage(),
        premiumEntitlement: _premiumController.entitlement,
        onOpenPremiumPaywall: _openPremiumPaywall,
        showAdPlaceholder: adPolicy.allows(AdPlacement.playListPassiveSlot),
        adWidgetFactory: widget.adWidgetFactory,
      ),
      JournalScreen(
        strings: _strings,
        controller: widget.journalController,
      ),
      SoundsScreen(
        strings: _strings,
        contentLoader: _contentLoaderForCurrentLanguage(),
        premiumEntitlement: _premiumController.entitlement,
        onOpenPremiumPaywall: _openPremiumPaywall,
        showAdPlaceholder: adPolicy.allows(AdPlacement.soundsListPassiveSlot),
        adWidgetFactory: widget.adWidgetFactory,
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          _ShellTopBar(
            currentTab: AppTab.values[_currentIndex],
            strings: _strings,
            onSettingsTap: _openSettings,
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.caption.copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        destinations: [
          for (final tab in AppTab.values)
            NavigationDestination(
              icon: Icon(tab.icon, color: AppColors.textMuted),
              selectedIcon: Icon(
                tab.selectedIcon,
                color: AppColors.primary,
              ),
              label: _strings.tabLabel(tab),
            ),
        ],
      ),
    );
  }

  String _premiumStatusText(
    AppStrings strings,
    PremiumEntitlement entitlement,
  ) {
    if (entitlement.state == PremiumState.free) {
      return strings.premiumStatusFree;
    }
    if (entitlement.state == PremiumState.pending) {
      return strings.premiumStatusPending;
    }
    if (entitlement.state == PremiumState.accountHold ||
        entitlement.state == PremiumState.expired) {
      return strings.premiumStatusPaymentIssue;
    }
    if (entitlement.state == PremiumState.active &&
        entitlement.source == PremiumSource.yearly) {
      return strings.premiumStatusYearlyActive;
    }
    if (entitlement.state == PremiumState.active &&
        entitlement.source == PremiumSource.monthly &&
        entitlement.expiresAt != null) {
      return strings.premiumStatusActiveUntil(
        _formatPremiumDate(entitlement.expiresAt!),
      );
    }
    return strings.premiumStatusActive;
  }

  String _premiumActionLabel(
    AppStrings strings,
    PremiumEntitlement entitlement,
  ) {
    return entitlement.hasPremiumAccess
        ? strings.premiumManage
        : strings.premiumUpgrade;
  }

  String _formatPremiumDate(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    return '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
  }

  String _packageMetadataLabel() {
    if (_packageMetadataError != null) {
      return _packageMetadataError!;
    }
    final packageMetadata = _packageMetadata;
    if (packageMetadata == null) {
      return 'Loading...';
    }
    final buildNumber = packageMetadata.buildNumber.trim();
    if (buildNumber.isEmpty) {
      return packageMetadata.version;
    }
    return '${packageMetadata.version}+$buildNumber';
  }
}

class _ShellTopBar extends StatelessWidget {
  const _ShellTopBar({
    required this.currentTab,
    required this.strings,
    required this.onSettingsTap,
  });

  final AppTab currentTab;
  final AppStrings strings;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Text(
              appName,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                currentTab == AppTab.home
                    ? strings.homeShellSubtitle
                    : strings.tabLabel(currentTab),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Material(
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.borderSoft),
              ),
              child: IconButton(
                tooltip: strings.settingsTooltip,
                color: AppColors.primary,
                icon: const Icon(Icons.settings_outlined),
                onPressed: onSettingsTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    super.key,
    required this.title,
    this.value,
    this.onTap,
  });

  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        dense: true,
        visualDensity: VisualDensity.compact,
        minVerticalPadding: 0,
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null) ...[
              Text(
                value!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            if (onTap != null) const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _LanguageChoiceRow extends StatelessWidget {
  const _LanguageChoiceRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderSoft),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          dense: true,
          visualDensity: VisualDensity.compact,
          minVerticalPadding: 0,
          title: Text(title),
          trailing: selected
              ? const Icon(Icons.check_rounded, color: AppColors.primary)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}

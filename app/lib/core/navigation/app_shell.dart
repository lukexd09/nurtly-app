import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../content/bundled_content_source.dart';
import '../content/content_loader.dart';
import '../localization/app_language.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/play/play_screen.dart';
import '../../features/privacy/privacy_data_screen.dart';
import '../../features/sounds/sounds_screen.dart';
import '../content/suggested_sound_resolver.dart';
import '../localization/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    this.contentLoader,
    super.key,
  });

  final ContentLoader? contentLoader;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _currentIndex = 0;
  late AppLanguage _selectedLanguage;
  ContentLoader? _localizedContentLoader;
  AppLanguage? _localizedContentLoaderLanguage;

  AppStrings get _strings => AppStrings.forLanguage(_selectedLanguage);

  @override
  void initState() {
    super.initState();
    _selectedLanguage = const AppLocaleResolver().resolve(
      preference: AppLanguagePreference.system,
      systemLocale: WidgetsBinding.instance.platformDispatcher.locale,
    );
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
  }

  Future<void> _openTodaysIdea() async {
    try {
      final package = await _contentLoaderForCurrentLanguage().load();
      if (!mounted || package.playIdeas.isEmpty) {
        return;
      }
      final idea = selectDailyPlayIdea(package.playIdeas, DateTime.now());
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

  void _openSettings() {
    final navigator = Navigator.of(context);
    final strings = _strings;
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
                          builder: (_) => PrivacyDataScreen(strings: strings),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    final screens = [
      HomeScreen(
        strings: _strings,
        onSelectTab: _selectTab,
        onOpenTodaysIdea: _openTodaysIdea,
      ),
      PlayScreen(
        strings: _strings,
        contentLoader: _contentLoaderForCurrentLanguage(),
      ),
      const JournalScreen(),
      SoundsScreen(
        strings: _strings,
        contentLoader: _contentLoaderForCurrentLanguage(),
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
    required this.onTap,
  });

  final String title;
  final String? value;
  final VoidCallback onTap;

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
            const Icon(Icons.chevron_right),
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

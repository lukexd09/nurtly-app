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
  var _languagePreference = AppLanguagePreference.system;
  AppLanguage? _localizedContentLoaderLanguage;
  ContentLoader? _localizedContentLoader;

  AppLanguage get _effectiveLanguage {
    return const AppLocaleResolver().resolve(
      preference: _languagePreference,
      systemLocale: WidgetsBinding.instance.platformDispatcher.locale,
    );
  }

  ContentLoader _contentLoaderForCurrentLanguage() {
    final loader = widget.contentLoader;
    if (loader != null) {
      return loader;
    }

    final language = _effectiveLanguage;
    if (_localizedContentLoaderLanguage != language ||
        _localizedContentLoader == null) {
      _localizedContentLoaderLanguage = language;
      _localizedContentLoader = ContentLoader(
        source: BundledContentSource(language: language),
      );
    }

    return _localizedContentLoader!;
  }

  void _selectTab(AppTab tab) {
    setState(() => _currentIndex = AppTab.values.indexOf(tab));
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
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Today\'s idea is not available yet.')),
      );
    }
  }

  void _openSettings() {
    final navigator = Navigator.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> selectLanguage(
                AppLanguagePreference preference) async {
              setState(() => _languagePreference = preference);
              setSheetState(() {});
            }

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.borderSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Settings',
                        style: AppTextStyles.cardTitle.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Privacy',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Material(
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: AppColors.borderSoft),
                        ),
                        child: ListTile(
                          key: const ValueKey('settings-privacy-data'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          title: const Text('Privacy & Data'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            navigator.push(
                              MaterialPageRoute<void>(
                                builder: (_) => const PrivacyDataScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Language',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _LanguageChoiceTile(
                        title: 'Use phone language',
                        value: AppLanguagePreference.system,
                        selected:
                            _languagePreference == AppLanguagePreference.system,
                        onChanged: selectLanguage,
                      ),
                      _LanguageChoiceTile(
                        title: 'Polski',
                        value: AppLanguagePreference.polish,
                        selected:
                            _languagePreference == AppLanguagePreference.polish,
                        onChanged: selectLanguage,
                      ),
                      _LanguageChoiceTile(
                        title: 'English',
                        value: AppLanguagePreference.english,
                        selected: _languagePreference ==
                            AppLanguagePreference.english,
                        onChanged: selectLanguage,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onSelectTab: _selectTab,
        onOpenTodaysIdea: _openTodaysIdea,
      ),
      PlayScreen(contentLoader: _contentLoaderForCurrentLanguage()),
      const JournalScreen(),
      SoundsScreen(contentLoader: _contentLoaderForCurrentLanguage()),
    ];

    return Scaffold(
      body: Column(
        children: [
          _ShellTopBar(
            currentTab: AppTab.values[_currentIndex],
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
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _ShellTopBar extends StatelessWidget {
  const _ShellTopBar({
    required this.currentTab,
    required this.onSettingsTap,
  });

  final AppTab currentTab;
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
                    ? 'A quieter start'
                    : currentTab.label,
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
                tooltip: 'Settings',
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

class _LanguageChoiceTile extends StatelessWidget {
  const _LanguageChoiceTile({
    required this.title,
    required this.value,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final AppLanguagePreference value;
  final bool selected;
  final ValueChanged<AppLanguagePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
      child: InkWell(
        key: ValueKey('language-choice-${value.name}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () => onChanged(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title)),
            ],
          ),
        ),
      ),
    );
  }
}

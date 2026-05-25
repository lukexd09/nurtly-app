import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../content/content_loader.dart';
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
    this.contentLoader = const ContentLoader(),
    super.key,
  });

  final ContentLoader contentLoader;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _currentIndex = 0;

  void _selectTab(AppTab tab) {
    setState(() => _currentIndex = AppTab.values.indexOf(tab));
  }

  Future<void> _openTodaysIdea() async {
    try {
      final package = await widget.contentLoader.load();
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

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onSelectTab: _selectTab,
        onOpenTodaysIdea: _openTodaysIdea,
      ),
      PlayScreen(contentLoader: widget.contentLoader),
      const JournalScreen(),
      const SoundsScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          _ShellTopBar(currentTab: AppTab.values[_currentIndex]),
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
  const _ShellTopBar({required this.currentTab});

  final AppTab currentTab;

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
                tooltip: 'Privacy & Data',
                color: AppColors.primary,
                icon: const Icon(Icons.shield_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyDataScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

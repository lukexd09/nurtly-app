import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal/journal_screen.dart';
import '../../features/play/play_screen.dart';
import '../../features/privacy/privacy_data_screen.dart';
import '../../features/sounds/sounds_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _currentIndex = 0;

  void _selectTab(AppTab tab) {
    setState(() => _currentIndex = AppTab.values.indexOf(tab));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onSelectTab: _selectTab),
      const PlayScreen(),
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
        destinations: [
          for (final tab in AppTab.values)
            NavigationDestination(
              icon: Icon(tab.icon),
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
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.panelRadius,
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.spa_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(appName, style: AppTextStyles.cardTitle),
                      Text(
                        currentTab == AppTab.home
                            ? 'Calm support for everyday family moments'
                            : currentTab.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Privacy & Data',
                  color: AppColors.primary,
                  icon: const Icon(Icons.privacy_tip_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacyDataScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

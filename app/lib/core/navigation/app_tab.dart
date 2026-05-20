import 'package:flutter/material.dart';

enum AppTab {
  home(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  play(
    label: 'Play',
    icon: Icons.lightbulb_outline,
    selectedIcon: Icons.lightbulb,
  ),
  journal(
    label: 'Journal',
    icon: Icons.event_note_outlined,
    selectedIcon: Icons.event_note,
  ),
  sounds(
    label: 'Sounds',
    icon: Icons.graphic_eq,
    selectedIcon: Icons.volume_up,
  );

  const AppTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

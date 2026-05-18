import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/nurtly_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/section_header.dart';

class SoundsScreen extends StatelessWidget {
  const SoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          SectionHeader(
            title: 'Sounds',
            subtitle: 'Choose a sound for a quiet moment.',
          ),
          SizedBox(height: AppSpacing.lg),
          NurtlyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NurtlyChip(label: 'Placeholder'),
                SizedBox(height: AppSpacing.md),
                EmptyState(
                  title: 'Sounds are not built yet',
                  message: 'The sound library and player will be added '
                      'in separate tasks.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

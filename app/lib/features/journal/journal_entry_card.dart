import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/nurtly_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import 'journal_entry.dart';

class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({required this.entry, super.key});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.note, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              NurtlyChip(label: entry.readableTimestamp),
              if (entry.moodLabel != null) NurtlyChip(label: entry.moodLabel!),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/nurtly_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/localization/app_strings.dart';
import 'journal_entry.dart';
import 'journal_entry_type.dart';

class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    required this.entry,
    required this.strings,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final JournalEntry entry;
  final AppStrings strings;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  strings.journalEntryTypeLabel(entry.type.code),
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              NurtlyChip(label: strings.journalTimeLabel(_displayTime(entry))),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(_detailText(strings, entry), style: AppTextStyles.body),
          if (entry.note != null && entry.note!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              entry.note!.trim(),
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              TextButton(
                onPressed: onEdit,
                child: Text(strings.journalEditEntry),
              ),
              TextButton(
                onPressed: onDelete,
                child: Text(strings.journalDeleteEntry),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DateTime _displayTime(JournalEntry entry) {
    return switch (entry.type) {
      JournalEntryType.sleep => entry.startAt ?? entry.createdAt,
      _ => entry.eventAt ?? entry.createdAt,
    };
  }

  String _detailText(AppStrings strings, JournalEntry entry) {
    return switch (entry.type) {
      JournalEntryType.sleep => _sleepText(strings, entry),
      JournalEntryType.feeding => _feedingText(strings, entry),
      JournalEntryType.diaper => _diaperText(strings, entry),
      JournalEntryType.note => entry.note ?? strings.journalNoteLabel,
    };
  }

  String _sleepText(AppStrings strings, JournalEntry entry) {
    if (entry.isActiveSleep) {
      return strings.journalActiveSleepTitle;
    }
    final start = entry.startAt;
    final end = entry.endAt;
    if (start == null) {
      return strings.journalActiveSleepTitle;
    }
    if (end == null) {
      return '${strings.journalActiveSleepTitle} · ${strings.journalTimeLabel(start)}';
    }
    final duration = entry.duration;
    if (duration == null) {
      return '${strings.journalTimeLabel(start)} - ${strings.journalTimeLabel(end)}';
    }
    return '${strings.journalTimeLabel(start)} - ${strings.journalTimeLabel(end)} · ${strings.formatJournalDuration(duration)}';
  }

  String _feedingText(AppStrings strings, JournalEntry entry) {
    final type = entry.feedingType?.code;
    final typeLabel = type == null
        ? strings.journalEntryTypeFeeding
        : strings.journalFeedingTypeChoiceLabel(type);
    final amount = <String>[
      if (entry.amountText != null && entry.amountText!.trim().isNotEmpty)
        entry.amountText!.trim(),
      if (entry.amountMl != null) '${entry.amountMl} ml',
    ].join(' · ');
    if (amount.isEmpty) {
      return typeLabel;
    }
    return '$typeLabel · $amount';
  }

  String _diaperText(AppStrings strings, JournalEntry entry) {
    final type = entry.diaperType?.code;
    final typeLabel = type == null
        ? strings.journalEntryTypeDiaper
        : strings.journalDiaperTypeChoiceLabel(type);
    if (entry.note == null || entry.note!.trim().isEmpty) {
      return typeLabel;
    }
    return typeLabel;
  }
}

import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/nurtly_card.dart';

Future<DateTime?> showJournalDayPickerSheet({
  required BuildContext context,
  required AppStrings strings,
  required DateTime initialDay,
  required DateTime now,
}) {
  return showModalBottomSheet<DateTime?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _JournalDayPickerSheet(
      strings: strings,
      initialDay: initialDay,
      now: now,
    ),
  );
}

class _JournalDayPickerSheet extends StatefulWidget {
  const _JournalDayPickerSheet({
    required this.strings,
    required this.initialDay,
    required this.now,
  });

  final AppStrings strings;
  final DateTime initialDay;
  final DateTime now;

  @override
  State<_JournalDayPickerSheet> createState() => _JournalDayPickerSheetState();
}

class _JournalDayPickerSheetState extends State<_JournalDayPickerSheet> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      widget.initialDay.year,
      widget.initialDay.month,
      widget.initialDay.day,
    );
  }

  void _setDay(DateTime day) {
    setState(() {
      _selectedDay = DateTime(day.year, day.month, day.day);
    });
  }

  void _goToPreviousDay() {
    _setDay(_selectedDay.subtract(const Duration(days: 1)));
  }

  void _goToNextDay() {
    _setDay(_selectedDay.add(const Duration(days: 1)));
  }

  DateTime _relativeDay(int deltaDays) {
    return DateTime(
      widget.now.year,
      widget.now.month,
      widget.now.day,
    ).add(Duration(days: deltaDays));
  }

  String _formatAbsoluteDay(DateTime day) {
    return switch (widget.strings.language) {
      AppLanguage.english =>
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
      AppLanguage.polish =>
        '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year.toString().padLeft(4, '0')}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final selectedLabel = strings.journalDayLabel(_selectedDay, widget.now);
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  strings.journalChangeDay,
                  key: const ValueKey('journal-day-picker-title'),
                  style: AppTextStyles.sectionTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  selectedLabel,
                  style: AppTextStyles.display.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _formatAbsoluteDay(_selectedDay),
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _QuickChip(
                      label: strings.journalYesterdayLabel,
                      onPressed: () => _setDay(_relativeDay(-1)),
                    ),
                    _QuickChip(
                      label: strings.journalTodayLabel,
                      onPressed: () => _setDay(_relativeDay(0)),
                    ),
                    _QuickChip(
                      label: strings.journalTomorrowLabel,
                      onPressed: () => _setDay(_relativeDay(1)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                NurtlyCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _goToPreviousDay,
                              icon: const Icon(Icons.chevron_left),
                              label: Text(strings.journalPickerPreviousDay),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _goToNextDay,
                              icon: const Icon(Icons.chevron_right),
                              label: Text(strings.journalPickerNextDay),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(strings.journalCancelEntry),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(_selectedDay),
                        child: Text(strings.journalSavePicker),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.surfaceBright,
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.borderSoft),
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }
}

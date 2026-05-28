import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/nurtly_card.dart';

Future<TimeOfDay?> showJournalTimePickerSheet({
  required BuildContext context,
  required AppStrings strings,
  required TimeOfDay initialTime,
  required DateTime Function() now,
}) {
  return showModalBottomSheet<TimeOfDay?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _JournalTimePickerSheet(
      strings: strings,
      initialTime: initialTime,
      now: now,
    ),
  );
}

class _JournalTimePickerSheet extends StatefulWidget {
  const _JournalTimePickerSheet({
    required this.strings,
    required this.initialTime,
    required this.now,
  });

  final AppStrings strings;
  final TimeOfDay initialTime;
  final DateTime Function() now;

  @override
  State<_JournalTimePickerSheet> createState() =>
      _JournalTimePickerSheetState();
}

class _JournalTimePickerSheetState extends State<_JournalTimePickerSheet> {
  late int _minutesOfDay;

  @override
  void initState() {
    super.initState();
    _minutesOfDay = widget.initialTime.hour * 60 + widget.initialTime.minute;
  }

  TimeOfDay get _selectedTimeOfDay =>
      TimeOfDay(hour: _minutesOfDay ~/ 60, minute: _minutesOfDay % 60);

  void _setMinutes(int minutesOfDay) {
    final normalized = minutesOfDay % (24 * 60);
    setState(() {
      _minutesOfDay = normalized < 0 ? normalized + 24 * 60 : normalized;
    });
  }

  void _adjustMinutes(int delta) {
    _setMinutes(_minutesOfDay + delta);
  }

  void _setNow() {
    final current = widget.now();
    _setMinutes(current.hour * 60 + current.minute);
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final selected = _selectedTimeOfDay;
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
                  strings.journalChooseTimeTitle,
                  key: const ValueKey('journal-time-picker-title'),
                  style: AppTextStyles.sectionTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                NurtlyCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.journalTimeLabel(
                          DateTime(
                            2026,
                            1,
                            1,
                            selected.hour,
                            selected.minute,
                          ),
                        ),
                        style: AppTextStyles.display.copyWith(
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeStepper(
                              minusKey: const ValueKey('journal-hour-minus'),
                              plusKey: const ValueKey('journal-hour-plus'),
                              labelKey: const ValueKey('journal-hour-label'),
                              label: strings.journalPickerHourLabel,
                              value: selected.hour.toString().padLeft(2, '0'),
                              onDecrement: () => _adjustMinutes(-60),
                              onIncrement: () => _adjustMinutes(60),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _TimeStepper(
                              minusKey: const ValueKey('journal-minute-minus'),
                              plusKey: const ValueKey('journal-minute-plus'),
                              labelKey: const ValueKey('journal-minute-label'),
                              label: strings.journalPickerMinuteLabel,
                              value: selected.minute.toString().padLeft(2, '0'),
                              onDecrement: () => _adjustMinutes(-5),
                              onIncrement: () => _adjustMinutes(5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _QuickChip(
                            label: strings.journalPickerNow,
                            onPressed: _setNow,
                          ),
                          _QuickChip(
                            label: strings.journalPickerMinus15,
                            onPressed: () => _adjustMinutes(-15),
                          ),
                          _QuickChip(
                            label: strings.journalPickerPlus15,
                            onPressed: () => _adjustMinutes(15),
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
                        onPressed: () => Navigator.of(context).pop(selected),
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

class _TimeStepper extends StatelessWidget {
  const _TimeStepper({
    required this.minusKey,
    required this.plusKey,
    required this.labelKey,
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final Key minusKey;
  final Key plusKey;
  final Key labelKey;
  final String label;
  final String value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.surfaceBright,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, key: labelKey, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.display.copyWith(fontSize: 30),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: minusKey,
                  onPressed: onDecrement,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surfaceBright,
                    side: const BorderSide(color: AppColors.borderSoft),
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('−'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  key: plusKey,
                  onPressed: onIncrement,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surfaceBright,
                    side: const BorderSide(color: AppColors.borderSoft),
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('+'),
                ),
              ),
            ],
          ),
        ],
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

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
}) {
  return showModalBottomSheet<TimeOfDay?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _JournalTimePickerSheet(
      strings: strings,
      initialTime: initialTime,
    ),
  );
}

class _JournalTimePickerSheet extends StatefulWidget {
  const _JournalTimePickerSheet({
    required this.strings,
    required this.initialTime,
  });

  final AppStrings strings;
  final TimeOfDay initialTime;

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
    final now = DateTime.now();
    _setMinutes(now.hour * 60 + now.minute);
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StepButton(
                            label: '-1h',
                            onPressed: () => _adjustMinutes(-60),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _StepButton(
                            label: '+1h',
                            onPressed: () => _adjustMinutes(60),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _StepButton(
                            label: '-5m',
                            onPressed: () => _adjustMinutes(-5),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _StepButton(
                            label: '+5m',
                            onPressed: () => _adjustMinutes(5),
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
                            label: strings.journalPickerMinus5,
                            onPressed: () => _adjustMinutes(-5),
                          ),
                          _QuickChip(
                            label: strings.journalPickerPlus5,
                            onPressed: () => _adjustMinutes(5),
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

class _StepButton extends StatelessWidget {
  const _StepButton({
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
        minimumSize: const Size(64, 44),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
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

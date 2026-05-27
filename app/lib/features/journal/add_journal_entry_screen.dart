// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/localization/app_strings.dart';
import 'journal_entry.dart';
import 'journal_entry_type.dart';

class AddJournalEntryScreen extends StatefulWidget {
  const AddJournalEntryScreen({
    required this.strings,
    required this.entryType,
    this.initialEntry,
    this.initialDay,
    this.now = DateTime.now,
    super.key,
  });

  final AppStrings strings;
  final JournalEntryType entryType;
  final JournalEntry? initialEntry;
  final DateTime? initialDay;
  final DateTime Function() now;

  @override
  State<AddJournalEntryScreen> createState() => _AddJournalEntryScreenState();
}

class _AddJournalEntryScreenState extends State<AddJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteController;
  late final TextEditingController _amountController;
  late DateTime _selectedEventAt;
  late DateTime _selectedStartAt;
  DateTime? _selectedEndAt;
  late JournalFeedingType _feedingType;
  late JournalDiaperType _diaperType;
  String? _errorText;

  JournalEntry? get _initialEntry => widget.initialEntry;

  @override
  void initState() {
    super.initState();
    final now = widget.now();
    final initial = _initialEntry;
    final initialDay = widget.initialDay == null
        ? null
        : DateTime(
            widget.initialDay!.year,
            widget.initialDay!.month,
            widget.initialDay!.day,
          );
    final selectedDay = initialDay ?? DateTime(now.year, now.month, now.day);
    _noteController = TextEditingController(text: initial?.note ?? '');
    _amountController = TextEditingController(text: initial?.amountText ?? '');
    _selectedEventAt = initial?.eventAt ?? _mergeDateAndTime(selectedDay, now);
    _selectedStartAt = initial?.startAt ??
        _mergeDateAndTime(selectedDay, now.subtract(const Duration(hours: 1)));
    _selectedEndAt = initial?.endAt ?? _mergeDateAndTime(selectedDay, now);
    _feedingType = initial?.feedingType ?? JournalFeedingType.breast;
    _diaperType = initial?.diaperType ?? JournalDiaperType.pee;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    setState(() {
      _errorText = null;
    });
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    final now = widget.now();
    final initial = _initialEntry;
    final entry = switch (widget.entryType) {
      JournalEntryType.note => JournalEntry.note(
          id: initial?.id ?? _newId(now),
          eventAt: _selectedEventAt,
          note: _noteController.text.trim(),
          createdAt: initial?.createdAt ?? _selectedEventAt,
          updatedAt: now,
          childId: initial?.childId,
        ),
      JournalEntryType.feeding => JournalEntry.feeding(
          id: initial?.id ?? _newId(now),
          eventAt: _selectedEventAt,
          feedingType: _feedingType,
          amountText: _amountController.text.trim().isEmpty
              ? null
              : _amountController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          createdAt: initial?.createdAt ?? _selectedEventAt,
          updatedAt: now,
          childId: initial?.childId,
        ),
      JournalEntryType.diaper => JournalEntry.diaper(
          id: initial?.id ?? _newId(now),
          eventAt: _selectedEventAt,
          diaperType: _diaperType,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          createdAt: initial?.createdAt ?? _selectedEventAt,
          updatedAt: now,
          childId: initial?.childId,
        ),
      JournalEntryType.sleep => JournalEntry.sleep(
          id: initial?.id ?? _newId(now),
          startAt: _selectedStartAt,
          endAt: _selectedEndAt,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          createdAt: initial?.createdAt ?? _selectedStartAt,
          updatedAt: now,
          childId: initial?.childId,
        ),
    };

    if (widget.entryType == JournalEntryType.sleep &&
        _selectedEndAt != null &&
        !_selectedEndAt!.isAfter(_selectedStartAt)) {
      setState(() {
        _errorText = widget.strings.journalSleepInvalidRange;
      });
      return;
    }

    if (!mounted) {
      return;
    }
    navigator.pop(entry);
  }

  Future<void> _pickEventTime() async {
    final picked = await _pickTimeOnly(_selectedEventAt);
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedEventAt = picked;
    });
  }

  Future<void> _pickEventDay() async {
    final picked = await _pickDateOnly(_selectedEventAt);
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedEventAt = _mergeDateAndTime(picked, _selectedEventAt);
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await _pickTimeOnly(_selectedStartAt);
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedStartAt = picked;
      if (_selectedEndAt != null &&
          !_selectedEndAt!.isAfter(_selectedStartAt)) {
        _selectedEndAt = _selectedStartAt.add(const Duration(minutes: 1));
      }
    });
  }

  Future<void> _pickStartDay() async {
    final picked = await _pickDateOnly(_selectedStartAt);
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedStartAt = _mergeDateAndTime(picked, _selectedStartAt);
      if (_selectedEndAt != null &&
          !_selectedEndAt!.isAfter(_selectedStartAt)) {
        _selectedEndAt = _selectedStartAt.add(const Duration(minutes: 1));
      }
    });
  }

  Future<void> _pickEndTime() async {
    final base =
        _selectedEndAt ?? _selectedStartAt.add(const Duration(hours: 1));
    final picked = await _pickTimeOnly(base);
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedEndAt = picked;
    });
  }

  Future<void> _pickEndDay() async {
    final base =
        _selectedEndAt ?? _selectedStartAt.add(const Duration(hours: 1));
    final picked = await _pickDateOnly(base);
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedEndAt = _mergeDateAndTime(picked, base);
    });
  }

  Future<DateTime?> _pickTimeOnly(DateTime initial) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (time == null) {
      return null;
    }
    return DateTime(
      initial.year,
      initial.month,
      initial.day,
      time.hour,
      time.minute,
    );
  }

  Future<DateTime?> _pickDateOnly(DateTime initial) async {
    // The picker dialogs intentionally use the current build context.
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 2),
      lastDate: DateTime(initial.year + 2),
    );
    if (date == null) {
      return null;
    }
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  DateTime _mergeDateAndTime(DateTime date, DateTime timeSource) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      timeSource.hour,
      timeSource.minute,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final time = widget.strings.journalTimeLabel(local);
    final now = widget.now();
    return '${widget.strings.journalDayLabel(local, now)}, $time';
  }

  String _newId(DateTime now) {
    return 'journal_${now.microsecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForType(strings, widget.entryType)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SectionHeader(
                title: _titleForType(strings, widget.entryType),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                strings.journalLocalOnlyHint,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (widget.entryType == JournalEntryType.sleep) ...[
                _TimePickerRow(
                  label: strings.journalSleepStartLabel,
                  value: _formatDateTime(_selectedStartAt),
                  onTap: _pickStartTime,
                  onChangeDay: _pickStartDay,
                  changeDayLabel: strings.journalChangeDay,
                  changeDayKey: const ValueKey('journal-change-start-day'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _TimePickerRow(
                  label: strings.journalSleepEndLabel,
                  value: _formatDateTime(_selectedEndAt ?? _selectedStartAt),
                  onTap: _pickEndTime,
                  onChangeDay: _pickEndDay,
                  changeDayLabel: strings.journalChangeDay,
                  changeDayKey: const ValueKey('journal-change-end-day'),
                ),
              ] else ...[
                _TimePickerRow(
                  label: strings.journalEventTimeLabel,
                  value: _formatDateTime(_selectedEventAt),
                  onTap: _pickEventTime,
                  onChangeDay: _pickEventDay,
                  changeDayLabel: strings.journalChangeDay,
                  changeDayKey: const ValueKey('journal-change-event-day'),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (widget.entryType == JournalEntryType.feeding) ...[
                Text(
                  strings.journalFeedingTypeLabel,
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final option in JournalFeedingType.values)
                      _EntryChoiceChip(
                        label:
                            strings.journalFeedingTypeChoiceLabel(option.code),
                        selected: _feedingType == option,
                        onPressed: () => setState(() => _feedingType = option),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: strings.journalAmountLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (widget.entryType == JournalEntryType.diaper) ...[
                Text(
                  strings.journalDiaperTypeLabel,
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final option in JournalDiaperType.values)
                      _EntryChoiceChip(
                        label:
                            strings.journalDiaperTypeChoiceLabel(option.code),
                        selected: _diaperType == option,
                        onPressed: () => setState(() => _diaperType = option),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              TextFormField(
                controller: _noteController,
                minLines: 4,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  if (widget.entryType == JournalEntryType.note &&
                      (value == null || value.trim().isEmpty)) {
                    return strings.journalNoteRequired;
                  }
                  if (widget.entryType == JournalEntryType.sleep &&
                      _selectedEndAt != null &&
                      !_selectedEndAt!.isAfter(_selectedStartAt)) {
                    return strings.journalSleepInvalidRange;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: strings.journalNoteLabel,
                  hintText: strings.journalNoteHint,
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorText!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
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
                    child: PrimaryButton(
                      label: strings.journalSaveEntry,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleForType(AppStrings strings, JournalEntryType type) {
    return switch (type) {
      JournalEntryType.sleep => strings.journalAddSleep,
      JournalEntryType.feeding => strings.journalAddFeeding,
      JournalEntryType.diaper => strings.journalAddDiaper,
      JournalEntryType.note => strings.journalAddNote,
    };
  }
}

class _TimePickerRow extends StatelessWidget {
  const _TimePickerRow({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onChangeDay,
    required this.changeDayLabel,
    required this.changeDayKey,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onChangeDay;
  final String changeDayLabel;
  final Key changeDayKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Text(label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value),
            if (onChangeDay != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              OutlinedButton(
                key: changeDayKey,
                onPressed: onChangeDay,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 0,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  changeDayLabel,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.schedule_outlined),
        onTap: onTap,
      ),
    );
  }
}

class _EntryChoiceChip extends StatelessWidget {
  const _EntryChoiceChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: colors.surface,
        foregroundColor: selected ? AppColors.primary : colors.onSurfaceVariant,
        side: BorderSide(
          color: selected ? colors.primary : AppColors.borderSoft,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.center,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

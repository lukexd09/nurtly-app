import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/nurtly_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/localization/app_strings.dart';
import 'add_journal_entry_screen.dart';
import 'journal_controller.dart';
import 'journal_entry.dart';
import 'journal_entry_card.dart';
import 'journal_entry_type.dart';
import 'journal_store.dart';
import 'journal_summary.dart';
import 'widgets/journal_day_picker_sheet.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    required this.strings,
    this.controller,
    this.store,
    this.now = DateTime.now,
    this.activeSleepTickerInterval = const Duration(minutes: 1),
    super.key,
  });

  final AppStrings strings;
  final JournalController? controller;
  final JournalStore? store;
  final DateTime Function() now;
  final Duration activeSleepTickerInterval;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final JournalController _controller;
  late final bool _ownsController;
  Timer? _activeSleepTicker;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        JournalController(
          store: widget.store ?? const SharedPreferencesJournalStore(),
          now: widget.now,
        );
    _controller.addListener(_syncActiveSleepTicker);
    if (!_controller.hasLoaded) {
      unawaited(_controller.load());
    }
    _syncActiveSleepTicker();
  }

  @override
  void dispose() {
    _controller.removeListener(_syncActiveSleepTicker);
    _activeSleepTicker?.cancel();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _syncActiveSleepTicker() {
    final activeSleep = _controller.activeSleep;
    if (activeSleep == null) {
      _activeSleepTicker?.cancel();
      _activeSleepTicker = null;
      return;
    }
    if (_activeSleepTicker != null) {
      return;
    }
    _activeSleepTicker = Timer.periodic(widget.activeSleepTickerInterval, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _openDayPicker() async {
    final selectedDay = await showJournalDayPickerSheet(
      context: context,
      strings: widget.strings,
      initialDay: _controller.selectedDay,
      now: widget.now(),
    );
    if (selectedDay == null) {
      return;
    }
    _controller.selectDay(selectedDay);
  }

  Future<void> _openAddEntry(JournalEntryType type) async {
    final selectedDay = _controller.selectedDay;
    final entry = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
        builder: (_) => AddJournalEntryScreen(
          strings: widget.strings,
          entryType: type,
          initialDay: selectedDay,
          now: widget.now,
        ),
      ),
    );
    if (entry == null) {
      return;
    }
    await _controller.addEntry(entry);
  }

  Future<void> _editEntry(JournalEntry entry) async {
    final updated = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
        builder: (_) => AddJournalEntryScreen(
          strings: widget.strings,
          entryType: entry.type,
          initialEntry: entry,
          now: widget.now,
        ),
      ),
    );
    if (updated == null) {
      return;
    }
    await _controller.updateEntry(updated);
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(widget.strings.journalDeleteEntryTitle),
          content: Text(widget.strings.journalDeleteEntryBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(widget.strings.journalCancelEntry),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(widget.strings.journalDeleteEntry),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await _controller.deleteEntry(entry.id);
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final summary = _controller.summary;
        final entries = _controller.entries;
        final activeSleep = _controller.activeSleep;
        final selectedDay = _controller.selectedDay;
        return SafeArea(
          child: ListView(
            key: const ValueKey('journal-scroll-view'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SectionHeader(
                key: const ValueKey('journal-header'),
                title: strings.journalTitle,
                subtitle: strings.journalSubtitle,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                key: const ValueKey('journal-local-only-hint'),
                strings.journalLocalOnlyHint,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              if (activeSleep != null) ...[
                const SizedBox(height: AppSpacing.md),
                _ActiveSleepCard(
                  key: const ValueKey('journal-active-sleep-card'),
                  strings: strings,
                  entry: activeSleep,
                  now: widget.now(),
                  onStop: _controller.stopSleep,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _DashboardSection(
                key: const ValueKey('journal-dashboard-section'),
                strings: strings,
                summary: summary,
                selectedDay: selectedDay,
                now: widget.now(),
                hasEntriesForSelectedDay: entries.isNotEmpty,
                onPreviousDay: _controller.goToPreviousDay,
                onNextDay: _controller.goToNextDay,
                onPickDay: _openDayPicker,
              ),
              const SizedBox(height: AppSpacing.lg),
              _QuickActions(
                key: const ValueKey('journal-quick-actions'),
                strings: strings,
                hasActiveSleep: activeSleep != null,
                onStartSleep: _controller.startSleep,
                onAddSleep: () => _openAddEntry(JournalEntryType.sleep),
                onAddFeeding: () => _openAddEntry(JournalEntryType.feeding),
                onAddDiaper: () => _openAddEntry(JournalEntryType.diaper),
                onAddNote: () => _openAddEntry(JournalEntryType.note),
              ),
              const SizedBox(height: AppSpacing.lg),
              _DayTimelineHeader(
                key: const ValueKey('journal-timeline-section'),
                strings: strings,
                selectedDay: selectedDay,
                now: widget.now(),
              ),
              const SizedBox(height: AppSpacing.md),
              if (entries.isEmpty)
                EmptyState(
                  key: const ValueKey('journal-empty-state'),
                  title: strings.journalEmptyStateTitle,
                  message: strings.journalEmptyStateMessage,
                )
              else
                ..._entryCards(strings, entries),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _entryCards(AppStrings strings, List<JournalEntry> entries) {
    return [
      for (var index = 0; index < entries.length; index++) ...[
        if (index > 0) const SizedBox(height: AppSpacing.md),
        JournalEntryCard(
          entry: entries[index],
          strings: strings,
          onEdit: () => _editEntry(entries[index]),
          onDelete: () => _deleteEntry(entries[index]),
        ),
      ],
    ];
  }
}

class _ActiveSleepCard extends StatelessWidget {
  const _ActiveSleepCard({
    super.key,
    required this.strings,
    required this.entry,
    required this.now,
    required this.onStop,
  });

  final AppStrings strings;
  final JournalEntry entry;
  final DateTime now;
  final Future<bool> Function() onStop;

  @override
  Widget build(BuildContext context) {
    final startAt = entry.startAt ?? entry.createdAt;
    final elapsed = now.difference(startAt);
    final canStop = !now.isBefore(startAt);
    return NurtlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.journalActiveSleepTitle,
            style:
                AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${strings.journalActiveSleepStartedLabel}: ${strings.journalTimeLabel(startAt)}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${strings.journalActiveSleepDurationLabel}: ${strings.formatJournalDuration(elapsed)}',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: canStop
                ? () async {
                    await onStop();
                  }
                : null,
            child: Text(strings.journalStopSleep),
          ),
        ],
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    super.key,
    required this.strings,
    required this.summary,
    required this.selectedDay,
    required this.now,
    required this.hasEntriesForSelectedDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onPickDay,
  });

  final AppStrings strings;
  final JournalSummary summary;
  final DateTime selectedDay;
  final DateTime now;
  final bool hasEntriesForSelectedDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final Future<void> Function() onPickDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _JournalDaySelector(
          key: const ValueKey('journal-day-selector'),
          strings: strings,
          selectedDay: selectedDay,
          now: now,
          onPreviousDay: onPreviousDay,
          onNextDay: onNextDay,
          onPickDay: onPickDay,
        ),
        const SizedBox(height: AppSpacing.xs),
        _JournalSection(
          key: const ValueKey('journal-summary-card'),
          child: _CompactSummaryCard(
            key: const ValueKey('journal-compact-summary-card'),
            strings: strings,
            summary: summary,
            selectedDay: selectedDay,
            now: now,
          ),
        ),
        if (hasEntriesForSelectedDay) ...[
          const SizedBox(height: AppSpacing.sm),
          _JournalSection(
            key: const ValueKey('journal-last-entries-card'),
            child: _LastMomentsSection(
              key: const ValueKey('journal-last-moments-section'),
              strings: strings,
              summary: summary,
            ),
          ),
        ],
      ],
    );
  }
}

class _JournalDaySelector extends StatelessWidget {
  const _JournalDaySelector({
    super.key,
    required this.strings,
    required this.selectedDay,
    required this.now,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onPickDay,
  });

  final AppStrings strings;
  final DateTime selectedDay;
  final DateTime now;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final Future<void> Function() onPickDay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          key: const ValueKey('journal-day-previous'),
          tooltip: strings.journalPreviousDay,
          onPressed: onPreviousDay,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 168,
                child: InkWell(
                  key: const ValueKey('journal-selected-day-picker-trigger'),
                  borderRadius: BorderRadius.circular(999),
                  onTap: onPickDay,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.borderSoft),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            strings.journalDayLabel(selectedDay, now),
                            style: AppTextStyles.sectionTitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        const Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          key: const ValueKey('journal-day-next'),
          tooltip: strings.journalNextDay,
          onPressed: onNextDay,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _JournalSection extends StatelessWidget {
  const _JournalSection({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: child,
    );
  }
}

class _CompactSummaryCard extends StatelessWidget {
  const _CompactSummaryCard({
    super.key,
    required this.strings,
    required this.summary,
    required this.selectedDay,
    required this.now,
  });

  final AppStrings strings;
  final JournalSummary summary;
  final DateTime selectedDay;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.journalDayLabel(selectedDay, now),
            key: const ValueKey('journal-compact-summary-label'),
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.xs),
          _JournalMetricRow(
            label: strings.journalTotalSleep,
            value: summary.totalSleep == Duration.zero
                ? '0 min'
                : strings.formatJournalDuration(summary.totalSleep),
          ),
          _JournalMetricRow(
            label: strings.journalFeedingsCount,
            value: summary.feedingsCount.toString(),
          ),
          _JournalMetricRow(
            label: strings.journalDiapersCount,
            value: summary.diapersCount.toString(),
          ),
          _JournalMetricRow(
            label: strings.journalNotesCount,
            value: summary.notesCount.toString(),
          ),
        ],
      ),
    );
  }
}

class _JournalMetricRow extends StatelessWidget {
  const _JournalMetricRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastMomentsSection extends StatelessWidget {
  const _LastMomentsSection({
    super.key,
    required this.strings,
    required this.summary,
  });

  final AppStrings strings;
  final JournalSummary summary;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.journalLastMomentsTitle, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          _JournalMetricRow(
            label: strings.journalLastSleep,
            value: _lastEntryValue(summary.lastSleep),
          ),
          _JournalMetricRow(
            label: strings.journalLastFeeding,
            value: _lastEntryValue(summary.lastFeeding),
          ),
          _JournalMetricRow(
            label: strings.journalLastDiaper,
            value: _lastEntryValue(summary.lastDiaper),
          ),
          _JournalMetricRow(
            label: strings.journalNotesToday,
            value: _lastEntryValue(summary.latestNote),
          ),
        ],
      ),
    );
  }

  String _lastEntryValue(JournalEntry? entry) {
    if (entry == null) {
      return strings.journalNoEntryShort;
    }
    return strings.journalTimeLabel(entry.effectiveAt);
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    super.key,
    required this.strings,
    required this.hasActiveSleep,
    required this.onStartSleep,
    required this.onAddSleep,
    required this.onAddFeeding,
    required this.onAddDiaper,
    required this.onAddNote,
  });

  final AppStrings strings;
  final bool hasActiveSleep;
  final Future<bool> Function() onStartSleep;
  final VoidCallback onAddSleep;
  final VoidCallback onAddFeeding;
  final VoidCallback onAddDiaper;
  final VoidCallback onAddNote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.journalQuickActionsTitle,
            style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            key: const ValueKey('journal-start-sleep'),
            onPressed: hasActiveSleep
                ? null
                : () async {
                    await onStartSleep();
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(strings.journalStartSleep),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            final chipWidth = (constraints.maxWidth - AppSpacing.xs) / 2;
            return Column(
              key: const ValueKey('journal-quick-action-chip-grid'),
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: chipWidth,
                      child: _JournalQuickActionChip(
                        key: const ValueKey('journal-quick-action-add-sleep'),
                        label: strings.journalQuickActionSleep,
                        onPressed: onAddSleep,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    SizedBox(
                      width: chipWidth,
                      child: _JournalQuickActionChip(
                        key: const ValueKey('journal-quick-action-feeding'),
                        label: strings.journalQuickActionFeeding,
                        onPressed: onAddFeeding,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    SizedBox(
                      width: chipWidth,
                      child: _JournalQuickActionChip(
                        key: const ValueKey('journal-quick-action-diaper'),
                        label: strings.journalQuickActionDiaper,
                        onPressed: onAddDiaper,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    SizedBox(
                      width: chipWidth,
                      child: _JournalQuickActionChip(
                        key: const ValueKey('journal-quick-action-note'),
                        label: strings.journalQuickActionNote,
                        onPressed: onAddNote,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _JournalQuickActionChip extends StatelessWidget {
  const _JournalQuickActionChip({
    super.key,
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minimumSize: const Size.fromHeight(40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

class _DayTimelineHeader extends StatelessWidget {
  const _DayTimelineHeader({
    super.key,
    required this.strings,
    required this.selectedDay,
    required this.now,
  });

  final AppStrings strings;
  final DateTime selectedDay;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Text(
      strings.journalDayLabel(selectedDay, now),
      style: AppTextStyles.sectionTitle,
    );
  }
}

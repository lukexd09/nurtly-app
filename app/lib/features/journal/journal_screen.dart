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

  Future<void> _openAddEntry(JournalEntryType type) async {
    final entry = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
        builder: (_) => AddJournalEntryScreen(
          strings: widget.strings,
          entryType: type,
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
                onPreviousDay: _controller.goToPreviousDay,
                onToday: _controller.goToToday,
                onNextDay: _controller.goToNextDay,
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
                key: const ValueKey('journal-day-timeline-header'),
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
    required this.onPreviousDay,
    required this.onToday,
    required this.onNextDay,
  });

  final AppStrings strings;
  final JournalSummary summary;
  final DateTime selectedDay;
  final DateTime now;
  final VoidCallback onPreviousDay;
  final VoidCallback onToday;
  final VoidCallback onNextDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          key: const ValueKey('journal-day-navigation'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  key: const ValueKey('journal-day-previous'),
                  tooltip: strings.journalPreviousDay,
                  onPressed: onPreviousDay,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      strings.journalDayLabel(selectedDay, now),
                      style: AppTextStyles.sectionTitle,
                      textAlign: TextAlign.center,
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
            ),
            if (_isNotToday(selectedDay, now))
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const ValueKey('journal-day-today'),
                  onPressed: onToday,
                  child: Text(strings.journalTodayLabel),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 360;
            final cardWidth = twoColumns
                ? (constraints.maxWidth - AppSpacing.sm) / 2
                : constraints.maxWidth;
            return Wrap(
              key: const ValueKey('journal-summary-cards'),
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _SummaryCard(
                    label: strings.journalTotalSleep,
                    value: _summaryValue(strings, summary.totalSleep),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _SummaryCard(
                    label: strings.journalFeedingsCount,
                    value: _countValue(summary.feedingsCount),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _SummaryCard(
                    label: strings.journalDiapersCount,
                    value: _countValue(summary.diapersCount),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _SummaryCard(
                    label: strings.journalNotesCount,
                    value: _countValue(summary.notesCount),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _LastMomentLine(
          label: strings.journalLastSleep,
          value: _lastEntryValue(
            strings,
            summary.lastSleep,
            strings.journalNoEntryShort,
          ),
        ),
        _LastMomentLine(
          label: strings.journalLastFeeding,
          value: _lastEntryValue(
            strings,
            summary.lastFeeding,
            strings.journalNoEntryShort,
          ),
        ),
        _LastMomentLine(
          label: strings.journalLastDiaper,
          value: _lastEntryValue(
            strings,
            summary.lastDiaper,
            strings.journalNoEntryShort,
          ),
        ),
        _LastMomentLine(
          label: strings.journalNotesToday,
          value: _lastEntryValue(
            strings,
            summary.latestNote,
            strings.journalNoEntryShort,
          ),
        ),
      ],
    );
  }

  String _summaryValue(
    AppStrings strings,
    Duration duration,
  ) {
    if (duration == Duration.zero) {
      return '0 min';
    }
    return strings.formatJournalDuration(duration);
  }

  String _countValue(int count) {
    return count.toString();
  }

  String _lastEntryValue(
      AppStrings strings, JournalEntry? entry, String emptyLabel) {
    if (entry == null) {
      return emptyLabel;
    }
    final time = entry.effectiveAt;
    return strings.journalTimeLabel(time);
  }

  bool _isNotToday(DateTime selectedDay, DateTime now) {
    final selected =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final today = DateTime(now.year, now.month, now.day);
    return selected != today;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LastMomentLine extends StatelessWidget {
  const _LastMomentLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.body),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
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
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            FilledButton.tonalIcon(
              key: const ValueKey('journal-start-sleep'),
              onPressed: hasActiveSleep
                  ? null
                  : () async {
                      await onStartSleep();
                    },
              icon: const Icon(Icons.play_arrow),
              label: Text(strings.journalStartSleep),
            ),
            TextButton(
              onPressed: onAddSleep,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(strings.journalQuickActionSleep),
            ),
            TextButton(
              onPressed: onAddFeeding,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(strings.journalQuickActionFeeding),
            ),
            TextButton(
              onPressed: onAddDiaper,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(strings.journalQuickActionDiaper),
            ),
            TextButton(
              onPressed: onAddNote,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(strings.journalQuickActionNote),
            ),
          ],
        ),
      ],
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

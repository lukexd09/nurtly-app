import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/nurtly_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';

const _moodLabels = [
  'Calm',
  'Tired',
  'Busy',
  'Good moment',
  'Hard moment',
];

class JournalScreen extends StatefulWidget {
  const JournalScreen({
    super.key,
    this.now = DateTime.now,
  });

  final DateTime Function() now;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<_JournalEntry> _entries = [];

  Future<void> _openAddEntry() async {
    final entry = await Navigator.of(context).push<_JournalEntry>(
      MaterialPageRoute<_JournalEntry>(
        builder: (_) => AddJournalEntryScreen(now: widget.now),
      ),
    );

    if (entry == null) {
      return;
    }

    setState(() {
      _entries.insert(0, entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SectionHeader(
            title: 'Journal',
            subtitle: 'Keep a small note from today.',
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Add note',
            onPressed: _openAddEntry,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_entries.isEmpty)
            const EmptyState(
              title: 'No journal notes yet.',
              message: 'Add a short note when you are ready.',
            )
          else
            ..._entryCards(_entries),
        ],
      ),
    );
  }

  List<Widget> _entryCards(List<_JournalEntry> entries) {
    return [
      for (var index = 0; index < entries.length; index++) ...[
        if (index > 0) const SizedBox(height: AppSpacing.md),
        _JournalEntryCard(entry: entries[index]),
      ],
    ];
  }
}

class AddJournalEntryScreen extends StatefulWidget {
  const AddJournalEntryScreen({
    super.key,
    this.now = DateTime.now,
  });

  final DateTime Function() now;

  @override
  State<AddJournalEntryScreen> createState() => _AddJournalEntryScreenState();
}

class _AddJournalEntryScreenState extends State<AddJournalEntryScreen> {
  final _noteController = TextEditingController();
  String? _selectedMood;
  String? _validationMessage;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      setState(() {
        _validationMessage = 'Please add a short note first.';
      });
      return;
    }

    Navigator.of(context).pop(
      _JournalEntry(
        note: note,
        moodLabel: _selectedMood,
        createdAt: widget.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back',
                color: AppColors.primary,
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const SectionHeader(
              title: 'Add note',
              subtitle: 'Capture a small moment from your day.',
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _noteController,
              minLines: 4,
              maxLines: 7,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Write a few words...',
              ),
            ),
            if (_validationMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _validationMessage!,
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            const Text('Mood', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final mood in _moodLabels)
                  ChoiceChip(
                    label: Text(mood),
                    selected: _selectedMood == mood,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMood = selected ? mood : null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Save note',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry});

  final _JournalEntry entry;

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

class _JournalEntry {
  const _JournalEntry({
    required this.note,
    required this.createdAt,
    this.moodLabel,
  });

  final String note;
  final DateTime createdAt;
  final String? moodLabel;

  String get readableTimestamp {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return 'Today $hour:$minute';
  }
}

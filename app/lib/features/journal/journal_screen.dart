import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';
import 'add_journal_entry_screen.dart';
import 'journal_entry.dart';
import 'journal_entry_card.dart';

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
  final List<JournalEntry> _entries = [];

  Future<void> _openAddEntry() async {
    final entry = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute<JournalEntry>(
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

  List<Widget> _entryCards(List<JournalEntry> entries) {
    return [
      for (var index = 0; index < entries.length; index++) ...[
        if (index > 0) const SizedBox(height: AppSpacing.md),
        JournalEntryCard(entry: entries[index]),
      ],
    ];
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';
import 'journal_entry.dart';

const _moodLabels = [
  'Calm',
  'Tired',
  'Busy',
  'Good moment',
  'Hard moment',
];

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
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  String? _selectedMood;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      JournalEntry(
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
        child: Form(
          key: _formKey,
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
              TextFormField(
                controller: _noteController,
                minLines: 4,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please add a short note first.';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Write a few words...',
                ),
              ),
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
      ),
    );
  }
}

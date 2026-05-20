import 'package:flutter/material.dart';

import '../../core/content/content_loader.dart';
import '../../core/content/content_package.dart';
import '../../core/content/play_idea.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_note.dart';
import '../../core/widgets/detail_section.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/tappable_nurtly_card.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    this.contentLoader = const ContentLoader(),
  });

  final ContentLoader contentLoader;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final Future<ContentPackage> _contentFuture;
  _QuickFilter _selectedFilter = _QuickFilter.all;

  @override
  void initState() {
    super.initState();
    _contentFuture = widget.contentLoader.load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: _contentFuture,
        builder: (context, snapshot) {
          final playIdeas = snapshot.data?.playIdeas;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const _PlayHeader(),
              const SizedBox(height: AppSpacing.lg),
              if (snapshot.connectionState != ConnectionState.done)
                const LoadingCard(label: 'Loading play ideas...')
              else if (snapshot.hasError)
                const EmptyState(
                  title: 'Play ideas could not be loaded.',
                  message: 'Please try again in a moment.',
                )
              else if (playIdeas == null || playIdeas.isEmpty)
                const EmptyState(
                  title: 'No play ideas available yet.',
                  message: 'More simple ideas will appear here later.',
                )
              else ...[
                _QuickFilters(
                  selectedFilter: _selectedFilter,
                  onSelected: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                ..._filteredPlayIdeaSection(playIdeas),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _filteredPlayIdeaSection(List<PlayIdea> playIdeas) {
    final filtered = _applyQuickFilter(playIdeas, _selectedFilter);
    if (filtered.isEmpty) {
      return const [
        EmptyState(
          title: 'Nothing here yet',
          message: 'Try another filter for now. More gentle ideas are coming.',
        ),
      ];
    }
    return _playIdeaCards(filtered);
  }

  List<PlayIdea> _applyQuickFilter(List<PlayIdea> ideas, _QuickFilter filter) {
    return switch (filter) {
      _QuickFilter.all => ideas,
      _QuickFilter.lowEffort =>
        ideas.where((idea) => idea.parentInvolvement == 'Low').toList(),
      _QuickFilter.lowMess =>
        ideas.where((idea) => idea.messLevel == 'Low').toList(),
      _QuickFilter.forBabies =>
        ideas.where((idea) => _isForBabies(idea.ageGroup)).toList(),
      _QuickFilter.toddlers =>
        ideas.where((idea) => _isForToddlers(idea.ageGroup)).toList(),
      _QuickFilter.movement =>
        ideas.where((idea) => idea.activityType == 'Movement').toList(),
      _QuickFilter.quiet => ideas
          .where(
            (idea) =>
                idea.activityType == 'Quiet time' ||
                idea.childEngagement == 'Low',
          )
          .toList(),
    };
  }

  List<Widget> _playIdeaCards(List<PlayIdea> playIdeas) {
    return [
      for (var index = 0; index < playIdeas.length; index++) ...[
        if (index > 0) const SizedBox(height: AppSpacing.md),
        _PlayIdeaCard(
          idea: playIdeas[index],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    PlayActivityDetailScreen(idea: playIdeas[index]),
              ),
            );
          },
        ),
      ],
    ];
  }
}

enum _QuickFilter {
  all('All'),
  lowEffort('Low effort'),
  lowMess('Low mess'),
  forBabies('For babies'),
  toddlers('Toddlers'),
  movement('Movement'),
  quiet('Quiet');

  const _QuickFilter(this.label);
  final String label;
}

class _QuickFilters extends StatelessWidget {
  const _QuickFilters({
    required this.selectedFilter,
    required this.onSelected,
  });

  final _QuickFilter selectedFilter;
  final ValueChanged<_QuickFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: _QuickFilter.values.map((filter) {
        return Material(
          color: Colors.transparent,
          child: ChoiceChip(
            label: Text(filter.label),
            selected: selectedFilter == filter,
            onSelected: (_) => onSelected(filter),
            selectedColor: AppColors.primarySoft,
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.borderSoft),
            labelStyle: selectedFilter == filter
                ? AppTextStyles.caption.copyWith(color: AppColors.primary)
                : AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
            showCheckmark: false,
          ),
        );
      }).toList(),
    );
  }
}

bool _isForBabies(String ageGroup) {
  return ageGroup.contains('0-12 months') || ageGroup.contains('6-18 months');
}

bool _isForToddlers(String ageGroup) {
  return ageGroup.contains('18 months-3 years') ||
      ageGroup.contains('2-5 years');
}

class _PlayHeader extends StatelessWidget {
  const _PlayHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose a gentle play idea',
                    style: AppTextStyles.screenTitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Simple screen-free moments for connection, calm, and everyday family rhythm.',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayIdeaCard extends StatelessWidget {
  const _PlayIdeaCard({
    required this.idea,
    required this.onTap,
  });

  final PlayIdea idea;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TappableNurtlyCard(
      semanticLabel: 'Open ${idea.title}',
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(idea.title, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(idea.summary, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          _PlayIdeaMetadata(idea: idea),
        ],
      ),
    );
  }
}

class PlayActivityDetailScreen extends StatelessWidget {
  const PlayActivityDetailScreen({
    required this.idea,
    super.key,
  });

  final PlayIdea idea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _DetailBackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.md),
            _PlayDetailHero(idea: idea),
            const SizedBox(height: AppSpacing.lg),
            _ExpectationSection(idea: idea),
            const SizedBox(height: AppSpacing.md),
            DetailSection(
              title: "What you'll need",
              children: [
                for (final item in idea.neededItems) _BulletText(item),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DetailSection(
              title: 'Steps',
              children: [
                for (var index = 0; index < idea.steps.length; index++)
                  _NumberedText(
                    number: index + 1,
                    text: idea.steps[index],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DetailNote(
              title: 'Parent note',
              text: idea.parentNote,
            ),
            const SizedBox(height: AppSpacing.md),
            DetailNote(
              title: 'Safety note',
              text: idea.safetyNote,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBackButton extends StatelessWidget {
  const _DetailBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.borderSoft),
        ),
        child: IconButton(
          tooltip: 'Back',
          color: AppColors.primary,
          icon: const Icon(Icons.arrow_back),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _PlayDetailHero extends StatelessWidget {
  const _PlayDetailHero({required this.idea});

  final PlayIdea idea;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(8),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(idea.title, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(idea.summary, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            _PlayIdeaMetadata(idea: idea),
          ],
        ),
      ),
    );
  }
}

class _ExpectationSection extends StatelessWidget {
  const _ExpectationSection({required this.idea});

  final PlayIdea idea;

  @override
  Widget build(BuildContext context) {
    return DetailSection(
      title: 'What to expect',
      children: [
        Text(_expectationSummary(idea), style: AppTextStyles.body),
      ],
    );
  }
}

String _expectationSummary(PlayIdea idea) {
  if (idea.whatToExpect.trim().isNotEmpty) {
    return idea.whatToExpect;
  }

  final mess = _messPhrase(idea.messLevel);
  final childEnergy = _childEnergyPhrase(idea.childEngagement);
  final parentEffort = _parentEffortPhrase(idea.parentInvolvement);
  final guidance = _parentGuidance(idea.parentInvolvement);

  if (mess == null ||
      childEnergy == null ||
      parentEffort == null ||
      guidance == null) {
    return 'Choose this when it feels like a good fit for your space, your child, and the energy you have available.';
  }

  return 'A $childEnergy, $mess activity that $parentEffort. $guidance';
}

String? _messPhrase(String value) {
  return switch (value) {
    'Low' => 'low-mess',
    'Medium' => 'slightly messy',
    'High' => 'more hands-on cleanup',
    _ => null,
  };
}

String? _childEnergyPhrase(String value) {
  return switch (value) {
    'Low' => 'quiet',
    'Medium' => 'gently engaging',
    'High' => 'more active',
    _ => null,
  };
}

String? _parentEffortPhrase(String value) {
  return switch (value) {
    'Low' => 'does not need much setup',
    'Medium' => 'works best with a little shared attention',
    'High' => 'works best when you have energy to join in',
    _ => null,
  };
}

String? _parentGuidance(String value) {
  return switch (value) {
    'Low' =>
      'Stay nearby, offer gentle guidance, and let your child explore at their own pace.',
    'Medium' => 'Join in for a few moments and keep the play easy.',
    'High' => 'Choose it when active participation feels available.',
    _ => null,
  };
}

class _PlayIdeaMetadata extends StatelessWidget {
  const _PlayIdeaMetadata({required this.idea});

  final PlayIdea idea;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        NurtlyChip(label: idea.ageGroup),
        NurtlyChip(label: idea.place),
        NurtlyChip(label: '${idea.messLevel} mess'),
        NurtlyChip(label: 'Child: ${_lowercaseLabel(idea.childEngagement)}'),
        NurtlyChip(label: 'Parent: ${_lowercaseLabel(idea.parentInvolvement)}'),
        NurtlyChip(label: idea.activityType),
      ],
    );
  }
}

String _lowercaseLabel(String value) => value.toLowerCase();

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text('- $text', style: AppTextStyles.body);
  }
}

class _NumberedText extends StatelessWidget {
  const _NumberedText({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text('$number. $text', style: AppTextStyles.body);
  }
}

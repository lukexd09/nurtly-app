import 'package:flutter/material.dart';

import '../../core/content/content_loader.dart';
import '../../core/content/content_package.dart';
import '../../core/content/content_taxonomy.dart';
import '../../core/content/play_filter.dart';
import '../../core/content/play_idea.dart';
import '../../core/content/sound_item.dart';
import '../../core/content/suggested_sound_resolver.dart';
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
import '../sounds/widgets/suggested_sound_mini_player.dart';

PlayIdea selectDailyPlayIdea(List<PlayIdea> ideas, DateTime date) {
  final dayOfYear = DateTime(date.year, date.month, date.day)
      .difference(DateTime(date.year, 1, 1))
      .inDays;
  return ideas[dayOfYear % ideas.length];
}

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
  late Future<ContentPackage> _contentFuture;
  bool _filtersExpanded = false;
  final Set<String> _selectedFilterIds = <String>{};

  @override
  void initState() {
    super.initState();
    _contentFuture = widget.contentLoader.load();
  }

  @override
  void didUpdateWidget(covariant PlayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentLoader != widget.contentLoader) {
      _contentFuture = widget.contentLoader.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: _contentFuture,
        builder: (context, snapshot) {
          final package = snapshot.data;
          final playIdeas = package?.playIdeas;

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
                _QuickFiltersModule(
                  expanded: _filtersExpanded,
                  filters: package?.playFilters ?? const <PlayFilter>[],
                  selectedFilterIds: _selectedFilterIds,
                  onToggleExpanded: () {
                    setState(() {
                      _filtersExpanded = !_filtersExpanded;
                    });
                  },
                  onToggleFilter: (filter) {
                    setState(() {
                      if (_selectedFilterIds.contains(filter.id)) {
                        _selectedFilterIds.remove(filter.id);
                      } else {
                        _selectedFilterIds.add(filter.id);
                      }
                    });
                  },
                  onClear: _selectedFilterIds.isEmpty
                      ? null
                      : () {
                          setState(() {
                            _selectedFilterIds.clear();
                          });
                        },
                  activeCountLabel: _selectedFilterIds.isEmpty
                      ? null
                      : '${_applyQuickFilters(playIdeas, package?.playFilters ?? const <PlayFilter>[], _selectedFilterIds).length} gentle ideas',
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._filteredPlayIdeaSection(
                  playIdeas,
                  package?.playFilters ?? const <PlayFilter>[],
                  package?.sounds ?? const <SoundItem>[],
                  package!.taxonomy,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _filteredPlayIdeaSection(
    List<PlayIdea> playIdeas,
    List<PlayFilter> filters,
    List<SoundItem> sounds,
    ContentTaxonomy taxonomy,
  ) {
    final filtered = _applyQuickFilters(
      playIdeas,
      filters,
      _selectedFilterIds,
    );
    if (filtered.isEmpty) {
      return const [
        EmptyState(
          title: 'Nothing here yet',
          message:
              'Try removing one filter for now. More gentle ideas are coming.',
        ),
      ];
    }
    return [
      ..._playIdeaCards(filtered, sounds, taxonomy),
    ];
  }

  List<PlayIdea> _applyQuickFilters(
    List<PlayIdea> ideas,
    List<PlayFilter> filters,
    Set<String> selectedFilterIds,
  ) {
    if (selectedFilterIds.isEmpty) {
      return ideas;
    }
    final selectedFilters = filters
        .where((filter) => selectedFilterIds.contains(filter.id))
        .toList();
    if (selectedFilters.isEmpty) {
      return ideas;
    }
    return ideas
        .where(
            (idea) => selectedFilters.every((filter) => filter.matches(idea)))
        .toList();
  }

  List<Widget> _playIdeaCards(
    List<PlayIdea> playIdeas,
    List<SoundItem> sounds,
    ContentTaxonomy taxonomy,
  ) {
    return [
      for (var index = 0; index < playIdeas.length; index++) ...[
        if (index > 0) const SizedBox(height: AppSpacing.md),
        _PlayIdeaCard(
          idea: playIdeas[index],
          taxonomy: taxonomy,
          onTap: () {
            final suggestedSound =
                resolveSuggestedSound(playIdeas[index], sounds);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PlayActivityDetailScreen(
                  idea: playIdeas[index],
                  taxonomy: taxonomy,
                  suggestedSound: suggestedSound,
                ),
              ),
            );
          },
        ),
      ],
    ];
  }
}

class _QuickFiltersModule extends StatelessWidget {
  const _QuickFiltersModule({
    required this.expanded,
    required this.filters,
    required this.selectedFilterIds,
    required this.onToggleExpanded,
    required this.onToggleFilter,
    required this.onClear,
    required this.activeCountLabel,
  });

  final bool expanded;
  final List<PlayFilter> filters;
  final Set<String> selectedFilterIds;
  final VoidCallback onToggleExpanded;
  final ValueChanged<PlayFilter> onToggleFilter;
  final VoidCallback? onClear;
  final String? activeCountLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: onToggleExpanded,
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                label: Text(
                  'Find the right fit',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (onClear != null)
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Clear', style: AppTextStyles.caption),
              ),
          ],
        ),
        if (activeCountLabel != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              activeCountLabel!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (expanded) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: filters.map((filter) {
              return Material(
                color: Colors.transparent,
                child: FilterChip(
                  label: Text(filter.label),
                  selected: selectedFilterIds.contains(filter.id),
                  onSelected: (_) => onToggleFilter(filter),
                  selectedColor: AppColors.primarySoft,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.borderSoft),
                  labelStyle: selectedFilterIds.contains(filter.id)
                      ? AppTextStyles.caption.copyWith(color: AppColors.primary)
                      : AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
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
    required this.taxonomy,
    required this.onTap,
  });

  final PlayIdea idea;
  final ContentTaxonomy taxonomy;
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
          _PlayIdeaMetadata(idea: idea, taxonomy: taxonomy),
        ],
      ),
    );
  }
}

class PlayActivityDetailScreen extends StatelessWidget {
  const PlayActivityDetailScreen({
    required this.idea,
    required this.taxonomy,
    this.suggestedSound,
    super.key,
  });

  final PlayIdea idea;
  final ContentTaxonomy taxonomy;
  final SoundItem? suggestedSound;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _PlayDetailHero(
              idea: idea,
              taxonomy: taxonomy,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (suggestedSound != null) ...[
              SuggestedSoundMiniPlayer(sound: suggestedSound!),
              const SizedBox(height: AppSpacing.lg),
            ],
            _ExpectationSection(idea: idea, taxonomy: taxonomy),
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
  const _PlayDetailHero({
    required this.idea,
    required this.taxonomy,
    required this.onBackPressed,
  });

  final PlayIdea idea;
  final ContentTaxonomy taxonomy;
  final VoidCallback onBackPressed;

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
            _DetailBackButton(onPressed: onBackPressed),
            const SizedBox(height: AppSpacing.sm),
            Text(idea.title, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(idea.summary, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            _PlayIdeaMetadata(idea: idea, taxonomy: taxonomy),
          ],
        ),
      ),
    );
  }
}

class _ExpectationSection extends StatelessWidget {
  const _ExpectationSection({
    required this.idea,
    required this.taxonomy,
  });

  final PlayIdea idea;
  final ContentTaxonomy taxonomy;

  @override
  Widget build(BuildContext context) {
    return DetailSection(
      title: 'What to expect',
      children: [
        Text(_expectationSummary(idea, taxonomy), style: AppTextStyles.body),
      ],
    );
  }
}

String _expectationSummary(PlayIdea idea, ContentTaxonomy taxonomy) {
  if (idea.whatToExpect.trim().isNotEmpty) {
    return idea.whatToExpect;
  }

  final mess = _messPhrase(taxonomy.labelForMessLevel(idea.messLevel));
  final childEnergy = _childEnergyPhrase(
      taxonomy.labelForChildEngagement(idea.childEngagement));
  final parentEffort = _parentEffortPhrase(
      taxonomy.labelForParentInvolvement(idea.parentInvolvement));
  final guidance = _parentGuidance(
      taxonomy.labelForParentInvolvement(idea.parentInvolvement));

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
  const _PlayIdeaMetadata({
    required this.idea,
    required this.taxonomy,
  });

  final PlayIdea idea;
  final ContentTaxonomy taxonomy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        NurtlyChip(label: idea.ageGroup),
        NurtlyChip(
          label: taxonomy.labelForPlace(idea.place),
        ),
        NurtlyChip(
          label: '${taxonomy.labelForMessLevel(idea.messLevel)} mess',
        ),
        NurtlyChip(
          label:
              'Child: ${_lowercaseLabel(taxonomy.labelForChildEngagement(idea.childEngagement))}',
        ),
        NurtlyChip(
          label:
              'Parent: ${_lowercaseLabel(taxonomy.labelForParentInvolvement(idea.parentInvolvement))}',
        ),
        NurtlyChip(
          label: taxonomy.labelForActivityType(idea.activityType),
        ),
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

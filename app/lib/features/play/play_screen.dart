import 'package:flutter/material.dart';

import '../../core/ads/ad_widget_factory.dart';
import '../../core/localization/app_strings.dart';
import '../../core/monetization/ad_insertion_policy.dart';
import '../../core/monetization/premium_entitlement.dart';
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
    this.strings = AppStrings.english,
    this.premiumEntitlement,
    this.onOpenPremiumPaywall,
    this.showAdPlaceholder = false,
    this.adWidgetFactory = const FakeAdWidgetFactory(),
  });

  final ContentLoader contentLoader;
  final AppStrings strings;
  final PremiumEntitlement? premiumEntitlement;
  final VoidCallback? onOpenPremiumPaywall;
  final bool showAdPlaceholder;
  final AdWidgetFactory adWidgetFactory;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late Future<ContentPackage> _contentFuture;
  bool _filtersExpanded = false;
  final Set<String> _selectedFilterIds = <String>{};
  final Set<String> _selectedAccessFilterIds = <String>{};
  late PremiumEntitlement _effectiveEntitlement;

  @override
  void initState() {
    super.initState();
    _effectiveEntitlement =
        widget.premiumEntitlement ?? PremiumEntitlement.free();
    _contentFuture = widget.contentLoader.load();
  }

  @override
  void didUpdateWidget(covariant PlayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentLoader != widget.contentLoader) {
      _contentFuture = widget.contentLoader.load();
    }
    if (oldWidget.premiumEntitlement != widget.premiumEntitlement) {
      _effectiveEntitlement =
          widget.premiumEntitlement ?? PremiumEntitlement.free();
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
              _PlayHeader(strings: widget.strings),
              const SizedBox(height: AppSpacing.lg),
              if (snapshot.connectionState != ConnectionState.done)
                LoadingCard(label: widget.strings.loadingPlayIdeas)
              else if (snapshot.hasError)
                EmptyState(
                  title: widget.strings.playIdeasCouldNotBeLoaded,
                  message: widget.strings.pleaseTryAgain,
                )
              else if (playIdeas == null || playIdeas.isEmpty)
                EmptyState(
                  title: widget.strings.noPlayIdeasTitle,
                  message: widget.strings.noPlayIdeasMessage,
                )
              else ...[
                _QuickFiltersModule(
                  strings: widget.strings,
                  expanded: _filtersExpanded,
                  accessFilters: _accessFilters(widget.strings),
                  filters: package?.playFilters ?? const <PlayFilter>[],
                  selectedFilterIds: _selectedFilterIds,
                  selectedAccessFilterIds: _selectedAccessFilterIds,
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
                  onToggleAccessFilter: (filterId) {
                    setState(() {
                      if (_selectedAccessFilterIds.contains(filterId)) {
                        _selectedAccessFilterIds.remove(filterId);
                      } else {
                        _selectedAccessFilterIds.add(filterId);
                      }
                    });
                  },
                  onClear: _selectedFilterIds.isEmpty
                      ? (_selectedAccessFilterIds.isEmpty
                          ? null
                          : () {
                              setState(() {
                                _selectedAccessFilterIds.clear();
                              });
                            })
                      : () {
                          setState(() {
                            _selectedFilterIds.clear();
                            _selectedAccessFilterIds.clear();
                          });
                        },
                  activeCountLabel: (_selectedFilterIds.isEmpty &&
                          _selectedAccessFilterIds.isEmpty)
                      ? null
                      : widget.strings.quickIdeasCount(
                          _applyQuickFilters(
                            playIdeas,
                            package?.playFilters ?? const <PlayFilter>[],
                            _selectedFilterIds,
                            _selectedAccessFilterIds,
                          ).length,
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._filteredPlayIdeaSection(
                  playIdeas,
                  package?.playFilters ?? const <PlayFilter>[],
                  package?.sounds ?? const <SoundItem>[],
                  package!.taxonomy,
                  widget.strings,
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
    AppStrings strings,
  ) {
    final filtered = _applyQuickFilters(
      playIdeas,
      filters,
      _selectedFilterIds,
      _selectedAccessFilterIds,
    );
    final isFiltered =
        _selectedFilterIds.isNotEmpty || _selectedAccessFilterIds.isNotEmpty;
    if (filtered.isEmpty) {
      return [
        EmptyState(
          title: strings.nothingHereYetTitle,
          message: strings.nothingHereYetMessage,
        ),
      ];
    }
    return [
      ..._playIdeaCards(
        filtered,
        sounds,
        taxonomy,
        strings,
        isFiltered: isFiltered,
      ),
    ];
  }

  List<PlayIdea> _applyQuickFilters(
    List<PlayIdea> ideas,
    List<PlayFilter> filters,
    Set<String> selectedFilterIds,
    Set<String> selectedAccessFilterIds,
  ) {
    if (selectedFilterIds.isEmpty && selectedAccessFilterIds.isEmpty) {
      return ideas;
    }
    final selectedFilters = filters
        .where((filter) => selectedFilterIds.contains(filter.id))
        .toList();
    return ideas
        .where((idea) =>
            _matchesAccessFilters(idea, selectedAccessFilterIds) &&
            (selectedFilters.isEmpty ||
                selectedFilters.every((filter) => filter.matches(idea))))
        .toList();
  }

  List<Widget> _playIdeaCards(List<PlayIdea> playIdeas, List<SoundItem> sounds,
      ContentTaxonomy taxonomy, AppStrings strings,
      {required bool isFiltered}) {
    final adPolicy = const AdInsertionPolicy();
    return [
      for (var index = 0; index < playIdeas.length; index++) ...[
        if (index > 0) const SizedBox(height: AppSpacing.md),
        _PlayIdeaCard(
          idea: playIdeas[index],
          taxonomy: taxonomy,
          strings: strings,
          onTap: () {
            if (_isPremiumUnlock(playIdeas[index].unlockType) &&
                !_effectiveEntitlement.canAccessPremiumContent) {
              widget.onOpenPremiumPaywall?.call();
              return;
            }
            final suggestedSound =
                resolveSuggestedSound(playIdeas[index], sounds);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PlayActivityDetailScreen(
                  idea: playIdeas[index],
                  taxonomy: taxonomy,
                  suggestedSound: suggestedSound,
                  strings: strings,
                ),
              ),
            );
          },
        ),
        if (widget.showAdPlaceholder &&
            _effectiveEntitlement.shouldShowAds &&
            adPolicy.shouldInsertAdAfterContentIndex(
              contentIndexOneBased: index + 1,
              totalVisibleItems: playIdeas.length,
              isFiltered: isFiltered,
            )) ...[
          const SizedBox(height: AppSpacing.md),
          widget.adWidgetFactory.buildPassiveSlot(strings: strings),
        ],
      ],
    ];
  }

  bool _isPremiumUnlock(String unlockType) {
    return unlockType.trim().toLowerCase() == 'premium';
  }

  bool _matchesAccessFilters(
    PlayIdea idea,
    Set<String> selectedAccessFilterIds,
  ) {
    if (selectedAccessFilterIds.isEmpty) {
      return true;
    }
    final unlockType = _displayUnlockTypeId(idea);
    final normalized = selectedAccessFilterIds
        .map((value) => value.trim().toLowerCase())
        .toSet();
    return normalized.contains(unlockType);
  }

  String _displayUnlockTypeId(PlayIdea idea) {
    final unlockType = idea.unlockType.trim().toLowerCase();
    if (unlockType == 'premium') {
      return 'access_premium';
    }
    return 'access_free';
  }

  List<_AccessFilterOption> _accessFilters(AppStrings strings) {
    return [
      _AccessFilterOption(id: 'access_free', label: strings.free),
      _AccessFilterOption(id: 'access_premium', label: strings.premium),
    ];
  }
}

class _QuickFiltersModule extends StatelessWidget {
  const _QuickFiltersModule({
    required this.strings,
    required this.expanded,
    required this.accessFilters,
    required this.filters,
    required this.selectedFilterIds,
    required this.selectedAccessFilterIds,
    required this.onToggleExpanded,
    required this.onToggleFilter,
    required this.onToggleAccessFilter,
    required this.onClear,
    required this.activeCountLabel,
  });

  final AppStrings strings;
  final bool expanded;
  final List<_AccessFilterOption> accessFilters;
  final List<PlayFilter> filters;
  final Set<String> selectedFilterIds;
  final Set<String> selectedAccessFilterIds;
  final VoidCallback onToggleExpanded;
  final ValueChanged<PlayFilter> onToggleFilter;
  final ValueChanged<String> onToggleAccessFilter;
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
                  strings.findTheRightFit,
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
                child: Text(strings.clearFilters, style: AppTextStyles.caption),
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
            key: const ValueKey('play-filter-chip-wrap'),
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final filter in accessFilters)
                _buildAccessFilterChip(filter),
              for (final filter in filters) _buildContentFilterChip(filter),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAccessFilterChip(_AccessFilterOption filter) {
    final selected = selectedAccessFilterIds.contains(filter.id);
    return Material(
      color: Colors.transparent,
      child: FilterChip(
        label: Text(filter.label),
        selected: selected,
        onSelected: (_) => onToggleAccessFilter(filter.id),
        selectedColor: AppColors.primarySoft,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.borderSoft),
        labelStyle: selected
            ? AppTextStyles.caption.copyWith(color: AppColors.primary)
            : AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildContentFilterChip(PlayFilter filter) {
    final selected = selectedFilterIds.contains(filter.id);
    return Material(
      color: Colors.transparent,
      child: FilterChip(
        label: Text(filter.label),
        selected: selected,
        onSelected: (_) => onToggleFilter(filter),
        selectedColor: AppColors.primarySoft,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.borderSoft),
        labelStyle: selected
            ? AppTextStyles.caption.copyWith(color: AppColors.primary)
            : AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        showCheckmark: false,
      ),
    );
  }
}

class _AccessFilterOption {
  const _AccessFilterOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

class _PlayHeader extends StatelessWidget {
  const _PlayHeader({required this.strings});

  final AppStrings strings;

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
                    strings.chooseGentlePlayIdea,
                    style: AppTextStyles.screenTitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    strings.playSubtitle,
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
    required this.strings,
    required this.onTap,
  });

  final PlayIdea idea;
  final ContentTaxonomy taxonomy;
  final AppStrings strings;
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
          _PlayIdeaMetadata(
            idea: idea,
            taxonomy: taxonomy,
            strings: strings,
          ),
        ],
      ),
    );
  }
}

class PlayActivityDetailScreen extends StatelessWidget {
  const PlayActivityDetailScreen({
    required this.idea,
    required this.taxonomy,
    required this.strings,
    this.suggestedSound,
    super.key,
  });

  final PlayIdea idea;
  final ContentTaxonomy taxonomy;
  final AppStrings strings;
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
              strings: strings,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (suggestedSound != null) ...[
              SuggestedSoundMiniPlayer(
                sound: suggestedSound!,
                strings: strings,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            _ExpectationSection(idea: idea, strings: strings),
            const SizedBox(height: AppSpacing.md),
            DetailSection(
              title: strings.whatYouNeed,
              children: [
                for (final item in idea.neededItems) _BulletText(item),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DetailSection(
              title: strings.steps,
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
              title: strings.parentNote,
              text: idea.parentNote,
            ),
            const SizedBox(height: AppSpacing.md),
            DetailNote(
              title: strings.safetyNote,
              text: idea.safetyNote,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBackButton extends StatelessWidget {
  const _DetailBackButton({required this.onPressed, required this.strings});

  final VoidCallback onPressed;
  final AppStrings strings;

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
          tooltip: strings.back,
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
    required this.strings,
    required this.onBackPressed,
  });

  final PlayIdea idea;
  final ContentTaxonomy taxonomy;
  final AppStrings strings;
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
            _DetailBackButton(onPressed: onBackPressed, strings: strings),
            const SizedBox(height: AppSpacing.sm),
            Text(idea.title, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(idea.summary, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            _PlayIdeaMetadata(
              idea: idea,
              taxonomy: taxonomy,
              strings: strings,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpectationSection extends StatelessWidget {
  const _ExpectationSection({
    required this.idea,
    required this.strings,
  });

  final PlayIdea idea;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return DetailSection(
      title: strings.whatToExpect,
      children: [
        Text(_expectationSummary(idea, strings), style: AppTextStyles.body),
      ],
    );
  }
}

String _expectationSummary(PlayIdea idea, AppStrings strings) {
  if (idea.whatToExpect.trim().isNotEmpty) {
    return idea.whatToExpect;
  }

  return strings.expectationFallback(
    messId: idea.messLevel,
    childId: idea.childEngagement,
    parentId: idea.parentInvolvement,
  );
}

class _PlayIdeaMetadata extends StatelessWidget {
  const _PlayIdeaMetadata({
    required this.idea,
    required this.taxonomy,
    required this.strings,
  });

  final PlayIdea idea;
  final ContentTaxonomy taxonomy;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: ValueKey('play-card-metadata-${idea.id}'),
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        NurtlyChip(label: idea.ageGroup),
        NurtlyChip(
          label: taxonomy.labelForPlace(idea.place),
        ),
        NurtlyChip(
          label: taxonomy.chipLabelForMessLevel(idea.messLevel),
        ),
        NurtlyChip(
          label: taxonomy.chipLabelForChildEngagement(
            idea.childEngagement,
          ),
        ),
        NurtlyChip(
          label: taxonomy.chipLabelForParentInvolvement(
            idea.parentInvolvement,
          ),
        ),
        NurtlyChip(
          label: taxonomy.labelForActivityType(idea.activityType),
        ),
        NurtlyChip(
          label: _displayUnlockType(idea, strings),
        ),
      ],
    );
  }
}

String _displayUnlockType(PlayIdea idea, AppStrings strings) {
  final unlockType = idea.unlockType.trim().toLowerCase();
  if (unlockType == 'premium') {
    return strings.premium;
  }
  return strings.free;
}

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

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
              else
                ..._playIdeaCards(playIdeas),
            ],
          );
        },
      ),
    );
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
        _ExpectationItem(expectation: _messExpectation(idea.messLevel)),
        _ExpectationItem(
          expectation: _childEnergyExpectation(idea.childEngagement),
        ),
        _ExpectationItem(
          expectation: _parentEffortExpectation(idea.parentInvolvement),
        ),
      ],
    );
  }
}

class _ExpectationItem extends StatelessWidget {
  const _ExpectationItem({required this.expectation});

  final _Expectation expectation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expectation.title, style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(expectation.body, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _Expectation {
  const _Expectation({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

_Expectation _messExpectation(String value) {
  return switch (value) {
    'Low' => const _Expectation(
        title: 'Low mess',
        body: 'Simple cleanup, no special setup.',
      ),
    'Medium' => const _Expectation(
        title: 'Medium mess',
        body: 'A little cleanup may help after the activity.',
      ),
    'High' => const _Expectation(
        title: 'High mess',
        body: 'Best for a moment when extra cleanup feels okay.',
      ),
    _ => _Expectation(
        title: '$value mess',
        body: 'Choose this when it feels like a good fit for your space.',
      ),
  };
}

_Expectation _childEnergyExpectation(String value) {
  return switch (value) {
    'Low' => const _Expectation(
        title: 'Low child energy',
        body: 'A quiet moment with gentle attention.',
      ),
    'Medium' => const _Expectation(
        title: 'Medium child energy',
        body: 'A little curiosity, movement, or conversation.',
      ),
    'High' => const _Expectation(
        title: 'High child energy',
        body: 'More active play when your child wants to move.',
      ),
    _ => _Expectation(
        title: '$value child energy',
        body: 'Choose this when it fits your child in the moment.',
      ),
  };
}

_Expectation _parentEffortExpectation(String value) {
  return switch (value) {
    'Low' => const _Expectation(
        title: 'Low parent effort',
        body: 'Stay nearby and gently guide when needed.',
      ),
    'Medium' => const _Expectation(
        title: 'Medium parent effort',
        body: 'Join in for a few moments and help shape the play.',
      ),
    'High' => const _Expectation(
        title: 'High parent effort',
        body: 'Best when you have energy to actively participate.',
      ),
    _ => _Expectation(
        title: '$value parent effort',
        body: 'Choose this when it fits the energy you have available.',
      ),
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

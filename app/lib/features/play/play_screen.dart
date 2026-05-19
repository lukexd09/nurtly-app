import 'package:flutter/material.dart';

import '../../core/content/content_loader.dart';
import '../../core/content/content_package.dart';
import '../../core/content/play_idea.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_note.dart';
import '../../core/widgets/detail_section.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/tappable_nurtly_card.dart';
import '../privacy/privacy_data_screen.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: SectionHeader(
            title: 'Play',
            subtitle: 'Simple screen-free ideas for calm, connected moments.',
          ),
        ),
        IconButton(
          tooltip: 'Privacy & Data',
          color: AppColors.primary,
          icon: const Icon(Icons.privacy_tip_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrivacyDataScreen(),
              ),
            );
          },
        ),
      ],
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
            Text(idea.title, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(idea.summary, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            _PlayIdeaMetadata(idea: idea),
            const SizedBox(height: AppSpacing.lg),
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
        NurtlyChip(label: idea.messLevel),
        NurtlyChip(label: 'Child: ${idea.childEngagement}'),
        NurtlyChip(label: 'Parent: ${idea.parentInvolvement}'),
        NurtlyChip(label: idea.activityType),
      ],
    );
  }
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

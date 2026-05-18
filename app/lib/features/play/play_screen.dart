import 'package:flutter/material.dart';

import '../../core/content/content_loader.dart';
import '../../core/content/play_idea.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/nurtly_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/section_header.dart';
import '../privacy/privacy_data_screen.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({
    super.key,
    this.contentLoader = const ContentLoader(),
  });

  final ContentLoader contentLoader;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: contentLoader.load(),
        builder: (context, snapshot) {
          final playIdeas = snapshot.data?.playIdeas;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const _PlayHeader(),
              const SizedBox(height: AppSpacing.lg),
              if (snapshot.connectionState != ConnectionState.done)
                const _LoadingState()
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
                for (final idea in playIdeas) ...[
                  _PlayIdeaCard(idea: idea),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ],
          );
        },
      ),
    );
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const NurtlyCard(
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: AppSpacing.md),
          Text('Loading play ideas...', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _PlayIdeaCard extends StatelessWidget {
  const _PlayIdeaCard({required this.idea});

  final PlayIdea idea;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(idea.title, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(idea.summary, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          Wrap(
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
          ),
        ],
      ),
    );
  }
}

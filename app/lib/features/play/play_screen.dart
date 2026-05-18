import 'package:flutter/material.dart';

import '../../core/content/content_loader.dart';
import '../../core/content/content_package.dart';
import '../../core/content/play_idea.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/nurtly_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/section_header.dart';
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
  const _PlayIdeaCard({
    required this.idea,
    required this.onTap,
  });

  final PlayIdea idea;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open ${idea.title}',
      child: Material(
        color: AppColors.surface,
        shadowColor: AppColors.textPrimary.withAlpha(10),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.borderSoft),
        ),
        child: InkWell(
          borderRadius: AppRadii.cardRadius,
          onTap: onTap,
          child: Padding(
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
          ),
        ),
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
            _DetailSection(
              title: "What you'll need",
              children: [
                for (final item in idea.neededItems) _BulletText(item),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailSection(
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
            _DetailNote(
              title: 'Parent note',
              text: idea.parentNote,
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailNote(
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

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.xs),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _DetailNote extends StatelessWidget {
  const _DetailNote({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return NurtlyCard(
      backgroundColor: AppColors.primarySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
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

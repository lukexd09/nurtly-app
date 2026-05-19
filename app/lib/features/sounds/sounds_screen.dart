import 'package:flutter/material.dart';

import '../../core/content/content_loader.dart';
import '../../core/content/content_package.dart';
import '../../core/content/sound_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/nurtly_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/section_header.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({
    super.key,
    this.contentLoader = const ContentLoader(),
  });

  final ContentLoader contentLoader;

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
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
          final sounds = snapshot.data?.sounds;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const SectionHeader(
                title: 'Sounds',
                subtitle: 'Choose a sound for a quiet moment.',
              ),
              const SizedBox(height: AppSpacing.lg),
              if (snapshot.connectionState != ConnectionState.done)
                const _LoadingState()
              else if (snapshot.hasError)
                const EmptyState(
                  title: 'Sounds could not be loaded.',
                  message: 'Please try again in a moment.',
                )
              else if (sounds == null || sounds.isEmpty)
                const EmptyState(
                  title: 'No sounds available yet.',
                  message: 'Quiet sound options will appear here later.',
                )
              else
                ..._soundCards(sounds),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _soundCards(List<SoundItem> sounds) {
    return [
      for (var index = 0; index < sounds.length; index++) ...[
        if (index > 0) const SizedBox(height: AppSpacing.md),
        _SoundCard(
          sound: sounds[index],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SoundDetailScreen(sound: sounds[index]),
              ),
            );
          },
        ),
      ],
    ];
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
          Text('Loading sounds...', style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.sound,
    required this.onTap,
  });

  final SoundItem sound;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open ${sound.title}',
      child: Material(
        color: AppColors.surface,
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
                Text(sound.title, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(sound.summary, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.md),
                _SoundMetadata(sound: sound),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SoundDetailScreen extends StatelessWidget {
  const SoundDetailScreen({
    required this.sound,
    super.key,
  });

  final SoundItem sound;

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
            Text(sound.title, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(sound.summary, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            _SoundMetadata(sound: sound),
            const SizedBox(height: AppSpacing.lg),
            const NurtlyCard(
              backgroundColor: AppColors.primarySoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Player placeholder', style: AppTextStyles.cardTitle),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Real sound playback will be added in a later task.',
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

class _SoundMetadata extends StatelessWidget {
  const _SoundMetadata({required this.sound});

  final SoundItem sound;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        NurtlyChip(label: sound.category),
        NurtlyChip(label: sound.unlockType),
      ],
    );
  }
}

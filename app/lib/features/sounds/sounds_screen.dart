import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/content/content_loader.dart';
import '../../core/content/content_package.dart';
import '../../core/content/sound_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_note.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/tappable_nurtly_card.dart';

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
                const LoadingCard(label: 'Loading sounds...')
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

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.sound,
    required this.onTap,
  });

  final SoundItem sound;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TappableNurtlyCard(
      semanticLabel: 'Open ${sound.title}',
      onTap: onTap,
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
    );
  }
}

class SoundDetailScreen extends StatefulWidget {
  const SoundDetailScreen({
    required this.sound,
    super.key,
  });

  final SoundItem sound;

  @override
  State<SoundDetailScreen> createState() => _SoundDetailScreenState();
}

class _SoundDetailScreenState extends State<SoundDetailScreen> {
  late final AudioPlayer _player;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setLoopMode(LoopMode.one);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading) {
      return;
    }

    if (_player.playing) {
      await _player.pause();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_player.audioSource == null) {
        await _player.setAsset(widget.sound.assetPath);
      }
      await _player.play();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Could not play this sound';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not play this sound')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _stop() async {
    await _player.stop();
  }

  String _statusText() {
    if (_errorMessage != null) {
      return _errorMessage!;
    }
    if (_isLoading) {
      return 'Loading';
    }
    if (_player.playing) {
      return 'Playing';
    }
    if (_player.processingState == ProcessingState.ready) {
      return 'Paused';
    }
    return 'Ready';
  }

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
            Text(widget.sound.title, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(widget.sound.summary, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            _SoundMetadata(sound: widget.sound),
            const SizedBox(height: AppSpacing.lg),
            DetailNote(
              title: 'Playback',
              text: _statusText(),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _togglePlayPause,
                    child: Text(_player.playing ? 'Pause' : 'Play'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _stop,
                    child: const Text('Stop'),
                  ),
                ),
              ],
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

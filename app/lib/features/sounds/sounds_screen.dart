import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/content/content_loader.dart';
import '../../core/content/content_package.dart';
import '../../core/content/sound_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
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
  late final StreamSubscription<PlayerState> _playerSubscription;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setLoopMode(LoopMode.one);
    _playerSubscription = _player.playerStateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _playerSubscription.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading) {
      return;
    }

    if (_player.playing) {
      await _player.pause();
      if (mounted) {
        setState(() {});
      }
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
    if (mounted) {
      setState(() {});
    }
  }

  String _statusText() {
    if (_errorMessage != null) {
      return 'COULD NOT PLAY';
    }
    if (_isLoading) {
      return 'LOADING';
    }
    if (_player.playing) {
      return 'NOW PLAYING';
    }
    if (_player.processingState == ProcessingState.ready) {
      return 'PAUSED';
    }
    return 'READY';
  }

  String _playPauseLabel() {
    if (_player.playing) {
      return 'Pause';
    }
    return 'Play';
  }

  Duration _safeDuration() {
    final value = _player.duration;
    if (value == null || value.inMilliseconds <= 0) {
      return Duration.zero;
    }
    return value;
  }

  String _formatTime(Duration value) {
    final seconds = value.inSeconds.clamp(0, 359999);
    final minutesPart = seconds ~/ 60;
    final secondsPart = seconds % 60;
    return '${minutesPart.toString()}:${secondsPart.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusBadge() {
    return Container(
      key: const ValueKey('sound-player-status'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusText(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildPlayerCard() {
    return Container(
      key: const ValueKey('sound-player-card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 148,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFE9F5ED), Color(0xFFF5F8F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 24,
                  left: 22,
                  child: _VisualDot(
                      color: AppColors.primary.withValues(alpha: 0.20)),
                ),
                Positioned(
                  right: 26,
                  bottom: 20,
                  child: _VisualDot(
                      color: AppColors.primary.withValues(alpha: 0.12)),
                ),
                const Center(
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    size: 46,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(widget.sound.title, style: AppTextStyles.screenTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.sound.summary, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          _SoundMetadata(sound: widget.sound),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return StreamBuilder<Duration>(
      stream: _player.positionStream,
      initialData: Duration.zero,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _safeDuration();
        final progress = duration == Duration.zero
            ? 0.0
            : (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);
        final durationLabel =
            duration == Duration.zero ? '--:--' : _formatTime(duration);

        return Column(
          key: const ValueKey('sound-player-progress'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.borderSoft,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(position), style: AppTextStyles.caption),
                Text(durationLabel, style: AppTextStyles.caption),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls() {
    return Column(
      key: const ValueKey('sound-player-controls'),
      children: [
        SizedBox(
          width: 86,
          height: 86,
          child: FilledButton(
            key: const ValueKey('sound-player-primary-control'),
            onLongPress: null,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
            onPressed: _togglePlayPause,
            child: Tooltip(
              message: _playPauseLabel(),
              child: Icon(
                _playPauseLabel() == 'Pause'
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 44,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: _stop,
          icon: const Icon(Icons.stop_rounded, size: 18),
          label: const Text('Stop'),
        ),
      ],
    );
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
            const SizedBox(height: AppSpacing.md),
            _buildStatusBadge(),
            const SizedBox(height: AppSpacing.lg),
            _buildPlayerCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildProgress(),
            const SizedBox(height: AppSpacing.lg),
            _buildControls(),
            const SizedBox(height: AppSpacing.lg),
            Container(
              key: const ValueKey('sound-player-safety-note'),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: const Text(
                'Keep volume comfortable and device away from child.',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualDot extends StatelessWidget {
  const _VisualDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/content/content_loader.dart';
import '../../core/content/content_package.dart';
import '../../core/content/sound_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
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
  late final StreamSubscription<PlayerState> _playerSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  double? _draggingProgress;

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

    if (_errorMessage != null && mounted) {
      setState(() {
        _errorMessage = null;
      });
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
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      unawaited(
        _player.play().catchError((Object _) async {
          await _player.pause();
          await _player.seek(Duration.zero);
          if (!mounted) {
            return;
          }
          setState(() {
            _errorMessage = 'Could not play';
            _isLoading = false;
            _draggingProgress = null;
          });
        }),
      );
    } catch (_) {
      await _player.pause();
      await _player.seek(Duration.zero);
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Could not play';
        _isLoading = false;
        _draggingProgress = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not play this sound.')),
      );
    }
  }

  Future<void> _stop() async {
    await _player.pause();
    await _player.seek(Duration.zero);
    if (mounted) {
      setState(() {
        _draggingProgress = null;
        _errorMessage = null;
      });
    }
  }

  String _statusText() {
    if (_errorMessage != null) {
      return 'Could not play';
    }
    if (_isLoading) {
      return 'Loading';
    }
    if (_player.playing) {
      return 'Playing';
    }
    if (_player.position == Duration.zero) {
      return 'Ready';
    }
    if (_player.processingState == ProcessingState.ready) {
      return 'Paused';
    }
    return 'Ready';
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 359999);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Duration _durationOrZero() {
    final duration = _player.duration;
    if (duration == null || duration.inMilliseconds <= 0) {
      return Duration.zero;
    }
    return duration;
  }

  Future<void> _seekToFraction(double value) async {
    final duration = _durationOrZero();
    if (duration == Duration.zero) {
      return;
    }
    final target = Duration(
      milliseconds: (duration.inMilliseconds * value).round(),
    );
    await _player.seek(target);
  }

  Widget _buildHeroCard() {
    return DecoratedBox(
      key: const ValueKey('sound-player-card'),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArtworkMoodPanel(),
            const SizedBox(height: AppSpacing.lg),
            Text(widget.sound.title, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(widget.sound.summary, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.sm),
            _SoundMetadata(
              sound: widget.sound,
              showUnlockType: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtworkMoodPanel() {
    return Container(
      key: const ValueKey('sound-player-artwork'),
      height: 124,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3F8F4),
            Color(0xFFE9F3EC),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 8,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 10,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.waves_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.panelRadius,
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Playback', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _statusText(),
              key: const ValueKey('sound-player-status'),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildProgressControl(),
            const SizedBox(height: AppSpacing.lg),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressControl() {
    return StreamBuilder<Duration>(
      stream: _player.positionStream,
      initialData: Duration.zero,
      builder: (context, snapshot) {
        final duration = _durationOrZero();
        final position = _draggingProgress != null
            ? Duration(
                milliseconds:
                    (duration.inMilliseconds * _draggingProgress!).round(),
              )
            : snapshot.data ?? Duration.zero;
        final canSeek = duration != Duration.zero;
        final value = canSeek
            ? (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;
        final durationLabel = canSeek ? _formatDuration(duration) : '--:--';

        return Column(
          key: const ValueKey('sound-player-progress'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                  disabledThumbRadius: 8,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 18,
                ),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.borderSoft,
                thumbColor: AppColors.primary,
                disabledActiveTrackColor: AppColors.borderSoft,
                disabledInactiveTrackColor: AppColors.borderSoft,
              ),
              child: Slider(
                value: value,
                onChanged: canSeek
                    ? (value) {
                        setState(() {
                          _draggingProgress = value;
                        });
                      }
                    : null,
                onChangeEnd: canSeek
                    ? (value) async {
                        await _seekToFraction(value);
                        if (mounted) {
                          setState(() {
                            _draggingProgress = null;
                          });
                        }
                      }
                    : null,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position), style: AppTextStyles.caption),
                Text(durationLabel, style: AppTextStyles.caption),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls() {
    final isPlaying = _player.playing;
    return Row(
      key: const ValueKey('sound-player-controls'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 40),
        SizedBox(
          width: 86,
          height: 86,
          child: FilledButton(
            key: const ValueKey('sound-player-primary-control'),
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
            onPressed: _togglePlayPause,
            child: Tooltip(
              message: isPlaying ? 'Pause' : 'Play',
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 44,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        TextButton(
          key: const ValueKey('sound-player-stop-control'),
          onPressed: _stop,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(40, 40),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Tooltip(
            message: 'Stop',
            child: Icon(Icons.stop_rounded, size: 18),
          ),
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
            _buildHeroCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildPlaybackCard(),
            const SizedBox(height: AppSpacing.lg),
            const DetailNote(
              key: ValueKey('sound-player-safety-note'),
              title: 'Safety note',
              text: 'Keep volume comfortable and device away from child.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundMetadata extends StatelessWidget {
  const _SoundMetadata({
    required this.sound,
    this.showUnlockType = true,
  });

  final SoundItem sound;
  final bool showUnlockType;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        NurtlyChip(label: sound.category),
        if (showUnlockType) NurtlyChip(label: sound.unlockType),
      ],
    );
  }
}

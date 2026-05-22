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
  static const int _loopPlaylistCopies = 3;
  static const double _normalVolume = 1;
  late final AudioPlayer _player;
  late final StreamSubscription<PlayerState> _playerSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  double? _draggingProgress;
  Timer? _sessionTimer;
  Duration? _selectedSessionDuration;
  Duration? _remainingSessionDuration;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _playerSubscription = _player.playerStateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _cancelSessionTimer();
    unawaited(_restoreVolume());
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
      _pauseSessionTimer();
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
        await _loadGaplessLoopPlaylist();
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      unawaited(
        _player.play().then((_) {}).catchError((Object _) async {
          _cancelSessionTimer();
          await _restoreVolume();
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
      _startSessionTimerIfNeeded();
    } catch (_) {
      _cancelSessionTimer();
      await _restoreVolume();
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

  Future<void> _loadGaplessLoopPlaylist() async {
    // Use repeated identical sources to spike a smoother loop boundary than
    // single-source LoopMode.one, which has shown an audible gap on devices.
    await _player.setAudioSources(
      List<AudioSource>.generate(
        _loopPlaylistCopies,
        (_) => AudioSource.asset(widget.sound.assetPath),
      ),
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
    await _player.setLoopMode(LoopMode.all);
  }

  void _selectSessionDuration(Duration? duration) {
    _cancelSessionTimer();
    _selectedSessionDuration = duration;
    _remainingSessionDuration = duration;
    unawaited(_restoreVolume());
    if (_player.playing) {
      _startSessionTimerIfNeeded();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _startSessionTimerIfNeeded() {
    final selectedDuration = _selectedSessionDuration;
    if (selectedDuration == null) {
      return;
    }
    _cancelSessionTimer();
    if (_remainingSessionDuration == null ||
        _remainingSessionDuration! <= Duration.zero) {
      _remainingSessionDuration = selectedDuration;
    }
    _updateFadeVolume();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final remaining = _remainingSessionDuration;
      if (remaining == null) {
        _cancelSessionTimer();
        return;
      }
      final nextRemaining = remaining - const Duration(seconds: 1);
      if (nextRemaining <= Duration.zero) {
        _remainingSessionDuration = selectedDuration;
        _cancelSessionTimer();
        await _player.pause();
        await _restoreVolume();
        if (mounted) {
          setState(() {});
        }
        return;
      }
      _remainingSessionDuration = nextRemaining;
      await _updateFadeVolume();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _pauseSessionTimer() {
    _cancelSessionTimer();
    unawaited(_restoreVolume());
  }

  void _cancelSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  Future<void> _updateFadeVolume() async {
    final selectedDuration = _selectedSessionDuration;
    final remaining = _remainingSessionDuration;
    if (selectedDuration == null || remaining == null) {
      await _restoreVolume();
      return;
    }
    final fadeSeconds = _fadeWindow(selectedDuration).inSeconds;
    if (fadeSeconds <= 0 || remaining.inSeconds > fadeSeconds) {
      await _restoreVolume();
      return;
    }
    final volume = (remaining.inMilliseconds /
            Duration(seconds: fadeSeconds).inMilliseconds)
        .clamp(0.0, _normalVolume);
    await _player.setVolume(volume);
  }

  Future<void> _restoreVolume() async {
    await _player.setVolume(_normalVolume);
  }

  Duration _fadeWindow(Duration duration) {
    final tenPercentSeconds = (duration.inSeconds * 0.1).round();
    final fadeSeconds = tenPercentSeconds.clamp(1, 30);
    return Duration(seconds: fadeSeconds);
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

  String _sessionLabel() {
    final selected = _selectedSessionDuration;
    if (selected == null) {
      return 'Continuous play';
    }
    final remaining = _remainingSessionDuration ?? selected;
    return '${_formatDuration(remaining)} left';
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

  Widget _buildPlayerPanel() {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildArtworkMoodPanel(),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.sound.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.sound.summary,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            _SoundMetadata(
              sound: widget.sound,
              showUnlockType: false,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _statusText(),
              key: const ValueKey('sound-player-status'),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildProgressControl(),
            const SizedBox(height: AppSpacing.sm),
            _buildSessionOptions(),
            const SizedBox(height: AppSpacing.xs),
            _buildAutoFadeIndicator(),
            const SizedBox(height: AppSpacing.sm),
            _buildControls(),
            const SizedBox(height: AppSpacing.sm),
            _buildSafetyNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildArtworkMoodPanel() {
    return Container(
      key: const ValueKey('sound-player-artwork'),
      height: 146,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            top: 12,
            right: 16,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 18,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceBright, width: 5),
              ),
              child: const Icon(
                Icons.waves_rounded,
                color: AppColors.primary,
                size: 38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionOptions() {
    return Column(
      key: const ValueKey('sound-player-session-options'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            _sessionLabel(),
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            borderRadius: AppRadii.chipRadius,
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              _SessionSegment(
                label: '15',
                selected:
                    _selectedSessionDuration == const Duration(minutes: 15),
                onSelected: () =>
                    _selectSessionDuration(const Duration(minutes: 15)),
              ),
              _SessionSegment(
                label: '30',
                selected:
                    _selectedSessionDuration == const Duration(minutes: 30),
                onSelected: () =>
                    _selectSessionDuration(const Duration(minutes: 30)),
              ),
              _SessionSegment(
                label: '60',
                selected:
                    _selectedSessionDuration == const Duration(minutes: 60),
                onSelected: () =>
                    _selectSessionDuration(const Duration(minutes: 60)),
              ),
              _SessionSegment(
                label: '\u221E',
                selected: _selectedSessionDuration == null,
                onSelected: () => _selectSessionDuration(null),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAutoFadeIndicator() {
    final finiteTimerSelected = _selectedSessionDuration != null;
    return Row(
      key: const ValueKey('sound-player-auto-fade'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.spa_outlined,
          size: 14,
          color: finiteTimerSelected ? AppColors.primary : AppColors.textMuted,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          finiteTimerSelected
              ? 'Auto-fade enabled'
              : 'Auto-fade available with timer',
          style: AppTextStyles.caption.copyWith(
            color:
                finiteTimerSelected ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyNote() {
    return Row(
      key: const ValueKey('sound-player-safety-note'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.volume_down_outlined,
          size: 14,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Keep volume comfortable and device away from child.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              height: 1.2,
            ),
          ),
        ),
      ],
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
    return Padding(
      key: const ValueKey('sound-player-controls'),
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: SizedBox(
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
              child: Material(
                color: AppColors.surface,
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.borderSoft),
                ),
                child: IconButton(
                  key: const ValueKey('sound-detail-back-button'),
                  tooltip: 'Back',
                  color: AppColors.primary,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPlayerPanel(),
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

class _SessionSegment extends StatelessWidget {
  const _SessionSegment({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onSelected,
        borderRadius: AppRadii.chipRadius,
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.transparent,
            borderRadius: AppRadii.chipRadius,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

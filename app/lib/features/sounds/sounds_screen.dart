import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/ads/ad_widget_factory.dart';
import '../../core/content/content_loader.dart';
import '../../core/content/content_package.dart';
import '../../core/content/sound_item.dart';
import '../../core/localization/app_strings.dart';
import '../../core/monetization/ad_insertion_policy.dart';
import '../../core/monetization/premium_entitlement.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_card.dart';
import '../../core/widgets/nurtly_chip.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/tappable_nurtly_card.dart';
import 'widgets/sound_artwork.dart';
import 'audio/looping_sound_loader.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({
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
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  late Future<ContentPackage> _contentFuture;
  late PremiumEntitlement _effectiveEntitlement;

  @override
  void initState() {
    super.initState();
    _effectiveEntitlement =
        widget.premiumEntitlement ?? PremiumEntitlement.free();
    _contentFuture = widget.contentLoader.load();
  }

  @override
  void didUpdateWidget(covariant SoundsScreen oldWidget) {
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
          final sounds = snapshot.data?.sounds;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              SectionHeader(
                title: widget.strings.soundsTitle,
                subtitle: widget.strings.soundsSubtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (snapshot.connectionState != ConnectionState.done)
                LoadingCard(label: widget.strings.loadingSounds)
              else if (snapshot.hasError)
                EmptyState(
                  title: widget.strings.soundsCouldNotBeLoaded,
                  message: widget.strings.pleaseTryAgain,
                )
              else if (sounds == null || sounds.isEmpty)
                EmptyState(
                  title: widget.strings.noSoundsTitle,
                  message: widget.strings.noSoundsMessage,
                )
              else ...[
                ..._soundCards(sounds),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _soundCards(List<SoundItem> sounds) {
    final adPolicy = const AdInsertionPolicy();
    return [
      for (var index = 0; index < sounds.length; index++) ...[
        if (index > 0) const SizedBox(height: AppSpacing.md),
        _SoundCard(
          sound: sounds[index],
          strings: widget.strings,
          isPremium: _isPremiumUnlock(sounds[index].unlockType),
          onTap: () {
            if (_isPremiumUnlock(sounds[index].unlockType) &&
                !_effectiveEntitlement.canAccessPremiumContent) {
              widget.onOpenPremiumPaywall?.call();
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SoundDetailScreen(
                  sound: sounds[index],
                  strings: widget.strings,
                ),
              ),
            );
          },
        ),
        if (widget.showAdPlaceholder &&
            _effectiveEntitlement.shouldShowAds &&
            adPolicy.shouldInsertAdAfterContentIndex(
              contentIndexOneBased: index + 1,
              totalVisibleItems: sounds.length,
              isFiltered: false,
            )) ...[
          const SizedBox(height: AppSpacing.md),
          widget.adWidgetFactory.buildPassiveSlot(strings: widget.strings),
        ],
      ],
    ];
  }

  bool _isPremiumUnlock(String unlockType) {
    return unlockType.trim().toLowerCase() == 'premium';
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.sound,
    required this.strings,
    required this.isPremium,
    required this.onTap,
  });

  final SoundItem sound;
  final AppStrings strings;
  final bool isPremium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TappableNurtlyCard(
      semanticLabel: 'Open ${sound.title}',
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(sound.title, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  sound.summary,
                  style: AppTextStyles.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SoundMetadata(
                  sound: sound,
                  strings: strings,
                  showUnlockType: !isPremium,
                ),
                if (isPremium) ...[
                  const SizedBox(height: AppSpacing.xs),
                  NurtlyChip(label: strings.premium),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SoundArtwork(
            sound: sound,
            variant: SoundArtworkVariant.card,
            valueKey: ValueKey('sound-card-artwork-${sound.id}'),
          ),
        ],
      ),
    );
  }
}

class SoundDetailScreen extends StatefulWidget {
  const SoundDetailScreen({
    required this.sound,
    required this.strings,
    super.key,
    this.loadSoundAsset = loadLoopingSoundAsset,
    this.startPlayback,
    this.playbackHarness,
  });

  final SoundItem sound;
  final AppStrings strings;
  final Future<void> Function(AudioPlayer player, String assetPath)
      loadSoundAsset;
  final Future<void> Function(AudioPlayer player)? startPlayback;
  final SoundPlaybackHarness? playbackHarness;

  @override
  State<SoundDetailScreen> createState() => _SoundDetailScreenState();
}

class _SoundDetailScreenState extends State<SoundDetailScreen> {
  static const double _normalVolume = 1;
  static const Duration _playbackStartTimeout = Duration(seconds: 5);
  late final AudioPlayer _player;
  late final StreamSubscription<PlayerState> _playerSubscription;
  StreamSubscription<PlayerState>? _harnessPlayerSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<PlaybackEvent>? _playerPlaybackEventSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  double? _draggingProgress;
  Timer? _sessionTimer;
  Duration? _selectedSessionDuration;
  Duration? _remainingSessionDuration;
  int _attemptGeneration = 0;
  Completer<void>? _activeStartCompleter;
  bool _playbackStartConfirmed = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _playerSubscription = _player.playerStateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _harnessPlayerSubscription =
        widget.playbackHarness?.playerStateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
    widget.playbackHarness?.onErrorRequested = (error, stackTrace) async {
      if (mounted) {
        unawaited(_handlePlaybackError(error, stackTrace));
      }
    };
  }

  @override
  void dispose() {
    _cancelSessionTimer();
    _cancelStartListeners();
    unawaited(_restoreVolume());
    _harnessPlayerSubscription?.cancel();
    _playerSubscription.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading && !_isPlaying) {
      return;
    }

    if (_errorMessage != null && mounted) {
      setState(() {
        _errorMessage = null;
      });
    }

    if (_isPlaying) {
      _cancelStartListeners();
      if (widget.playbackHarness != null) {
        await widget.playbackHarness!.requestPause(
          fallback: () => _player.pause(),
        );
      } else {
        await _player.pause();
      }
      _pauseSessionTimer();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_player.audioSource == null) {
        await _loadSoundAsset();
      }
      if (!mounted) {
        return;
      }
      unawaited(_beginPlaybackAttempt());
    } catch (error, stackTrace) {
      await _handlePlaybackError(error, stackTrace);
    }
  }

  Future<void> _loadSoundAsset() async {
    await widget.loadSoundAsset(_player, widget.sound.assetPath);
  }

  Future<void> _startPlayback() async {
    final harness = widget.playbackHarness;
    if (harness != null) {
      await harness.requestStart(
        fallback: widget.startPlayback == null
            ? null
            : () => widget.startPlayback!(_player),
      );
      return;
    }
    final starter = widget.startPlayback ?? (player) => player.play();
    await starter(_player);
  }

  Future<void> _handlePlaybackError(Object error, StackTrace stackTrace) async {
    _cancelStartListeners();
    _cancelSessionTimer();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _draggingProgress = null;
      });
    }
    try {
      await _restoreVolume();
      if (widget.playbackHarness == null) {
        await _player.pause();
        await _player.seek(Duration.zero);
      }
    } catch (cleanupError, cleanupStackTrace) {
      _logPlaybackError(cleanupError, cleanupStackTrace);
    }
    _logPlaybackError(error, stackTrace);
    if (!mounted) {
      return;
    }
    setState(() {
      _errorMessage = widget.strings.couldNotPlay;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.strings.couldNotPlaySound)),
    );
  }

  Future<void> _beginPlaybackAttempt() async {
    _attemptGeneration++;
    final generation = _attemptGeneration;
    _playbackStartConfirmed = false;
    _activeStartCompleter = Completer<void>();
    _playerStateSubscription?.cancel();
    _playerPlaybackEventSubscription?.cancel();
    _playerStateSubscription = _playerStateStream.listen((playerState) {
      _handlePlayerStateUpdate(generation, playerState);
    });
    _playerPlaybackEventSubscription = _playbackEventStream.listen(
      (_) => _handlePlaybackEvent(generation),
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted || generation != _attemptGeneration) {
          return;
        }
        unawaited(_handlePlaybackError(error, stackTrace));
      },
    );

    unawaited(_startPlayback().catchError((error, stackTrace) {
      if (!mounted || generation != _attemptGeneration) {
        return;
      }
      if (!_playbackStartConfirmed) {
        unawaited(_handlePlaybackError(error, stackTrace));
      }
    }));
    _maybeMarkPlaybackStarted(generation);

    try {
      await _activeStartCompleter!.future.timeout(_playbackStartTimeout);
    } on TimeoutException catch (error, stackTrace) {
      if (!mounted || generation != _attemptGeneration) {
        return;
      }
      await _handlePlaybackError(error, stackTrace);
    }
  }

  void _handlePlayerStateUpdate(int generation, PlayerState state) {
    if (!mounted || generation != _attemptGeneration) {
      return;
    }
    _maybeMarkPlaybackStarted(generation, state);
  }

  void _handlePlaybackEvent(int generation) {
    if (!mounted || generation != _attemptGeneration) {
      return;
    }
    _maybeMarkPlaybackStarted(generation);
  }

  void _maybeMarkPlaybackStarted(int generation, [PlayerState? state]) {
    if (generation != _attemptGeneration || !mounted) {
      return;
    }
    final currentState = state ?? _currentPlayerState;
    final started = currentState.playing &&
        currentState.processingState == ProcessingState.ready;
    if (!started) {
      return;
    }
    if (_playbackStartConfirmed) {
      return;
    }
    _playbackStartConfirmed = true;
    _cancelStartListeners();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    _startSessionTimerIfNeeded();
    if (!(_activeStartCompleter?.isCompleted ?? true)) {
      _activeStartCompleter?.complete();
    }
  }

  void _cancelStartListeners() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    _playerPlaybackEventSubscription?.cancel();
    _playerPlaybackEventSubscription = null;
    if (!(_activeStartCompleter?.isCompleted ?? true)) {
      _activeStartCompleter?.complete();
    }
    _activeStartCompleter = null;
  }

  void _selectSessionDuration(Duration? duration) {
    _cancelSessionTimer();
    _selectedSessionDuration = duration;
    _remainingSessionDuration = duration;
    unawaited(_restoreVolume());
    if (_isPlaying) {
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

  void _logPlaybackError(Object error, StackTrace stackTrace) {
    final playerException = error is PlayerException ? error : null;
    final releaseSafeMessage = [
      '[sounds] playback error',
      'type=${error.runtimeType}',
      if (playerException != null) 'code=${playerException.code}',
      if (playerException != null) 'message=${playerException.message}',
      if (playerException != null) 'index=${playerException.index}',
      'currentIndex=$_currentIndex',
      'assetPath=${widget.sound.assetPath}',
    ].join(' | ');
    if (kDebugMode) {
      developer.log(
        '$releaseSafeMessage | stackTrace=$stackTrace | error=$error',
        name: 'nurtly.sounds',
      );
      return;
    }
    developer.log(releaseSafeMessage, name: 'nurtly.sounds');
  }

  Duration _fadeWindow(Duration duration) {
    final tenPercentSeconds = (duration.inSeconds * 0.1).round();
    final fadeSeconds = tenPercentSeconds.clamp(1, 30);
    return Duration(seconds: fadeSeconds);
  }

  String _statusText() {
    if (_errorMessage != null) {
      return widget.strings.couldNotPlay;
    }
    if (_isLoading) {
      return widget.strings.loading;
    }
    if (_isPlaying) {
      return widget.strings.playing;
    }
    if (_currentPlayerState.processingState == ProcessingState.ready) {
      return widget.strings.paused;
    }
    return widget.strings.ready;
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 359999);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String? _sessionLabel() {
    final selected = _selectedSessionDuration;
    if (selected == null) {
      return null;
    }
    final remaining = _remainingSessionDuration ?? selected;
    return '${_formatDuration(remaining)} ${widget.strings.left}';
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
            Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: AppColors.surface,
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.borderSoft),
                ),
                child: IconButton(
                  key: const ValueKey('sound-detail-back-button'),
                  tooltip: widget.strings.back,
                  color: AppColors.primary,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            _buildArtworkMoodPanel(),
            const SizedBox(height: 4),
            Text(
              widget.sound.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle,
            ),
            const SizedBox(height: 2),
            Text(
              widget.sound.summary,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 2),
            _SoundMetadata(
              sound: widget.sound,
              strings: widget.strings,
              showUnlockType: false,
            ),
            const SizedBox(height: 4),
            Text(
              _statusText(),
              key: const ValueKey('sound-player-status'),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            _buildProgressControl(),
            const SizedBox(height: 4),
            _buildSessionOptions(),
            const SizedBox(height: 2),
            _buildAutoFadeIndicator(),
            const SizedBox(height: 4),
            _buildControls(),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildSafetyNote(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtworkMoodPanel() {
    return SoundArtwork(
      sound: widget.sound,
      variant: SoundArtworkVariant.detail,
      valueKey: const ValueKey('sound-player-artwork'),
    );
  }

  Widget _buildSessionOptions() {
    final sessionLabel = _sessionLabel();
    return Column(
      key: const ValueKey('sound-player-session-options'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sessionLabel != null)
          Center(
            child: Text(
              sessionLabel,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        if (sessionLabel != null) const SizedBox(height: AppSpacing.xs),
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
                key: const ValueKey('sound-player-timer-infinity'),
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
              ? widget.strings.autoFadeEnabled
              : widget.strings.autoFadeAvailableWithTimer,
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
            widget.strings.soundSafetyNote,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              height: 1.1,
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
    final isPlaying = _isPlaying;
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
            message: isPlaying ? widget.strings.pause : widget.strings.play,
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
            _buildPlayerPanel(),
          ],
        ),
      ),
    );
  }

  bool get _isPlaying => widget.playbackHarness?.playing ?? _player.playing;

  int? get _currentIndex =>
      widget.playbackHarness?.currentIndex ?? _player.currentIndex;

  PlayerState get _currentPlayerState =>
      widget.playbackHarness?.playerState ?? _player.playerState;

  Stream<PlayerState> get _playerStateStream =>
      widget.playbackHarness?.playerStateStream ?? _player.playerStateStream;

  Stream<PlaybackEvent> get _playbackEventStream =>
      widget.playbackHarness?.playbackEventStream ??
      _player.playbackEventStream;
}

class SoundPlaybackHarness {
  SoundPlaybackHarness({
    PlayerState? initialState,
    this.currentIndex,
  }) : _playerState = initialState ?? PlayerState(false, ProcessingState.idle);

  final StreamController<PlayerState> _playerStateController =
      StreamController<PlayerState>.broadcast();
  final StreamController<PlaybackEvent> _playbackEventController =
      StreamController<PlaybackEvent>.broadcast();
  PlayerState _playerState;
  Future<void> Function()? onStartRequested;
  Future<void> Function()? onPauseRequested;
  int startAttempts = 0;
  int pauseCalls = 0;

  int? currentIndex;

  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<PlaybackEvent> get playbackEventStream =>
      _playbackEventController.stream;
  PlayerState get playerState => _playerState;
  bool get playing => _playerState.playing;

  Future<void> requestStart({Future<void> Function()? fallback}) async {
    startAttempts++;
    if (onStartRequested != null) {
      await onStartRequested!();
      return;
    }
    if (fallback != null) {
      await fallback();
    }
  }

  Future<void> requestPause({Future<void> Function()? fallback}) async {
    pauseCalls++;
    if (onPauseRequested != null) {
      await onPauseRequested!();
      return;
    }
    if (fallback != null) {
      await fallback();
    }
  }

  void updateState({
    bool? playing,
    ProcessingState? processingState,
    int? currentIndex,
  }) {
    _playerState = PlayerState(
      playing ?? _playerState.playing,
      processingState ?? _playerState.processingState,
    );
    this.currentIndex = currentIndex ?? this.currentIndex;
    _playerStateController.add(_playerState);
    _playbackEventController.add(
      PlaybackEvent(
        currentIndex: this.currentIndex,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
        duration: Duration.zero,
      ),
    );
  }

  void markReadyPlaying({int? currentIndex}) {
    updateState(
      playing: true,
      processingState: ProcessingState.ready,
      currentIndex: currentIndex,
    );
  }

  void markReadyPaused({int? currentIndex}) {
    updateState(
      playing: false,
      processingState: ProcessingState.ready,
      currentIndex: currentIndex,
    );
  }

  void markIdlePaused({int? currentIndex}) {
    updateState(
      playing: false,
      processingState: ProcessingState.idle,
      currentIndex: currentIndex,
    );
  }

  void emitError(Object error) {
    if (onErrorRequested != null) {
      onErrorRequested!(error, StackTrace.current);
    }
    _playbackEventController.addError(error);
  }

  Future<void> Function(Object error, StackTrace stackTrace)? onErrorRequested;

  Future<void> dispose() async {
    await _playerStateController.close();
    await _playbackEventController.close();
  }
}

class _SoundMetadata extends StatelessWidget {
  const _SoundMetadata({
    required this.sound,
    required this.strings,
    this.showUnlockType = true,
  });

  final SoundItem sound;
  final AppStrings strings;
  final bool showUnlockType;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        NurtlyChip(label: sound.category),
        if (showUnlockType) NurtlyChip(label: _displayUnlockType(sound)),
      ],
    );
  }

  String _displayUnlockType(SoundItem sound) {
    if (sound.unlockType.toLowerCase() == 'free') {
      return strings.free;
    }
    return strings.premium;
  }
}

class _SessionSegment extends StatelessWidget {
  const _SessionSegment({
    super.key,
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
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.transparent,
            borderRadius: AppRadii.chipRadius,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

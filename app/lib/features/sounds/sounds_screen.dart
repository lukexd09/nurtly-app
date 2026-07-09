import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_soloud/flutter_soloud.dart' as soloud;

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
import 'audio/bundled_sound_file_cache.dart';
import 'audio/looping_sound_loader.dart';

const bool _useSoloudSounds = bool.fromEnvironment('NURTLY_USE_SOLOUD_SOUNDS');

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
    this.playbackDriver,
    this.sessionTicker,
  });

  final SoundItem sound;
  final AppStrings strings;
  final SoundPlaybackDriver? playbackDriver;
  final SoundSessionTicker? sessionTicker;

  @override
  State<SoundDetailScreen> createState() => _SoundDetailScreenState();
}

class _SoundDetailScreenState extends State<SoundDetailScreen> {
  static const double _normalVolume = 1;
  static const Duration _playbackStartTimeout = Duration(seconds: 5);
  StreamSubscription<SoundPlaybackState>? _driverStateSubscription;
  late final StreamSubscription<Object> _runtimeErrorSubscription;
  StreamSubscription<SoundPlaybackState>? _playerStateSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  double? _draggingProgress;
  Duration? _selectedSessionDuration;
  Duration? _remainingSessionDuration;
  int _attemptGeneration = 0;
  Completer<void>? _activeStartCompleter;
  Timer? _startTimeoutTimer;
  bool _playbackStartConfirmed = false;
  bool _attemptErrorHandled = false;
  late final SoundPlaybackDriver _playbackDriver;
  late final SoundSessionTicker _sessionTicker;
  StreamSubscription<Duration>? _positionSubscription;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _playbackDriver = widget.playbackDriver ??
        (_useSoloudSounds && defaultTargetPlatform == TargetPlatform.android
            ? SoLoudSoundPlaybackDriver()
            : JustAudioSoundPlaybackDriver(AudioPlayer()));
    _sessionTicker = widget.sessionTicker ?? TimerSoundSessionTicker();
    _driverStateSubscription = _playbackDriver.playerStateStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _runtimeErrorSubscription = _playbackDriver.errorStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        unawaited(_handlePlaybackError(error, stackTrace));
      },
    );
    _positionSubscription = _playbackDriver.positionStream.listen((position) {
      _currentPosition = position;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _cancelSessionTimer();
    _cancelStartTimeout();
    _invalidatePendingAttempt();
    unawaited(_restoreVolume());
    _driverStateSubscription?.cancel();
    _runtimeErrorSubscription.cancel();
    _positionSubscription?.cancel();
    _sessionTicker.dispose();
    _playbackDriver.dispose();
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
      _invalidatePendingAttempt();
      await _playbackDriver.pause();
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
      if (!_playbackDriver.isLoaded) {
        await _playbackDriver.load(widget.sound.assetPath);
      }
      if (!mounted) {
        return;
      }
      unawaited(_beginPlaybackAttempt());
    } catch (error, stackTrace) {
      await _handlePlaybackError(error, stackTrace);
    }
  }

  Future<void> _startPlayback() async {
    await _playbackDriver.play();
  }

  Future<void> _handlePlaybackError(
    Object error,
    StackTrace stackTrace, {
    int? generation,
  }) async {
    final activeGeneration = generation ?? _attemptGeneration;
    if (activeGeneration != _attemptGeneration || _attemptErrorHandled) {
      return;
    }
    _invalidatePendingAttempt();
    _attemptErrorHandled = true;
    _cancelSessionTimer();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _draggingProgress = null;
      });
    }
    try {
      await _restoreVolume();
      await _playbackDriver.pause();
      await _playbackDriver.seek(Duration.zero);
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
    final generation = ++_attemptGeneration;
    _playbackStartConfirmed = false;
    _attemptErrorHandled = false;
    final startCompleter = Completer<void>();
    _activeStartCompleter = startCompleter;
    _cancelStartTimeout();
    _startTimeoutTimer = Timer(_playbackStartTimeout, () {
      if (!mounted || generation != _attemptGeneration) {
        return;
      }
      unawaited(
        _handlePlaybackError(
          TimeoutException('Playback start timed out'),
          StackTrace.current,
          generation: generation,
        ),
      );
    });
    _playerStateSubscription?.cancel();
    _playerStateSubscription = _playerStateStream.listen((playerState) {
      _handlePlayerStateUpdate(generation, playerState);
    });
    unawaited(_startPlayback().catchError((error, stackTrace) {
      if (!mounted ||
          generation != _attemptGeneration ||
          _attemptErrorHandled) {
        return;
      }
      unawaited(
          _handlePlaybackError(error, stackTrace, generation: generation));
    }));
    _maybeMarkPlaybackStarted(generation);
  }

  void _handlePlayerStateUpdate(int generation, SoundPlaybackState state) {
    if (!mounted || generation != _attemptGeneration) {
      return;
    }
    _maybeMarkPlaybackStarted(generation, state);
  }

  void _maybeMarkPlaybackStarted(int generation, [SoundPlaybackState? state]) {
    if (generation != _attemptGeneration || !mounted) {
      return;
    }
    final currentState = state ?? _currentPlayerState;
    final started = currentState.playing && currentState.ready;
    if (!started) {
      return;
    }
    if (_playbackStartConfirmed) {
      return;
    }
    _playbackStartConfirmed = true;
    _cancelStartTimeout();
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
    _completeActiveStart();
  }

  void _invalidatePendingAttempt() {
    _attemptGeneration++;
    _cancelStartListeners();
  }

  void _completeActiveStart() {
    if (!(_activeStartCompleter?.isCompleted ?? true)) {
      _activeStartCompleter?.complete();
    }
    _activeStartCompleter = null;
  }

  void _cancelStartTimeout() {
    _startTimeoutTimer?.cancel();
    _startTimeoutTimer = null;
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
    if (selectedDuration == null || _sessionTicker.isRunning) {
      return;
    }
    _remainingSessionDuration ??= selectedDuration;
    unawaited(_updateFadeVolume());
    _sessionTicker.start(_handleSessionTick);
  }

  void _handleSessionTick() {
    final remaining = _remainingSessionDuration;
    final selectedDuration = _selectedSessionDuration;
    if (remaining == null || selectedDuration == null) {
      _cancelSessionTimer();
      return;
    }
    final nextRemaining = remaining - const Duration(seconds: 1);
    if (nextRemaining <= Duration.zero) {
      _remainingSessionDuration = selectedDuration;
      _cancelSessionTimer();
      if (mounted) {
        setState(() {});
      }
      unawaited(_completeTimedSession());
      return;
    }
    _remainingSessionDuration = nextRemaining;
    if (mounted) {
      setState(() {});
    }
    unawaited(_updateFadeVolume());
  }

  Future<void> _completeTimedSession() async {
    try {
      await _playbackDriver.pause();
      await _restoreVolume();
    } catch (error, stackTrace) {
      _logPlaybackError(error, stackTrace);
    }
  }

  void _pauseSessionTimer() {
    _cancelSessionTimer();
    unawaited(_restoreVolume());
  }

  void _cancelSessionTimer() {
    _sessionTicker.stop();
  }

  Future<void> _updateFadeVolume() async {
    if (!_playbackDriver.isLoaded) {
      return;
    }
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
    await _playbackDriver.setVolume(volume);
  }

  Future<void> _restoreVolume() async {
    if (!_playbackDriver.isLoaded) {
      return;
    }
    await _playbackDriver.setVolume(_normalVolume);
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
    if (_currentPlayerState.ready) {
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
    final duration = _playbackDriver.duration;
    if (duration.inMilliseconds <= 0) {
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
    await _playbackDriver.seek(target);
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
    final duration = _durationOrZero();
    final position = _draggingProgress != null
        ? Duration(
            milliseconds:
                (duration.inMilliseconds * _draggingProgress!).round(),
          )
        : _currentPosition;
    final canSeek = duration != Duration.zero;
    final value = canSeek
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
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

  bool get _isPlaying => _playbackDriver.playerState.playing;

  int? get _currentIndex => _playbackDriver.currentIndex;

  SoundPlaybackState get _currentPlayerState => _playbackDriver.playerState;

  Stream<SoundPlaybackState> get _playerStateStream =>
      _playbackDriver.playerStateStream;
}

abstract interface class SoundSessionTicker {
  void start(void Function() onTick);
  void stop();
  bool get isRunning;
  void dispose();
}

class TimerSoundSessionTicker implements SoundSessionTicker {
  Timer? _timer;
  void Function()? _onTick;

  @override
  void start(void Function() onTick) {
    if (_timer != null) {
      return;
    }
    _onTick = onTick;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTick?.call();
    });
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    _onTick = null;
  }

  @override
  bool get isRunning => _timer != null;

  @override
  void dispose() {
    stop();
  }
}

class SoundPlaybackState {
  const SoundPlaybackState({
    required this.playing,
    required this.ready,
    this.currentIndex,
  });

  final bool playing;
  final bool ready;
  final int? currentIndex;
}

abstract interface class SoundPlaybackDriver {
  Stream<SoundPlaybackState> get playerStateStream;
  Stream<Object> get errorStream;
  Stream<Duration> get positionStream;
  SoundPlaybackState get playerState;
  int? get currentIndex;
  Duration get duration;
  bool get isLoaded;

  Future<void> load(String assetPath);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> dispose();
}

class JustAudioSoundPlaybackDriver implements SoundPlaybackDriver {
  JustAudioSoundPlaybackDriver(this.player) {
    _init();
  }

  final AudioPlayer player;
  final StreamController<SoundPlaybackState> _stateController =
      StreamController<SoundPlaybackState>.broadcast();
  final StreamController<Object> _errorController =
      StreamController<Object>.broadcast();
  late final StreamSubscription<PlayerState> _stateSubscription;
  late final StreamSubscription<PlaybackEvent> _errorSubscription;
  SoundPlaybackState _state =
      const SoundPlaybackState(playing: false, ready: false);

  void _init() {
    _stateSubscription = player.playerStateStream.listen((state) {
      _state = SoundPlaybackState(
        playing: state.playing,
        ready: state.processingState == ProcessingState.ready,
        currentIndex: player.currentIndex,
      );
      _stateController.add(_state);
    });
    _errorSubscription = player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        _errorController.addError(error, stackTrace);
      },
    );
  }

  @override
  Stream<SoundPlaybackState> get playerStateStream => _stateController.stream;

  @override
  Stream<Object> get errorStream => _errorController.stream;

  @override
  SoundPlaybackState get playerState => _state;

  @override
  int? get currentIndex => player.currentIndex;

  @override
  Stream<Duration> get positionStream => player.positionStream;

  @override
  Duration get duration => player.duration ?? Duration.zero;

  @override
  bool get isLoaded => player.audioSource != null;

  @override
  Future<void> load(String assetPath) async {
    await loadLoopingSoundAsset(player, assetPath);
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> setVolume(double volume) => player.setVolume(volume);

  @override
  Future<void> dispose() async {
    await _stateSubscription.cancel();
    await _errorSubscription.cancel();
    await _stateController.close();
    await _errorController.close();
    await player.dispose();
  }
}

class SoLoudSoundPlaybackDriver implements SoundPlaybackDriver {
  SoLoudSoundPlaybackDriver({
    soloud.SoLoud? soloudInstance,
    BundledSoundFileCache? soundFileCache,
  })  : _soloud = soloudInstance ?? soloud.SoLoud.instance,
        _soundFileCache = soundFileCache ?? const BundledSoundFileCache() {
    _positionTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _pollPosition();
    });
  }

  final soloud.SoLoud _soloud;
  final BundledSoundFileCache _soundFileCache;
  final StreamController<SoundPlaybackState> _stateController =
      StreamController<SoundPlaybackState>.broadcast();
  final StreamController<Object> _errorController =
      StreamController<Object>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  Timer? _positionTimer;
  soloud.AudioSource? _source;
  soloud.SoundHandle? _handle;
  SoundPlaybackState _state =
      const SoundPlaybackState(playing: false, ready: false);
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  void _emitState({bool? playing, bool? ready}) {
    _state = SoundPlaybackState(
      playing: playing ?? _state.playing,
      ready: ready ?? _state.ready,
      currentIndex: 0,
    );
    _stateController.add(_state);
  }

  void _pollPosition() {
    final handle = _handle;
    final source = _source;
    if (handle == null || source == null) {
      return;
    }
    try {
      _position = _soloud.getPosition(handle);
      _positionController.add(_position);
      _duration = _soloud.getLength(source);
      _emitState(
        playing: !_soloud.getPause(handle),
        ready: true,
      );
    } catch (error, stackTrace) {
      _errorController.addError(error, stackTrace);
    }
  }

  @override
  Stream<SoundPlaybackState> get playerStateStream => _stateController.stream;

  @override
  Stream<Object> get errorStream => _errorController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  SoundPlaybackState get playerState => _state;

  @override
  int? get currentIndex => _handle != null ? 0 : null;

  @override
  Duration get duration => _duration;

  @override
  bool get isLoaded => _source != null;

  @override
  Future<void> load(String assetPath) async {
    if (!_soloud.isInitialized) {
      await _soloud.init();
    }
    final localPath = await _soundFileCache.materialize(assetPath);
    _source = await _soloud.loadFile(localPath, mode: soloud.LoadMode.disk);
    _duration = _soloud.getLength(_source!);
    _handle = _soloud.play(
      _source!,
      paused: true,
      looping: true,
    );
    _position = Duration.zero;
    _positionController.add(_position);
    _emitState(playing: false, ready: true);
  }

  @override
  Future<void> play() async {
    final handle = _handle;
    if (handle == null) {
      return;
    }
    _soloud.setPause(handle, false);
    _emitState(playing: true, ready: true);
  }

  @override
  Future<void> pause() async {
    final handle = _handle;
    if (handle == null) {
      return;
    }
    _soloud.setPause(handle, true);
    _emitState(playing: false, ready: true);
  }

  @override
  Future<void> seek(Duration position) async {
    final handle = _handle;
    if (handle == null) {
      return;
    }
    _soloud.seek(handle, position);
    _position = position;
    _positionController.add(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    final handle = _handle;
    if (handle == null) {
      return;
    }
    _soloud.setVolume(handle, volume);
  }

  @override
  Future<void> dispose() async {
    _positionTimer?.cancel();
    final handle = _handle;
    final source = _source;
    if (handle != null) {
      await _soloud.stop(handle);
    }
    if (source != null) {
      await _soloud.disposeSource(source);
    }
    await _stateController.close();
    await _errorController.close();
    await _positionController.close();
    _handle = null;
    _source = null;
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

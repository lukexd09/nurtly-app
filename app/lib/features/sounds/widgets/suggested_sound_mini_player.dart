import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/content/sound_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class SuggestedSoundMiniPlayer extends StatefulWidget {
  const SuggestedSoundMiniPlayer({required this.sound, super.key});

  final SoundItem sound;

  @override
  State<SuggestedSoundMiniPlayer> createState() =>
      _SuggestedSoundMiniPlayerState();
}

class _SuggestedSoundMiniPlayerState extends State<SuggestedSoundMiniPlayer> {
  static const int _loopPlaylistCopies = 3;
  late final AudioPlayer _player;
  late final StreamSubscription<PlayerState> _playerSubscription;
  bool _isLoading = false;
  String? _errorMessage;

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
    _playerSubscription.cancel();
    unawaited(_player.dispose());
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
        await _loadLoopingPlaylist();
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      unawaited(
        _player.play().then((_) {}).catchError((Object _) async {
          await _player.pause();
          if (mounted) {
            setState(() {
              _errorMessage = 'Could not start this sound.';
            });
          }
        }),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not start this sound.';
      });
    }
  }

  Future<void> _loadLoopingPlaylist() async {
    final sources = List<AudioSource>.generate(
      _loopPlaylistCopies,
      (_) => AudioSource.asset(widget.sound.assetPath),
    );
    await _player.setAudioSources(
      sources,
      initialIndex: 0,
      initialPosition: Duration.zero,
    );
    await _player.setLoopMode(LoopMode.all);
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _player.playing;

    return DecoratedBox(
      key: const ValueKey('play-suggested-sound'),
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
            Text(
              'Suggested sound',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: FilledButton(
                    key: const ValueKey('play-suggested-sound-control'),
                    onPressed: _togglePlayPause,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 30,
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    widget.sound.title,
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _SuggestedSoundArtwork(sound: widget.sound),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 2),
              Text(
                _errorMessage!,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestedSoundArtwork extends StatelessWidget {
  const _SuggestedSoundArtwork({required this.sound});

  final SoundItem sound;

  @override
  Widget build(BuildContext context) {
    final artworkAssetPath = sound.artworkAssetPath?.trim();
    return Container(
      key: const ValueKey('play-suggested-sound-artwork'),
      width: 56,
      height: 56,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Semantics(
        label: '${sound.title} artwork',
        child: artworkAssetPath == null || artworkAssetPath.isEmpty
            ? const _SuggestedSoundFallbackArtwork()
            : Image.asset(
                artworkAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _SuggestedSoundFallbackArtwork(),
              ),
      ),
    );
  }
}

class _SuggestedSoundFallbackArtwork extends StatelessWidget {
  const _SuggestedSoundFallbackArtwork();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3F8F4),
            Color(0xFFE9F3EC),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceBright, width: 2),
          ),
          child: const Icon(
            Icons.waves_rounded,
            color: AppColors.primary,
            size: 14,
          ),
        ),
      ),
    );
  }
}

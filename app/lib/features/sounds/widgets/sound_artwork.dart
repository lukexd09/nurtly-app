import 'package:flutter/material.dart';

import '../../../core/content/sound_item.dart';
import '../../../core/theme/app_colors.dart';

enum SoundArtworkVariant { card, detail, mini }

class SoundArtwork extends StatelessWidget {
  const SoundArtwork({
    required this.sound,
    required this.variant,
    this.valueKey,
    super.key,
  });

  final SoundItem sound;
  final SoundArtworkVariant variant;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final artworkAssetPath = sound.artworkAssetPath?.trim();

    return Container(
      key: valueKey,
      width: _width,
      height: _height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Semantics(
        label: _semanticLabel,
        image: true,
        child: artworkAssetPath == null || artworkAssetPath.isEmpty
            ? _buildFallbackArtwork()
            : Image.asset(
                artworkAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackArtwork(),
              ),
      ),
    );
  }

  double get _width {
    switch (variant) {
      case SoundArtworkVariant.card:
        return 76;
      case SoundArtworkVariant.detail:
        return double.infinity;
      case SoundArtworkVariant.mini:
        return 56;
    }
  }

  double get _height {
    switch (variant) {
      case SoundArtworkVariant.card:
        return 76;
      case SoundArtworkVariant.detail:
        return 132;
      case SoundArtworkVariant.mini:
        return 56;
    }
  }

  double get _radius {
    switch (variant) {
      case SoundArtworkVariant.card:
        return 14;
      case SoundArtworkVariant.detail:
        return 20;
      case SoundArtworkVariant.mini:
        return 14;
    }
  }

  String get _semanticLabel => '${sound.title} artwork';

  Widget _buildFallbackArtwork() {
    switch (variant) {
      case SoundArtworkVariant.card:
        return _SoundArtworkCardFallback();
      case SoundArtworkVariant.detail:
        return _SoundArtworkDetailFallback();
      case SoundArtworkVariant.mini:
        return _SoundArtworkMiniFallback();
    }
  }
}

class _SoundArtworkCardFallback extends StatelessWidget {
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceBright, width: 3),
          ),
          child: const Icon(
            Icons.waves_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SoundArtworkDetailFallback extends StatelessWidget {
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
}

class _SoundArtworkMiniFallback extends StatelessWidget {
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

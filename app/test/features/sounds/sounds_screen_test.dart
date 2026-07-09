import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
import 'package:nurtly/core/content/content_taxonomy.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/core/monetization/premium_entitlement.dart';
import 'package:nurtly/features/sounds/sounds_screen.dart';

void main() {
  testWidgets('shows sounds from bundled-style content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundsScreen(contentLoader: _SoundsArtworkFallbackLoader()),
      ),
    );
    await tester.pump();

    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('Gentle rain for a calmer background.'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sound-card-artwork-sound_soft_rain')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.waves_rounded), findsOneWidget);
  });

  testWidgets('shows sound card artwork when artworkAssetPath exists',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundsScreen(contentLoader: _SoundsArtworkImageLoader()),
      ),
    );
    await tester.pump();

    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('free'), findsNothing);
    expect(
      find.byKey(const ValueKey('sound-card-artwork-sound_soft_rain')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((widget) {
        final image = widget is Image ? widget.image : null;
        return image is AssetImage &&
            image.assetName == 'assets/images/sounds/soft_rain.webp';
      }),
      findsOneWidget,
    );
  });

  testWidgets('opens sound detail from the sounds list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundsScreen(contentLoader: _SoundsArtworkFallbackLoader()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Soft rain'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('sound-detail-back-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-status')), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-artwork')), findsOneWidget);
    expect(find.byIcon(Icons.waves_rounded), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-progress')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-session-options')),
        findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('Continuous play'), findsNothing);
    expect(find.byKey(const ValueKey('sound-player-timer-infinity')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('sound-player-auto-fade')), findsOneWidget);
    expect(find.text('Auto-fade available with timer'), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-controls')), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-primary-control')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('sound-player-stop-control')), findsNothing);
    expect(find.text('Soft rain'), findsOneWidget);
    expect(find.text('Gentle rain for a calmer background.'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);
    expect(find.text('Free'), findsNothing);
    expect(find.text('free'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Keep volume comfortable and device away from child.'),
      120,
    );
    await tester.pump();

    expect(find.text('Keep volume comfortable and device away from child.'),
        findsOneWidget);
    expect(find.textContaining('placeholder'), findsNothing);
    expect(find.textContaining('future'), findsNothing);
  });

  testWidgets('renders configured sound artwork asset when present',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SoundDetailScreen(
          strings: AppStrings.english,
          sound: SoundItem(
            id: 'sound_artwork_test',
            title: 'Artwork sound',
            category: 'Nature',
            summary: 'A sound with artwork.',
            assetPath: 'assets/audio/soft_rain.mp3',
            artworkAssetPath: 'assets/images/sounds/artwork_test.webp',
            unlockType: 'free',
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('sound-player-artwork')), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) {
        final image = widget is Image ? widget.image : null;
        return image is AssetImage &&
            image.assetName == 'assets/images/sounds/artwork_test.webp';
      }),
      findsOneWidget,
    );
  });

  testWidgets('starts playback only after ready and starts timer then',
      (tester) async {
    final harness = TestSoundPlaybackDriver();
    final ticker = FakeSoundSessionTicker();
    final playStarted = Completer<void>();
    harness.onPlayRequested = () {
      playStarted.complete();
    };

    await tester.pumpWidget(
      MaterialApp(
        home: SoundDetailScreen(
          strings: AppStrings.english,
          sound: const SoundItem(
            id: 'sound_asset_path_test',
            title: 'Asset path test',
            category: 'Nature',
            summary: 'A sound used for loader verification.',
            assetPath: 'assets/audio/soft_rain.mp3',
            unlockType: 'free',
          ),
          playbackDriver: harness,
          sessionTicker: ticker,
        ),
      ),
    );

    await tester
        .tap(find.byKey(const ValueKey('sound-player-primary-control')));
    await tester.pump();
    await tester.tap(
      find
          .descendant(
            of: find.byKey(const ValueKey('sound-player-session-options')),
            matching: find.text('15'),
          )
          .first,
    );
    await tester.pump();

    expect(find.text(AppStrings.english.loading), findsOneWidget);
    expect(find.text('15:00 left'), findsOneWidget);
    expect(harness.startAttempts, 1);
    expect(playStarted.isCompleted, isTrue);
    expect(ticker.tickCount, 0);

    harness.markReadyPlaying(currentIndex: 0);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text(AppStrings.english.playing), findsOneWidget);
    expect(find.text('15:00 left'), findsOneWidget);

    ticker.tick();
    await tester.pump();
    expect(find.text('14:59 left'), findsOneWidget);
    expect(ticker.tickCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await harness.dispose();
    ticker.dispose();
  });

  testWidgets('allows pause while loop playback is pending', (tester) async {
    final harness = TestSoundPlaybackDriver();
    final ticker = FakeSoundSessionTicker();
    harness.onPlayRequested = () {};
    harness.onPauseRequested = () {};

    await tester.pumpWidget(
      MaterialApp(
        home: SoundDetailScreen(
          strings: AppStrings.english,
          sound: const SoundItem(
            id: 'sound_failure_test',
            title: 'Failure test',
            category: 'Nature',
            summary: 'A sound used for pause verification.',
            assetPath: 'assets/audio/soft_rain.mp3',
            unlockType: 'free',
          ),
          playbackDriver: harness,
          sessionTicker: ticker,
        ),
      ),
    );

    await tester
        .tap(find.byKey(const ValueKey('sound-player-primary-control')));
    await tester.pump();
    await tester.tap(
      find
          .descendant(
            of: find.byKey(const ValueKey('sound-player-session-options')),
            matching: find.text('15'),
          )
          .first,
    );
    await tester.pump();

    harness.markReadyPlaying(currentIndex: 0);
    await tester.pump();

    expect(find.text(AppStrings.english.playing), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-primary-control')),
        findsOneWidget);
    expect(harness.pauseCalls, 0);

    await tester
        .tap(find.byKey(const ValueKey('sound-player-primary-control')));
    await tester.pump();
    harness.markReadyPaused(currentIndex: 0);
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.english.paused), findsOneWidget);
    expect(harness.pauseCalls, 1);
    ticker.tick();
    ticker.tick();
    await tester.pump();
    expect(find.text('15:00 left'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await harness.dispose();
    ticker.dispose();
  });

  testWidgets(
      'shows playback failure, allows retry, and succeeds on second try',
      (tester) async {
    final harness = TestSoundPlaybackDriver();
    final ticker = FakeSoundSessionTicker();
    final secondAttemptReady = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: SoundDetailScreen(
          strings: AppStrings.english,
          sound: const SoundItem(
            id: 'sound_failure_test',
            title: 'Failure test',
            category: 'Nature',
            summary: 'A sound used for failure verification.',
            assetPath: 'assets/audio/soft_rain.mp3',
            unlockType: 'free',
          ),
          playbackDriver: harness,
          sessionTicker: ticker,
        ),
      ),
    );

    await tester
        .tap(find.byKey(const ValueKey('sound-player-primary-control')));
    await tester.pump();
    await tester.tap(
      find
          .descendant(
            of: find.byKey(const ValueKey('sound-player-session-options')),
            matching: find.text('15'),
          )
          .first,
    );
    await tester.pump();

    expect(harness.startAttempts, 1);
    expect(find.text(AppStrings.english.loading), findsOneWidget);

    harness.emitError(StateError('simulated playback failure'));
    harness.markReadyPaused(currentIndex: 0);
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.english.couldNotPlay), findsOneWidget);
    expect(find.text(AppStrings.english.couldNotPlaySound), findsOneWidget);
    expect(find.text('15:00 left'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey('sound-player-primary-control')));
    await tester.pump();

    expect(harness.startAttempts, 2);
    expect(find.text(AppStrings.english.loading), findsOneWidget);

    harness.markReadyPlaying(currentIndex: 0);
    await tester.pump();
    secondAttemptReady.complete();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.english.playing), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-player-primary-control')),
        findsOneWidget);
    ticker.tick();
    await tester.pump();
    expect(find.text('14:59 left'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await harness.dispose();
    ticker.dispose();
  });

  testWidgets(
    'premium sound cards open paywall for free users and detail for premium users',
    (tester) async {
      var paywallCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: SoundsScreen(
            contentLoader: const _PremiumSoundsContentLoader(),
            premiumEntitlement: PremiumEntitlement.free(
              checkedAt: DateTime.utc(2026, 5, 26, 12),
            ),
            onOpenPremiumPaywall: () {
              paywallCalls++;
            },
            showAdPlaceholder: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sponsored space'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.text('premium'), findsNothing);

      await tester.tap(find.text('Premium room fan'));
      await tester.pumpAndSettle();

      expect(paywallCalls, 1);
      expect(find.byKey(const ValueKey('sound-player-card')), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: SoundsScreen(
            contentLoader: const _PremiumSoundsContentLoader(),
            premiumEntitlement: PremiumEntitlement.yearlyActive(
              checkedAt: DateTime.utc(2026, 5, 26, 12),
            ),
            showAdPlaceholder: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sponsored space'), findsNothing);
      await tester.tap(find.text('Premium room fan'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sound-player-card')), findsOneWidget);
      expect(find.text('Premium room fan'), findsWidgets);
    },
  );

  testWidgets('free sounds list inserts ad after the 3rd item', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SoundsScreen(
          contentLoader: const _AdPlacementSoundsContentLoader4(),
          premiumEntitlement: PremiumEntitlement.free(
            checkedAt: DateTime.utc(2026, 5, 26, 12),
          ),
          showAdPlaceholder: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Sound 4'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Sponsored space'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Sponsored space')).dy,
      greaterThan(tester.getTopLeft(find.text('Sound 3')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Sponsored space')).dy,
      lessThan(tester.getTopLeft(find.text('Sound 4')).dy),
    );
  });

  testWidgets('short unfiltered sounds list inserts ad at the end',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SoundsScreen(
          contentLoader: const _AdPlacementSoundsContentLoader2(),
          premiumEntitlement: PremiumEntitlement.free(
            checkedAt: DateTime.utc(2026, 5, 26, 12),
          ),
          showAdPlaceholder: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sponsored space'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Sponsored space')).dy,
      greaterThan(tester.getTopLeft(find.text('Sound 2')).dy),
    );
  });

  testWidgets('premium sounds lists do not show ad placeholders',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SoundsScreen(
          contentLoader: const _AdPlacementSoundsContentLoader4(),
          premiumEntitlement: PremiumEntitlement.yearlyActive(
            checkedAt: DateTime.utc(2026, 5, 26, 12),
          ),
          showAdPlaceholder: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sponsored space'), findsNothing);
  });
}

class TestSoundPlaybackDriver implements SoundPlaybackDriver {
  TestSoundPlaybackDriver({
    SoundPlaybackState? initialState,
    this.currentIndex,
  }) : _state = initialState ??
            const SoundPlaybackState(
              playing: false,
              ready: false,
            );

  final StreamController<SoundPlaybackState> _stateController =
      StreamController<SoundPlaybackState>.broadcast();
  final StreamController<Object> _errorController =
      StreamController<Object>.broadcast();
  SoundPlaybackState _state;
  VoidCallback? onPlayRequested;
  VoidCallback? onPauseRequested;
  int startAttempts = 0;
  int pauseCalls = 0;
  bool _loaded = false;

  @override
  int? currentIndex;

  @override
  Stream<SoundPlaybackState> get playerStateStream => _stateController.stream;

  @override
  Stream<Object> get errorStream => _errorController.stream;

  @override
  Stream<Duration> get positionStream => const Stream<Duration>.empty();

  @override
  SoundPlaybackState get playerState => _state;

  @override
  Future<void> play() async {
    startAttempts++;
    if (onPlayRequested != null) {
      onPlayRequested!();
    }
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    if (onPauseRequested != null) {
      onPauseRequested!();
    }
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Duration get duration => Duration.zero;

  @override
  bool get isLoaded => _loaded;

  @override
  Future<void> load(String assetPath) async {
    _loaded = true;
  }

  void markReadyPlaying({int? currentIndex}) {
    updateState(
      playing: true,
      ready: true,
      currentIndex: currentIndex,
    );
  }

  void markReadyPaused({int? currentIndex}) {
    updateState(
      playing: false,
      ready: true,
      currentIndex: currentIndex,
    );
  }

  void markIdlePaused({int? currentIndex}) {
    updateState(
      playing: false,
      ready: false,
      currentIndex: currentIndex,
    );
  }

  void emitError(Object error) {
    _errorController.addError(error);
  }

  void updateState({
    bool? playing,
    bool? ready,
    int? currentIndex,
  }) {
    _state = SoundPlaybackState(
      playing: playing ?? _state.playing,
      ready: ready ?? _state.ready,
      currentIndex: currentIndex ?? this.currentIndex,
    );
    this.currentIndex = currentIndex ?? this.currentIndex;
    _stateController.add(_state);
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    await _errorController.close();
  }
}

class FakeSoundSessionTicker implements SoundSessionTicker {
  void Function()? _onTick;
  bool _running = false;
  int tickCount = 0;

  @override
  void start(void Function() onTick) {
    if (_running) {
      return;
    }
    _running = true;
    _onTick = onTick;
  }

  @override
  void stop() {
    _running = false;
    _onTick = null;
  }

  @override
  bool get isRunning => _running;

  void tick() {
    if (!_running) {
      return;
    }
    tickCount++;
    _onTick?.call();
  }

  @override
  void dispose() {
    stop();
  }
}

class _SoundsArtworkFallbackLoader extends ContentLoader {
  const _SoundsArtworkFallbackLoader();

  @override
  Future<ContentPackage> load() async {
    return _basePackage(
      const [
        SoundItem(
          id: 'sound_soft_rain',
          title: 'Soft rain',
          category: 'Nature',
          summary: 'Gentle rain for a calmer background.',
          assetPath: 'assets/audio/soft_rain.mp3',
          unlockType: 'free',
        ),
      ],
    );
  }
}

class _SoundsArtworkImageLoader extends ContentLoader {
  const _SoundsArtworkImageLoader();

  @override
  Future<ContentPackage> load() async {
    return _basePackage(
      const [
        SoundItem(
          id: 'sound_soft_rain',
          title: 'Soft rain',
          category: 'Nature',
          summary: 'Gentle rain for a calmer background.',
          assetPath: 'assets/audio/soft_rain.mp3',
          artworkAssetPath: 'assets/images/sounds/soft_rain.webp',
          unlockType: 'free',
        ),
      ],
    );
  }
}

class _PremiumSoundsContentLoader extends ContentLoader {
  const _PremiumSoundsContentLoader();

  @override
  Future<ContentPackage> load() async {
    return _basePackage(
      const [
        SoundItem(
          id: 'sound_soft_rain',
          title: 'Soft rain',
          category: 'Nature',
          summary: 'Gentle rain for a calmer background.',
          assetPath: 'assets/audio/soft_rain.mp3',
          unlockType: 'free',
        ),
        SoundItem(
          id: 'sound_room_fan',
          title: 'Premium room fan',
          category: 'Home',
          summary: 'A soft fan sound for steady background calm.',
          assetPath: 'assets/audio/room_fan.mp3',
          unlockType: 'premium',
        ),
      ],
    );
  }
}

class _AdPlacementSoundsContentLoader4 extends ContentLoader {
  const _AdPlacementSoundsContentLoader4();

  @override
  Future<ContentPackage> load() async {
    return _basePackage(
      const [
        SoundItem(
          id: 'sound_1',
          title: 'Sound 1',
          category: 'Nature',
          summary: 'Sound one.',
          assetPath: 'assets/audio/soft_rain.mp3',
          unlockType: 'free',
        ),
        SoundItem(
          id: 'sound_2',
          title: 'Sound 2',
          category: 'Nature',
          summary: 'Sound two.',
          assetPath: 'assets/audio/soft_rain.mp3',
          unlockType: 'free',
        ),
        SoundItem(
          id: 'sound_3',
          title: 'Sound 3',
          category: 'Nature',
          summary: 'Sound three.',
          assetPath: 'assets/audio/soft_rain.mp3',
          unlockType: 'free',
        ),
        SoundItem(
          id: 'sound_4',
          title: 'Sound 4',
          category: 'Nature',
          summary: 'Sound four.',
          assetPath: 'assets/audio/soft_rain.mp3',
          unlockType: 'free',
        ),
      ],
    );
  }
}

class _AdPlacementSoundsContentLoader2 extends ContentLoader {
  const _AdPlacementSoundsContentLoader2();

  @override
  Future<ContentPackage> load() async {
    return _basePackage(
      const [
        SoundItem(
          id: 'sound_1',
          title: 'Sound 1',
          category: 'Nature',
          summary: 'Sound one.',
          assetPath: 'assets/audio/soft_rain.mp3',
          unlockType: 'free',
        ),
        SoundItem(
          id: 'sound_2',
          title: 'Sound 2',
          category: 'Nature',
          summary: 'Sound two.',
          assetPath: 'assets/audio/soft_rain.mp3',
          unlockType: 'free',
        ),
      ],
    );
  }
}

ContentPackage _basePackage(List<SoundItem> sounds) {
  return ContentPackage(
    metadata: const ContentMetadata(
      packageId: 'test',
      schemaVersion: 1,
      version: '1.0.0',
      locale: 'en',
      publishedAt: '2026-05-18',
      minAppVersion: '0.1.0',
    ),
    taxonomy: _testTaxonomy,
    playFilters: const [],
    playIdeas: const [],
    sounds: sounds,
  );
}

const _testTaxonomy = ContentTaxonomy(
  places: [
    TaxonomyTerm(id: 'place_home', label: 'Home'),
    TaxonomyTerm(id: 'place_floor', label: 'Floor'),
    TaxonomyTerm(id: 'place_kitchen', label: 'Kitchen'),
    TaxonomyTerm(id: 'place_living_room', label: 'Living room'),
    TaxonomyTerm(id: 'place_bedroom', label: 'Bedroom'),
    TaxonomyTerm(id: 'place_outside', label: 'Outside'),
    TaxonomyTerm(id: 'place_bathroom', label: 'Bathroom'),
    TaxonomyTerm(id: 'place_table', label: 'Table'),
    TaxonomyTerm(id: 'place_sofa', label: 'Sofa'),
    TaxonomyTerm(id: 'place_window', label: 'Window'),
    TaxonomyTerm(id: 'place_any_quiet_spot', label: 'Any quiet spot'),
    TaxonomyTerm(id: 'place_hallway', label: 'Hallway'),
  ],
  messLevels: [
    TaxonomyTerm(id: 'mess_low', label: 'Low'),
    TaxonomyTerm(id: 'mess_medium', label: 'Medium'),
  ],
  childEngagementLevels: [
    TaxonomyTerm(id: 'child_engagement_low', label: 'Low'),
    TaxonomyTerm(id: 'child_engagement_medium', label: 'Medium'),
    TaxonomyTerm(id: 'child_engagement_high', label: 'High'),
  ],
  parentInvolvementLevels: [
    TaxonomyTerm(id: 'parent_involvement_low', label: 'Low'),
    TaxonomyTerm(id: 'parent_involvement_medium', label: 'Medium'),
    TaxonomyTerm(id: 'parent_involvement_high', label: 'High'),
  ],
  activityTypes: [
    TaxonomyTerm(id: 'activity_connection', label: 'Connection'),
    TaxonomyTerm(id: 'activity_fine_motor', label: 'Fine motor'),
    TaxonomyTerm(id: 'activity_imaginative_play', label: 'Imaginative play'),
    TaxonomyTerm(id: 'activity_language', label: 'Language'),
    TaxonomyTerm(id: 'activity_movement', label: 'Movement'),
    TaxonomyTerm(id: 'activity_music', label: 'Music'),
    TaxonomyTerm(id: 'activity_observation', label: 'Observation'),
    TaxonomyTerm(id: 'activity_practical_life', label: 'Practical life'),
    TaxonomyTerm(id: 'activity_quiet_time', label: 'Quiet time'),
    TaxonomyTerm(id: 'activity_sensory', label: 'Sensory'),
    TaxonomyTerm(id: 'activity_sorting', label: 'Sorting'),
  ],
  contexts: [
    TaxonomyTerm(id: 'context_home', label: 'home'),
    TaxonomyTerm(id: 'context_baby', label: 'baby'),
    TaxonomyTerm(id: 'context_sensory', label: 'sensory'),
    TaxonomyTerm(id: 'context_low_setup', label: 'low_setup'),
    TaxonomyTerm(id: 'context_toddler', label: 'toddler'),
    TaxonomyTerm(id: 'context_movement', label: 'movement'),
    TaxonomyTerm(id: 'context_kitchen', label: 'kitchen'),
    TaxonomyTerm(id: 'context_practical_life', label: 'practical_life'),
    TaxonomyTerm(id: 'context_quiet', label: 'quiet'),
    TaxonomyTerm(id: 'context_transition', label: 'transition'),
    TaxonomyTerm(id: 'context_preschool', label: 'preschool'),
    TaxonomyTerm(id: 'context_pretend', label: 'pretend'),
    TaxonomyTerm(id: 'context_connection', label: 'connection'),
    TaxonomyTerm(id: 'context_outside', label: 'outside'),
    TaxonomyTerm(id: 'context_bathroom', label: 'bathroom'),
  ],
  soundCategories: [
    TaxonomyTerm(id: 'sound_category_calm', label: 'Calm'),
    TaxonomyTerm(id: 'sound_category_home', label: 'Home'),
    TaxonomyTerm(id: 'sound_category_nature', label: 'Nature'),
    TaxonomyTerm(id: 'sound_category_white_noise', label: 'White noise'),
  ],
);

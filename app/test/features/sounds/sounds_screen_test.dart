import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
import 'package:nurtly/core/content/content_taxonomy.dart';
import 'package:nurtly/core/content/sound_item.dart';
import 'package:nurtly/core/localization/app_strings.dart';
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

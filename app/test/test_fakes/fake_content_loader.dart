import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
import 'package:nurtly/core/content/content_taxonomy.dart';
import 'package:nurtly/core/content/play_filter.dart';
import 'package:nurtly/core/content/play_idea.dart';
import 'package:nurtly/core/content/sound_item.dart';

class FakeContentLoader extends ContentLoader {
  const FakeContentLoader();

  @override
  Future<ContentPackage> load() async {
    return const ContentPackage(
      metadata: ContentMetadata(
        packageId: 'test',
        schemaVersion: 1,
        version: '1.0.0',
        locale: 'en',
        publishedAt: '2026-05-18',
        minAppVersion: '0.1.0',
      ),
      playFilters: [
        PlayFilter(
          id: 'low_effort',
          label: 'Low effort',
          matchMode: PlayFilterMatchMode.all,
          rules: [
            PlayFilterRule(
              field: 'parentInvolvement',
              operator: 'equals',
              value: 'parent_involvement_low',
            ),
          ],
        ),
      ],
      taxonomy: _testTaxonomy,
      playIdeas: [
        PlayIdea(
          id: 'play_soft_treasure_basket',
          title: 'Soft treasure basket',
          summary: 'Offer a few safe household textures to explore together.',
          ageGroup: '6-18 months',
          ageRangeMonths: AgeRangeMonths(min: 6, max: 18),
          place: 'place_home',
          messLevel: 'mess_low',
          childEngagement: 'child_engagement_medium',
          parentInvolvement: 'parent_involvement_low',
          activityType: 'activity_sensory',
          contexts: [
            'context_home',
            'context_baby',
            'context_sensory',
            'context_low_setup'
          ],
          neededItems: [
            'Soft cloth',
            'Wooden spoon',
          ],
          steps: [
            'Place the items in the container.',
            'Sit nearby and let your child choose what to touch.',
          ],
          whatToExpect:
              'This is a low-mess, gently engaging activity with very little setup. Stay nearby, offer simple guidance, and let your child explore at their own pace.',
          suggestedSoundId: 'sound_soft_rain',
          parentNote: 'Choose what fits the moment and keep it simple.',
          safetyNote: 'Use only large, clean items that cannot be swallowed.',
        ),
      ],
      sounds: [
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

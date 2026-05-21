import 'package:nurtly/core/content/content_loader.dart';
import 'package:nurtly/core/content/content_package.dart';
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
              value: 'Low',
            ),
          ],
        ),
      ],
      playIdeas: [
        PlayIdea(
          id: 'play_soft_treasure_basket',
          title: 'Soft treasure basket',
          summary: 'Offer a few safe household textures to explore together.',
          ageGroup: '6-18 months',
          ageRangeMonths: AgeRangeMonths(min: 6, max: 18),
          place: 'Home',
          messLevel: 'Low',
          childEngagement: 'Medium',
          parentInvolvement: 'Low',
          activityType: 'Sensory',
          contexts: ['home', 'baby', 'sensory', 'low_setup'],
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

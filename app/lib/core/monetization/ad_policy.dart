import 'premium_entitlement.dart';

enum AdPlacement {
  homePassiveSlot,
  playListPassiveSlot,
  soundsListPassiveSlot,
  soundPlayback,
  playDetail,
  settings,
  privacy,
  paywall,
}

class AdPolicy {
  const AdPolicy(this.entitlement);

  final PremiumEntitlement entitlement;

  bool allows(AdPlacement placement) {
    if (!entitlement.shouldShowAds) {
      return false;
    }
    return switch (placement) {
      AdPlacement.homePassiveSlot ||
      AdPlacement.playListPassiveSlot ||
      AdPlacement.soundsListPassiveSlot =>
        true,
      AdPlacement.soundPlayback ||
      AdPlacement.playDetail ||
      AdPlacement.settings ||
      AdPlacement.privacy ||
      AdPlacement.paywall =>
        false,
    };
  }
}

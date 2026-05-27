import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/monetization/ad_policy.dart';
import 'package:nurtly/core/monetization/premium_entitlement.dart';

void main() {
  final now = DateTime.utc(2026, 5, 26, 12);

  test('free entitlement allows ads only in passive slots', () {
    final policy = AdPolicy(PremiumEntitlement.free(checkedAt: now));

    expect(policy.allows(AdPlacement.homePassiveSlot), isTrue);
    expect(policy.allows(AdPlacement.playListPassiveSlot), isTrue);
    expect(policy.allows(AdPlacement.soundsListPassiveSlot), isTrue);
    expect(policy.allows(AdPlacement.soundPlayback), isFalse);
    expect(policy.allows(AdPlacement.playDetail), isFalse);
    expect(policy.allows(AdPlacement.settings), isFalse);
    expect(policy.allows(AdPlacement.privacy), isFalse);
    expect(policy.allows(AdPlacement.paywall), isFalse);
  });

  test('premium entitlement hides ads everywhere', () {
    final policy = AdPolicy(PremiumEntitlement.yearlyActive(checkedAt: now));

    for (final placement in AdPlacement.values) {
      expect(policy.allows(placement), isFalse);
    }
  });
}

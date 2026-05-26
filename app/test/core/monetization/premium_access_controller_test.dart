import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/monetization/premium_access_controller.dart';
import 'package:nurtly/core/monetization/premium_entitlement.dart';

import '../../test_fakes/fake_premium_entitlement_provider.dart';

void main() {
  final now = DateTime.utc(2026, 5, 26, 12);

  test('default provider returns free', () async {
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(),
    );

    await controller.load();

    expect(controller.entitlement.state, PremiumState.free);
    expect(controller.hasPremiumAccess, isFalse);
    expect(controller.shouldShowAds, isTrue);
  });

  test('refresh updates entitlement', () async {
    final provider = FakePremiumEntitlementProvider(
      loadEntitlement: PremiumEntitlement.free(checkedAt: now),
      refreshEntitlement: PremiumEntitlement.lifetimeActive(checkedAt: now),
    );
    final controller = PremiumAccessController(provider: provider);

    await controller.load();
    expect(controller.entitlement.state, PremiumState.free);

    await controller.refresh();

    expect(controller.entitlement.state, PremiumState.active);
    expect(controller.entitlement.source, PremiumSource.lifetime);
    expect(controller.hasPremiumAccess, isTrue);
    expect(provider.loadCalls, 1);
    expect(provider.refreshCalls, 1);
  });

  test('restore placeholder does not crash', () async {
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.free(checkedAt: now),
      ),
    );

    await controller.load();
    await controller.restorePurchases();

    expect(controller.entitlement.state, PremiumState.free);
  });
}

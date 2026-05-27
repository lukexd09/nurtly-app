import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/monetization/premium_access_controller.dart';
import 'package:nurtly/core/monetization/premium_entitlement.dart';
import 'package:nurtly/core/monetization/purchase_result.dart';

import '../../test_fakes/fake_premium_entitlement_provider.dart';
import '../../test_fakes/fake_premium_purchase_provider.dart';

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

  test('buyMonthly delegates to purchase provider', () async {
    final purchaseProvider = FakePremiumPurchaseProvider(
      buyMonthlyResult: const PurchaseActionResult(
        status: PurchaseActionStatus.pending,
      ),
    );
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.free(checkedAt: now),
      ),
      purchaseProvider: purchaseProvider,
    );

    await controller.load();
    final result = await controller.buyMonthly();

    expect(result.status, PurchaseActionStatus.pending);
    expect(purchaseProvider.buyMonthlyCalls, 1);
  });

  test('buyLifetime delegates to purchase provider', () async {
    final purchaseProvider = FakePremiumPurchaseProvider(
      buyLifetimeResult: const PurchaseActionResult(
        status: PurchaseActionStatus.pending,
      ),
    );
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.free(checkedAt: now),
      ),
      purchaseProvider: purchaseProvider,
    );

    await controller.load();
    final result = await controller.buyLifetime();

    expect(result.status, PurchaseActionStatus.pending);
    expect(purchaseProvider.buyLifetimeCalls, 1);
  });

  test('initial load error falls back to free', () async {
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(failOnLoad: true),
    );

    await controller.load();

    expect(controller.entitlement.state, PremiumState.free);
    expect(controller.hasPremiumAccess, isFalse);
  });

  test('refresh error preserves existing premium entitlement', () async {
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.lifetimeActive(checkedAt: now),
        failOnRefresh: true,
      ),
    );

    await controller.load();
    await controller.refresh();

    expect(controller.entitlement.state, PremiumState.active);
    expect(controller.entitlement.source, PremiumSource.lifetime);
    expect(controller.hasPremiumAccess, isTrue);
  });

  test('restorePurchases error preserves existing premium entitlement',
      () async {
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.monthlyActive(
          checkedAt: now,
          expiresAt: now.add(const Duration(days: 30)),
        ),
        failOnRefresh: true,
      ),
    );

    await controller.load();
    await controller.restorePurchases();

    expect(controller.entitlement.state, PremiumState.active);
    expect(controller.entitlement.source, PremiumSource.monthly);
    expect(controller.hasPremiumAccess, isTrue);
  });

  test('restorePurchases returns noPurchaseFound when no purchases exist',
      () async {
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.free(checkedAt: now),
      ),
      purchaseProvider: FakePremiumPurchaseProvider(
        restorePurchasesResult: const PurchaseActionResult(
          status: PurchaseActionStatus.noPurchaseFound,
        ),
      ),
    );

    await controller.load();
    final result = await controller.restorePurchases();

    expect(result.status, PurchaseActionStatus.noPurchaseFound);
    expect(controller.entitlement.state, PremiumState.free);
  });

  test('restorePurchases success preserves premium entitlement', () async {
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.lifetimeActive(checkedAt: now),
      ),
      purchaseProvider: FakePremiumPurchaseProvider(),
    );

    await controller.load();
    final result = await controller.restorePurchases();

    expect(result.status, PurchaseActionStatus.success);
    expect(controller.entitlement.state, PremiumState.active);
    expect(controller.entitlement.source, PremiumSource.lifetime);
  });
}

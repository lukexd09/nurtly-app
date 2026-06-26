import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/monetization/premium_access_controller.dart';
import 'package:nurtly/core/monetization/premium_entitlement.dart';
import 'package:nurtly/core/monetization/purchase_result.dart';

import '../../test_fakes/fake_premium_entitlement_provider.dart';
import '../../test_fakes/fake_premium_purchase_provider.dart';
import '../../test_fakes/fake_reviewer_access_store.dart';

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
      refreshEntitlement: PremiumEntitlement.yearlyActive(checkedAt: now),
    );
    final controller = PremiumAccessController(provider: provider);

    await controller.load();
    expect(controller.entitlement.state, PremiumState.free);

    await controller.refresh();

    expect(controller.entitlement.state, PremiumState.active);
    expect(controller.entitlement.source, PremiumSource.yearly);
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

  test('buyYearly delegates to purchase provider', () async {
    final purchaseProvider = FakePremiumPurchaseProvider(
      buyYearlyResult: const PurchaseActionResult(
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
    final result = await controller.buyYearly();

    expect(result.status, PurchaseActionStatus.pending);
    expect(purchaseProvider.buyYearlyCalls, 1);
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
        loadEntitlement: PremiumEntitlement.yearlyActive(checkedAt: now),
        failOnRefresh: true,
      ),
    );

    await controller.load();
    await controller.refresh();

    expect(controller.entitlement.state, PremiumState.active);
    expect(controller.entitlement.source, PremiumSource.yearly);
    expect(controller.hasPremiumAccess, isTrue);
  });

  test('restorePurchases error preserves existing premium entitlement',
      () async {
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.monthlyActive(checkedAt: now),
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
        loadEntitlement: PremiumEntitlement.yearlyActive(checkedAt: now),
      ),
      purchaseProvider: FakePremiumPurchaseProvider(),
    );

    await controller.load();
    final result = await controller.restorePurchases();

    expect(result.status, PurchaseActionStatus.success);
    expect(controller.entitlement.state, PremiumState.active);
    expect(controller.entitlement.source, PremiumSource.yearly);
  });

  test('valid reviewer code enables reviewer access and persists it', () async {
    final reviewerStore = FakeReviewerAccessStore();
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.free(checkedAt: now),
      ),
      reviewerAccessStore: reviewerStore,
    );

    await controller.load();
    await controller.enableReviewerAccess('NURTLY-REVIEWER-162');

    expect(controller.reviewerAccessEnabled, isTrue);
    expect(controller.hasPremiumAccess, isTrue);
    expect(controller.shouldShowAds, isFalse);
    expect(reviewerStore.saved, isTrue);
  });

  test('invalid reviewer code does not enable reviewer access', () async {
    final reviewerStore = FakeReviewerAccessStore();
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.free(checkedAt: now),
      ),
      reviewerAccessStore: reviewerStore,
    );

    await controller.load();
    await controller.enableReviewerAccess('wrong-code');

    expect(controller.reviewerAccessEnabled, isFalse);
    expect(controller.hasPremiumAccess, isFalse);
    expect(reviewerStore.savedValues, isEmpty);
  });

  test('reset only clears reviewer access and keeps true premium', () async {
    final reviewerStore = FakeReviewerAccessStore(saved: true);
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.yearlyActive(checkedAt: now),
      ),
      reviewerAccessStore: reviewerStore,
    );

    await controller.load();
    expect(controller.reviewerAccessEnabled, isTrue);
    expect(controller.hasPremiumAccess, isTrue);

    await controller.disableReviewerAccess();

    expect(controller.reviewerAccessEnabled, isFalse);
    expect(controller.hasPremiumAccess, isTrue);
  });
}

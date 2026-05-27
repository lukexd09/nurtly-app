import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:nurtly/core/monetization/billing_product_ids.dart';
import 'package:nurtly/core/monetization/billing_purchase_mapper.dart';
import 'package:nurtly/core/monetization/premium_entitlement.dart';

void main() {
  final now = DateTime.utc(2026, 5, 26, 12);

  test('successful monthly purchase maps to monthly active', () {
    final entitlement = entitlementFromPurchaseDetails(
      productId: kMonthlyPremiumProductId,
      status: PurchaseStatus.purchased,
      checkedAt: now,
    );

    expect(entitlement, isNotNull);
    expect(entitlement!.state, PremiumState.active);
    expect(entitlement.source, PremiumSource.monthly);
    expect(entitlement.hasPremiumAccessAt(now), isTrue);
  });

  test('successful yearly purchase maps to yearly active', () {
    final entitlement = entitlementFromPurchaseDetails(
      productId: kYearlyPremiumProductId,
      status: PurchaseStatus.restored,
      checkedAt: now,
    );

    expect(entitlement, isNotNull);
    expect(entitlement!.state, PremiumState.active);
    expect(entitlement.source, PremiumSource.yearly);
    expect(entitlement.hasPremiumAccessAt(now), isTrue);
  });

  test('pending purchase does not unlock Premium', () {
    final entitlement = entitlementFromPurchaseDetails(
      productId: kMonthlyPremiumProductId,
      status: PurchaseStatus.pending,
      checkedAt: now,
    );

    expect(entitlement, isNotNull);
    expect(entitlement!.state, PremiumState.pending);
    expect(entitlement.hasPremiumAccessAt(now), isFalse);
  });
}

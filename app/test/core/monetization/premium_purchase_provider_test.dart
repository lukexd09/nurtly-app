import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/monetization/premium_purchase_provider.dart';
import 'package:nurtly/core/monetization/purchase_result.dart';

void main() {
  test('local purchase provider is unavailable', () async {
    const provider = LocalPremiumPurchaseProvider();

    expect(provider.productCatalog.hasMonthly, isFalse);
    expect(provider.productCatalog.hasLifetime, isFalse);
    expect(await provider.buyMonthly(),
        const PurchaseActionResult(status: PurchaseActionStatus.unavailable));
    expect(await provider.buyLifetime(),
        const PurchaseActionResult(status: PurchaseActionStatus.unavailable));
    expect(await provider.restorePurchases(),
        const PurchaseActionResult(status: PurchaseActionStatus.unavailable));
  });
}

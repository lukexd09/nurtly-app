import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_product_ids.dart';
import 'premium_entitlement.dart';

PremiumEntitlement? entitlementFromPurchaseDetails({
  required String productId,
  required PurchaseStatus status,
  required DateTime checkedAt,
}) {
  final source = sourceForBillingProductId(productId);
  if (source == PremiumSource.none) {
    return null;
  }

  return switch (status) {
    PurchaseStatus.pending => PremiumEntitlement.pending(
        checkedAt: checkedAt,
        source: source,
      ),
    PurchaseStatus.purchased || PurchaseStatus.restored => switch (source) {
        PremiumSource.monthly =>
          PremiumEntitlement.monthlyActive(checkedAt: checkedAt),
        PremiumSource.lifetime =>
          PremiumEntitlement.lifetimeActive(checkedAt: checkedAt),
        PremiumSource.none => PremiumEntitlement.free(checkedAt: checkedAt),
      },
    PurchaseStatus.canceled || PurchaseStatus.error => null,
  };
}

PremiumSource sourceForBillingProductId(String productId) {
  return switch (productId) {
    kMonthlyPremiumProductId => PremiumSource.monthly,
    kLifetimePremiumProductId => PremiumSource.lifetime,
    _ => PremiumSource.none,
  };
}

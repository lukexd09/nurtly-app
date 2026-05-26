import 'premium_product_catalog.dart';
import 'purchase_result.dart';

abstract interface class PremiumPurchaseProvider {
  PremiumProductCatalog get productCatalog;

  Future<void> initialize();

  Future<PurchaseActionResult> buyMonthly();

  Future<PurchaseActionResult> buyLifetime();

  Future<PurchaseActionResult> restorePurchases();

  void dispose();
}

class LocalPremiumPurchaseProvider implements PremiumPurchaseProvider {
  const LocalPremiumPurchaseProvider();

  @override
  PremiumProductCatalog get productCatalog => PremiumProductCatalog.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<PurchaseActionResult> buyLifetime() async {
    return const PurchaseActionResult(status: PurchaseActionStatus.unavailable);
  }

  @override
  Future<PurchaseActionResult> buyMonthly() async {
    return const PurchaseActionResult(status: PurchaseActionStatus.unavailable);
  }

  @override
  Future<PurchaseActionResult> restorePurchases() async {
    return const PurchaseActionResult(status: PurchaseActionStatus.unavailable);
  }

  @override
  void dispose() {}
}

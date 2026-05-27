import 'package:nurtly/core/monetization/premium_product_catalog.dart';
import 'package:nurtly/core/monetization/premium_purchase_provider.dart';
import 'package:nurtly/core/monetization/purchase_result.dart';

class FakePremiumPurchaseProvider implements PremiumPurchaseProvider {
  FakePremiumPurchaseProvider({
    PremiumProductCatalog? productCatalog,
    this.buyMonthlyResult =
        const PurchaseActionResult(status: PurchaseActionStatus.success),
    this.buyYearlyResult =
        const PurchaseActionResult(status: PurchaseActionStatus.success),
    this.restorePurchasesResult =
        const PurchaseActionResult(status: PurchaseActionStatus.success),
  }) : _productCatalog = productCatalog ?? PremiumProductCatalog.empty();

  PremiumProductCatalog _productCatalog;
  final PurchaseActionResult buyMonthlyResult;
  final PurchaseActionResult buyYearlyResult;
  final PurchaseActionResult restorePurchasesResult;

  int initializeCalls = 0;
  int buyMonthlyCalls = 0;
  int buyYearlyCalls = 0;
  int restorePurchasesCalls = 0;

  void setProductCatalog(PremiumProductCatalog catalog) {
    _productCatalog = catalog;
  }

  @override
  PremiumProductCatalog get productCatalog => _productCatalog;

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<PurchaseActionResult> buyYearly() async {
    buyYearlyCalls++;
    return buyYearlyResult;
  }

  @override
  Future<PurchaseActionResult> buyMonthly() async {
    buyMonthlyCalls++;
    return buyMonthlyResult;
  }

  @override
  Future<PurchaseActionResult> restorePurchases() async {
    restorePurchasesCalls++;
    return restorePurchasesResult;
  }

  @override
  void dispose() {}
}

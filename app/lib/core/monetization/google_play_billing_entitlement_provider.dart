import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_product_ids.dart';
import 'billing_purchase_mapper.dart';
import 'google_play_billing_client.dart';
import 'premium_entitlement.dart';
import 'premium_entitlement_provider.dart';
import 'premium_product_catalog.dart';
import 'premium_purchase_provider.dart';
import 'purchase_result.dart';

class GooglePlayBillingEntitlementProvider extends ChangeNotifier
    implements PremiumEntitlementProvider, PremiumPurchaseProvider {
  GooglePlayBillingEntitlementProvider({
    GooglePlayBillingClient? billingClient,
  }) : _billingClient = billingClient ?? InAppPurchaseBillingClient();

  final GooglePlayBillingClient _billingClient;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  PremiumProductCatalog _productCatalog = PremiumProductCatalog.empty();
  PremiumEntitlement _entitlement = PremiumEntitlement.free();
  var _isInitialized = false;
  var _hasPurchaseSubscription = false;
  var _isSyncingPurchases = false;
  var _didReceivePurchaseUpdateDuringSync = false;

  @override
  PremiumProductCatalog get productCatalog => _productCatalog;

  PremiumEntitlement get currentEntitlement => _entitlement;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    final available = await _billingClient.isAvailable();
    if (!available) {
      _isInitialized = true;
      return;
    }

    _purchaseSubscription = _billingClient.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
    );
    _hasPurchaseSubscription = true;
    await _loadProductCatalog();
    _isInitialized = true;
  }

  @override
  Future<PremiumEntitlement> loadEntitlement() async {
    await initialize();
    final synced = await _syncPurchases();
    _applyNoPurchaseFallback(synced);
    return _entitlement;
  }

  @override
  Future<PremiumEntitlement> refreshEntitlement() async {
    await initialize();
    final synced = await _syncPurchases();
    _applyNoPurchaseFallback(synced);
    return _entitlement;
  }

  @override
  Future<PurchaseActionResult> buyMonthly() async {
    return _buyProduct(kMonthlyPremiumProductId);
  }

  @override
  Future<PurchaseActionResult> buyLifetime() async {
    return _buyProduct(kLifetimePremiumProductId);
  }

  @override
  Future<PurchaseActionResult> restorePurchases() async {
    await initialize();
    if (!await _billingClient.isAvailable()) {
      return const PurchaseActionResult(
        status: PurchaseActionStatus.unavailable,
      );
    }

    final synced = await _syncPurchases();
    if (!synced) {
      return const PurchaseActionResult(status: PurchaseActionStatus.error);
    }

    _applyNoPurchaseFallback(true);

    if (_entitlement.hasPremiumAccess) {
      return const PurchaseActionResult(status: PurchaseActionStatus.success);
    }

    return const PurchaseActionResult(
      status: PurchaseActionStatus.noPurchaseFound,
    );
  }

  Future<void> _loadProductCatalog() async {
    final response = await _billingClient.queryProductDetails({
      kMonthlyPremiumProductId,
      kLifetimePremiumProductId,
    });

    _productCatalog = PremiumProductCatalog(
      monthly: response.productDetails.firstWhereOrNull(
        (product) => product.id == kMonthlyPremiumProductId,
      ),
      lifetime: response.productDetails.firstWhereOrNull(
        (product) => product.id == kLifetimePremiumProductId,
      ),
    );
    notifyListeners();
  }

  Future<bool> _syncPurchases() async {
    if (_isSyncingPurchases) {
      return true;
    }

    _isSyncingPurchases = true;
    _didReceivePurchaseUpdateDuringSync = false;
    try {
      await _billingClient.restorePurchases();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSyncingPurchases = false;
    }
  }

  void _applyNoPurchaseFallback(bool synced) {
    if (!synced || _didReceivePurchaseUpdateDuringSync) {
      return;
    }

    if (_entitlement.hasPremiumAccess) {
      _entitlement = PremiumEntitlement.free(checkedAt: DateTime.now());
      notifyListeners();
    }
  }

  Future<PurchaseActionResult> _buyProduct(String productId) async {
    await initialize();
    if (!await _billingClient.isAvailable()) {
      return const PurchaseActionResult(
        status: PurchaseActionStatus.unavailable,
      );
    }

    final product = _productCatalog.productForId(productId);
    if (product == null) {
      return const PurchaseActionResult(
        status: PurchaseActionStatus.unavailable,
      );
    }

    try {
      final started = await _billingClient.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) {
        return const PurchaseActionResult(
            status: PurchaseActionStatus.canceled);
      }
      return const PurchaseActionResult(status: PurchaseActionStatus.pending);
    } catch (_) {
      return const PurchaseActionResult(status: PurchaseActionStatus.error);
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    var updated = false;

    for (final purchase in purchases) {
      final nextEntitlement = _entitlementFromPurchase(purchase);
      if (nextEntitlement != null) {
        _didReceivePurchaseUpdateDuringSync = true;
      }
      if (nextEntitlement != null &&
          !_isSameEntitlement(_entitlement, nextEntitlement)) {
        _entitlement = nextEntitlement;
        updated = true;
      }

      if (purchase.pendingCompletePurchase) {
        unawaited(_billingClient.completePurchase(purchase));
      }
    }

    if (updated) {
      notifyListeners();
    }
  }

  bool _isSameEntitlement(
    PremiumEntitlement left,
    PremiumEntitlement right,
  ) {
    return left.state == right.state &&
        left.source == right.source &&
        left.expiresAt == right.expiresAt;
  }

  PremiumEntitlement? _entitlementFromPurchase(PurchaseDetails purchase) {
    final now = DateTime.now();
    return entitlementFromPurchaseDetails(
      productId: purchase.productID,
      status: purchase.status,
      checkedAt: now,
    );
  }

  @override
  void dispose() {
    if (_hasPurchaseSubscription) {
      unawaited(_purchaseSubscription.cancel());
    }
    super.dispose();
  }
}

extension _IterableFirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final value in this) {
      if (test(value)) {
        return value;
      }
    }
    return null;
  }
}

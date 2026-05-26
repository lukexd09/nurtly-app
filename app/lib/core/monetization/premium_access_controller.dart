import 'dart:async';

import 'package:flutter/foundation.dart';

import 'premium_entitlement.dart';
import 'premium_entitlement_provider.dart';
import 'premium_product_catalog.dart';
import 'premium_purchase_provider.dart';
import 'purchase_result.dart';

class PremiumAccessController extends ChangeNotifier {
  PremiumAccessController({
    required PremiumEntitlementProvider provider,
    PremiumPurchaseProvider? purchaseProvider,
  })  : _provider = provider,
        _purchaseProvider = purchaseProvider {
    _provider.addListener(_handleProviderUpdate);
  }

  final PremiumEntitlementProvider _provider;
  final PremiumPurchaseProvider? _purchaseProvider;
  PremiumEntitlement _entitlement = PremiumEntitlement.free();
  bool _hasLoaded = false;

  PremiumEntitlement get entitlement => _entitlement;

  bool get hasPremiumAccess => _entitlement.hasPremiumAccess;

  bool get shouldShowAds => _entitlement.shouldShowAds;

  bool get canAccessPremiumContent => _entitlement.canAccessPremiumContent;

  PremiumProductCatalog get productCatalog =>
      _purchaseProvider?.productCatalog ?? PremiumProductCatalog.empty();

  Future<void> load() async {
    _entitlement = await _safeLoad(
      _provider.loadEntitlement,
      fallback: PremiumEntitlement.free(),
    );
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    _entitlement = await _safeLoad(
      _provider.refreshEntitlement,
      fallback: _entitlement,
    );
    notifyListeners();
  }

  Future<PurchaseActionResult> restorePurchases() async {
    final purchaseProvider = _purchaseProvider;
    if (purchaseProvider == null) {
      await refresh();
      return const PurchaseActionResult(
        status: PurchaseActionStatus.unavailable,
      );
    }

    final result = await purchaseProvider.restorePurchases();
    if (result.status != PurchaseActionStatus.unavailable) {
      await refresh();
    }
    return result;
  }

  Future<PurchaseActionResult> buyMonthly() async {
    final purchaseProvider = _purchaseProvider;
    if (purchaseProvider == null) {
      return const PurchaseActionResult(
        status: PurchaseActionStatus.unavailable,
      );
    }

    final result = await purchaseProvider.buyMonthly();
    if (result.status != PurchaseActionStatus.unavailable) {
      await refresh();
    }
    return result;
  }

  Future<PurchaseActionResult> buyLifetime() async {
    final purchaseProvider = _purchaseProvider;
    if (purchaseProvider == null) {
      return const PurchaseActionResult(
        status: PurchaseActionStatus.unavailable,
      );
    }

    final result = await purchaseProvider.buyLifetime();
    if (result.status != PurchaseActionStatus.unavailable) {
      await refresh();
    }
    return result;
  }

  Future<PremiumEntitlement> _safeLoad(
    Future<PremiumEntitlement> Function() loader, {
    required PremiumEntitlement fallback,
  }) async {
    try {
      return await loader();
    } catch (_) {
      return fallback;
    }
  }

  bool get hasLoaded => _hasLoaded;

  @override
  void dispose() {
    _provider.removeListener(_handleProviderUpdate);
    super.dispose();
  }

  void _handleProviderUpdate() {
    if (!_hasLoaded) {
      return;
    }
    unawaited(refresh());
  }
}

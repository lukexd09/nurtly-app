import 'dart:async';

import 'package:flutter/foundation.dart';

import 'premium_entitlement.dart';
import 'premium_entitlement_provider.dart';
import 'premium_product_catalog.dart';
import 'reviewer_access_code.dart';
import 'premium_purchase_provider.dart';
import 'purchase_result.dart';
import '../localization/language_preference_store.dart';

class PremiumAccessController extends ChangeNotifier {
  PremiumAccessController({
    required PremiumEntitlementProvider provider,
    PremiumPurchaseProvider? purchaseProvider,
    ReviewerAccessStore? reviewerAccessStore,
  })  : _provider = provider,
        _purchaseProvider = purchaseProvider,
        _reviewerAccessStore = reviewerAccessStore ??
            const SharedPreferencesReviewerAccessStore() {
    _provider.addListener(_handleProviderUpdate);
  }

  final PremiumEntitlementProvider _provider;
  final PremiumPurchaseProvider? _purchaseProvider;
  late final ReviewerAccessStore _reviewerAccessStore;
  PremiumEntitlement _entitlement = PremiumEntitlement.free();
  bool _hasLoaded = false;

  PremiumEntitlement get entitlement => _entitlement;

  bool get hasPremiumAccess => _entitlement.hasPremiumAccess;

  bool get shouldShowAds => _entitlement.shouldShowAds;

  bool get canAccessPremiumContent => _entitlement.canAccessPremiumContent;

  PremiumProductCatalog get productCatalog =>
      _purchaseProvider?.productCatalog ?? PremiumProductCatalog.empty();

  Future<void> load() async {
    final reviewerAccessEnabled = await _safeLoadBool(
      _reviewerAccessStore.load,
      fallback: false,
    );
    _entitlement = (await _safeLoad(
      _provider.loadEntitlement,
      fallback: PremiumEntitlement.free(),
    ))
        .withReviewerAccess(reviewerAccessEnabled);
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    final updated = await _safeLoad(
      _provider.refreshEntitlement,
      fallback: _entitlement,
    );
    _entitlement =
        updated.withReviewerAccess(_entitlement.reviewerAccessEnabled);
    notifyListeners();
  }

  Future<void> enableReviewerAccess(String code) async {
    if (!_isValidReviewerCode(code)) {
      return;
    }
    await _reviewerAccessStore.save(true);
    _entitlement = _entitlement.withReviewerAccess(true);
    notifyListeners();
  }

  Future<void> disableReviewerAccess() async {
    await _reviewerAccessStore.delete();
    if (_entitlement.reviewerAccessEnabled) {
      _entitlement = _entitlement.withReviewerAccess(false);
      notifyListeners();
    }
  }

  bool get reviewerAccessEnabled => _entitlement.reviewerAccessEnabled;

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

  Future<PurchaseActionResult> buyYearly() async {
    final purchaseProvider = _purchaseProvider;
    if (purchaseProvider == null) {
      return const PurchaseActionResult(
        status: PurchaseActionStatus.unavailable,
      );
    }

    final result = await purchaseProvider.buyYearly();
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

  Future<bool> _safeLoadBool(
    Future<bool> Function() loader, {
    required bool fallback,
  }) async {
    try {
      return await loader();
    } catch (_) {
      return fallback;
    }
  }

  bool _isValidReviewerCode(String code) {
    return code.trim() == reviewerAccessCode;
  }

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

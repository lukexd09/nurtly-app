import 'package:flutter/foundation.dart';

import 'premium_entitlement.dart';
import 'premium_entitlement_provider.dart';

class PremiumAccessController extends ChangeNotifier {
  PremiumAccessController({
    required PremiumEntitlementProvider provider,
  }) : _provider = provider;

  final PremiumEntitlementProvider _provider;
  PremiumEntitlement _entitlement = PremiumEntitlement.free();

  PremiumEntitlement get entitlement => _entitlement;

  bool get hasPremiumAccess => _entitlement.hasPremiumAccess;

  bool get shouldShowAds => _entitlement.shouldShowAds;

  bool get canAccessPremiumContent => _entitlement.canAccessPremiumContent;

  Future<void> load() async {
    _entitlement = await _safeLoad(_provider.loadEntitlement);
    notifyListeners();
  }

  Future<void> refresh() async {
    _entitlement = await _safeLoad(_provider.refreshEntitlement);
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    await refresh();
  }

  Future<PremiumEntitlement> _safeLoad(
    Future<PremiumEntitlement> Function() loader,
  ) async {
    try {
      return await loader();
    } catch (_) {
      return PremiumEntitlement.free();
    }
  }
}

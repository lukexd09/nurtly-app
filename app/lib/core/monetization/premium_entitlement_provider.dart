import 'premium_entitlement.dart';

abstract interface class PremiumEntitlementProvider {
  Future<PremiumEntitlement> loadEntitlement();

  Future<PremiumEntitlement> refreshEntitlement();
}

class LocalPremiumEntitlementProvider implements PremiumEntitlementProvider {
  const LocalPremiumEntitlementProvider();

  @override
  Future<PremiumEntitlement> loadEntitlement() async {
    return PremiumEntitlement.free();
  }

  @override
  Future<PremiumEntitlement> refreshEntitlement() async {
    return PremiumEntitlement.free();
  }
}

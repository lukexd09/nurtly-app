import 'premium_entitlement.dart';

import 'package:flutter/foundation.dart';

abstract interface class PremiumEntitlementProvider extends Listenable {
  Future<PremiumEntitlement> loadEntitlement();

  Future<PremiumEntitlement> refreshEntitlement();
}

class LocalPremiumEntitlementProvider extends ChangeNotifier
    implements PremiumEntitlementProvider {
  LocalPremiumEntitlementProvider();

  @override
  Future<PremiumEntitlement> loadEntitlement() async {
    return PremiumEntitlement.free();
  }

  @override
  Future<PremiumEntitlement> refreshEntitlement() async {
    return PremiumEntitlement.free();
  }
}

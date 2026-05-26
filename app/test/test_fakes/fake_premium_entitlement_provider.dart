import 'package:nurtly/core/monetization/premium_entitlement.dart';
import 'package:nurtly/core/monetization/premium_entitlement_provider.dart';

class FakePremiumEntitlementProvider implements PremiumEntitlementProvider {
  FakePremiumEntitlementProvider({
    PremiumEntitlement? loadEntitlement,
    PremiumEntitlement? refreshEntitlement,
    this.failOnLoad = false,
    this.failOnRefresh = false,
  })  : _loadEntitlement = loadEntitlement ?? PremiumEntitlement.free(),
        _refreshEntitlement =
            refreshEntitlement ?? loadEntitlement ?? PremiumEntitlement.free();

  PremiumEntitlement _loadEntitlement;
  PremiumEntitlement _refreshEntitlement;
  final bool failOnLoad;
  final bool failOnRefresh;

  int loadCalls = 0;
  int refreshCalls = 0;

  void setLoadEntitlement(PremiumEntitlement entitlement) {
    _loadEntitlement = entitlement;
  }

  void setRefreshEntitlement(PremiumEntitlement entitlement) {
    _refreshEntitlement = entitlement;
  }

  @override
  Future<PremiumEntitlement> loadEntitlement() async {
    loadCalls++;
    if (failOnLoad) {
      throw StateError('load failed');
    }
    return _loadEntitlement;
  }

  @override
  Future<PremiumEntitlement> refreshEntitlement() async {
    refreshCalls++;
    if (failOnRefresh) {
      throw StateError('refresh failed');
    }
    return _refreshEntitlement;
  }
}

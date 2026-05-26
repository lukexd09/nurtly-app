import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app_config.dart';
import 'core/ads/ad_widget_factory.dart';
import 'core/monetization/google_play_billing_entitlement_provider.dart';
import 'core/monetization/premium_entitlement_provider.dart';
import 'core/monetization/premium_purchase_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_shell.dart';

void main() {
  unawaited(MobileAds.instance.initialize());
  final billing = GooglePlayBillingEntitlementProvider();
  runApp(
    NurtlyApp(
      premiumProvider: billing,
      purchaseProvider: billing,
      adWidgetFactory: const RealAdWidgetFactory(),
    ),
  );
}

class NurtlyApp extends StatelessWidget {
  NurtlyApp({
    PremiumEntitlementProvider? premiumProvider,
    PremiumPurchaseProvider? purchaseProvider,
    AdWidgetFactory? adWidgetFactory,
    super.key,
  })  : premiumProvider = premiumProvider ?? LocalPremiumEntitlementProvider(),
        purchaseProvider =
            purchaseProvider ?? const LocalPremiumPurchaseProvider(),
        adWidgetFactory = adWidgetFactory ?? const FakeAdWidgetFactory();

  final PremiumEntitlementProvider premiumProvider;
  final PremiumPurchaseProvider purchaseProvider;
  final AdWidgetFactory adWidgetFactory;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppShell(
        premiumEntitlementProvider: premiumProvider,
        premiumPurchaseProvider: purchaseProvider,
        adWidgetFactory: adWidgetFactory,
      ),
    );
  }
}

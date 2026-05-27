import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app_config.dart';
import 'core/ads/ad_widget_factory.dart';
import 'core/monetization/google_play_billing_entitlement_provider.dart';
import 'core/monetization/premium_entitlement_provider.dart';
import 'core/monetization/premium_purchase_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_shell.dart';

void main() {
  final isAndroidRuntime =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  GooglePlayBillingEntitlementProvider? billing;
  if (isAndroidRuntime) {
    unawaited(MobileAds.instance.initialize());
    billing = GooglePlayBillingEntitlementProvider();
  }
  final PremiumEntitlementProvider premiumProvider =
      billing ?? LocalPremiumEntitlementProvider();
  final PremiumPurchaseProvider purchaseProvider =
      billing ?? const LocalPremiumPurchaseProvider();
  runApp(
    NurtlyApp(
      premiumProvider: premiumProvider,
      purchaseProvider: purchaseProvider,
      adWidgetFactory: isAndroidRuntime
          ? const RealAdWidgetFactory()
          : const FakeAdWidgetFactory(),
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

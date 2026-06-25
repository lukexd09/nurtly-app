import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app_config.dart';
import 'core/ads/consent_flow_controller.dart';
import 'core/ads/ad_widget_factory.dart';
import 'core/monetization/google_play_billing_entitlement_provider.dart';
import 'core/monetization/premium_entitlement_provider.dart';
import 'core/monetization/premium_purchase_provider.dart';
import 'core/localization/language_preference_store.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_shell.dart';
import 'core/localization/app_language.dart';

void main() {
  final isAndroidRuntime =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  GooglePlayBillingEntitlementProvider? billing;
  final consentFlow = isAndroidRuntime
      ? GoogleConsentFlow(debugGeographyEnabled: true)
      : const NoopConsentFlow();
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
      consentFlow: consentFlow,
      adWidgetFactory: isAndroidRuntime
          ? RealAdWidgetFactory(consentFlow: consentFlow)
          : const FakeAdWidgetFactory(),
    ),
  );
}

class NurtlyApp extends StatefulWidget {
  NurtlyApp({
    this.languagePreferenceStore,
    PremiumEntitlementProvider? premiumProvider,
    PremiumPurchaseProvider? purchaseProvider,
    AdWidgetFactory? adWidgetFactory,
    ConsentFlow? consentFlow,
    super.key,
  })  : premiumProvider = premiumProvider ?? LocalPremiumEntitlementProvider(),
        purchaseProvider =
            purchaseProvider ?? const LocalPremiumPurchaseProvider(),
        consentFlow = consentFlow ?? const NoopConsentFlow(),
        adWidgetFactory = adWidgetFactory ?? const FakeAdWidgetFactory();

  final LanguagePreferenceStore? languagePreferenceStore;
  final PremiumEntitlementProvider premiumProvider;
  final PremiumPurchaseProvider purchaseProvider;
  final ConsentFlow consentFlow;
  final AdWidgetFactory adWidgetFactory;

  @override
  State<NurtlyApp> createState() => _NurtlyAppState();
}

class _NurtlyAppState extends State<NurtlyApp> {
  Locale? _locale;

  void _handleLocaleChanged(AppLanguage language) {
    final nextLocale = Locale(language.languageCode);
    if (_locale == nextLocale) {
      return;
    }
    setState(() {
      _locale = nextLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pl')],
      home: AppShell(
        languagePreferenceStore: widget.languagePreferenceStore,
        premiumEntitlementProvider: widget.premiumProvider,
        premiumPurchaseProvider: widget.purchaseProvider,
        consentFlow: widget.consentFlow,
        adWidgetFactory: widget.adWidgetFactory,
        onLanguageChanged: _handleLocaleChanged,
      ),
    );
  }
}

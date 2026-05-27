import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:nurtly/core/localization/app_language.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/core/monetization/billing_product_ids.dart';
import 'package:nurtly/core/monetization/premium_access_controller.dart';
import 'package:nurtly/core/monetization/premium_entitlement.dart';
import 'package:nurtly/core/monetization/premium_paywall_sheet.dart';
import 'package:nurtly/core/monetization/premium_product_catalog.dart';
import 'package:nurtly/core/theme/app_theme.dart';

import '../../test_fakes/fake_premium_entitlement_provider.dart';
import '../../test_fakes/fake_premium_purchase_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'paywall keeps launch-offer note when product details are loaded',
    (tester) async {
      final controller = PremiumAccessController(
        provider: FakePremiumEntitlementProvider(
          loadEntitlement: PremiumEntitlement.free(),
        ),
        purchaseProvider: FakePremiumPurchaseProvider(
          productCatalog: PremiumProductCatalog(
            yearly: _product(
              id: kYearlyPremiumProductId,
              title: 'Google Play yearly title',
              description: 'Google Play yearly description',
              price: '129.99 PLN',
            ),
            monthly: _product(
              id: kMonthlyPremiumProductId,
              title: 'Google Play monthly title',
              description: 'Google Play monthly description',
              price: '14.99 PLN',
            ),
          ),
        ),
      );

      await controller.load();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: PremiumPaywallScreen(
            strings: AppStrings.forLanguage(AppLanguage.english),
            controller: controller,
            onRestoreAccess: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('premium-paywall-yearly-title')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('premium-paywall-monthly-title')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('premium-paywall-yearly-price')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('premium-paywall-monthly-price')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('premium-paywall-yearly-note')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('premium-paywall-monthly-note')),
        findsOneWidget,
      );
      expect(find.text('129.99 PLN'), findsOneWidget);
      expect(find.text('14.99 PLN'), findsOneWidget);
      expect(
        find.text('Launch price, regular price 129.99 PLN / year'),
        findsOneWidget,
      );
      expect(
        find.text('Launch price, regular price 14.99 PLN / month'),
        findsOneWidget,
      );
      expect(find.text('Google Play yearly description'), findsNothing);
      expect(find.text('Google Play monthly description'), findsNothing);
      expect(find.text('Google Play yearly title'), findsNothing);
      expect(find.text('Google Play monthly title'), findsNothing);
    },
  );
}

ProductDetails _product({
  required String id,
  required String title,
  required String description,
  required String price,
}) {
  return ProductDetails(
    id: id,
    title: title,
    description: description,
    price: price,
    rawPrice: 0,
    currencyCode: 'PLN',
    currencySymbol: 'PLN',
  );
}

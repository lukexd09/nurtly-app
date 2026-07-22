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
import 'package:nurtly/core/monetization/purchase_result.dart';
import 'package:nurtly/core/theme/app_theme.dart';

import '../../test_fakes/fake_premium_entitlement_provider.dart';
import '../../test_fakes/fake_premium_purchase_provider.dart';
import '../../test_fakes/fake_reviewer_access_store.dart';

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
        reviewerAccessStore: FakeReviewerAccessStore(),
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

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

  testWidgets('unavailable purchase remains visible and can be retried',
      (tester) async {
    final purchases = FakePremiumPurchaseProvider(
      buyMonthlyResult: const PurchaseActionResult(
        status: PurchaseActionStatus.unavailable,
      ),
    );
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.free(),
      ),
      purchaseProvider: purchases,
      reviewerAccessStore: FakeReviewerAccessStore(),
    );
    await controller.load();
    await controller.buyMonthly();
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

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('premium-paywall-retry')),
      200,
    );
    expect(find.byKey(const ValueKey('premium-paywall-retry')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('premium-paywall-retry')));
    await tester.pumpAndSettle();
    expect(purchases.buyMonthlyCalls, 2);
  });

  testWidgets('Polish unavailable feedback stays readable on a narrow layout',
      (tester) async {
    final purchases = FakePremiumPurchaseProvider(
      buyYearlyResult: const PurchaseActionResult(
        status: PurchaseActionStatus.unavailable,
      ),
    );
    final controller = PremiumAccessController(
      provider: FakePremiumEntitlementProvider(
        loadEntitlement: PremiumEntitlement.free(),
      ),
      purchaseProvider: purchases,
      reviewerAccessStore: FakeReviewerAccessStore(),
    );
    await controller.load();
    await controller.buyYearly();

    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.25)),
        child: MaterialApp(
          theme: AppTheme.light,
          home: PremiumPaywallScreen(
            strings: AppStrings.polish,
            controller: controller,
            onRestoreAccess: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('premium-paywall-retry')),
      200,
    );
    expect(find.byKey(const ValueKey('premium-paywall-retry')), findsOneWidget);
    expect(
      find.textContaining('Zakupy są chwilowo niedostępne'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
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

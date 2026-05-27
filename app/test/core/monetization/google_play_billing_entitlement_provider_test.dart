import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:nurtly/core/monetization/billing_product_ids.dart';
import 'package:nurtly/core/monetization/google_play_billing_client.dart';
import 'package:nurtly/core/monetization/google_play_billing_entitlement_provider.dart';
import 'package:nurtly/core/monetization/premium_access_controller.dart';
import 'package:nurtly/core/monetization/premium_entitlement.dart';
import 'package:nurtly/core/monetization/purchase_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'restore with no purchase after previous premium returns noPurchaseFound, not success',
    () async {
      final client = FakeGooglePlayBillingClient(
        restoreEventsByCall: const [
          [],
          [],
        ],
      );
      final provider = GooglePlayBillingEntitlementProvider(
        billingClient: client,
      );

      await provider.loadEntitlement();
      client.emit([
        _purchase(
          productId: kLifetimePremiumProductId,
          status: PurchaseStatus.restored,
        ),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentEntitlement.state, PremiumState.active);

      final result = await provider.restorePurchases();

      expect(result.status, PurchaseActionStatus.noPurchaseFound);
      expect(provider.currentEntitlement.state, PremiumState.free);
    },
  );

  test('refresh provider update does not loop infinitely', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        const [],
        [
          _purchase(
            productId: kLifetimePremiumProductId,
            status: PurchaseStatus.restored,
          ),
        ],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );
    final controller = PremiumAccessController(provider: provider);

    await controller.load();
    client.emit([
      _purchase(
        productId: kLifetimePremiumProductId,
        status: PurchaseStatus.restored,
      ),
    ]);
    await _waitFor(() => controller.hasPremiumAccess);

    expect(controller.hasPremiumAccess, isTrue);
    expect(client.restorePurchasesCalls, 2);
  });

  test('restore error preserves existing premium entitlement', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kLifetimePremiumProductId,
            status: PurchaseStatus.restored,
          ),
        ],
      ],
      throwOnRestoreCalls: {2},
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    final result = await provider.restorePurchases();

    expect(result.status, PurchaseActionStatus.error);
    expect(provider.currentEntitlement.state, PremiumState.active);
    expect(provider.currentEntitlement.source, PremiumSource.lifetime);
  });

  test('confirmed no active purchase clears stale premium entitlement',
      () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kLifetimePremiumProductId,
            status: PurchaseStatus.restored,
          ),
        ],
        const [],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    final refreshed = await provider.refreshEntitlement();

    expect(refreshed.state, PremiumState.free);
    expect(provider.currentEntitlement.state, PremiumState.free);
  });

  test('pending purchase still does not unlock premium', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kMonthlyPremiumProductId,
            status: PurchaseStatus.pending,
          ),
        ],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();

    expect(provider.currentEntitlement.state, PremiumState.pending);
    expect(provider.currentEntitlement.hasPremiumAccess, isFalse);
  });

  test('confirmed no active purchase clears stale pending entitlement',
      () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kMonthlyPremiumProductId,
            status: PurchaseStatus.pending,
          ),
        ],
        const [],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    expect(provider.currentEntitlement.state, PremiumState.pending);

    final refreshed = await provider.refreshEntitlement();

    expect(refreshed.state, PremiumState.free);
    expect(provider.currentEntitlement.state, PremiumState.free);
    expect(provider.currentEntitlement.hasPremiumAccess, isFalse);
  });
}

class FakeGooglePlayBillingClient implements GooglePlayBillingClient {
  FakeGooglePlayBillingClient({
    this.restoreEventsByCall = const [],
    this.throwOnRestoreCalls = const {},
    this.available = true,
  });

  final List<List<PurchaseDetails>> restoreEventsByCall;
  final Set<int> throwOnRestoreCalls;
  final bool available;

  final StreamController<List<PurchaseDetails>> _purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();
  int restorePurchasesCalls = 0;
  int completePurchaseCalls = 0;
  int buyNonConsumableCalls = 0;

  void emit(List<PurchaseDetails> purchases) {
    _purchaseController.add(purchases);
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseController.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    final products = <ProductDetails>[
      if (identifiers.contains(kMonthlyPremiumProductId))
        _product(
          id: kMonthlyPremiumProductId,
          title: 'Monthly',
          description: 'Monthly premium',
          price: '14.99 PLN',
        ),
      if (identifiers.contains(kLifetimePremiumProductId))
        _product(
          id: kLifetimePremiumProductId,
          title: 'Lifetime',
          description: 'Lifetime premium',
          price: '129.99 PLN',
        ),
    ];

    return ProductDetailsResponse(
      productDetails: products,
      notFoundIDs: const [],
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyNonConsumableCalls++;
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completePurchaseCalls++;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restorePurchasesCalls++;
    if (throwOnRestoreCalls.contains(restorePurchasesCalls)) {
      throw StateError('restore failed');
    }

    final index = restorePurchasesCalls - 1;
    if (index < restoreEventsByCall.length) {
      _purchaseController.add(restoreEventsByCall[index]);
    }
  }

  Future<String> countryCode() async => 'US';

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
}

PurchaseDetails _purchase({
  required String productId,
  required PurchaseStatus status,
}) {
  return PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: '0',
    status: status,
  );
}

Future<void> _waitFor(bool Function() predicate) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

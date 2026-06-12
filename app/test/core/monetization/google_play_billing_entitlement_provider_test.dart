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
          productId: kYearlyPremiumProductId,
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
            productId: kYearlyPremiumProductId,
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
        productId: kYearlyPremiumProductId,
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
            productId: kYearlyPremiumProductId,
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
    expect(provider.currentEntitlement.source, PremiumSource.yearly);
  });

  test('confirmed no active purchase clears stale premium entitlement',
      () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kYearlyPremiumProductId,
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

  test('monthly pending then canceled clears to free', () async {
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
    client.emit([
      _purchase(
        productId: kMonthlyPremiumProductId,
        status: PurchaseStatus.canceled,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentEntitlement.state, PremiumState.free);
    expect(provider.currentEntitlement.hasPremiumAccess, isFalse);
  });

  test('monthly pending then error clears to free', () async {
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
    client.emit([
      _purchase(
        productId: kMonthlyPremiumProductId,
        status: PurchaseStatus.error,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentEntitlement.state, PremiumState.free);
    expect(provider.currentEntitlement.hasPremiumAccess, isFalse);
  });

  test('restore waits for delayed purchase update before clearing state',
      () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kYearlyPremiumProductId,
            status: PurchaseStatus.restored,
          ),
        ],
      ],
      restoreEventDelay: const Duration(milliseconds: 400),
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    final entitlement = await provider.loadEntitlement();

    expect(entitlement.state, PremiumState.active);
    expect(provider.currentEntitlement.state, PremiumState.active);
    expect(provider.currentEntitlement.source, PremiumSource.yearly);
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

  test('yearly pending then canceled clears to free', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kYearlyPremiumProductId,
            status: PurchaseStatus.pending,
          ),
        ],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    client.emit([
      _purchase(
        productId: kYearlyPremiumProductId,
        status: PurchaseStatus.canceled,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentEntitlement.state, PremiumState.free);
    expect(provider.currentEntitlement.hasPremiumAccess, isFalse);
  });

  test('yearly pending then error clears to free', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kYearlyPremiumProductId,
            status: PurchaseStatus.pending,
          ),
        ],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    client.emit([
      _purchase(
        productId: kYearlyPremiumProductId,
        status: PurchaseStatus.error,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentEntitlement.state, PremiumState.free);
    expect(provider.currentEntitlement.hasPremiumAccess, isFalse);
  });

  test('canceled event does not revoke active premium entitlement', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kYearlyPremiumProductId,
            status: PurchaseStatus.restored,
          ),
        ],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    client.emit([
      _purchase(
        productId: kYearlyPremiumProductId,
        status: PurchaseStatus.canceled,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentEntitlement.state, PremiumState.active);
    expect(provider.currentEntitlement.source, PremiumSource.yearly);
  });

  test('error event does not revoke active premium entitlement', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kYearlyPremiumProductId,
            status: PurchaseStatus.restored,
          ),
        ],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    client.emit([
      _purchase(
        productId: kYearlyPremiumProductId,
        status: PurchaseStatus.error,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentEntitlement.state, PremiumState.active);
    expect(provider.currentEntitlement.source, PremiumSource.yearly);
  });

  test('unknown product updates do not change entitlement', () async {
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
    final before = provider.currentEntitlement;
    client.emit([
      _purchase(
        productId: 'unknown.product',
        status: PurchaseStatus.pending,
      ),
      _purchase(
        productId: 'unknown.product',
        status: PurchaseStatus.canceled,
      ),
      _purchase(
        productId: 'unknown.product',
        status: PurchaseStatus.error,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentEntitlement.state, before.state);
    expect(provider.currentEntitlement.source, before.source);
  });

  test('delayed restored callback still grants Premium', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kYearlyPremiumProductId,
            status: PurchaseStatus.restored,
          ),
        ],
      ],
      restoreEventDelay: const Duration(milliseconds: 400),
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    final entitlement = await provider.loadEntitlement();

    expect(entitlement.state, PremiumState.active);
    expect(provider.currentEntitlement.state, PremiumState.active);
    expect(provider.currentEntitlement.source, PremiumSource.yearly);
  });

  test(
      'restore timeout with no valid purchase results in free and noPurchaseFound',
      () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: const [
        [],
      ],
      restoreEventDelay: const Duration(seconds: 3),
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    final result = await provider.restorePurchases();

    expect(result.status, PurchaseActionStatus.noPurchaseFound);
    expect(provider.currentEntitlement.state, PremiumState.free);
    provider.dispose();
    await Future<void>.delayed(Duration.zero);
  });

  test('duplicate restored updates remain idempotent', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: const [
        [],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    client.emit([
      _purchase(
        productId: kYearlyPremiumProductId,
        status: PurchaseStatus.restored,
      ),
      _purchase(
        productId: kYearlyPremiumProductId,
        status: PurchaseStatus.restored,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.currentEntitlement.state, PremiumState.active);
    expect(provider.currentEntitlement.source, PremiumSource.yearly);
  });

  test('pendingCompletePurchase is completed safely', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kMonthlyPremiumProductId,
            status: PurchaseStatus.purchased,
            pendingCompletePurchase: true,
          ),
        ],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();

    expect(provider.currentEntitlement.state, PremiumState.active);
    expect(client.completePurchaseCalls, 1);
  });

  test('completion failure does not crash or corrupt entitlement', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: [
        [
          _purchase(
            productId: kYearlyPremiumProductId,
            status: PurchaseStatus.restored,
            pendingCompletePurchase: true,
          ),
        ],
      ],
      throwOnCompleteCalls: {1},
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();

    expect(provider.currentEntitlement.state, PremiumState.active);
    expect(provider.currentEntitlement.source, PremiumSource.yearly);
    expect(client.completePurchaseCalls, 1);
  });

  test(
      'store unavailable keeps entitlement free and purchase actions unavailable',
      () async {
    final client = FakeGooglePlayBillingClient(available: false);
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    final entitlement = await provider.loadEntitlement();
    final restoreResult = await provider.restorePurchases();
    final monthlyResult = await provider.buyMonthly();
    final yearlyResult = await provider.buyYearly();

    expect(entitlement.state, PremiumState.free);
    expect(restoreResult.status, PurchaseActionStatus.unavailable);
    expect(monthlyResult.status, PurchaseActionStatus.unavailable);
    expect(yearlyResult.status, PurchaseActionStatus.unavailable);
    expect(provider.productCatalog.hasMonthly, isFalse);
    expect(provider.productCatalog.hasYearly, isFalse);
  });

  test('product query error falls back to empty catalog', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: const [
        [],
      ],
      throwOnQueryCalls: {1},
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();

    expect(provider.productCatalog.hasMonthly, isFalse);
    expect(provider.productCatalog.hasYearly, isFalse);
    expect(await provider.buyMonthly(), isUnavailablePurchase());
    expect(await provider.buyYearly(), isUnavailablePurchase());
  });

  test('partial monthly product catalog keeps yearly available', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: const [
        [],
      ],
      hasMonthlyProduct: false,
      hasYearlyProduct: true,
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();

    expect(provider.productCatalog.hasMonthly, isFalse);
    expect(provider.productCatalog.hasYearly, isTrue);
    expect(await provider.buyMonthly(), isUnavailablePurchase());
  });

  test('partial yearly product catalog keeps monthly available', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: const [
        [],
      ],
      hasMonthlyProduct: true,
      hasYearlyProduct: false,
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();

    expect(provider.productCatalog.hasMonthly, isTrue);
    expect(provider.productCatalog.hasYearly, isFalse);
    expect(await provider.buyYearly(), isUnavailablePurchase());
  });

  test('purchase start returning false is canceled without corrupting state',
      () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: const [
        [],
      ],
      buyNonConsumableResult: false,
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    final result = await provider.buyMonthly();

    expect(result.status, PurchaseActionStatus.canceled);
    expect(provider.currentEntitlement.state, PremiumState.free);
    expect(client.buyNonConsumableCalls, 1);
  });

  test('purchase start exception is reported as error without corrupting state',
      () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: const [
        [],
      ],
      throwOnBuyCalls: {1},
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    final result = await provider.buyYearly();

    expect(result.status, PurchaseActionStatus.error);
    expect(provider.currentEntitlement.state, PremiumState.free);
    expect(client.buyNonConsumableCalls, 1);
  });

  test('provider disposal cancels the purchase subscription', () async {
    final client = FakeGooglePlayBillingClient(
      restoreEventsByCall: const [
        [],
      ],
    );
    final provider = GooglePlayBillingEntitlementProvider(
      billingClient: client,
    );

    await provider.loadEntitlement();
    provider.dispose();
    await Future<void>.delayed(Duration.zero);

    expect(client.purchaseStreamCancelCalls, 1);
  });
}

class FakeGooglePlayBillingClient implements GooglePlayBillingClient {
  FakeGooglePlayBillingClient({
    this.restoreEventsByCall = const [],
    this.throwOnRestoreCalls = const {},
    this.available = true,
    this.restoreEventDelay = Duration.zero,
    this.throwOnQueryCalls = const {},
    this.hasMonthlyProduct = true,
    this.hasYearlyProduct = true,
    this.buyNonConsumableResult = true,
    this.throwOnBuyCalls = const {},
    this.throwOnCompleteCalls = const {},
  }) {
    _purchaseController = StreamController<List<PurchaseDetails>>.broadcast(
      onCancel: () {
        purchaseStreamCancelCalls++;
      },
    );
  }

  final List<List<PurchaseDetails>> restoreEventsByCall;
  final Set<int> throwOnRestoreCalls;
  final bool available;
  final Duration restoreEventDelay;
  final Set<int> throwOnQueryCalls;
  final bool hasMonthlyProduct;
  final bool hasYearlyProduct;
  final bool buyNonConsumableResult;
  final Set<int> throwOnBuyCalls;
  final Set<int> throwOnCompleteCalls;

  late final StreamController<List<PurchaseDetails>> _purchaseController;
  int restorePurchasesCalls = 0;
  int queryProductDetailsCalls = 0;
  int completePurchaseCalls = 0;
  int buyNonConsumableCalls = 0;
  int purchaseStreamCancelCalls = 0;

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
    queryProductDetailsCalls++;
    if (throwOnQueryCalls.contains(queryProductDetailsCalls)) {
      throw StateError('query failed');
    }

    final products = <ProductDetails>[
      if (identifiers.contains(kMonthlyPremiumProductId) && hasMonthlyProduct)
        _product(
          id: kMonthlyPremiumProductId,
          title: 'Monthly',
          description: 'Monthly premium',
          price: '14.99 PLN',
        ),
      if (identifiers.contains(kYearlyPremiumProductId) && hasYearlyProduct)
        _product(
          id: kYearlyPremiumProductId,
          title: 'Yearly',
          description: 'Yearly premium',
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
    if (throwOnBuyCalls.contains(buyNonConsumableCalls)) {
      throw StateError('buy failed');
    }
    return buyNonConsumableResult;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completePurchaseCalls++;
    if (throwOnCompleteCalls.contains(completePurchaseCalls)) {
      throw StateError('complete failed');
    }
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restorePurchasesCalls++;
    if (throwOnRestoreCalls.contains(restorePurchasesCalls)) {
      throw StateError('restore failed');
    }

    final index = restorePurchasesCalls - 1;
    if (index < restoreEventsByCall.length) {
      final events = restoreEventsByCall[index];
      if (restoreEventDelay == Duration.zero) {
        _purchaseController.add(events);
      } else {
        unawaited(Future<void>.delayed(restoreEventDelay).then((_) {
          if (!_purchaseController.isClosed) {
            _purchaseController.add(events);
          }
        }));
      }
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
  bool pendingCompletePurchase = false,
}) {
  final purchase = PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: '0',
    status: status,
  );
  purchase.pendingCompletePurchase = pendingCompletePurchase;
  return purchase;
}

Future<void> _waitFor(bool Function() predicate) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

Matcher isUnavailablePurchase() {
  return isA<PurchaseActionResult>().having(
    (result) => result.status,
    'status',
    PurchaseActionStatus.unavailable,
  );
}

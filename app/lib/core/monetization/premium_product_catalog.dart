import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_product_ids.dart';

class PremiumProductCatalog {
  const PremiumProductCatalog({
    required this.monthly,
    required this.lifetime,
  });

  factory PremiumProductCatalog.empty() {
    return const PremiumProductCatalog(
      monthly: null,
      lifetime: null,
    );
  }

  final ProductDetails? monthly;
  final ProductDetails? lifetime;

  ProductDetails? productForId(String id) {
    return switch (id) {
      kMonthlyPremiumProductId => monthly,
      kLifetimePremiumProductId => lifetime,
      _ => null,
    };
  }

  bool get hasMonthly => monthly != null;

  bool get hasLifetime => lifetime != null;
}

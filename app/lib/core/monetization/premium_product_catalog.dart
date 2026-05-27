import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_product_ids.dart';

class PremiumProductCatalog {
  const PremiumProductCatalog({
    required this.monthly,
    required this.yearly,
  });

  factory PremiumProductCatalog.empty() {
    return const PremiumProductCatalog(
      monthly: null,
      yearly: null,
    );
  }

  final ProductDetails? monthly;
  final ProductDetails? yearly;

  ProductDetails? productForId(String id) {
    return switch (id) {
      kMonthlyPremiumProductId => monthly,
      kYearlyPremiumProductId => yearly,
      _ => null,
    };
  }

  bool get hasMonthly => monthly != null;

  bool get hasYearly => yearly != null;
}

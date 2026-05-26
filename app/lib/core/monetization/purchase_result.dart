enum PurchaseActionStatus {
  success,
  canceled,
  pending,
  unavailable,
  noPurchaseFound,
  error,
}

class PurchaseActionResult {
  const PurchaseActionResult({
    required this.status,
    this.message,
  });

  final PurchaseActionStatus status;
  final String? message;

  bool get isSuccess => status == PurchaseActionStatus.success;
}

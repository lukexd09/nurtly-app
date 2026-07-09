import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/ads/ad_widget_factory.dart';

void main() {
  test('banner load gate allows retry after consent is revoked and restored',
      () {
    final gate = BannerLoadGate();

    expect(gate.canAttemptLoad, isFalse);
    gate.markConsentGranted();
    expect(gate.canAttemptLoad, isTrue);
    expect(gate.beginLoadAttempt(), isTrue);
    expect(gate.canAttemptLoad, isFalse);

    gate.markConsentRevoked();
    expect(gate.canAttemptLoad, isFalse);

    gate.markConsentGranted();
    expect(gate.canAttemptLoad, isTrue);
    expect(gate.beginLoadAttempt(), isTrue);
  });

  test('banner load gate retries after a failed load', () {
    final gate = BannerLoadGate();

    gate.markConsentGranted();
    expect(gate.beginLoadAttempt(), isTrue);
    expect(gate.canAttemptLoad, isFalse);

    gate.markLoadFailed();
    expect(gate.canAttemptLoad, isTrue);
    expect(gate.beginLoadAttempt(), isTrue);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/ads/ad_widget_factory.dart';

void main() {
  test('banner load gate allows retry after consent is revoked and restored',
      () {
    final gate = BannerLoadGate();

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

  test('banner load gate does not attempt without configuration', () {
    final gate = BannerLoadGate();

    gate.markConsentGranted();
    expect(gate.beginLoadAttempt(hasConfiguration: false), isFalse);
    expect(gate.canAttemptLoad, isTrue);
  });

  test('banner load gate permits one active request at a time', () {
    final gate = BannerLoadGate();

    gate.markConsentGranted();
    expect(gate.beginLoadAttempt(), isTrue);
    expect(gate.beginLoadAttempt(), isFalse);

    gate.markLoadFailed();
    expect(gate.beginLoadAttempt(), isTrue);
  });

  test('banner load gate invalidates an active request when consent changes',
      () {
    final gate = BannerLoadGate();

    gate.markConsentGranted();
    expect(gate.beginLoadAttempt(), isTrue);
    gate.markConsentRevoked();
    gate.markConsentGranted();

    expect(gate.beginLoadAttempt(), isTrue);
  });

  test('banner slot lifecycle loads once and disposes on teardown', () {
    final disposed = <String>[];
    late _FakeBannerHandle handle;
    final lifecycle = BannerSlotLifecycle(
      bannerId: 'banner-1',
      bannerCreator: ({required callbacks, required bannerId}) {
        handle = _FakeBannerHandle(
          bannerId: bannerId,
          disposed: disposed,
          onLoaded: (id) => callbacks.onLoaded(_FakeBannerAd(id, disposed)),
        );
        return handle;
      },
    );

    lifecycle.setConsentAllowed(true);
    expect(lifecycle.beginLoad(), isTrue);
    expect(lifecycle.beginLoad(), isFalse);
    handle.simulateLoaded();
    expect(lifecycle.isLoaded, isTrue);
    lifecycle.dispose();
    expect(disposed, contains('banner-1'));
  });

  test('banner slot lifecycle disposes stale loaded callbacks after revoke',
      () {
    final disposed = <String>[];
    late _FakeBannerHandle handle;
    final lifecycle = BannerSlotLifecycle(
      bannerId: 'banner-1',
      bannerCreator: ({required callbacks, required bannerId}) {
        handle = _FakeBannerHandle(
          bannerId: bannerId,
          disposed: disposed,
          onLoaded: (id) => callbacks.onLoaded(_FakeBannerAd(id, disposed)),
        );
        return handle;
      },
    );

    lifecycle.setConsentAllowed(true);
    expect(lifecycle.beginLoad(), isTrue);
    lifecycle.setConsentAllowed(false);
    handle.simulateLoaded();

    expect(lifecycle.isLoaded, isFalse);
    expect(disposed, contains('banner-1-callback'));
  });

  test('banner slot lifecycle keeps a reserved slot while loading', () {
    final lifecycle = BannerSlotLifecycle(
      bannerId: 'banner-1',
      bannerCreator: ({required callbacks, required bannerId}) {
        return _FakeBannerHandle(
          bannerId: bannerId,
          disposed: <String>[],
          onLoaded: (_) {},
        );
      },
    );

    lifecycle.setConsentAllowed(true);
    expect(lifecycle.canReserveSlot, isTrue);
    expect(lifecycle.beginLoad(), isTrue);
    expect(lifecycle.canReserveSlot, isTrue);
  });
}

class _FakeBannerHandle implements BannerSlotHandle {
  _FakeBannerHandle({
    required this.bannerId,
    required this.disposed,
    required this.onLoaded,
  });

  final String bannerId;
  final List<String> disposed;
  final void Function(String bannerId) onLoaded;

  void simulateLoaded() => onLoaded(bannerId);

  @override
  void dispose() {
    disposed.add(bannerId);
  }
}

class _FakeBannerAd {
  _FakeBannerAd(this.bannerId, this.disposed);

  final String bannerId;
  final List<String> disposed;

  void dispose() {
    disposed.add('$bannerId-callback');
  }
}

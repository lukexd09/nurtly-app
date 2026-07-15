import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/ads/consent_flow_controller.dart';

void main() {
  test('updates consent before reading provider state', () async {
    final gateway = FakeConsentPlatformGateway(canRequestAdsValue: true);
    final flow = GoogleConsentFlow(isDebugMode: false, gateway: gateway);

    await flow.initialize();

    expect(
        gateway.calls, ['update', 'form', 'canRequestAds', 'privacy', 'ads']);
    expect(flow.canRequestAds, isTrue);
    expect(gateway.initializeMobileAdsCalls, 1);
  });

  test('debug mode includes geography and test-device IDs', () async {
    final gateway = FakeConsentPlatformGateway();
    await GoogleConsentFlow(
      isDebugMode: true,
      debugTestDeviceIds: const ['device-1'],
      gateway: gateway,
    ).initialize();

    final settings = gateway.parameters!.consentDebugSettings;
    expect(settings?.debugGeography, DebugGeography.debugGeographyEea);
    expect(settings?.testIdentifiers, ['device-1']);
  });

  test('release mode excludes all debug settings and supplied IDs', () async {
    final gateway = FakeConsentPlatformGateway();
    await GoogleConsentFlow(
      isDebugMode: false,
      debugTestDeviceIds: const ['device-1'],
      gateway: gateway,
    ).initialize();

    expect(gateway.parameters!.consentDebugSettings, isNull);
  });

  test('ads initialize once only when provider permits requests', () async {
    final blocked = FakeConsentPlatformGateway();
    final blockedFlow = GoogleConsentFlow(isDebugMode: false, gateway: blocked);
    await blockedFlow.initialize();
    expect(blocked.initializeMobileAdsCalls, 0);

    final allowed = FakeConsentPlatformGateway(canRequestAdsValue: true);
    final allowedFlow = GoogleConsentFlow(isDebugMode: false, gateway: allowed);
    await allowedFlow.initialize();
    await allowedFlow.initialize();
    expect(allowed.initializeMobileAdsCalls, 1);
  });

  test('update failure preserves a requestable previous session', () async {
    final gateway = FakeConsentPlatformGateway(
      canRequestAdsValue: true,
      updateError: StateError('update failed'),
    );
    final flow = GoogleConsentFlow(isDebugMode: false, gateway: gateway);

    await flow.initialize();

    expect(flow.canRequestAds, isTrue);
    expect(gateway.initializeMobileAdsCalls, 1);
  });

  test('update failure remains blocked when provider is blocked', () async {
    final gateway = FakeConsentPlatformGateway(
      updateError: StateError('update failed'),
    );
    final flow = GoogleConsentFlow(isDebugMode: false, gateway: gateway);

    await flow.initialize();

    expect(flow.canRequestAds, isFalse);
    expect(gateway.initializeMobileAdsCalls, 0);
  });

  test('provider state read failure cannot enable ads locally', () async {
    final gateway = FakeConsentPlatformGateway(
      canRequestAdsError: StateError('state unavailable'),
    );
    final flow = GoogleConsentFlow(isDebugMode: false, gateway: gateway);

    await flow.initialize();

    expect(flow.canRequestAds, isFalse);
    expect(flow.privacyOptionsRequired, isFalse);
    expect(gateway.initializeMobileAdsCalls, 0);
  });

  test('privacy choices unavailable, provider errors, and exceptions propagate',
      () async {
    final unavailable = FakeConsentPlatformGateway(formAvailable: false);
    await expectLater(
      GoogleConsentFlow(isDebugMode: false, gateway: unavailable)
          .showPrivacyOptions(),
      throwsStateError,
    );

    final callbackError = FakeConsentPlatformGateway(
      privacyOptionsError: StateError('provider error'),
    );
    await expectLater(
      GoogleConsentFlow(isDebugMode: false, gateway: callbackError)
          .showPrivacyOptions(),
      throwsStateError,
    );

    final exception = FakeConsentPlatformGateway(
      privacyFormAvailabilityError: StateError('exception'),
    );
    await expectLater(
      GoogleConsentFlow(isDebugMode: false, gateway: exception)
          .showPrivacyOptions(),
      throwsStateError,
    );
  });

  test('successful privacy choices refresh state and notify listeners',
      () async {
    final gateway = FakeConsentPlatformGateway(
      canRequestAdsValue: true,
      privacyOptionsRequiredValue: true,
    );
    final flow = GoogleConsentFlow(isDebugMode: false, gateway: gateway);
    var notifications = 0;
    flow.addListener(() => notifications++);

    await flow.showPrivacyOptions();

    expect(flow.canRequestAds, isTrue);
    expect(flow.privacyOptionsRequired, isTrue);
    expect(notifications, 1);
    expect(gateway.initializeMobileAdsCalls, 1);
  });
}

class FakeConsentPlatformGateway implements ConsentPlatformGateway {
  FakeConsentPlatformGateway({
    this.canRequestAdsValue = false,
    this.privacyOptionsRequiredValue = false,
    this.formAvailable = true,
    this.updateError,
    this.canRequestAdsError,
    this.privacyFormAvailabilityError,
    this.privacyOptionsError,
  });

  final bool canRequestAdsValue;
  final bool privacyOptionsRequiredValue;
  final bool formAvailable;
  final Object? updateError;
  final Object? canRequestAdsError;
  final Object? privacyFormAvailabilityError;
  final Object? privacyOptionsError;
  final calls = <String>[];
  ConsentRequestParameters? parameters;
  var initializeMobileAdsCalls = 0;

  @override
  Future<bool> canRequestAds() async {
    calls.add('canRequestAds');
    if (canRequestAdsError != null) throw canRequestAdsError!;
    return canRequestAdsValue;
  }

  @override
  Future<PrivacyOptionsRequirementStatus>
      getPrivacyOptionsRequirementStatus() async {
    calls.add('privacy');
    return privacyOptionsRequiredValue
        ? PrivacyOptionsRequirementStatus.required
        : PrivacyOptionsRequirementStatus.notRequired;
  }

  @override
  Future<void> initializeMobileAds() async {
    calls.add('ads');
    initializeMobileAdsCalls++;
  }

  @override
  Future<bool> isConsentFormAvailable() async {
    if (privacyFormAvailabilityError != null) {
      throw privacyFormAvailabilityError!;
    }
    return formAvailable;
  }

  @override
  Future<void> loadAndShowConsentFormIfRequired() async {
    calls.add('form');
  }

  @override
  Future<void> requestConsentInfoUpdate(
    ConsentRequestParameters parameters,
  ) async {
    calls.add('update');
    this.parameters = parameters;
    if (updateError != null) throw updateError!;
  }

  @override
  Future<void> showPrivacyOptionsForm() async {
    if (privacyOptionsError != null) throw privacyOptionsError!;
  }
}

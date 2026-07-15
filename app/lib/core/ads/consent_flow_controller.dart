import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

export 'package:google_mobile_ads/google_mobile_ads.dart'
    show
        ConsentRequestParameters,
        DebugGeography,
        PrivacyOptionsRequirementStatus;

abstract interface class ConsentPlatformGateway {
  Future<void> requestConsentInfoUpdate(ConsentRequestParameters parameters);
  Future<void> loadAndShowConsentFormIfRequired();
  Future<bool> canRequestAds();
  Future<PrivacyOptionsRequirementStatus> getPrivacyOptionsRequirementStatus();
  Future<bool> isConsentFormAvailable();
  Future<void> showPrivacyOptionsForm();
  Future<void> initializeMobileAds();
}

class GoogleConsentPlatformGateway implements ConsentPlatformGateway {
  const GoogleConsentPlatformGateway();

  @override
  Future<void> requestConsentInfoUpdate(
    ConsentRequestParameters parameters,
  ) {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      parameters,
      () => completer.complete(),
      (error) => completer.completeError(error),
    );
    return completer.future;
  }

  @override
  Future<void> loadAndShowConsentFormIfRequired() async {
    final completer = Completer<void>();
    await ConsentForm.loadAndShowConsentFormIfRequired(
      (error) =>
          error == null ? completer.complete() : completer.completeError(error),
    );
    return completer.future;
  }

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  @override
  Future<PrivacyOptionsRequirementStatus>
      getPrivacyOptionsRequirementStatus() =>
          ConsentInformation.instance.getPrivacyOptionsRequirementStatus();

  @override
  Future<bool> isConsentFormAvailable() =>
      ConsentInformation.instance.isConsentFormAvailable();

  @override
  Future<void> showPrivacyOptionsForm() async {
    final completer = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm(
      (error) =>
          error == null ? completer.complete() : completer.completeError(error),
    );
    return completer.future;
  }

  @override
  Future<void> initializeMobileAds() async {
    await MobileAds.instance.initialize();
  }
}

abstract interface class ConsentFlow {
  Future<void> initialize();
  bool get canRequestAds;
  bool get privacyOptionsRequired;
  Future<void> showPrivacyOptions();
}

class NoopConsentFlow implements ConsentFlow {
  const NoopConsentFlow();

  @override
  bool get canRequestAds => true;

  @override
  bool get privacyOptionsRequired => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showPrivacyOptions() async {}
}

class GoogleConsentFlow extends ChangeNotifier implements ConsentFlow {
  GoogleConsentFlow({
    required bool isDebugMode,
    List<String>? debugTestDeviceIds,
    ConsentPlatformGateway? gateway,
  })  : _isDebugMode = isDebugMode,
        _debugTestDeviceIds = debugTestDeviceIds ?? const <String>[],
        _gateway = gateway ?? const GoogleConsentPlatformGateway();

  final bool _isDebugMode;
  final List<String> _debugTestDeviceIds;
  final ConsentPlatformGateway _gateway;
  bool _isInitialized = false;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;
  bool _adsInitialized = false;

  @override
  bool get canRequestAds => _canRequestAds;

  @override
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    try {
      final params = ConsentRequestParameters(
        consentDebugSettings: _isDebugMode
            ? ConsentDebugSettings(
                testIdentifiers: _debugTestDeviceIds,
                debugGeography: DebugGeography.debugGeographyEea,
              )
            : null,
      );
      await _gateway.requestConsentInfoUpdate(params);
      await _gateway.loadAndShowConsentFormIfRequired();
      await _refreshConsentState();
    } catch (_) {
      try {
        await _refreshConsentState();
      } catch (_) {
        _canRequestAds = false;
        _privacyOptionsRequired = false;
      }
    }
    notifyListeners();
  }

  @override
  Future<void> showPrivacyOptions() async {
    if (!await _gateway.isConsentFormAvailable()) {
      throw StateError('Privacy options form is unavailable.');
    }
    await _gateway.showPrivacyOptionsForm();
    await _refreshConsentState();
    notifyListeners();
  }

  Future<void> _refreshConsentState() async {
    _canRequestAds = await _gateway.canRequestAds();
    _privacyOptionsRequired =
        await _gateway.getPrivacyOptionsRequirementStatus() ==
            PrivacyOptionsRequirementStatus.required;
    if (_canRequestAds && !_adsInitialized) {
      _adsInitialized = true;
      await _gateway.initializeMobileAds();
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
    required bool debugGeographyEnabled,
    List<String>? debugTestDeviceIds,
  })  : _debugGeographyEnabled = debugGeographyEnabled,
        _debugTestDeviceIds = debugTestDeviceIds ?? const <String>[];

  final bool _debugGeographyEnabled;
  final List<String> _debugTestDeviceIds;
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
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    try {
      final params = ConsentRequestParameters(
        consentDebugSettings: kDebugMode && _debugGeographyEnabled
            ? ConsentDebugSettings(
                testIdentifiers: _debugTestDeviceIds,
                debugGeography: DebugGeography.debugGeographyEea,
              )
            : null,
      );
      await _requestConsentInfoUpdate(params);
      await _loadAndShowConsentFormIfRequired();
      await _refreshConsentState();
    } catch (_) {
      _canRequestAds = false;
      _privacyOptionsRequired = false;
    }
    notifyListeners();
  }

  @override
  Future<void> showPrivacyOptions() async {
    try {
      final formAvailable =
          await ConsentInformation.instance.isConsentFormAvailable();
      if (!formAvailable) {
        return;
      }
      await ConsentForm.showPrivacyOptionsForm((_) {});
      await _refreshConsentState();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _refreshConsentState() async {
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    _privacyOptionsRequired = await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
    if (_canRequestAds && !_adsInitialized) {
      _adsInitialized = true;
      await MobileAds.instance.initialize();
    }
  }

  Future<void> _requestConsentInfoUpdate(ConsentRequestParameters params) {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () => completer.complete(),
      (error) => completer.completeError(error),
    );
    return completer.future;
  }

  Future<void> _loadAndShowConsentFormIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired(
      (_) => completer.complete(),
    );
    return completer.future;
  }
}

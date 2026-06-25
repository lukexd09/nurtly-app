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
  GoogleConsentFlow({required bool debugGeographyEnabled})
      : _debugGeographyEnabled = debugGeographyEnabled;

  final bool _debugGeographyEnabled;
  bool _isInitialized = false;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;

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
                debugGeography: DebugGeography.debugGeographyEea,
              )
            : null,
      );
      await _requestConsentInfoUpdate(params);
      await _loadAndShowConsentFormIfRequired();
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      _privacyOptionsRequired =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
              PrivacyOptionsRequirementStatus.required;
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
    } catch (_) {}
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

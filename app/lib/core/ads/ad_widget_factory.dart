import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'consent_flow_controller.dart';
import '../localization/app_strings.dart';
import '../monetization/ad_placeholder.dart';

abstract interface class AdWidgetFactory {
  Widget buildPassiveSlot({required AppStrings strings});
}

class FakeAdWidgetFactory implements AdWidgetFactory {
  const FakeAdWidgetFactory();

  @override
  Widget buildPassiveSlot({required AppStrings strings}) {
    return AdPlaceholderCard(strings: strings);
  }
}

class RealAdWidgetFactory implements AdWidgetFactory {
  const RealAdWidgetFactory({required this.consentFlow, this.bannerId});

  final ConsentFlow consentFlow;
  final String? bannerId;

  @override
  Widget buildPassiveSlot({required AppStrings strings}) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    return _RealBannerAdSlot(consentFlow: consentFlow, bannerId: bannerId);
  }
}

class _RealBannerAdSlot extends StatefulWidget {
  const _RealBannerAdSlot({required this.consentFlow, required this.bannerId});

  final ConsentFlow consentFlow;
  final String? bannerId;

  @override
  State<_RealBannerAdSlot> createState() => _RealBannerAdSlotState();
}

class _RealBannerAdSlotState extends State<_RealBannerAdSlot> {
  BannerAd? _bannerAd;
  BannerAd? _loadingAd;
  final BannerLoadGate _loadGate = BannerLoadGate();
  var _isLoaded = false;
  var _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    if (widget.consentFlow is Listenable) {
      (widget.consentFlow as Listenable).addListener(_syncConsentState);
    }
    _syncConsentState();
  }

  @override
  void didUpdateWidget(covariant _RealBannerAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consentFlow != widget.consentFlow) {
      if (oldWidget.consentFlow is Listenable) {
        (oldWidget.consentFlow as Listenable).removeListener(_syncConsentState);
      }
      if (widget.consentFlow is Listenable) {
        (widget.consentFlow as Listenable).addListener(_syncConsentState);
      }
      _syncConsentState();
    }
    if (oldWidget.bannerId != widget.bannerId) {
      _disposeAds();
      _loadGate.markConsentRevoked();
      _syncConsentState();
    }
  }

  void _syncConsentState() {
    if (!mounted) {
      return;
    }
    if (!widget.consentFlow.canRequestAds) {
      _disposeAds();
      _loadGate.markConsentRevoked();
    } else {
      _loadGate.markConsentGranted();
      if (_loadGate.canAttemptLoad) {
        unawaited(_loadAd());
      }
    }
    setState(() {});
  }

  void _disposeAds() {
    _loadGeneration++;
    _bannerAd?.dispose();
    _loadingAd?.dispose();
    _bannerAd = null;
    _loadingAd = null;
    _isLoaded = false;
  }

  Future<void> _loadAd() async {
    if (defaultTargetPlatform != TargetPlatform.android ||
        !widget.consentFlow.canRequestAds ||
        !_loadGate.beginLoadAttempt(
            hasConfiguration: widget.bannerId != null)) {
      return;
    }

    final generation = _loadGeneration;
    late final BannerAd ad;
    ad = BannerAd(
      size: AdSize.banner,
      adUnitId: widget.bannerId!,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted ||
              generation != _loadGeneration ||
              _loadingAd != ad ||
              !widget.consentFlow.canRequestAds) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _loadingAd = null;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (generation != _loadGeneration || _loadingAd != ad) {
            return;
          }
          _loadingAd = null;
          _loadGate.markLoadFailed();
          if (!mounted) {
            return;
          }
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
        },
      ),
    );
    _loadingAd = ad;

    try {
      await ad.load();
    } catch (_) {
      ad.dispose();
      if (generation != _loadGeneration || _loadingAd != ad) {
        return;
      }
      _loadingAd = null;
      _loadGate.markLoadFailed();
      if (!mounted) {
        return;
      }
      setState(() {
        _bannerAd = null;
        _isLoaded = false;
      });
    }
  }

  @override
  void dispose() {
    if (widget.consentFlow is Listenable) {
      (widget.consentFlow as Listenable).removeListener(_syncConsentState);
    }
    _disposeAds();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.consentFlow.canRequestAds || widget.bannerId == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: AdSize.banner.height.toDouble(),
      child: _isLoaded && _bannerAd != null
          ? Center(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class BannerLoadGate {
  var _consentAllowed = false;
  var _loadAttempted = false;

  bool get canAttemptLoad => _consentAllowed && !_loadAttempted;

  bool beginLoadAttempt({bool hasConfiguration = true}) {
    if (!hasConfiguration || !canAttemptLoad) {
      return false;
    }
    _loadAttempted = true;
    return true;
  }

  void markConsentRevoked() {
    _consentAllowed = false;
    _loadAttempted = false;
  }

  void markConsentGranted() {
    _consentAllowed = true;
  }

  void markLoadFailed() {
    _loadAttempted = false;
  }
}

class AdSlotFactory {
  const AdSlotFactory._();

  static AdWidgetFactory defaultForRuntime({required ConsentFlow consentFlow}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const FakeAdWidgetFactory();
    }
    return RealAdWidgetFactory(consentFlow: consentFlow);
  }
}

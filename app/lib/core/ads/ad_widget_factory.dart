import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'consent_flow_controller.dart';
import '../localization/app_strings.dart';
import '../monetization/ad_placeholder.dart';
import 'ad_unit_ids.dart';

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
  const RealAdWidgetFactory({required this.consentFlow});

  final ConsentFlow consentFlow;

  @override
  Widget buildPassiveSlot({required AppStrings strings}) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    return _RealBannerAdSlot(consentFlow: consentFlow);
  }
}

class _RealBannerAdSlot extends StatefulWidget {
  const _RealBannerAdSlot({required this.consentFlow});

  final ConsentFlow consentFlow;

  @override
  State<_RealBannerAdSlot> createState() => _RealBannerAdSlotState();
}

class _RealBannerAdSlotState extends State<_RealBannerAdSlot> {
  BannerAd? _bannerAd;
  var _isLoaded = false;
  var _loadAttempted = false;

  @override
  void initState() {
    super.initState();
    if (widget.consentFlow is Listenable) {
      (widget.consentFlow as Listenable).addListener(_syncConsentState);
    }
    _loadAd();
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
  }

  void _syncConsentState() {
    if (!mounted) {
      return;
    }
    if (widget.consentFlow.canRequestAds && !_loadAttempted) {
      unawaited(_loadAd());
    }
    setState(() {});
  }

  Future<void> _loadAd() async {
    if (defaultTargetPlatform != TargetPlatform.android ||
        _loadAttempted ||
        !widget.consentFlow.canRequestAds) {
      return;
    }
    _loadAttempted = true;

    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: AdUnitIds.bannerAndroid,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
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

    try {
      await ad.load();
    } catch (_) {
      ad.dispose();
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
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.consentFlow.canRequestAds || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
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

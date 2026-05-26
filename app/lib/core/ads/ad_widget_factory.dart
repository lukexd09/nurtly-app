import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  const RealAdWidgetFactory();

  @override
  Widget buildPassiveSlot({required AppStrings strings}) {
    return const _RealBannerAdSlot();
  }
}

class _RealBannerAdSlot extends StatefulWidget {
  const _RealBannerAdSlot();

  @override
  State<_RealBannerAdSlot> createState() => _RealBannerAdSlotState();
}

class _RealBannerAdSlotState extends State<_RealBannerAdSlot> {
  BannerAd? _bannerAd;
  var _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: defaultTargetPlatform == TargetPlatform.iOS
          ? AdUnitIds.bannerIos
          : AdUnitIds.bannerAndroid,
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

    await ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
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

  static AdWidgetFactory defaultForRuntime() {
    if (kIsWeb) {
      return const FakeAdWidgetFactory();
    }
    return const RealAdWidgetFactory();
  }
}

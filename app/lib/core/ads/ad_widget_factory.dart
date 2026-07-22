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

typedef BannerSlotCreator = BannerSlotHandle Function({
  required BannerSlotCallbacks callbacks,
  required String bannerId,
});

abstract interface class BannerSlotHandle {
  void dispose();
}

class BannerSlotCallbacks {
  BannerSlotCallbacks({
    required this.onLoaded,
    required this.onFailedToLoad,
  });

  final void Function(Object ad) onLoaded;
  final void Function() onFailedToLoad;
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
    return _RealBannerAdSlot(
      consentFlow: consentFlow,
      bannerId: bannerId,
      bannerCreator: _createBannerHandle,
    );
  }
}

class _RealBannerAdSlot extends StatefulWidget {
  const _RealBannerAdSlot({
    required this.consentFlow,
    required this.bannerId,
    required this.bannerCreator,
  });

  final ConsentFlow consentFlow;
  final String? bannerId;
  final BannerSlotCreator bannerCreator;

  @override
  State<_RealBannerAdSlot> createState() => _RealBannerAdSlotState();
}

class _RealBannerAdSlotState extends State<_RealBannerAdSlot> {
  final BannerLoadGate _loadGate = BannerLoadGate();
  BannerSlotHandle? _bannerHandle;
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
    _bannerHandle?.dispose();
    _bannerHandle = null;
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
    late final BannerSlotHandle handle;
    final callbacks = BannerSlotCallbacks(
      onLoaded: (ad) {
        if (!mounted ||
            generation != _loadGeneration ||
            _bannerHandle != handle ||
            !widget.consentFlow.canRequestAds) {
          (ad as dynamic).dispose();
          return;
        }
        setState(() {
          _isLoaded = true;
        });
      },
      onFailedToLoad: () {
        if (generation != _loadGeneration || _bannerHandle != handle) {
          return;
        }
        _bannerHandle = null;
        _loadGate.markLoadFailed();
        if (!mounted) {
          return;
        }
        setState(() {
          _isLoaded = false;
        });
      },
    );
    handle = widget.bannerCreator(
      callbacks: callbacks,
      bannerId: widget.bannerId!,
    );
    _bannerHandle = handle;

    try {
      final ad = BannerAd(
        size: AdSize.banner,
        adUnitId: widget.bannerId!,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) => callbacks.onLoaded(ad),
          onAdFailedToLoad: (ad, _) {
            callbacks.onFailedToLoad();
            ad.dispose();
          },
        ),
      );
      await ad.load();
    } catch (_) {
      _loadGate.markLoadFailed();
      if (!mounted) {
        return;
      }
      setState(() {
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
      child: _isLoaded ? const SizedBox.expand() : const SizedBox.shrink(),
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

class BannerSlotLifecycle {
  BannerSlotLifecycle({
    required this.bannerCreator,
    required this.bannerId,
  });

  final BannerSlotCreator bannerCreator;
  String? bannerId;
  BannerSlotHandle? _handle;
  var _generation = 0;
  var _loaded = false;
  var _consentAllowed = false;
  var _loadAttempted = false;

  bool get isLoaded => _loaded;
  bool get hasBanner => _handle != null;
  bool get canReserveSlot => bannerId != null && _consentAllowed;
  int get generation => _generation;

  void setConsentAllowed(bool allowed) {
    _consentAllowed = allowed;
    if (!allowed) {
      _disposeHandle();
      _loadAttempted = false;
    }
  }

  void setBannerId(String? newBannerId) {
    if (bannerId == newBannerId) {
      return;
    }
    bannerId = newBannerId;
    _disposeHandle();
    _loadAttempted = false;
  }

  bool beginLoad() {
    if (!canReserveSlot || _loadAttempted) {
      return false;
    }
    _loadAttempted = true;
    final currentGeneration = _generation;
    _handle = bannerCreator(
      bannerId: bannerId!,
      callbacks: BannerSlotCallbacks(
        onLoaded: (ad) {
          if (_generation != currentGeneration || !_consentAllowed) {
            (ad as dynamic).dispose();
            return;
          }
          _loaded = true;
        },
        onFailedToLoad: () {
          if (_generation != currentGeneration) {
            return;
          }
          _handle = null;
          _loaded = false;
          _loadAttempted = false;
        },
      ),
    );
    return true;
  }

  void dispose() {
    _disposeHandle();
  }

  void _disposeHandle() {
    _generation++;
    _handle?.dispose();
    _handle = null;
    _loaded = false;
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

BannerSlotHandle _createBannerHandle({
  required BannerSlotCallbacks callbacks,
  required String bannerId,
}) {
  late final BannerAd ad;
  ad = BannerAd(
    size: AdSize.banner,
    adUnitId: bannerId,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (loadedAd) => callbacks.onLoaded(loadedAd),
      onAdFailedToLoad: (failedAd, _) {
        callbacks.onFailedToLoad();
        failedAd.dispose();
      },
    ),
  );
  unawaited(ad.load());
  return _BannerAdHandle(ad);
}

class _BannerAdHandle implements BannerSlotHandle {
  _BannerAdHandle(this._ad);

  final BannerAd _ad;

  @override
  void dispose() {
    _ad.dispose();
  }
}

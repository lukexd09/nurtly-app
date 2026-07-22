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
  required String bannerId,
});

abstract interface class BannerSlotHandle {
  Future<void> load({
    required void Function(BannerSlotHandle handle) onLoaded,
    required void Function() onFailedToLoad,
  });

  Widget buildWidget();

  void dispose();
}

class FakeAdWidgetFactory implements AdWidgetFactory {
  const FakeAdWidgetFactory();

  @override
  Widget buildPassiveSlot({required AppStrings strings}) {
    return AdPlaceholderCard(strings: strings);
  }
}

class RealAdWidgetFactory implements AdWidgetFactory {
  const RealAdWidgetFactory({
    required this.consentFlow,
    this.bannerId,
    this.bannerCreator = _createBannerHandle,
  });

  final ConsentFlow consentFlow;
  final String? bannerId;
  final BannerSlotCreator bannerCreator;

  @override
  Widget buildPassiveSlot({required AppStrings strings}) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    return _RealBannerAdSlot(
      consentFlow: consentFlow,
      bannerId: bannerId,
      bannerCreator: bannerCreator,
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
  var _retryUsedForGeneration = false;

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
    _retryUsedForGeneration = false;
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
    await _loadBannerForGeneration(generation);
  }

  Future<void> _loadBannerForGeneration(int generation) async {
    final handle = widget.bannerCreator(bannerId: widget.bannerId!);
    _bannerHandle = handle;

    Future<void> onFailure() async {
      if (generation != _loadGeneration || _bannerHandle != handle) {
        return;
      }
      handle.dispose();
      if (_retryUsedForGeneration) {
        _bannerHandle = null;
        _loadGate.markLoadFailed();
        if (!mounted) {
          return;
        }
        setState(() {
          _isLoaded = false;
        });
        return;
      }
      _retryUsedForGeneration = true;
      _bannerHandle = null;
      _loadGate.markLoadFailed();
      if (!mounted ||
          generation != _loadGeneration ||
          !widget.consentFlow.canRequestAds) {
        return;
      }
      await _loadBannerForGeneration(generation);
    }

    try {
      await handle.load(
        onLoaded: (loadedHandle) {
          if (!mounted ||
              generation != _loadGeneration ||
              _bannerHandle != loadedHandle ||
              !widget.consentFlow.canRequestAds) {
            loadedHandle.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
          });
        },
        onFailedToLoad: () {
          unawaited(onFailure());
        },
      );
    } catch (_) {
      await onFailure();
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
      child: _isLoaded && _bannerHandle != null
          ? Center(child: _bannerHandle!.buildWidget())
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

BannerSlotHandle _createBannerHandle({
  required String bannerId,
}) {
  return _BannerAdHandle(bannerId);
}

class _BannerAdHandle implements BannerSlotHandle {
  _BannerAdHandle(this._bannerId);

  final String _bannerId;
  BannerAd? _ad;
  var _loadStarted = false;
  var _disposed = false;

  @override
  Future<void> load({
    required void Function(BannerSlotHandle handle) onLoaded,
    required void Function() onFailedToLoad,
  }) async {
    if (_loadStarted) {
      return;
    }
    _loadStarted = true;
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: _bannerId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(this),
        onAdFailedToLoad: (_, __) => onFailedToLoad(),
      ),
    );
    _ad = ad;
    try {
      await ad.load();
    } catch (_) {
      ad.dispose();
      _disposed = true;
      onFailedToLoad();
    }
  }

  @override
  Widget buildWidget() => AdWidget(ad: _ad!);

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _ad?.dispose();
  }
}

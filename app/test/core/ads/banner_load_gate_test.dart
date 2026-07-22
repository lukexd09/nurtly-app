import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/ads/ad_widget_factory.dart';
import 'package:nurtly/core/ads/consent_flow_controller.dart';
import 'package:nurtly/core/localization/app_strings.dart';

void main() {
  testWidgets('successful load renders the handle widget once', (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = _testFactory(
      consentFlow: consentFlow,
      handles: handles,
    );

    await tester.pumpWidget(_shell(factory));
    await tester.pump();

    expect(handles, hasLength(1));
    expect(handles.single.loadCalls, 1);
    expect(find.text('banner:banner-1'), findsOneWidget);
  });

  testWidgets('rebuild does not create duplicate handle or load',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = _testFactory(
      consentFlow: consentFlow,
      handles: handles,
    );

    await tester.pumpWidget(_shell(factory));
    await tester.pump();
    await tester.pumpWidget(_shell(factory));
    await tester.pump();

    expect(handles, hasLength(1));
    expect(handles.single.loadCalls, 1);
  });

  testWidgets('consent revoke disposes the active loading handle',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = _testFactory(
      consentFlow: consentFlow,
      handles: handles,
      completeOnLoad: false,
    );

    await tester.pumpWidget(_shell(factory));
    await tester.pump();
    consentFlow.setCanRequestAds(false);
    await tester.pump();

    expect(handles.single.disposeCalls, 1);
    expect(find.byType(_FakeBannerWidget), findsNothing);
  });

  testWidgets('stale loaded callback after revoke is rejected and disposed',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = _testFactory(
      consentFlow: consentFlow,
      handles: handles,
      completeOnLoad: false,
    );

    await tester.pumpWidget(_shell(factory));
    await tester.pump();
    consentFlow.setCanRequestAds(false);
    await tester.pump();
    handles.single.simulateLoaded();
    await tester.pump();

    expect(handles.single.disposeCalls, 1);
    expect(find.byType(_FakeBannerWidget), findsNothing);
  });

  testWidgets('banner id change disposes old handle and loads one new handle',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    var bannerId = 'banner-1';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (_) => RealAdWidgetFactory(
            consentFlow: consentFlow,
            bannerId: bannerId,
            bannerCreator: ({required bannerId}) {
              final handle = _FakeBannerHandle(bannerId: bannerId);
              handles.add(handle);
              return handle;
            },
          ).buildPassiveSlot(strings: AppStrings.english),
        ),
      ),
    );
    await tester.pump();
    bannerId = 'banner-2';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (_) => RealAdWidgetFactory(
            consentFlow: consentFlow,
            bannerId: bannerId,
            bannerCreator: ({required bannerId}) {
              final handle = _FakeBannerHandle(bannerId: bannerId);
              handles.add(handle);
              return handle;
            },
          ).buildPassiveSlot(strings: AppStrings.english),
        ),
      ),
    );
    await tester.pump();

    expect(handles, hasLength(2));
    expect(handles.first.disposeCalls, 1);
    expect(handles.last.loadCalls, 1);
  });

  testWidgets('widget disposal disposes the handle exactly once',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = _testFactory(
      consentFlow: consentFlow,
      handles: handles,
      completeOnLoad: false,
    );

    await tester.pumpWidget(_shell(factory));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());

    expect(handles.single.disposeCalls, 1);
  });

  testWidgets('thrown load failure disposes the failed handle exactly once',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = _testFactory(
      consentFlow: consentFlow,
      handles: handles,
      throwOnLoad: true,
    );

    await tester.pumpWidget(_shell(factory));
    await tester.pump();

    expect(handles, hasLength(2));
    expect(handles.first.disposeCalls, 1);
    expect(handles.last.loadCalls, 1);
  });

  testWidgets('callback failure disposes the failed handle exactly once',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = _testFactory(
      consentFlow: consentFlow,
      handles: handles,
      failFirstLoad: true,
    );

    await tester.pumpWidget(_shell(factory));
    await tester.pump();

    expect(handles, hasLength(2));
    expect(handles.first.disposeCalls, 1);
    expect(handles.first.loadCalls, 1);
    expect(handles.last.loadCalls, 1);
    expect(find.text('banner:banner-1-retry'), findsOneWidget);
  });

  testWidgets('persistent failure does not create an infinite retry loop',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = _testFactory(
      consentFlow: consentFlow,
      handles: handles,
      failAlways: true,
    );

    await tester.pumpWidget(_shell(factory));
    await tester.pump();

    expect(handles, hasLength(2));
    expect(handles[0].disposeCalls, 1);
    expect(handles[1].disposeCalls, 1);
    expect(handles[1].loadCalls, 1);
  });

  testWidgets('reserved height stays stable while loading and after success',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = _testFactory(
      consentFlow: consentFlow,
      handles: handles,
    );

    await tester.pumpWidget(_shell(factory));
    final loadingSize =
        tester.getSize(find.byKey(const ValueKey('banner-slot')));
    await tester.pump();
    final loadedSize =
        tester.getSize(find.byKey(const ValueKey('banner-slot')));

    expect(loadingSize.height, loadedSize.height);
  });
}

Widget _shell(RealAdWidgetFactory factory) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (_) => factory.buildPassiveSlot(strings: AppStrings.english),
      ),
    ),
  );
}

RealAdWidgetFactory _testFactory({
  required _FakeConsentFlow consentFlow,
  required List<_FakeBannerHandle> handles,
  bool completeOnLoad = true,
  bool failFirstLoad = false,
  bool failAlways = false,
  bool throwOnLoad = false,
}) {
  var attempt = 0;
  return RealAdWidgetFactory(
    consentFlow: consentFlow,
    bannerId: 'banner-1',
    bannerCreator: ({required bannerId}) {
      attempt++;
      final handle = _FakeBannerHandle(
        bannerId: attempt == 2 ? 'banner-1-retry' : bannerId,
        completeOnLoad: completeOnLoad,
        failFirstLoad: failFirstLoad && attempt == 1,
        failAlways: failAlways,
        throwOnLoad: throwOnLoad && attempt == 1,
      );
      handles.add(handle);
      return handle;
    },
  );
}

class _FakeConsentFlow extends ChangeNotifier implements ConsentFlow {
  _FakeConsentFlow({required bool canRequestAds})
      : _canRequestAds = canRequestAds;

  bool _canRequestAds;

  void setCanRequestAds(bool value) {
    _canRequestAds = value;
    notifyListeners();
  }

  @override
  bool get canRequestAds => _canRequestAds;

  @override
  bool get privacyOptionsRequired => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showPrivacyOptions() async {}
}

class _FakeBannerHandle implements BannerSlotHandle {
  _FakeBannerHandle({
    required this.bannerId,
    this.completeOnLoad = true,
    this.failFirstLoad = false,
    this.failAlways = false,
    this.throwOnLoad = false,
  });

  final String bannerId;
  final bool completeOnLoad;
  final bool failFirstLoad;
  final bool failAlways;
  final bool throwOnLoad;
  var loadCalls = 0;
  var disposeCalls = 0;
  var loaded = false;
  var _widgetVisible = false;
  var _failedOnce = false;
  var _disposed = false;

  @override
  Future<void> load({
    required void Function(BannerSlotHandle handle) onLoaded,
    required void Function() onFailedToLoad,
  }) async {
    loadCalls++;
    if (throwOnLoad) {
      throw StateError('load failed');
    }
    if (failAlways || (failFirstLoad && !_failedOnce)) {
      _failedOnce = true;
      onFailedToLoad();
      return;
    }
    if (completeOnLoad) {
      loaded = true;
      _widgetVisible = true;
      onLoaded(this);
    }
  }

  void simulateLoaded() {
    loaded = true;
    _widgetVisible = true;
  }

  @override
  Widget buildWidget() {
    return SizedBox(
      key: const ValueKey('banner-slot'),
      height: 50,
      child: _widgetVisible
          ? _FakeBannerWidget(bannerId: bannerId)
          : const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    disposeCalls++;
  }
}

class _FakeBannerWidget extends StatelessWidget {
  const _FakeBannerWidget({required this.bannerId});

  final String bannerId;

  @override
  Widget build(BuildContext context) {
    return Text('banner:$bannerId');
  }
}

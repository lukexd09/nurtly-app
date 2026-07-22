import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/ads/ad_widget_factory.dart';
import 'package:nurtly/core/ads/consent_flow_controller.dart';
import 'package:nurtly/core/localization/app_strings.dart';

void main() {
  testWidgets('banner slot uses one handle, one load, and renders the widget',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = RealAdWidgetFactory(
      consentFlow: consentFlow,
      bannerId: 'banner-1',
      bannerCreator: ({required bannerId}) {
        final handle = _FakeBannerHandle(bannerId: bannerId);
        handles.add(handle);
        return handle;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: factory.buildPassiveSlot(strings: AppStrings.english),
        ),
      ),
    );
    await tester.pump();

    expect(handles, hasLength(1));
    expect(handles.single.loadCalls, 1);
    expect(handles.single.loaded, isTrue);
    expect(find.byType(_FakeBannerWidget), findsOneWidget);
  });

  testWidgets('rebuild does not create duplicate banner handles or loads',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = RealAdWidgetFactory(
      consentFlow: consentFlow,
      bannerId: 'banner-1',
      bannerCreator: ({required bannerId}) {
        final handle = _FakeBannerHandle(bannerId: bannerId);
        handles.add(handle);
        return handle;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (_) =>
                factory.buildPassiveSlot(strings: AppStrings.english),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (_) =>
                factory.buildPassiveSlot(strings: AppStrings.english),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(handles, hasLength(1));
    expect(handles.single.loadCalls, 1);
  });

  testWidgets('consent revoke disposes the active loading handle',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = RealAdWidgetFactory(
      consentFlow: consentFlow,
      bannerId: 'banner-1',
      bannerCreator: ({required bannerId}) {
        final handle =
            _FakeBannerHandle(bannerId: bannerId, completeOnLoad: false);
        handles.add(handle);
        return handle;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: factory.buildPassiveSlot(strings: AppStrings.english),
        ),
      ),
    );
    await tester.pump();
    consentFlow.setCanRequestAds(false);
    await tester.pump();

    expect(handles.single.disposeCalls, 1);
    expect(find.byType(_FakeBannerWidget), findsNothing);
  });

  testWidgets('stale loaded callback after revoke is rejected', (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = RealAdWidgetFactory(
      consentFlow: consentFlow,
      bannerId: 'banner-1',
      bannerCreator: ({required bannerId}) {
        final handle =
            _FakeBannerHandle(bannerId: bannerId, completeOnLoad: false);
        handles.add(handle);
        return handle;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: factory.buildPassiveSlot(strings: AppStrings.english),
        ),
      ),
    );
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
    String bannerId = 'banner-1';
    final factory = RealAdWidgetFactory(
      consentFlow: consentFlow,
      bannerCreator: ({required bannerId}) {
        final handle = _FakeBannerHandle(bannerId: bannerId);
        handles.add(handle);
        return handle;
      },
    );

    Future<void> pump() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (_) => RealAdWidgetFactory(
                consentFlow: consentFlow,
                bannerId: bannerId,
                bannerCreator: factory.bannerCreator,
              ).buildPassiveSlot(strings: AppStrings.english),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pump();
    bannerId = 'banner-2';
    await pump();

    expect(handles, hasLength(2));
    expect(handles.first.disposeCalls, 1);
    expect(handles.last.loadCalls, 1);
  });

  testWidgets('widget disposal disposes the handle exactly once',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = RealAdWidgetFactory(
      consentFlow: consentFlow,
      bannerId: 'banner-1',
      bannerCreator: ({required bannerId}) {
        final handle =
            _FakeBannerHandle(bannerId: bannerId, completeOnLoad: false);
        handles.add(handle);
        return handle;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: factory.buildPassiveSlot(strings: AppStrings.english),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox());

    expect(handles.single.disposeCalls, 1);
  });

  testWidgets('failed load allows one controlled retry without leaking handle',
      (tester) async {
    final consentFlow = _FakeConsentFlow(canRequestAds: true);
    final handles = <_FakeBannerHandle>[];
    final factory = RealAdWidgetFactory(
      consentFlow: consentFlow,
      bannerId: 'banner-1',
      bannerCreator: ({required bannerId}) {
        final handle = _FakeBannerHandle(
          bannerId: bannerId,
          failOnLoadOnce: true,
        );
        handles.add(handle);
        return handle;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: factory.buildPassiveSlot(strings: AppStrings.english),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: factory.buildPassiveSlot(strings: AppStrings.english),
        ),
      ),
    );
    await tester.pump();

    expect(handles, hasLength(1));
    expect(handles.single.loadCalls, 1);
  });
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
    this.failOnLoadOnce = false,
  });

  final String bannerId;
  final bool completeOnLoad;
  final bool failOnLoadOnce;
  var loadCalls = 0;
  var disposeCalls = 0;
  var loaded = false;
  var _widgetVisible = false;
  var _failed = false;

  @override
  Future<void> load({
    required void Function(BannerSlotHandle handle) onLoaded,
    required void Function() onFailedToLoad,
  }) async {
    loadCalls++;
    if (failOnLoadOnce && !_failed) {
      _failed = true;
      onFailedToLoad();
      return;
    }
    loaded = completeOnLoad;
    if (completeOnLoad) {
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
    return _widgetVisible
        ? _FakeBannerWidget(bannerId: bannerId)
        : const SizedBox.shrink();
  }

  @override
  void dispose() {
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

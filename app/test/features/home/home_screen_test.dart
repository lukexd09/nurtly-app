import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/ads/ad_widget_factory.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/core/navigation/app_tab.dart';
import 'package:nurtly/features/home/home_screen.dart';

void main() {
  testWidgets('free home screen can show passive ad placeholder',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          strings: AppStrings.english,
          onSelectTab: (_) {},
          onOpenTodaysIdea: () {},
          showAdPlaceholder: true,
          adWidgetFactory: const FakeAdWidgetFactory(),
        ),
      ),
    );

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('ad-placeholder')),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sponsored space'), findsOneWidget);
    expect(find.byKey(const ValueKey('ad-placeholder')), findsOneWidget);
  });

  testWidgets('home screen stays ad-free when placeholder is disabled',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          strings: AppStrings.english,
          onSelectTab: (_) {},
          onOpenTodaysIdea: () {},
          showAdPlaceholder: false,
          adWidgetFactory: const FakeAdWidgetFactory(),
        ),
      ),
    );

    expect(find.text('Sponsored space'), findsNothing);
    expect(find.byKey(const ValueKey('ad-placeholder')), findsNothing);
  });

  testWidgets('home quick links still navigate without affecting ads',
      (tester) async {
    AppTab? tappedTab;
    var openedTodayIdea = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          strings: AppStrings.english,
          onSelectTab: (tab) => tappedTab = tab,
          onOpenTodaysIdea: () => openedTodayIdea++,
          showAdPlaceholder: true,
          adWidgetFactory: const FakeAdWidgetFactory(),
        ),
      ),
    );

    await tester.tap(find.text('Find a play idea'));
    await tester.pumpAndSettle();
    expect(tappedTab, AppTab.play);

    await tester.tap(find.text("Open today's idea"));
    await tester.pumpAndSettle();
    expect(openedTodayIdea, 1);

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('ad-placeholder')),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sponsored space'), findsOneWidget);
  });
}

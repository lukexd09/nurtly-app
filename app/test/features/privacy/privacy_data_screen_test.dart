import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_strings.dart';
import 'package:nurtly/features/privacy/privacy_data_screen.dart';

void main() {
  testWidgets('shows accessible English privacy policy action and current copy',
      (tester) async {
    Uri? openedUri;
    await tester.pumpWidget(
      MaterialApp(
        home: PrivacyDataScreen(
          externalUrlLauncher: (uri) async {
            openedUri = uri;
            return true;
          },
        ),
      ),
    );

    final action = find.byKey(const ValueKey('privacy-policy-action'));
    expect(action, findsOneWidget);
    expect(find.text('Open Privacy Policy'), findsOneWidget);
    expect(find.textContaining('18 or older'), findsOneWidget);
    expect(
      find.textContaining('not intended for independent use by children'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
          'No child account, child name, or exact date of birth is required.'),
      findsOneWidget,
    );
    expect(find.textContaining('A child name is not required'), findsNothing);
    expect(find.textContaining('exact child birthdate'), findsNothing);
    expect(find.text('Future changes'), findsNothing);
    expect(find.textContaining('passive list slots'), findsNothing);
    expect(
      tester
          .getSemantics(
              find.byKey(const ValueKey('privacy-policy-link-semantics')))
          .flagsCollection
          .isLink,
      isTrue,
    );
    expect(find.textContaining('no product analytics SDK'), findsOneWidget);
    expect(
      find.textContaining('If analytics is added later'),
      findsNothing,
    );

    await tester.tap(find.text('Open Privacy Policy'));
    await tester.pump();
    expect(openedUri.toString(), 'https://nurtly.graylion.pl/privacy/en');
  });

  testWidgets('opens the Polish policy route and localizes the action',
      (tester) async {
    Uri? openedUri;
    await tester.pumpWidget(
      MaterialApp(
        home: PrivacyDataScreen(
          strings: AppStrings.polish,
          externalUrlLauncher: (uri) async {
            openedUri = uri;
            return true;
          },
        ),
      ),
    );

    expect(find.text('Otwórz Politykę prywatności'), findsOneWidget);
    expect(find.textContaining('co najmniej 18 lat'), findsOneWidget);
    expect(
      find.textContaining('samodzielnego używania przez dzieci'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
          'Konto dziecka, jego imię ani dokładna data urodzenia nie są wymagane.'),
      findsOneWidget,
    );
    expect(find.text('Przyszłe zmiany'), findsNothing);
    expect(find.textContaining('spokojnych miejscach list'), findsNothing);
    await tester.ensureVisible(find.text('Otwórz Politykę prywatności'));
    await tester.tap(find.text('Otwórz Politykę prywatności'));
    await tester.pump();
    expect(openedUri.toString(), 'https://nurtly.graylion.pl/privacy/pl');
  });

  testWidgets('shows English failure when launcher returns false',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PrivacyDataScreen(
          externalUrlLauncher: (_) async => false,
        ),
      ),
    );
    await tester.ensureVisible(find.text('Open Privacy Policy'));
    await tester.tap(find.text('Open Privacy Policy'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not open the Privacy Policy. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('shows Polish failure when launcher throws', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PrivacyDataScreen(
          strings: AppStrings.polish,
          externalUrlLauncher: (_) async => throw StateError('not shown'),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Otwórz Politykę prywatności'));
    await tester.tap(find.text('Otwórz Politykę prywatności'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nie udało się otworzyć'), findsOneWidget);
  });

  testWidgets('does not show a failure after the screen unmounts',
      (tester) async {
    final launchResult = Completer<bool>();
    await tester.pumpWidget(
      MaterialApp(
        home: PrivacyDataScreen(
          externalUrlLauncher: (_) async {
            return launchResult.future;
          },
        ),
      ),
    );
    await tester.ensureVisible(find.text('Open Privacy Policy'));
    await tester.tap(find.text('Open Privacy Policy'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    launchResult.complete(false);
    await tester.pump();
    expect(find.text('Could not open the Privacy Policy. Please try again.'),
        findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/features/privacy/privacy_data_screen.dart';

void main() {
  testWidgets('shows privacy data screen content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrivacyDataScreen(),
      ),
    );

    expect(find.text('Privacy & Data'), findsOneWidget);
    expect(find.text('- No account is used.'), findsOneWidget);
    expect(find.text('- Premium removes ads.'), findsOneWidget);
    expect(find.text('- No cloud sync is currently enabled.'), findsOneWidget);
    expect(find.text('- No analytics are currently enabled.'), findsOneWidget);
    expect(
      find.text('- Free plan may show ads in passive list slots.'),
      findsOneWidget,
    );
    expect(
      find.text('- Purchases on Android go through Google Play.'),
      findsOneWidget,
    );
    expect(
      find.text('- Journal note content is not used for ads.'),
      findsOneWidget,
    );
    expect(
      find.text(
        '- Premium state may be stored locally to keep access working.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('- Bundled sample content is included in the app.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Future changes'), 120);
    expect(find.text('Future changes'), findsOneWidget);
  });
}

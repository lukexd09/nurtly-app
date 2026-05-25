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
    expect(find.text('- No cloud sync is currently enabled.'), findsOneWidget);
    expect(find.text('- No analytics are currently enabled.'), findsOneWidget);
    expect(find.text('- No ads are currently enabled.'), findsOneWidget);
    expect(
      find.text('- Bundled sample content is included in the app.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Future data-related changes should be introduced clearly before they are enabled.',
      ),
      findsOneWidget,
    );
  });
}

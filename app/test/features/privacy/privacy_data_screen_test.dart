import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/main.dart';

void main() {
  testWidgets('opens Privacy & Data from settings', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    await tester.tap(find.byTooltip('Settings'));
    await tester.pump(const Duration(milliseconds: 250));

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.byKey(const ValueKey('settings-privacy-data')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));

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

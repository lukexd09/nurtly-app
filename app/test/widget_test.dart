import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/app_config.dart';
import 'package:nurtly/main.dart';

void main() {
  testWidgets('shows placeholder home screen', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    expect(find.text(appName), findsOneWidget);
    expect(find.text(appSubtitle), findsOneWidget);
  });
}

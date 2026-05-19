import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/main.dart';

void main() {
  testWidgets('shows app shell tabs', (tester) async {
    await tester.pumpWidget(const NurtlyApp());

    expect(find.text('Play'), findsWidgets);
    expect(find.text('Journal'), findsWidgets);
    expect(find.text('Sounds'), findsWidgets);
    expect(find.byTooltip('Privacy & Data'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Soft treasure basket'), findsOneWidget);
  });
}

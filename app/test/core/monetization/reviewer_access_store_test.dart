import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/monetization/reviewer_access_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('load returns false when nothing is stored', () async {
    final store = SharedPreferencesReviewerAccessStore();

    expect(await store.load(), isFalse);
  });

  test('save(true) persists reviewer access across loads', () async {
    final store = SharedPreferencesReviewerAccessStore();

    await store.save(true);

    expect(await store.load(), isTrue);
  });

  test('delete removes persisted reviewer access', () async {
    final store = SharedPreferencesReviewerAccessStore();

    await store.save(true);
    await store.delete();

    expect(await store.load(), isFalse);
  });
}

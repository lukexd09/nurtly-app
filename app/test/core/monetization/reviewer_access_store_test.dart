import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurtly/core/monetization/reviewer_access_store.dart';

import '../../test_fakes/fake_shared_preferences_store_platform.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

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

  test('delete failures remain retryable', () async {
    final previous = SharedPreferencesStorePlatform.instance;
    final platform = FakeSharedPreferencesStorePlatform(
      falseOnRemoveKeys: {SharedPreferencesReviewerAccessStore.key},
    );
    SharedPreferencesStorePlatform.instance = platform;
    addTearDown(() => SharedPreferencesStorePlatform.instance = previous);
    final store = SharedPreferencesReviewerAccessStore();

    await expectLater(store.delete(), throwsStateError);
  });
}

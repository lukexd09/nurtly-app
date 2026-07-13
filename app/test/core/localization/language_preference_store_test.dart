import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurtly/core/localization/app_language.dart';
import 'package:nurtly/core/localization/language_preference_store.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../test_fakes/fake_shared_preferences_store_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('store saves and loads English', () async {
    final store = SharedPreferencesLanguagePreferenceStore();

    await store.save(AppLanguage.english);

    expect(await store.load(), AppLanguage.english);
  });

  test('store saves and loads Polish', () async {
    final store = SharedPreferencesLanguagePreferenceStore();

    await store.save(AppLanguage.polish);

    expect(await store.load(), AppLanguage.polish);
  });

  test('store returns null for missing value', () async {
    final store = SharedPreferencesLanguagePreferenceStore();

    expect(await store.load(), isNull);
  });

  test('store returns null for unknown or corrupted value', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      SharedPreferencesLanguagePreferenceStore.key: 'de',
    });
    final store = SharedPreferencesLanguagePreferenceStore();

    expect(await store.load(), isNull);
  });

  test('delete failures remain retryable', () async {
    final previous = SharedPreferencesStorePlatform.instance;
    final platform = FakeSharedPreferencesStorePlatform(
      initialValues: {
        SharedPreferencesLanguagePreferenceStore.key: 'en',
      },
      falseOnRemoveKeys: {SharedPreferencesLanguagePreferenceStore.key},
    );
    SharedPreferencesStorePlatform.instance = platform;
    addTearDown(() => SharedPreferencesStorePlatform.instance = previous);
    SharedPreferences.resetStatic();
    final store = SharedPreferencesLanguagePreferenceStore();

    await expectLater(store.delete(), throwsStateError);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SharedPreferencesLanguagePreferenceStore.key), 'en');

    platform.disableRemoveFailure(SharedPreferencesLanguagePreferenceStore.key);
    await store.delete();

    final refreshed = await SharedPreferences.getInstance();
    expect(
      refreshed.getString(SharedPreferencesLanguagePreferenceStore.key),
      isNull,
    );
    expect(
      platform
          .containsPersistedKey(SharedPreferencesLanguagePreferenceStore.key),
      isFalse,
    );
  });
}

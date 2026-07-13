import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nurtly/core/localization/app_language.dart';
import 'package:nurtly/core/localization/language_preference_store.dart';

import '../../test_fakes/fake_shared_preferences_store_platform.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

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
      falseOnRemoveKeys: {SharedPreferencesLanguagePreferenceStore.key},
    );
    SharedPreferencesStorePlatform.instance = platform;
    addTearDown(() => SharedPreferencesStorePlatform.instance = previous);
    final store = SharedPreferencesLanguagePreferenceStore();

    await expectLater(store.delete(), throwsStateError);
  });
}

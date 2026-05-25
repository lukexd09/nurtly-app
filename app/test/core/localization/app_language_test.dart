import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_language.dart';

void main() {
  const resolver = AppLocaleResolver();

  test('system preference resolves Polish when system locale is pl', () {
    expect(
      resolver.resolve(
        preference: AppLanguagePreference.system,
        systemLocale: const Locale('pl'),
      ),
      AppLanguage.polish,
    );
  });

  test('system preference resolves English when system locale is en', () {
    expect(
      resolver.resolve(
        preference: AppLanguagePreference.system,
        systemLocale: const Locale('en'),
      ),
      AppLanguage.english,
    );
  });

  test('system preference falls back to English for unsupported locale', () {
    expect(
      resolver.resolve(
        preference: AppLanguagePreference.system,
        systemLocale: const Locale('de'),
      ),
      AppLanguage.english,
    );
  });

  test('explicit Polish preference overrides English system locale', () {
    expect(
      resolver.resolve(
        preference: AppLanguagePreference.polish,
        systemLocale: const Locale('en'),
      ),
      AppLanguage.polish,
    );
  });

  test('explicit English preference overrides Polish system locale', () {
    expect(
      resolver.resolve(
        preference: AppLanguagePreference.english,
        systemLocale: const Locale('pl'),
      ),
      AppLanguage.english,
    );
  });

  test('language codes map to supported locales', () {
    expect(AppLanguage.english.languageCode, 'en');
    expect(AppLanguage.polish.languageCode, 'pl');
  });

  test('display names are readable', () {
    expect(AppLanguage.english.displayName, 'English');
    expect(AppLanguage.polish.displayName, 'Polski');
  });
}

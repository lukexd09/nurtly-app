import 'dart:ui';

enum AppLanguage {
  english,
  polish,
}

enum AppLanguagePreference {
  system,
  english,
  polish,
}

extension AppLanguageX on AppLanguage {
  String get languageCode => switch (this) {
        AppLanguage.english => 'en',
        AppLanguage.polish => 'pl',
      };

  String get displayName => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.polish => 'Polski',
      };
}

class AppLocaleResolver {
  const AppLocaleResolver();

  AppLanguage resolve({
    required AppLanguagePreference preference,
    required Locale systemLocale,
  }) {
    return switch (preference) {
      AppLanguagePreference.english => AppLanguage.english,
      AppLanguagePreference.polish => AppLanguage.polish,
      AppLanguagePreference.system => _resolveSystemLocale(systemLocale),
    };
  }

  AppLanguage _resolveSystemLocale(Locale systemLocale) {
    return switch (systemLocale.languageCode) {
      'pl' => AppLanguage.polish,
      'en' => AppLanguage.english,
      _ => AppLanguage.english,
    };
  }
}

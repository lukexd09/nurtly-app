import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

abstract interface class LanguagePreferenceStore {
  Future<AppLanguage?> load();

  Future<void> save(AppLanguage language);
}

class SharedPreferencesLanguagePreferenceStore
    implements LanguagePreferenceStore {
  const SharedPreferencesLanguagePreferenceStore();

  static const String key = 'nurtly.selected_language';

  @override
  Future<AppLanguage?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(key);
    return switch (code) {
      'en' => AppLanguage.english,
      'pl' => AppLanguage.polish,
      _ => null,
    };
  }

  @override
  Future<void> save(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, language.languageCode);
  }
}

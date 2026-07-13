import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

abstract interface class LanguagePreferenceStore {
  Future<AppLanguage?> load();

  Future<void> save(AppLanguage language);

  Future<void> delete();
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
    final success = await prefs.setString(key, language.languageCode);
    if (!success) {
      try {
        await prefs.reload();
      } catch (_) {
        throw StateError('language preference write failed');
      }
      throw StateError('language preference write failed');
    }
  }

  @override
  Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.remove(key);
    if (!success) {
      try {
        await prefs.reload();
      } catch (_) {
        throw StateError('language preference delete failed');
      }
      throw StateError('language preference delete failed');
    }
  }
}

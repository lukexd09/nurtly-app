import 'package:nurtly/core/localization/app_language.dart';
import 'package:nurtly/core/localization/language_preference_store.dart';

class FakeLanguagePreferenceStore implements LanguagePreferenceStore {
  FakeLanguagePreferenceStore({this.saved});

  AppLanguage? saved;
  final List<AppLanguage> savedValues = [];

  @override
  Future<AppLanguage?> load() async => saved;

  @override
  Future<void> save(AppLanguage language) async {
    saved = language;
    savedValues.add(language);
  }
}

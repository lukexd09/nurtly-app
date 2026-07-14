import 'core/localization/app_language.dart';

const appName = 'Nurtly';
const appSubtitle = 'Simple support for calm, connected parenting.';

abstract final class PrivacyPolicyRoutes {
  static Uri forLanguage(AppLanguage language) {
    final suffix = language == AppLanguage.polish ? 'pl' : 'en';
    return Uri.parse('https://nurtly.graylion.pl/privacy/$suffix');
  }
}

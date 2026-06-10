import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_strings.dart';

void main() {
  test('privacy strings expose MVP privacy and data copy in English', () {
    const strings = AppStrings.english;

    expect(
      strings.parentFirstAudience,
      'Nurtly is for parents and caregivers, not for children.',
    );
    expect(
      strings.childNameNotRequired,
      'A child name is not required to use the MVP.',
    );
    expect(
      strings.birthdateNotRequired,
      'An exact child birthdate is not required in the MVP.',
    );
    expect(
      strings.analyticsScopeMayInclude,
      'If analytics is added later, it should stay limited to app quality, module usage, retention, ads, and errors.',
    );
  });

  test('privacy strings expose MVP privacy and data copy in Polish', () {
    const strings = AppStrings.polish;

    expect(
      strings.parentFirstAudience,
      'Nurtly jest dla rodziców i opiekunów, nie dla dzieci.',
    );
    expect(
      strings.childNameNotRequired,
      'Imię dziecka nie jest wymagane do korzystania z MVP.',
    );
    expect(
      strings.birthdateNotRequired,
      'Dokładna data urodzenia dziecka nie jest wymagana w MVP.',
    );
    expect(
      strings.analyticsScopeMayInclude,
      'Jeśli analityka zostanie dodana później, powinna ograniczać się do jakości aplikacji, użycia modułów, retencji, reklam i błędów.',
    );
  });
}

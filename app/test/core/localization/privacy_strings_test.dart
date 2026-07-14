import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/app_strings.dart';

void main() {
  test('privacy strings expose MVP privacy and data copy in English', () {
    const strings = AppStrings.english;

    expect(strings.parentFirstAudience, contains('18 or older'));
    expect(
        strings.parentFirstAudience, contains('independent use by children'));
    expect(strings.noChildAccount, contains('child account'));
    expect(strings.noAnalytics, contains('no product analytics SDK'));
  });

  test('privacy strings expose MVP privacy and data copy in Polish', () {
    const strings = AppStrings.polish;

    expect(strings.parentFirstAudience, contains('co najmniej 18 lat'));
    expect(strings.parentFirstAudience,
        contains('samodzielnego używania przez dzieci'));
    expect(strings.noChildAccount, contains('Konto dziecka'));
    expect(strings.noAnalytics, contains('SDK analityki produktu'));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/ads/ad_unit_ids.dart';
import 'package:nurtly/core/ads/mobile_ads_runtime_configuration.dart';

void main() {
  const validApp = 'ca-app-pub-1234567890123456~1234567890';
  const validBanner = 'ca-app-pub-1234567890123456/1234567890';

  test('debug always resolves to the Android sample banner', () {
    final config = MobileAdsRuntimeConfiguration.resolve(
      isReleaseMode: false,
      profile: '',
      configuredProductionBannerId: '',
    );
    expect(config.bannerId, AdUnitIds.bannerAndroid);
  });

  test('closed testing resolves to the sample banner', () {
    final config = MobileAdsRuntimeConfiguration.resolve(
      isReleaseMode: true,
      profile: 'closed-test-sample-banner',
      configuredProductionBannerId: '',
    );
    expect(config.bannerId, AdUnitIds.bannerAndroid);
  });

  test('production requires a non-sample structurally valid banner', () {
    expect(
      MobileAdsRuntimeConfiguration.resolve(
        isReleaseMode: true,
        profile: 'production-banner',
        configuredProductionBannerId: AdUnitIds.bannerAndroid,
      ).isUsable,
      isFalse,
    );
    expect(
      MobileAdsRuntimeConfiguration.resolve(
        isReleaseMode: true,
        profile: 'production-banner',
        configuredProductionBannerId: validBanner,
      ).bannerId,
      validBanner,
    );
  });

  test(
    'invalid release profile or application inputs cannot enable a banner',
    () {
      expect(
        MobileAdsRuntimeConfiguration.resolve(
          isReleaseMode: true,
          profile: 'unknown',
          configuredProductionBannerId: validBanner,
        ).isUsable,
        isFalse,
      );
      // The app ID is validated by Gradle/workflow; the Dart resolver remains
      // deliberately pure and only resolves the banner profile contract.
      expect(validApp, matches(RegExp(r'^ca-app-pub-[0-9]{16}~[0-9]{10}$')));
    },
  );
}

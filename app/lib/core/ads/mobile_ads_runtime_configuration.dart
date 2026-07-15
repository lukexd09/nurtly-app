import 'ad_unit_ids.dart';

enum MobileAdsProfile {
  closedTestSampleBanner('closed-test-sample-banner'),
  productionBanner('production-banner');

  const MobileAdsProfile(this.value);
  final String value;

  static MobileAdsProfile? parse(String value) {
    for (final profile in values) {
      if (profile.value == value.trim()) return profile;
    }
    return null;
  }
}

class MobileAdsRuntimeConfiguration {
  const MobileAdsRuntimeConfiguration._({required this.bannerId});

  final String? bannerId;

  bool get isUsable => bannerId != null;

  static MobileAdsRuntimeConfiguration resolve({
    required bool isReleaseMode,
    required String profile,
    required String configuredProductionBannerId,
  }) {
    if (!isReleaseMode) {
      return const MobileAdsRuntimeConfiguration._(
        bannerId: AdUnitIds.bannerAndroid,
      );
    }
    final parsed = MobileAdsProfile.parse(profile);
    if (parsed == null) {
      return const MobileAdsRuntimeConfiguration._(bannerId: null);
    }
    if (parsed == MobileAdsProfile.closedTestSampleBanner) {
      return const MobileAdsRuntimeConfiguration._(
        bannerId: AdUnitIds.bannerAndroid,
      );
    }
    final bannerId = configuredProductionBannerId.trim();
    if (bannerId.isEmpty || AdUnitIds.isKnownSampleBanner(bannerId)) {
      return const MobileAdsRuntimeConfiguration._(bannerId: null);
    }
    if (!RegExp(r'^ca-app-pub-[0-9]{16}/[0-9]{10}$').hasMatch(bannerId)) {
      return const MobileAdsRuntimeConfiguration._(bannerId: null);
    }
    return MobileAdsRuntimeConfiguration._(bannerId: bannerId);
  }
}

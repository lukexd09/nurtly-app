class AdUnitIds {
  const AdUnitIds._();

  static const String bannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String bannerIos = 'ca-app-pub-3940256099942544/2934735716';

  static bool isKnownSampleBanner(String value) =>
      value == bannerAndroid || value == bannerIos;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/monetization/premium_entitlement.dart';

void main() {
  final now = DateTime.utc(2026, 5, 26, 12);

  test('free entitlement has no premium access and shows ads', () {
    final entitlement = PremiumEntitlement.free(checkedAt: now);

    expect(entitlement.hasPremiumAccess, isFalse);
    expect(entitlement.shouldShowAds, isTrue);
    expect(entitlement.canAccessPremiumContent, isFalse);
  });

  test('active monthly before expiresAt has premium access and no ads', () {
    final entitlement = PremiumEntitlement.monthlyActive(
      checkedAt: now,
      expiresAt: now.add(const Duration(days: 1)),
    );

    expect(entitlement.hasPremiumAccessAt(now), isTrue);
    expect(entitlement.canAccessPremiumContentAt(now), isTrue);
    expect(entitlement.shouldShowAdsAt(now), isFalse);
  });

  test('active monthly without expiresAt still has premium access', () {
    final entitlement = PremiumEntitlement.monthlyActive(
      checkedAt: now,
    );

    expect(entitlement.hasPremiumAccessAt(now), isTrue);
    expect(entitlement.shouldShowAds, isFalse);
    expect(entitlement.needsRefresh(now), isFalse);
  });

  test('active monthly needs refresh after 24h', () {
    final entitlement = PremiumEntitlement.monthlyActive(
      checkedAt: now.subtract(const Duration(hours: 25)),
      expiresAt: now.add(const Duration(days: 1)),
    );

    expect(entitlement.needsRefresh(now), isTrue);
  });

  test('active monthly expired needs refresh', () {
    final entitlement = PremiumEntitlement.monthlyActive(
      checkedAt: now,
      expiresAt: now.subtract(const Duration(minutes: 1)),
    );

    expect(entitlement.needsRefresh(now), isTrue);
  });

  test('expired monthly has no premium access', () {
    final entitlement = PremiumEntitlement.expired(
      checkedAt: now,
      source: PremiumSource.monthly,
      expiresAt: now.subtract(const Duration(hours: 2)),
    );

    expect(entitlement.hasPremiumAccessAt(now), isFalse);
    expect(entitlement.shouldShowAds, isTrue);
  });

  test('gracePeriod has premium access and no ads', () {
    final entitlement = PremiumEntitlement.monthlyGracePeriod(
      checkedAt: now.subtract(const Duration(hours: 2)),
      expiresAt: now.subtract(const Duration(hours: 2)),
    );

    expect(entitlement.hasPremiumAccess, isTrue);
    expect(entitlement.shouldShowAds, isFalse);
    expect(entitlement.canAccessPremiumContent, isTrue);
  });

  test('accountHold has no premium access and shows ads', () {
    final entitlement = PremiumEntitlement.accountHold(checkedAt: now);

    expect(entitlement.hasPremiumAccess, isFalse);
    expect(entitlement.shouldShowAds, isTrue);
  });

  test('pending has no premium access', () {
    final entitlement = PremiumEntitlement.pending(checkedAt: now);

    expect(entitlement.hasPremiumAccess, isFalse);
    expect(entitlement.canAccessPremiumContent, isFalse);
  });

  test('yearly active has premium access', () {
    final entitlement = PremiumEntitlement.yearlyActive(checkedAt: now);

    expect(entitlement.hasPremiumAccess, isTrue);
    expect(entitlement.shouldShowAds, isFalse);
  });

  test('yearly checked 6 days ago does not need refresh', () {
    final entitlement = PremiumEntitlement.yearlyActive(
      checkedAt: now.subtract(const Duration(days: 6)),
    );

    expect(entitlement.needsRefresh(now), isFalse);
    expect(entitlement.hasPremiumAccess, isTrue);
  });

  test('yearly checked 8 days ago needs refresh but still has access', () {
    final entitlement = PremiumEntitlement.yearlyActive(
      checkedAt: now.subtract(const Duration(days: 8)),
    );

    expect(entitlement.needsRefresh(now), isTrue);
    expect(entitlement.hasPremiumAccess, isTrue);
  });

  test('monthly soft grace allows access for up to 24 hours after expiry', () {
    final entitlement = PremiumEntitlement.monthlyActive(
      checkedAt: now,
      expiresAt: now.subtract(const Duration(hours: 6)),
    );

    expect(entitlement.allowsOfflineSoftGrace(now), isTrue);
    expect(entitlement.canAccessPremiumContentAt(now), isTrue);
  });

  test('monthly soft grace stops after 24 hours', () {
    final entitlement = PremiumEntitlement.monthlyActive(
      checkedAt: now,
      expiresAt: now.subtract(const Duration(hours: 25)),
    );

    expect(entitlement.allowsOfflineSoftGrace(now), isFalse);
    expect(entitlement.canAccessPremiumContentAt(now), isFalse);
  });
}

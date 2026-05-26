enum PremiumSource {
  none,
  monthly,
  lifetime,
}

enum PremiumState {
  free,
  active,
  gracePeriod,
  accountHold,
  expired,
  pending,
}

class PremiumEntitlement {
  const PremiumEntitlement({
    required this.state,
    required this.source,
    required this.checkedAt,
    this.expiresAt,
  });

  factory PremiumEntitlement.free({DateTime? checkedAt}) {
    return PremiumEntitlement(
      state: PremiumState.free,
      source: PremiumSource.none,
      checkedAt: checkedAt ?? DateTime.now(),
    );
  }

  factory PremiumEntitlement.monthlyActive({
    required DateTime checkedAt,
    required DateTime expiresAt,
  }) {
    return PremiumEntitlement(
      state: PremiumState.active,
      source: PremiumSource.monthly,
      checkedAt: checkedAt,
      expiresAt: expiresAt,
    );
  }

  factory PremiumEntitlement.monthlyGracePeriod({
    required DateTime checkedAt,
    required DateTime expiresAt,
  }) {
    return PremiumEntitlement(
      state: PremiumState.gracePeriod,
      source: PremiumSource.monthly,
      checkedAt: checkedAt,
      expiresAt: expiresAt,
    );
  }

  factory PremiumEntitlement.lifetimeActive({
    required DateTime checkedAt,
  }) {
    return PremiumEntitlement(
      state: PremiumState.active,
      source: PremiumSource.lifetime,
      checkedAt: checkedAt,
    );
  }

  factory PremiumEntitlement.accountHold({
    required DateTime checkedAt,
    PremiumSource source = PremiumSource.none,
    DateTime? expiresAt,
  }) {
    return PremiumEntitlement(
      state: PremiumState.accountHold,
      source: source,
      checkedAt: checkedAt,
      expiresAt: expiresAt,
    );
  }

  factory PremiumEntitlement.expired({
    required DateTime checkedAt,
    PremiumSource source = PremiumSource.none,
    DateTime? expiresAt,
  }) {
    return PremiumEntitlement(
      state: PremiumState.expired,
      source: source,
      checkedAt: checkedAt,
      expiresAt: expiresAt,
    );
  }

  factory PremiumEntitlement.pending({
    required DateTime checkedAt,
    PremiumSource source = PremiumSource.none,
    DateTime? expiresAt,
  }) {
    return PremiumEntitlement(
      state: PremiumState.pending,
      source: source,
      checkedAt: checkedAt,
      expiresAt: expiresAt,
    );
  }

  final PremiumState state;
  final PremiumSource source;
  final DateTime checkedAt;
  final DateTime? expiresAt;

  bool get hasPremiumAccess => hasPremiumAccessAt(DateTime.now());

  bool get shouldShowAds => !hasPremiumAccess;

  bool get canAccessPremiumContent => hasPremiumAccess;

  bool hasPremiumAccessAt(DateTime now) {
    if (state == PremiumState.gracePeriod) {
      return true;
    }

    if (state != PremiumState.active) {
      return false;
    }

    return switch (source) {
      PremiumSource.lifetime => true,
      PremiumSource.monthly => _isMonthlyAccessAllowed(now),
      PremiumSource.none => false,
    };
  }

  bool canAccessPremiumContentAt(DateTime now) => hasPremiumAccessAt(now);

  bool needsRefresh(DateTime now) {
    return switch (source) {
      PremiumSource.monthly => _needsMonthlyRefresh(now),
      PremiumSource.lifetime =>
        now.difference(checkedAt) > const Duration(days: 7),
      PremiumSource.none => false,
    };
  }

  bool allowsOfflineSoftGrace(DateTime now) {
    if (source != PremiumSource.monthly || expiresAt == null) {
      return false;
    }
    if (!now.isAfter(expiresAt!)) {
      return false;
    }
    return now.difference(expiresAt!) <= const Duration(hours: 24);
  }

  bool _isMonthlyAccessAllowed(DateTime now) {
    if (expiresAt == null) {
      return false;
    }
    if (!now.isAfter(expiresAt!)) {
      return true;
    }
    return allowsOfflineSoftGrace(now);
  }

  bool _needsMonthlyRefresh(DateTime now) {
    if (now.difference(checkedAt) > const Duration(hours: 24)) {
      return true;
    }
    if (expiresAt == null) {
      return false;
    }
    return now.isAfter(expiresAt!);
  }
}

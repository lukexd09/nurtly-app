class AdInsertionPolicy {
  const AdInsertionPolicy({
    this.firstAdAfterItems = 3,
    this.repeatEveryItems = 20,
  });

  final int firstAdAfterItems;
  final int repeatEveryItems;

  bool shouldInsertAdAfterContentIndex({
    required int contentIndexOneBased,
    required int totalVisibleItems,
    required bool isFiltered,
  }) {
    if (totalVisibleItems <= 0 || contentIndexOneBased <= 0) {
      return false;
    }

    if (isFiltered) {
      if (totalVisibleItems < firstAdAfterItems) {
        return false;
      }
      return contentIndexOneBased <= totalVisibleItems &&
          _isRecurringAdSlot(contentIndexOneBased);
    }

    if (totalVisibleItems < firstAdAfterItems) {
      return contentIndexOneBased == totalVisibleItems;
    }

    return contentIndexOneBased <= totalVisibleItems &&
        _isRecurringAdSlot(contentIndexOneBased);
  }

  bool _isRecurringAdSlot(int contentIndexOneBased) {
    if (contentIndexOneBased < firstAdAfterItems) {
      return false;
    }

    return (contentIndexOneBased - firstAdAfterItems) % repeatEveryItems == 0;
  }
}

enum LocalDataComponent { journal, language, reviewerAccess }

enum LocalDataDeletionStatus { complete, partial, failed }

class LocalDataDeletionResult {
  const LocalDataDeletionResult({
    required this.succeeded,
    required this.failed,
  });

  final Set<LocalDataComponent> succeeded;
  final Set<LocalDataComponent> failed;

  LocalDataDeletionStatus get status {
    if (failed.isEmpty) {
      return LocalDataDeletionStatus.complete;
    }
    if (succeeded.isEmpty) {
      return LocalDataDeletionStatus.failed;
    }
    return LocalDataDeletionStatus.partial;
  }
}

class LocalDataDeletionCoordinator {
  const LocalDataDeletionCoordinator();

  Future<LocalDataDeletionResult> deleteAll({
    required Future<void> Function() deleteJournal,
    required Future<void> Function() deleteLanguage,
    required Future<void> Function() deleteReviewerAccess,
  }) async {
    final succeeded = <LocalDataComponent>{};
    final failed = <LocalDataComponent>{};

    await _run(LocalDataComponent.journal, deleteJournal, succeeded, failed);
    await _run(LocalDataComponent.language, deleteLanguage, succeeded, failed);
    await _run(
      LocalDataComponent.reviewerAccess,
      deleteReviewerAccess,
      succeeded,
      failed,
    );

    return LocalDataDeletionResult(
      succeeded: Set.unmodifiable(succeeded),
      failed: Set.unmodifiable(failed),
    );
  }

  Future<void> _run(
    LocalDataComponent component,
    Future<void> Function() operation,
    Set<LocalDataComponent> succeeded,
    Set<LocalDataComponent> failed,
  ) async {
    try {
      await operation();
      succeeded.add(component);
    } catch (_) {
      failed.add(component);
    }
  }
}

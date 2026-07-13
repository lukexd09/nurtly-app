import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/privacy/local_data_deletion.dart';

void main() {
  test('classifies complete deletion', () async {
    final result = await const LocalDataDeletionCoordinator().deleteAll(
      deleteJournal: () async {},
      deleteLanguage: () async {},
      deleteReviewerAccess: () async {},
    );

    expect(result.status, LocalDataDeletionStatus.complete);
    expect(result.failed, isEmpty);
    expect(result.succeeded, hasLength(3));
  });

  test('continues after a failure and classifies partial deletion', () async {
    final calls = <String>[];
    final result = await const LocalDataDeletionCoordinator().deleteAll(
      deleteJournal: () async {
        calls.add('journal');
      },
      deleteLanguage: () async {
        calls.add('language');
        throw StateError('language failed');
      },
      deleteReviewerAccess: () async {
        calls.add('reviewer');
      },
    );

    expect(calls, ['journal', 'language', 'reviewer']);
    expect(result.status, LocalDataDeletionStatus.partial);
    expect(result.succeeded, {
      LocalDataComponent.journal,
      LocalDataComponent.reviewerAccess,
    });
    expect(result.failed, {LocalDataComponent.language});
  });

  test('classifies complete failure', () async {
    final result = await const LocalDataDeletionCoordinator().deleteAll(
      deleteJournal: () async => throw StateError('journal failed'),
      deleteLanguage: () async => throw StateError('language failed'),
      deleteReviewerAccess: () async => throw StateError('reviewer failed'),
    );

    expect(result.status, LocalDataDeletionStatus.failed);
    expect(result.succeeded, isEmpty);
    expect(result.failed, hasLength(3));
  });

  test('repeated empty deletion remains complete', () async {
    final coordinator = const LocalDataDeletionCoordinator();
    final first = await coordinator.deleteAll(
      deleteJournal: () async {},
      deleteLanguage: () async {},
      deleteReviewerAccess: () async {},
    );
    final second = await coordinator.deleteAll(
      deleteJournal: () async {},
      deleteLanguage: () async {},
      deleteReviewerAccess: () async {},
    );

    expect(first.status, LocalDataDeletionStatus.complete);
    expect(second.status, LocalDataDeletionStatus.complete);
  });
}

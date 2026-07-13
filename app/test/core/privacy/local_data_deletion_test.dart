import 'package:flutter_test/flutter_test.dart';
import 'package:nurtly/core/localization/language_preference_store.dart';
import 'package:nurtly/core/monetization/reviewer_access_store.dart';
import 'package:nurtly/core/privacy/local_data_deletion.dart';
import 'package:nurtly/features/journal/journal_store.dart';

import '../../test_fakes/fake_shared_preferences_store_platform.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('false journal persistence prevents a complete deletion result',
      () async {
    final previous = SharedPreferencesStorePlatform.instance;
    final platform = FakeSharedPreferencesStorePlatform(
      falseOnRemoveKeys: {
        SharedPreferencesJournalStore.key,
        SharedPreferencesLanguagePreferenceStore.key,
        SharedPreferencesReviewerAccessStore.key,
      },
    );
    SharedPreferencesStorePlatform.instance = platform;
    addTearDown(() => SharedPreferencesStorePlatform.instance = previous);
    final coordinator = const LocalDataDeletionCoordinator();

    final result = await coordinator.deleteAll(
      deleteJournal: () async {
        final store = SharedPreferencesJournalStore();
        await store.deleteAllEntries();
      },
      deleteLanguage: () async {
        final store = SharedPreferencesLanguagePreferenceStore();
        await store.delete();
      },
      deleteReviewerAccess: () async {
        final store = SharedPreferencesReviewerAccessStore();
        await store.delete();
      },
    );

    expect(result.status, isNot(LocalDataDeletionStatus.complete));
    expect(result.failed, contains(LocalDataComponent.journal));
  });
}

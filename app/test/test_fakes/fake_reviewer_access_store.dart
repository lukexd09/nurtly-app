import 'dart:async';

import 'package:nurtly/core/monetization/reviewer_access_store.dart';

class FakeReviewerAccessStore implements ReviewerAccessStore {
  FakeReviewerAccessStore({
    this.saved = false,
    this.failOnLoad = false,
    this.failOnSave = false,
    this.failOnDelete = false,
    this.saveCompleter,
    this.deleteCompleter,
  });

  bool saved;
  final List<bool> savedValues = [];
  final bool failOnLoad;
  final bool failOnSave;
  final bool failOnDelete;
  final Completer<void>? saveCompleter;
  final Completer<void>? deleteCompleter;

  @override
  Future<bool> load() async {
    if (failOnLoad) {
      throw StateError('load failed');
    }
    return saved;
  }

  @override
  Future<void> save(bool enabled) async {
    if (failOnSave) {
      throw StateError('save failed');
    }
    await saveCompleter?.future;
    saved = enabled;
    savedValues.add(enabled);
  }

  @override
  Future<void> delete() async {
    if (failOnDelete) {
      throw StateError('delete failed');
    }
    await deleteCompleter?.future;
    saved = false;
  }
}

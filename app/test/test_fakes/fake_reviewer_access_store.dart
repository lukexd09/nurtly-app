import 'package:nurtly/core/localization/language_preference_store.dart';

class FakeReviewerAccessStore implements ReviewerAccessStore {
  FakeReviewerAccessStore({
    this.saved = false,
    this.failOnLoad = false,
    this.failOnSave = false,
    this.failOnDelete = false,
  });

  bool saved;
  final List<bool> savedValues = [];
  final bool failOnLoad;
  final bool failOnSave;
  final bool failOnDelete;

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
    saved = enabled;
    savedValues.add(enabled);
  }

  @override
  Future<void> delete() async {
    if (failOnDelete) {
      throw StateError('delete failed');
    }
    saved = false;
  }
}

import 'package:nurtly/core/localization/language_preference_store.dart';

class FakeReviewerAccessStore implements ReviewerAccessStore {
  FakeReviewerAccessStore({this.saved = false});

  bool saved;
  final List<bool> savedValues = [];

  @override
  Future<bool> load() async => saved;

  @override
  Future<void> save(bool enabled) async {
    saved = enabled;
    savedValues.add(enabled);
  }

  @override
  Future<void> delete() async {
    saved = false;
  }
}

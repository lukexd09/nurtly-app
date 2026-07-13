import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ReviewerAccessStore {
  Future<bool> load();

  Future<void> save(bool enabled);

  Future<void> delete();
}

class SharedPreferencesReviewerAccessStore implements ReviewerAccessStore {
  const SharedPreferencesReviewerAccessStore();

  static const String key = 'nurtly.reviewer_access_enabled';

  @override
  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  @override
  Future<void> save(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setBool(key, enabled);
    if (!success) {
      try {
        await prefs.reload();
      } catch (_) {
        throw StateError('reviewer access write failed');
      }
      throw StateError('reviewer access write failed');
    }
  }

  @override
  Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.remove(key);
    if (!success) {
      try {
        await prefs.reload();
      } catch (_) {
        throw StateError('reviewer access delete failed');
      }
      throw StateError('reviewer access delete failed');
    }
  }
}

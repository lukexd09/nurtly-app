import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

class FakeSharedPreferencesStorePlatform
    extends SharedPreferencesStorePlatform {
  static const String _legacyPrefix = 'flutter.';

  FakeSharedPreferencesStorePlatform({
    Map<String, Object>? initialValues,
    Set<String>? falseOnSetKeys,
    Set<String>? falseOnRemoveKeys,
  })  : _values = Map<String, Object>.from(initialValues ?? const {}),
        _falseOnSetKeys = falseOnSetKeys ?? const <String>{},
        _falseOnRemoveKeys = falseOnRemoveKeys ?? const <String>{};

  @override
  bool get isMock => true;

  final Map<String, Object> _values;
  final Set<String> _falseOnSetKeys;
  final Set<String> _falseOnRemoveKeys;

  @override
  Future<Map<String, Object>> getAll() async {
    return Map<String, Object>.from(_values);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (_shouldFailKey(key, _falseOnSetKeys)) {
      return false;
    }
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    if (_shouldFailKey(key, _falseOnRemoveKeys)) {
      return false;
    }
    _values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async {
    _values.clear();
    return true;
  }

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async {
    return Map<String, Object>.from(_values);
  }

  bool _shouldFailKey(String key, Set<String> failingKeys) {
    return failingKeys.contains(key) ||
        failingKeys.contains(key.startsWith(_legacyPrefix)
            ? key.substring(_legacyPrefix.length)
            : '$_legacyPrefix$key');
  }
}

import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

class FakeSharedPreferencesStorePlatform
    extends SharedPreferencesStorePlatform {
  FakeSharedPreferencesStorePlatform({
    Map<String, Object>? initialValues,
    Set<String>? falseOnSetKeys,
    Set<String>? falseOnRemoveKeys,
  })  : _values = <String, Object>{
          for (final entry
              in (initialValues ?? const <String, Object>{}).entries)
            _storageKey(entry.key): entry.value,
        },
        _falseOnSetKeys = Set<String>.from(falseOnSetKeys ?? const <String>{}),
        _falseOnRemoveKeys =
            Set<String>.from(falseOnRemoveKeys ?? const <String>{});

  @override
  bool get isMock => true;

  final Map<String, Object> _values;
  final Set<String> _falseOnSetKeys;
  final Set<String> _falseOnRemoveKeys;

  void disableSetFailure(String key) {
    _falseOnSetKeys.remove(_logicalKey(key));
  }

  void disableRemoveFailure(String key) {
    _falseOnRemoveKeys.remove(_logicalKey(key));
  }

  bool containsPersistedKey(String key) =>
      _values.containsKey(_storageKey(key));

  Object? persistedValue(String key) => _values[_storageKey(key)];

  @override
  Future<Map<String, Object>> getAll() async {
    return Map<String, Object>.from(_values);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (_falseOnSetKeys.contains(_logicalKey(key))) {
      return false;
    }
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    if (_falseOnRemoveKeys.contains(_logicalKey(key))) {
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

  static String _storageKey(String key) {
    return key.startsWith(_legacyPrefix) ? key : '$_legacyPrefix$key';
  }

  static String _logicalKey(String key) {
    return key.startsWith(_legacyPrefix)
        ? key.substring(_legacyPrefix.length)
        : key;
  }

  static const String _legacyPrefix = 'flutter.';
}

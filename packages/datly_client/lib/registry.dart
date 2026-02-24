import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api.dart';

enum RegistryValueState { loading, available, missing, unavailable }

/// Registry class with asynchronous fetching and caching of data.
///
/// Usage:
/// ```dart
/// class StuffRegistry extends _Registry<int, StuffData> {
///   StuffRegistry._() : super._();
///   static final StuffRegistry _instance = StuffRegistry._();
///   static StuffRegistry get instance => _instance;
///
///   @override
///   Uri _uriFromId(String identifier) =>
///       Uri.parse("${ApiManager.baseUri}/stuff/$identifier");
///
///   @override
///   StuffData _fromJson(json) => StuffData.fromJson(json);
/// }
/// ```
abstract class _Registry<I extends Object, D extends Object>
    extends ChangeNotifier {
  _Registry._();

  final Map<I, D?> _projects = {};
  final Map<I, Completer<void>> _activeFetches = {};

  Future<D?> get(I identifier, {bool noCache = false}) async {
    if (_projects.containsKey(identifier) && !noCache) {
      return _projects[identifier];
    }

    if (_activeFetches.containsKey(identifier)) {
      await _activeFetches[identifier]!.future;
      return _projects[identifier];
    }

    final completer = Completer<void>();
    _activeFetches[identifier] = completer;
    notifyListeners();

    void complete() {
      if (completer.isCompleted) return;
      completer.complete();
      _activeFetches.remove(identifier);
      notifyListeners();
    }

    try {
      final response = await AuthManager.instance.fetch(
        http.Request(_requestMethod, _uriFromId(identifier)),
      );

      final body = response?.body;
      if (response != null) {
        if (response.statusCode == 200 && body != null) {
          final entity = _fromJson(jsonDecode(body));
          _projects[identifier] = entity;
          complete();
          return entity;
        } else if (response.statusCode == 404) {
          _projects[identifier] = null;
          complete();
          return null;
        }
      }
    } catch (_) {}

    complete();
    return null;
  }

  void _notifyListeners(Function fn) {
    fn();
    notifyListeners();
  }

  void add(I identifier, D data) =>
      _notifyListeners(() => _projects[identifier] = data);
  void addAll(Map<I, D> data) => _notifyListeners(() => _projects.addAll(data));

  void invalidate(I identifier) =>
      _notifyListeners(() => _projects.remove(identifier));
  void invalidateAll() => _notifyListeners(() => _projects.clear());

  RegistryValueState state(I identifier) {
    if (_projects.containsKey(identifier)) {
      return _projects[identifier] != null
          ? RegistryValueState.available
          : RegistryValueState.missing;
    } else if (_activeFetches.containsKey(identifier)) {
      return RegistryValueState.loading;
    } else {
      return RegistryValueState.unavailable;
    }
  }

  String get _requestMethod => "GET";
  Uri _uriFromId(I identifier);
  D _fromJson(Map<String, dynamic> json);
}

class UserRegistry extends _Registry<String, UserData> {
  UserRegistry._() : super._();
  static final UserRegistry _instance = UserRegistry._();
  static UserRegistry get instance => _instance;

  @override
  Uri _uriFromId(String identifier) =>
      Uri.parse("${ApiManager.baseUri}/user/$identifier");

  @override
  UserData _fromJson(json) => UserData.fromJson(json);
}

class ProjectRegistry extends _Registry<int, ProjectData> {
  ProjectRegistry._() : super._();
  static final ProjectRegistry _instance = ProjectRegistry._();
  static ProjectRegistry get instance => _instance;

  @override
  Uri _uriFromId(int identifier) =>
      Uri.parse("${ApiManager.baseUri}/projects/$identifier");

  @override
  ProjectData _fromJson(json) => ProjectData.fromJson(json);
}

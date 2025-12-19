import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api.dart';

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
abstract class _Registry<I extends Object, D extends Object> {
  _Registry._();

  final Map<I, D> _projects = {};
  final Map<I, Completer<void>> _activeFetches = {};

  Future<D?> get(I identifier) async {
    if (_projects.containsKey(identifier)) {
      return _projects[identifier];
    }

    if (_activeFetches.containsKey(identifier)) {
      await _activeFetches[identifier]!.future;
      return _projects[identifier];
    }

    final completer = Completer<void>();
    _activeFetches[identifier] = completer;

    try {
      final response = await AuthManager.instance.fetch(
        http.Request(_requestMethod, _uriFromId(identifier)),
      );

      final body = response?.body;
      if (response != null && response.statusCode == 200 && body != null) {
        _projects[identifier] = _fromJson(jsonDecode(body));
        return _fromJson(jsonDecode(body));
      }
    } finally {
      completer.complete();
      _activeFetches.remove(identifier);
    }

    return null;
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
      Uri.parse("${ApiManager.baseUri}/users/$identifier");

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

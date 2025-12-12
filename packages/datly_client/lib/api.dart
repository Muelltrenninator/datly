import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class ApiManager {
  ApiManager._() {
    AuthManager.instance.initialize();
  }

  static final ApiManager _instance = ApiManager._();
  static ApiManager get instance => _instance;

  static Uri get baseUri =>
      kDebugMode ? Uri.parse("http://localhost:33552/api") : Uri.parse("/api");
}

class AuthManager extends ChangeNotifier {
  AuthManager._();
  static final AuthManager _instance = AuthManager._();
  static AuthManager get instance => _instance;

  Completer<void> initializeCompleter = Completer();
  Future<void> initialize() async {
    await _instance.fetchAuthenticatedUser();
    if (!initializeCompleter.isCompleted) initializeCompleter.complete();
  }

  UserData? _authenticatedUser;
  UserData? get authenticatedUser => _authenticatedUser;
  Future<void> fetchAuthenticatedUser({String? token}) async {
    if (authToken == null && token == null) {
      final valueBefore = _authenticatedUser;
      _authenticatedUser = null;
      if (valueBefore != null) notifyListeners();
      return;
    }

    final response = await fetch(
      http.Request(
        "GET",
        Uri.parse("${ApiManager.baseUri}/users/whoami"),
      ),
      token: token,
    );

    final body = response?.body;
    if (response != null && response.statusCode == 200 && body != null) {
      final valueBefore = _authenticatedUser;
      _authenticatedUser = UserData.fromJson(jsonDecode(body));
      if (authToken == null) prefs.setString("token", token!);
      if (valueBefore != _authenticatedUser) notifyListeners();
    }
  }

  String? get authToken => prefs.getString("token");
  final http.Client client = http.Client();

  Future<http.Response?> fetch(http.Request request, {String? token}) async {
    final effectiveToken = token ?? authToken;
    assert(
      effectiveToken != null,
      "The [AuthManager.fetch] must never be called when there is no auth token set.",
    );
    request.headers["Authorization"] = "Token $effectiveToken";

    http.Response? response;
    try {
      final streamedResponse = await client.send(request);
      response = await http.Response.fromStream(streamedResponse);
    } catch (_) {}

    if (response?.statusCode == 401) {
      final valueBefore = _authenticatedUser;
      _authenticatedUser = null;
      prefs.remove("token");
      if (valueBefore != null) notifyListeners();
      return null;
    }

    return response;
  }
}

class UserData {
  String username;
  String email;
  DateTime joinedAt;
  List<int> projects;
  String role;

  UserData({
    required this.username,
    required this.email,
    required this.joinedAt,
    required this.projects,
    required this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    username: json["username"]!,
    email: json["email"]!,
    joinedAt: DateTime.fromMillisecondsSinceEpoch(json["joinedAt"]),
    projects: List<int>.from(json["projects"]),
    role: json["role"]!,
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "email": email,
    "joinedAt": joinedAt.millisecondsSinceEpoch,
    "projects": projects,
    "role": role,
  };

  UserData copyWith({
    String? username,
    String? email,
    DateTime? joinedAt,
    List<int>? projects,
    String? role,
  }) {
    return UserData(
      username: username ?? this.username,
      email: email ?? this.email,
      joinedAt: joinedAt ?? this.joinedAt,
      projects: projects ?? this.projects,
      role: role ?? this.role,
    );
  }
}

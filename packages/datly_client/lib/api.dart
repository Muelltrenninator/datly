import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import 'main.dart';
import 'registry.dart';
import 'widgets/title_bar.dart';

class ApiManager {
  ApiManager._();
  static final ApiManager _instance = ApiManager._();
  static ApiManager get instance => _instance;

  static Uri get baseUri =>
      kDebugMode ? Uri.parse("http://localhost:33552/api") : Uri.parse("/api");
}

class AuthManager extends ChangeNotifier {
  AuthManager._();
  static final AuthManager _instance = AuthManager._();
  static AuthManager get instance => _instance;

  Future<void> initialize() async {
    await _instance.fetchAuthenticatedUser();
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
      http.Request("GET", Uri.parse("${ApiManager.baseUri}/users/whoami")),
      token: token,
    );

    final body = response?.body;
    if (response != null && response.statusCode == 200 && body != null) {
      final valueBefore = _authenticatedUser;
      _authenticatedUser = UserData.fromJson(jsonDecode(body));
      UserRegistry.instance.add(
        _authenticatedUser!.username,
        _authenticatedUser!,
      );
      if (authToken == null) prefs.setString("token", token!);
      if (valueBefore != _authenticatedUser) notifyListeners();
    }
  }

  Future<void> logout() async {
    _authenticatedUser = null;
    prefs.remove("token");
    notifyListeners();
  }

  bool get authenticatedUserIsAdmin =>
      authenticatedUser != null && authenticatedUser!.isAdmin();

  String? get authToken => prefs.getString("token");
  final http.Client client = http.Client();

  Future<http.Response?> fetch(
    http.BaseRequest request, {
    String? token,
  }) async {
    request = fetchPrepare(request, token: token);

    http.Response? response;
    try {
      final streamedResponse = await client
          .send(request)
          .timeout(Duration(seconds: 15));
      response = await http.Response.fromStream(streamedResponse).onError(
        (error, stackTrace) => Error.throwWithStackTrace(error!, stackTrace),
      );
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

  http.BaseRequest fetchPrepare(http.BaseRequest request, {String? token}) {
    final effectiveToken = token ?? authToken;
    assert(
      effectiveToken != null,
      "[AuthManager.fetchPrepare] must never be called with no auth token set.",
    );
    return request..headers["Authorization"] = "Token $effectiveToken";
  }
}

// MARK: Data Classes

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

  bool isAdmin() => role == "admin";
  Color? roleColor() => switch (role) {
    "admin" => Colors.red[900]!,
    _ => null,
  };
  CircleAvatar avatar(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: HSVColor.fromAHSV(
        1.0,
        (username.hashCode % 360).toDouble(),
        0.75 + (((username.hashCode >> 3) % 25) / 100.0),
        0.85 + (((username.hashCode >> 7) % 15) / 100.0),
      ).toColor(),
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      brightness: Theme.brightnessOf(context),
    );
    return CircleAvatar(
      backgroundColor: colorScheme.secondaryContainer,
      child: Text(
        initialsFromUsername(username),
        style: TextStyle(color: colorScheme.onSecondaryContainer),
      ),
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    username: json["username"]!,
    email: json["email"]!,
    joinedAt: DateTime.fromMillisecondsSinceEpoch(
      json["joinedAt"],
      isUtc: true,
    ),
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
}

class SubmissionData {
  int id;
  int projectId;
  String user;
  String status;
  DateTime submittedAt;
  String? assetId;
  String? assetMimeType;
  String assetBlurHash;

  SubmissionData({
    required this.id,
    required this.projectId,
    required this.user,
    required this.status,
    required this.submittedAt,
    required this.assetId,
    required this.assetMimeType,
    required this.assetBlurHash,
  });

  Color statusColor() => switch (status) {
    "accepted" => Colors.green,
    "rejected" => Colors.redAccent,
    "censored" => Colors.blueAccent,
    _ => Colors.grey,
  };
  Uri? assetUri() => assetId != null && assetMimeType != null
      ? Uri.parse(
          "${ApiManager.baseUri}/assets/${assetId!}.${extensionFromMime(assetMimeType!)}",
        )
      : null;

  factory SubmissionData.fromJson(Map<String, dynamic> json) => SubmissionData(
    id: json["id"]!,
    projectId: json["projectId"]!,
    user: json["user"]!,
    status: json["status"]!,
    submittedAt: DateTime.fromMillisecondsSinceEpoch(
      json["submittedAt"],
      isUtc: true,
    ),
    assetId: json["assetId"],
    assetMimeType: json["assetMimeType"],
    assetBlurHash: json["assetBlurHash"]!,
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "projectId": projectId,
    "user": user,
    "status": status,
    "submittedAt": submittedAt.millisecondsSinceEpoch,
    "assetId": assetId,
    "assetMimeType": assetMimeType,
    "assetBlurHash": assetBlurHash,
  };
}

class ProjectData {
  int id;
  String title;
  String? description;
  DateTime createdAt;

  ProjectData({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) => ProjectData(
    id: json["id"]!,
    title: json["title"]!,
    description: json["description"],
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      json["createdAt"],
      isUtc: true,
    ),
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "createdAt": createdAt.millisecondsSinceEpoch,
  };
}

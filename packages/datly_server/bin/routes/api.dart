import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_limiter/shelf_limiter.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/database.dart';
import '../server.dart';
import 'api_assets.dart' as api_assets;
import 'api_projects.dart' as api_projects;
import 'api_users.dart' as api_user;

final apiRouter = Router(
  notFoundHandler: (request) => Response.notFound(
    jsonEncode({"error": "Unknown endpoint"}),
    headers: {"Content-Type": "application/json"},
  ),
);
Handler get apiPipeline => Pipeline()
    .addMiddleware(
      shelfLimiter(
        RateLimiterOptions(
          maxRequests: 20,
          windowSize: Duration(seconds: 20),
          onRateLimitExceeded: (r) => Response(
            429,
            body: jsonEncode({
              "error": "Too many requests, please try again later.",
            }),
            headers: {"Content-Type": "application/json"},
          ),
        ),
      ),
    )
    .addHandler(apiRouter.call);

void defineApiRouter() {
  api_assets.define(apiRouter);
  api_projects.define(apiRouter);
  api_user.define(apiRouter);
}

// MARK: Authentication

Future<Object?> _apiAuthInternal(
  Request req, {
  UserRole minimumRole = UserRole.user,
}) async {
  var token = req.headers["authorization"];
  if ((!(token?.startsWith("Token ") ?? false) || token!.length != (6 + 8))) {
    if (minimumRole == UserRole.guest) {
      return null;
    }
    return Response.unauthorized(
      jsonEncode({"error": "Invalid or missing authorization token"}),
      headers: {"Content-Type": "application/json"},
    );
  }
  token = token.substring(6);

  final code =
      await (db.select(db.loginCodes)..where(
            (lc) =>
                lc.code.equals(token!.toUpperCase()) &
                lc.expiresAt.isBiggerThan(currentDateAndTime),
          ))
          .getSingleOrNull();
  if (code == null) {
    return Response.unauthorized(
      jsonEncode({"error": "Unknown authorization token"}),
      headers: {"Content-Type": "application/json"},
    );
  }

  final user = await (db.select(
    db.users,
  )..where((u) => u.username.equals(code.user))).getSingle();
  if (user.role.index < minimumRole.index) {
    return Response.unauthorized(
      jsonEncode({"error": "Insufficient permissions"}),
      headers: {"Content-Type": "application/json"},
    );
  }

  return (code: code, user: user);
}

Future<Response?> apiAuth(
  Request req, {
  UserRole minimumRole = UserRole.user,
}) async {
  final result = await _apiAuthInternal(req, minimumRole: minimumRole);
  if (result is Response) return result;
  return null;
}

Future<Response> Function(Request req) apiAuthWall(
  Function(Request req, ({LoginCode code, User user})? auth) handler, {
  UserRole minimumRole = UserRole.user,
}) => (Request req) async {
  final result = await _apiAuthInternal(req, minimumRole: minimumRole);
  if (result is Response) return result;
  return handler.call(req, result as ({LoginCode code, User user})?);
};

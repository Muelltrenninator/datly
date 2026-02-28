import 'dart:async';
import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_limiter/shelf_limiter.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/database.dart';
import '../helpers.dart';
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
    .addMiddleware((innerHandler) {
      final limiter = shelfLimiter(
        RateLimiterOptions(
          maxRequests: 5,
          windowSize: Duration(seconds: 10),
          clientIdentifierExtractor: (request) =>
              identifierFromRequest(request)!,
          onRateLimitExceeded: (request) {
            t.warn(
              "Rate limit exceeded for: ${identifierFromRequest(request)} (unauthenticated)",
            );
            return Response(
              429,
              body: jsonEncode({
                "error": "Too many requests, please try again later",
              }),
              headers: {"Content-Type": "application/json"},
            );
          },
        ),
      );
      return (request) async {
        if (identifierFromRequest(request) == null) {
          return Response(
            400,
            body: jsonEncode({
              "error": "Cannot identify client for rate limiting",
            }),
            headers: {"Content-Type": "application/json"},
          );
        }

        final response = await innerHandler(request);
        if (response.statusCode == 401) {
          return limiter.call((_) => response).call(request);
        } else {
          return response;
        }
      };
    })
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
  if ((!(token?.startsWith("Bearer ") ?? false) || token!.length <= 7)) {
    if (minimumRole.index == UserRole.external.index) return null;
    return Response.unauthorized(
      jsonEncode({"error": "Invalid or missing authorization header"}),
      headers: {"Content-Type": "application/json"},
    );
  }
  token = token.substring(7);

  JWT jwt;
  try {
    jwt = JWT.verify(
      token,
      jwtPublicKey,
      issuer: jwtIssuer(req),
      audience: Audience.one("auth"),
    );
    if (jwt.subject == null) throw JWTException("");
  } on JWTExpiredException catch (_) {
    return Response.unauthorized(
      jsonEncode({"error": "Authorization token expired"}),
      headers: {"Content-Type": "application/json"},
    );
  } on JWTException catch (_) {
    return Response.unauthorized(
      jsonEncode({"error": "Invalid authorization token"}),
      headers: {"Content-Type": "application/json"},
    );
  }

  final user = await (db.select(
    db.users,
  )..where((u) => u.username.equals(jwt.subject!))).getSingleOrNull();
  if (user == null) {
    return Response.unauthorized(
      jsonEncode({"error": "User not found, outdated token"}),
      headers: {"Content-Type": "application/json"},
    );
  }

  if (user.disabled != null) {
    return Response.forbidden(
      jsonEncode({"error": "User account is disabled"}),
      headers: {"Content-Type": "application/json"},
    );
  }

  bool firstTimeLogin = false;
  if (!user.activated) {
    firstTimeLogin = true;
    await (db.users.update()..where((u) => u.username.equals(user.username)))
        .write(UsersCompanion(activated: Value(true)));
  }

  final locale = localeFromRequest(req);
  if (locale != null && user.locale != locale) {
    await (db.users.update()..where((u) => u.username.equals(user.username)))
        .write(UsersCompanion(locale: Value(locale)));
  }

  if (user.role.index < minimumRole.index) {
    return Response.forbidden(
      jsonEncode({"error": "Insufficient permissions"}),
      headers: {"Content-Type": "application/json"},
    );
  }

  return (user: user, firstTimeLogin: firstTimeLogin);
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
  Function(Request req, ({User user, bool firstTimeLogin})? auth) handler, {
  UserRole minimumRole = UserRole.user,
}) => (Request req) async {
  final result = await _apiAuthInternal(req, minimumRole: minimumRole);
  if (result is Response) return result;
  return handler.call(req, result as ({User user, bool firstTimeLogin})?);
};

import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/database.dart';
import '../helpers.dart';
import '../server.dart';
import 'api.dart';

void define(Router router) {
  router
    ..get(
      "/users/whoami",
      apiAuthWall((req, auth) {
        if (auth == null) {
          return Response.ok(
            jsonEncode({}),
            headers: {"Content-Type": "application/json"},
          );
        }
        return Response.ok(
          jsonEncode(auth.user.toJson()..addAll({"code": auth.code.toJson()})),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.guest),
    )
    ..get(
      "/users/list",
      apiAuthWall((req, auth) async {
        final users = await db.select(db.users).get();
        return Response.ok(
          users.map((u) => u.toJson()).toList(),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/users/<username>",
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        if (auth!.user.role.index < UserRole.admin.index) {
          return Response.ok(
            jsonEncode({
              "username": user.username,
              "joinedAt": user.joinedAt.millisecondsSinceEpoch,
            }),
            headers: {"Content-Type": "application/json"},
          );
        } else {
          return Response.ok(
            user.toJsonString(),
            headers: {"Content-Type": "application/json"},
          );
        }
      }),
    )
    ..put(
      "/users/<username>",
      apiAuthWall((req, _) async {
        final username = req.params["username"]!;
        final user = await (db.select(
          db.users,
        )..where((u) => u.username.equals(username))).getSingleOrNull();
        if (user != null) {
          return Response.notFound(
            jsonEncode({"error": "Username already taken"}),
          );
        }

        if (jsonDecode(await req.readAsString()) case {
          "email": String email,
          "projects": List<int> projects,
          "role": String role,
        }) {
          final createdUser = UsersCompanion.insert(
            username: username,
            email: email,
            projects: projects.isNotEmpty ? Value(projects) : Value.absent(),
            role: Value(UserRole.values.byName(role)),
          );

          await db.into(db.users).insert(createdUser);
          return Response(201);
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid user data"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.admin),
    )
    ..post(
      "/users/<username>",
      apiAuthWall((req, _) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        if (jsonDecode(await req.readAsString()) case {
          "email": String? email,
          "projects": List<int>? projects,
          "role": String? role,
        }) {
          if (role != null &&
              !UserRole.values.asNameMap().keys.contains(role)) {
            return Response.badRequest(
              body: jsonEncode({"error": "Invalid user role"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          final updatedUser = UsersCompanion(
            email: email != null ? Value(email) : Value.absent(),
            projects: projects != null ? Value(projects) : Value.absent(),
            role: role != null
                ? Value(UserRole.values.byName(role))
                : Value.absent(),
          );

          await (db.update(
            db.users,
          )..where((u) => u.username.equals(user.username))).write(updatedUser);
          return Response.ok(null);
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid user data"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.admin),
    )
    ..delete(
      "/users/<username>",
      apiAuthWall((req, _) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        await (db.delete(
          db.users,
        )..where((u) => u.username.equals(user.username))).go();
        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/users/<username>/loginCode",
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        final codes = await (db.select(
          db.loginCodes,
        )..where((lc) => lc.user.equals(user.username))).get();

        return Response.ok(
          jsonEncode(codes.map((c) => c.toJson()).toList()),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..put(
      "/users/<username>/loginCode",
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        final code = generateCode();
        await db
            .into(db.loginCodes)
            .insert(
              LoginCodesCompanion.insert(
                code: code,
                user: user.username,
                createdBy: Value(auth!.user.username),
              ),
            );

        return Response.ok(
          jsonEncode({"code": code}),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..post(
      "/users/<username>/loginCode/renew",
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }
        final code =
            await (db.select(db.loginCodes)..where(
                  (c) => c.code.equals(req.url.queryParameters["code"] ?? ""),
                ))
                .getSingleOrNull();
        if (code == null) {
          return Response.badRequest(
            body: jsonEncode({"error": "Code not found"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        final newExpiresAt = code.expiresAt.add(Duration(days: 180));
        await (db.update(db.loginCodes)
              ..where((lc) => lc.code.equals(code.code)))
            .write(LoginCodesCompanion(expiresAt: Value(newExpiresAt)));

        return Response.ok(null, headers: {"Content-Type": "application/json"});
      }, minimumRole: UserRole.admin),
    )
    ..delete(
      "/users/<username>/loginCode",
      apiAuthWall((req, _) async {
        final code =
            await (db.select(db.loginCodes)..where(
                  (u) =>
                      u.user.equals(req.params["username"]!) &
                      u.code.equals(req.url.queryParameters["code"]!),
                ))
                .getSingleOrNull();
        if (code == null) {
          return Response.notFound(jsonEncode({"error": "Code not found"}));
        }

        await (db.delete(
          db.loginCodes,
        )..where((lc) => lc.code.equals(code.code))).go();

        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    )
    ..delete(
      "/users/<username>/loginCode/purge",
      apiAuthWall((req, _) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        } else if (user.role.index >= UserRole.admin.index) {
          return Response.badRequest(
            body: jsonEncode({
              "error":
                  "Cannot purge admin login codes, delete them individually",
            }),
            headers: {"Content-Type": "application/json"},
          );
        }

        await (db.delete(
          db.loginCodes,
        )..where((lc) => lc.user.equals(user.username))).go();

        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/users/<username>/submissions",
      apiAuthWall((req, _) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        final submissions = await (db.select(
          db.submissions,
        )..where((s) => s.user.equals(user.username))).get();

        return Response.ok(
          jsonEncode(submissions.map((s) => s.toJson()).toList()),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/users/<username>/submissions/live",
      apiAuthWall((req, _) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        final submissions = (db.select(
          db.submissions,
        )..where((s) => s.user.equals(user.username))).watch();

        return Response.ok(
          submissions.map(
            (data) => utf8.encode(
              "${jsonEncode(data.map((s) => s.toJson()).toList())}\n",
            ),
          ),
          headers: {"Content-Type": "application/jsonl; charset=utf-8"},
          context: {"shelf.io.buffer_output": false},
        );
      }, minimumRole: UserRole.admin),
    );
}

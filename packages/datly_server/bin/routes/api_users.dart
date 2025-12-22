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
      "/users/whoami", // MARK: [GET] /users/whoami
      apiAuthWall((req, auth) {
        return Response.ok(
          jsonEncode(auth!.user.toJson()..addAll({"code": auth.code.toJson()})),
          headers: {"Content-Type": "application/json"},
        );
      }),
    )
    ..get(
      "/users/list", // MARK: [GET] /users/list
      apiAuthWall((req, auth) async {
        final users = await db.select(db.users).get();
        return Response.ok(
          jsonEncode(users.map((u) => u.toJson()).toList()),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/users/<username>", // MARK: [GET] /users/<username>
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        if (auth!.user.role.index < UserRole.admin.index &&
            auth.user.username != user.username) {
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
    ..post(
      "/users/<username>", // MARK: [POST] /users/<username>
      apiAuthWall((req, _) async {
        final username = req.params["username"]!;
        if (!RegExp(r"^[a-zA-Z0-9_]{3,16}$").hasMatch(username)) {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid username"}),
            headers: {"Content-Type": "application/json"},
          );
        }

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
          "projects": List<dynamic> projects,
          "role": String role,
        }) {
          List<int> parsedProjects;
          try {
            parsedProjects = projects.map((e) => e as int).toList();
            for (var projectId in parsedProjects) {
              final project = await (db.select(
                db.projects,
              )..where((p) => p.id.equals(projectId))).getSingleOrNull();
              if (project == null) {
                return Response.badRequest(
                  body: jsonEncode({"error": "Project $projectId not found"}),
                  headers: {"Content-Type": "application/json"},
                );
              }
            }
          } catch (e) {
            return Response.badRequest(
              body: jsonEncode({"error": "Invalid projects list"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          if (!UserRole.values.asNameMap().keys.contains(role)) {
            return Response.badRequest(
              body: jsonEncode({"error": "Invalid user role"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          final createdUser = UsersCompanion.insert(
            username: username,
            email: email,
            projects: projects.isNotEmpty
                ? Value(parsedProjects)
                : Value.absent(),
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
    ..put(
      "/users/<username>", // MARK: [PUT] /users/<username>
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
          "projects": List<dynamic>? projects,
          "role": String? role,
        }) {
          List<int>? parsedProjects;
          if (projects != null) {
            try {
              parsedProjects = projects.map((e) => e as int).toList();
              for (var projectId in parsedProjects) {
                final project = await (db.select(
                  db.projects,
                )..where((p) => p.id.equals(projectId))).getSingleOrNull();
                if (project == null) {
                  return Response.badRequest(
                    body: jsonEncode({"error": "Project $projectId not found"}),
                    headers: {"Content-Type": "application/json"},
                  );
                }
              }
            } catch (e) {
              return Response.badRequest(
                body: jsonEncode({"error": "Invalid projects list"}),
                headers: {"Content-Type": "application/json"},
              );
            }
          }

          if (role != null &&
              !UserRole.values.asNameMap().keys.contains(role)) {
            return Response.badRequest(
              body: jsonEncode({"error": "Invalid user role"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          final updatedUser = UsersCompanion(
            email: email != null ? Value(email) : Value.absent(),
            projects: parsedProjects != null
                ? Value(parsedProjects)
                : Value.absent(),
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
      "/users/<username>", // MARK: [DELETE] /users/<username>
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        if (user.username == auth!.user.username) {
          return Response.badRequest(
            body: jsonEncode({"error": "Cannot delete own user account"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        await (db.delete(
          db.users,
        )..where((u) => u.username.equals(user.username))).go();
        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/users/<username>/loginCode", // MARK: [GET] /users/<username>/loginCode
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
    ..post(
      "/users/<username>/loginCode", // MARK: [POST] /users/<username>/loginCode
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
      "/users/<username>/loginCode/renew", // MARK: [POST] /users/<username>/loginCode/renew
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
      "/users/<username>/loginCode", // MARK: [DELETE] /users/<username>/loginCode
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
      "/users/<username>/loginCode/purge", // MARK: [DELETE] /users/<username>/loginCode/purge
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        await (db.delete(db.loginCodes)..where(
              (lc) =>
                  lc.user.equals(user.username) &
                  lc.code.equals(auth!.code.code).not(),
            ))
            .go();

        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/users/<username>/submissions", // MARK: [GET] /users/<username>/submissions
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        if (auth!.user.role.index < UserRole.admin.index &&
            auth.user.username != user.username) {
          return Response.forbidden(
            jsonEncode({"error": "Insufficient permissions"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        final submissions =
            await (db.select(db.submissions)
                  ..where((s) => s.user.equals(user.username))
                  ..orderBy([
                    (s) => OrderingTerm.desc(s.submittedAt),
                    (s) => OrderingTerm.desc(s.id),
                  ]))
                .get();

        return Response.ok(
          jsonEncode(submissions.map((s) => s.toJson()).toList()),
          headers: {"Content-Type": "application/json"},
        );
      }),
    )
    ..get(
      "/users/<username>/submissions/live", // MARK: [GET] /users/<username>/submissions/live
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(jsonEncode({"error": "User not found"}));
        }

        if (auth!.user.role.index < UserRole.admin.index &&
            auth.user.username != user.username) {
          return Response.forbidden(
            jsonEncode({"error": "Insufficient permissions"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        final submissions =
            (db.select(db.submissions)
                  ..where((s) => s.user.equals(user.username))
                  ..orderBy([
                    (s) => OrderingTerm.desc(s.submittedAt),
                    (s) => OrderingTerm.desc(s.id),
                  ]))
                .watch();

        return Response.ok(
          submissions.map(
            (data) => utf8.encode(
              "${jsonEncode(data.map((s) => s.toJson()).toList())}\n",
            ),
          ),
          headers: {"Content-Type": "application/jsonl; charset=utf-8"},
          context: {"shelf.io.buffer_output": false},
        );
      }),
    );
}

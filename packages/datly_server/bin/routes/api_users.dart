import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/database.dart';
import '../email/email.dart';
import '../helpers.dart';
import '../server.dart';
import 'api.dart';

void define(Router router) {
  router
    ..get(
      "/users/whoami", // MARK: [GET] /users/whoami
      apiAuthWall((req, auth) async {
        final count = db.submissions.id.count();
        final submissionCount =
            (await (db.selectOnly(db.submissions)
                      ..addColumns([count])
                      ..where(db.submissions.user.equals(auth!.user.username)))
                    .get())
                .first
                .read(count) ??
            0;

        return Response.ok(
          jsonEncode(
            auth.user.toJson()
              ..remove("password")
              ..addAll({"submissionCount": submissionCount}),
          ),
          headers: {"Content-Type": "application/json"},
        );
      }),
    )
    ..get(
      "/users/list", // MARK: [GET] /users/list
      apiAuthWall((req, auth) async {
        final users = await db.select(db.users).get();

        final count = db.submissions.id.count();
        final submissionCounts = Map.fromEntries(
          (await ((db.selectOnly(db.submissions)
                    ..addColumns([db.submissions.user, count])
                    ..groupBy([db.submissions.user]))
                  .get()))
              .map(
                (row) => MapEntry(
                  row.read(db.submissions.user)!,
                  row.read(count) ?? 0,
                ),
              ),
        );

        return Response.ok(
          jsonEncode(
            users
                .map(
                  (u) => u.toJson()
                    ..remove("password")
                    ..addAll({
                      "submissionCount": submissionCounts[u.username] ?? 0,
                    }),
                )
                .toList(),
          ),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..post(
      "/users/login", // MARK: [POST] /users/login
      apiAuthWall((req, auth) async {
        if (auth != null) {
          return Response.ok(
            jsonEncode({"message": "Already logged in"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        if (jsonDecode(await req.readAsString()) case {
          "email": String email,
          "password": String password,
        }) {
          if (email.isEmpty || password.isEmpty) {
            return Response.badRequest(
              body: jsonEncode({
                "error":
                    "${email.isEmpty ? "Email" : "Password"} cannot be empty",
              }),
              headers: {"Content-Type": "application/json"},
            );
          } else if (emailRegex.hasMatch(email) == false) {
            return Response.badRequest(
              body: jsonEncode({"error": "Invalid email address"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          final user = await (db.select(
            db.users,
          )..where((u) => u.email.equals(email))).getSingleOrNull();
          if (user == null ||
              !(await verifyPassword(password, user.password))) {
            return Response.unauthorized(
              jsonEncode({"error": "Unknown email or password"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          if (user.disabled != null) {
            return Response.forbidden(
              jsonEncode({"error": "User account is disabled"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          return Response.ok(
            jsonEncode({
              "token":
                  JWT(
                    {},
                    issuer: jwtIssuer(req),
                    audience: Audience.one("auth"),
                    subject: user.username,
                  ).sign(
                    jwtPrivateKey,
                    algorithm: JWTAlgorithm.RS256,
                    expiresIn: Duration(days: 180),
                  ),
            }),
            headers: {"Content-Type": "application/json"},
          );
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Username and password required"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.external),
    )
    ..get(
      "/user/<username>", // MARK: [GET] /user/<username>
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        final count = db.submissions.id.count();
        final submissionCount =
            (await (db.selectOnly(db.submissions)
                      ..addColumns([count])
                      ..where(db.submissions.user.equals(user.username)))
                    .get())
                .first
                .read(count) ??
            0;

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
            jsonEncode(
              user.toJson()
                ..remove("password")
                ..addAll({"submissionCount": submissionCount}),
            ),
            headers: {"Content-Type": "application/json"},
          );
        }
      }),
    )
    ..post(
      "/user/<username>", // MARK: [POST] /user/<username>
      apiAuthWall((req, auth) async {
        final isAdmin =
            (auth?.user.role ?? UserRole.user).index >= UserRole.admin.index;
        if (auth != null && !isAdmin) {
          return Response.forbidden(
            jsonEncode({"error": "Insufficient permissions"}),
            headers: {"Content-Type": "application/json"},
          );
        }

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
          return Response(
            409,
            body: jsonEncode({"error": "Username already taken"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        if (jsonDecode(await req.readAsString()) case {
          "email": String email,
          "projects": List<dynamic>? projects,
          "role": String? role,
          "locale": String? locale,
        }) {
          final password = await generatePlaintextPassword();

          final emailCheck = emailRegex.hasMatch(email);
          if (!emailCheck) {
            return Response.badRequest(
              body: jsonEncode({"error": "Invalid email address"}),
              headers: {"Content-Type": "application/json"},
            );
          }
          if (await (db.select(
                db.users,
              )..where((u) => u.email.equals(email))).getSingleOrNull() !=
              null) {
            return Response(
              409,
              body: jsonEncode({"error": "Email already linked"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          List<int> parsedProjects;
          if (isAdmin && projects != null) {
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
          } else {
            parsedProjects = [1];
          }

          UserRole effectiveRole;
          if (isAdmin && role != null) {
            if (UserRole.values.asNameMap().keys.contains(role)) {
              effectiveRole = UserRole.values.byName(role);
            } else {
              return Response.badRequest(
                body: jsonEncode({"error": "Invalid user role"}),
                headers: {"Content-Type": "application/json"},
              );
            }
          } else {
            effectiveRole = UserRole.user;
          }

          String effectiveLocale;
          if (locale != null) {
            effectiveLocale = locale;
          } else {
            effectiveLocale = localeFromRequest(req) ?? "en";
          }

          final createdUser = UsersCompanion.insert(
            username: username,
            password: await hashPassword(password: password),
            email: email,
            projects: parsedProjects.isNotEmpty
                ? Value(parsedProjects)
                : Value.absent(),
            role: Value(effectiveRole),
            locale: Value(effectiveLocale),
          );
          await db.into(db.users).insert(createdUser);

          final user = await (db.select(
            db.users,
          )..where((u) => u.username.equals(username))).getSingle();
          queueEmail(
            (isAdmin
                    ? EmailMessagesTemplates.passwordResetWelcome
                    : EmailMessagesTemplates.welcome)(
                  user: user,
                  newPassword: password,
                )
                .stylized(),
          );

          return Response(201);
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid user data"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.external),
    )
    ..put(
      "/user/<username>", // MARK: [PUT] /user/<username>
      apiAuthWall((req, _) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        if (jsonDecode(await req.readAsString()) case {
          "password": String? password,
          "email": String? email,
          "projects": List<dynamic>? projects,
          "role": String? role,
        }) {
          if (password != null) {
            final passwordCheck = await isSecurePassword(password);
            if (!passwordCheck.secure) {
              return Response.badRequest(
                body: jsonEncode({
                  "error": "Insecure password",
                  "code": passwordCheck.code,
                  "message": passwordCheck.message,
                }),
                headers: {"Content-Type": "application/json"},
              );
            }
          }

          if (email != null) {
            final emailCheck = emailRegex.hasMatch(email);
            if (!emailCheck) {
              return Response.badRequest(
                body: jsonEncode({"error": "Invalid email address"}),
                headers: {"Content-Type": "application/json"},
              );
            }
            if (await (db.select(
                  db.users,
                )..where((u) => u.email.equals(email))).getSingleOrNull() !=
                null) {
              return Response(
                409,
                body: jsonEncode({"error": "Email already linked"}),
                headers: {"Content-Type": "application/json"},
              );
            }
          }

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
            password: password != null
                ? Value(await hashPassword(password: password))
                : Value.absent(),
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
      "/user/<username>", // MARK: [DELETE] /user/<username>
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {"Content-Type": "application/json"},
          );
        } else if (user.username == auth!.user.username) {
          return Response(
            409,
            body: jsonEncode({"error": "Cannot delete own user account"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        await (db.delete(
          db.users,
        )..where((u) => u.username.equals(user.username))).go();
        await (db.update(
          db.signatures,
        )..where((s) => s.user.equals(user.username))).write(
          SignaturesCompanion(
            revokedAt: Value(DateTime.now()),
            revokedReason: Value("User deleted by '${auth.user.username}'"),
          ),
        );

        queueEmail(
          EmailMessagesTemplates.accountDeleted(user: user).stylized(),
        );

        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    )
    ..post(
      "/user/<username>/disable", // MARK: [POST] /user/<username>/disable
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {"Content-Type": "application/json"},
          );
        } else if (user.disabled != null) {
          return Response(
            409,
            body: jsonEncode({"error": "User account already disabled"}),
            headers: {"Content-Type": "application/json"},
          );
        } else if (user.username == auth!.user.username) {
          return Response(
            409,
            body: jsonEncode({"error": "Cannot disable own user account"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        if (jsonDecode(await req.readAsString()) case {
          "reason": String? reason,
        }) {
          await (db.update(db.users)
                ..where((u) => u.username.equals(user.username)))
              .write(UsersCompanion(disabled: Value(reason?.trim() ?? "")));
          queueEmail(
            EmailMessagesTemplates.accountDisabled(
              user: user,
              reason: reason?.trim() ?? "",
            ).stylized(),
          );

          return Response.ok(null);
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid request body"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.admin),
    )
    ..post(
      "/user/<username>/reenable", // MARK: [POST] /user/<username>/reenable
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {"Content-Type": "application/json"},
          );
        } else if (user.disabled == null) {
          return Response(
            409,
            body: jsonEncode({"error": "User account is not disabled"}),
            headers: {"Content-Type": "application/json"},
          );
        } else if (user.username == auth!.user.username) {
          return Response(
            409,
            body: jsonEncode({"error": "Cannot reenable own user account"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        await (db.update(db.users)
              ..where((u) => u.username.equals(user.username)))
            .write(UsersCompanion(disabled: Value(null)));
        queueEmail(
          EmailMessagesTemplates.accountReenabled(user: user).stylized(),
        );

        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    )
    ..post(
      "/user/<username>/passwordReset", // MARK: [POST] /user/<username>/passwordReset
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        final password = await generatePlaintextPassword();
        db.update(db.users)
          ..where((u) => u.username.equals(user.username))
          ..write(
            UsersCompanion(
              password: Value(await hashPassword(password: password)),
            ),
          );

        queueEmail(
          EmailMessagesTemplates.passwordResetTemporary(
            user: user,
            newPassword: password,
          ).stylized(),
        );

        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/user/<username>/submissions", // MARK: [GET] /user/<username>/submissions
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {"Content-Type": "application/json"},
          );
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
      "/user/<username>/submissions/live", // MARK: [GET] /user/<username>/submissions/live
      apiAuthWall((req, auth) async {
        final user =
            await (db.select(db.users)
                  ..where((u) => u.username.equals(req.params["username"]!)))
                .getSingleOrNull();
        if (user == null) {
          return Response.notFound(
            jsonEncode({"error": "User not found"}),
            headers: {"Content-Type": "application/json"},
          );
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

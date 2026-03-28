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
      "/categories/list", // MARK: [GET] /categories/list
      apiAuthWall((req, auth) async {
        final categories = await db.select(db.categories).get();

        final count = db.submissions.id.count();
        final submissionCounts = Map.fromEntries(
          (await ((db.selectOnly(db.submissions)
                    ..addColumns([db.submissions.category, count])
                    ..groupBy([db.submissions.category]))
                  .get()))
              .map(
                (row) => MapEntry(
                  row.read(db.submissions.category),
                  row.read(count) ?? 0,
                ),
              ),
        );
        final canValidate =
            (await (db.select(db.categories).join([
                        innerJoin(
                          db.submissions,
                          db.submissions.category.equalsExp(db.categories.name),
                        ),
                        innerJoin(
                          db.users,
                          db.users.username.equalsExp(db.submissions.user),
                        ),
                      ])
                      ..where(
                        db.submissions.projectId.equals(1) &
                            db.submissions.status.equals(
                              SubmissionStatus.pending.name,
                            ) &
                            db.users.disabled.isNull(),
                      )
                      ..groupBy(
                        [db.categories.name],
                        having: db.submissions.id.count().isBiggerOrEqualValue(
                          4,
                        ),
                      ))
                    .get())
                .map((row) => row.readTable(db.categories).name)
                .toSet();

        return Response.ok(
          jsonEncode(
            categories
                .map(
                  (c) => c.toJson()
                    ..addAll({
                      "submissionCount": submissionCounts[c.name] ?? 0,
                      "canValidate": canValidate.contains(c.name),
                    }),
                )
                .toList(),
          ),
          headers: {"Content-Type": "application/json"},
        );
      }),
    )
    ..get(
      "/categories/<name>", // MARK: [GET] /categories/<name>
      apiAuthWall((req, auth) async {
        final category =
            await (db.select(db.categories)
                  ..where((u) => u.name.equals(req.params["name"] ?? "")))
                .getSingleOrNull();
        if (category == null) {
          return Response.notFound(jsonEncode({"error": "Category not found"}));
        }

        final count = db.submissions.id.count();
        final submissionCount =
            (await (db.selectOnly(db.submissions)
                      ..addColumns([count])
                      ..where(db.submissions.category.equals(category.name)))
                    .get())
                .first
                .read(count) ??
            0;

        final canValidate =
            await (db.select(db.categories).join([
                    innerJoin(
                      db.submissions,
                      db.submissions.category.equalsExp(db.categories.name),
                    ),
                    innerJoin(
                      db.users,
                      db.users.username.equalsExp(db.submissions.user),
                    ),
                  ])
                  ..where(
                    db.categories.name.equals(category.name) &
                        db.submissions.projectId.equals(1) &
                        db.submissions.status.equals(
                          SubmissionStatus.pending.name,
                        ) &
                        db.users.disabled.isNull(),
                  )
                  ..groupBy([
                    db.categories.name,
                  ], having: db.submissions.id.count().isBiggerOrEqualValue(4)))
                .getSingleOrNull() !=
            null;

        return Response.ok(
          jsonEncode(
            category.toJson()..addAll({
              "submissionCount": submissionCount,
              "canValidate": canValidate,
            }),
          ),
          headers: {"Content-Type": "application/json"},
        );
      }),
    )
    ..put(
      "/categories/<name>", // MARK: [PUT] /categories/<name>
      apiAuthWall((req, _) async {
        final category =
            await (db.select(db.categories)
                  ..where((u) => u.name.equals(req.params["name"] ?? "")))
                .getSingleOrNull();
        if (category == null) {
          return Response.notFound(jsonEncode({"error": "Category not found"}));
        }

        if (jsonDecode(await req.readAsString()) case {
          "displayName": String? displayName,
        }) {
          final updatedCategory = CategoriesCompanion(
            displayName: displayName.absentOrNullIfBlank,
          );

          await (db.update(
            db.categories,
          )..where((u) => u.name.equals(category.name))).write(updatedCategory);
          return Response.ok(null);
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid request data"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.admin),
    )
    ..post(
      "/categories", // MARK: [POST] /categories
      apiAuthWall((req, _) async {
        if (jsonDecode(await req.readAsString()) case {
          "name": String name,
          "displayName": String? displayName,
        }) {
          if (!RegExp(r"^[a-z0-9]+(?:-[a-z0-9]+)*$").hasMatch(name)) {
            return Response.badRequest(
              body: jsonEncode({
                "error":
                    "Invalid category name. Only lowercase letters, numbers, and hyphens are allowed.",
              }),
              headers: {"Content-Type": "application/json"},
            );
          }

          final createdCategory = CategoriesCompanion.insert(
            name: name,
            displayName: displayName.absentOrNullIfBlank,
          );

          await db.into(db.categories).insert(createdCategory);
          return Response(201);
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid request data"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.admin),
    )
    ..delete(
      "/categories/<name>", // MARK: [DELETE] /categories/<name>
      apiAuthWall((req, _) async {
        final category =
            await (db.select(db.categories)
                  ..where((u) => u.name.equals(req.params["name"] ?? "")))
                .getSingleOrNull();
        if (category == null) {
          return Response.notFound(jsonEncode({"error": "Category not found"}));
        }

        await (db.delete(
          db.categories,
        )..where((u) => u.name.equals(category.name))).go();
        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    );
}

import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/database.dart';
import '../server.dart';
import 'api.dart';

const _minimumValidationWeight = 5;
const _validationProjectId = 1;

void define(Router router) {
  router
    ..post(
      "/validation/create", // MARK: [POST] /validation/create
      apiAuthWall(
        (req, auth) async => await db.transaction<Response>(() async {
          final category =
              (await (db.select(db.categories).join([
                          innerJoin(
                            db.submissions,
                            db.submissions.category.equalsExp(
                              db.categories.name,
                            ),
                          ),
                          innerJoin(
                            db.users,
                            db.users.username.equalsExp(db.submissions.user),
                          ),
                        ])
                        ..where(
                          db.submissions.projectId.equals(
                                _validationProjectId,
                              ) &
                              db.submissions.status.equals(
                                SubmissionStatus.pending.name,
                              ) &
                              db.submissions.user.isNotValue(
                                auth!.user.username,
                              ) &
                              db.users.disabled.isNull(),
                        )
                        ..groupBy(
                          [db.categories.name],
                          having: db.submissions.id
                              .count()
                              .isBiggerOrEqualValue(4),
                        )
                        ..orderBy([OrderingTerm.random()])
                        ..limit(1))
                      .getSingleOrNull())
                  ?.readTable(db.categories);
          if (category == null) {
            return Response(
              409,
              body: jsonEncode({
                "error": "No categories available for validation",
              }),
              headers: {"Content-Type": "application/json"},
            );
          }

          final unknownPositives =
              (await (db.select(db.submissions).join([
                          innerJoin(
                            db.users,
                            db.users.username.equalsExp(db.submissions.user),
                          ),
                        ])
                        ..where(
                          db.submissions.projectId.equals(
                                _validationProjectId,
                              ) &
                              db.submissions.status.equals(
                                SubmissionStatus.pending.name,
                              ) &
                              db.submissions.category.isNull().not() &
                              db.submissions.category.equals(category.name) &
                              db.submissions.user.isNotValue(
                                auth.user.username,
                              ) &
                              db.users.disabled.isNull(),
                        )
                        ..orderBy([OrderingTerm.random()])
                        ..limit(4))
                      .get())
                  .map((row) => row.readTable(db.submissions));
          final knownPositives =
              (await (db.select(db.submissions).join([
                          innerJoin(
                            db.users,
                            db.users.username.equalsExp(db.submissions.user),
                          ),
                        ])
                        ..where(
                          db.submissions.projectId.equals(
                                _validationProjectId,
                              ) &
                              db.submissions.status.equals(
                                SubmissionStatus.accepted.name,
                              ) &
                              db.submissions.category.equals(category.name) &
                              db.submissions.user.isNotValue(
                                auth.user.username,
                              ) &
                              db.users.disabled.isNull(),
                        )
                        ..orderBy([OrderingTerm.random()])
                        ..limit(8))
                      .get())
                  .map((row) => row.readTable(db.submissions));
          final knownNegatives =
              (await (db.select(db.submissions).join([
                          innerJoin(
                            db.users,
                            db.users.username.equalsExp(db.submissions.user),
                          ),
                        ])
                        ..where(
                          db.submissions.projectId.equals(
                                _validationProjectId,
                              ) &
                              db.submissions.status.equals(
                                SubmissionStatus.accepted.name,
                              ) &
                              db.submissions.category
                                  .equals(category.name)
                                  .not() &
                              db.submissions.user.isNotValue(
                                auth.user.username,
                              ) &
                              db.users.disabled.isNull(),
                        )
                        ..orderBy([OrderingTerm.random()])
                        ..limit(8))
                      .get())
                  .map((row) => row.readTable(db.submissions));
          if (unknownPositives.length < 4 ||
              knownPositives.length < 8 ||
              knownNegatives.length < 8) {
            return Response(
              409,
              body: jsonEncode({
                "error": "Not enough submissions available for validation",
              }),
              headers: {"Content-Type": "application/json"},
            );
          }

          final itemsFormatted =
              [...unknownPositives, ...knownPositives, ...knownNegatives]
                  .map(
                    (s) =>
                        "${s.assetId}.${extensionFromMime(s.assetMimeType!) ?? "dat"}",
                  )
                  .toList()
                ..shuffle();
          final knownNegativesFormatted = knownNegatives
              .map(
                (s) =>
                    "${s.assetId}.${extensionFromMime(s.assetMimeType!) ?? "dat"}",
              )
              .toList();
          return Response.ok(
            jsonEncode({
              "payload":
                  JWT(
                    {
                      "category": category.name,
                      "items": itemsFormatted,
                      "knownNegatives": knownNegativesFormatted,
                    },
                    issuer: jwtIssuer(req),
                    audience: jwtAudienceValidation,
                    subject: auth.user.username,
                  ).sign(
                    jwtPrivateKey,
                    algorithm: JWTAlgorithm.RS256,
                    expiresIn: Duration(minutes: 20),
                  ),
            }),
            headers: {"Content-Type": "application/json"},
          );
        }),
      ),
    )
    ..post(
      "/validation/extend", // MARK: [POST] /validation/extend
      apiAuthWall((req, auth) async {
        if (jsonDecode(await req.readAsString()) case {
          "payload": String payload,
        }) {
          JWT jwt;
          try {
            jwt = JWT.verify(
              payload,
              jwtPublicKey,
              issuer: jwtIssuer(req),
              audience: jwtAudienceValidation,
            );
            if (jwt.subject == null) throw JWTException("");
          } on JWTExpiredException catch (_) {
            return Response.unauthorized(
              jsonEncode({"error": "Validation token expired"}),
              headers: {"Content-Type": "application/json"},
            );
          } on JWTException catch (_) {
            return Response.unauthorized(
              jsonEncode({"error": "Invalid validation token"}),
              headers: {"Content-Type": "application/json"},
            );
          }
          if (jwt.subject != auth?.user.username) {
            return Response.unauthorized(
              jsonEncode({"error": "Validation token does not match user"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          final category = jwt.payload["category"] as String;
          final existingItems = List<String>.from(jwt.payload["items"]);
          final knownNegatives = List<String>.from(
            jwt.payload["knownNegatives"],
          );

          final existingAssetIds = existingItems
              .map((item) => item.split(".").first)
              .toList();

          final newRowCondition =
              db.submissions.projectId.equals(_validationProjectId) &
              (db.submissions.status.equals(SubmissionStatus.accepted.name) |
                  (db.submissions.status.equals(SubmissionStatus.pending.name) &
                      db.submissions.category.equals(category) &
                      Constant(existingItems.length < 36))) &
              db.submissions.category.isNotNull() &
              db.submissions.assetId.isNotIn(existingAssetIds) &
              db.submissions.user.isNotValue(auth!.user.username) &
              db.users.disabled.isNull();
          final newRow =
              await (db.select(db.submissions).join([
                      innerJoin(
                        db.users,
                        db.users.username.equalsExp(db.submissions.user),
                      ),
                    ])
                    ..where(newRowCondition)
                    ..orderBy([OrderingTerm.random()])
                    ..limit(1))
                  .getSingleOrNull();
          if (newRow == null) {
            return Response(
              409,
              body: jsonEncode({
                "error": "No more submissions available for this category",
              }),
              headers: {"Content-Type": "application/json"},
            );
          }

          final submission = newRow.readTable(db.submissions);
          final newItem =
              "${submission.assetId}.${extensionFromMime(submission.assetMimeType!) ?? "dat"}";
          existingItems.add(newItem);

          final originalExp = jwt.payload["exp"] as int;
          final expiresAt = DateTime.fromMillisecondsSinceEpoch(
            originalExp * 1000,
          );
          final remaining = expiresAt.difference(DateTime.now());
          if (remaining.isNegative) {
            throw StateError(
              "Token is already expired, should've been caught earlier, idk",
            );
          }

          return Response.ok(
            jsonEncode({
              "payload":
                  JWT(
                    {
                      "category": category,
                      "items": existingItems,
                      "knownNegatives": knownNegatives,
                    },
                    issuer: jwtIssuer(req),
                    audience: jwtAudienceValidation,
                    subject: auth.user.username,
                  ).sign(
                    jwtPrivateKey,
                    algorithm: JWTAlgorithm.RS256,
                    expiresIn: remaining,
                  ),
            }),
            headers: {"Content-Type": "application/json"},
          );
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid request data"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }),
    )
    ..post(
      "/validation/submit", // MARK: [POST] /validation/submit
      apiAuthWall(
        (req, auth) async => await db.transaction<Response>(() async {
          if (jsonDecode(await req.readAsString()) case {
            "payload": String payload,
            "shown": List<dynamic> shown,
            "clicked": List<dynamic> clicked,
          }) {
            JWT jwt;
            try {
              jwt = JWT.verify(
                payload,
                jwtPublicKey,
                issuer: jwtIssuer(req),
                audience: jwtAudienceValidation,
              );
              if (jwt.subject == null) throw JWTException("");
            } on JWTExpiredException catch (_) {
              return Response.unauthorized(
                jsonEncode({"error": "Validation token expired"}),
                headers: {"Content-Type": "application/json"},
              );
            } on JWTException catch (_) {
              return Response.unauthorized(
                jsonEncode({"error": "Invalid validation token"}),
                headers: {"Content-Type": "application/json"},
              );
            }
            if (jwt.subject != auth?.user.username) {
              return Response.unauthorized(
                jsonEncode({"error": "Validation token does not match user"}),
                headers: {"Content-Type": "application/json"},
              );
            }

            List<String> effectiveShown;
            try {
              effectiveShown = shown
                  .map((e) => e as String)
                  .where(
                    (r) =>
                        r.trim().isNotEmpty &&
                        r.split(".").length == 2 &&
                        r.split(".").first.trim().isNotEmpty,
                  )
                  .map((r) => r.split(".").first)
                  .where(
                    (r) => (jwt.payload["items"] as List).any(
                      (i) => i.split(".").first == r,
                    ),
                  )
                  .toList();
            } catch (_) {
              return Response.badRequest(
                body: jsonEncode({"error": "Invalid shown data format"}),
                headers: {"Content-Type": "application/json"},
              );
            }

            List<String> effectiveClicked;
            try {
              effectiveClicked = clicked
                  .map((e) => e as String)
                  .where(
                    (r) =>
                        r.trim().isNotEmpty &&
                        r.split(".").length == 2 &&
                        r.split(".").first.trim().isNotEmpty,
                  )
                  .map((r) => r.split(".").first)
                  .where(
                    (r) => (jwt.payload["items"] as List).any(
                      (i) => i.split(".").first == r,
                    ),
                  )
                  .toList();
            } catch (_) {
              return Response.badRequest(
                body: jsonEncode({"error": "Invalid clicked data format"}),
                headers: {"Content-Type": "application/json"},
              );
            }

            final shownSubmissions = await (db.select(
              db.submissions,
            )..where((s) => s.assetId.isIn(effectiveShown))).get();

            final isUnknownClicked = Map.fromEntries(
              shownSubmissions
                  .where(
                    (s) =>
                        s.status == SubmissionStatus.pending &&
                        s.category == jwt.payload["category"],
                  )
                  .map(
                    (s) => MapEntry(
                      s,
                      effectiveClicked.contains(s.assetId) ? 1 : 0,
                    ),
                  ),
            );
            final isKnownCorrectlyAssigned = Map.fromEntries(
              shownSubmissions
                  .where((s) => s.status == SubmissionStatus.accepted)
                  .map(
                    (s) => MapEntry(
                      s,
                      (s.category == jwt.payload["category"] &&
                                  effectiveClicked.contains(s.assetId)) ||
                              (s.category != jwt.payload["category"] &&
                                  !effectiveClicked.contains(s.assetId))
                          ? 1
                          : 0,
                    ),
                  ),
            );

            final userScore =
                (1 + auth!.user.validationWeightPositive) /
                (2 +
                    auth.user.validationWeightPositive +
                    auth.user.validationWeightNegative);

            final imageWeightPositives = Map.fromEntries(
              shownSubmissions
                  .where(
                    (s) =>
                        s.status == SubmissionStatus.pending &&
                        s.category == jwt.payload["category"],
                  )
                  .map(
                    (s) => MapEntry(
                      s,
                      s.validationWeightPositive +
                          (userScore * isUnknownClicked[s]!),
                    ),
                  ),
            );
            final imageWeightNegatives = Map.fromEntries(
              shownSubmissions
                  .where(
                    (s) =>
                        s.status == SubmissionStatus.pending &&
                        s.category == jwt.payload["category"],
                  )
                  .map(
                    (s) => MapEntry(
                      s,
                      s.validationWeightNegative +
                          (userScore * (1 - isUnknownClicked[s]!)),
                    ),
                  ),
            );

            final userWeightPositive =
                auth.user.validationWeightPositive +
                shownSubmissions
                    .where((s) => s.status == SubmissionStatus.accepted)
                    .fold(0, (n, s) => n + isKnownCorrectlyAssigned[s]!);
            final userWeightNegative =
                auth.user.validationWeightNegative +
                shownSubmissions
                    .where((s) => s.status == SubmissionStatus.accepted)
                    .fold(
                      0,
                      (n, s) => n + (2 * (1 - isKnownCorrectlyAssigned[s]!)),
                    );
            await (db.update(
              db.users,
            )..where((u) => u.username.equals(auth.user.username))).write(
              UsersCompanion(
                validationWeightPositive: Value(userWeightPositive),
                validationWeightNegative: Value(userWeightNegative),
              ),
            );

            final submissionScores = Map.fromEntries(
              shownSubmissions
                  .where(
                    (s) =>
                        s.status == SubmissionStatus.pending &&
                        s.category == jwt.payload["category"],
                  )
                  .map(
                    (s) => MapEntry(
                      s,
                      (1 + imageWeightPositives[s]!) /
                          (2 +
                              imageWeightPositives[s]! +
                              imageWeightNegatives[s]!),
                    ),
                  ),
            );

            for (final s in shownSubmissions.where(
              (s) =>
                  s.status == SubmissionStatus.pending &&
                  s.category == jwt.payload["category"],
            )) {
              final submissionWeightPositive = imageWeightPositives[s]!;
              final submissionWeightNegative = imageWeightNegatives[s]!;
              final submissionScore = submissionScores[s]!;

              bool approve = false;
              bool reject = false;
              if (submissionWeightPositive + submissionWeightNegative >=
                  _minimumValidationWeight) {
                if (submissionScore >= 0.9) {
                  approve = true;
                } else if (submissionScore <= 0.1) {
                  reject = true;
                }
              }

              await (db.update(
                db.submissions,
              )..where((s2) => s2.id.equals(s.id))).write(
                SubmissionsCompanion(
                  status: approve
                      ? Value(SubmissionStatus.accepted)
                      : (reject
                            ? Value(SubmissionStatus.rejected)
                            : Value.absent()),
                  validationWeightPositive: Value(submissionWeightPositive),
                  validationWeightNegative: Value(submissionWeightNegative),
                ),
              );
            }

            return Response.ok(null);
          } else {
            return Response.badRequest(
              body: jsonEncode({"error": "Invalid request data"}),
              headers: {"Content-Type": "application/json"},
            );
          }
        }),
      ),
    )
    ..post(
      "/validation/report/<asset>", // MARK: [POST] /validation/report/<asset>
      apiAuthWall(
        (req, auth) async => await db.transaction<Response>(() async {
          if (jsonDecode(await req.readAsString()) case {
            "payload": String payload,
          }) {
            JWT jwt;
            try {
              jwt = JWT.verify(
                payload,
                jwtPublicKey,
                issuer: jwtIssuer(req),
                audience: jwtAudienceValidation,
              );
              if (jwt.subject == null) throw JWTException("");
            } on JWTExpiredException catch (_) {
              return Response.unauthorized(
                jsonEncode({"error": "Validation token expired"}),
                headers: {"Content-Type": "application/json"},
              );
            } on JWTException catch (_) {
              return Response.unauthorized(
                jsonEncode({"error": "Invalid validation token"}),
                headers: {"Content-Type": "application/json"},
              );
            }
            if (jwt.subject != auth?.user.username) {
              return Response.unauthorized(
                jsonEncode({"error": "Validation token does not match user"}),
                headers: {"Content-Type": "application/json"},
              );
            }

            if (!jwt.payload["items"].contains(req.params["asset"])) {
              return Response.unauthorized(
                jsonEncode({"error": "Asset not included in validation token"}),
                headers: {"Content-Type": "application/json"},
              );
            }

            final submission =
                await (db.select(db.submissions)..where(
                      (s) => s.assetId.equals(
                        req.params["asset"]?.split(".").first ?? "",
                      ),
                    ))
                    .getSingleOrNull();
            final user =
                await (db.select(db.users)
                      ..where((u) => u.username.equals(submission?.user ?? "")))
                    .getSingleOrNull();
            if (submission == null ||
                user?.disabled != null ||
                submission.validationReports.contains(auth!.user.username)) {
              return Response.ok(null);
            }

            final rejectSubmission =
                (submission.validationReports.length + 1) >= 3;
            await (db.update(
              db.submissions,
            )..where((s) => s.id.equals(submission.id))).write(
              SubmissionsCompanion(
                status: rejectSubmission
                    ? Value(SubmissionStatus.reported)
                    : Value.absent(),
                validationReports: Value([
                  ...submission.validationReports,
                  auth.user.username,
                ]),
              ),
            );

            return Response.ok(null);
          } else {
            return Response.badRequest(
              body: jsonEncode({"error": "Invalid request data"}),
              headers: {"Content-Type": "application/json"},
            );
          }
        }),
      ),
    );
}

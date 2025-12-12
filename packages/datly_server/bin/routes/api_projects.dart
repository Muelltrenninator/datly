import 'dart:convert';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:image/image.dart' as img;
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../helpers.dart';
import '../server.dart';
import 'api.dart';

void define(Router router) {
  router
    ..get(
      "/projects/list",
      apiAuthWall((req, auth) async {
        final projects = await db.select(db.projects).get();
        projects.removeWhere((p) => !auth!.user.projects.contains(p.id));
        return Response.ok(
          projects.map((u) => u.toJson()).toList(),
          headers: {"Content-Type": "application/json"},
        );
      }),
    )
    ..get(
      "/projects/<id>",
      apiAuthWall((req, auth) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        return Response.ok(
          project.toJsonString(),
          headers: {"Content-Type": "application/json"},
        );
      }),
    )
    ..post(
      "/projects/<id>",
      apiAuthWall((req, _) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        if (jsonDecode(await req.readAsString()) case {
          "title": String? title,
          "description": String? description,
        }) {
          final updatedProject = ProjectsCompanion(
            title: title != null ? Value(title) : Value.absent(),
            description: description != null
                ? Value(description)
                : Value.absent(),
          );

          await (db.update(
            db.projects,
          )..where((u) => u.id.equals(project.id))).write(updatedProject);
          return Response.ok(null);
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid project data"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.admin),
    )
    ..put(
      "/projects",
      apiAuthWall((req, _) async {
        if (jsonDecode(await req.readAsString()) case {
          "title": String title,
          "description": String? description,
        }) {
          final createdProject = ProjectsCompanion.insert(
            title: title,
            description: description != null
                ? Value(description)
                : Value.absent(),
          );

          await db.into(db.projects).insert(createdProject);
          return Response(201);
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid project data"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.admin),
    )
    ..delete(
      "/projects/<id>",
      apiAuthWall((req, _) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        await (db.delete(
          db.projects,
        )..where((u) => u.id.equals(project.id))).go();
        return Response.ok(null);
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/projects/<id>/submissions",
      apiAuthWall((req, _) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        final submissions = await (db.select(
          db.submissions,
        )..where((s) => s.projectId.equals(project.id))).get();

        return Response.ok(
          jsonEncode(submissions.map((s) => s.toJson()).toList()),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/projects/<id>/submissions/live",
      apiAuthWall((req, _) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        final submissions = (db.select(
          db.submissions,
        )..where((s) => s.projectId.equals(project.id))).watch();

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
    )
    ..put(
      "/projects/<id>/submissions",
      apiAuthWall((req, auth) async {
        if (req.headers["content-type"] == null ||
            !req.headers["content-type"]!.startsWith("multipart/")) {
          return Response.badRequest(
            body: jsonEncode({
              "error": "Content-Type must be multipart/form-data",
            }),
            headers: {"Content-Type": "application/json"},
          );
        }

        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        if (!auth!.user.projects.contains(project.id)) {
          return Response.forbidden(
            jsonEncode({"error": "Insufficient permissions"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        final multipart = req.multipart();
        if (multipart == null) {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid multipart data"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        final part = await multipart.parts.first;
        var mime = part.headers["content-type"] ?? "application/octet-stream";
        final uuid = Uuid().v4().replaceAll("-", "");

        if (!["image/png", "image/jpeg"].contains(mime)) {
          mime = "image/png";
        }

        final file = assetFile(uuid, mime);
        var image = img.decodeImage(await part.readBytes());
        if (image == null) {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid image data"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        if (image.width != 224 || image.height != 224) {
          // return Response.badRequest(
          //   body: jsonEncode({"error": "Image must be 224x224 pixels"}),
          //   headers: {"Content-Type": "application/json"},
          // );
          image = img.resize(
            image,
            width: 224,
            height: 224,
            interpolation: img.Interpolation.cubic,
          );
        }

        final blurHash = BlurHash.encode(image).hash;
        final encoded = mime == "image/png"
            ? img.encodePng(image)
            : img.encodeJpg(image);
        await file.writeAsBytes(encoded, flush: true);

        await db
            .into(db.submissions)
            .insert(
              SubmissionsCompanion.insert(
                projectId: project.id,
                user: Value(auth.user.username),
                assetId: Value(uuid),
                assetMimeType: Value(mime),
                assetBlurHash: blurHash,
              ),
            );

        return Response(201, headers: {"Content-Type": "application/json"});
      }),
    )
    ..post(
      "/projects/<id>/submissions/<submissionId>",
      apiAuthWall((req, auth) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        final submission =
            await (db.select(db.submissions)..where(
                  (s) =>
                      s.id.equals(
                        int.tryParse(req.params["submissionId"]!) ?? -1,
                      ) &
                      s.projectId.equals(project.id),
                ))
                .getSingleOrNull();
        if (submission == null) {
          return Response.notFound(
            jsonEncode({"error": "Submission not found"}),
          );
        }

        if (jsonDecode(await req.readAsString()) case {
          "status": String? status,
        }) {
          if (status != null &&
              !SubmissionStatus.values.asNameMap().keys.contains(status)) {
            return Response.badRequest(
              body: jsonEncode({"error": "Invalid submission status"}),
              headers: {"Content-Type": "application/json"},
            );
          }

          await (db.update(
            db.submissions,
          )..where((s) => s.id.equals(submission.id))).write(
            SubmissionsCompanion(
              status: status != null
                  ? Value(SubmissionStatus.values.byName(status))
                  : Value.absent(),
            ),
          );

          if (status != null &&
              SubmissionStatus.values.byName(status) ==
                  SubmissionStatus.censored &&
              submission.assetId != null &&
              submission.assetMimeType != null) {
            final asset = assetFile(
              submission.assetId!,
              submission.assetMimeType!,
            );
            if (await asset.exists()) await asset.delete();

            await ((db.update(
              db.submissions,
            )..where((s) => s.id.equals(submission.id))).write(
              SubmissionsCompanion(
                assetId: const Value(null),
                assetMimeType: const Value(null),
              ),
            ));
          }

          return Response.ok(null);
        } else {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid submission data"}),
            headers: {"Content-Type": "application/json"},
          );
        }
      }, minimumRole: UserRole.admin),
    )
    ..delete(
      "/projects/<id>/submissions/<submissionId>",
      apiAuthWall((req, auth) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        final submission =
            await (db.select(db.submissions)..where(
                  (s) =>
                      s.id.equals(
                        int.tryParse(req.params["submissionId"]!) ?? -1,
                      ) &
                      s.projectId.equals(project.id),
                ))
                .getSingleOrNull();
        if (submission == null) {
          return Response.notFound(
            jsonEncode({"error": "Submission not found"}),
          );
        }

        if (submission.user != auth!.user.username &&
            auth.user.role != UserRole.admin) {
          return Response.forbidden(
            jsonEncode({"error": "Insufficient permissions"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        await (db.delete(
          db.submissions,
        )..where((s) => s.id.equals(submission.id))).go();

        return Response.ok(null, headers: {"Content-Type": "application/json"});
      }),
    );
}

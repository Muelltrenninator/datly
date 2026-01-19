import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:image/image.dart' as img;
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

// parent package
// ignore: depend_on_referenced_packages, directives_ordering
import 'package:datly/generated/gitbaker.g.dart';

import '../database/database.dart';
import '../helpers.dart';
import '../server.dart';
import 'api.dart';

void define(Router router) {
  router
    ..get(
      "/projects/list", // MARK: [GET] /projects/list
      apiAuthWall((req, auth) async {
        final projects = await db.select(db.projects).get();
        projects.removeWhere((p) {
          if (auth?.user.role == UserRole.admin) return false;
          return !auth!.user.projects.contains(p.id);
        });
        return Response.ok(
          jsonEncode(projects.map((u) => u.toJson()).toList()),
          headers: {"Content-Type": "application/json"},
        );
      }),
    )
    ..get(
      "/projects/<id>", // MARK: [GET] /projects/<id>
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
    ..put(
      "/projects/<id>", // MARK: [PUT] /projects/<id>
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
    ..post(
      "/projects", // MARK: [POST] /projects
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
      "/projects/<id>", // MARK: [DELETE] /projects/<id>
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
      "/projects/<id>/submissions", // MARK: [GET] /projects/<id>/submissions
      apiAuthWall((req, _) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        final submissions =
            await (db.select(db.submissions)
                  ..where((s) => s.projectId.equals(project.id))
                  ..orderBy([
                    (s) => OrderingTerm.desc(s.submittedAt),
                    (s) => OrderingTerm.desc(s.id),
                  ]))
                .get();

        return Response.ok(
          jsonEncode(submissions.map((s) => s.toJson()).toList()),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/projects/<id>/submissions/dump", // MARK: [GET] /projects/<id>/submissions/dump
      apiAuthWall((req, _) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        final submissions =
            await (db.select(db.submissions)
                  ..where(
                    (s) =>
                        s.projectId.equals(project.id) &
                        s.status.equals(SubmissionStatus.accepted.name),
                  )
                  ..orderBy([
                    (s) => OrderingTerm.desc(s.submittedAt),
                    (s) => OrderingTerm.desc(s.id),
                  ]))
                .get();
        for (var submission in List.from(submissions)) {
          final signature =
              await (db.select(db.signatures)
                    ..where((sg) => sg.submissionId.equals(submission.id)))
                  .getSingleOrNull();
          if (signature == null || signature.revokedAt != null) {
            submissions.remove(submission);
          }
        }

        final archive = Archive()
          ..addFile(
            ArchiveFile.string(
              "manifest.json",
              JsonEncoder.withIndent(" " * 4).convert({
                "datly": GitBaker.currentBranch.commits.last.hash,
                "generatedAt": DateTime.now().millisecondsSinceEpoch,
                "project": project.toJson(),
                "submissions": (await Future.wait(
                  submissions.map(
                    (s) async => s.toJson()
                      ..["signature"] =
                          (await (db.select(db.signatures)..where(
                                    (sg) => sg.submissionId.equals(s.id),
                                  ))
                                  .getSingle())
                              .toJson(),
                  ),
                )).toList(),
              }),
            ),
          )
          // ..addFile(
          //   ArchiveFile.string(
          //     "data.csv",
          //     "images,labels\n${submissions.map((s) => "${s.assetId != null && s.assetMimeType != null ? assetFile(s.assetId!, s.assetMimeType!).path.split("/").last : ""},").join("\n")}",
          //   ),
          // )
          ..addFile(ArchiveFile.directory("images/"));
        for (var submission in submissions) {
          if (submission.assetId != null && submission.assetMimeType != null) {
            final asset = assetFile(
              submission.assetId!,
              submission.assetMimeType!,
            );
            if (await asset.exists()) {
              archive.addFile(
                ArchiveFile.bytes(
                  "images/${asset.path.split("/").last}",
                  await asset.readAsBytes(),
                ),
              );
            }
          }
        }

        return Response.ok(
          ZipEncoder().encodeBytes(archive),
          headers: {"Content-Type": "application/zip"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/projects/<id>/submissions/attributions", // MARK: [GET] /projects/<id>/submissions/attributions
      apiAuthWall((req, _) async {
        if (!pandocAvailable) {
          return Response(
            503,
            body: jsonEncode({
              "error": "Pandoc is not available on the server",
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

        final submissions =
            await (db.select(db.submissions)
                  ..where(
                    (s) =>
                        s.projectId.equals(project.id) &
                        s.status.equals(SubmissionStatus.accepted.name),
                  )
                  ..orderBy([
                    (s) => OrderingTerm.desc(s.submittedAt),
                    (s) => OrderingTerm.desc(s.id),
                  ]))
                .get();
        for (var submission in List.from(submissions)) {
          final signature =
              await (db.select(db.signatures)
                    ..where((sg) => sg.submissionId.equals(submission.id)))
                  .getSingleOrNull();
          if (signature == null || signature.revokedAt != null) {
            submissions.remove(submission);
          }
        }

        if (submissions.isEmpty) {
          return Response.badRequest(
            body: jsonEncode({"error": "No valid submissions found"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        String formatSignature(Signature sig) {
          final signatureMethod = switch (sig.signatureMethod) {
            SignatureMethod.typed => "typing",
          };
          return "Signed v${sig.consentVersion} by $signatureMethod at ${sig.signedAt.toUtc().toIso8601String()}";
        }

        final src = (await Future.wait<String>(
          submissions.reversed.toList().asMap().entries.map(
            (e) async => [
              "${e.key + 1}. Submission #${e.value.id + 1} – ${e.value.user} – Datly",
              e.value.submittedAt.toUtc().toIso8601String(),
              formatSignature(
                await (db.select(db.signatures)
                      ..where((sg) => sg.submissionId.equals(e.value.id)))
                    .getSingle(),
              ),
            ].reduce((a, b) => "$a<br>$b"),
          ),
        )).join("\n");

        return Response.ok(
          jsonEncode({
            "plain": src,
            "html": await pandoc(src, to: "html", standalone: false),
            "rtf": await pandoc(src),
          }),
          headers: {"Content-Type": "application/json"},
        );
      }, minimumRole: UserRole.admin),
    )
    ..get(
      "/projects/<id>/submissions/live", // MARK: [GET] /projects/<id>/submissions/live
      apiAuthWall((req, _) async {
        final project =
            await (db.select(db.projects)..where(
                  (u) => u.id.equals(int.tryParse(req.params["id"]!) ?? -1),
                ))
                .getSingleOrNull();
        if (project == null) {
          return Response.notFound(jsonEncode({"error": "Project not found"}));
        }

        final submissions =
            (db.select(db.submissions)
                  ..where((s) => s.projectId.equals(project.id))
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
      }, minimumRole: UserRole.admin),
    )
    ..post(
      "/projects/<id>/submissions", // MARK: [POST] /projects/<id>/submissions
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

        MultipartRequest? data;
        try {
          data = req.multipart();
        } catch (_) {}
        if (data == null) {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid multipart request"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        final signature = req.url.queryParameters["signature"];
        final signatureParental = req.url.queryParameters["signatureParental"];
        final signatureSnapshot = req.url.queryParameters["signatureSnapshot"]
            ?.split("")
            .take(4096) // length limit
            .join();
        final consentVersion = int.tryParse(
          req.url.queryParameters["consentVersion"] ?? "",
        );
        if (signature == null ||
            signature.isEmpty ||
            signatureSnapshot == null ||
            signatureSnapshot.isEmpty ||
            consentVersion == null ||
            consentVersion < 1) {
          return Response.badRequest(
            body: jsonEncode({"error": "Missing signature parameters"}),
            headers: {"Content-Type": "application/json"},
          );
        }
        if (signature.length > 128 ||
            (signatureParental != null && signatureParental.length > 128)) {
          return Response.badRequest(
            body: jsonEncode({"error": "Signature parameters too long"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        late final Multipart part;
        String mime;
        try {
          part = (await data.parts.toList()).first;
          mime = part.headers["content-type"] ?? "application/octet-stream";
        } catch (e) {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid multipart data: $e"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        if (!["image/png", "image/jpeg"].contains(mime)) {
          mime = "image/png";
        }

        final uuid = Uuid().v4().replaceAll("-", "");
        final file = assetFile(uuid, mime);
        var image = img.decodeImage(await part.readBytes());
        if (image == null) {
          return Response.badRequest(
            body: jsonEncode({"error": "Invalid image data"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        image.exif.clear();
        image.exif.imageIfd
          ..software = "Datly"
          ..copyright =
              "(c) ${DateTime.now().toUtc().year} ${auth.user.username}";

        if (image.width != 224 || image.height != 224) {
          final size = image.width < image.height ? image.width : image.height;
          image = img.resize(
            img.copyCrop(
              image,
              x: (image.width - size) ~/ 2,
              y: (image.height - size) ~/ 2,
              width: size,
              height: size,
            ),
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

        final insertion = await db
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
        final newSubmission = await (db.select(
          db.submissions,
        )..where((s) => s.id.equals(insertion))).getSingle();

        await db
            .into(db.signatures)
            .insert(
              SignaturesCompanion.insert(
                submissionId: Value(newSubmission.id),
                submissionSnapshot: jsonEncode(newSubmission.toJson()),
                user: auth.user.username,
                userSnapshot: jsonEncode(auth.user.toJson()),
                ipAddress: identifierFromRequest(req)!,
                userAgent: Value.absentIfNull(req.headers["user-agent"]),
                signature: signature,
                signatureParental: Value.absentIfNull(signatureParental),
                signatureMethod: SignatureMethod.typed,
                signatureSnapshot: signatureSnapshot,
                consentVersion: consentVersion,
              ),
            );

        return Response(201, headers: {"Content-Type": "application/json"});
      }),
    )
    ..put(
      "/projects/<id>/submissions/<submissionId>", // MARK: [PUT] /projects/<id>/submissions/<submissionId>
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
              (submission.assetId != null ||
                  submission.assetMimeType != null)) {
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
      "/projects/<id>/submissions/<submissionId>", // MARK: [DELETE] /projects/<id>/submissions/<submissionId>
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
            auth.user.role.index < UserRole.admin.index) {
          return Response.forbidden(
            jsonEncode({"error": "Insufficient permissions"}),
            headers: {"Content-Type": "application/json"},
          );
        }

        if (submission.assetId != null && submission.assetMimeType != null) {
          final asset = assetFile(
            submission.assetId!,
            submission.assetMimeType!,
          );
          if (await asset.exists()) await asset.delete();
        }

        await (db.delete(
          db.submissions,
        )..where((s) => s.id.equals(submission.id))).go();

        await (db.update(
          db.signatures,
        )..where((s) => s.submissionId.equals(submission.id))).write(
          SignaturesCompanion(
            revokedAt: Value(DateTime.now()),
            revokedReason: const Value("Submission deleted"),
          ),
        );

        return Response.ok(null, headers: {"Content-Type": "application/json"});
      }),
    );
}

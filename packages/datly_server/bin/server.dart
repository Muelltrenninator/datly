import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:datly/generated/gitbaker.g.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tracer/tracer.dart';

import 'database/database.dart';
import 'email/email.dart';
import 'helpers.dart';
import 'routes/api.dart';

late final Directory dataDirectory;
late final Directory assetsDirectory;
late final Directory certsDirectory;

final t = Tracer(
  "datly_server",
  logLevel: TracerLevel.debug,
  indentation: false,
  forceUtc: true,
  handlers: [TracerConsoleHandler(useStderr: true)],
);
late final DotEnv env;
const devEnv = !bool.fromEnvironment("dart.vm.product");

late final HttpServer server;
late final AppDatabase db;
final _router = Router()
  ..mount("/api", apiPipeline)
  ..get("/legal/privacy", legalHandler)
  ..get("/legal/terms", legalHandler)
  ..mount("/", fileHandler);

String jwtIssuer(Request req) =>
    env["DATLY_CANONICAL_URL"] ?? req.requestedUri.origin;
final jwtPrivateKeyFile = File("${certsDirectory.path}/jwt");
final jwtPublicKeyFile = File("${certsDirectory.path}/jwt.pub");
late final RSAPrivateKey jwtPrivateKey;
late final RSAPublicKey jwtPublicKey;

Future<Response> fileHandler(Request req) async {
  final path = req.url.path == ""
      ? "index.html"
      : req.url.path.replaceAll("..", "");

  var file = File("public/$path");
  if (!(await file.exists())) file = File("public/index.html");

  late final Object contents;
  if (file.path == "public/index.html") {
    contents = (await file.readAsString()).replaceAll(
      "{{CANONICAL}}",
      Uri.parse(env["DATLY_CANONICAL_URL"] ?? "").origin,
    );
  } else {
    contents = await file.readAsBytes();
  }

  final headers = {
    HttpHeaders.contentTypeHeader:
        lookupMimeType(file.path) ?? "application/octet-stream",

    // https://docs.flutter.dev/platform-integration/web/wasm#serve-the-built-output-with-an-http-server
    "Cross-Origin-Embedder-Policy": "require-corp",
    "Cross-Origin-Opener-Policy": "same-origin",
  };
  final response = Response.ok(contents, headers: headers);
  return req.method == "HEAD" ? response.change(body: null) : response;
}

Future<Response> legalHandler(Request req) async {
  final path = req.url.path.replaceAll("..", "").split("/").last;
  final file = File("legal/$path.md");
  if (!(await file.exists())) return Response.notFound("Document not found");

  final contents = await file.readAsString();
  final headers = {
    HttpHeaders.contentTypeHeader: "text/markdown; charset=utf-8",
  };
  final response = Response.ok(contents, headers: headers);
  return req.method == "HEAD" ? response.change(body: null) : response;
}

bool processingShutdown = false;
void shutdown([String signal = "Signal"]) async {
  if (processingShutdown) return;
  processingShutdown = true;
  t.info("Received $signal -> Shutting down");

  try {
    await server.close();
    t.debug("Server closed successfully");
  } catch (e) {
    t.error("Error closing server: $e");
  }

  try {
    await db.customStatement("PRAGMA optimize");
    await db.customStatement("PRAGMA wal_checkpoint");
    t.debug("Database optimized successfully");
  } catch (e) {
    t.error("Error optimizing database: $e");
  }

  try {
    await db.close();
    t.debug("Database connection closed successfully");
  } catch (e) {
    t.error("Error closing database: $e");
  }

  t.info("Shutdown complete, bye 👋");
  exit(0);
}

void main(List<String> args) async {
  t.info(
    "Datly Server [${GitBaker.currentBranch.name}@${GitBaker.currentBranch.commits.last.hashAbbreviated} (${gitBakerWorkspaceFormat(GitBaker.workspace)})]",
  );

  pandoc("").onError((e, _) => e.toString()).then((value) {
    if (value.contains("pandoc failed")) {
      t.warn(
        "Pandoc is not installed, not correctly configured, or not functioning properly. Document conversion features will not work.",
        description: value,
      );
      pandocAvailable = false;
      return;
    }
    pandocAvailable = true;
  });

  for (var i in [ProcessSignal.sigint, ProcessSignal.sigterm]) {
    i.watch().listen((e) => shutdown(e.name), onError: (_) {});
  }

  Directory.current = Platform.script.resolve(".").toFilePath();
  dataDirectory = Directory("${Directory.current.parent.path}/data");
  assetsDirectory = Directory("${dataDirectory.path}/assets");
  certsDirectory = Directory("${dataDirectory.path}/certs");

  env = DotEnv(includePlatformEnvironment: true, quiet: true)
    ..load(["${dataDirectory.path}/.env"]);
  initializeSmtpServer();
  captchaSecretKey = env["DATLY_CAPTCHA_SECRET"] ;

  await generateJwtKeys();
  jwtPrivateKey = RSAPrivateKey(await jwtPrivateKeyFile.readAsString());
  jwtPublicKey = RSAPublicKey(await jwtPublicKeyFile.readAsString());

  defineApiRouter();
  db = AppDatabase();
  await db.customSelect("SELECT 1").getSingle(); // await migration

  final handler = Pipeline()
      .addMiddleware(
        logRequests(
          logger: (message, isError) {
            String format(String message, [bool isError = false]) {
              var parts = message.split(RegExp(r" |\t"))
                ..removeWhere((part) => part.trim().isEmpty);
              if (isError) {
                parts.removeAt(0);
                parts.insert(3, "[500]");
              }

              var path = parts[4];
              if (path.startsWith("/api/projects/1/submissions?signature=")) {
                path = "/api/projects/1/submissions?[REDACTED]";
              }

              return "${parts[2]} ${parts[3].replaceAll(RegExp(r"\[|\]"), "")} - $path";
            }

            if (isError) {
              var output = message.split("\n");
              var log = output.removeAt(0);
              t.error(
                format(log, true),
                error: output.removeAt(0),
                stack: StackTrace.fromString(output.join("\n")),
              );
            } else {
              var formatted = format(message);
              ((formatted.split(" ")[1].toString().startsWith("5"))
                      ? t.warn
                      : t.debug)
                  .call(formatted);
            }
          },
        ),
      )
      .addHandler(_router.call);

  final ip = InternetAddress.anyIPv4;
  final port = 33552;
  server = await serve(handler, ip, port, poweredByHeader: "Datly Server");

  t.info("Server listening on port ${server.port}");

  final adminUser = env["DATLY_ADMIN"] ?? "admin";
  final existing = await (db.select(
    db.users,
  )..where((u) => u.username.equals(adminUser))).getSingleOrNull();

  if (existing == null) {
    final email = env["DATLY_ADMIN_EMAIL"] ?? "admin@localhost";
    final adminPassword =
        env["DATLY_ADMIN_PASSWORD"] ?? await generatePlaintextPassword();
    final secureContext =
        !(bool.tryParse(
              env["DATLY_UNTRUSTED_CONSOLE"] ?? "",
              caseSensitive: false,
            ) ??
            false);

    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            username: adminUser,
            password: adminPassword,
            email: email,
            role: Value(UserRole.admin),
          ),
        );
    t.warn(
      "Created admin user '$adminUser' ($email)${secureContext ? ". Temporary password: $adminPassword" : ""}",
    );
  } else if (existing.role != UserRole.admin) {
    await (db.update(db.users)..where((u) => u.username.equals(adminUser)))
        .write(UsersCompanion(role: Value(UserRole.admin)));
    t.warn("Updated user '$adminUser' to have admin role");
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';

import 'server.dart';

String _codeCharSpace = "0123456789ABCDEFGHJKLMNPQRSTUVWXY";
String generateCode() {
  final random = Random.secure();
  return List.generate(8, (index) {
    return _codeCharSpace[random.nextInt(_codeCharSpace.length)];
  }).join();
}

File assetFile(String assetId, String assetMimeType) {
  final extension = extensionFromMime(assetMimeType) ?? "png";
  return File("${assetsDirectory.path}/$assetId.$extension");
}

String? identifierFromRequest(Request request) {
  final xForwarded = request.headers["x-forwarded-for"]
      ?.split(",")
      .first
      .trim();
  if (xForwarded != null && xForwarded.isNotEmpty) return xForwarded;

  final forwarded = request.headers["Forwarded"]
      ?.split(";")
      .where((e) => e.trim().startsWith("for"))
      .firstOrNull
      ?.split("=")
      .last;
  if (forwarded != null && forwarded.isNotEmpty) return forwarded;

  final ip =
      (request.context["shelf.io.connection_info"] as HttpConnectionInfo?)
          ?.remoteAddress
          .address;
  return ip;
}

late final bool pandocAvailable;
Future<String> pandoc(
  String src, {
  String from = "markdown",
  String to = "rtf",
  bool standalone = true,
  List<String> extraArgs = const [],
}) async {
  final args = <String>[
    if (standalone) "-s",
    "-f",
    from,
    "-t",
    to,
    ...extraArgs,
  ];
  final process = await Process.start("pandoc", args); // runInShell: true

  process.stdin.add(utf8.encode(src));
  await process.stdin.close();

  final stdout = await utf8.decoder.bind(process.stdout).join();
  final stderr = await utf8.decoder.bind(process.stderr).join();

  if (await process.exitCode != 0) {
    throw Exception("pandoc failed (exit ${await process.exitCode}): $stderr");
  }

  return stdout;
}

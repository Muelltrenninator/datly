import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';

import 'server.dart';

String _codeCharSpace = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
String generateCode() {
  final random = Random.secure();
  return List.generate(8, (index) {
    return _codeCharSpace[random.nextInt(_codeCharSpace.length)];
  }).join();
}

File assetFile(String assetId, String assetMimeType) {
  final extension = extensionFromMime(assetMimeType) ?? "png"; // fallback
  return File("${assetsDirectory.path}/$assetId.$extension");
}

String? identifierFromRequest(Request request) {
  final xForwarded = request.headers["x-forwarded-for"]
      ?.split(",")
      .first
      .trim();
  final forwarded = request.headers["Forwarded"]
      ?.split(";")
      .where((e) => e.trim().startsWith("for"))
      .firstOrNull
      ?.split("=")
      .last;
  final ip =
      (request.context["shelf.io.connection_info"] as HttpConnectionInfo?)
          ?.remoteAddress
          .address;
  return xForwarded ?? forwarded ?? ip;
}

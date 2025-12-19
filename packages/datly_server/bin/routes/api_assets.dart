import 'dart:io';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../server.dart';

void define(Router router) {
  final assetsDirectory = Directory("${dataDirectory.path}/assets")
    ..createSync(recursive: true);
  router.mount("/assets", (req) {
    // MARK: [GET|HEAD] /assets/<asset>
    final path = req.url.path.replaceAll("..", "");
    if (!RegExp(r"[0-9a-zA-Z]{32}\.(?:jpg|png)").hasMatch(path)) {
      return Response.badRequest(
        body: "Invalid asset path",
        headers: {"Content-Type": "text/plain"},
      );
    }

    var file = File("${assetsDirectory.path}/$path");
    if (!file.existsSync()) {
      return Response.notFound(
        "Asset not found",
        headers: {"Content-Type": "text/plain"},
      );
    }

    final contents = file.readAsBytesSync();
    final headers = {
      HttpHeaders.contentTypeHeader:
          lookupMimeType(file.path) ?? "application/octet-stream",
    };
    final response = Response.ok(contents, headers: headers);
    return req.method == "HEAD" ? response.change(body: null) : response;
  });
}

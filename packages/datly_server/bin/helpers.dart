import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'server.dart';

String _codeCharSpace = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
String generateCode() => List.generate(
  8,
  (index) => _codeCharSpace[Random.secure().nextInt(_codeCharSpace.length)],
).join();

File assetFile(String assetId, String assetMimeType) {
  final extension =
      extensionFromMime(assetMimeType) ?? "application/octet-stream";
  return File("${assetsDirectory.path}/$assetId.$extension");
}

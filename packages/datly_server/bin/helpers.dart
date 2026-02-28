import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:datly/generated/gitbaker.g.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';

import 'server.dart';

final _rng = Random.secure();
final emailRegex = RegExp(
  r"""^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$""",
);
late final String? captchaSecretKey;

Future<({bool secure, String? code, String? message})> isSecurePassword(
  String password, {
  bool checkPwned = true,
}) async {
  if (password.length < 12) {
    return (
      secure: false,
      code: "short",
      message: "Password must be at least 12 characters long",
    );
  } else if (password.length > 128) {
    return (
      secure: false,
      code: "long",
      message: "Password must be at most 128 characters long",
    );
  } else if (!password.contains(RegExp(r'[A-Z]'))) {
    return (
      secure: false,
      code: "uppercase",
      message: "Password must contain at least one uppercase letter",
    );
  } else if (!password.contains(RegExp(r'[a-z]'))) {
    return (
      secure: false,
      code: "lowercase",
      message: "Password must contain at least one lowercase letter",
    );
  } else if (!password.contains(RegExp(r'[0-9]'))) {
    return (
      secure: false,
      code: "digit",
      message: "Password must contain at least one digit",
    );
  } else if (!password.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{}|;:,.<>?]'))) {
    return (
      secure: false,
      code: "special",
      message:
          "Password must contain at least one special character (!@#\$%^&*()-_=+[]{}|;:,.<>?)",
    );
  }

  if (checkPwned) {
    final sha1 = (await Sha1().hash(utf8.encode(password))).bytes
        .map((b) => b.toRadixString(16).padLeft(2, "0"))
        .join()
        .toUpperCase();
    if ((await http.get(
      Uri.parse("https://api.pwnedpasswords.com/range/${sha1.substring(0, 5)}"),
    )).body.split("\n").any((l) => l.split(":").first == sha1.substring(5))) {
      return (
        secure: false,
        code: "compromised",
        message:
            "This password has appeared in a data breach is not to be considered secure",
      );
    }
  }

  return (secure: true, code: null, message: null);
}

Future<String> generatePlaintextPassword() async {
  String result = "";
  const chars =
      r"0123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnopqrstuvwxyz!@#$%^&*-_=+;:?";
  while (!result.startsWith(RegExp("[A-Za-z]")) ||
      !(await isSecurePassword(result, checkPwned: false)).secure) {
    result = List.generate(
      16,
      (index) => chars[_rng.nextInt(chars.length)],
    ).join();
  }
  return result;
}

Future<String> hashPassword({
  required String password,
  int memoryKB = 19456, // 19 MiB (OWASP minimum for Argon2id)
  int parallelism = 1,
  int iterations = 2,
  int hashLength = 32,
  int saltLen = 16,
}) async {
  final salt = List<int>.generate(saltLen, (_) => _rng.nextInt(256));
  final argon2id = Argon2id(
    memory: memoryKB,
    parallelism: parallelism,
    iterations: iterations,
    hashLength: hashLength,
  );
  final secretKey = await argon2id.deriveKeyFromPassword(
    password: password,
    nonce: salt,
  );

  final derived = await secretKey.extractBytes();
  final b64Hash = base64.encode(derived).replaceAll('=', '');
  final b64Salt = base64.encode(salt).replaceAll('=', '');

  return "\$argon2id\$v=19\$m=$memoryKB,t=$iterations,p=$parallelism\$$b64Salt\$$b64Hash";
}

Future<bool> verifyPassword(String password, String stored) async {
  // format: $argon2id$v=19$m=<memoryKB>,t=<iterations>,p=<parallelism>$<saltBase64NoPad>$<hashBase64NoPad>
  final parts = stored.split(r"$");
  if (parts.length != 6 || parts[1] != "argon2id" || parts[2] != "v=19") {
    return false;
  }

  final params = parts[3].split(',');
  int memoryKB = 19456;
  int iterations = 2;
  int parallelism = 1;

  for (final param in params) {
    if (param.startsWith("m=")) memoryKB = int.parse(param.substring(2));
    if (param.startsWith("t=")) iterations = int.parse(param.substring(2));
    if (param.startsWith("p=")) parallelism = int.parse(param.substring(2));
  }

  // base64 padding
  String padBase64(String str) =>
      str.padRight(str.length + (4 - str.length % 4) % 4, '=');

  final salt = base64.decode(padBase64(parts[4]));
  final hash = base64.decode(padBase64(parts[5]));

  final argon2id = Argon2id(
    memory: memoryKB,
    parallelism: parallelism,
    iterations: iterations,
    hashLength: hash.length,
  );
  final derivedKey = await argon2id.deriveKeyFromPassword(
    password: password,
    nonce: salt,
  );
  final derived = await derivedKey.extractBytes();

  bool constantTimeBytesEquality(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var res = 0;
    for (var i = 0; i < a.length; i++) {
      res |= a[i] ^ b[i];
    }
    return res == 0;
  }

  return constantTimeBytesEquality(derived, hash);
}

Future<bool> verifyCaptcha(String token, [Request? req]) async {
  if (captchaSecretKey == null) {
    t.warn("Captcha secret key not configured, skipping captcha verification");
    return true;
  }

  try {
    final response = await http.post(
      Uri.parse("https://challenges.cloudflare.com/turnstile/v0/siteverify"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "secret": captchaSecretKey!,
        "response": token,
        "remoteip": req != null ? identifierFromRequest(req) : null,
      }),
    );

    final data = json.decode(response.body);
    return data["success"] == true;
  } catch (_) {
    return false;
  }
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

String? localeFromRequest(Request request) {
  final languages = request.headers["accept-language"]?.split(",");
  if (languages == null || languages.isEmpty) return null;

  languages.sort(
    (a, b) => (a.contains(";q=") ? double.parse(a.split(";q=")[1]) : 1)
        .compareTo(b.contains(";q=") ? double.parse(b.split(";q=")[1]) : 1),
  );
  return languages.last.split("-").first.toLowerCase();
}

String gitBakerWorkspaceFormat(List<WorkspaceEntry> entries) {
  if (entries.isEmpty ||
      (entries.length == 1 && entries[0].path.endsWith("gitbaker.g.dart"))) {
    return "clean";
  }
  final addedIndex = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.x == WorkspaceEntryStatusPart.added)
      .length;
  final addedWorking = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.y == WorkspaceEntryStatusPart.added)
      .length;
  final modifiedIndex = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.x == WorkspaceEntryStatusPart.modified)
      .length;
  final modifiedWorking = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.y == WorkspaceEntryStatusPart.modified)
      .length;
  final removedIndex = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.x == WorkspaceEntryStatusPart.deleted)
      .length;
  final removedWorking = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.y == WorkspaceEntryStatusPart.deleted)
      .length;
  final renamedCopied = entries.whereType<WorkspaceEntryRenameCopy>().length;
  final untracked = entries.whereType<WorkspaceEntryUntracked>().length;
  return [
    if (addedIndex > 0 || modifiedIndex > 0 || removedIndex > 0)
      "I${[if (addedIndex > 0) "+$addedIndex", if (modifiedIndex > 0) "\u00B1$modifiedIndex", if (removedIndex > 0) "\u2212$removedIndex"].join()}",
    if (addedWorking > 0 || modifiedWorking > 0 || removedWorking > 0)
      "W${[if (addedWorking > 0) "+$addedWorking", if (modifiedWorking > 0) "\u00B1$modifiedWorking", if (removedWorking > 0) "\u2212$removedWorking"].join()}",
    if (renamedCopied > 0) "R$renamedCopied",
    if (untracked > 0) "U$untracked",
  ].join(" ");
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

Future<void> generateJwtKeys() async {
  final privatePath = jwtPrivateKeyFile.absolute.path;
  final publicPath = jwtPublicKeyFile.absolute.path;
  await certsDirectory.create(recursive: true);

  if (!(await jwtPrivateKeyFile.exists())) {
    Process process;
    try {
      process = await Process.start("openssl", [
        "genrsa",
        "-out",
        privatePath,
        "2048",
      ]);
    } catch (_) {
      t.fatal(
        "OpenSSL is not installed, not correctly configured, or not functioning properly. User authentication not possible without signing keys, panicking.",
      );
      exit(1);
    }

    final stderr = await utf8.decoder.bind(process.stderr).join();
    if (await process.exitCode != 0) {
      t.fatal("OpenSSL failed to generate private key", error: stderr);
      exit(1);
    }
  }

  if (!(await jwtPublicKeyFile.exists())) {
    Process process;
    try {
      process = await Process.start("openssl", [
        "rsa",
        "-in",
        privatePath,
        "-outform",
        "PEM",
        "-pubout",
        "-out",
        publicPath,
      ]);
    } catch (_) {
      t.fatal(
        "OpenSSL is not installed, not correctly configured, or not functioning properly. User authentication not possible without signing keys, panicking.",
      );
      exit(1);
    }

    final stderr = await utf8.decoder.bind(process.stderr).join();
    if (await process.exitCode != 0) {
      t.fatal("OpenSSL failed to generate public key", error: stderr);
      exit(1);
    }
  }
}

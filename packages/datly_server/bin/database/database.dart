import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';

import '../email/email.dart';
import '../helpers.dart';
import '../server.dart';
import 'converters.dart';
import 'tables.dart';

export 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Projects, Users, Submissions, Signatures])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  static QueryExecutor _openConnection() => NativeDatabase.createInBackground(
    File("${dataDirectory.path}/datly.db"),
    isolateSetup: () => open.overrideForAll(() {
      if (Platform.isWindows) {
        try {
          return DynamicLibrary.open("sqlite/sqlite3.arm64.windows.dll");
        } catch (_) {
          try {
            return DynamicLibrary.open("sqlite/sqlite3.x64.windows.dll");
          } catch (_) {}
        }
      } else if (Platform.isLinux) {
        try {
          return DynamicLibrary.open("sqlite/libsqlite3.arm64.linux.so");
        } catch (_) {
          try {
            return DynamicLibrary.open("sqlite/libsqlite3.x64.linux.so");
          } catch (_) {}
        }
      }
      t.error(
        "Unsupported platform (${Abi.current().toString().split("_").join(" ")}); compile `sqlite3` for your architecture and operating system and place it in the `bin/sqlite/` folder, then recompile the Docker server image.",
      );
      exit(1);
    }),
  );

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement("PRAGMA foreign_keys = ON");
      await customStatement("PRAGMA main.auto_vacuum = 1");
      await customStatement("PRAGMA journal_mode = WAL");
      await customStatement("PRAGMA optimize=0x10002");
    },
    onUpgrade: (m, from, to) async {
      t.info("Performing database migration from version $from to $to");

      if (from < 2) {
        await m.createTable(signatures);
      }
      if (from < 3) {
        await m.alterTable(
          TableMigration(
            users,
            newColumns: [
              users.password,
              users.disabled,
              users.activated,
              users.locale,
            ],
            columnTransformer: {
              users.password: const Constant(""),
              // default to German for existing users since most are German.
              // will be overwritten the first time user logs in
              users.locale: const Constant("de"),
            },
          ),
        );
        await m.alterTable(TableMigration(submissions));
        await m.deleteTable("login_codes");

        for (final user in await select(users).get()) {
          var password = await generatePlaintextPassword();
          if (user.username == (env["DATLY_ADMIN"] ?? "admin")) {
            if (env["DATLY_ADMIN_PASSWORD"] != null) {
              password = env["DATLY_ADMIN_PASSWORD"]!;
            }
            if (!(bool.tryParse(
                  env["DATLY_UNTRUSTED_CONSOLE"] ?? "",
                  caseSensitive: false,
                ) ??
                false)) {
              t.warn(
                "Admin user '${user.username}' requires password reset. Temporary password: $password",
              );
            }
          }
          await update(users).replace(
            user.copyWith(password: await hashPassword(password: password)),
          );

          queueEmail(
            EmailMessagesTemplates.passwordResetMigration(
              user: user,
              newPassword: password,
            ).stylized(),
          );
        }
      }

      t.info("Database migration completed");
    },
  );
}

enum UserRole { external, user, admin }

enum SubmissionStatus { pending, accepted, rejected, censored }

enum SignatureMethod { typed }

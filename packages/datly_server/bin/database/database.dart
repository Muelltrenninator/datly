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

@DriftDatabase(tables: [Projects, Users, Submissions, Signatures, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 13;

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
      // if (from < 4) { // disabled in favor of 6
      //   for (final user in await select(users).get()) {
      //     queueEmail(
      //       EmailMessagesTemplates.legalChangedAll(
      //         user: user,
      //         effectiveDate: DateTime(2026, 3, 1),
      //       ).stylized(),
      //     );
      //   }
      // }
      if (from < 5) {
        await m.createTable(categories);
        await m.alterTable(
          TableMigration(
            submissions,
            newColumns: [
              submissions.category,
              submissions.validationWeightPositive,
              submissions.validationWeightNegative,
            ],
          ),
        );
        await m.alterTable(
          TableMigration(
            users,
            newColumns: [
              users.validationWeightPositive,
              users.validationWeightNegative,
            ],
          ),
        );
      }
      // if (from < 6) { // disabled in favor of 10
      //   for (final user in await select(users).get()) {
      //     queueEmail(
      //       EmailMessagesTemplates.legalChangedTerms(
      //         user: user,
      //         effectiveDate: DateTime(2026, 3, 6),
      //       ).stylized(),
      //     );
      //   }
      // }
      if (from < 7) {
        await m.alterTable(
          TableMigration(submissions, newColumns: [submissions.moderated]),
        );
      }
      if (from < 8) {
        await m.alterTable(
          TableMigration(
            submissions,
            newColumns: [submissions.moderationReason],
          ),
        );
      }
      if (from < 9) {
        await m.alterTable(
          TableMigration(
            submissions,
            newColumns: [submissions.validationReports],
          ),
        );
        await (db.update(db.submissions)..where(
              (s) =>
                  s.category.isNull() &
                  s.status.equals(SubmissionStatus.accepted.name),
            ))
            .write(
              SubmissionsCompanion(status: Value(SubmissionStatus.pending)),
            );
      }
      if (from < 10) {
        for (final user in await select(users).get()) {
          queueEmail(
            EmailMessagesTemplates.legalChangedAll(
              user: user,
              effectiveDate: DateTime(2026, 3, 21),
            ).stylized(),
          );
        }
      }
      if (from < 11) {
        // forgot a single dot in `api_projects.dart` which lead to only the
        // passwords being stored as user snapshot instead of them being
        // removed. no one's gonna know
        await (db.update(db.signatures)
              ..where((s) => s.userSnapshot.contains(r"$argon2id$")))
            .write(SignaturesCompanion(userSnapshot: Value("<<REDACTED>>")));
      }
      if (from < 12) {
        for (final user in await select(users).get()) {
          queueEmail(
            EmailMessagesTemplates.validationIntroduction(
              user: user,
            ).stylized(),
          );
        }
      }
      if (from < 13) {
        await m.alterTable(TableMigration(signatures));
      }

      t.info("Database migration completed");
    },
  );
}

enum UserRole { external, user, admin }

enum SubmissionStatus { pending, accepted, rejected, reported, censored }

enum ScoreType { unknown, knownPositive, knownNegative }

enum SignatureMethod { typed }

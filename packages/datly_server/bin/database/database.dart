import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';

import '../server.dart';
import 'converters.dart';
import 'tables.dart';

export 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Projects, Users, LoginCodes, Submissions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => NativeDatabase.createInBackground(
    File("${dataDirectory.path}/datly.db"),
    isolateSetup: () => open.overrideForAll(() {
      if (Platform.isWindows) {
        try {
          return DynamicLibrary.open("sqlite/sqlite3.dll");
        } catch (_) {}
      } else if (Platform.isLinux) {
        try {
          return DynamicLibrary.open("sqlite/sqlite3_arm64.so");
        } catch (_) {
          try {
            return DynamicLibrary.open("sqlite/sqlite3.so");
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
  );
}

enum UserRole { user, admin }

enum SubmissionStatus { pending, accepted, rejected, censored }

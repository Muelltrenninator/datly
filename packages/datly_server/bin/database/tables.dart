// code generation handles this
// ignore_for_file: recursive_getters

import 'converters.dart';
import 'database.dart';

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Users extends Table {
  TextColumn get username => text().withLength(min: 3, max: 16)();
  TextColumn get password => text()();
  TextColumn get email => text().unique()();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get projects =>
      text().map(ListConverter<int>()).withDefault(const Constant("[]"))();
  TextColumn get role =>
      textEnum<UserRole>().withDefault(Constant(UserRole.user.name))();
  TextColumn get disabled =>
      text().nullable().withDefault(const Constant(null))();
  BoolColumn get activated => boolean().withDefault(const Constant(false))();
  TextColumn get locale => text().withDefault(const Constant("en"))();

  @override
  Set<Column<Object>>? get primaryKey => {username};
}

class Submissions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get user =>
      text().references(Users, #username, onDelete: KeyAction.cascade)();
  TextColumn get status => textEnum<SubmissionStatus>().withDefault(
    Constant(SubmissionStatus.pending.name),
  )();
  DateTimeColumn get submittedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get assetId => text().nullable().withLength(min: 32, max: 32)();
  TextColumn get assetMimeType => text().nullable()();
  TextColumn get assetBlurHash => text()();
}

class Signatures extends Table {
  IntColumn get submissionId => integer()();
  TextColumn get submissionSnapshot => text()();

  TextColumn get user => text()();
  TextColumn get userSnapshot => text()();

  TextColumn get ipAddress => text()();
  TextColumn get userAgent => text().nullable()();

  TextColumn get signature => text()();
  TextColumn get signatureParental => text().nullable()();
  TextColumn get signatureMethod => textEnum<SignatureMethod>()();
  TextColumn get signatureSnapshot => text()();

  DateTimeColumn get signedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get consentVersion => integer()();

  DateTimeColumn get revokedAt => dateTime().nullable()();
  TextColumn get revokedReason => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {submissionId};
}

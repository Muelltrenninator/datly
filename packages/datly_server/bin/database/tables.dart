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
  TextColumn get email => text()();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get projects =>
      text().map(ListConverter<int>()).withDefault(const Constant("[]"))();
  TextColumn get role =>
      textEnum<UserRole>().withDefault(const Constant("user"))();

  @override
  Set<Column<Object>>? get primaryKey => {username};
}

class LoginCodes extends Table {
  TextColumn get code => text().withLength(min: 8, max: 8)();
  @ReferenceName('loginCodeOfUser')
  TextColumn get user => text().references(
    Users,
    #username,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  @ReferenceName('loginCodeCreatedBy')
  TextColumn get createdBy => text().nullable().references(
    Users,
    #username,
    onDelete: KeyAction.setDefault,
    onUpdate: KeyAction.setDefault,
  )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime().withDefault(
    currentDateAndTime.modify(DateTimeModifier.days(180)),
  )();

  @override
  Set<Column<Object>>? get primaryKey => {code};
}

class Submissions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(
    Projects,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get user => text().nullable().references(
    Users,
    #username,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.setDefault,
  )();
  TextColumn get status => textEnum<SubmissionStatus>().withDefault(
    Constant(SubmissionStatus.pending.name),
  )();
  DateTimeColumn get submittedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get assetId => text().nullable().withLength(min: 32, max: 32)();
  TextColumn get assetMimeType => text().nullable()();
  TextColumn get assetBlurHash => text()();
}

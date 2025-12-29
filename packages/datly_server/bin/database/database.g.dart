// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, description, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String title;
  final String? description;
  final DateTime createdAt;
  const Project({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Project copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
  }) => Project(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? createdAt,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String> projects =
      GeneratedColumn<String>(
        'projects',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant("[]"),
      ).withConverter<List<int>>($UsersTable.$converterprojects);
  @override
  late final GeneratedColumnWithTypeConverter<UserRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(UserRole.user.name),
      ).withConverter<UserRole>($UsersTable.$converterrole);
  @override
  List<GeneratedColumn> get $columns => [
    username,
    email,
    joinedAt,
    projects,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {username};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
      projects: $UsersTable.$converterprojects.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}projects'],
        )!,
      ),
      role: $UsersTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static TypeConverter<List<int>, String> $converterprojects =
      ListConverter<int>();
  static JsonTypeConverter2<UserRole, String, String> $converterrole =
      const EnumNameConverter<UserRole>(UserRole.values);
}

class User extends DataClass implements Insertable<User> {
  final String username;
  final String email;
  final DateTime joinedAt;
  final List<int> projects;
  final UserRole role;
  const User({
    required this.username,
    required this.email,
    required this.joinedAt,
    required this.projects,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['username'] = Variable<String>(username);
    map['email'] = Variable<String>(email);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    {
      map['projects'] = Variable<String>(
        $UsersTable.$converterprojects.toSql(projects),
      );
    }
    {
      map['role'] = Variable<String>($UsersTable.$converterrole.toSql(role));
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      username: Value(username),
      email: Value(email),
      joinedAt: Value(joinedAt),
      projects: Value(projects),
      role: Value(role),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      username: serializer.fromJson<String>(json['username']),
      email: serializer.fromJson<String>(json['email']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
      projects: serializer.fromJson<List<int>>(json['projects']),
      role: $UsersTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'username': serializer.toJson<String>(username),
      'email': serializer.toJson<String>(email),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
      'projects': serializer.toJson<List<int>>(projects),
      'role': serializer.toJson<String>(
        $UsersTable.$converterrole.toJson(role),
      ),
    };
  }

  User copyWith({
    String? username,
    String? email,
    DateTime? joinedAt,
    List<int>? projects,
    UserRole? role,
  }) => User(
    username: username ?? this.username,
    email: email ?? this.email,
    joinedAt: joinedAt ?? this.joinedAt,
    projects: projects ?? this.projects,
    role: role ?? this.role,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      username: data.username.present ? data.username.value : this.username,
      email: data.email.present ? data.email.value : this.email,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      projects: data.projects.present ? data.projects.value : this.projects,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('projects: $projects, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(username, email, joinedAt, projects, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.username == this.username &&
          other.email == this.email &&
          other.joinedAt == this.joinedAt &&
          other.projects == this.projects &&
          other.role == this.role);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> username;
  final Value<String> email;
  final Value<DateTime> joinedAt;
  final Value<List<int>> projects;
  final Value<UserRole> role;
  final Value<int> rowid;
  const UsersCompanion({
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.projects = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String username,
    required String email,
    this.joinedAt = const Value.absent(),
    this.projects = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : username = Value(username),
       email = Value(email);
  static Insertable<User> custom({
    Expression<String>? username,
    Expression<String>? email,
    Expression<DateTime>? joinedAt,
    Expression<String>? projects,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (projects != null) 'projects': projects,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? username,
    Value<String>? email,
    Value<DateTime>? joinedAt,
    Value<List<int>>? projects,
    Value<UserRole>? role,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      username: username ?? this.username,
      email: email ?? this.email,
      joinedAt: joinedAt ?? this.joinedAt,
      projects: projects ?? this.projects,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (projects.present) {
      map['projects'] = Variable<String>(
        $UsersTable.$converterprojects.toSql(projects.value),
      );
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $UsersTable.$converterrole.toSql(role.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('projects: $projects, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoginCodesTable extends LoginCodes
    with TableInfo<$LoginCodesTable, LoginCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoginCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 8,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<String> user = GeneratedColumn<String>(
    'user',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (username) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (username) ON UPDATE SET DEFAULT ON DELETE SET DEFAULT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: DateTimeExpressions(
      currentDateAndTime,
    ).modify(DateTimeModifier.days(180)),
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    user,
    createdBy,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'login_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoginCode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('user')) {
      context.handle(
        _userMeta,
        user.isAcceptableOrUnknown(data['user']!, _userMeta),
      );
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  LoginCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoginCode(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      user: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $LoginCodesTable createAlias(String alias) {
    return $LoginCodesTable(attachedDatabase, alias);
  }
}

class LoginCode extends DataClass implements Insertable<LoginCode> {
  final String code;
  final String user;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime expiresAt;
  const LoginCode({
    required this.code,
    required this.user,
    this.createdBy,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['user'] = Variable<String>(user);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  LoginCodesCompanion toCompanion(bool nullToAbsent) {
    return LoginCodesCompanion(
      code: Value(code),
      user: Value(user),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory LoginCode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoginCode(
      code: serializer.fromJson<String>(json['code']),
      user: serializer.fromJson<String>(json['user']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'user': serializer.toJson<String>(user),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  LoginCode copyWith({
    String? code,
    String? user,
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? expiresAt,
  }) => LoginCode(
    code: code ?? this.code,
    user: user ?? this.user,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  LoginCode copyWithCompanion(LoginCodesCompanion data) {
    return LoginCode(
      code: data.code.present ? data.code.value : this.code,
      user: data.user.present ? data.user.value : this.user,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoginCode(')
          ..write('code: $code, ')
          ..write('user: $user, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, user, createdBy, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoginCode &&
          other.code == this.code &&
          other.user == this.user &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class LoginCodesCompanion extends UpdateCompanion<LoginCode> {
  final Value<String> code;
  final Value<String> user;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const LoginCodesCompanion({
    this.code = const Value.absent(),
    this.user = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoginCodesCompanion.insert({
    required String code,
    required String user,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       user = Value(user);
  static Insertable<LoginCode> custom({
    Expression<String>? code,
    Expression<String>? user,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (user != null) 'user': user,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoginCodesCompanion copyWith({
    Value<String>? code,
    Value<String>? user,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return LoginCodesCompanion(
      code: code ?? this.code,
      user: user ?? this.user,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (user.present) {
      map['user'] = Variable<String>(user.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoginCodesCompanion(')
          ..write('code: $code, ')
          ..write('user: $user, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubmissionsTable extends Submissions
    with TableInfo<$SubmissionsTable, Submission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubmissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<String> user = GeneratedColumn<String>(
    'user',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (username) ON UPDATE SET DEFAULT ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SubmissionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SubmissionStatus.pending.name),
      ).withConverter<SubmissionStatus>($SubmissionsTable.$converterstatus);
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 32,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetMimeTypeMeta = const VerificationMeta(
    'assetMimeType',
  );
  @override
  late final GeneratedColumn<String> assetMimeType = GeneratedColumn<String>(
    'asset_mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetBlurHashMeta = const VerificationMeta(
    'assetBlurHash',
  );
  @override
  late final GeneratedColumn<String> assetBlurHash = GeneratedColumn<String>(
    'asset_blur_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    user,
    status,
    submittedAt,
    assetId,
    assetMimeType,
    assetBlurHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'submissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Submission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('user')) {
      context.handle(
        _userMeta,
        user.isAcceptableOrUnknown(data['user']!, _userMeta),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    }
    if (data.containsKey('asset_mime_type')) {
      context.handle(
        _assetMimeTypeMeta,
        assetMimeType.isAcceptableOrUnknown(
          data['asset_mime_type']!,
          _assetMimeTypeMeta,
        ),
      );
    }
    if (data.containsKey('asset_blur_hash')) {
      context.handle(
        _assetBlurHashMeta,
        assetBlurHash.isAcceptableOrUnknown(
          data['asset_blur_hash']!,
          _assetBlurHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assetBlurHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Submission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Submission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      user: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user'],
      ),
      status: $SubmissionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      ),
      assetMimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_mime_type'],
      ),
      assetBlurHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_blur_hash'],
      )!,
    );
  }

  @override
  $SubmissionsTable createAlias(String alias) {
    return $SubmissionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SubmissionStatus, String, String> $converterstatus =
      const EnumNameConverter<SubmissionStatus>(SubmissionStatus.values);
}

class Submission extends DataClass implements Insertable<Submission> {
  final int id;
  final int projectId;
  final String? user;
  final SubmissionStatus status;
  final DateTime submittedAt;
  final String? assetId;
  final String? assetMimeType;
  final String assetBlurHash;
  const Submission({
    required this.id,
    required this.projectId,
    this.user,
    required this.status,
    required this.submittedAt,
    this.assetId,
    this.assetMimeType,
    required this.assetBlurHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    if (!nullToAbsent || user != null) {
      map['user'] = Variable<String>(user);
    }
    {
      map['status'] = Variable<String>(
        $SubmissionsTable.$converterstatus.toSql(status),
      );
    }
    map['submitted_at'] = Variable<DateTime>(submittedAt);
    if (!nullToAbsent || assetId != null) {
      map['asset_id'] = Variable<String>(assetId);
    }
    if (!nullToAbsent || assetMimeType != null) {
      map['asset_mime_type'] = Variable<String>(assetMimeType);
    }
    map['asset_blur_hash'] = Variable<String>(assetBlurHash);
    return map;
  }

  SubmissionsCompanion toCompanion(bool nullToAbsent) {
    return SubmissionsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      user: user == null && nullToAbsent ? const Value.absent() : Value(user),
      status: Value(status),
      submittedAt: Value(submittedAt),
      assetId: assetId == null && nullToAbsent
          ? const Value.absent()
          : Value(assetId),
      assetMimeType: assetMimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(assetMimeType),
      assetBlurHash: Value(assetBlurHash),
    );
  }

  factory Submission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Submission(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      user: serializer.fromJson<String?>(json['user']),
      status: $SubmissionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      submittedAt: serializer.fromJson<DateTime>(json['submittedAt']),
      assetId: serializer.fromJson<String?>(json['assetId']),
      assetMimeType: serializer.fromJson<String?>(json['assetMimeType']),
      assetBlurHash: serializer.fromJson<String>(json['assetBlurHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'user': serializer.toJson<String?>(user),
      'status': serializer.toJson<String>(
        $SubmissionsTable.$converterstatus.toJson(status),
      ),
      'submittedAt': serializer.toJson<DateTime>(submittedAt),
      'assetId': serializer.toJson<String?>(assetId),
      'assetMimeType': serializer.toJson<String?>(assetMimeType),
      'assetBlurHash': serializer.toJson<String>(assetBlurHash),
    };
  }

  Submission copyWith({
    int? id,
    int? projectId,
    Value<String?> user = const Value.absent(),
    SubmissionStatus? status,
    DateTime? submittedAt,
    Value<String?> assetId = const Value.absent(),
    Value<String?> assetMimeType = const Value.absent(),
    String? assetBlurHash,
  }) => Submission(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    user: user.present ? user.value : this.user,
    status: status ?? this.status,
    submittedAt: submittedAt ?? this.submittedAt,
    assetId: assetId.present ? assetId.value : this.assetId,
    assetMimeType: assetMimeType.present
        ? assetMimeType.value
        : this.assetMimeType,
    assetBlurHash: assetBlurHash ?? this.assetBlurHash,
  );
  Submission copyWithCompanion(SubmissionsCompanion data) {
    return Submission(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      user: data.user.present ? data.user.value : this.user,
      status: data.status.present ? data.status.value : this.status,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      assetMimeType: data.assetMimeType.present
          ? data.assetMimeType.value
          : this.assetMimeType,
      assetBlurHash: data.assetBlurHash.present
          ? data.assetBlurHash.value
          : this.assetBlurHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Submission(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('user: $user, ')
          ..write('status: $status, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('assetId: $assetId, ')
          ..write('assetMimeType: $assetMimeType, ')
          ..write('assetBlurHash: $assetBlurHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    user,
    status,
    submittedAt,
    assetId,
    assetMimeType,
    assetBlurHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Submission &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.user == this.user &&
          other.status == this.status &&
          other.submittedAt == this.submittedAt &&
          other.assetId == this.assetId &&
          other.assetMimeType == this.assetMimeType &&
          other.assetBlurHash == this.assetBlurHash);
}

class SubmissionsCompanion extends UpdateCompanion<Submission> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String?> user;
  final Value<SubmissionStatus> status;
  final Value<DateTime> submittedAt;
  final Value<String?> assetId;
  final Value<String?> assetMimeType;
  final Value<String> assetBlurHash;
  const SubmissionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.user = const Value.absent(),
    this.status = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.assetId = const Value.absent(),
    this.assetMimeType = const Value.absent(),
    this.assetBlurHash = const Value.absent(),
  });
  SubmissionsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    this.user = const Value.absent(),
    this.status = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.assetId = const Value.absent(),
    this.assetMimeType = const Value.absent(),
    required String assetBlurHash,
  }) : projectId = Value(projectId),
       assetBlurHash = Value(assetBlurHash);
  static Insertable<Submission> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? user,
    Expression<String>? status,
    Expression<DateTime>? submittedAt,
    Expression<String>? assetId,
    Expression<String>? assetMimeType,
    Expression<String>? assetBlurHash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (user != null) 'user': user,
      if (status != null) 'status': status,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (assetId != null) 'asset_id': assetId,
      if (assetMimeType != null) 'asset_mime_type': assetMimeType,
      if (assetBlurHash != null) 'asset_blur_hash': assetBlurHash,
    });
  }

  SubmissionsCompanion copyWith({
    Value<int>? id,
    Value<int>? projectId,
    Value<String?>? user,
    Value<SubmissionStatus>? status,
    Value<DateTime>? submittedAt,
    Value<String?>? assetId,
    Value<String?>? assetMimeType,
    Value<String>? assetBlurHash,
  }) {
    return SubmissionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      user: user ?? this.user,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      assetId: assetId ?? this.assetId,
      assetMimeType: assetMimeType ?? this.assetMimeType,
      assetBlurHash: assetBlurHash ?? this.assetBlurHash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (user.present) {
      map['user'] = Variable<String>(user.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SubmissionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (assetMimeType.present) {
      map['asset_mime_type'] = Variable<String>(assetMimeType.value);
    }
    if (assetBlurHash.present) {
      map['asset_blur_hash'] = Variable<String>(assetBlurHash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubmissionsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('user: $user, ')
          ..write('status: $status, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('assetId: $assetId, ')
          ..write('assetMimeType: $assetMimeType, ')
          ..write('assetBlurHash: $assetBlurHash')
          ..write(')'))
        .toString();
  }
}

class $SignaturesTable extends Signatures
    with TableInfo<$SignaturesTable, Signature> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SignaturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _submissionIdMeta = const VerificationMeta(
    'submissionId',
  );
  @override
  late final GeneratedColumn<int> submissionId = GeneratedColumn<int>(
    'submission_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _submissionSnapshotMeta =
      const VerificationMeta('submissionSnapshot');
  @override
  late final GeneratedColumn<String> submissionSnapshot =
      GeneratedColumn<String>(
        'submission_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _userMeta = const VerificationMeta('user');
  @override
  late final GeneratedColumn<String> user = GeneratedColumn<String>(
    'user',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userSnapshotMeta = const VerificationMeta(
    'userSnapshot',
  );
  @override
  late final GeneratedColumn<String> userSnapshot = GeneratedColumn<String>(
    'user_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipAddressMeta = const VerificationMeta(
    'ipAddress',
  );
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
    'ip_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userAgentMeta = const VerificationMeta(
    'userAgent',
  );
  @override
  late final GeneratedColumn<String> userAgent = GeneratedColumn<String>(
    'user_agent',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
    'signature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signatureParentalMeta = const VerificationMeta(
    'signatureParental',
  );
  @override
  late final GeneratedColumn<String> signatureParental =
      GeneratedColumn<String>(
        'signature_parental',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SignatureMethod, String>
  signatureMethod = GeneratedColumn<String>(
    'signature_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SignatureMethod>($SignaturesTable.$convertersignatureMethod);
  static const VerificationMeta _signedAtMeta = const VerificationMeta(
    'signedAt',
  );
  @override
  late final GeneratedColumn<DateTime> signedAt = GeneratedColumn<DateTime>(
    'signed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _consentVersionMeta = const VerificationMeta(
    'consentVersion',
  );
  @override
  late final GeneratedColumn<int> consentVersion = GeneratedColumn<int>(
    'consent_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revokedReasonMeta = const VerificationMeta(
    'revokedReason',
  );
  @override
  late final GeneratedColumn<String> revokedReason = GeneratedColumn<String>(
    'revoked_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    submissionId,
    submissionSnapshot,
    user,
    userSnapshot,
    ipAddress,
    userAgent,
    signature,
    signatureParental,
    signatureMethod,
    signedAt,
    consentVersion,
    revokedAt,
    revokedReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signatures';
  @override
  VerificationContext validateIntegrity(
    Insertable<Signature> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('submission_id')) {
      context.handle(
        _submissionIdMeta,
        submissionId.isAcceptableOrUnknown(
          data['submission_id']!,
          _submissionIdMeta,
        ),
      );
    }
    if (data.containsKey('submission_snapshot')) {
      context.handle(
        _submissionSnapshotMeta,
        submissionSnapshot.isAcceptableOrUnknown(
          data['submission_snapshot']!,
          _submissionSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_submissionSnapshotMeta);
    }
    if (data.containsKey('user')) {
      context.handle(
        _userMeta,
        user.isAcceptableOrUnknown(data['user']!, _userMeta),
      );
    } else if (isInserting) {
      context.missing(_userMeta);
    }
    if (data.containsKey('user_snapshot')) {
      context.handle(
        _userSnapshotMeta,
        userSnapshot.isAcceptableOrUnknown(
          data['user_snapshot']!,
          _userSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userSnapshotMeta);
    }
    if (data.containsKey('ip_address')) {
      context.handle(
        _ipAddressMeta,
        ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta),
      );
    } else if (isInserting) {
      context.missing(_ipAddressMeta);
    }
    if (data.containsKey('user_agent')) {
      context.handle(
        _userAgentMeta,
        userAgent.isAcceptableOrUnknown(data['user_agent']!, _userAgentMeta),
      );
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    } else if (isInserting) {
      context.missing(_signatureMeta);
    }
    if (data.containsKey('signature_parental')) {
      context.handle(
        _signatureParentalMeta,
        signatureParental.isAcceptableOrUnknown(
          data['signature_parental']!,
          _signatureParentalMeta,
        ),
      );
    }
    if (data.containsKey('signed_at')) {
      context.handle(
        _signedAtMeta,
        signedAt.isAcceptableOrUnknown(data['signed_at']!, _signedAtMeta),
      );
    }
    if (data.containsKey('consent_version')) {
      context.handle(
        _consentVersionMeta,
        consentVersion.isAcceptableOrUnknown(
          data['consent_version']!,
          _consentVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consentVersionMeta);
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    if (data.containsKey('revoked_reason')) {
      context.handle(
        _revokedReasonMeta,
        revokedReason.isAcceptableOrUnknown(
          data['revoked_reason']!,
          _revokedReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {submissionId};
  @override
  Signature map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Signature(
      submissionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}submission_id'],
      )!,
      submissionSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}submission_snapshot'],
      )!,
      user: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user'],
      )!,
      userSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_snapshot'],
      )!,
      ipAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip_address'],
      )!,
      userAgent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_agent'],
      ),
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature'],
      )!,
      signatureParental: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature_parental'],
      ),
      signatureMethod: $SignaturesTable.$convertersignatureMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}signature_method'],
        )!,
      ),
      signedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}signed_at'],
      )!,
      consentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consent_version'],
      )!,
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}revoked_at'],
      ),
      revokedReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revoked_reason'],
      ),
    );
  }

  @override
  $SignaturesTable createAlias(String alias) {
    return $SignaturesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SignatureMethod, String, String>
  $convertersignatureMethod = const EnumNameConverter<SignatureMethod>(
    SignatureMethod.values,
  );
}

class Signature extends DataClass implements Insertable<Signature> {
  final int submissionId;
  final String submissionSnapshot;
  final String user;
  final String userSnapshot;
  final String ipAddress;
  final String? userAgent;
  final String signature;
  final String? signatureParental;
  final SignatureMethod signatureMethod;
  final DateTime signedAt;
  final int consentVersion;
  final DateTime? revokedAt;
  final String? revokedReason;
  const Signature({
    required this.submissionId,
    required this.submissionSnapshot,
    required this.user,
    required this.userSnapshot,
    required this.ipAddress,
    this.userAgent,
    required this.signature,
    this.signatureParental,
    required this.signatureMethod,
    required this.signedAt,
    required this.consentVersion,
    this.revokedAt,
    this.revokedReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['submission_id'] = Variable<int>(submissionId);
    map['submission_snapshot'] = Variable<String>(submissionSnapshot);
    map['user'] = Variable<String>(user);
    map['user_snapshot'] = Variable<String>(userSnapshot);
    map['ip_address'] = Variable<String>(ipAddress);
    if (!nullToAbsent || userAgent != null) {
      map['user_agent'] = Variable<String>(userAgent);
    }
    map['signature'] = Variable<String>(signature);
    if (!nullToAbsent || signatureParental != null) {
      map['signature_parental'] = Variable<String>(signatureParental);
    }
    {
      map['signature_method'] = Variable<String>(
        $SignaturesTable.$convertersignatureMethod.toSql(signatureMethod),
      );
    }
    map['signed_at'] = Variable<DateTime>(signedAt);
    map['consent_version'] = Variable<int>(consentVersion);
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    if (!nullToAbsent || revokedReason != null) {
      map['revoked_reason'] = Variable<String>(revokedReason);
    }
    return map;
  }

  SignaturesCompanion toCompanion(bool nullToAbsent) {
    return SignaturesCompanion(
      submissionId: Value(submissionId),
      submissionSnapshot: Value(submissionSnapshot),
      user: Value(user),
      userSnapshot: Value(userSnapshot),
      ipAddress: Value(ipAddress),
      userAgent: userAgent == null && nullToAbsent
          ? const Value.absent()
          : Value(userAgent),
      signature: Value(signature),
      signatureParental: signatureParental == null && nullToAbsent
          ? const Value.absent()
          : Value(signatureParental),
      signatureMethod: Value(signatureMethod),
      signedAt: Value(signedAt),
      consentVersion: Value(consentVersion),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
      revokedReason: revokedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedReason),
    );
  }

  factory Signature.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Signature(
      submissionId: serializer.fromJson<int>(json['submissionId']),
      submissionSnapshot: serializer.fromJson<String>(
        json['submissionSnapshot'],
      ),
      user: serializer.fromJson<String>(json['user']),
      userSnapshot: serializer.fromJson<String>(json['userSnapshot']),
      ipAddress: serializer.fromJson<String>(json['ipAddress']),
      userAgent: serializer.fromJson<String?>(json['userAgent']),
      signature: serializer.fromJson<String>(json['signature']),
      signatureParental: serializer.fromJson<String?>(
        json['signatureParental'],
      ),
      signatureMethod: $SignaturesTable.$convertersignatureMethod.fromJson(
        serializer.fromJson<String>(json['signatureMethod']),
      ),
      signedAt: serializer.fromJson<DateTime>(json['signedAt']),
      consentVersion: serializer.fromJson<int>(json['consentVersion']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
      revokedReason: serializer.fromJson<String?>(json['revokedReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'submissionId': serializer.toJson<int>(submissionId),
      'submissionSnapshot': serializer.toJson<String>(submissionSnapshot),
      'user': serializer.toJson<String>(user),
      'userSnapshot': serializer.toJson<String>(userSnapshot),
      'ipAddress': serializer.toJson<String>(ipAddress),
      'userAgent': serializer.toJson<String?>(userAgent),
      'signature': serializer.toJson<String>(signature),
      'signatureParental': serializer.toJson<String?>(signatureParental),
      'signatureMethod': serializer.toJson<String>(
        $SignaturesTable.$convertersignatureMethod.toJson(signatureMethod),
      ),
      'signedAt': serializer.toJson<DateTime>(signedAt),
      'consentVersion': serializer.toJson<int>(consentVersion),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
      'revokedReason': serializer.toJson<String?>(revokedReason),
    };
  }

  Signature copyWith({
    int? submissionId,
    String? submissionSnapshot,
    String? user,
    String? userSnapshot,
    String? ipAddress,
    Value<String?> userAgent = const Value.absent(),
    String? signature,
    Value<String?> signatureParental = const Value.absent(),
    SignatureMethod? signatureMethod,
    DateTime? signedAt,
    int? consentVersion,
    Value<DateTime?> revokedAt = const Value.absent(),
    Value<String?> revokedReason = const Value.absent(),
  }) => Signature(
    submissionId: submissionId ?? this.submissionId,
    submissionSnapshot: submissionSnapshot ?? this.submissionSnapshot,
    user: user ?? this.user,
    userSnapshot: userSnapshot ?? this.userSnapshot,
    ipAddress: ipAddress ?? this.ipAddress,
    userAgent: userAgent.present ? userAgent.value : this.userAgent,
    signature: signature ?? this.signature,
    signatureParental: signatureParental.present
        ? signatureParental.value
        : this.signatureParental,
    signatureMethod: signatureMethod ?? this.signatureMethod,
    signedAt: signedAt ?? this.signedAt,
    consentVersion: consentVersion ?? this.consentVersion,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
    revokedReason: revokedReason.present
        ? revokedReason.value
        : this.revokedReason,
  );
  Signature copyWithCompanion(SignaturesCompanion data) {
    return Signature(
      submissionId: data.submissionId.present
          ? data.submissionId.value
          : this.submissionId,
      submissionSnapshot: data.submissionSnapshot.present
          ? data.submissionSnapshot.value
          : this.submissionSnapshot,
      user: data.user.present ? data.user.value : this.user,
      userSnapshot: data.userSnapshot.present
          ? data.userSnapshot.value
          : this.userSnapshot,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      userAgent: data.userAgent.present ? data.userAgent.value : this.userAgent,
      signature: data.signature.present ? data.signature.value : this.signature,
      signatureParental: data.signatureParental.present
          ? data.signatureParental.value
          : this.signatureParental,
      signatureMethod: data.signatureMethod.present
          ? data.signatureMethod.value
          : this.signatureMethod,
      signedAt: data.signedAt.present ? data.signedAt.value : this.signedAt,
      consentVersion: data.consentVersion.present
          ? data.consentVersion.value
          : this.consentVersion,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
      revokedReason: data.revokedReason.present
          ? data.revokedReason.value
          : this.revokedReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Signature(')
          ..write('submissionId: $submissionId, ')
          ..write('submissionSnapshot: $submissionSnapshot, ')
          ..write('user: $user, ')
          ..write('userSnapshot: $userSnapshot, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('userAgent: $userAgent, ')
          ..write('signature: $signature, ')
          ..write('signatureParental: $signatureParental, ')
          ..write('signatureMethod: $signatureMethod, ')
          ..write('signedAt: $signedAt, ')
          ..write('consentVersion: $consentVersion, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('revokedReason: $revokedReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    submissionId,
    submissionSnapshot,
    user,
    userSnapshot,
    ipAddress,
    userAgent,
    signature,
    signatureParental,
    signatureMethod,
    signedAt,
    consentVersion,
    revokedAt,
    revokedReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Signature &&
          other.submissionId == this.submissionId &&
          other.submissionSnapshot == this.submissionSnapshot &&
          other.user == this.user &&
          other.userSnapshot == this.userSnapshot &&
          other.ipAddress == this.ipAddress &&
          other.userAgent == this.userAgent &&
          other.signature == this.signature &&
          other.signatureParental == this.signatureParental &&
          other.signatureMethod == this.signatureMethod &&
          other.signedAt == this.signedAt &&
          other.consentVersion == this.consentVersion &&
          other.revokedAt == this.revokedAt &&
          other.revokedReason == this.revokedReason);
}

class SignaturesCompanion extends UpdateCompanion<Signature> {
  final Value<int> submissionId;
  final Value<String> submissionSnapshot;
  final Value<String> user;
  final Value<String> userSnapshot;
  final Value<String> ipAddress;
  final Value<String?> userAgent;
  final Value<String> signature;
  final Value<String?> signatureParental;
  final Value<SignatureMethod> signatureMethod;
  final Value<DateTime> signedAt;
  final Value<int> consentVersion;
  final Value<DateTime?> revokedAt;
  final Value<String?> revokedReason;
  const SignaturesCompanion({
    this.submissionId = const Value.absent(),
    this.submissionSnapshot = const Value.absent(),
    this.user = const Value.absent(),
    this.userSnapshot = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.userAgent = const Value.absent(),
    this.signature = const Value.absent(),
    this.signatureParental = const Value.absent(),
    this.signatureMethod = const Value.absent(),
    this.signedAt = const Value.absent(),
    this.consentVersion = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.revokedReason = const Value.absent(),
  });
  SignaturesCompanion.insert({
    this.submissionId = const Value.absent(),
    required String submissionSnapshot,
    required String user,
    required String userSnapshot,
    required String ipAddress,
    this.userAgent = const Value.absent(),
    required String signature,
    this.signatureParental = const Value.absent(),
    required SignatureMethod signatureMethod,
    this.signedAt = const Value.absent(),
    required int consentVersion,
    this.revokedAt = const Value.absent(),
    this.revokedReason = const Value.absent(),
  }) : submissionSnapshot = Value(submissionSnapshot),
       user = Value(user),
       userSnapshot = Value(userSnapshot),
       ipAddress = Value(ipAddress),
       signature = Value(signature),
       signatureMethod = Value(signatureMethod),
       consentVersion = Value(consentVersion);
  static Insertable<Signature> custom({
    Expression<int>? submissionId,
    Expression<String>? submissionSnapshot,
    Expression<String>? user,
    Expression<String>? userSnapshot,
    Expression<String>? ipAddress,
    Expression<String>? userAgent,
    Expression<String>? signature,
    Expression<String>? signatureParental,
    Expression<String>? signatureMethod,
    Expression<DateTime>? signedAt,
    Expression<int>? consentVersion,
    Expression<DateTime>? revokedAt,
    Expression<String>? revokedReason,
  }) {
    return RawValuesInsertable({
      if (submissionId != null) 'submission_id': submissionId,
      if (submissionSnapshot != null) 'submission_snapshot': submissionSnapshot,
      if (user != null) 'user': user,
      if (userSnapshot != null) 'user_snapshot': userSnapshot,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (userAgent != null) 'user_agent': userAgent,
      if (signature != null) 'signature': signature,
      if (signatureParental != null) 'signature_parental': signatureParental,
      if (signatureMethod != null) 'signature_method': signatureMethod,
      if (signedAt != null) 'signed_at': signedAt,
      if (consentVersion != null) 'consent_version': consentVersion,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (revokedReason != null) 'revoked_reason': revokedReason,
    });
  }

  SignaturesCompanion copyWith({
    Value<int>? submissionId,
    Value<String>? submissionSnapshot,
    Value<String>? user,
    Value<String>? userSnapshot,
    Value<String>? ipAddress,
    Value<String?>? userAgent,
    Value<String>? signature,
    Value<String?>? signatureParental,
    Value<SignatureMethod>? signatureMethod,
    Value<DateTime>? signedAt,
    Value<int>? consentVersion,
    Value<DateTime?>? revokedAt,
    Value<String?>? revokedReason,
  }) {
    return SignaturesCompanion(
      submissionId: submissionId ?? this.submissionId,
      submissionSnapshot: submissionSnapshot ?? this.submissionSnapshot,
      user: user ?? this.user,
      userSnapshot: userSnapshot ?? this.userSnapshot,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      signature: signature ?? this.signature,
      signatureParental: signatureParental ?? this.signatureParental,
      signatureMethod: signatureMethod ?? this.signatureMethod,
      signedAt: signedAt ?? this.signedAt,
      consentVersion: consentVersion ?? this.consentVersion,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedReason: revokedReason ?? this.revokedReason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (submissionId.present) {
      map['submission_id'] = Variable<int>(submissionId.value);
    }
    if (submissionSnapshot.present) {
      map['submission_snapshot'] = Variable<String>(submissionSnapshot.value);
    }
    if (user.present) {
      map['user'] = Variable<String>(user.value);
    }
    if (userSnapshot.present) {
      map['user_snapshot'] = Variable<String>(userSnapshot.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (userAgent.present) {
      map['user_agent'] = Variable<String>(userAgent.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (signatureParental.present) {
      map['signature_parental'] = Variable<String>(signatureParental.value);
    }
    if (signatureMethod.present) {
      map['signature_method'] = Variable<String>(
        $SignaturesTable.$convertersignatureMethod.toSql(signatureMethod.value),
      );
    }
    if (signedAt.present) {
      map['signed_at'] = Variable<DateTime>(signedAt.value);
    }
    if (consentVersion.present) {
      map['consent_version'] = Variable<int>(consentVersion.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    if (revokedReason.present) {
      map['revoked_reason'] = Variable<String>(revokedReason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SignaturesCompanion(')
          ..write('submissionId: $submissionId, ')
          ..write('submissionSnapshot: $submissionSnapshot, ')
          ..write('user: $user, ')
          ..write('userSnapshot: $userSnapshot, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('userAgent: $userAgent, ')
          ..write('signature: $signature, ')
          ..write('signatureParental: $signatureParental, ')
          ..write('signatureMethod: $signatureMethod, ')
          ..write('signedAt: $signedAt, ')
          ..write('consentVersion: $consentVersion, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('revokedReason: $revokedReason')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $LoginCodesTable loginCodes = $LoginCodesTable(this);
  late final $SubmissionsTable submissions = $SubmissionsTable(this);
  late final $SignaturesTable signatures = $SignaturesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    users,
    loginCodes,
    submissions,
    signatures,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('login_codes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('login_codes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('login_codes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('login_codes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('submissions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('submissions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('submissions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('submissions', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      Value<DateTime> createdAt,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> createdAt,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubmissionsTable, List<Submission>>
  _submissionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.submissions,
    aliasName: $_aliasNameGenerator(db.projects.id, db.submissions.projectId),
  );

  $$SubmissionsTableProcessedTableManager get submissionsRefs {
    final manager = $$SubmissionsTableTableManager(
      $_db,
      $_db.submissions,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_submissionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> submissionsRefs(
    Expression<bool> Function($$SubmissionsTableFilterComposer f) f,
  ) {
    final $$SubmissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.submissions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubmissionsTableFilterComposer(
            $db: $db,
            $table: $db.submissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> submissionsRefs<T extends Object>(
    Expression<T> Function($$SubmissionsTableAnnotationComposer a) f,
  ) {
    final $$SubmissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.submissions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubmissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.submissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({bool submissionsRefs})
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                title: title,
                description: description,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({submissionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (submissionsRefs) db.submissions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (submissionsRefs)
                    await $_getPrefetchedData<
                      Project,
                      $ProjectsTable,
                      Submission
                    >(
                      currentTable: table,
                      referencedTable: $$ProjectsTableReferences
                          ._submissionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProjectsTableReferences(
                        db,
                        table,
                        p0,
                      ).submissionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({bool submissionsRefs})
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String username,
      required String email,
      Value<DateTime> joinedAt,
      Value<List<int>> projects,
      Value<UserRole> role,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> username,
      Value<String> email,
      Value<DateTime> joinedAt,
      Value<List<int>> projects,
      Value<UserRole> role,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LoginCodesTable, List<LoginCode>>
  _loginCodeOfUserTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.loginCodes,
    aliasName: $_aliasNameGenerator(db.users.username, db.loginCodes.user),
  );

  $$LoginCodesTableProcessedTableManager get loginCodeOfUser {
    final manager = $$LoginCodesTableTableManager($_db, $_db.loginCodes).filter(
      (f) => f.user.username.sqlEquals($_itemColumn<String>('username')!),
    );

    final cache = $_typedResult.readTableOrNull(_loginCodeOfUserTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoginCodesTable, List<LoginCode>>
  _loginCodeCreatedByTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.loginCodes,
    aliasName: $_aliasNameGenerator(db.users.username, db.loginCodes.createdBy),
  );

  $$LoginCodesTableProcessedTableManager get loginCodeCreatedBy {
    final manager = $$LoginCodesTableTableManager($_db, $_db.loginCodes).filter(
      (f) => f.createdBy.username.sqlEquals($_itemColumn<String>('username')!),
    );

    final cache = $_typedResult.readTableOrNull(_loginCodeCreatedByTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SubmissionsTable, List<Submission>>
  _submissionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.submissions,
    aliasName: $_aliasNameGenerator(db.users.username, db.submissions.user),
  );

  $$SubmissionsTableProcessedTableManager get submissionsRefs {
    final manager = $$SubmissionsTableTableManager($_db, $_db.submissions)
        .filter(
          (f) => f.user.username.sqlEquals($_itemColumn<String>('username')!),
        );

    final cache = $_typedResult.readTableOrNull(_submissionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<int>, List<int>, String> get projects =>
      $composableBuilder(
        column: $table.projects,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<UserRole, UserRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> loginCodeOfUser(
    Expression<bool> Function($$LoginCodesTableFilterComposer f) f,
  ) {
    final $$LoginCodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.username,
      referencedTable: $db.loginCodes,
      getReferencedColumn: (t) => t.user,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoginCodesTableFilterComposer(
            $db: $db,
            $table: $db.loginCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loginCodeCreatedBy(
    Expression<bool> Function($$LoginCodesTableFilterComposer f) f,
  ) {
    final $$LoginCodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.username,
      referencedTable: $db.loginCodes,
      getReferencedColumn: (t) => t.createdBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoginCodesTableFilterComposer(
            $db: $db,
            $table: $db.loginCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> submissionsRefs(
    Expression<bool> Function($$SubmissionsTableFilterComposer f) f,
  ) {
    final $$SubmissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.username,
      referencedTable: $db.submissions,
      getReferencedColumn: (t) => t.user,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubmissionsTableFilterComposer(
            $db: $db,
            $table: $db.submissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projects => $composableBuilder(
    column: $table.projects,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<int>, String> get projects =>
      $composableBuilder(column: $table.projects, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UserRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  Expression<T> loginCodeOfUser<T extends Object>(
    Expression<T> Function($$LoginCodesTableAnnotationComposer a) f,
  ) {
    final $$LoginCodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.username,
      referencedTable: $db.loginCodes,
      getReferencedColumn: (t) => t.user,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoginCodesTableAnnotationComposer(
            $db: $db,
            $table: $db.loginCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> loginCodeCreatedBy<T extends Object>(
    Expression<T> Function($$LoginCodesTableAnnotationComposer a) f,
  ) {
    final $$LoginCodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.username,
      referencedTable: $db.loginCodes,
      getReferencedColumn: (t) => t.createdBy,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoginCodesTableAnnotationComposer(
            $db: $db,
            $table: $db.loginCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> submissionsRefs<T extends Object>(
    Expression<T> Function($$SubmissionsTableAnnotationComposer a) f,
  ) {
    final $$SubmissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.username,
      referencedTable: $db.submissions,
      getReferencedColumn: (t) => t.user,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubmissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.submissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({
            bool loginCodeOfUser,
            bool loginCodeCreatedBy,
            bool submissionsRefs,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> username = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<List<int>> projects = const Value.absent(),
                Value<UserRole> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                username: username,
                email: email,
                joinedAt: joinedAt,
                projects: projects,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String username,
                required String email,
                Value<DateTime> joinedAt = const Value.absent(),
                Value<List<int>> projects = const Value.absent(),
                Value<UserRole> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                username: username,
                email: email,
                joinedAt: joinedAt,
                projects: projects,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                loginCodeOfUser = false,
                loginCodeCreatedBy = false,
                submissionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (loginCodeOfUser) db.loginCodes,
                    if (loginCodeCreatedBy) db.loginCodes,
                    if (submissionsRefs) db.submissions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (loginCodeOfUser)
                        await $_getPrefetchedData<User, $UsersTable, LoginCode>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._loginCodeOfUserTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).loginCodeOfUser,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.user == item.username,
                              ),
                          typedResults: items,
                        ),
                      if (loginCodeCreatedBy)
                        await $_getPrefetchedData<User, $UsersTable, LoginCode>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._loginCodeCreatedByTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).loginCodeCreatedBy,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.createdBy == item.username,
                              ),
                          typedResults: items,
                        ),
                      if (submissionsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          Submission
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._submissionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).submissionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.user == item.username,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({
        bool loginCodeOfUser,
        bool loginCodeCreatedBy,
        bool submissionsRefs,
      })
    >;
typedef $$LoginCodesTableCreateCompanionBuilder =
    LoginCodesCompanion Function({
      required String code,
      required String user,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });
typedef $$LoginCodesTableUpdateCompanionBuilder =
    LoginCodesCompanion Function({
      Value<String> code,
      Value<String> user,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

final class $$LoginCodesTableReferences
    extends BaseReferences<_$AppDatabase, $LoginCodesTable, LoginCode> {
  $$LoginCodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.loginCodes.user, db.users.username),
  );

  $$UsersTableProcessedTableManager get user {
    final $_column = $_itemColumn<String>('user')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.username.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _createdByTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.loginCodes.createdBy, db.users.username),
  );

  $$UsersTableProcessedTableManager? get createdBy {
    final $_column = $_itemColumn<String>('created_by');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.username.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LoginCodesTableFilterComposer
    extends Composer<_$AppDatabase, $LoginCodesTable> {
  $$LoginCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get user {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.user,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.username,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get createdBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.username,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoginCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $LoginCodesTable> {
  $$LoginCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get user {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.user,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.username,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get createdBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.username,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoginCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoginCodesTable> {
  $$LoginCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get user {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.user,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.username,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get createdBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.username,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoginCodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoginCodesTable,
          LoginCode,
          $$LoginCodesTableFilterComposer,
          $$LoginCodesTableOrderingComposer,
          $$LoginCodesTableAnnotationComposer,
          $$LoginCodesTableCreateCompanionBuilder,
          $$LoginCodesTableUpdateCompanionBuilder,
          (LoginCode, $$LoginCodesTableReferences),
          LoginCode,
          PrefetchHooks Function({bool user, bool createdBy})
        > {
  $$LoginCodesTableTableManager(_$AppDatabase db, $LoginCodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoginCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoginCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoginCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> user = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoginCodesCompanion(
                code: code,
                user: user,
                createdBy: createdBy,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String user,
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoginCodesCompanion.insert(
                code: code,
                user: user,
                createdBy: createdBy,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LoginCodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({user = false, createdBy = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (user) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.user,
                                referencedTable: $$LoginCodesTableReferences
                                    ._userTable(db),
                                referencedColumn: $$LoginCodesTableReferences
                                    ._userTable(db)
                                    .username,
                              )
                              as T;
                    }
                    if (createdBy) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.createdBy,
                                referencedTable: $$LoginCodesTableReferences
                                    ._createdByTable(db),
                                referencedColumn: $$LoginCodesTableReferences
                                    ._createdByTable(db)
                                    .username,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LoginCodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoginCodesTable,
      LoginCode,
      $$LoginCodesTableFilterComposer,
      $$LoginCodesTableOrderingComposer,
      $$LoginCodesTableAnnotationComposer,
      $$LoginCodesTableCreateCompanionBuilder,
      $$LoginCodesTableUpdateCompanionBuilder,
      (LoginCode, $$LoginCodesTableReferences),
      LoginCode,
      PrefetchHooks Function({bool user, bool createdBy})
    >;
typedef $$SubmissionsTableCreateCompanionBuilder =
    SubmissionsCompanion Function({
      Value<int> id,
      required int projectId,
      Value<String?> user,
      Value<SubmissionStatus> status,
      Value<DateTime> submittedAt,
      Value<String?> assetId,
      Value<String?> assetMimeType,
      required String assetBlurHash,
    });
typedef $$SubmissionsTableUpdateCompanionBuilder =
    SubmissionsCompanion Function({
      Value<int> id,
      Value<int> projectId,
      Value<String?> user,
      Value<SubmissionStatus> status,
      Value<DateTime> submittedAt,
      Value<String?> assetId,
      Value<String?> assetMimeType,
      Value<String> assetBlurHash,
    });

final class $$SubmissionsTableReferences
    extends BaseReferences<_$AppDatabase, $SubmissionsTable, Submission> {
  $$SubmissionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.submissions.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.submissions.user, db.users.username),
  );

  $$UsersTableProcessedTableManager? get user {
    final $_column = $_itemColumn<String>('user');
    if ($_column == null) return null;
    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.username.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubmissionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SubmissionStatus, SubmissionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetMimeType => $composableBuilder(
    column: $table.assetMimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetBlurHash => $composableBuilder(
    column: $table.assetBlurHash,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get user {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.user,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.username,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubmissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetMimeType => $composableBuilder(
    column: $table.assetMimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetBlurHash => $composableBuilder(
    column: $table.assetBlurHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get user {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.user,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.username,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubmissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SubmissionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get assetMimeType => $composableBuilder(
    column: $table.assetMimeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assetBlurHash => $composableBuilder(
    column: $table.assetBlurHash,
    builder: (column) => column,
  );

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get user {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.user,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.username,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubmissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubmissionsTable,
          Submission,
          $$SubmissionsTableFilterComposer,
          $$SubmissionsTableOrderingComposer,
          $$SubmissionsTableAnnotationComposer,
          $$SubmissionsTableCreateCompanionBuilder,
          $$SubmissionsTableUpdateCompanionBuilder,
          (Submission, $$SubmissionsTableReferences),
          Submission,
          PrefetchHooks Function({bool projectId, bool user})
        > {
  $$SubmissionsTableTableManager(_$AppDatabase db, $SubmissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubmissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubmissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubmissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String?> user = const Value.absent(),
                Value<SubmissionStatus> status = const Value.absent(),
                Value<DateTime> submittedAt = const Value.absent(),
                Value<String?> assetId = const Value.absent(),
                Value<String?> assetMimeType = const Value.absent(),
                Value<String> assetBlurHash = const Value.absent(),
              }) => SubmissionsCompanion(
                id: id,
                projectId: projectId,
                user: user,
                status: status,
                submittedAt: submittedAt,
                assetId: assetId,
                assetMimeType: assetMimeType,
                assetBlurHash: assetBlurHash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int projectId,
                Value<String?> user = const Value.absent(),
                Value<SubmissionStatus> status = const Value.absent(),
                Value<DateTime> submittedAt = const Value.absent(),
                Value<String?> assetId = const Value.absent(),
                Value<String?> assetMimeType = const Value.absent(),
                required String assetBlurHash,
              }) => SubmissionsCompanion.insert(
                id: id,
                projectId: projectId,
                user: user,
                status: status,
                submittedAt: submittedAt,
                assetId: assetId,
                assetMimeType: assetMimeType,
                assetBlurHash: assetBlurHash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubmissionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false, user = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$SubmissionsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$SubmissionsTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (user) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.user,
                                referencedTable: $$SubmissionsTableReferences
                                    ._userTable(db),
                                referencedColumn: $$SubmissionsTableReferences
                                    ._userTable(db)
                                    .username,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SubmissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubmissionsTable,
      Submission,
      $$SubmissionsTableFilterComposer,
      $$SubmissionsTableOrderingComposer,
      $$SubmissionsTableAnnotationComposer,
      $$SubmissionsTableCreateCompanionBuilder,
      $$SubmissionsTableUpdateCompanionBuilder,
      (Submission, $$SubmissionsTableReferences),
      Submission,
      PrefetchHooks Function({bool projectId, bool user})
    >;
typedef $$SignaturesTableCreateCompanionBuilder =
    SignaturesCompanion Function({
      Value<int> submissionId,
      required String submissionSnapshot,
      required String user,
      required String userSnapshot,
      required String ipAddress,
      Value<String?> userAgent,
      required String signature,
      Value<String?> signatureParental,
      required SignatureMethod signatureMethod,
      Value<DateTime> signedAt,
      required int consentVersion,
      Value<DateTime?> revokedAt,
      Value<String?> revokedReason,
    });
typedef $$SignaturesTableUpdateCompanionBuilder =
    SignaturesCompanion Function({
      Value<int> submissionId,
      Value<String> submissionSnapshot,
      Value<String> user,
      Value<String> userSnapshot,
      Value<String> ipAddress,
      Value<String?> userAgent,
      Value<String> signature,
      Value<String?> signatureParental,
      Value<SignatureMethod> signatureMethod,
      Value<DateTime> signedAt,
      Value<int> consentVersion,
      Value<DateTime?> revokedAt,
      Value<String?> revokedReason,
    });

class $$SignaturesTableFilterComposer
    extends Composer<_$AppDatabase, $SignaturesTable> {
  $$SignaturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get submissionId => $composableBuilder(
    column: $table.submissionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get submissionSnapshot => $composableBuilder(
    column: $table.submissionSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get user => $composableBuilder(
    column: $table.user,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userSnapshot => $composableBuilder(
    column: $table.userSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userAgent => $composableBuilder(
    column: $table.userAgent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signatureParental => $composableBuilder(
    column: $table.signatureParental,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SignatureMethod, SignatureMethod, String>
  get signatureMethod => $composableBuilder(
    column: $table.signatureMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get signedAt => $composableBuilder(
    column: $table.signedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consentVersion => $composableBuilder(
    column: $table.consentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revokedReason => $composableBuilder(
    column: $table.revokedReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SignaturesTableOrderingComposer
    extends Composer<_$AppDatabase, $SignaturesTable> {
  $$SignaturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get submissionId => $composableBuilder(
    column: $table.submissionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get submissionSnapshot => $composableBuilder(
    column: $table.submissionSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get user => $composableBuilder(
    column: $table.user,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userSnapshot => $composableBuilder(
    column: $table.userSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAgent => $composableBuilder(
    column: $table.userAgent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signatureParental => $composableBuilder(
    column: $table.signatureParental,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signatureMethod => $composableBuilder(
    column: $table.signatureMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get signedAt => $composableBuilder(
    column: $table.signedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consentVersion => $composableBuilder(
    column: $table.consentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revokedReason => $composableBuilder(
    column: $table.revokedReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SignaturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SignaturesTable> {
  $$SignaturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get submissionId => $composableBuilder(
    column: $table.submissionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get submissionSnapshot => $composableBuilder(
    column: $table.submissionSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get user =>
      $composableBuilder(column: $table.user, builder: (column) => column);

  GeneratedColumn<String> get userSnapshot => $composableBuilder(
    column: $table.userSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<String> get userAgent =>
      $composableBuilder(column: $table.userAgent, builder: (column) => column);

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  GeneratedColumn<String> get signatureParental => $composableBuilder(
    column: $table.signatureParental,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SignatureMethod, String>
  get signatureMethod => $composableBuilder(
    column: $table.signatureMethod,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get signedAt =>
      $composableBuilder(column: $table.signedAt, builder: (column) => column);

  GeneratedColumn<int> get consentVersion => $composableBuilder(
    column: $table.consentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  GeneratedColumn<String> get revokedReason => $composableBuilder(
    column: $table.revokedReason,
    builder: (column) => column,
  );
}

class $$SignaturesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SignaturesTable,
          Signature,
          $$SignaturesTableFilterComposer,
          $$SignaturesTableOrderingComposer,
          $$SignaturesTableAnnotationComposer,
          $$SignaturesTableCreateCompanionBuilder,
          $$SignaturesTableUpdateCompanionBuilder,
          (
            Signature,
            BaseReferences<_$AppDatabase, $SignaturesTable, Signature>,
          ),
          Signature,
          PrefetchHooks Function()
        > {
  $$SignaturesTableTableManager(_$AppDatabase db, $SignaturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SignaturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SignaturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SignaturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> submissionId = const Value.absent(),
                Value<String> submissionSnapshot = const Value.absent(),
                Value<String> user = const Value.absent(),
                Value<String> userSnapshot = const Value.absent(),
                Value<String> ipAddress = const Value.absent(),
                Value<String?> userAgent = const Value.absent(),
                Value<String> signature = const Value.absent(),
                Value<String?> signatureParental = const Value.absent(),
                Value<SignatureMethod> signatureMethod = const Value.absent(),
                Value<DateTime> signedAt = const Value.absent(),
                Value<int> consentVersion = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<String?> revokedReason = const Value.absent(),
              }) => SignaturesCompanion(
                submissionId: submissionId,
                submissionSnapshot: submissionSnapshot,
                user: user,
                userSnapshot: userSnapshot,
                ipAddress: ipAddress,
                userAgent: userAgent,
                signature: signature,
                signatureParental: signatureParental,
                signatureMethod: signatureMethod,
                signedAt: signedAt,
                consentVersion: consentVersion,
                revokedAt: revokedAt,
                revokedReason: revokedReason,
              ),
          createCompanionCallback:
              ({
                Value<int> submissionId = const Value.absent(),
                required String submissionSnapshot,
                required String user,
                required String userSnapshot,
                required String ipAddress,
                Value<String?> userAgent = const Value.absent(),
                required String signature,
                Value<String?> signatureParental = const Value.absent(),
                required SignatureMethod signatureMethod,
                Value<DateTime> signedAt = const Value.absent(),
                required int consentVersion,
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<String?> revokedReason = const Value.absent(),
              }) => SignaturesCompanion.insert(
                submissionId: submissionId,
                submissionSnapshot: submissionSnapshot,
                user: user,
                userSnapshot: userSnapshot,
                ipAddress: ipAddress,
                userAgent: userAgent,
                signature: signature,
                signatureParental: signatureParental,
                signatureMethod: signatureMethod,
                signedAt: signedAt,
                consentVersion: consentVersion,
                revokedAt: revokedAt,
                revokedReason: revokedReason,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SignaturesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SignaturesTable,
      Signature,
      $$SignaturesTableFilterComposer,
      $$SignaturesTableOrderingComposer,
      $$SignaturesTableAnnotationComposer,
      $$SignaturesTableCreateCompanionBuilder,
      $$SignaturesTableUpdateCompanionBuilder,
      (Signature, BaseReferences<_$AppDatabase, $SignaturesTable, Signature>),
      Signature,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$LoginCodesTableTableManager get loginCodes =>
      $$LoginCodesTableTableManager(_db, _db.loginCodes);
  $$SubmissionsTableTableManager get submissions =>
      $$SubmissionsTableTableManager(_db, _db.submissions);
  $$SignaturesTableTableManager get signatures =>
      $$SignaturesTableTableManager(_db, _db.signatures);
}

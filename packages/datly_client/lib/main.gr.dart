// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:datly_client/main.dart' as _i4;
import 'package:datly_client/screens/error.dart' as _i1;
import 'package:datly_client/screens/list.dart' as _i2;
import 'package:datly_client/screens/login.dart' as _i3;
import 'package:datly_client/screens/submissions.dart' as _i5;
import 'package:datly_client/screens/upload.dart' as _i6;
import 'package:datly_client/screens/validate.dart' as _i7;
import 'package:flutter/foundation.dart' as _i9;

/// generated route for
/// [_i1.ErrorScreen]
class ErrorRoute extends _i8.PageRouteInfo<void> {
  const ErrorRoute({List<_i8.PageRouteInfo>? children})
    : super(ErrorRoute.name, initialChildren: children);

  static const String name = 'ErrorRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i1.ErrorScreen();
    },
  );
}

/// generated route for
/// [_i2.ListProjectsPage]
class ListProjectsRoute extends _i8.PageRouteInfo<void> {
  const ListProjectsRoute({List<_i8.PageRouteInfo>? children})
    : super(ListProjectsRoute.name, initialChildren: children);

  static const String name = 'ListProjectsRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i2.ListProjectsPage();
    },
  );
}

/// generated route for
/// [_i2.ListUsersPage]
class ListUsersRoute extends _i8.PageRouteInfo<void> {
  const ListUsersRoute({List<_i8.PageRouteInfo>? children})
    : super(ListUsersRoute.name, initialChildren: children);

  static const String name = 'ListUsersRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i2.ListUsersPage();
    },
  );
}

/// generated route for
/// [_i3.LoginRegisterParentPage]
class LoginRegisterParentRoute extends _i8.PageRouteInfo<void> {
  const LoginRegisterParentRoute({List<_i8.PageRouteInfo>? children})
    : super(LoginRegisterParentRoute.name, initialChildren: children);

  static const String name = 'LoginRegisterParentRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i3.LoginRegisterParentPage();
    },
  );
}

/// generated route for
/// [_i3.LoginScreen]
class LoginRoute extends _i8.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i9.Key? key,
    String? initialEmail,
    List<_i8.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, initialEmail: initialEmail),
         rawQueryParams: {'email': initialEmail},
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () =>
            LoginRouteArgs(initialEmail: queryParams.optString('email')),
      );
      return _i3.LoginScreen(key: args.key, initialEmail: args.initialEmail);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.initialEmail});

  final _i9.Key? key;

  final String? initialEmail;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, initialEmail: $initialEmail}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key && initialEmail == other.initialEmail;
  }

  @override
  int get hashCode => key.hashCode ^ initialEmail.hashCode;
}

/// generated route for
/// [_i4.MainScreen]
class MainRoute extends _i8.PageRouteInfo<void> {
  const MainRoute({List<_i8.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i4.MainScreen();
    },
  );
}

/// generated route for
/// [_i3.RegisterScreen]
class RegisterRoute extends _i8.PageRouteInfo<void> {
  const RegisterRoute({List<_i8.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i3.RegisterScreen();
    },
  );
}

/// generated route for
/// [_i5.SubmissionsPage]
class SubmissionsRoute extends _i8.PageRouteInfo<SubmissionsRouteArgs> {
  SubmissionsRoute({
    _i9.Key? key,
    String? user,
    String? project,
    int page = 1,
    List<_i8.PageRouteInfo>? children,
  }) : super(
         SubmissionsRoute.name,
         args: SubmissionsRouteArgs(
           key: key,
           user: user,
           project: project,
           page: page,
         ),
         rawQueryParams: {'user': user, 'project': project, 'page': page},
         initialChildren: children,
       );

  static const String name = 'SubmissionsRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<SubmissionsRouteArgs>(
        orElse: () => SubmissionsRouteArgs(
          user: queryParams.optString('user'),
          project: queryParams.optString('project'),
          page: queryParams.getInt('page', 1),
        ),
      );
      return _i5.SubmissionsPage(
        key: args.key,
        user: args.user,
        project: args.project,
        page: args.page,
      );
    },
  );
}

class SubmissionsRouteArgs {
  const SubmissionsRouteArgs({
    this.key,
    this.user,
    this.project,
    this.page = 1,
  });

  final _i9.Key? key;

  final String? user;

  final String? project;

  final int page;

  @override
  String toString() {
    return 'SubmissionsRouteArgs{key: $key, user: $user, project: $project, page: $page}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SubmissionsRouteArgs) return false;
    return key == other.key &&
        user == other.user &&
        project == other.project &&
        page == other.page;
  }

  @override
  int get hashCode =>
      key.hashCode ^ user.hashCode ^ project.hashCode ^ page.hashCode;
}

/// generated route for
/// [_i6.UploadPage]
class UploadRoute extends _i8.PageRouteInfo<void> {
  const UploadRoute({List<_i8.PageRouteInfo>? children})
    : super(UploadRoute.name, initialChildren: children);

  static const String name = 'UploadRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i6.UploadPage();
    },
  );
}

/// generated route for
/// [_i4.UploadValidateParentPage]
class UploadValidateParentRoute extends _i8.PageRouteInfo<void> {
  const UploadValidateParentRoute({List<_i8.PageRouteInfo>? children})
    : super(UploadValidateParentRoute.name, initialChildren: children);

  static const String name = 'UploadValidateParentRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i4.UploadValidateParentPage();
    },
  );
}

/// generated route for
/// [_i7.ValidatePage]
class ValidateRoute extends _i8.PageRouteInfo<void> {
  const ValidateRoute({List<_i8.PageRouteInfo>? children})
    : super(ValidateRoute.name, initialChildren: children);

  static const String name = 'ValidateRoute';

  static _i8.PageInfo page = _i8.PageInfo(
    name,
    builder: (data) {
      return const _i7.ValidatePage();
    },
  );
}

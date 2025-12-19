// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:datly_client/main.dart' as _i4;
import 'package:datly_client/screens/error.dart' as _i1;
import 'package:datly_client/screens/list.dart' as _i2;
import 'package:datly_client/screens/login.dart' as _i3;
import 'package:datly_client/screens/submissions.dart' as _i5;
import 'package:datly_client/screens/upload.dart' as _i6;
import 'package:flutter/material.dart' as _i8;

/// generated route for
/// [_i1.ErrorScreen]
class ErrorRoute extends _i7.PageRouteInfo<void> {
  const ErrorRoute({List<_i7.PageRouteInfo>? children})
    : super(ErrorRoute.name, initialChildren: children);

  static const String name = 'ErrorRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i1.ErrorScreen();
    },
  );
}

/// generated route for
/// [_i2.ListProjectsPage]
class ListProjectsRoute extends _i7.PageRouteInfo<void> {
  const ListProjectsRoute({List<_i7.PageRouteInfo>? children})
    : super(ListProjectsRoute.name, initialChildren: children);

  static const String name = 'ListProjectsRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.ListProjectsPage();
    },
  );
}

/// generated route for
/// [_i2.ListUsersPage]
class ListUsersRoute extends _i7.PageRouteInfo<void> {
  const ListUsersRoute({List<_i7.PageRouteInfo>? children})
    : super(ListUsersRoute.name, initialChildren: children);

  static const String name = 'ListUsersRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.ListUsersPage();
    },
  );
}

/// generated route for
/// [_i3.LoginScreen]
class LoginRoute extends _i7.PageRouteInfo<void> {
  const LoginRoute({List<_i7.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.LoginScreen();
    },
  );
}

/// generated route for
/// [_i4.MainScreen]
class MainRoute extends _i7.PageRouteInfo<void> {
  const MainRoute({List<_i7.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.MainScreen();
    },
  );
}

/// generated route for
/// [_i5.SubmissionsPage]
class SubmissionsRoute extends _i7.PageRouteInfo<SubmissionsRouteArgs> {
  SubmissionsRoute({
    _i8.Key? key,
    String? user,
    String? project,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         SubmissionsRoute.name,
         args: SubmissionsRouteArgs(key: key, user: user, project: project),
         rawQueryParams: {'user': user, 'project': project},
         initialChildren: children,
       );

  static const String name = 'SubmissionsRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<SubmissionsRouteArgs>(
        orElse: () => SubmissionsRouteArgs(
          user: queryParams.optString('user'),
          project: queryParams.optString('project'),
        ),
      );
      return _i5.SubmissionsPage(
        key: args.key,
        user: args.user,
        project: args.project,
      );
    },
  );
}

class SubmissionsRouteArgs {
  const SubmissionsRouteArgs({this.key, this.user, this.project});

  final _i8.Key? key;

  final String? user;

  final String? project;

  @override
  String toString() {
    return 'SubmissionsRouteArgs{key: $key, user: $user, project: $project}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SubmissionsRouteArgs) return false;
    return key == other.key && user == other.user && project == other.project;
  }

  @override
  int get hashCode => key.hashCode ^ user.hashCode ^ project.hashCode;
}

/// generated route for
/// [_i6.UploadPage]
class UploadRoute extends _i7.PageRouteInfo<void> {
  const UploadRoute({List<_i7.PageRouteInfo>? children})
    : super(UploadRoute.name, initialChildren: children);

  static const String name = 'UploadRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.UploadPage();
    },
  );
}

// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:datly_client/api.dart' as _i11;
import 'package:datly_client/main.dart' as _i4;
import 'package:datly_client/screens/error.dart' as _i1;
import 'package:datly_client/screens/list.dart' as _i2;
import 'package:datly_client/screens/login.dart' as _i3;
import 'package:datly_client/screens/submissions.dart' as _i6;
import 'package:datly_client/screens/terms.dart' as _i5;
import 'package:datly_client/screens/upload.dart' as _i7;
import 'package:datly_client/screens/validate.dart' as _i8;
import 'package:flutter/foundation.dart' as _i10;

/// generated route for
/// [_i1.ErrorScreen]
class ErrorRoute extends _i9.PageRouteInfo<void> {
  const ErrorRoute({List<_i9.PageRouteInfo>? children})
    : super(ErrorRoute.name, initialChildren: children);

  static const String name = 'ErrorRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.ErrorScreen();
    },
  );
}

/// generated route for
/// [_i2.ListCategoriesPage]
class ListCategoriesRoute extends _i9.PageRouteInfo<void> {
  const ListCategoriesRoute({List<_i9.PageRouteInfo>? children})
    : super(ListCategoriesRoute.name, initialChildren: children);

  static const String name = 'ListCategoriesRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.ListCategoriesPage();
    },
  );
}

/// generated route for
/// [_i2.ListProjectsPage]
class ListProjectsRoute extends _i9.PageRouteInfo<void> {
  const ListProjectsRoute({List<_i9.PageRouteInfo>? children})
    : super(ListProjectsRoute.name, initialChildren: children);

  static const String name = 'ListProjectsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.ListProjectsPage();
    },
  );
}

/// generated route for
/// [_i2.ListUsersPage]
class ListUsersRoute extends _i9.PageRouteInfo<void> {
  const ListUsersRoute({List<_i9.PageRouteInfo>? children})
    : super(ListUsersRoute.name, initialChildren: children);

  static const String name = 'ListUsersRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.ListUsersPage();
    },
  );
}

/// generated route for
/// [_i3.LoginRegisterParentPage]
class LoginRegisterParentRoute extends _i9.PageRouteInfo<void> {
  const LoginRegisterParentRoute({List<_i9.PageRouteInfo>? children})
    : super(LoginRegisterParentRoute.name, initialChildren: children);

  static const String name = 'LoginRegisterParentRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.LoginRegisterParentPage();
    },
  );
}

/// generated route for
/// [_i3.LoginScreen]
class LoginRoute extends _i9.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i10.Key? key,
    String? initialEmail,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, initialEmail: initialEmail),
         rawQueryParams: {'email': initialEmail},
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i9.PageInfo page = _i9.PageInfo(
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

  final _i10.Key? key;

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
class MainRoute extends _i9.PageRouteInfo<void> {
  const MainRoute({List<_i9.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.MainScreen();
    },
  );
}

/// generated route for
/// [_i5.MarkdownDialogImprintPage]
class MarkdownDialogImprintRoute extends _i9.PageRouteInfo<void> {
  const MarkdownDialogImprintRoute({List<_i9.PageRouteInfo>? children})
    : super(MarkdownDialogImprintRoute.name, initialChildren: children);

  static const String name = 'MarkdownDialogImprintRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.MarkdownDialogImprintPage();
    },
  );
}

/// generated route for
/// [_i5.MarkdownDialogPrivacyPolicyPage]
class MarkdownDialogPrivacyPolicyRoute extends _i9.PageRouteInfo<void> {
  const MarkdownDialogPrivacyPolicyRoute({List<_i9.PageRouteInfo>? children})
    : super(MarkdownDialogPrivacyPolicyRoute.name, initialChildren: children);

  static const String name = 'MarkdownDialogPrivacyPolicyRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.MarkdownDialogPrivacyPolicyPage();
    },
  );
}

/// generated route for
/// [_i5.MarkdownDialogTermsOfServicePage]
class MarkdownDialogTermsOfServiceRoute extends _i9.PageRouteInfo<void> {
  const MarkdownDialogTermsOfServiceRoute({List<_i9.PageRouteInfo>? children})
    : super(MarkdownDialogTermsOfServiceRoute.name, initialChildren: children);

  static const String name = 'MarkdownDialogTermsOfServiceRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.MarkdownDialogTermsOfServicePage();
    },
  );
}

/// generated route for
/// [_i3.RegisterScreen]
class RegisterRoute extends _i9.PageRouteInfo<void> {
  const RegisterRoute({List<_i9.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.RegisterScreen();
    },
  );
}

/// generated route for
/// [_i6.SubmissionDetailsPage]
class SubmissionDetailsRoute
    extends _i9.PageRouteInfo<SubmissionDetailsRouteArgs> {
  SubmissionDetailsRoute({
    _i10.Key? key,
    required int submissionId,
    _i11.SubmissionData? data,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         SubmissionDetailsRoute.name,
         args: SubmissionDetailsRouteArgs(
           key: key,
           submissionId: submissionId,
           data: data,
         ),
         rawPathParams: {'id': submissionId},
         initialChildren: children,
       );

  static const String name = 'SubmissionDetailsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<SubmissionDetailsRouteArgs>(
        orElse: () =>
            SubmissionDetailsRouteArgs(submissionId: pathParams.getInt('id')),
      );
      return _i6.SubmissionDetailsPage(
        key: args.key,
        submissionId: args.submissionId,
        data: args.data,
      );
    },
  );
}

class SubmissionDetailsRouteArgs {
  const SubmissionDetailsRouteArgs({
    this.key,
    required this.submissionId,
    this.data,
  });

  final _i10.Key? key;

  final int submissionId;

  final _i11.SubmissionData? data;

  @override
  String toString() {
    return 'SubmissionDetailsRouteArgs{key: $key, submissionId: $submissionId, data: $data}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SubmissionDetailsRouteArgs) return false;
    return key == other.key &&
        submissionId == other.submissionId &&
        data == other.data;
  }

  @override
  int get hashCode => key.hashCode ^ submissionId.hashCode ^ data.hashCode;
}

/// generated route for
/// [_i6.SubmissionsPage]
class SubmissionsRoute extends _i9.PageRouteInfo<SubmissionsRouteArgs> {
  SubmissionsRoute({
    _i10.Key? key,
    String? user,
    String? project,
    int page = 1,
    List<_i9.PageRouteInfo>? children,
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

  static _i9.PageInfo page = _i9.PageInfo(
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
      return _i6.SubmissionsPage(
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

  final _i10.Key? key;

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
/// [_i7.UploadPage]
class UploadRoute extends _i9.PageRouteInfo<void> {
  const UploadRoute({List<_i9.PageRouteInfo>? children})
    : super(UploadRoute.name, initialChildren: children);

  static const String name = 'UploadRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i7.UploadPage();
    },
  );
}

/// generated route for
/// [_i4.UploadValidateParentPage]
class UploadValidateParentRoute extends _i9.PageRouteInfo<void> {
  const UploadValidateParentRoute({List<_i9.PageRouteInfo>? children})
    : super(UploadValidateParentRoute.name, initialChildren: children);

  static const String name = 'UploadValidateParentRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.UploadValidateParentPage();
    },
  );
}

/// generated route for
/// [_i8.ValidatePage]
class ValidateRoute extends _i9.PageRouteInfo<void> {
  const ValidateRoute({List<_i9.PageRouteInfo>? children})
    : super(ValidateRoute.name, initialChildren: children);

  static const String name = 'ValidateRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i8.ValidatePage();
    },
  );
}

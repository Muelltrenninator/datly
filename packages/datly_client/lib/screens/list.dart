import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../registry.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/multi_prompt_dialog.dart';
import '../widgets/multiple_choice_dialog.dart';
import '../widgets/prompt_dialog.dart';
import '../widgets/status_modal.dart';
import '../widgets/title_bar.dart';

@RoutePage()
class ListUsersPage extends StatelessWidget {
  const ListUsersPage({super.key});
  @override
  Widget build(BuildContext context) => const ListScreen(isProjects: false);
}

@RoutePage()
class ListProjectsPage extends StatelessWidget {
  const ListProjectsPage({super.key});
  @override
  Widget build(BuildContext context) => const ListScreen(isProjects: true);
}

class ListScreen extends StatefulWidget {
  final bool isProjects;
  const ListScreen({super.key, required this.isProjects});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  http.Response? response;
  bool error = false;
  bool optionLeftAligned = false;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() {
    response = null;
    if (mounted) setState(() {});

    if (!AuthManager.instance.authenticatedUserIsAdmin && widget.isProjects) {
      error = true;
      if (mounted) setState(() {});
      return;
    }

    try {
      AuthManager.instance
          .fetch(
            http.Request(
              "GET",
              widget.isProjects
                  ? Uri.parse("${ApiManager.baseUri}/projects/list")
                  : Uri.parse("${ApiManager.baseUri}/users/list"),
            ),
          )
          .then((value) {
            if (value == null ||
                value.statusCode != 200 ||
                !(value.headers["content-type"]?.startsWith(
                      "application/json",
                    ) ??
                    false)) {
              error = true;
              if (mounted) setState(() {});
              return;
            }

            response = value;
            if (mounted) setState(() {});
          });
    } catch (_) {
      error = true;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminOptions = (widget.isProjects
        ? [
            MenuItemButton(
              onPressed: () async {
                var inputRaw = await showMultiPromptDialog(
                  context: context,
                  title: "Create Project",
                  description:
                      "Creates a new project with the specified information.",
                  prompts: {
                    "title": MultiPromptPrompt(
                      label: "Title",
                      validator: (v) =>
                          v.isEmpty ? "Title cannot be empty." : null,
                      capitalization: TextCapitalization.words,
                    ),
                    "description": MultiPromptPrompt(
                      label: "Description",
                      placeholder: "Training data for a model to detect…",
                      maxLength: 256,
                      maxLines: 4,
                    ),
                  },
                );
                if (inputRaw == null) return;
                final input = Map<String, dynamic>.from(inputRaw);

                input["description"] = (input["description"]! as String).trim();
                if (input["description"]!.isEmpty) {
                  input["description"] = null;
                }

                final response = await AuthManager.instance.fetch(
                  http.Request(
                      "POST",
                      Uri.parse("${ApiManager.baseUri}/projects"),
                    )
                    ..headers["Content-Type"] = "application/json"
                    ..body = jsonEncode(input),
                );
                if (response?.statusCode == 201) fetch();
              },
              leadingIcon: Icon(Icons.add),
              child: Text("Create Project"),
            ),
          ]
        : [
            MenuItemButton(
              onPressed: () async {
                final allProjectsFuture = AuthManager.instance.fetch(
                  http.Request(
                    "GET",
                    Uri.parse("${ApiManager.baseUri}/projects/list"),
                  ),
                );
                var inputRaw = await showMultiPromptDialog(
                  context: context,
                  title: "Create User",
                  description:
                      "Creates a new user with the specified information and generates a login code for them. Meaning this should only be used during direct user onboarding.",
                  prompts: {
                    "username": MultiPromptPrompt(
                      label: "Username",
                      validator: (v) =>
                          v.isEmpty ? "Username cannot be empty." : null,
                      capitalization: TextCapitalization.none,
                      autofillHints: [],
                    ),
                    "email": MultiPromptPrompt(
                      label: "Email Address",
                      placeholder: "user@example.com",
                      validator: (v) => !validateEmail(v)
                          ? "Not a valid email address."
                          : null,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: [],
                    ),
                    "role": MultiPromptPrompt(
                      label: "Role",
                      placeholder: "user, admin",
                      content: "user",
                      validator: (value) => !["user", "admin"].contains(value)
                          ? "Role must be one of: user, admin"
                          : null,
                      capitalization: TextCapitalization.none,
                    ),
                    "locale": MultiPromptPrompt(
                      label: "Account Locale",
                      placeholder: "en, de, …",
                      content: "en",
                      validator: (value) =>
                          !AppLocalizations.supportedLocales
                              .map((e) => e.languageCode)
                              .contains(value)
                          ? "Locale must be one of: ${AppLocalizations.supportedLocales.map((e) => e.languageCode).join(", ")}"
                          : null,
                      capitalization: TextCapitalization.none,
                    ),
                  },
                );
                if (inputRaw == null) return;
                final input = Map<String, dynamic>.from(inputRaw)
                  ..["captcha"] = null;

                final allProjectsResponse = await allProjectsFuture;
                if (allProjectsResponse == null ||
                    allProjectsResponse.statusCode != 200 ||
                    !(allProjectsResponse.headers["content-type"]?.startsWith(
                          "application/json",
                        ) ??
                        false)) {
                  return;
                }
                final allProjects =
                    (jsonDecode(allProjectsResponse.body) as List<dynamic>)
                        .map(
                          (e) =>
                              ProjectData.fromJson(e as Map<String, dynamic>),
                        )
                        .toList();
                if (allProjects.isEmpty) {
                  input["projects"] = [];
                } else {
                  if (!context.mounted) return;
                  final selectedProjects =
                      (await showMultipleChoiceDialog(
                              context: context,
                              title: "Assign Projects",
                              description:
                                  "Select the projects to assign to this user.",
                              initialValue: allProjects.length == 1
                                  ? allProjects
                                  : null,
                              items: allProjects,
                              titleGenerator: (item) => item.title,
                              subtitleGenerator: (item) => item.description,
                              allowEmptySelection: true,
                            ) ??
                            [])
                        ..sort((a, b) => a.id.compareTo(b.id));
                  input["projects"] = selectedProjects
                      .map((p) => p.id)
                      .toList();
                }

                final username = input.remove("username");
                final response = await AuthManager.instance.fetch(
                  http.Request(
                      "POST",
                      Uri.parse("${ApiManager.baseUri}/user/$username"),
                    )
                    ..headers["Content-Type"] = "application/json"
                    ..body = jsonEncode(input),
                );
                if (response?.statusCode == 201) fetch();
              },
              leadingIcon: Icon(Icons.add),
              child: Text("Create User"),
            ),
          ]);
    adminOptions.add(
      MenuItemButton(
        onPressed: () => fetch(),
        leadingIcon: Icon(Icons.refresh),
        child: Text("Refetch Data"),
      ),
    );

    final windowSizeClass = WindowSizeClass.of(context);
    return Stack(
      children: [
        !error
            ? response != null
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: windowSizeClass > WindowSizeClass.compact
                            ? EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: 8,
                                bottom: 24,
                              )
                            : EdgeInsets.all(8),
                        child: Builder(
                          builder: (context) {
                            List data;
                            try {
                              data = jsonDecode(response!.body) as List;
                            } catch (_) {
                              return Center(
                                child: Icon(Icons.error_outline, size: 48),
                              );
                            }

                            if (data.isEmpty) {
                              return Text(
                                "No data.",
                                style: DefaultTextStyle.of(context).style
                                    .copyWith(
                                      color: Theme.of(context).disabledColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                              );
                            }

                            return SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  data.length,
                                  (i) => ListWidget(
                                    key: ValueKey(
                                      widget.isProjects
                                          ? "project_${data[i]["id"]}"
                                          : "user_${data[i]["username"]}",
                                    ),
                                    data: data[i],
                                    isProject: widget.isProjects,
                                    onDelete: fetch,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Center(child: CircularProgressIndicator())
            : Center(child: Icon(Icons.error_outline, size: 48)),
        if (AuthManager.instance.authenticatedUserIsAdmin) ...[
          AnimatedAlign(
            duration: Durations.medium1,
            curve: Curves.easeInOutCubic,
            alignment: optionLeftAligned
                ? Alignment.topLeft
                : Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, left: 12, right: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 512),
                child: MenuAnchor(
                  menuChildren: adminOptions,
                  builder: (context, controller, _) => Card.outlined(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: controller.isOpen
                          ? controller.close
                          : controller.open,
                      onLongPress: () {
                        optionLeftAligned = !optionLeftAligned;
                        if (mounted) setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.admin_panel_settings),
                            SizedBox(width: 8),
                            Text(
                              "Options",
                              style: TextTheme.of(context).titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ListWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isProject;
  final VoidCallback onDelete;

  const ListWidget({
    super.key,
    required this.data,
    required this.isProject,
    required this.onDelete,
  });

  @override
  State<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  ProjectData? project;
  UserData? user;

  final List<ProjectData> userAssignedProjects = [];
  final List<int> allProjectIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.isProject) {
      project = ProjectData.fromJson(widget.data);
    } else {
      user = UserData.fromJson(widget.data);
      _preloadUserProjects();
      if (AuthManager.instance.authenticatedUserIsAdmin) {
        () async {
          final allProjectsResponse = await AuthManager.instance.fetch(
            http.Request(
              "GET",
              Uri.parse("${ApiManager.baseUri}/projects/list"),
            ),
          );
          if (allProjectsResponse == null ||
              allProjectsResponse.statusCode != 200 ||
              !(allProjectsResponse.headers["content-type"]?.startsWith(
                    "application/json",
                  ) ??
                  false)) {
            return;
          }

          allProjectIds.addAll(
            (jsonDecode(allProjectsResponse.body) as List<dynamic>).map((e) {
              final projectId = ProjectData.fromJson(
                e as Map<String, dynamic>,
              ).id;
              ProjectRegistry.instance.get(projectId);
              return projectId;
            }),
          );
          if (mounted) setState(() {});
        }.call();
      }
    }
  }

  Future<void> _preloadUserProjects() async {
    userAssignedProjects.clear();
    userAssignedProjects.addAll(
      (await Future.wait<ProjectData?>(
        (user?.projects ?? []).map((p) => ProjectRegistry.instance.get(p)),
      )).whereType<ProjectData>(),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final windowSizeClass = WindowSizeClass.of(context);
    final submissionRoute = SubmissionsRoute(
      user: widget.isProject ? null : user!.username,
      project: widget.isProject ? project!.id.toString() : null,
    );

    final showSubmissionsButton =
        context.router.current.route.name != submissionRoute.routeName ||
        context.router.current.queryParams != submissionRoute.queryParams;
    final showDeleteButton = widget.isProject
        ? true
        : AuthManager.instance.authenticatedUser?.username != user?.username;

    void delete() async {
      if (!await showConfirmationDialog(
            context: context,
            title: "Delete ${widget.isProject ? "Project" : "User"}",
            description:
                "Are you sure you want to delete this ${widget.isProject ? "project" : "user"}? This action cannot be undone.",
          ) ||
          !context.mounted) {
        return;
      }

      final completer = Completer<void>();
      http.Response? response;
      showStatusModal(
        context: context,
        completer: completer,
        failureDetailsGenerator: () =>
            responseFailureDetailsGenerator(response),
      );

      try {
        response = await AuthManager.instance.fetch(
          http.Request("DELETE", uri),
        );
        if (response == null || response.statusCode != 200) {
          completer.completeError("");
          return;
        }
      } catch (_) {
        completer.completeError("");
        return;
      }

      widget.onDelete();
      completer.complete();
    }

    void projectSetDescription() async {
      final newDescription = await showPromptDialog(
        context: context,
        title: "Set Description",
        content: project?.description,
        placeholder: "Training data for a model to detect…",
        maxLength: 256,
        maxLines: 4,
      );
      if (newDescription != null &&
          newDescription != project?.description &&
          context.mounted) {
        final completer = Completer<void>();
        http.Response? response;
        showStatusModal(
          context: context,
          completer: completer,
          failureDetailsGenerator: () =>
              responseFailureDetailsGenerator(response),
        );

        try {
          response = await AuthManager.instance.fetch(
            http.Request("PUT", uri)
              ..headers["Content-Type"] = "application/json"
              ..body = jsonEncode({
                "title": null,
                "description": newDescription,
              }),
          );
          if (response == null || response.statusCode != 200) {
            completer.completeError("");
            return;
          }
        } catch (_) {
          completer.completeError("");
          return;
        }

        project?.description = newDescription;
        if (mounted) setState(() {});
        completer.complete();
      }
    }

    void userSetEmail() async {
      final newEmail = await showPromptDialog(
        context: context,
        title: "Set Email Address",
        content: user?.email,
        quickValidator: (e) => validateEmail(e),
        keyboardType: TextInputType.emailAddress,
        autofillHints: [],
      );
      if (newEmail != null && newEmail != user?.email && context.mounted) {
        final completer = Completer<void>();
        http.Response? response;
        showStatusModal(
          context: context,
          completer: completer,
          failureDetailsGenerator: () =>
              responseFailureDetailsGenerator(response),
        );

        try {
          response = await AuthManager.instance.fetch(
            http.Request("PUT", uri)
              ..headers["Content-Type"] = "application/json"
              ..body = jsonEncode({
                "password": null,
                "email": newEmail,
                "projects": null,
                "role": null,
              }),
          );
          if (response == null || response.statusCode != 200) {
            completer.completeError("");
            return;
          }
        } catch (_) {
          completer.completeError("");
          return;
        }

        user?.email = newEmail;
        if (mounted) setState(() {});
        completer.complete();
      }
    }

    void userSetProjects() async {
      final items = (await Future.wait(
        allProjectIds.map((id) => ProjectRegistry.instance.get(id)),
      )).whereType<ProjectData>();
      if (!context.mounted) return;
      final newProjects = (await showMultipleChoiceDialog(
        context: context,
        title: "Change Assigned Projects",
        initialValue: userAssignedProjects,
        items: items,
        titleGenerator: (item) => item.title,
        subtitleGenerator: (item) => item.description,
        allowEmptySelection: true,
      ));
      if (newProjects != null &&
          (newProjects..sort((a, b) => a.id.compareTo(b.id))).map(
                (p) => p.id,
              ) !=
              user?.projects &&
          context.mounted) {
        final completer = Completer<void>();
        http.Response? response;
        showStatusModal(
          context: context,
          completer: completer,
          failureDetailsGenerator: () =>
              responseFailureDetailsGenerator(response),
        );

        try {
          response = await AuthManager.instance.fetch(
            http.Request("PUT", uri)
              ..headers["Content-Type"] = "application/json"
              ..body = jsonEncode({
                "password": null,
                "email": null,
                "projects": newProjects.map((p) => p.id).toList(),
                "role": null,
              }),
          );
          if (response == null || response.statusCode != 200) {
            completer.completeError("");
            return;
          }
        } catch (_) {
          completer.completeError("");
          return;
        }

        user?.projects = newProjects.map((p) => p.id).toList();
        await _preloadUserProjects();
        if (mounted) setState(() {});
        completer.complete();
      }
    }

    void userDisableReenable() async {
      if (user!.disabled == null) {
        final reason = await showPromptDialog(
          context: context,
          title: "Ban user",
          description:
              "Provide a reason for disabling this user. This will be shown to the user.\nThe user will be notified via email. This should only be used for banning users that have violated the terms of service.",
          placeholder: "Violated Par. 4 of the ToS",
          maxLines: 3,
        );
        if (reason == null || !context.mounted) return;

        final completer = Completer<void>();
        http.Response? response;
        showStatusModal(
          context: context,
          completer: completer,
          failureDetailsGenerator: () =>
              responseFailureDetailsGenerator(response),
        );

        try {
          response = await AuthManager.instance.fetch(
            http.Request("POST", Uri.parse("$uri/disable"))
              ..headers["Content-Type"] = "application/json"
              ..body = jsonEncode({"reason": reason}),
          );
          if (response == null || response.statusCode != 200) {
            return;
          }
        } catch (_) {
          completer.completeError("");
          return;
        }

        user?.disabled = reason;
        if (mounted) setState(() {});
        completer.complete();
      } else {
        if (!await showConfirmationDialog(
              context: context,
              title: "Reenable user",
              description:
                  "Are you sure you want to reenable this user? This will allow them to log in again. The user will be notified via email.",
            ) ||
            !context.mounted) {
          return;
        }

        final completer = Completer<void>();
        http.Response? response;
        showStatusModal(
          context: context,
          completer: completer,
          failureDetailsGenerator: () =>
              responseFailureDetailsGenerator(response),
        );

        try {
          response = await AuthManager.instance.fetch(
            http.Request("POST", Uri.parse("$uri/reenable")),
          );
          if (response == null || response.statusCode != 200) {
            completer.completeError("");
            return;
          }
        } catch (_) {
          completer.completeError("");
          return;
        }

        user?.disabled = null;
        if (mounted) setState(() {});
        completer.complete();
      }
    }

    void userSetPassword() async {
      if (!await showConfirmationDialog(
            context: context,
            title: "Send new password",
            description:
                "Are you sure you want to reset this user's password? This will send an email to the user with a new temporary password. The current password will become invalid. This action cannot be undone.",
          ) ||
          !context.mounted) {
        return;
      }

      final completer = Completer<void>();
      http.Response? response;
      showStatusModal(
        context: context,
        completer: completer,
        failureDetailsGenerator: () =>
            responseFailureDetailsGenerator(response),
      );

      try {
        response = await AuthManager.instance.fetch(
          http.Request("POST", Uri.parse("$uri/passwordReset")),
        );
        if (response == null || response.statusCode != 200) {
          completer.completeError("");
          return;
        }
      } catch (_) {
        completer.completeError("");
        return;
      }
      completer.complete();
    }

    final card = SizedBox(
      width: windowSizeClass > WindowSizeClass.compact ? 224 : null,
      child: Card.filled(
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: widget.isProject
                      ? [
                          Chip(
                            avatar: Icon(Icons.title_outlined),
                            label: Text(project?.title.toTitleCase() ?? "–"),
                          ),
                          Chip(
                            avatar: Icon(Icons.description_outlined),
                            label: Text(
                              project?.description ?? "–",
                              maxLines: 5,
                            ),
                            deleteIcon: Icon(Icons.edit),
                            onDeleted:
                                AuthManager.instance.authenticatedUserIsAdmin
                                ? projectSetDescription
                                : null,
                          ),
                          Chip(
                            avatar: Icon(Icons.event),
                            label: Text(
                              project != null
                                  ? dateFormat(
                                      context,
                                    ).format(project!.createdAt)
                                  : "–",
                            ),
                          ),
                          Chip(
                            avatar: Icon(Icons.list_alt_outlined),
                            label: Text("${project?.submissionCount}"),
                          ),
                        ]
                      : [
                          Chip(
                            avatar: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: user?.avatar(context),
                            ),
                            label: Text(
                              user?.username ?? "–",
                              style: TextStyle(color: user?.roleColor()),
                            ),
                          ),
                          Chip(
                            avatar: Icon(Icons.email_outlined),
                            label: Text(
                              user?.email ?? "–",
                              style: validateEmail(user?.email ?? "")
                                  ? null
                                  : TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: theme.disabledColor,
                                    ),
                            ),
                            deleteIcon: Icon(Icons.edit),
                            onDeleted:
                                AuthManager.instance.authenticatedUserIsAdmin
                                ? userSetEmail
                                : null,
                          ),
                          Chip(
                            avatar: Icon(Icons.event),
                            label: Text(
                              user != null
                                  ? dateFormat(context).format(user!.joinedAt)
                                  : "–",
                            ),
                          ),
                          Chip(
                            avatar: Icon(Icons.key),
                            label: Text(user?.role.toTitleCase() ?? "–"),
                          ),
                          Chip(
                            avatar: Icon(Icons.widgets_outlined),
                            label: Text(
                              user?.projects.isNotEmpty ?? false
                                  ? userAssignedProjects.isNotEmpty
                                        ? user!.projects
                                              .map((e) {
                                                if (userAssignedProjects
                                                    .where((p) => p.id == e)
                                                    .isEmpty) {
                                                  return "#$e";
                                                }
                                                return "“${userAssignedProjects.singleWhere((p) => p.id == e).title}”";
                                              })
                                              .join(", ")
                                        : "–"
                                  : (AuthManager
                                            .instance
                                            .authenticatedUserIsAdmin
                                        ? "None"
                                        : "–"),
                              style:
                                  user?.projects.isEmpty ??
                                      true &&
                                          AuthManager
                                              .instance
                                              .authenticatedUserIsAdmin
                                  ? TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: theme.disabledColor,
                                    )
                                  : null,
                            ),
                            deleteIcon: Icon(Icons.edit),
                            onDeleted:
                                AuthManager.instance.authenticatedUserIsAdmin
                                ? userSetProjects
                                : null,
                          ),
                          Chip(
                            avatar: Icon(Icons.list_alt_outlined),
                            label: Text("${user?.submissionCount}"),
                          ),
                        ],
                ),
              ),
            ),
            if (AuthManager.instance.authenticatedUserIsAdmin) ...[
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: [
                      if (showSubmissionsButton)
                        ActionChip(
                          avatar: Icon(Icons.arrow_forward),
                          label: Text("Submissions"),
                          onPressed: () => context.navigateTo(submissionRoute),
                        ),
                      if (widget.isProject) ...[
                        ActionChip(
                          avatar: Icon(Icons.cloud_download_outlined),
                          label: Text("Asset Dump"),
                          onPressed: () async {
                            final completer = Completer();
                            String? error;
                            http.Response? response;
                            showStatusModal(
                              context: context,
                              completer: completer,
                              failureDetailsGenerator: () =>
                                  error ??
                                  responseFailureDetailsGenerator(response),
                            );

                            response = await AuthManager.instance.fetch(
                              http.Request(
                                "GET",
                                Uri.parse(
                                  "${ApiManager.baseUri}/projects/${project!.id}/submissions/dump",
                                ),
                              ),
                            );
                            if (response == null ||
                                response.statusCode != 200) {
                              completer.completeError("");
                              return;
                            }

                            // DOWNLOAD

                            try {
                              if (kIsWeb) {
                                final blob = web.Blob(
                                  [response.bodyBytes.toJS].toJS
                                      as JSArray<web.BlobPart>,
                                  web.BlobPropertyBag(type: "application/zip"),
                                );
                                final url = web.URL.createObjectURL(blob);

                                final anchor = web.HTMLAnchorElement()
                                  ..style.display = "none"
                                  ..href = url
                                  ..download =
                                      "datly-project_${project!.id}-dump.zip";
                                web.document.body?.append(anchor);
                                anchor.dispatchEvent(web.MouseEvent("click"));
                                anchor.remove();

                                web.URL.revokeObjectURL(url);
                              } else {
                                throw UnimplementedError();
                              }
                            } catch (e) {
                              if (e is UnimplementedError) rethrow;
                              error = e.toString();
                              completer.completeError("");
                              return;
                            }

                            completer.complete();
                          },
                        ),
                        ActionChip(
                          avatar: Icon(Icons.attribution),
                          label: Text("Copy Attributions"),
                          onPressed: () async {
                            final completer = Completer();
                            String? error;
                            http.Response? response;
                            showStatusModal(
                              context: context,
                              completer: completer,
                              failureDetailsGenerator: () =>
                                  error ??
                                  responseFailureDetailsGenerator(response),
                            );

                            response = await AuthManager.instance.fetch(
                              http.Request(
                                "GET",
                                Uri.parse(
                                  "${ApiManager.baseUri}/projects/${project!.id}/submissions/attributions",
                                ),
                              ),
                            );
                            if (response == null ||
                                response.statusCode != 200) {
                              completer.completeError("");
                              return;
                            }
                            final body = jsonDecode(response.body);

                            try {
                              if (kIsWeb) {
                                final blobPlain = web.Blob(
                                  [body["plain"] as String].jsify()
                                      as JSArray<web.BlobPart>,
                                  web.BlobPropertyBag(type: "text/plain"),
                                );
                                final blobHtml = web.Blob(
                                  [body["html"] as String].jsify()
                                      as JSArray<web.BlobPart>,
                                  web.BlobPropertyBag(type: "text/html"),
                                );

                                final clipboardApi =
                                    web.window.navigator.clipboard;
                                final clipboardData = web.ClipboardItem(
                                  {
                                        blobPlain.type: blobPlain,
                                        blobHtml.type: blobHtml,
                                      }.jsify()
                                      as JSObject,
                                );

                                await clipboardApi
                                    .write([clipboardData].toJS)
                                    .toDart;
                              } else {
                                throw UnimplementedError();
                              }
                            } catch (e) {
                              if (e is UnimplementedError) rethrow;
                              error = e.toString();
                              completer.completeError("");
                              return;
                            }

                            completer.complete();
                          },
                        ),
                      ],
                      ActionChip(
                        backgroundColor: colorScheme.error,
                        avatar: Icon(
                          Icons.delete_outlined,
                          color: showDeleteButton ? colorScheme.onError : null,
                        ),
                        label: Builder(
                          builder: (context) => Text(
                            "Delete",
                            style: DefaultTextStyle.of(context).style.copyWith(
                              color: showDeleteButton
                                  ? colorScheme.onError
                                  : null,
                            ),
                          ),
                        ),
                        onPressed: showDeleteButton ? delete : null,
                      ),
                      if (!widget.isProject) ...[
                        ActionChip(
                          avatar: Icon(
                            user!.disabled == null
                                ? Icons.block_outlined
                                : Icons.check_circle_outline,
                            color: user!.disabled == null && showDeleteButton
                                ? colorScheme.error
                                : null,
                          ),
                          label: Text(
                            user!.disabled == null ? "Disable" : "Reenable",
                          ),
                          onPressed: showDeleteButton
                              ? userDisableReenable
                              : null,
                        ),
                        ActionChip(
                          avatar: Icon(Icons.upcoming_outlined),
                          label: Text("New password"),
                          onPressed: showDeleteButton ? userSetPassword : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return card;
  }

  Uri get uri => widget.isProject
      ? Uri.parse("${ApiManager.baseUri}/projects/${project!.id}")
      : Uri.parse("${ApiManager.baseUri}/user/${user!.username}");
}

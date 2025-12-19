import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../main.dart';
import '../main.gr.dart';
import '../registry.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/multi_prompt_dialog.dart';
import '../widgets/multiple_choice_dialog.dart';
import '../widgets/prompt_dialog.dart';
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
                      "PUT",
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
                    ),
                    "email": MultiPromptPrompt(
                      label: "Email Address",
                      placeholder: "user@example.com",
                      validator: (v) => v.isNotEmpty && !validateEmail(v)
                          ? "Not a valid email address."
                          : null,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    "role": MultiPromptPrompt(
                      label: "Role",
                      placeholder: "user, admin",
                      content: "user",
                      validator: (value) => !["user", "admin"].contains(value)
                          ? "Role must be either 'user' or 'admin'."
                          : null,
                      capitalization: TextCapitalization.none,
                    ),
                  },
                );
                if (inputRaw == null) return;
                final input = Map<String, dynamic>.from(inputRaw);

                if (input["email"]!.isEmpty) {
                  input["email"] = "${input["username"]}@localhost";
                }

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
                      await showMultipleChoiceDialog(
                          context: context,
                          title: "Assign Projects",
                          description:
                              "Select the projects to assign to this user.",
                          items: allProjects,
                          titleGenerator: (item) => item.title,
                          subtitleGenerator: (item) => item.description,
                          allowEmptySelection: true,
                        )
                        ..sort((a, b) => a.id.compareTo(b.id));
                  input["projects"] = selectedProjects
                      .map((p) => p.id)
                      .toList();
                }

                final username = input.remove("username");
                final response = await AuthManager.instance.fetch(
                  http.Request(
                      "PUT",
                      Uri.parse("${ApiManager.baseUri}/users/$username"),
                    )
                    ..headers["Content-Type"] = "application/json"
                    ..body = jsonEncode(input),
                );
                if (response?.statusCode == 201) {
                  fetch();
                  final response = await AuthManager.instance.fetch(
                    http.Request(
                      "PUT",
                      Uri.parse(
                        "${ApiManager.baseUri}/users/$username/loginCode",
                      ),
                    ),
                  );
                  if (response == null || response.statusCode != 200) {
                    return;
                  }

                  final code = jsonDecode(response.body)["code"] as String?;
                  if (code == null) return;

                  if (!context.mounted) return;
                  showLoginCodeDialog(context, code);
                }
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

    return Stack(
      children: [
        !error
            ? response != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                List data;
                                try {
                                  data = jsonDecode(response!.body) as List;
                                } catch (_) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 32),
                                    child: Text(
                                      "Failed to parse server response.",
                                      style: DefaultTextStyle.of(context).style
                                          .copyWith(
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  );
                                }

                                if (data.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 32),
                                    child: Text(
                                      "No data.",
                                      style: DefaultTextStyle.of(context).style
                                          .copyWith(
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                            fontStyle: FontStyle.italic,
                                          ),
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
                                        data: data[i],
                                        isProject: widget.isProjects,
                                        onDelete: fetch,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    )
                  : Center(child: CircularProgressIndicator())
            : Center(child: Icon(Icons.error_outline, size: 48)),
        if (AuthManager.instance.authenticatedUserIsAdmin) ...[
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 512),
                child: MenuAnchor(
                  menuChildren: adminOptions,
                  builder: (context, controller, _) => Card.filled(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: controller.isOpen
                          ? controller.close
                          : controller.open,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.admin_panel_settings),
                            SizedBox(width: 8),
                            Text(
                              "Options",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
  final void Function() onDelete;

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
      () async {
        final allProjectsResponse = await AuthManager.instance.fetch(
          http.Request("GET", Uri.parse("${ApiManager.baseUri}/projects/list")),
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

    final card = ConstrainedBox(
      constraints: BoxConstraints(minWidth: 224, maxWidth: 224),
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
                                ? () async {
                                    final newDescription = await showPromptDialog(
                                      context: context,
                                      title: "Set Description",
                                      content: project?.description,
                                      placeholder:
                                          "Training data for a model to detect…",
                                      maxLength: 256,
                                      maxLines: 4,
                                    );
                                    if (newDescription != null &&
                                        newDescription !=
                                            project?.description) {
                                      await AuthManager.instance.fetch(
                                        http.Request("POST", uri)
                                          ..headers["Content-Type"] =
                                              "application/json"
                                          ..body = jsonEncode({
                                            "title": null,
                                            "description": newDescription,
                                          }),
                                      );
                                      project?.description = newDescription;
                                      if (mounted) setState(() {});
                                    }
                                  }
                                : null,
                          ),
                          Chip(
                            avatar: Icon(Icons.event),
                            label: Text(
                              project?.createdAt
                                      .toLocal()
                                      .toIso8601String()
                                      .split("T")
                                      .join(" ")
                                      .split(".")
                                      .first ??
                                  "–",
                            ),
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
                                ? () async {
                                    final newEmail = await showPromptDialog(
                                      context: context,
                                      title: "Set Email Address",
                                      content: user?.email,
                                      quickValidator: (e) => validateEmail(e),
                                      keyboardType: TextInputType.emailAddress,
                                    );
                                    if (newEmail != null &&
                                        newEmail != user?.email) {
                                      await AuthManager.instance.fetch(
                                        http.Request("POST", uri)
                                          ..headers["Content-Type"] =
                                              "application/json"
                                          ..body = jsonEncode({
                                            "email": newEmail,
                                            "projects": null,
                                            "role": null,
                                          }),
                                      );
                                      user?.email = newEmail;
                                      if (mounted) setState(() {});
                                    }
                                  }
                                : null,
                          ),
                          Chip(
                            avatar: Icon(Icons.event),
                            label: Text(
                              user?.joinedAt
                                      .toLocal()
                                      .toIso8601String()
                                      .split("T")
                                      .join(" ")
                                      .split(".")
                                      .first ??
                                  "–",
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
                                        ? user?.projects
                                                  .map((e) {
                                                    if (userAssignedProjects
                                                        .where((p) => p.id == e)
                                                        .isEmpty) {
                                                      return "#$e";
                                                    }
                                                    return "“${userAssignedProjects.singleWhere((p) => p.id == e).title}”";
                                                  })
                                                  .join(", ") ??
                                              "–"
                                        : "–"
                                  : "No projects assigned",
                              style: user?.projects.isEmpty ?? true
                                  ? TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: theme.disabledColor,
                                    )
                                  : null,
                            ),
                            deleteIcon: Icon(Icons.edit),
                            onDeleted:
                                AuthManager.instance.authenticatedUserIsAdmin
                                ? () async {
                                    final items = (await Future.wait(
                                      allProjectIds.map(
                                        (id) =>
                                            ProjectRegistry.instance.get(id),
                                      ),
                                    )).whereType<ProjectData>();
                                    if (!context.mounted) return;
                                    final newProjects =
                                        (await showMultipleChoiceDialog(
                                          context: context,
                                          title: "Change Assigned Projects",
                                          initialValue: userAssignedProjects,
                                          items: items,
                                          titleGenerator: (item) => item.title,
                                          subtitleGenerator: (item) =>
                                              item.description,
                                        ))..sort(
                                          (a, b) => a.id.compareTo(b.id),
                                        );
                                    if (newProjects.isNotEmpty &&
                                        newProjects.map((p) => p.id) !=
                                            user?.projects) {
                                      await AuthManager.instance.fetch(
                                        http.Request("POST", uri)
                                          ..headers["Content-Type"] =
                                              "application/json"
                                          ..body = jsonEncode({
                                            "email": null,
                                            "projects": newProjects
                                                .map((p) => p.id)
                                                .toList(),
                                            "role": null,
                                          }),
                                      );
                                      user?.projects = newProjects
                                          .map((p) => p.id)
                                          .toList();
                                      _preloadUserProjects();
                                      if (mounted) setState(() {});
                                    }
                                  }
                                : null,
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
                      if (widget.isProject)
                        ActionChip(
                          avatar: Icon(Icons.cloud_download_outlined),
                          label: Text("Asset Dump"),
                          onPressed: () async {
                            final response = await AuthManager.instance.fetch(
                              http.Request(
                                "GET",
                                Uri.parse(
                                  "${ApiManager.baseUri}/projects/${project!.id}/submissions/dump",
                                ),
                              ),
                            );
                            await FilePicker.platform.saveFile(
                              fileName: "datly-project_${project!.id}-dump.zip",
                              type: FileType.custom,
                              allowedExtensions: ["zip"],
                              bytes: response?.bodyBytes,
                              lockParentWindow: true,
                            );
                          },
                        ),
                      ActionChip(
                        backgroundColor: colorScheme.error,
                        avatar: Icon(
                          Icons.delete,
                          color: showDeleteButton
                              ? colorScheme.onError
                              : theme.disabledColor,
                        ),
                        label: Builder(
                          builder: (context) => Text(
                            "Delete",
                            style: DefaultTextStyle.of(context).style.copyWith(
                              color: showDeleteButton
                                  ? colorScheme.onError
                                  : theme.disabledColor,
                            ),
                          ),
                        ),
                        onPressed: showDeleteButton
                            ? () async {
                                final selection = await showConfirmationDialog(
                                  context: context,
                                  title:
                                      "Delete ${widget.isProject ? "Project" : "User"}",
                                  description:
                                      "Are you sure you want to delete this ${widget.isProject ? "project" : "user"}? This action cannot be undone.",
                                );
                                if (!selection) return;
                                await AuthManager.instance.fetch(
                                  http.Request("DELETE", uri),
                                );
                                widget.onDelete();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              if (!widget.isProject)
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: [
                        Chip(label: Text("Login Codes:")),
                        ActionChip(
                          avatar: Icon(Icons.add),
                          label: Text("Add"),
                          onPressed: () async {
                            final response = await AuthManager.instance.fetch(
                              http.Request("PUT", Uri.parse("$uri/loginCode")),
                            );
                            if (response == null ||
                                response.statusCode != 200) {
                              return;
                            }

                            final code =
                                jsonDecode(response.body)["code"] as String?;
                            if (code == null) return;

                            if (!context.mounted) return;
                            showLoginCodeDialog(context, code);
                          },
                        ),
                        ActionChip(
                          backgroundColor: colorScheme.error,
                          avatar: Icon(
                            Icons.folder_delete,
                            color: colorScheme.onError,
                          ),
                          label: Builder(
                            builder: (context) => Text(
                              "Purge All",
                              style: DefaultTextStyle.of(
                                context,
                              ).style.copyWith(color: colorScheme.onError),
                            ),
                          ),
                          onPressed: () => AuthManager.instance.fetch(
                            http.Request(
                              "DELETE",
                              Uri.parse("$uri/loginCode/purge"),
                            ),
                          ),
                        ),
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
      : Uri.parse("${ApiManager.baseUri}/users/${user!.username}");
}

Future<void> showLoginCodeDialog(BuildContext context, String code) {
  assert(code.length == 8, "Login code must be 8 characters long.");
  final textTheme = TextTheme.of(context);
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsetsGeometry.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 16,
      ),
      constraints: BoxConstraints(minWidth: 280, maxWidth: 560),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            style: textTheme.displayLarge?.copyWith(
              fontFamily: "GoogleSansCode",
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
          Text(
            "THIS CODE WILL NOT BE SHOWN AGAIN.",
            style: textTheme.labelMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
          child: Text(MaterialLocalizations.of(context).copyButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ),
  );
}

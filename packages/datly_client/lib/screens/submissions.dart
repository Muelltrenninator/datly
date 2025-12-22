import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../main.gr.dart';
import '../registry.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/radio_dialog.dart';
import 'list.dart';

@RoutePage()
class SubmissionsPage extends StatefulWidget {
  final String? user;
  final String? project;
  const SubmissionsPage({
    super.key,
    @QueryParam() this.user,
    @QueryParam() this.project,
  });

  @override
  State<SubmissionsPage> createState() => _SubmissionsPageState();
}

class _SubmissionsPageState extends State<SubmissionsPage> {
  String? stateValueUser;
  String? stateValueProject;

  http.Client? client;
  Stream<List>? stream;
  bool error = false;

  ProjectData? effectiveProjectData;
  UserData? effectiveUserData;

  int? get effectiveProject =>
      (widget.project != null &&
          widget.project!.isNotEmpty &&
          int.tryParse(widget.project!) != null &&
          AuthManager.instance.authenticatedUserIsAdmin)
      ? int.parse(widget.project!)
      : null;
  String get effectiveUser =>
      (widget.user != null &&
          widget.user!.isNotEmpty &&
          AuthManager.instance.authenticatedUserIsAdmin)
      ? widget.user!
      : AuthManager.instance.authenticatedUser?.username ?? "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    client?.close();
    stream = null;
    super.dispose();
  }

  void fetch() {
    client?.close();
    stream = null;
    effectiveProjectData = null;
    effectiveUserData = null;
    if (mounted) setState(() {});

    if (!AuthManager.instance.authenticatedUserIsAdmin &&
        (effectiveUser != AuthManager.instance.authenticatedUser?.username ||
            effectiveProject != null)) {
      error = true;
      if (mounted) setState(() {});
      return;
    }

    client = http.Client();
    try {
      client!
          .send(
            AuthManager.instance.fetchPrepare(
              http.Request(
                "GET",
                effectiveProject != null
                    ? Uri.parse(
                        "${ApiManager.baseUri}/projects/$effectiveProject/submissions/live",
                      )
                    : Uri.parse(
                        "${ApiManager.baseUri}/users/$effectiveUser/submissions/live",
                      ),
              ),
            ),
          )
          .then((value) {
            if (value.statusCode != 200 ||
                !(value.headers["content-type"]?.startsWith(
                      "application/jsonl",
                    ) ??
                    false)) {
              error = true;
              if (mounted) setState(() {});
              return;
            }

            stream = value.stream
                .transform(Utf8Decoder())
                .map((e) => jsonDecode(e) as List)
                .handleError((_) {
                  error = true;
                  if (mounted) setState(() {});
                });
            if (mounted) setState(() {});
          })
          .catchError((_, _) {
            error = true;
            if (mounted) setState(() {});
          });
    } catch (_) {
      error = true;
      if (mounted) setState(() {});
    }

    if (effectiveProject != null) {
      ProjectRegistry.instance.get(effectiveProject!).then((projectData) {
        effectiveProjectData = projectData;
        if (mounted) setState(() {});
      });
    }
    UserRegistry.instance.get(effectiveUser).then((userData) {
      effectiveUserData = userData;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (stateValueUser != widget.user || stateValueProject != widget.project) {
      stateValueUser = widget.user;
      stateValueProject = widget.project;
      fetch();
    }

    return Stack(
      children: [
        !error
            ? stream != null
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 8,
                          bottom: 24,
                        ),
                        child: StreamBuilder(
                          stream: stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Icon(Icons.error_outline, size: 48),
                              );
                            } else if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            List data = snapshot.data ?? [];
                            if (data.isEmpty) {
                              return Text(
                                AppLocalizations.of(context).noSubmissions,
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
                                  (i) => SubmissionWidget(
                                    data: SubmissionData.fromJson(data[i]),
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
        if (AuthManager.instance.authenticatedUserIsAdmin)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 512),
                child: SubmissionTargetWidget(
                  effectiveProject: effectiveProject,
                  effectiveProjectData: effectiveProjectData,
                  effectiveUser: effectiveUser,
                  effectiveUserData: effectiveUserData,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SubmissionWidget extends StatefulWidget {
  final SubmissionData data;
  const SubmissionWidget({super.key, required this.data});

  @override
  State<SubmissionWidget> createState() => _SubmissionWidgetState();
}

class _SubmissionWidgetState extends State<SubmissionWidget> {
  ProjectData? project;
  UserData? user;

  @override
  void initState() {
    super.initState();
    ProjectRegistry.instance.get(widget.data.projectId).then((projectData) {
      project = projectData;
      if (mounted) setState(() {});
    });
    UserRegistry.instance.get(widget.data.user).then((userData) {
      user = userData;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final image = SizedBox(
      width: 224,
      height: 224,
      child: widget.data.assetUri() != null
          ? FadeInImage.memoryNetwork(
              placeholder: blurHashImage,
              image: widget.data.assetUri().toString(),
              fadeInDuration: Duration(milliseconds: 1),
              fadeOutDuration: Duration(milliseconds: 1),
              imageErrorBuilder: (_, _, _) => SizedBox(
                height: 224,
                width: 224,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: Image.memory(
                          blurHashImage,
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ),
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: colorScheme.error.withAlpha(128),
                    ),
                    Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: colorScheme.onError,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
              width: 224,
              height: 224,
              fit: BoxFit.cover,
            )
          : FittedBox(
              child: Image.memory(blurHashImage, width: 64, height: 64),
            ),
    );
    final card = SizedBox(
      width: 224,
      child: Card.filled(
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: image,
            ),
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: [
                    ActionChip(
                      avatar: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: user?.avatar(context),
                      ),
                      label: Text(
                        widget.data.user,
                        style: TextStyle(color: user?.roleColor()),
                      ),
                      onPressed: () => context.navigateTo(
                        SubmissionsRoute(user: widget.data.user),
                      ),
                    ),
                    ActionChip(
                      avatar: Icon(Icons.widgets_outlined),
                      label: Text(project?.title ?? "–"),
                      onPressed: AuthManager.instance.authenticatedUserIsAdmin
                          ? () => context.navigateTo(
                              SubmissionsRoute(
                                project: widget.data.projectId.toString(),
                              ),
                            )
                          : null,
                    ),
                    Chip(
                      label: Text(
                        GetTimeAgo.parse(
                          widget.data.submittedAt,
                          locale: AppLocalizations.of(context).localeName,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: [
                    Chip(
                      backgroundColor: widget.data.statusColor(),
                      label: Builder(
                        builder: (context) => Text(
                          switch (widget.data.status) {
                            "pending" => AppLocalizations.of(
                              context,
                            ).submissionStatusPending,
                            "accepted" => AppLocalizations.of(
                              context,
                            ).submissionStatusAccepted,
                            "rejected" => AppLocalizations.of(
                              context,
                            ).submissionStatusRejected,
                            "censored" => AppLocalizations.of(
                              context,
                            ).submissionStatusCensored,
                            _ => widget.data.status.toTitleCase(),
                          },
                          style: DefaultTextStyle.of(context).style.copyWith(
                            color: widget.data.statusColor().onColor(),
                          ),
                        ),
                      ),
                      deleteIcon: Icon(
                        Icons.edit,
                        color: widget.data.statusColor().onColor(),
                      ),
                      onDeleted:
                          AuthManager.instance.authenticatedUserIsAdmin &&
                              widget.data.status != "censored"
                          ? () async {
                              final selection = await showRadioDialog(
                                context: context,
                                title: "Set Status",
                                items: [
                                  "pending",
                                  "accepted",
                                  "rejected",
                                  "censored",
                                ],
                                initialValue: widget.data.status,
                                titleGenerator: (item) => item.toTitleCase(),
                                subtitleGenerator: (item) => switch (item) {
                                  "pending" =>
                                    "The submission will be reviewed again later. Don't use this unless necessary.",
                                  "accepted" =>
                                    "This will add the asset to asset dumps.",
                                  "rejected" => "The asset will be ignored.",
                                  "censored" =>
                                    "While the submission will not be deleted, the asset will be, only keeping metadata and a crude thumbnail. This is not reversible.",
                                  _ => "",
                                },
                              );
                              if (selection != widget.data.status) {
                                await AuthManager.instance.fetch(
                                  http.Request("PUT", uri)
                                    ..headers["Content-Type"] =
                                        "application/json"
                                    ..body = jsonEncode({"status": selection}),
                                );
                              }
                            }
                          : null,
                    ),
                    ActionChip(
                      backgroundColor: colorScheme.error,
                      avatar: Icon(
                        Icons.delete_outline,
                        color: colorScheme.onError,
                      ),
                      label: Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context).delete,
                          style: DefaultTextStyle.of(
                            context,
                          ).style.copyWith(color: colorScheme.onError),
                        ),
                      ),
                      onPressed: () async {
                        final selection = await showConfirmationDialog(
                          context: context,
                          title: AppLocalizations.of(
                            context,
                          ).submissionDeleteTitle,
                          description: AppLocalizations.of(
                            context,
                          ).submissionDeleteMessage,
                        );
                        if (!selection) return;
                        await AuthManager.instance.fetch(
                          http.Request("DELETE", uri),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return card;
  }

  Uri get uri => Uri.parse(
    "${ApiManager.baseUri}/projects/${widget.data.projectId}/submissions/${widget.data.id}",
  );
  Uint8List get blurHashImage => Uint8List.fromList(
    img.encodePng(BlurHash.decode(widget.data.assetBlurHash).toImage(64, 64)),
  );
}

class SubmissionTargetWidget extends StatefulWidget {
  final int? effectiveProject;
  final ProjectData? effectiveProjectData;
  final String effectiveUser;
  final UserData? effectiveUserData;

  const SubmissionTargetWidget({
    super.key,
    required this.effectiveProject,
    required this.effectiveProjectData,
    required this.effectiveUser,
    required this.effectiveUserData,
  });

  @override
  State<SubmissionTargetWidget> createState() => _SubmissionTargetWidgetState();
}

class _SubmissionTargetWidgetState extends State<SubmissionTargetWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // value: 1,
      duration: Durations.medium1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
    );
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _controller.isCompleted
                  ? _controller.reverse()
                  : _controller.forward(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: -0.5).animate(animation),
                      child: Icon(Icons.expand_more),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Admin View",
                      style: TextTheme.of(context).titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: ColoredBox(
                color: ColorScheme.of(context).surfaceContainerHighest,
                child: SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: SizeTransition(
                    axis: Axis.vertical,
                    sizeFactor: animation,
                    axisAlignment: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(height: 1),
                        (widget.effectiveProject == null ||
                                    widget.effectiveProjectData != null) &&
                                (widget.effectiveProject != null ||
                                    widget.effectiveUserData != null)
                            ? ListWidget(
                                data:
                                    (widget.effectiveProject != null
                                            ? widget.effectiveProjectData!
                                            : widget.effectiveUserData!
                                                  as dynamic)
                                        .toJson(),
                                isProject: widget.effectiveProject != null,
                                onDelete: () => context.navigateTo(MainRoute()),
                              )
                            : Padding(
                                padding: EdgeInsets.only(
                                  left: 52,
                                  top: 32,
                                  bottom: 32,
                                ),
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

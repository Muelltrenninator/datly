import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../registry.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/prompt_dialog.dart';
import '../widgets/radio_dialog.dart';
import '../widgets/status_modal.dart';
import 'list.dart';

final Map<String, Uint8List?> _blurHashCache = {};
Uint8List _decodeBlurHash(String blurHash) {
  return Uint8List.fromList(
    img.encodePng(BlurHash.decode(blurHash).toImage(64, 64)),
  );
}

@RoutePage()
class SubmissionsPage extends StatefulWidget {
  final String? user;
  final String? project;
  final int page;
  const SubmissionsPage({
    super.key,
    @QueryParam() this.user,
    @QueryParam() this.project,
    @QueryParam() this.page = 1,
  });

  @override
  State<SubmissionsPage> createState() => _SubmissionsPageState();
}

class _SubmissionsPageState extends State<SubmissionsPage> {
  http.Client? client;
  Stream<List>? stream;
  bool error = false;

  ProjectData? effectiveProjectData;
  UserData? effectiveUserData;

  ValueNotifier<bool> optionLeftAligned = ValueNotifier(false);

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
    optionLeftAligned.addListener(opUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => fetch());
  }

  @override
  void dispose() {
    optionLeftAligned.removeListener(opUpdate);
    client?.close();
    stream = null;
    super.dispose();
  }

  void opUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(SubmissionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    fetch();
  }

  Stream<List> _bufferedJsonStream(Stream<List<int>> byteStream) async* {
    final buffer = StringBuffer();

    await for (final chunk in byteStream.transform(const Utf8Decoder())) {
      buffer.write(chunk);
      final content = buffer.toString();
      final lines = content.split("\n");

      for (var i = 0; i < lines.length - 1; i++) {
        final line = lines[i].trim();
        if (line.isNotEmpty) {
          try {
            yield jsonDecode(line) as List;
          } catch (e) {
            if (kDebugMode) {
              print("Failed to parse JSON line: $e");
            }
          }
        }
      }

      buffer.clear();
      buffer.write(lines.last);
    }

    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      try {
        yield jsonDecode(remaining) as List;
      } catch (e) {
        if (kDebugMode) {
          print("Failed to parse final JSON: $e");
        }
      }
    }
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
      if (kDebugMode) {
        print(
          "Non-admin user tried to access another user's or a specific project's submissions.",
        );
      }
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
                        "${ApiManager.baseUri}/projects/$effectiveProject/submissions/live?page=${widget.page.abs()}",
                      )
                    : Uri.parse(
                        "${ApiManager.baseUri}/user/$effectiveUser/submissions/live",
                      ),
              ),
            ),
          )
          .then((value) {
            if (value.statusCode == 401 || value.statusCode == 403) {
              AuthManager.instance.fourOhOneFourOhThree(value.statusCode);
              error = true;
              if (mounted) setState(() {});
              return;
            }
            if (value.statusCode != 200 ||
                !(value.headers["content-type"]?.startsWith(
                      "application/jsonl",
                    ) ??
                    false)) {
              error = true;
              if (kDebugMode) {
                print(
                  "Failed to fetch submissions stream: ${value.statusCode} ${value.reasonPhrase}",
                );
              }
              if (mounted) setState(() {});
              return;
            }

            stream = _bufferedJsonStream(value.stream).handleError((e) {
              error = true;
              if (kDebugMode) {
                print("Error while receiving submissions stream. [$e]");
              }
              if (mounted) setState(() {});
            });
            if (mounted) setState(() {});
          })
          .catchError((e, _) {
            error = true;
            if (kDebugMode) {
              print("Error while initiating submissions stream (#2). [$e]");
            }
            if (mounted) setState(() {});
          });
    } catch (e) {
      error = true;
      if (kDebugMode) {
        print("Error while initiating submissions stream (#1). [$e]");
      }
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
    final availablePages = effectiveProjectData?.submissionCount != null
        ? (effectiveProjectData!.submissionCount / 96).ceil()
        : null;
    return Stack(
      children: [
        !error
            ? stream != null &&
                      (effectiveProject == null || effectiveProjectData != null)
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
                                widget.page < 1 ||
                                        (availablePages != null &&
                                            widget.page > availablePages)
                                    ? AppLocalizations.of(context).invalidPage
                                    : AppLocalizations.of(
                                        context,
                                      ).noSubmissions,
                                style: DefaultTextStyle.of(context).style
                                    .copyWith(
                                      color: Theme.of(context).disabledColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                              );
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(data.length, (i) {
                                      final submissionData =
                                          SubmissionData.fromJson(data[i]);
                                      return SubmissionWidget(
                                        key: ValueKey(submissionData.id),
                                        data: submissionData,
                                      );
                                    }),
                                  ),
                                ),
                                if (effectiveProject != null &&
                                    availablePages! > 1)
                                  Container(
                                    margin: const EdgeInsets.only(
                                      top: 32,
                                      left: 64,
                                      right: 64,
                                    ),
                                    constraints: BoxConstraints(maxWidth: 320),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: Divider(height: 1),
                                        ),
                                        SizedBox(height: 4),
                                        SubmissionsPageControl(
                                          page: widget.page,
                                          availablePages: availablePages,
                                          routeParams: (
                                            project: widget.project,
                                            user: widget.user,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    )
                  : Center(child: CircularProgressIndicator())
            : Center(child: Icon(Icons.error_outline, size: 48)),
        if (AuthManager.instance.authenticatedUserIsAdmin)
          AnimatedAlign(
            duration: Durations.medium1,
            curve: Curves.easeInOutCubic,
            alignment: optionLeftAligned.value
                ? Alignment.topLeft
                : Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, left: 12, right: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 512),
                child: SubmissionTargetWidget(
                  effectiveProject: effectiveProject,
                  effectiveProjectData: effectiveProjectData,
                  effectiveUser: effectiveUser,
                  effectiveUserData: effectiveUserData,
                  optionLeftAligned: optionLeftAligned,
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
  final bool includeImage;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  const SubmissionWidget({
    super.key,
    required this.data,
    this.includeImage = true,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<SubmissionWidget> createState() => _SubmissionWidgetState();
}

class _SubmissionWidgetState extends State<SubmissionWidget> {
  ProjectData? project;
  UserData? user;
  CategoryData? category;
  Uint8List? blurHashImage;

  List<CategoryData> availableCategories = [];

  @override
  void initState() {
    super.initState();
    _loadBlurHash();
    _loadMetadata();
  }

  @override
  void didUpdateWidget(SubmissionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _preloadCategories();
    if (oldWidget.data.id != widget.data.id) {
      _loadBlurHash();
      _loadMetadata();
    } else if (oldWidget.data.assetBlurHash != widget.data.assetBlurHash) {
      _loadBlurHash();
    }
  }

  Future<void> _loadBlurHash() async {
    if (!widget.includeImage) return;
    final hash = widget.data.assetBlurHash;

    if (_blurHashCache.containsKey(hash)) {
      blurHashImage = _blurHashCache[hash];
      if (mounted) setState(() {});
      return;
    }
    _blurHashCache[hash] = null; // blocking

    try {
      final decoded = await compute(_decodeBlurHash, hash);
      _blurHashCache[hash] = decoded;
      blurHashImage = decoded;
      if (mounted) setState(() {});
    } catch (e) {
      if (kDebugMode) print("Failed to decode BlurHash: $e");
    }
  }

  void _loadMetadata() {
    if (!widget.includeImage) return;
    ProjectRegistry.instance.get(widget.data.projectId).then((projectData) {
      project = projectData;
      if (mounted) setState(() {});
    });
    UserRegistry.instance.get(widget.data.user).then((userData) {
      user = userData;
      if (mounted) setState(() {});
    });
  }

  Future<void> _preloadCategories() async {
    final categories = await _listAvailableCategories() ?? [];
    availableCategories
      ..clear()
      ..addAll(categories)
      ..sort((a, b) => a.name.compareTo(b.name));
    if (widget.data.category != null &&
        availableCategories.any((c) => c.name == widget.data.category)) {
      category = availableCategories.firstWhere(
        (c) => c.name == widget.data.category,
      );
    }
    if (mounted) setState(() {});
  }

  Future<List<CategoryData>?> _listAvailableCategories() async {
    final request = await AuthManager.instance.fetch(
      http.Request("GET", Uri.parse("${ApiManager.baseUri}/categories/list")),
    );
    if (request == null || request.statusCode != 200) return null;

    var data = jsonDecode(request.body);
    if (data is! List) return null;
    data = data.whereType<Map>().toList();

    final processed = List<Map<String, dynamic>>.from(data)
        .map((c) {
          try {
            return CategoryData.fromJson(c);
          } catch (_) {
            return null;
          }
        })
        .whereType<CategoryData>()
        .toList();

    CategoryRegistry.instance.addAll(
      Map.fromEntries(processed.map((c) => MapEntry(c.name, c))),
    );

    return processed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final windowSizeClass = WindowSizeClass.of(context);

    void setModerationReason() async {
      final newReason = await showPromptDialog(
        context: context,
        title: "Set moderation reason",
        description:
            "The reason why this submission was blocked. Available format:\n\u2022\t'Automated moderation: (self-harm|sexual|violence)'\n\u2022\tComma separated list of reasons from the list above.\n\u2022\tAny custom reason.",
        previewBuilder: (value) => Card.outlined(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Builder(
              builder: (context) => Text(
                value.trim().isEmpty
                    ? "Moderation reason will be cleared."
                    : widget.data.moderationReasonDisplay(context, value)!,
                style: DefaultTextStyle.of(context).style.copyWith(
                  fontStyle: value.trim().isEmpty ? FontStyle.italic : null,
                  color: value.trim().isEmpty ? theme.disabledColor : null,
                ),
              ),
            ),
          ),
        ),
        content: widget.data.moderationReason,
        maxLength: 256,
        maxLines: 4,
      );
      if (newReason != null &&
          newReason != widget.data.moderationReason &&
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
              ..body = jsonEncode(
                SubmissionData.modifying(moderationReason: newReason),
              ),
          );
          if (response == null || response.statusCode != 200) {
            completer.completeError("");
            return;
          }
        } catch (_) {
          completer.completeError("");
          return;
        }

        project?.description = newReason;
        if (mounted) setState(() {});
        completer.complete();
        widget.onUpdate?.call();
      }
    }

    void setStatus() async {
      String? selection;
      if (HardwareKeyboard.instance.isShiftPressed) {
        selection ??= widget.data.status == "accepted"
            ? "rejected"
            : "accepted";
      } else if (HardwareKeyboard.instance.isControlPressed) {
        selection ??= "rejected";
      }

      selection ??= await showRadioDialog(
        context: context,
        title: "Set status",
        items: ["pending", "accepted", "rejected", "censored"],
        initialValue: widget.data.status,
        titleGenerator: (item) => item.toTitleCase(),
        subtitleGenerator: (item) => switch (item) {
          "pending" =>
            "The submission will be reviewed again later. Don't use this unless necessary.",
          "accepted" => "This will add the asset to asset dumps.",
          "rejected" => "The asset will be ignored.",
          "censored" =>
            "While the submission will not be deleted, the asset will be, only keeping metadata and a crude thumbnail. This is not reversible.",
          _ => "",
        },
      );
      if (!context.mounted) return;
      if (selection == "censored" &&
          !(await showConfirmationDialog(
            context: context,
            title: "Censor submission?",
            description:
                "All associated image data will be permanently deleted. The submission data and a blurhash will remain in the database. This action cannot be undone.",
          ))) {
        return;
      }
      if (selection != null &&
          selection != widget.data.status &&
          context.mounted) {
        final completer = Completer<void>();
        http.Response? response;
        showStatusModal(
          context: context,
          completer: completer,
          failureDetailsGenerator: () =>
              responseFailureDetailsGenerator(response),
        );

        response = await AuthManager.instance.fetch(
          http.Request("PUT", uri)
            ..headers["Content-Type"] = "application/json"
            ..body = jsonEncode(SubmissionData.modifying(status: selection)),
        );
        if (response != null && response.statusCode == 200) {
          widget.onUpdate?.call();
          completer.complete();
        } else {
          completer.completeError("");
        }
      }
    }

    void setCategory() async {
      bool submitted = false;
      final newCategory = await showRadioDialog<CategoryData>(
        context: context,
        title: "Set category",
        description:
            "This will be used to sort and validate the submission in the 3×3 crowd sourcing validation grid.",
        items: availableCategories,
        initialValue: category,
        titleGenerator: (item) => item.displayName ?? item.name,
        iconGenerator: (item) =>
            item.displayName != null ? Text(item.name) : null,
        allowEmptySelection: true,
        toggleable: true,
        onSubmit: (_) => submitted = true,
      );
      if (submitted &&
          newCategory?.name != widget.data.category &&
          context.mounted &&
          await showConfirmationDialog(
            context: context,
            title: "Reset validation weights to set new category?",
            description:
                "To change the category of a submission it is necessary to reset the positive and negative validation score of the submission. This action cannot be undone.",
          )) {
        if (!context.mounted) return;
        final completer = Completer<void>();
        http.Response? response;
        showStatusModal(
          context: context,
          completer: completer,
          failureDetailsGenerator: () =>
              responseFailureDetailsGenerator(response),
        );

        response = await AuthManager.instance.fetch(
          http.Request("PUT", uri)
            ..headers["Content-Type"] = "application/json"
            ..body = jsonEncode(
              SubmissionData.modifying(category: newCategory?.name ?? ""),
            ),
        );
        if (response != null && response.statusCode == 200) {
          widget.onUpdate?.call();
          completer.complete();
        } else {
          completer.completeError("");
        }
      }
    }

    void deleteSubmission() async {
      final selection = await showConfirmationDialog(
        context: context,
        title: AppLocalizations.of(context).submissionDeleteTitle,
        description: AppLocalizations.of(context).submissionDeleteMessage,
      );

      if (!context.mounted) return;
      final completer = Completer<void>();
      http.Response? response;
      showStatusModal(
        context: context,
        completer: completer,
        failureDetailsGenerator: () =>
            responseFailureDetailsGenerator(response),
      );

      if (!selection) return;
      response = await AuthManager.instance.fetch(http.Request("DELETE", uri));
      if (response != null && response.statusCode == 200) {
        widget.onDelete?.call();
        completer.complete();
        return;
      }
      completer.completeError("");
    }

    Widget? image;
    if (widget.includeImage) {
      if (blurHashImage == null) {
        image = SizedBox(
          width: 224,
          height: 224,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      image ??= widget.data.assetUri() != null
          ? FadeInImage.memoryNetwork(
              placeholder: blurHashImage!,
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
                          blurHashImage!,
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
              child: Image.memory(blurHashImage!, width: 64, height: 64),
            );
      image = AuthManager.instance.authenticatedUserIsAdmin
          ? InkWell(
              onTap: () => context.navigateTo(
                SubmissionDetailsRoute(
                  submissionId: widget.data.id,
                  data: widget.data,
                ),
              ),
              hoverColor: Colors.transparent,
              child: SizedBox(
                width: 224,
                height: 224,
                child: Hero(
                  tag: "submissionImage${widget.data.id}",
                  child: image,
                ),
              ),
            )
          : AspectRatio(aspectRatio: 1 / 1, child: image);
    }

    final card = SizedBox(
      width: windowSizeClass > WindowSizeClass.compact ? 224 : null,
      child: Card.filled(
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.includeImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: image,
              ),
              Divider(height: 1),
            ],
            Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: [
                    if (widget.includeImage) ...[
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
                    ],
                    Chip(
                      label: Text(
                        GetTimeAgo.parse(
                          widget.data.submittedAt,
                          locale: AppLocalizations.of(context).localeName,
                          pattern: dateFormat(context).pattern,
                        ),
                      ),
                    ),
                    if (!widget.includeImage &&
                        widget.data.moderationReason == null)
                      Chip(
                        backgroundColor: widget.data.moderated
                            ? null
                            : colorScheme.errorContainer,
                        avatar: Icon(
                          widget.data.moderated
                              ? Icons.check_circle_outline_outlined
                              : Icons.report_outlined,
                        ),
                        label: Builder(
                          builder: (context) => Text(
                            widget.data.moderated
                                ? "Deemed appropriate"
                                : "Pending moderation",
                            style: DefaultTextStyle.of(context).style.copyWith(
                              color: widget.data.moderated
                                  ? null
                                  : colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    if (!widget.includeImage &&
                        AuthManager.instance.authenticatedUserIsAdmin)
                      ActionChip(
                        avatar: Icon(Icons.share),
                        label: Text("Share"),
                        onPressed: () => Clipboard.setData(
                          ClipboardData(
                            text: Uri.parse(
                              "${Uri.base.origin}/submissions/${widget.data.id}",
                            ).toString(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if ((!widget.includeImage &&
                    widget.data.moderationReason != null &&
                    AuthManager.instance.authenticatedUserIsAdmin) ||
                (widget.data.status == "censored" &&
                    (widget.data.moderationReason != null ||
                        !widget.includeImage)))
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: [
                      if (!widget.includeImage &&
                          widget.data.moderationReason != null)
                        Chip(
                          backgroundColor: widget.data.moderated
                              ? null
                              : colorScheme.errorContainer,
                          avatar: Icon(Icons.report_outlined),
                          label: Builder(
                            builder: (context) => Text(
                              widget.data.moderated
                                  ? "Blocked"
                                  : "Pending moderation",
                              style: DefaultTextStyle.of(context).style
                                  .copyWith(
                                    color: widget.data.moderated
                                        ? null
                                        : colorScheme.onErrorContainer,
                                  ),
                            ),
                          ),
                        ),
                      if (widget.data.moderationReason != null ||
                          widget.data.status == "censored")
                        Chip(
                          label: Text(
                            widget.data.moderationReasonDisplay(context) ?? "–",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 8,
                          ),
                          deleteIcon: Icon(Icons.edit),
                          onDeleted: !widget.includeImage
                              ? setModerationReason
                              : null,
                        ),
                    ],
                  ),
                ),
              ),
            if (!widget.includeImage &&
                AuthManager.instance.authenticatedUserIsAdmin) ...[
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 2),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: [
                      Chip(
                        avatar: Icon(Icons.keyboard_arrow_up),
                        label: Text(
                          NumberFormat.decimalPatternDigits(
                            locale: AppLocalizations.of(context).localeName,
                            decimalDigits: 3,
                          ).format(widget.data.validationWeightPositive),
                        ),
                      ),
                      Chip(
                        avatar: Icon(Icons.keyboard_arrow_down),
                        label: Text(
                          NumberFormat.decimalPatternDigits(
                            locale: AppLocalizations.of(context).localeName,
                            decimalDigits: 3,
                          ).format(widget.data.validationWeightNegative),
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
                        avatar: Icon(Icons.credit_score),
                        label: Text(
                          NumberFormat.decimalPatternDigits(
                            locale: AppLocalizations.of(context).localeName,
                            decimalDigits: 3,
                          ).format(
                            (1 + widget.data.validationWeightPositive) /
                                (2 +
                                    widget.data.validationWeightPositive +
                                    widget.data.validationWeightNegative),
                          ),
                        ),
                      ),
                      Chip(
                        avatar: Icon(Icons.topic_outlined),
                        label: Text(
                          widget.data.category != null
                              ? availableCategories.any(
                                      (c) => c.name == widget.data.category,
                                    )
                                    ? availableCategories
                                              .firstWhere(
                                                (c) =>
                                                    c.name ==
                                                    widget.data.category,
                                              )
                                              .displayName ??
                                          widget.data.category!
                                    : widget.data.category!
                              : "–",
                        ),
                        deleteIcon: Icon(Icons.edit),
                        onDeleted: availableCategories.isNotEmpty
                            ? setCategory
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                          ? setStatus
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
                      onPressed: deleteSubmission,
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
}

class SubmissionTargetWidget extends StatefulWidget {
  final int? effectiveProject;
  final ProjectData? effectiveProjectData;
  final String effectiveUser;
  final UserData? effectiveUserData;
  final ValueNotifier<bool> optionLeftAligned;

  const SubmissionTargetWidget({
    super.key,
    required this.effectiveProject,
    required this.effectiveProjectData,
    required this.effectiveUser,
    required this.effectiveUserData,
    required this.optionLeftAligned,
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
    widget.optionLeftAligned.addListener(opUpdate);
    _controller = AnimationController(duration: Durations.medium1, vsync: this);
  }

  @override
  void dispose() {
    widget.optionLeftAligned.removeListener(opUpdate);
    _controller.dispose();
    super.dispose();
  }

  void opUpdate() {
    if (mounted) setState(() {});
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
          children: [
            AnimatedAlign(
              duration: Durations.medium1,
              curve: Curves.easeInOutCubic,
              alignment: widget.optionLeftAligned.value
                  ? Alignment.topLeft
                  : Alignment.topRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _controller.isCompleted
                    ? _controller.reverse()
                    : _controller.forward(),
                onLongPress: () => widget.optionLeftAligned.value =
                    !widget.optionLeftAligned.value,
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
                                type: widget.effectiveProject != null
                                    ? ListType.project
                                    : ListType.user,
                                onDelete: () {
                                  if (context.router.stack.length > 1) {
                                    context.router.pop();
                                  } else {
                                    context.navigateTo(MainRoute());
                                  }
                                },
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

class SubmissionsPageControl extends StatelessWidget {
  final int page;
  final int availablePages;
  final ({String? project, String? user}) routeParams;
  final bool enabled;

  const SubmissionsPageControl({
    super.key,
    required this.page,
    required this.availablePages,
    required this.routeParams,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final tileCount = (constraints.maxWidth / 40).floor() - 2;
      assert(tileCount > 0);

      var startPage = (page - (tileCount / 2).floor()).clamp(1, availablePages);
      var endPage = (startPage + tileCount - 1).clamp(1, availablePages);

      while (endPage - startPage + 1 < tileCount && startPage > 1) {
        startPage = (startPage - 1).clamp(1, availablePages);
      }

      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: page > 1
                ? () {
                    context.navigateTo(
                      SubmissionsRoute(
                        project: routeParams.project,
                        user: routeParams.user,
                        page: page - 1,
                      ),
                    );
                  }
                : null,
            icon: Icon(Icons.navigate_before),
          ),
          for (var i = startPage; i <= endPage; i++)
            (i == page ? IconButton.filledTonal : IconButton.new)(
              onPressed: () {
                if (i == page) return;
                context.navigateTo(
                  SubmissionsRoute(
                    project: routeParams.project,
                    user: routeParams.user,
                    page: i,
                  ),
                );
              },
              icon: Builder(builder: (context) => Text("$i")),
            ),
          IconButton(
            onPressed: page < availablePages
                ? () {
                    context.navigateTo(
                      SubmissionsRoute(
                        project: routeParams.project,
                        user: routeParams.user,
                        page: page + 1,
                      ),
                    );
                  }
                : null,
            icon: Icon(Icons.navigate_next),
          ),
        ],
      );
    },
  );
}

@RoutePage()
class SubmissionDetailsPage extends StatefulWidget {
  final int submissionId;
  final SubmissionData? data;
  const SubmissionDetailsPage({
    super.key,
    @PathParam("id") required this.submissionId,
    this.data,
  });

  @override
  State<SubmissionDetailsPage> createState() => _SubmissionDetailsPageState();
}

class _SubmissionDetailsPageState extends State<SubmissionDetailsPage> {
  SubmissionData? data;
  ProjectData? project;
  UserData? user;
  Uint8List? blurHashImage;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      data = widget.data;
      if (mounted) setState(() {});
      _loadBlurHash();
      _loadMetadata();
    } else {
      _loadData().then((_) {
        _loadBlurHash();
        _loadMetadata();
      });
    }
  }

  @override
  void didUpdateWidget(SubmissionDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.submissionId != widget.submissionId) {
      if (widget.data != null) {
        data = widget.data;
        if (mounted) setState(() {});

        _loadBlurHash();
        _loadMetadata();
      } else {
        _loadData().then((_) {
          _loadBlurHash();
          _loadMetadata();
        });
      }
    }
  }

  Future<void> _loadData() async {
    final response = await AuthManager.instance.fetch(
      http.Request(
        "GET",
        Uri.parse(
          "${ApiManager.baseUri}/projects/u/submissions/${widget.submissionId}",
        ),
      ),
    );
    if (response != null && response.statusCode == 200) {
      data = SubmissionData.fromJson(jsonDecode(response.body));
      if (mounted) setState(() {});
    } else {
      if (mounted) context.replaceRoute(MainRoute());
    }
  }

  Future<void> _loadBlurHash() async {
    final hash = data!.assetBlurHash;

    if (_blurHashCache.containsKey(hash)) {
      blurHashImage = _blurHashCache[hash];
      if (mounted) setState(() {});
      return;
    }
    _blurHashCache[hash] = null; // blocking

    try {
      final decoded = await compute(_decodeBlurHash, hash);
      _blurHashCache[hash] = decoded;
      blurHashImage = decoded;
      if (mounted) setState(() {});
    } catch (e) {
      if (kDebugMode) print("Failed to decode BlurHash: $e");
    }
  }

  void _loadMetadata() {
    ProjectRegistry.instance.get(data!.projectId).then((projectData) {
      project = projectData;
      if (mounted) setState(() {});
    });
    UserRegistry.instance.get(data!.user).then((userData) {
      user = userData;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return Center(child: CircularProgressIndicator());

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final windowSizeClass = WindowSizeClass.of(context);

    Widget? image;
    if (blurHashImage == null) {
      image = SizedBox(
        width: 224,
        height: 224,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    image ??= data!.assetUri() != null
        ? Hero(
            tag: "submissionImage${data!.id}",
            child: FadeInImage.memoryNetwork(
              placeholder: blurHashImage!,
              image: data!.assetUri().toString(),
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
                          blurHashImage!,
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
              fit: BoxFit.contain,
            ),
          )
        : FittedBox(child: Image.memory(blurHashImage!, width: 64, height: 64));

    void onDelete({bool toUser = false}) {
      if (context.router.stack.length > 1) {
        context.router.pop();
      } else {
        context.navigateTo(
          toUser ? SubmissionsRoute(user: data!.user) : MainRoute(),
        );
      }
    }

    final isColumn = windowSizeClass <= WindowSizeClass.medium;
    final size = MediaQuery.sizeOf(context);
    return (isColumn ? Column.new : Row.new)(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: isColumn ? size.height * 0.4 : double.infinity,
            maxWidth: isColumn ? double.infinity : size.width * 0.75,
          ),
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Card.outlined(clipBehavior: Clip.antiAlias, child: image),
          ),
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: SizedBox(
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SubmissionWidget(
                      data: data!,
                      includeImage: false,
                      onUpdate: _loadData,
                      onDelete: () => onDelete(toUser: true),
                    ),
                    SizedBox(height: 8),
                    AnimatedSize(
                      duration: Durations.medium1,
                      curve: Curves.easeInOutCubicEmphasized,
                      child: user != null && project != null
                          ? Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ListWidget(
                                  data: user!.toJson(),
                                  type: ListType.user,
                                  onDelete: onDelete,
                                ),
                                ListWidget(
                                  data: project!.toJson(),
                                  type: ListType.project,
                                  onDelete: onDelete,
                                ),
                              ],
                            )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

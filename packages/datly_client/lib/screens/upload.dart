import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../registry.dart';
import '../widgets/radio_dialog.dart';
import '../widgets/status_modal.dart';
import 'terms.dart';

@RoutePage()
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with WidgetsBindingObserver {
  int cameraIndex = 0;
  CameraController? controller;

  bool error = false;
  bool noCamera = false;

  int? projectIndex;
  ProjectData? projectIndexCache;
  List<int> projects = [];

  @override
  void initState() {
    super.initState();
    camerasInitialize().then((_) => loadStoredCamera());
    fetchProjects();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  Future<void> loadStoredCamera() async {
    bool loaded = false;
    if (prefs.containsKey("camera")) {
      cameraIndex = prefs.getInt("camera")!;
      loaded = true;
    }

    final availableCameras = await cameras.future;
    if (availableCameras.isEmpty) {
      error = true;
      noCamera = true;
      if (mounted) setState(() {});
      return;
    }

    if (!loaded && cameraIndex == 0 && availableCameras.length > 1) {
      final backCameraIndex = availableCameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      if (backCameraIndex != -1) cameraIndex = backCameraIndex;
    }

    await _initializeCameraController(availableCameras[cameraIndex]);
  }

  Future<void> _initializeCameraController(
    CameraDescription description,
  ) async {
    controller = CameraController(
      description,
      ResolutionPreset.low,
      enableAudio: false,
    );

    await controller!.initialize().onError((_, _) {
      error = true;
      if (mounted) setState(() {});
    });
    if (!error && mounted) setState(() {});
  }

  Future<void> fetchProjects() async {
    if (AuthManager.instance.authenticatedUser == null) return;
    projects = AuthManager.instance.authenticatedUser!.projects;
    for (final project in AuthManager.instance.authenticatedUser!.projects) {
      final res = await ProjectRegistry.instance.get(project);
      if (res == null) {
        projects.remove(project);
      }
    }
    if (mounted) setState(() {});

    if (projects.isEmpty) return;
    projectIndex ??= 0;
    projectIndexCache = await ProjectRegistry.instance.get(
      projects[projectIndex!],
    );
  }

  void switchCamera() async {
    final availableCameras = await cameras.future;

    if (!mounted) return;
    final selection = await showRadioDialog(
      context: context,
      title: AppLocalizations.of(context).selectCamera,
      initialValue: availableCameras[cameraIndex],
      items: availableCameras,
      titleGenerator: (item) => item.name,
      subtitleGenerator: (item) =>
          "${switch (item.lensDirection) {
            CameraLensDirection.back => AppLocalizations.of(context).selectCameraDescriptionBack,
            CameraLensDirection.front => AppLocalizations.of(context).selectCameraDescriptionFront,
            CameraLensDirection.external => AppLocalizations.of(context).selectCameraDescriptionExternal,
          }} (${item.sensorOrientation}°)",
      iconGenerator: (item) => Icon(switch (item.lensDirection) {
        CameraLensDirection.back => Icons.camera_rear,
        CameraLensDirection.front => Icons.camera_front,
        CameraLensDirection.external => Icons.outbond_outlined,
      }),
    );
    if (selection == null) return;

    final tmpIndex = availableCameras.indexOf(selection);
    if (tmpIndex == cameraIndex) return;

    cameraIndex = tmpIndex;
    prefs.setInt("camera", cameraIndex);
    controller?.dispose();
    controller = null;

    if (mounted) setState(() {});
    await _initializeCameraController(selection);
  }

  void switchProject() async {
    final List<ProjectData> projectData = (await Future.wait<ProjectData?>(
      projects.map((e) async => (await ProjectRegistry.instance.get(e))),
    )).whereType<ProjectData>().toList();

    if (!mounted) return;
    final selection = await showRadioDialog(
      context: context,
      title: AppLocalizations.of(context).selectProject,
      initialValue: projectIndex != null ? projectData[projectIndex!] : null,
      items: projectData,
      titleGenerator: (item) => item.title,
      subtitleGenerator: (item) => item.description,
    );
    if (selection == null) return;

    projectIndex = projectData.indexOf(selection);
    projectIndexCache = selection;
    if (mounted) setState(() {});
  }

  void submit() async {
    final imageRaw = await controller!.takePicture();
    await controller!.pausePreview();
    var image = img.decodeImage(await imageRaw.readAsBytes())!;
    if (!mounted) return;

    UploadConsentResult? signature =
        await showModalBottomSheet<UploadConsentResult>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (_) => UploadConsentModal(),
        );
    if (signature == null) {
      await controller!.resumePreview();
      return;
    }
    if (!mounted) return;

    final completer = Completer<void>();
    http.Response? response;
    showStatusModal(
      context: context,
      completer: completer,
      failureDetailsGenerator: () {
        try {
          if (jsonDecode(response!.body) case {"error": String errorMessage}) {
            return errorMessage;
          }
        } catch (_) {}
        return "Status code: ${response?.statusCode ?? "<unavailable>"}\n${response?.body}"
            .trim();
      },
    );

    final project = await ProjectRegistry.instance.get(projects[projectIndex!]);
    if (project == null) {
      completer.completeError("Project not found");
      return;
    }

    response = await AuthManager.instance.fetch(
      http.MultipartRequest(
          "POST",
          Uri.parse(
            "${ApiManager.baseUri}/projects/${project.id}/submissions",
          ).replace(
            queryParameters: {
              "signature": signature.signature,
              if (signature.signatureParental != null)
                "signatureParental": signature.signatureParental!,
              "signatureSnapshot": signature.signatureSnapshot,
              "consentVersion": signature.consentVersion.toString(),
            },
          ),
        )
        ..files.add(
          http.MultipartFile.fromBytes(
            "",
            img.encodePng(image),
            contentType: http.MediaType.parse("image/png"),
          ),
        ),
    );

    await controller!.resumePreview();
    response != null && response.statusCode == 201
        ? completer.complete()
        : completer.completeError("Upload failed");
  }

  @override
  Widget build(BuildContext context) {
    Widget previewWidget() => Card.outlined(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: CameraPreview(controller!),
        ),
      ),
    );
    Widget errorWidget() => ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.device_unknown, size: 48),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).cameraNotFound,
            textAlign: TextAlign.center,
            style: TextTheme.of(context).headlineSmall!.copyWith(height: 1),
          ),
          Text(
            camerasPermissionDenied
                ? AppLocalizations.of(context).cameraErrorPermission
                : AppLocalizations.of(context).cameraErrorUnavailable,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          SizedBox(height: 16),
          (camerasPermissionDenied ? FilledButton.icon : OutlinedButton.icon)
              .call(
                onPressed: () async {
                  controller?.dispose();
                  controller = null;
                  error = false;
                  if (mounted) setState(() {});

                  await camerasInitialize();
                  await loadStoredCamera();
                },
                label: Text(AppLocalizations.of(context).retry),
                icon: Icon(Icons.refresh),
              ),
        ],
      ),
    );
    Widget projectWidget() => Align(
      alignment: Alignment.bottomLeft,
      child: AnimatedSwitcher(
        duration: Durations.medium1,
        switchInCurve: Curves.easeInOutCubicEmphasized,
        switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
        transitionBuilder: (child, animation) => SlideTransition(
          position: (Tween<Offset>(
            begin: Offset(0, 1.1),
            end: Offset(0, 0),
          )).animate(animation),
          child: child,
        ),
        child:
            controller != null &&
                projectIndex != null &&
                projectIndexCache != null
            ? Container(
                key: ValueKey("container"),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorScheme.of(context).surface,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                  ),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.6,
                ),
                child: AnimatedSize(
                  duration: Durations.medium1,
                  curve: Curves.easeInOutCubicEmphasized,
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectIndexCache!.title,
                        style: TextTheme.of(context).titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (projectIndexCache!.description?.isNotEmpty ?? false)
                        Text(
                          projectIndexCache!.description!,
                          style: TextTheme.of(context).bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );

    final widget = Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          !error
              ? controller != null && controller!.value.isInitialized
                    ? Center(heightFactor: 1.2, child: previewWidget())
                    : Center(child: CircularProgressIndicator())
              : noCamera
              ? Center(child: errorWidget())
              : Center(child: Icon(Icons.error_outline, size: 48)),
          projectWidget(),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: Durations.medium1,
        switchInCurve: Curves.easeInOutCubicEmphasized,
        switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
        transitionBuilder: (child, animation) => SlideTransition(
          position: (Tween<Offset>(
            begin: Offset(0, 1.1),
            end: Offset(0, 0),
          )).animate(animation),
          child: child,
        ),
        child: controller != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: switchCamera,
                    child: AnimatedSwitcher(
                      duration: Durations.medium1,
                      switchInCurve: Curves.easeInOutCubicEmphasized,
                      switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
                      child: Icon(
                        switch (controller!.description.lensDirection) {
                          CameraLensDirection.back => Icons.camera_rear,
                          CameraLensDirection.front => Icons.camera_front,
                          CameraLensDirection.external => Icons.cameraswitch,
                        },
                      ),
                    ),
                  ),
                  if (projects.isNotEmpty) ...[
                    SizedBox(height: 4),
                    FloatingActionButton(
                      onPressed: projects.isNotEmpty ? switchProject : null,
                      child: Icon(Icons.assignment),
                    ),
                    SizedBox(height: 8),
                    FloatingActionButton.large(
                      onPressed: projects.isNotEmpty ? submit : null,
                      child: Icon(Icons.camera),
                    ),
                  ],
                ],
              )
            : null,
      ),
    );
    return Shortcuts(
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.space): UploadTriggerIntent(),
      },
      child: Actions(
        actions: {UploadTriggerIntent: UploadTriggerAction(submit)},
        child: widget,
      ),
    );
  }
}

class UploadTriggerIntent extends Intent {}

class UploadTriggerAction extends Action<UploadTriggerIntent> {
  VoidCallback onUpdate;
  UploadTriggerAction(this.onUpdate);

  @override
  void invoke(_) => onUpdate();
}

class UploadConsentModal extends StatefulWidget {
  const UploadConsentModal({super.key});

  @override
  State<UploadConsentModal> createState() => _UploadConsentModalState();
}

typedef UploadConsentResult = ({
  String signature,
  String? signatureParental,
  String signatureSnapshot,
  int consentVersion,
});

class _UploadConsentModalState extends State<UploadConsentModal> {
  static const int consentVersion = 1;
  static const String consentVersionDate = "2025-12-29";

  late bool checkExplanation;
  late bool checkPolicy;
  late bool checkAge;
  late bool checkParental;

  late final TextEditingController signatureController;
  late final TextEditingController parentalSignatureController;

  @override
  void initState() {
    super.initState();

    checkExplanation = prefs.getBool("uploadConsentExplanation") ?? false;
    checkPolicy = prefs.getBool("uploadConsentPolicy") ?? false;
    checkAge = prefs.getBool("uploadConsentAge") ?? false;
    checkParental = false;

    signatureController = TextEditingController()..addListener(onUpdate);
    parentalSignatureController = TextEditingController()
      ..addListener(onUpdate);
  }

  @override
  void dispose() {
    signatureController.dispose();
    parentalSignatureController.dispose();
    super.dispose();
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  bool submitEnabled() =>
      checkExplanation &&
      checkPolicy &&
      signatureController.text.trim().isNotEmpty &&
      (checkAge ||
          (parentalSignatureController.text.trim().isNotEmpty &&
              checkParental));
  void submit() {
    prefs.setBool("uploadConsentExplanation", checkExplanation);
    prefs.setBool("uploadConsentPolicy", checkPolicy);
    prefs.setBool("uploadConsentAge", checkAge);

    final appLocalizations = AppLocalizations.of(context);
    final username = AuthManager.instance.authenticatedUser!.username;
    final snapshot =
        """
# ${appLocalizations.consentTitle}
#### ${appLocalizations.consentVersion(consentVersion.toString(), consentVersionDate)}

${appLocalizations.consentExplanation1}

${appLocalizations.consentExplanation2}

- [${checkExplanation ? "x" : " "}] ${appLocalizations.consentCheckbox}
- [${checkPolicy ? "x" : " "}] ${appLocalizations.consentPolicy(appLocalizations.loginPrivacyPolicy, appLocalizations.loginTermsOfService)}

---

- ${appLocalizations.consentSignature}: ${signatureController.text.trim()}
  - (${appLocalizations.consentSignatureLegal(username)})
- [${checkAge ? "x" : " "}] ${appLocalizations.consentAge}
${!checkAge ? """

---

- ${appLocalizations.consentSignatureParental}: ${parentalSignatureController.text.trim()}
  - (${appLocalizations.consentSignatureLegal(username)})
- [${checkParental ? "x" : " "}] ${appLocalizations.consentParental}
""" : ""}
---

[${appLocalizations.consentButton}]()"""
            .trim();

    Navigator.of(context).pop<UploadConsentResult>((
      signature: signatureController.text.trim(),
      signatureParental: checkAge
          ? null
          : parentalSignatureController.text.trim(),
      signatureSnapshot: snapshot,
      consentVersion: consentVersion,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    Widget divider = Padding(padding: EdgeInsets.all(8), child: Divider());
    Widget signatureField(TextEditingController controller, String label) =>
        ListTile(
          contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 16),
          title: TextField(
            controller: controller,
            autofillHints: [AutofillHints.name],
            maxLength: 128,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.draw),
              labelText: label,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: appLocalizations.consentSignatureName,
              helperText: appLocalizations.consentSignatureLegal(
                AuthManager.instance.authenticatedUser!.username,
              ),
              helperMaxLines: 5,
              counterText: "",
            ),
          ),
        );
    Widget signatureCheckbox(
      Text label,
      bool value,
      ValueChanged<bool?> onChanged,
    ) => CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: label,
      controlAffinity: ListTileControlAffinity.leading,
      visualDensity: VisualDensity.compact,
    );
    return DraggableScrollableSheet(
      minChildSize: 0.6,
      maxChildSize: 1.0,
      initialChildSize: 0.8,
      expand: false,
      builder: (_, controller) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ListView(
          controller: controller,
          shrinkWrap: true,
          children: [
            SizedBox(height: 16),
            ListTile(
              title: Text(
                appLocalizations.consentTitle,
                style: TextTheme.of(context).headlineSmall,
              ),
              subtitle: Text(
                appLocalizations.consentVersion(
                  consentVersion.toString(),
                  consentVersionDate,
                ),
                style: TextTheme.of(context).bodyMedium,
              ),
            ),
            ListTile(
              title: Text(
                appLocalizations.consentExplanation1,
                textAlign: TextAlign.justify,
              ),
              dense: true,
            ),
            ListTile(
              title: Text(
                appLocalizations.consentExplanation2,
                textAlign: TextAlign.justify,
              ),
              dense: true,
            ),
            signatureCheckbox(
              Text(appLocalizations.consentCheckbox),
              checkExplanation,
              (value) {
                checkExplanation = value ?? false;
                if (mounted) setState(() {});
              },
            ),
            signatureCheckbox(
              Text.rich(
                TextSpan(
                  children: () {
                    final text = appLocalizations.consentPolicy(
                      "{privacyPolicy}",
                      "{termsOfService}",
                    );
                    final matches = RegExp(
                      r"(\{privacyPolicy\})|(\{termsOfService\})",
                    ).allMatches(text);

                    final children = <InlineSpan>[];
                    var cursor = 0;
                    for (final match in matches) {
                      if (match.start > cursor) {
                        children.add(
                          TextSpan(text: text.substring(cursor, match.start)),
                        );
                      }
                      final isPrivacy = match.group(0) == "{privacyPolicy}";
                      children.add(
                        TextSpan(
                          text: isPrivacy
                              ? appLocalizations.loginPrivacyPolicy
                              : appLocalizations.loginTermsOfService,
                          style: TextStyle(
                            color: ColorScheme.of(context).primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => showMarkdownDialog(
                              context: context,
                              origin: Uri.parse(
                                "${ApiManager.baseUri.replace(path: "")}/legal/${isPrivacy ? "privacy" : "terms"}",
                              ),
                            ),
                        ),
                      );
                      cursor = match.end;
                    }
                    if (cursor < text.length) {
                      children.add(TextSpan(text: text.substring(cursor)));
                    }
                    return children;
                  }(),
                ),
              ),
              checkPolicy,
              (value) {
                checkPolicy = value ?? false;
                if (mounted) setState(() {});
              },
            ),
            divider,
            signatureField(
              signatureController,
              appLocalizations.consentSignature,
            ),
            signatureCheckbox(Text(appLocalizations.consentAge), checkAge, (
              value,
            ) {
              checkAge = value ?? false;
              if (mounted) setState(() {});
            }),
            AnimatedSwitcher(
              duration: Durations.medium1,
              switchInCurve: Curves.easeInOutCubicEmphasized,
              switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
              child: checkAge
                  ? null
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        divider,
                        signatureField(
                          parentalSignatureController,
                          appLocalizations.consentSignatureParental,
                        ),
                        signatureCheckbox(
                          Text(appLocalizations.consentParental),
                          checkParental,
                          (value) {
                            checkParental = value ?? false;
                            if (mounted) setState(() {});
                          },
                        ),
                      ],
                    ),
            ),
            divider,
            ListTile(
              title: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: submitEnabled() ? submit : null,
                  icon: Icon(Icons.check),
                  label: Text(appLocalizations.consentButton),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../registry.dart';
import '../widgets/radio_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          !error
              ? controller != null && controller!.value.isInitialized
                    ? Center(
                        heightFactor: 1.5,
                        child: Card.outlined(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CameraPreview(controller!),
                            ),
                          ),
                        ),
                      )
                    : Center(child: CircularProgressIndicator())
              : noCamera
              ? Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.device_unknown, size: 48),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).cameraNotFound,
                          style: TextTheme.of(
                            context,
                          ).headlineSmall!.copyWith(height: 1),
                        ),
                        Text(
                          camerasPermissionDenied
                              ? AppLocalizations.of(
                                  context,
                                ).cameraErrorPermission
                              : AppLocalizations.of(
                                  context,
                                ).cameraErrorUnavailable,
                          maxLines: 3,
                        ),
                        SizedBox(height: 16),
                        (camerasPermissionDenied
                                ? FilledButton.icon
                                : OutlinedButton.icon)
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
                  ),
                )
              : Center(child: Icon(Icons.error_outline, size: 48)),
          Align(
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
                            if (projectIndexCache!.description?.isNotEmpty ??
                                false)
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
          ),
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
            ? LayoutBuilder(
                builder: (_, constraints) {
                  void onPressedSwitch() async {
                    final availableCameras = await cameras.future;

                    if (!context.mounted) return;
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
                      iconGenerator: (item) =>
                          Icon(switch (item.lensDirection) {
                            CameraLensDirection.back => Icons.camera_rear,
                            CameraLensDirection.front => Icons.camera_front,
                            CameraLensDirection.external =>
                              Icons.outbond_outlined,
                          }),
                    );
                    if (selection == null) return;
                    cameraIndex = availableCameras.indexOf(selection);
                    prefs.setInt("camera", cameraIndex);
                    controller?.dispose();
                    controller = null;
                    if (mounted) setState(() {});
                    await _initializeCameraController(selection);
                  }

                  void onPressedSelect() async {
                    final List<ProjectData> projectData =
                        (await Future.wait<ProjectData?>(
                          projects.map(
                            (e) async =>
                                (await ProjectRegistry.instance.get(e)),
                          ),
                        )).whereType<ProjectData>().toList();

                    if (!context.mounted) return;
                    final selection = await showRadioDialog(
                      context: context,
                      title: AppLocalizations.of(context).selectProject,
                      initialValue: projectIndex != null
                          ? projectData[projectIndex!]
                          : null,
                      items: projectData,
                      titleGenerator: (item) => item.title,
                      subtitleGenerator: (item) => item.description,
                    );
                    if (selection == null) return;
                    projectIndex = projectData.indexOf(selection);
                    projectIndexCache = selection;
                    if (mounted) setState(() {});
                  }

                  void onPressedCamera() async {
                    showModalBottomSheet(
                      context: context,
                      constraints: BoxConstraints(minWidth: 280, maxWidth: 560),
                      isDismissible: false,
                      requestFocus: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(top: 64, bottom: 64),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CircularProgressIndicator()],
                        ),
                      ),
                    );

                    final imageRaw = await controller!.takePicture();
                    await controller!.pausePreview();

                    await Future.delayed(Durations.long1);
                    var image = img.decodeImage(await imageRaw.readAsBytes())!;

                    final project = await ProjectRegistry.instance.get(
                      projects[projectIndex!],
                    );
                    final response = await AuthManager.instance.fetch(
                      http.MultipartRequest(
                          "PUT",
                          Uri.parse(
                            "${ApiManager.baseUri}/projects/${project!.id}/submissions",
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
                    // TODO: Implement dialog with success feedback
                    // ignore: unused_local_variable
                    final success =
                        response != null && response.statusCode == 201;

                    await Future.delayed(Durations.medium1);
                    await controller!.resumePreview();
                    if (context.mounted) context.pop();
                  }

                  final iconSwitch = Icon(
                    key: ValueKey(controller!.description.lensDirection),
                    switch (controller!.description.lensDirection) {
                      CameraLensDirection.back => Icons.camera_rear,
                      CameraLensDirection.front => Icons.camera_front,
                      CameraLensDirection.external => Icons.cameraswitch,
                    },
                  );
                  final iconSelect = Icon(Icons.assignment);
                  final iconCamera = Icon(Icons.camera);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: onPressedSwitch,
                        child: AnimatedSwitcher(
                          duration: Durations.medium1,
                          switchInCurve: Curves.easeInOutCubicEmphasized,
                          switchOutCurve:
                              Curves.easeInOutCubicEmphasized.flipped,
                          child: iconSwitch,
                        ),
                      ),
                      if (projects.isNotEmpty) ...[
                        SizedBox(height: 4),
                        FloatingActionButton(
                          onPressed: projects.isNotEmpty
                              ? onPressedSelect
                              : null,
                          child: iconSelect,
                        ),
                        SizedBox(height: 8),
                        FloatingActionButton.large(
                          onPressed: projects.isNotEmpty
                              ? onPressedCamera
                              : null,
                          child: iconCamera,
                        ),
                      ],
                    ],
                  );
                },
              )
            : null,
      ),
    );
  }
}

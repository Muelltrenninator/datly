import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

import 'api.dart';
import 'l10n/app_localizations.dart';
import 'main.gr.dart';
import 'widgets/title_bar.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainRoute.page,
      path: "/",
      guards: [AuthenticationGuard()],
      children: [
        AutoRoute(page: UploadRoute.page, path: ""),
        AutoRoute(page: SubmissionsRoute.page, path: "submissions"),
        AutoRoute(page: ListUsersRoute.page, path: "users"),
        AutoRoute(page: ListProjectsRoute.page, path: "projects"),
      ],
    ),
    AutoRoute(page: LoginRoute.page, path: "/login"),
    AutoRoute(page: ErrorRoute.page, path: "*"),
  ];

  // @override
  // List<AutoRouteGuard> get guards => [LogGuard()];
}

class AuthenticationGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    await AuthManager.instance.initializeCompleter.future;
    if (AuthManager.instance.authenticatedUser != null) {
      resolver.next(true);
    } else {
      resolver.next(false);
      router.replaceAll([const LoginRoute()]);
    }
  }
}

class LogGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    print(
      "[${DateTime.now().toUtc().toIso8601String()}] ${router.currentPath} (${router.current.name}) -> ${resolver.route.path} (${resolver.route.name})",
    );
    print(
      StackTrace.current
          .toString()
          .split("\n")
          .map(
            (e) =>
                (" " * "[${DateTime.now().toUtc().toIso8601String()}]".length) +
                e,
          )
          .join("\n"),
    );
    resolver.next(true);
  }
}

final Color themeColor = Color(0xFF9c27b0);
ColorScheme get colorSchemeLight => ColorScheme.fromSeed(seedColor: themeColor);
ColorScheme get colorSchemeDark =>
    ColorScheme.fromSeed(seedColor: themeColor, brightness: Brightness.dark);

late final SharedPreferencesWithCache prefs;

Completer<List<CameraDescription>> cameras = Completer();
bool camerasPermissionDenied = false;
Future<void> camerasInitialize() async {
  cameras = Completer();
  cameras.complete(
    await availableCameras().onError((e, _) {
      if (kDebugMode) print(e);
      switch (e) {
        case CameraException c when c.code == "CameraAccessDenied":
          camerasPermissionDenied = true;
          break;
      }
      return [];
    }),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks([
        "Google Sans Code",
        "Poppins",
      ], await DefaultAssetBundle.of(context).loadString("assets/OFL.txt"));
    });
    AuthManager.instance
      ..addListener(onUpdate)
      ..initialize();

    if (kIsWeb) web.document.getElementById("loaderContainer")?.remove();
  }

  @override
  void dispose() {
    AuthManager.instance.removeListener(onUpdate);
    super.dispose();
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Datly",
      theme: ThemeData(colorScheme: colorSchemeLight).withYear2024(),
      darkTheme: ThemeData(colorScheme: colorSchemeDark).withYear2024(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: AppRouter().config(),
    );
  }
}

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final ValueNotifier<bool> _immersiveMode;

  @override
  void initState() {
    super.initState();
    _immersiveMode = ValueNotifier(prefs.getBool("immersiveMode") ?? false);
    _immersiveMode.addListener(onUpdate);
  }

  @override
  void dispose() {
    _immersiveMode.removeListener(onUpdate);
    super.dispose();
  }

  void onUpdate() {
    if (_immersiveMode.value == true) {
      prefs.setBool("immersiveMode", true);
    } else {
      prefs.remove("immersiveMode");
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: {
      LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.alt,
        LogicalKeyboardKey.keyI,
      ): ImmersiveModeIntent(),
      LogicalKeySet(LogicalKeyboardKey.altGraph, LogicalKeyboardKey.keyI):
          ImmersiveModeIntent(),
    },
    child: Actions(
      actions: {ImmersiveModeIntent: ImmersiveModeAction(_immersiveMode)},
      child: Scaffold(
        appBar: TitleBar(
          backgroundColor: _immersiveMode.value ? Colors.transparent : null,
        ),
        extendBodyBehindAppBar: _immersiveMode.value,
        body: AutoRouter(),
      ),
    ),
  );
}

class ImmersiveModeIntent extends Intent {
  const ImmersiveModeIntent();
}

class ImmersiveModeAction extends Action<ImmersiveModeIntent> {
  final ValueNotifier<bool> enabledNotifier;
  ImmersiveModeAction(this.enabledNotifier);

  @override
  void invoke(covariant ImmersiveModeIntent intent) =>
      enabledNotifier.value = !enabledNotifier.value;
}

extension OnColor on Color {
  Color onColor() {
    final brightness = computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }
}

extension TitleCase on String {
  String toTitleCase() {
    if (length <= 1) return toUpperCase();
    final words = split(" ");
    final capitalized = words.map(
      (word) =>
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : "",
    );
    return capitalized.join(" ");
  }
}

extension on ThemeData {
  ThemeData withYear2024() => copyWith(
    sliderTheme: sliderTheme.copyWith(year2023: false),
    progressIndicatorTheme: progressIndicatorTheme.copyWith(year2023: false),
  );
}

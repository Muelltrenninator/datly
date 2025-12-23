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
    AutoRoute(
      page: LoginRoute.page,
      path: "/login",
      guards: [ReverseAuthenticationGuard()],
    ),
    AutoRoute(page: ErrorRoute.page, path: "*"),
  ];
}

class AuthenticationGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (AuthManager.instance.authenticatedUser != null) {
      resolver.next(true);
    } else {
      resolver.redirectUntil(LoginRoute());
    }
  }
}

class ReverseAuthenticationGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (AuthManager.instance.authenticatedUser == null) {
      resolver.next(true);
    } else {
      resolver.redirectUntil(MainRoute());
    }
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
  // await BrowserContextMenu.disableContextMenu();

  prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  await AuthManager.instance.initialize();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();

    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks([
        "Google Sans Code",
        "Poppins",
      ], await DefaultAssetBundle.of(context).loadString("assets/OFL.txt"));
    });

    if (kIsWeb) web.document.getElementById("loaderContainer")?.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Datly",
      theme: ThemeData(colorScheme: colorSchemeLight).modified(),
      darkTheme: ThemeData(colorScheme: colorSchemeDark).modified(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _appRouter.config(
        reevaluateListenable: AuthManager.instance,
      ),
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

class ImmersiveModeIntent extends Intent {}

class ImmersiveModeAction extends Action<ImmersiveModeIntent> {
  final ValueNotifier<bool> enabledNotifier;
  ImmersiveModeAction(this.enabledNotifier);

  @override
  void invoke(_) => enabledNotifier.value = !enabledNotifier.value;
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
  ThemeData modified() => copyWith(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ).withYear2024();
  ThemeData withYear2024() => copyWith(
    sliderTheme: sliderTheme.copyWith(year2023: false),
    progressIndicatorTheme: progressIndicatorTheme.copyWith(year2023: false),
  );
}

/// Implementation of Material You Window Size Classes.
///
/// The current implementation is based on the guidelines from Material You
/// Expressive design documentation.
/// 
/// The sizes can be compared using the standard comparison operators (<, >,
/// <=,  >=). This is useful for adapting layouts based on the current window size
/// class.
///
/// See also:
/// - https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowSizeClass {
  compact(to: 599),
  medium(from: 600, to: 839),
  expanded(from: 840, to: 1199),
  large(from: 1200, to: 1599),
  extraLarge(from: 1600);

  final int? from;
  final int? to;
  const WindowSizeClass({this.from, this.to});

  factory WindowSizeClass.of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return WindowSizeClass.values.firstWhere(
      (sizeClass) =>
          (sizeClass.from == null || width >= sizeClass.from!) &&
          (sizeClass.to == null || width <= sizeClass.to!),
    );
  }

  bool operator <(WindowSizeClass other) => index < other.index;
  bool operator >(WindowSizeClass other) => index > other.index;
  bool operator <=(WindowSizeClass other) => index <= other.index;
  bool operator >=(WindowSizeClass other) => index >= other.index;
}

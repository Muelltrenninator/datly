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
        AutoRoute(
          page: UploadValidateParentRoute.page,
          path: "",
          children: [
            AutoRoute(page: UploadRoute.page, path: ""),
            AutoRoute(page: ValidateRoute.page, path: "validate"),
          ],
        ),
        AutoRoute(page: SubmissionsRoute.page, path: "submissions"),
        AutoRoute(page: ListUsersRoute.page, path: "users"),
        AutoRoute(page: ListProjectsRoute.page, path: "projects"),
      ],
    ),
    AutoRoute(
      page: LoginRegisterParentRoute.page,
      path: "/",
      guards: [ReverseAuthenticationGuard()],
      children: [
        AutoRoute(page: LoginRoute.page, path: "login"),
        AutoRoute(page: RegisterRoute.page, path: "register"),
      ],
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

final Color themeColor = Color(0xff9c27b0);
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
      debugShowCheckedModeBanner: false,
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
  @override
  void initState() {
    super.initState();
    ImmersiveModeAction.enabledNotifier.addListener(onUpdate);
  }

  @override
  void dispose() {
    ImmersiveModeAction.enabledNotifier.removeListener(onUpdate);
    super.dispose();
  }

  void onUpdate() {
    if (ImmersiveModeAction.enabledNotifier.value == true) {
      if (kIsWeb) web.document.documentElement?.requestFullscreen();
      prefs.setBool("immersiveMode", true);
    } else {
      if (kIsWeb) web.document.exitFullscreen();
      prefs.remove("immersiveMode");
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final immersiveMode = ImmersiveModeAction.enabledNotifier.value;
    return Shortcuts(
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
        actions: {ImmersiveModeIntent: ImmersiveModeAction()},
        child: Scaffold(
          appBar: TitleBar(
            backgroundColor: immersiveMode ? Colors.transparent : null,
            scrollUnserElevation:
                context.router.currentUrl != "/" &&
                context.router.currentUrl != "/validate",
          ),
          extendBodyBehindAppBar: immersiveMode,
          body: AutoRouter(),
        ),
      ),
    );
  }
}

class ImmersiveModeIntent extends Intent {}

class ImmersiveModeAction extends Action<ImmersiveModeIntent> {
  static ValueNotifier<bool> enabledNotifier = ValueNotifier(
    prefs.getBool("immersiveMode") ?? false,
  );

  @override
  void invoke(_) => enabledNotifier.value = !enabledNotifier.value;
}

@RoutePage()
class UploadValidateParentPage extends StatefulWidget {
  const UploadValidateParentPage({super.key});

  @override
  State<UploadValidateParentPage> createState() =>
      _UploadValidateParentPageState();
}

class _UploadValidateParentPageState extends State<UploadValidateParentPage> {
  @override
  void initState() {
    super.initState();
    ImmersiveModeAction.enabledNotifier.addListener(onUpdate);
  }

  @override
  void dispose() {
    ImmersiveModeAction.enabledNotifier.removeListener(onUpdate);
    super.dispose();
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mobile = WindowSizeClass.of(context) <= WindowSizeClass.medium;
    final narrowHeight = MediaQuery.sizeOf(context).height <= 800;
    return AutoTabsRouter.pageView(
      routes: [UploadRoute(), ValidateRoute()],
      physics: NeverScrollableScrollPhysics(),
      builder: (context, child, pageController) {
        final tabsRouter = AutoTabsRouter.of(context);
        final immersiveMode = ImmersiveModeAction.enabledNotifier.value;
        if (immersiveMode) return child;
        return Scaffold(
          body: !mobile
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    NavigationRail(
                      backgroundColor: Colors.transparent,
                      selectedIndex: tabsRouter.activeIndex,
                      onDestinationSelected: tabsRouter.setActiveIndex,
                      leadingAtTop: true,
                      labelType: NavigationRailLabelType.selected,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.upload_file),
                          label: Text(
                            AppLocalizations.of(context).navigationUpload,
                          ),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.check),
                          label: Text(
                            AppLocalizations.of(context).navigationValidate,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Card.outlined(
                        margin: EdgeInsets.only(bottom: 4, right: 4),
                        child: child,
                      ),
                    ),
                  ],
                )
              : child,
          bottomNavigationBar: mobile
              ? NavigationBar(
                  selectedIndex: tabsRouter.activeIndex,
                  onDestinationSelected: tabsRouter.setActiveIndex,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  height: narrowHeight ? 60 : null,
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.upload_file),
                      label: AppLocalizations.of(context).navigationUpload,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.approval),
                      label: AppLocalizations.of(context).navigationValidate,
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
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

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'main.gr.dart';
import 'widgets/title_bar.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainRoute.page,
      path: "/",
      initial: true,
      guards: [AuthenticationGuard()],
      children: [
        AutoRoute(page: UploadRoute.page, path: ""),
        AutoRoute(page: Upload2Route.page, path: "upload2"),
      ],
    ),
    AutoRoute(page: LoginRoute.page, path: "/login"),
    AutoRoute(page: ErrorRoute.page, path: "*"),
  ];
}

class AuthenticationGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (!AuthManager.instance.initializeCompleter.isCompleted ||
        (AuthManager.instance.authenticatedUser != null &&
            router.currentPath != "/login")) {
      resolver.next(true);
    } else {
      resolver.next(false);
      router.push(LoginRoute());
    }
  }
}

final Color themeColor = Color(0xFF9c27b0);
ColorScheme get colorSchemeLight => ColorScheme.fromSeed(seedColor: themeColor);
ColorScheme get colorSchemeDark =>
    ColorScheme.fromSeed(seedColor: themeColor, brightness: Brightness.dark);

late final SharedPreferencesWithCache prefs;

void main() {
  usePathUrlStrategy();
  SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  ).then((value) => prefs = value);

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
    AuthManager.instance.addListener(onUpdate);
    AuthManager.instance.initialize();
  }

  @override
  void dispose() {
    AuthManager.instance.removeListener(onUpdate);
    super.dispose();
  }

  void onUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Datly",
      theme: ThemeData(colorScheme: colorSchemeLight),
      darkTheme: ThemeData(colorScheme: colorSchemeDark),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter().config(),
    );
  }
}

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter.pageView(
      routes: [UploadRoute(), Upload2Route()],
      physics: NeverScrollableScrollPhysics(),
      builder: (_, child, pageController) =>
          Scaffold(appBar: TitleBar(), body: child),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:datly/generated/gitbaker.g.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'password_change_dialog.dart';

class TitleBarTitle extends StatelessWidget {
  final GestureTapCallback? onTap;
  const TitleBarTitle({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      hoverColor: Colors.transparent,
      child: Hero(
        tag: "TitleBarTitle",
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flourescent_rounded),
              SizedBox(width: 4),
              Builder(
                builder: (context) => Text(
                  "Datly",
                  style: DefaultTextStyle.of(context).style.copyWith(
                    fontFamily: "Poppins",
                    fontSize: TextTheme.of(context).titleLarge?.fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  const TitleBar({super.key, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/icon.png"), context);
    final username = AuthManager.instance.authenticatedUser?.username;
    return AppBar(
      automaticallyImplyLeading: false,
      title: TitleBarTitle(onTap: () => context.navigateTo(MainRoute())),
      backgroundColor: backgroundColor ?? ColorScheme.of(context).surface,
      scrolledUnderElevation: 0,
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Semantics(
            button: true,
            label:
                "${AppLocalizations.of(context).accountOverview}${username != null ? " ${AppLocalizations.of(context).accountOverviewFor(username)}" : ""}",
            child: Tooltip(
              message: username ?? "Account",
              child: InkWell(
                onTap: () =>
                    context.navigateTo(SubmissionsRoute(user: username)),
                borderRadius: BorderRadius.circular(100),
                child: Padding(
                  padding: EdgeInsetsGeometry.all(1),
                  child: AuthManager.instance.authenticatedUser?.avatar(
                    context,
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => showAboutDialog(
            context: context,
            applicationName: "Datly",
            applicationVersion:
                "${GitBaker.currentBranch.name}"
                        "@${GitBaker.currentBranch.commits.last.hashAbbreviated} "
                        "${GitBaker.workspace.isNotEmpty ? "(${gitBakerWorkspaceFormat(GitBaker.workspace)})" : ""}"
                    .trim(),
            applicationIcon: Image.asset(
              "assets/icon.png",
              width: 72,
              height: 72,
              isAntiAlias: true,
              filterQuality: FilterQuality.high,
            ),
            applicationLegalese: "© 2025–2026 JHubi1. All rights reserved.",
            children: [
              SizedBox(height: 24),
              ListTile(
                onTap: () => showPasswordChangeDialog(context: context),
                leading: Icon(Icons.key),
                title: Text(
                  AppLocalizations.of(context).aboutAppChangePassword,
                ),
              ),
              ListTile(
                onTap: () async {
                  await context.navigateTo(MainRoute());
                  await AuthManager.instance.logout();
                },
                leading: Icon(Icons.logout),
                title: Text(AppLocalizations.of(context).aboutAppLogout),
              ),
              SizedBox(height: 12),
              ListTile(
                onTap: () =>
                    launchUrl(Uri.parse("https://github.com/Muelltrenninator")),
                leading: Icon(Icons.open_in_new),
                title: Text(AppLocalizations.of(context).aboutAppLearnMore),
              ),
              SizedBox(height: 12),
              ListTile(
                onTap: () =>
                    context.pushRoute(MarkdownDialogTermsOfServiceRoute()),
                leading: Icon(Icons.description_outlined),
                title: Text(AppLocalizations.of(context).termsOfService),
              ),
              ListTile(
                onTap: () =>
                    context.pushRoute(MarkdownDialogPrivacyPolicyRoute()),
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text(AppLocalizations.of(context).privacyPolicy),
              ),
              ListTile(
                onTap: () => context.pushRoute(MarkdownDialogImprintRoute()),
                leading: Icon(Icons.gavel_outlined),
                title: Text(AppLocalizations.of(context).imprint),
              ),
              if (AuthManager.instance.authenticatedUserIsAdmin) ...[
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "Admin settings",
                    style: TextTheme.of(context).labelLarge,
                  ),
                ),
                ListTile(
                  onTap: () {
                    prefs.setBool(
                      "enableValidationScreen",
                      !(prefs.getBool("enableValidationScreen") ?? false),
                    );
                    web.window.location.reload();
                  },
                  leading: Badge(
                    backgroundColor:
                        (prefs.getBool("enableValidationScreen") ?? false)
                        ? Colors.green
                        : Colors.red,
                    child: Icon(Icons.science_outlined),
                  ),
                  title: Text(
                    "${(prefs.getBool("enableValidationScreen") ?? false) ? "Turn off" : "Turn on"} validation screen",
                  ),
                  dense: true,
                ),
              ],
            ],
          ),
          icon: Icon(Icons.info_outline),
          tooltip: "About",
        ),
        if (AuthManager.instance.authenticatedUserIsAdmin)
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                onPressed: () => context.navigateTo(ListUsersRoute()),
                leadingIcon: Icon(Icons.group),
                child: Text("Users"),
              ),
              MenuItemButton(
                onPressed: () => context.navigateTo(ListProjectsRoute()),
                leadingIcon: Icon(Icons.widgets),
                child: Text("Projects"),
              ),
              MenuItemButton(
                onPressed: () => context.navigateTo(ListCategoriesRoute()),
                leadingIcon: Icon(Icons.topic),
                child: Text("Categories"),
              ),
            ],
            builder: (_, controller, _) {
              return IconButton(
                onPressed: controller.isOpen
                    ? controller.close
                    : controller.open,
                icon: Icon(Icons.admin_panel_settings_outlined),
                tooltip: "Admin menu",
              );
            },
          ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

String initialsFromUsername(String? username) {
  if (username == null || username.isEmpty) return "";
  final wordMatches = RegExp(r"[A-Z]?[a-z]+").allMatches(username);
  if (wordMatches.isNotEmpty) {
    final initials = wordMatches
        .take(2)
        .map((m) => username[m.start].toUpperCase())
        .join();
    if (initials.isNotEmpty) return initials;
  }
  final caps = RegExp(
    r"[A-Z]",
  ).allMatches(username).map((m) => username[m.start]).toList();
  if (caps.isNotEmpty) return caps.take(2).join().toUpperCase();
  return username[0].toUpperCase();
}

bool validateEmail(String email) => RegExp(
  r"""^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$""",
).hasMatch(email);

String gitBakerWorkspaceFormat(List<WorkspaceEntry> entries) {
  if (entries.isEmpty ||
      (entries.length == 1 && entries[0].path.endsWith("gitbaker.g.dart"))) {
    return "clean";
  }
  final addedIndex = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.x == WorkspaceEntryStatusPart.added)
      .length;
  final addedWorking = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.y == WorkspaceEntryStatusPart.added)
      .length;
  final modifiedIndex = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.x == WorkspaceEntryStatusPart.modified)
      .length;
  final modifiedWorking = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.y == WorkspaceEntryStatusPart.modified)
      .length;
  final removedIndex = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.x == WorkspaceEntryStatusPart.deleted)
      .length;
  final removedWorking = entries
      .whereType<WorkspaceEntryChange>()
      .where((e) => e.status.y == WorkspaceEntryStatusPart.deleted)
      .length;
  final renamedCopied = entries.whereType<WorkspaceEntryRenameCopy>().length;
  final untracked = entries.whereType<WorkspaceEntryUntracked>().length;
  return [
    if (addedIndex > 0 || modifiedIndex > 0 || removedIndex > 0)
      "I${[if (addedIndex > 0) "+$addedIndex", if (modifiedIndex > 0) "\u00B1$modifiedIndex", if (removedIndex > 0) "\u2212$removedIndex"].join()}",
    if (addedWorking > 0 || modifiedWorking > 0 || removedWorking > 0)
      "W${[if (addedWorking > 0) "+$addedWorking", if (modifiedWorking > 0) "\u00B1$modifiedWorking", if (removedWorking > 0) "\u2212$removedWorking"].join()}",
    if (renamedCopied > 0) "R$renamedCopied",
    if (untracked > 0) "U$untracked",
  ].join(" ");
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../api.dart';

class TitleBarTitle extends StatelessWidget {
  final GestureTapCallback? onTap;
  const TitleBarTitle({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: "TitleBarTitle",
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flourescent_rounded),
            SizedBox(width: 8),
            Builder(
              builder: (context) => Text(
                "Datly",
                style: DefaultTextStyle.of(
                  context,
                ).style.copyWith(fontFamily: "Poppins"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final username = AuthManager.instance.authenticatedUser?.username;
    return AppBar(
      automaticallyImplyLeading: false,
      title: TitleBarTitle(onTap: () => context.navigateToPath("/")),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Semantics(
            button: true,
            label:
                "Account overview${username != null ? " for $username" : ""}",
            child: Tooltip(
              message: username ?? "Account",
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(100),
                child: Padding(
                  padding: EdgeInsetsGeometry.all(1),
                  child: CircleAvatar(
                    child: Text(initialsFromUsername(username)),
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
            applicationVersion: "",
            applicationIcon: Image.asset(
              "assets/icon.png",
              width: 72,
              height: 72,
              isAntiAlias: true,
              filterQuality: FilterQuality.high,
            ),
            applicationLegalese: "© 2025 JHubi1. All rights reserved.",
          ),
          icon: Icon(Icons.info_outline),
          tooltip: "About",
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.settings),
          tooltip: "Settings",
        ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String initialsFromUsername(String? username) {
    final parts = username?.split(" ") ?? [];
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return "";
  }
}

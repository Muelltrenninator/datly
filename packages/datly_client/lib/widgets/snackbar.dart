import 'package:flutter/material.dart';
import '../main.dart';

Future<void> showBetterSnackbar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) async {
  final windowSizeClass = WindowSizeClass.of(context);
  final materialLocalizations = MaterialLocalizations.of(context);

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      width: windowSizeClass > WindowSizeClass.compact ? 360 : null,
      actionOverflowThreshold: 1,
      action: onAction != null
          ? SnackBarAction(
              label: actionLabel ?? materialLocalizations.continueButtonLabel,
              onPressed: onAction,
            )
          : null,
      showCloseIcon: onAction == null,
    ),
  );
}

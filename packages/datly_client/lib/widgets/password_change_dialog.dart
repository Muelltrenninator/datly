import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../l10n/app_localizations.dart';
import 'multi_prompt_dialog.dart';
import 'status_modal.dart';

Future<void> showPasswordChangeDialog({
  required BuildContext context,
  String? user,
  String? description,
}) async {
  assert(
    user == null || AuthManager.instance.authenticatedUserIsAdmin,
    "Only admins can change other users' passwords. If you want to change your own password, don't provide a user.",
  );

  final appLocalizations = AppLocalizations.of(context);
  String newPassword = "";

  while (true) {
    if (!context.mounted) return;
    final values = await showMultiPromptDialog(
      context: context,
      title: appLocalizations.passwordChangeTitle,
      description: description,
      maxWidth: 360,
      prompts: {
        "password": MultiPromptPrompt(
          content: newPassword,
          label: appLocalizations.passwordChangeNew,
          obscure: true,
          validator: (value) {
            newPassword = value;
            return isSecurePassword(value)
                ? null
                : appLocalizations.passwordChangeErrorWeak;
          },
        ),
        "passwordConfirm": MultiPromptPrompt(
          content: newPassword,
          label: appLocalizations.passwordChangeConfirm,
          obscure: true,
          validator: (value) => value == newPassword
              ? null
              : appLocalizations.passwordChangeErrorMismatch,
        ),
      },
    );

    if (!context.mounted || values == null) return;

    final completer = Completer<void>();
    http.Response? response;
    final modal = showStatusModal(
      context: context,
      completer: completer,
      failureDetailsGenerator: () {
        final body = jsonDecode(response!.body) as Map<String, dynamic>;
        if (response.statusCode == 400 && body.containsKey("code")) {
          final codeMessage = switch (body["code"]) {
            "short" => appLocalizations.passwordChangeErrorInsecureCodeShort,
            "long" => appLocalizations.passwordChangeErrorInsecureCodeLong,
            "uppercase" =>
              appLocalizations.passwordChangeErrorInsecureCodeUppercase,
            "lowercase" =>
              appLocalizations.passwordChangeErrorInsecureCodeLowercase,
            "digit" => appLocalizations.passwordChangeErrorInsecureCodeDigit,
            "special" =>
              appLocalizations.passwordChangeErrorInsecureCodeSpecial,
            "compromised" =>
              appLocalizations.passwordChangeErrorInsecureCodeCompromised,
            _ => null,
          };
          if (codeMessage != null) {
            return appLocalizations.passwordChangeErrorInsecure(codeMessage);
          }
        }
        return responseFailureDetailsGenerator(response);
      },
    );

    response = await AuthManager.instance.fetch(
      http.Request(
          "PUT",
          Uri.parse(
            "${ApiManager.baseUri}/user/${user ?? AuthManager.instance.authenticatedUser!.username}",
          ),
        )
        ..headers["Content-Type"] = "application/json"
        ..body = jsonEncode({
          "password": newPassword,
          "email": null,
          "projects": null,
          "role": null,
        }),
    );
    if (response == null || response.statusCode != 200) {
      completer.completeError("");
      await modal;
    } else {
      completer.complete();
      await modal;
      return;
    }
  }
}

bool isSecurePassword(String password) {
  if (password.length < 12 ||
      password.length > 128 ||
      !password.contains(RegExp(r'[A-Z]')) ||
      !password.contains(RegExp(r'[a-z]')) ||
      !password.contains(RegExp(r'[0-9]')) ||
      !password.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{}|;:,.<>?]'))) {
    return false;
  }
  return true;
}

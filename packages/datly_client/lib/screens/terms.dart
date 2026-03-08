import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:markdown_widget/markdown_widget.dart';

import '../api.dart';
import '../l10n/app_localizations.dart';
import '../main.gr.dart';

abstract class MarkdownDialogSource {
  MarkdownDialogSource();
  FutureOr<String> getMarkdown();
  MarkdownDialogSource copyWith();

  factory MarkdownDialogSource._termsOfService() => MarkdownDialogHttpSource(
    Uri.parse("${ApiManager.baseUri.replace(path: "")}/legal/terms"),
  );
  factory MarkdownDialogSource._privacyPolicy() => MarkdownDialogHttpSource(
    Uri.parse("${ApiManager.baseUri.replace(path: "")}/legal/privacy"),
  );
  factory MarkdownDialogSource._imprint() => MarkdownDialogHttpSource(
    Uri.parse("${ApiManager.baseUri.replace(path: "")}/legal/imprint"),
  );
}

class MarkdownDialogStringSource extends MarkdownDialogSource {
  final String data;
  MarkdownDialogStringSource(this.data);

  @override
  String getMarkdown() => data;

  @override
  MarkdownDialogStringSource copyWith({String? data}) =>
      MarkdownDialogStringSource(data ?? this.data);
}

class MarkdownDialogHttpSource extends MarkdownDialogSource {
  final Uri origin;
  MarkdownDialogHttpSource(this.origin);

  @override
  Future<String> getMarkdown() async {
    final response = await http.get(origin);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return response.body;
    } else {
      throw Exception();
    }
  }

  @override
  MarkdownDialogHttpSource copyWith({Uri? origin}) =>
      MarkdownDialogHttpSource(origin ?? this.origin);
}

class MarkdownDialog extends StatefulWidget {
  final MarkdownDialogSource source;
  const MarkdownDialog({super.key, required this.source});

  @override
  State<MarkdownDialog> createState() => _MarkdownDialogState();
}

class _MarkdownDialogState extends State<MarkdownDialog> {
  String? data;
  bool error = false;

  @override
  void initState() {
    super.initState();
    Future<String?>.value(widget.source.getMarkdown())
        .catchError((_) {
          error = true;
          return null;
        })
        .then((markdown) {
          data = markdown;
          if (mounted) setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    var markdownConfig = Theme.brightnessOf(context) == Brightness.dark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;
    markdownConfig = markdownConfig.copy(
      configs: [
        TableConfig(
          wrapper: (child) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: child,
          ),
        ),
      ],
    );
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 16),
      constraints: BoxConstraints(minWidth: 280, maxWidth: 560),
      content: AnimatedSize(
        duration: Durations.medium1,
        curve: Curves.easeInOutCubicEmphasized,
        child: !error
            ? data != null
                  ? SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: MarkdownBlock(
                            data: data!,
                            config: markdownConfig,
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(top: 32, bottom: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [CircularProgressIndicator()],
                      ),
                    )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Builder(
                  builder: (context) => Text(
                    AppLocalizations.of(context).failedToLoadDocument,
                    style: DefaultTextStyle.of(
                      context,
                    ).style.copyWith(color: ColorScheme.of(context).error),
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}

Future<void> showMarkdownDialog({
  required BuildContext context,
  required MarkdownDialogSource source,
}) async => showDialog<void>(
  context: context,
  builder: (_) => MarkdownDialog(source: source),
);

// MARK: Routes

@RoutePage()
class MarkdownDialogTermsOfServicePage extends StatefulWidget {
  const MarkdownDialogTermsOfServicePage({super.key});

  @override
  State<MarkdownDialogTermsOfServicePage> createState() =>
      _MarkdownDialogTermsOfServicePageState();
}

class _MarkdownDialogTermsOfServicePageState
    extends State<MarkdownDialogTermsOfServicePage> {
  @override
  void initState() {
    super.initState();
    if (context.router.stack.length <= 1) {
      context.router.insert(
        AuthManager.instance.authenticatedUser != null
            ? MainRoute()
            : LoginRoute(),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
      MarkdownDialog(source: MarkdownDialogSource._termsOfService());
}

@RoutePage()
class MarkdownDialogPrivacyPolicyPage extends StatefulWidget {
  const MarkdownDialogPrivacyPolicyPage({super.key});

  @override
  State<MarkdownDialogPrivacyPolicyPage> createState() =>
      _MarkdownDialogPrivacyPolicyPageState();
}

class _MarkdownDialogPrivacyPolicyPageState
    extends State<MarkdownDialogPrivacyPolicyPage> {
  @override
  void initState() {
    super.initState();
    if (context.router.stack.length <= 1) {
      context.router.insert(
        AuthManager.instance.authenticatedUser != null
            ? MainRoute()
            : LoginRoute(),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
      MarkdownDialog(source: MarkdownDialogSource._privacyPolicy());
}

@RoutePage()
class MarkdownDialogImprintPage extends StatefulWidget {
  const MarkdownDialogImprintPage({super.key});

  @override
  State<MarkdownDialogImprintPage> createState() =>
      _MarkdownDialogImprintPageState();
}

class _MarkdownDialogImprintPageState extends State<MarkdownDialogImprintPage> {
  @override
  void initState() {
    super.initState();
    if (context.router.stack.length <= 1) {
      context.router.insert(
        AuthManager.instance.authenticatedUser != null
            ? MainRoute()
            : LoginRoute(),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
      MarkdownDialog(source: MarkdownDialogSource._imprint());
}

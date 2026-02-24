import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:markdown_widget/markdown_widget.dart';

abstract class MarkdownDialogSource {
  FutureOr<String> getMarkdown();
}

class MarkdownDialogStringSource extends MarkdownDialogSource {
  final String data;
  MarkdownDialogStringSource(this.data);

  @override
  String getMarkdown() => data;
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
      throw Exception("Failed to load document.");
    }
  }
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
                            config:
                                Theme.brightnessOf(context) == Brightness.dark
                                ? MarkdownConfig.darkConfig
                                : MarkdownConfig.defaultConfig,
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
                child: Text(
                  "Failed to load document.",
                  style: DefaultTextStyle.of(
                    context,
                  ).style.copyWith(color: ColorScheme.of(context).error),
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
  fullscreenDialog: true,
  builder: (_) => MarkdownDialog(source: source),
);

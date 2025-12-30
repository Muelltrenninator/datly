import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:markdown_widget/markdown_widget.dart';

class MarkdownDialog extends StatefulWidget {
  final Uri origin;
  const MarkdownDialog({super.key, required this.origin});

  @override
  State<MarkdownDialog> createState() => _MarkdownDialogState();
}

class _MarkdownDialogState extends State<MarkdownDialog> {
  String? data;
  bool error = false;

  @override
  void initState() {
    super.initState();
    http.get(widget.origin).then((response) {
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        data = response.body;
      } else {
        error = true;
      }
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
  required Uri origin,
}) async => showDialog<void>(
  context: context,
  fullscreenDialog: true,
  builder: (_) => MarkdownDialog(origin: origin),
);

/// Radio dialog widget and helper functions from Material Apps project.
///
/// Source: https://github.com/JHubi1/material/blob/main/packages/material_helper/lib/src/components/radio_dialog.dart
/// @docImport 'password_change_dialog.dart';
library;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'prompt_dialog.dart';

class MultiPromptDialog extends StatefulWidget {
  /// An optional icon to display at the top of the dialog.
  ///
  /// Typically, an [Icon] widget. Providing an icon centers the [title]'s text.
  final Widget? icon;

  /// Color for the [Icon] in the [icon] of this [AlertDialog].
  ///
  /// If null, [DialogThemeData.iconColor] is used. If that is null, defaults to
  /// color scheme's [ColorScheme.secondary] if [ThemeData.useMaterial3] is
  /// true, black otherwise.
  final Color? iconColor;

  /// The title of the dialog.
  final String title;

  /// The (optional) description of the dialog.
  final String? description;

  /// The semantic label of the dialog used by accessibility frameworks to
  /// announce screen transitions when the dialog is opened and closed.
  ///
  /// In iOS, if this label is not provided, a semantic label will be inferred
  /// from the [title] if it is not null.
  ///
  /// In Android, if this label is not provided, the dialog will use the
  /// [MaterialLocalizations.alertDialogLabel] as its label.
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.namesRoute], for a description of how this
  ///    value is used.
  final String? semanticLabel;

  /// {@macro flutter.material.dialog.alignment}
  final AlignmentGeometry? alignment;

  /// The maximum width of the dialog.
  ///
  /// Must be smaller than 560, which is the default max width of the dialog.
  /// Otherwise it will be ignored.
  ///
  /// This should not be used and is only present for the [showPasswordChangeDialog]
  /// to not look weird on larger screens.
  final double? maxWidth;

  /// The prompts to display in the dialog.
  final Map<String, MultiPromptPrompt> prompts;

  MultiPromptDialog({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.description,
    this.semanticLabel,
    this.alignment,
    this.maxWidth,
    required this.prompts,
  }) : assert(prompts.isNotEmpty, "At least one prompt is required");

  @override
  State<MultiPromptDialog> createState() => _MultiPromptDialogState();
}

class _MultiPromptDialogState extends State<MultiPromptDialog> {
  late final Map<String, FocusNode> focusNodes;
  late final Map<String, TextEditingController> controllers;

  Map<String, String?> errorTexts = {};
  bool get loading => loadingValidation || (loadingAction ?? false);
  bool loadingValidation = false;

  bool? _loadingAction = false;
  bool? get loadingAction => _loadingAction;

  void setLoadingAction(String index, bool? value) {
    if (_loadingAction == null || value == null) return;
    if (_loadingAction != value) {
      if (value || !invokeActionCondition(index)) {
        _loadingAction = value;
        if (mounted) setState(() {});
        focusTextField(index);
      } else {
        _loadingAction = null;
        if (mounted) setState(() {});
        focusTextField(index);

        if (!loadingValidation) {
          Future.delayed(Durations.extralong4).then((_) {
            _loadingAction = value;
            if (mounted) setState(() {});
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    focusNodes = {for (var p in widget.prompts.keys) p: FocusNode()};
    controllers = {
      for (var p in widget.prompts.entries)
        p.key: TextEditingController(text: p.value.content ?? ""),
    };
  }

  @override
  void dispose() {
    for (var node in focusNodes.values) {
      node.dispose();
    }
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void focusTextField(String index) => WidgetsBinding.instance
      .addPersistentFrameCallback((_) => focusNodes[index]!.requestFocus());

  void submit() async {
    setState(() {
      errorTexts.clear();
      loadingValidation = true;
    });

    bool returnDecided = false;

    for (var i in widget.prompts.entries) {
      final text = controllers[i.key]!.text;
      final validation = await Future.value(i.value.validator?.call(text));

      if (validation != null) {
        setState(() {
          errorTexts[i.key] = validation;
          loadingValidation = false;
        });
        returnDecided = true;
      }
    }
    if (returnDecided) return;
    if (mounted) {
      Navigator.of(
        context,
      ).pop({for (var e in widget.prompts.keys) e: controllers[e]!.text});
    }
  }

  void invokeAction(String index) async {
    setState(() => errorTexts[index] = null);

    var doSubmit = false;
    final event = PromptDialogActionEvent(
      setValue: ([value]) => controllers[index]!.text = value ?? "",
      getValue: () => controllers[index]!.text,
      submit: () => doSubmit = true,
    );

    setLoadingAction(index, true);
    try {
      await Future.value(widget.prompts[index]!.action!.invoke.call(event));
    } catch (e) {
      errorTexts[index] = e.toString();
      if (mounted) setState(() {});
    }
    if (doSubmit) submit();
    setLoadingAction(index, false);
  }

  bool invokeActionCondition(String index) {
    if (widget.prompts[index]!.action?.condition == null) return true;
    return widget.prompts[index]!.action!.condition!.call(
      controllers[index]!.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return PopScope(
      canPop: !loading,
      child: AlertDialog(
        icon: widget.icon,
        iconColor: widget.iconColor,
        title: Text(widget.title),
        semanticLabel: widget.semanticLabel,
        alignment: widget.alignment,
        scrollable: true,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        constraints: BoxConstraints(
          minWidth: 280,
          maxWidth: widget.maxWidth != null
              ? math.min(widget.maxWidth!, 560)
              : 560,
        ),

        content: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.description != null)
                Transform.translate(
                  offset: Offset(0, -16),
                  child: Text(widget.description!),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.prompts.entries
                    .map(
                      (e) => [
                        TextField(
                          enabled: !loading,
                          controller: controllers[e.key],
                          focusNode: focusNodes[e.key],
                          autofocus: true,

                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: e.value.label,
                            alignLabelWithHint: true,

                            hintText: e.value.placeholder,
                            hintMaxLines: 1,
                            errorText: errorTexts[e.key],
                            errorMaxLines: 3,

                            prefixText: e.value.prefixText,
                            prefixIcon: e.value.prefixIcon,

                            suffixText: e.value.suffixText,
                            suffixIcon:
                                e.value.action != null &&
                                    invokeActionCondition(e.key)
                                ? AnimatedSwitcher(
                                    duration: Durations.short2,
                                    switchInCurve:
                                        Curves.easeInOutCubicEmphasized,
                                    switchOutCurve:
                                        Curves.easeInOutCubicEmphasized.flipped,
                                    child: loadingAction == false
                                        ? IconButton(
                                            onPressed: !loading
                                                ? () => invokeAction(e.key)
                                                : null,
                                            icon: Icon(
                                              e.value.action!.icon ??
                                                  Icons.auto_fix_high,
                                              semanticLabel:
                                                  e.value.action!.label,
                                            ),
                                            tooltip: loadingAction != null
                                                ? e.value.action!.label ??
                                                      "Invoke"
                                                : null,
                                          )
                                        : loadingAction == null
                                        ? Icon(
                                            errorTexts[e.key] == null
                                                ? Icons.done
                                                : Icons.error_outline,
                                          )
                                        : SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                  )
                                : e.value.suffixIcon ??
                                      (errorTexts[e.key] != null
                                          ? Icon(
                                              Icons.error,
                                              color: colorScheme.error,
                                            )
                                          : null),
                          ),

                          maxLines: e.value.maxLines,
                          maxLength: e.value.maxLength,
                          buildCounter: loadingValidation
                              ? (
                                  _, {
                                  required currentLength,
                                  required isFocused,
                                  required maxLength,
                                }) => null
                              : null,

                          obscureText: e.value.obscure,
                          autocorrect: e.value.autocorrect,
                          enableSuggestions: e.value.autocorrect
                              ? e.value.enableSuggestions
                              : false,
                          autofillHints: e.value.autofillHints,
                          textCapitalization: e.value.capitalization,
                          onSubmitted: (_) => submit(),

                          textInputAction: e.value.maxLines == 1
                              ? TextInputAction.done
                              : TextInputAction.newline,
                          keyboardType:
                              e.value.keyboardType ??
                              (e.value.maxLines == 1
                                  ? TextInputType.text
                                  : TextInputType.multiline),
                        ),
                        if (e.key != widget.prompts.keys.last)
                          SizedBox(height: 8),
                      ],
                    )
                    .expand((e) => e)
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          if (loadingValidation)
            SizedBox.square(dimension: 24, child: CircularProgressIndicator()),
          TextButton(
            onPressed: !loading ? () => Navigator.of(context).pop() : null,
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: !loading ? submit : null,
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}

Future<Map<String, String>?> showMultiPromptDialog({
  required BuildContext context,
  Widget? icon,
  Color? iconColor,
  required String title,
  String? description,
  String? semanticLabel,
  AlignmentGeometry? alignment,
  double? maxWidth,
  required Map<String, MultiPromptPrompt> prompts,
}) async {
  return await showDialog<Map<String, String>?>(
    context: context,
    builder: (_) => MultiPromptDialog(
      icon: icon,
      iconColor: iconColor,
      title: title,
      description: description,
      semanticLabel: semanticLabel,
      alignment: alignment,
      maxWidth: maxWidth,
      prompts: prompts,
    ),
  );
}

class MultiPromptPrompt {
  /// An optional text to display before the input field.
  ///
  /// See also: [prefixIcon]
  final String? prefixText;

  /// An optional icon to display before the input field.
  ///
  /// See also: [prefixText]
  final Widget? prefixIcon;

  /// Initial content of the input field.
  final String? content;

  /// Label displayed above the input field.
  final String? label;

  /// Placeholder text for the input field.
  final String? placeholder;

  /// An optional text to display after the input field.
  ///
  /// This only works if no [action] is provided.
  ///
  /// See also: [suffixIcon]
  final String? suffixText;

  /// An optional widget to display after the input field.
  ///
  /// This only works if no [action] is provided.
  ///
  /// See also: [suffixText]
  final Widget? suffixIcon;

  /// An optional validator for the input.
  ///
  /// If provided, the input will be validated when the user submits the dialog.
  ///
  /// This method should return an error message if the input is invalid, or
  /// null if the input is valid.
  final ValueValidator<String>? validator;

  /// Whether to hide the input text.
  ///
  /// Defaults to false.
  final bool obscure;

  /// Whether to enable autocorrect for the input text.
  ///
  /// Defaults to true.
  final bool autocorrect;

  /// Whether to enable suggestions for the input text.
  ///
  /// This is ignored if [autocorrect] is false. This also gets ignored by the
  /// OS if [obscure] is true.
  ///
  /// Defaults to true.
  final bool enableSuggestions;

  /// The maximum length of the input text.
  ///
  /// If null, there is no limit.
  final int? maxLength;

  /// The maximum number of lines for the input text.
  ///
  /// Must be 1 or greater. Defaults to 1.
  ///
  /// If greater than 1, the input field will be a multiline text field. This
  /// will change the input action to [TextInputAction.newline] and the
  /// keyboard type to [TextInputType.multiline].
  ///
  /// To trigger the same, but keep the default height, set this to null.
  final int? maxLines;

  /// Optional autofill hints for the input text.
  ///
  /// See [AutofillHints] for a list of common autofill hints.
  final Iterable<String>? autofillHints;

  /// The text capitalization to use for the input text.
  final TextCapitalization capitalization;

  /// The type of keyboard to use for the input text.
  final TextInputType? keyboardType;

  /// An optional action for the dialog.
  ///
  /// The [PromptDialogAction.icon] will be displayed as a suffix icon in the
  /// input field. When pressed, the [PromptDialogAction.invoke] callback will
  /// be called.
  ///
  /// The [PromptDialogAction.invoke] callback can be asynchronous, but should
  /// not take too long to complete. The dialog will show a loading indicator
  /// while the callback is running, so taking too long will be a negative user
  /// experience.
  final PromptDialogAction? action;

  MultiPromptPrompt({
    this.prefixText,
    this.prefixIcon,
    this.content,
    this.label,
    this.placeholder,
    this.suffixText,
    this.suffixIcon,
    this.validator,
    this.obscure = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLength,
    this.maxLines = 1,
    this.autofillHints,
    this.capitalization = TextCapitalization.sentences,
    this.keyboardType,
    this.action,
  }) : assert((maxLines ?? 1) > 0, "maxLines must be greater than 0");

  MultiPromptPrompt copyWith({
    String? prefixText,
    Widget? prefixIcon,
    String? content,
    String? label,
    String? placeholder,
    String? suffixText,
    Widget? suffixIcon,
    ValueValidator<String>? validator,
    ValueValidatorSimple<String>? quickValidator,
    ValueManipulator<String>? manipulator,
    bool? obscure,
    bool? autocorrect,
    bool? enableSuggestions,
    int? maxLength,
    int? maxLines,
    Iterable<String>? autofillHints,
    TextCapitalization? capitalization,
    TextInputType? keyboardType,
    PromptDialogAction? action,
  }) {
    return MultiPromptPrompt(
      prefixText: prefixText ?? this.prefixText,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      content: content ?? this.content,
      label: label ?? this.label,
      placeholder: placeholder ?? this.placeholder,
      suffixText: suffixText ?? this.suffixText,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      validator: validator ?? this.validator,
      obscure: obscure ?? this.obscure,
      autocorrect: autocorrect ?? this.autocorrect,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      maxLength: maxLength ?? this.maxLength,
      maxLines: maxLines ?? this.maxLines,
      autofillHints: autofillHints ?? this.autofillHints,
      capitalization: capitalization ?? this.capitalization,
      keyboardType: keyboardType ?? this.keyboardType,
      action: action ?? this.action,
    );
  }
}

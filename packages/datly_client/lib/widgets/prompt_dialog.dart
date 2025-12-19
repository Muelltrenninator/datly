/// Radio dialog widget and helper functions from Material Apps project.
///
/// Source: https://github.com/JHubi1/material/blob/main/packages/material_helper/lib/src/components/radio_dialog.dart
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A function that validates an input.
///
/// It should return an error message if the input is invalid, or null if the
/// input is valid.
typedef ValueValidator<T> = FutureOr<String?> Function(T value);

/// A function that validates an input without a message.
///
/// This function should return true if the input is valid, or false if the
/// input is invalid.
typedef ValueValidatorSimple<T> = bool Function(T value);

/// A function that manipulates an input value.
typedef ValueManipulator<T> = T Function(T value);

class PromptDialog extends StatefulWidget {
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

  /// An optional validator for the input.
  ///
  /// If provided, the input will be validated when the user submits the dialog.
  ///
  /// This method should return an error message if the input is invalid, or
  /// null if the input is valid.
  final ValueValidator<String>? validator;

  /// An optional synchronous validator for the input.
  ///
  /// This is only used for enabling the submit button. If the input is invalid,
  /// the submit button will be disabled.
  final ValueValidatorSimple<String>? quickValidator;

  /// A manipulator for the input value.
  ///
  /// It is called whenever the input value changes. The returned value is set
  /// as the new input value.
  final ValueManipulator<String>? manipulator;

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

  const PromptDialog({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.description,
    this.prefixText,
    this.prefixIcon,
    this.content,
    this.placeholder,
    this.suffixText,
    this.suffixIcon,
    this.semanticLabel,
    this.alignment,
    this.validator,
    this.quickValidator,
    this.manipulator,
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

  @override
  State<PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<PromptDialog> {
  final focusNode = FocusNode();
  late final TextEditingController controller;

  String? errorText;
  bool get loading => loadingValidation || (loadingAction ?? false);
  bool loadingValidation = false;

  bool? _loadingAction = false;
  bool? get loadingAction => _loadingAction;
  set loadingAction(bool? value) {
    if (_loadingAction == null || value == null) return;
    if (_loadingAction != value) {
      if (value || !invokeActionCondition()) {
        _loadingAction = value;
        if (mounted) setState(() {});
        focusTextField();
      } else {
        _loadingAction = null;
        if (mounted) setState(() {});
        focusTextField();

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
    controller = TextEditingController(text: widget.content)
      ..addListener(onUpdate);
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  void onUpdate() {
    if (widget.manipulator != null) {
      final manipulated = widget.manipulator!.call(controller.text);
      if (manipulated != controller.text) {
        final selection = controller.selection;
        controller.value = TextEditingValue(
          text: manipulated,
          selection: selection,
        );
      }
    }
    if (mounted) setState(() {});
  }

  void focusTextField() => WidgetsBinding.instance.addPersistentFrameCallback(
    (_) => focusNode.requestFocus(),
  );

  void submit() async {
    setState(() {
      errorText = null;
      loadingValidation = true;
    });

    final text = controller.text;
    final validation = await Future.value(widget.validator?.call(text));

    if (validation != null) {
      setState(() {
        errorText = validation;
        loadingValidation = false;
      });
      focusTextField();
      return;
    }

    if (mounted) {
      Navigator.of(context).pop(text);
    }
  }

  bool quickValidate() {
    if (widget.quickValidator == null) return true;
    return widget.quickValidator!.call(controller.text);
  }

  void invokeAction() async {
    setState(() => errorText = null);

    var doSubmit = false;
    final event = PromptDialogActionEvent(
      setValue: ([value]) => controller.text = value ?? "",
      getValue: () => controller.text,
      submit: () => doSubmit = true,
    );

    loadingAction = true;
    try {
      await Future.value(widget.action!.invoke.call(event));
    } catch (e) {
      errorText = e.toString();
      if (mounted) setState(() {});
    }
    if (doSubmit) submit();
    loadingAction = false;
  }

  bool invokeActionCondition() {
    if (widget.action?.condition == null) return true;
    return widget.action!.condition!.call(controller.text);
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
        constraints: BoxConstraints(minWidth: 280, maxWidth: 560),

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
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  TextField(
                    enabled: !loading,
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,

                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: widget.placeholder,
                      hintMaxLines: 1,
                      errorText: errorText,
                      errorMaxLines: 3,

                      prefixText: widget.prefixText,
                      prefixIcon: widget.prefixIcon,

                      suffixText: widget.suffixText,
                      suffixIcon:
                          widget.action != null && invokeActionCondition()
                          ? AnimatedSwitcher(
                              duration: Durations.short2,
                              switchInCurve: Curves.easeInOutCubicEmphasized,
                              switchOutCurve:
                                  Curves.easeInOutCubicEmphasized.flipped,
                              child: loadingAction == false
                                  ? IconButton(
                                      onPressed: !loading ? invokeAction : null,
                                      icon: Icon(
                                        widget.action!.icon ??
                                            Icons.auto_fix_high,
                                        semanticLabel: widget.action!.label,
                                      ),
                                      tooltip: loadingAction != null
                                          ? widget.action!.label ?? "Invoke"
                                          : null,
                                    )
                                  : loadingAction == null
                                  ? Icon(
                                      errorText == null
                                          ? Icons.done
                                          : Icons.error_outline,
                                    )
                                  : SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: colorScheme.onSurfaceVariant,
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                            )
                          : widget.suffixIcon ??
                                (errorText != null
                                    ? Icon(
                                        Icons.error,
                                        color: colorScheme.error,
                                      )
                                    : null),
                    ),

                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    buildCounter: loadingValidation
                        ? (
                            _, {
                            required currentLength,
                            required isFocused,
                            required maxLength,
                          }) => null
                        : null,

                    obscureText: widget.obscure,
                    autocorrect: widget.autocorrect,
                    enableSuggestions: widget.autocorrect
                        ? widget.enableSuggestions
                        : false,
                    autofillHints: widget.autofillHints,
                    textCapitalization: widget.capitalization,
                    onSubmitted: (_) => submit(),

                    textInputAction: widget.maxLines == 1
                        ? TextInputAction.done
                        : TextInputAction.newline,
                    keyboardType:
                        widget.keyboardType ??
                        (widget.maxLines == 1
                            ? TextInputType.text
                            : TextInputType.multiline),
                  ),
                  if (loadingValidation) LinearProgressIndicator(),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: !loading ? () => Navigator.of(context).pop() : null,
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: !loading && quickValidate() ? submit : null,
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}

Future<String?> showPromptDialog({
  required BuildContext context,
  Widget? icon,
  Color? iconColor,
  required String title,
  String? description,
  String? prefixText,
  Widget? prefixIcon,
  String? content,
  String? placeholder,
  String? suffixText,
  Widget? suffixIcon,
  String? semanticLabel,
  AlignmentGeometry? alignment,
  ValueValidator<String>? validator,
  ValueValidatorSimple<String>? quickValidator,
  ValueManipulator<String>? manipulator,
  bool obscure = false,
  bool autocorrect = true,
  int? maxLength,
  int? maxLines = 1,
  Iterable<String>? autofillHints,
  TextCapitalization capitalization = TextCapitalization.sentences,
  TextInputType? keyboardType,
  PromptDialogAction? action,
}) async {
  return await showDialog<String>(
    context: context,
    builder: (_) => PromptDialog(
      icon: icon,
      iconColor: iconColor,
      title: title,
      description: description,
      prefixText: prefixText,
      prefixIcon: prefixIcon,
      content: content,
      placeholder: placeholder,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      semanticLabel: semanticLabel,
      alignment: alignment,
      validator: validator,
      quickValidator: quickValidator,
      manipulator: manipulator,
      obscure: obscure,
      autocorrect: autocorrect,
      maxLength: maxLength,
      maxLines: maxLines,
      autofillHints: autofillHints,
      capitalization: capitalization,
      keyboardType: keyboardType,
      action: action,
    ),
  );
}

typedef PromptDialogActionCallback =
    FutureOr<void> Function(PromptDialogActionEvent event);
typedef PromptDialogActionCondition = bool Function(String value);

/// An action for a [PromptDialog].
class PromptDialogAction {
  final IconData? icon;
  final String? label;
  final PromptDialogActionCallback invoke;
  final PromptDialogActionCondition? condition;
  const PromptDialogAction({
    this.icon,
    this.label,
    required this.invoke,
    this.condition,
  });
}

class PromptDialogActionEvent {
  /// Set the value of the input field.
  ///
  /// If [value] is null or not provided, the input field will be cleared.
  void Function([String? value]) setValue;

  /// Get the current value of the input field.
  String Function() getValue;

  /// Mark the result as final and submit the dialog.
  ///
  /// This will run the validation function right after the
  /// [PromptDialogAction.invoke] method has completed.
  ///
  /// If the validation fails, the dialog will not be closed.
  void Function() submit;

  PromptDialogActionEvent({
    required this.setValue,
    required this.getValue,
    required this.submit,
  });
}

abstract class PromptDialogActions {
  static PromptDialogAction clear(BuildContext context) => PromptDialogAction(
    icon: Icons.clear,
    label: "Clear",
    invoke: (event) => event.setValue(),
    condition: (value) => value.isNotEmpty,
  );

  static PromptDialogAction copy(BuildContext context) => PromptDialogAction(
    icon: Icons.copy,
    label: "Copy",
    invoke: (event) => Clipboard.setData(ClipboardData(text: event.getValue())),
    condition: (value) => value.isNotEmpty,
  );
}

/// Radio dialog widget and helper functions from Material Apps project.
///
/// Source: https://github.com/JHubi1/material/blob/main/packages/material_helper/lib/src/components/radio_dialog.dart
library;

import 'dart:async';
import 'package:flutter/material.dart';

typedef RadioDialogObjectGenerator<T, E> = E Function(T item);

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

String radioDialogDefaultTitleGenerator<T>(T item) {
  if (item is Enum) return item.name.capitalize();
  return item.toString();
}

class RadioDialog<T extends Object> extends StatefulWidget {
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

  /// The initially selected value.
  final T? initialValue;

  /// The items the user can choose from.
  ///
  /// For visualization, the [Object.toString] of each item is used. Override
  /// [toString] if needed. Otherwise, use [titleGenerator] to provide custom
  /// titles.
  final Iterable<T> items;

  /// A function that generates the title for each item.
  final RadioDialogObjectGenerator<T, String?>? titleGenerator;

  /// A function that generates the subtitle for each item.
  final RadioDialogObjectGenerator<T, String?>? subtitleGenerator;

  /// A function that generates the icon for each item.
  final RadioDialogObjectGenerator<T, Widget?>? iconGenerator;

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

  /// If true, the user can unselect the currently selected item by tapping on
  /// it a second time.
  ///
  /// This should be used together with [allowEmptySelection] to allow the user
  /// to submit the dialog without any selection.
  final bool toggleable;

  /// If true, the user can submit the dialog without selecting an item.
  ///
  /// Careful: Once the user has selected an item, they usually cannot unselect
  /// it unless [toggleable] is true.
  ///
  /// By default, [Navigator.pop] will return `null` if no item is selected or
  /// if the dialog was dismissed. Use this property together with [onSubmit]
  /// to differentiate between the two cases.
  final bool allowEmptySelection;

  /// Called when the user submits the dialog.
  ///
  /// This does not provide the selected value, but is just available as a hook.
  /// The selected value is returned via [Navigator.pop].
  final ValueChanged<T?>? onSubmit;

  RadioDialog({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.description,
    this.initialValue,
    required this.items,
    this.titleGenerator,
    this.subtitleGenerator,
    this.iconGenerator,
    this.semanticLabel,
    this.alignment,
    this.toggleable = false,
    this.allowEmptySelection = false,
    this.onSubmit,
  }) : assert(
         items.length == items.toSet().length,
         "The items must be unique.",
       );

  @override
  State<RadioDialog<T>> createState() => _RadioDialogState<T>();
}

class _RadioDialogState<T extends Object> extends State<RadioDialog<T>> {
  T? _value;

  late final ScrollController _scrollController;
  bool _hasTopScroll = false;
  bool _hasBottomScroll = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _scrollController = ScrollController()..addListener(onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => onScroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onScroll() {
    if (!_scrollController.hasClients) return;
    final hasTopScroll =
        _scrollController.position.pixels >
        _scrollController.position.minScrollExtent;
    final hasBottomScroll =
        _scrollController.position.pixels <
        _scrollController.position.maxScrollExtent;
    if (hasTopScroll != _hasTopScroll || hasBottomScroll != _hasBottomScroll) {
      _hasTopScroll = hasTopScroll;
      _hasBottomScroll = hasBottomScroll;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final divider = Divider(
      key: UniqueKey(),
      height: 0,
      color: colorScheme.outline,
    );
    return AlertDialog(
      icon: widget.icon,
      iconColor: widget.iconColor,
      title: Text(widget.title),
      semanticLabel: widget.semanticLabel,
      alignment: widget.alignment,
      contentPadding: EdgeInsets.symmetric(vertical: 16),
      constraints: BoxConstraints(minWidth: 280, maxWidth: 560),

      content: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.description != null)
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Transform.translate(
                  offset: Offset(0, -16),
                  child: Text(widget.description!),
                ),
              ),
            AnimatedSwitcher(
              duration: Durations.short2,
              switchInCurve: Curves.easeInOutCubicEmphasized,
              switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
              child: _hasTopScroll ? divider : null,
            ),
            Flexible(
              child: RadioGroup<T>(
                groupValue: _value,
                onChanged: (value) => setState(() => _value = value),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.items.length, (index) {
                      final item = widget.items.elementAt(index);
                      final title =
                          widget.titleGenerator?.call(item) ??
                          radioDialogDefaultTitleGenerator(item);
                      final subtitle = widget.subtitleGenerator?.call(item);
                      final icon = widget.iconGenerator?.call(item);
                      return ListTile(
                        leading: IgnorePointer(
                          child: ExcludeFocus(
                            child: SizedBox.square(
                              dimension: 24,
                              child: Radio<T>(
                                value: item,
                                toggleable: widget.toggleable,
                              ),
                            ),
                          ),
                        ),
                        title: Text(title),
                        subtitle: subtitle != null ? Text(subtitle) : null,
                        trailing: icon,
                        selected: item == _value,
                        minTileHeight: 48,
                        contentPadding: EdgeInsets.symmetric(horizontal: 24),
                        onTap: () {
                          if (widget.toggleable && item == _value) {
                            setState(() => _value = null);
                          } else {
                            setState(() => _value = item);
                          }
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: Durations.short2,
              switchInCurve: Curves.easeInOutCubicEmphasized,
              switchOutCurve: Curves.easeInOutCubicEmphasized.flipped,
              child: _hasBottomScroll ? divider : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: widget.allowEmptySelection || _value != null
              ? () {
                  widget.onSubmit?.call(_value);
                  Navigator.of(context).pop(_value);
                }
              : null,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

Future<T?> showRadioDialog<T extends Object>({
  required BuildContext context,
  Widget? icon,
  Color? iconColor,
  required String title,
  String? description,
  T? initialValue,
  required Iterable<T> items,
  RadioDialogObjectGenerator<T, String?>? titleGenerator,
  RadioDialogObjectGenerator<T, String?>? subtitleGenerator,
  RadioDialogObjectGenerator<T, Widget?>? iconGenerator,
  String? semanticLabel,
  AlignmentGeometry? alignment,
  bool toggleable = false,
  bool allowEmptySelection = false,
  ValueChanged<T?>? onSubmit,
}) async {
  return await showDialog<T>(
    context: context,
    builder: (_) => RadioDialog<T>(
      icon: icon,
      iconColor: iconColor,
      title: title,
      description: description,
      initialValue: initialValue,
      items: items,
      titleGenerator: titleGenerator,
      subtitleGenerator: subtitleGenerator,
      iconGenerator: iconGenerator,
      semanticLabel: semanticLabel,
      alignment: alignment,
      toggleable: toggleable,
      allowEmptySelection: allowEmptySelection,
      onSubmit: onSubmit,
    ),
  );
}

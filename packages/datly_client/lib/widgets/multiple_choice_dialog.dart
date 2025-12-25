import 'dart:async';
import 'package:flutter/material.dart';
import 'radio_dialog.dart';

class MultipleChoiceDialog<T extends Object> extends StatefulWidget {
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
  final List<T>? initialValue;

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
  final ValueChanged<List<T>>? onSubmit;

  MultipleChoiceDialog({
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
    this.allowEmptySelection = false,
    this.onSubmit,
  }) : assert(
         items.length == items.toSet().length,
         "The items must be unique.",
       );

  @override
  State<MultipleChoiceDialog<T>> createState() =>
      _MultipleChoiceDialogState<T>();
}

class _MultipleChoiceDialogState<T extends Object>
    extends State<MultipleChoiceDialog<T>> {
  late List<T> _selected;

  late final ScrollController _scrollController;
  bool _hasTopScroll = false;
  bool _hasBottomScroll = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue != null
        ? List<T>.from(widget.initialValue!)
        : <T>[];
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
                            child: Checkbox(
                              value: _selected.contains(item),
                              onChanged: (_) => setState(
                                () => _selected.contains(item)
                                    ? _selected.remove(item)
                                    : _selected.add(item),
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Text(title),
                      subtitle: subtitle != null ? Text(subtitle) : null,
                      trailing: icon,
                      selected: _selected.contains(item),
                      minTileHeight: 48,
                      contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      onTap: () {
                        _selected.contains(item)
                            ? _selected.remove(item)
                            : _selected.add(item);
                        if (mounted) setState(() {});
                      },
                    );
                  }),
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
          autofocus: true,
          onPressed: widget.allowEmptySelection || _selected.isNotEmpty
              ? () {
                  widget.onSubmit?.call(_selected);
                  Navigator.of(context).pop(_selected);
                }
              : null,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

Future<List<T>> showMultipleChoiceDialog<T extends Object>({
  required BuildContext context,
  Widget? icon,
  Color? iconColor,
  required String title,
  String? description,
  List<T>? initialValue,
  required Iterable<T> items,
  RadioDialogObjectGenerator<T, String?>? titleGenerator,
  RadioDialogObjectGenerator<T, String?>? subtitleGenerator,
  RadioDialogObjectGenerator<T, Widget?>? iconGenerator,
  String? semanticLabel,
  AlignmentGeometry? alignment,
  bool toggleable = false,
  bool allowEmptySelection = false,
  ValueChanged<List<T>>? onSubmit,
}) async {
  return await showDialog<List<T>>(
        context: context,
        builder: (_) => MultipleChoiceDialog<T>(
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
          allowEmptySelection: allowEmptySelection,
          onSubmit: onSubmit,
        ),
      ) ??
      [];
}

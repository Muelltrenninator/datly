import 'package:flutter/material.dart';

class SizeUpDialogAnimation extends InheritedWidget {
  final Animation<double> animation;

  const SizeUpDialogAnimation._({
    required this.animation,
    required super.child,
  });

  static Animation<double>? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SizeUpDialogAnimation>()
      ?.animation;
  static Animation<double> of(BuildContext context) {
    final Animation<double>? result = maybeOf(context);
    assert(result != null, 'No SizeUpDialogAnimation found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SizeUpDialogAnimation oldWidget) =>
      animation != oldWidget.animation;
}

class SizeUpDialog extends StatefulWidget {
  final Widget child;
  const SizeUpDialog({super.key, required this.child});

  @override
  State<SizeUpDialog> createState() => _SizeUpDialogState();
}

class _SizeUpDialogState extends State<SizeUpDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Durations.extralong4,
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeUpDialogAnimation._(animation: _animation, child: widget.child);
  }
}

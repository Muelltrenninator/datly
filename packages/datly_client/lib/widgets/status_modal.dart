import 'dart:async';

import 'package:flutter/material.dart';

class StatusModal extends StatefulWidget {
  final Completer completer;
  final FutureOr<String?> Function()? failureDetailsGenerator;

  const StatusModal({
    super.key,
    required this.completer,
    this.failureDetailsGenerator,
  });

  @override
  State<StatusModal> createState() => _StatusModalState();
}

class _StatusModalState extends State<StatusModal> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Durations.medium1).then(
      (_) => widget.completer.future
          .then((_) => _onComplete(true))
          .catchError((_, _) => _onComplete(false)),
    );
  }

  bool _isSuccess = false;
  String? _failureDetails;
  void _onComplete(bool success) async {
    if (!mounted) return;

    if (success) _isSuccess = true;
    setState(() {});

    String? tmpDetails;
    if (!success && widget.failureDetailsGenerator != null) {
      tmpDetails = await Future.value(widget.failureDetailsGenerator!());
    }

    if (!success && tmpDetails != null) {
      Future.delayed(Durations.medium3, () {
        if (!mounted) return;
        _failureDetails = tmpDetails;
        setState(() {});
      });
    } else {
      Future.delayed(Durations.long4, () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  Widget _buildFailureDetails() {
    if (_failureDetails == null) return SizedBox(width: double.infinity);
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16, left: 24, right: 24),
          child: Text(
            _failureDetails!,
            textAlign: TextAlign.start,
            style: DefaultTextStyle.of(
              context,
            ).style.copyWith(color: ColorScheme.of(context).error),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.completer.isCompleted,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(top: 64, bottom: 64),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: 48,
                    child: AnimatedSwitcher(
                      duration: Durations.medium3,
                      switchInCurve: Curves.easeInOutCubicEmphasized,
                      switchOutCurve: Curves.easeInOutCubicEmphasized,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: !widget.completer.isCompleted
                          ? CircularProgressIndicator(padding: EdgeInsets.zero)
                          : _isSuccess
                          ? Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.error_outline,
                              size: 48,
                              color: ColorScheme.of(context).error,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: AnimatedSize(
              duration: Durations.medium1,
              curve: Curves.easeInOutCubicEmphasized,
              alignment: AlignmentGeometry.topCenter,
              child: _buildFailureDetails(),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showStatusModal({
  required BuildContext context,
  required Completer completer,
  FutureOr<String?> Function()? failureDetailsGenerator,
}) async {
  return await showModalBottomSheet(
    context: context,
    constraints: BoxConstraints(minWidth: 280, maxWidth: 560),
    requestFocus: true,
    useRootNavigator: true,
    builder: (_) => StatusModal(
      completer: completer,
      failureDetailsGenerator: failureDetailsGenerator,
    ),
  );
}

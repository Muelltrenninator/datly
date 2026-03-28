import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class UnpublishedStrip extends StatelessWidget {
  const UnpublishedStrip({super.key});

  static Widget align([AlignmentGeometry alignment = Alignment.bottomCenter]) =>
      Align(alignment: alignment, child: const UnpublishedStrip());

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        color: Colors.red.withValues(alpha: 0.7),
        child: Transform.scale(
          scaleX: 0.9,
          child: Text(
            AppLocalizations.of(context).adminOnly,
            textAlign: TextAlign.center,
            style: TextTheme.of(context).titleMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SunsetCard extends StatelessWidget {
  const SunsetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Card.filled(
      color: Colors.amber.withValues(alpha: 0.25),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        leading: Icon(Icons.waving_hand_outlined, color: Colors.orange[700]!),
        isThreeLine: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Builder(
          builder: (context) => Text(
            appLocalizations.sunsetTitle,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: DefaultTextStyle.of(context).style.copyWith(height: 1.3),
          ),
        ),
        subtitle: Text(
          appLocalizations.sunsetMessage,
          maxLines: 15,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

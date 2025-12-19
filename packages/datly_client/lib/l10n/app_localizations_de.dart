// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get retry => 'Erneut Versuchen';

  @override
  String get delete => 'Löschen';

  @override
  String get cameraNotFound => 'Keine Kamera Gefunden';

  @override
  String get cameraErrorPermission =>
      'Der Zugriff auf die Kamera wurde verweigert.';

  @override
  String get cameraErrorUnavailable =>
      'Keine Kamera auf diesem Gerät verfügbar.';

  @override
  String get selectCamera => 'Kamera Auswählen';

  @override
  String get selectCameraDescriptionBack => 'Rückkamera';

  @override
  String get selectCameraDescriptionFront => 'Frontkamera';

  @override
  String get selectCameraDescriptionExternal => 'Externe Kamera';

  @override
  String get selectProject => 'Projekt Auswählen';

  @override
  String get noSubmissions => 'Noch keine Einsendungen.';

  @override
  String get submissionStatusPending => 'Ausstehend';

  @override
  String get submissionStatusAccepted => 'Akzeptiert';

  @override
  String get submissionStatusRejected => 'Abgelehnt';

  @override
  String get submissionStatusCensored => 'Zensiert';

  @override
  String get submissionDeleteTitle => 'Einsendung Löschen';

  @override
  String get submissionDeleteMessage =>
      'Möchtest du diese Einsendung wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.';
}

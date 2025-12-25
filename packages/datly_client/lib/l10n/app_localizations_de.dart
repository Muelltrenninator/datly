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
  String invite(
    String username,
    String host,
    int projectCount,
    String projects,
    String code,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      projectCount,
      locale: localeName,
      other: 'Du wurdest hinzugefügt zu: $projects',
      zero: 'Du wurdest noch nicht zu einem Project hinzugefügt',
    );
    return 'Hallo $username 👋\nDu bist eingeladen, an einem Crowdsourcing teilzunehmen! Logg dich gleich ein, ein Account wurde schon für dich erstellt:\n\n- $host\n- $_temp0\n- Logincode: `$code` (NICHT TEILEN!)\n\nHilf uns unser Ziel zu verwirklichen. Man sieht sich dort!';
  }

  @override
  String get loginUnknown => 'Unbekannter Logincode.';

  @override
  String get loginCodeLabel => 'Logincode';

  @override
  String get loginNewHere => 'Neu hier?';

  @override
  String get loginNewHereRequest => 'Einen Code Anfordern.';

  @override
  String get loginPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get loginTermsOfService => 'Nutzungsbedingungen';

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

  @override
  String get accountOverview => 'Account-Übersicht';

  @override
  String accountOverviewFor(String username) {
    return 'für $username';
  }

  @override
  String get aboutAppLearnMore => 'Mehr Erfahren';

  @override
  String get aboutAppLogout => 'Abmelden';
}

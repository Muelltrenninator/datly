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
  String get loginNewHereRequest => 'Einen Code anfordern.';

  @override
  String get loginPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get loginTermsOfService => 'Nutzungsbedingungen';

  @override
  String get cameraNotFound => 'Keine Kamera gefunden';

  @override
  String get cameraErrorPermission =>
      'Der Zugriff auf die Kamera wurde verweigert.';

  @override
  String get cameraErrorUnavailable =>
      'Keine Kamera auf diesem Gerät verfügbar.';

  @override
  String get selectCamera => 'Kamera auswählen';

  @override
  String get selectCameraDescriptionBack => 'Rückkamera';

  @override
  String get selectCameraDescriptionFront => 'Frontkamera';

  @override
  String get selectCameraDescriptionExternal => 'Externe Kamera';

  @override
  String get selectProject => 'Projekt auswählen';

  @override
  String get consentTitle => 'Bildübermittlungszustimmung';

  @override
  String consentVersion(String version, String date) {
    return 'Version: $version, $date';
  }

  @override
  String get consentExplanation1 =>
      'Um dein Bild direkt oder indirekt zu speichern, zu verarbeiten und schließlich zu veröffentlichen, benötigen wir deine ausdrückliche Zustimmung. Dein Benutzername wird mit der Bildeinsendung verknüpft und kann in zukünftigen Veröffentlichungen sichtbar sein. Du kannst deine Zustimmung jederzeit widerrufen, indem du deine Einsendung über dein Profil löschst; dadurch wird das Bild nur nicht in den nächsten Datenexport aufgenommen, aber bereits veröffentlichte Bilder können möglicherweise bis zur nächsten Veröffentlichung nicht vollständig gelöscht werden.  Wenn du nicht zustimmst, fahre bitte nicht mit der Einsendung fort.';

  @override
  String get consentExplanation2 =>
      'Mit deiner Zustimmung bestätigst du, dass du die notwendigen Rechte hast, dieses Bild einzureichen, und dass es keine Rechte Dritter verletzt. Du darfst keine Bilder einreichen, die andere Personen, Themen, die nicht Gegenstand des Projekts sind, oder Inhalte, die gegen gesetzliche Rechte in deiner Gerichtsbarkeit oder Deutschland verstoßen, abbilden. Du stimmst außerdem zu, dass das Bild für Forschungs-, Analyse- und Veröffentlichungszwecke im Zusammenhang mit dem Projekt, zu dem du beiträgst, verwendet werden darf.';

  @override
  String get consentCheckbox =>
      'Ich bestätige, dass das Bild diesen Bedingungen entspricht';

  @override
  String consentPolicy(String privacyPolicy, String termsOfService) {
    return 'Ich habe die $privacyPolicy und $termsOfService gelesen und stimme ihnen zu';
  }

  @override
  String get consentSignature => 'Einfache Elektronische Unterschrift (EES)';

  @override
  String get consentSignatureName => 'Max Mustermann';

  @override
  String consentSignatureLegal(String username) {
    return 'Diese Unterschrift ist rechtsverbindlich. Die Eingabe eines falschen Namens macht die Einsendung ungültig und kann zur Sperrung des Kontos \'$username\' führen.';
  }

  @override
  String get consentAge => 'Ich bin mindestens 16 Jahre alt';

  @override
  String get consentSignatureParental => 'EES eines Erziehungsberechtigten';

  @override
  String get consentParental =>
      'Ich bin Erziehungsberechtigter des Minderjährigen, habe die oben genannten Bedingungen gelesen und stimme diesen zu';

  @override
  String get consentButton => 'Zustimmen und absenden';

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
  String get submissionDeleteTitle => 'Einsendung löschen?';

  @override
  String get submissionDeleteMessage =>
      'Das Löschen einer Einsendung wird dessen Bild vom nächsten Export entfernen und die Einwilligung zurückziehen. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get accountOverview => 'Account-Übersicht';

  @override
  String accountOverviewFor(String username) {
    return 'für $username';
  }

  @override
  String get aboutAppLearnMore => 'Mehr erfahren';

  @override
  String get aboutAppLogout => 'Abmelden';
}

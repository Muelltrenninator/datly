// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String quote(String content) {
    return '„$content“';
  }

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
      other: '\n- Mitglied von: $projects',
      zero: '',
    );
    return 'Hallo $username 👋\nDu bist eingeladen, an einem Crowdsourcing teilzunehmen! Logg dich gleich ein, ein Account wurde schon für dich erstellt:\n\n- $host$_temp0\n- Logincode: `$code` (NICHT TEILEN!)\n\nHilf uns unser Ziel zu verwirklichen. Man sieht sich dort!';
  }

  @override
  String get loginInvalidEmail => 'Ungültige E‑Mail‑Adresse.';

  @override
  String get loginError =>
      'Server nicht erreichbar. Bitte überprüfe deine Internetverbindung.';

  @override
  String get loginAccountDisabled =>
      'Dein Account wurde deaktiviert. Erfahre mehr in der Nachricht, die an deine verknüpfte E‑Mail‑Adresse gesendet wurde.';

  @override
  String get loginUnknown => 'Unbekannte E‑Mail‑Adresse oder Passwort.';

  @override
  String get loginEmailLabel => 'E‑Mail‑Adresse';

  @override
  String get loginPasswordLabel => 'Passwort';

  @override
  String get loginSubmit => 'Login';

  @override
  String get loginRegister => 'Registrieren';

  @override
  String get registerUsernameLabel => 'Benutzername';

  @override
  String get registerEmailLabel => 'E‑Mail‑Adresse';

  @override
  String get registerSubmit => 'Registrieren';

  @override
  String get registerSuccess => 'Registrierung erfolgreich!';

  @override
  String get registerSuccessDescription =>
      'Dein Account wurde erfolgreich erstellt. Bitte überprüfe deine E‑Mail auf ein temporäres Passwort und weitere Anweisungen, um den Registrierungsprozess abzuschließen.';

  @override
  String get registerInvalidUsername =>
      'Benutzernamen müssen zwischen 3 und 16 Zeichen lang sein und dürfen nur Buchstaben, Zahlen und Unterstriche enthalten.';

  @override
  String get registerErrorConflictUsername =>
      'Der Benutzername ist bereits vergeben. Bitte wähle einen anderen.';

  @override
  String get registerErrorConflictEmail =>
      'Die E‑Mail‑Adresse ist bereits mit einem anderen Account verknüpft. Bitte verwende eine andere.';

  @override
  String get registerErrorCaptcha =>
      'Die Captcha‑Überprüfung ist fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get registerLogin => 'Login';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get imprint => 'Impressum';

  @override
  String get navigationUpload => 'Hochladen';

  @override
  String get navigationValidate => 'Validieren';

  @override
  String get cameraNotFound => 'Keine Kamera gefunden';

  @override
  String get cameraErrorPermission =>
      'Der Zugriff auf die Kamera wurde verweigert.';

  @override
  String get cameraErrorUnavailable =>
      'Keine Kamera auf diesem Gerät verfügbar.';

  @override
  String get cameraErrorUnavailableDescription =>
      '# „Keine Kamera auf diesem Gerät verfügbar“ Fehlerbehebung\n\nDatly kann derzeit nicht auf deine Kamera zugreifen. Dies kann verschiedene Ursachen haben. Die häufigsten sind unten aufgeführt.\n\n- Eine andere Anwendung verwendet die Kamera\n\n  - Bitte schließe alle anderen Anwendungen, die die Kamera verwenden könnten, und versuche es erneut.\n\n  - Manchmal können auch andere Browser-Tabs die Kamera blockieren, also versuche bitte auch, andere Tabs zu schließen, die die Kamera verwenden könnten.\n\n- Hardwareproblem oder vorübergehender Fehler\n\n  - Bitte überprüfe deine Kameraeinstellungen, um sicherzustellen, dass sie ordnungsgemäß konfiguriert und von deinem Gerät erkannt wird.\n  - Versuche, dein Gerät neu zu starten, da dies oft vorübergehende Hardwarefehler beheben kann.\n  - Wenn das Problem weiterhin besteht, konsultiere bitte die Dokumentation deines Geräts oder den Support für weitere Schritte zur Fehlerbehebung.';

  @override
  String get cameraErrorTroubleshoot => 'Fehlerbehebung';

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
  String get consentSignature => 'Einfache Elektronische Signatur (EES)';

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
  String get passwordChangeFirstTimeLogin =>
      'Dein aktuelles Passwort ist temporär und wir empfehlen dringend, es durch ein nur dir bekanntes zu ersetzen. Bitte wähle ein neues Passwort, um deinen Account zu sichern.';

  @override
  String get passwordChangeTitle => 'Passwort ändern';

  @override
  String get passwordChangeCurrent => 'Aktuelles Passwort';

  @override
  String get passwordChangeNew => 'Neues Passwort';

  @override
  String get passwordChangeConfirm => 'Neues Passwort bestätigen';

  @override
  String get passwordChangeSubmit => 'Passwort ändern';

  @override
  String get passwordChangeErrorWrongPassword =>
      'Aktuelles Passwort ist falsch.';

  @override
  String get passwordChangeErrorMismatch =>
      'Neues Passwort und Bestätigung stimmen nicht überein.';

  @override
  String get passwordChangeErrorWeak =>
      'Das Passwort muss mindestens 12 Zeichen lang sein und Großbuchstaben, Kleinbuchstaben, Zahlen und Sonderzeichen enthalten.';

  @override
  String passwordChangeErrorInsecure(String message) {
    return 'Dieses Passwort erfüllt nicht die Sicherheitsanforderungen. $message.';
  }

  @override
  String get passwordChangeErrorInsecureCodeShort =>
      'Passwörter müssen mindestens 12 Zeichen lang sein';

  @override
  String get passwordChangeErrorInsecureCodeLong =>
      'Passwörter dürfen höchstens 128 Zeichen lang sein';

  @override
  String get passwordChangeErrorInsecureCodeUppercase =>
      'Passwörter müssen mindestens einen Großbuchstaben enthalten';

  @override
  String get passwordChangeErrorInsecureCodeLowercase =>
      'Passwörter müssen mindestens einen Kleinbuchstaben enthalten';

  @override
  String get passwordChangeErrorInsecureCodeDigit =>
      'Passwörter müssen mindestens eine Ziffer enthalten';

  @override
  String get passwordChangeErrorInsecureCodeSpecial =>
      'Passwörter müssen mindestens ein Sonderzeichen enthalten';

  @override
  String get passwordChangeErrorInsecureCodeCompromised =>
      'Es ist in einem Datenleck aufgetaucht und gilt nicht als sicher';

  @override
  String get noSubmissions => 'Noch keine Einsendungen.';

  @override
  String get invalidPage => 'Ungültige Seitenzahl.';

  @override
  String get validatePleaseSelect => 'Bitte auswählen:';

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
  String get accountOverview => 'Account‑Übersicht';

  @override
  String accountOverviewFor(String username) {
    return 'für $username';
  }

  @override
  String get aboutAppChangePassword => 'Passwort ändern';

  @override
  String get aboutAppLogout => 'Abmelden';

  @override
  String get aboutAppLearnMore => 'Mehr erfahren';
}

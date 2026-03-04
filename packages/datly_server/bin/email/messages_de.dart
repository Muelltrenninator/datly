// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.
// @dart=2.12
// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String? MessageIfAbsent(
    String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'de';

  static m0(reason) => "Grund:<br>${reason}";

  static m1(username) => "Hallo ${username},";

  static m2(date) => "wir möchten dich darüber informieren, dass unsere Nutzungsbedingungen und Datenschutzerklärung aktualisiert wurden. Die Änderungen treten am ${date} in Kraft.";

  static m3(date) => "wir möchten dich darüber informieren, dass unsere Datenschutzerklärung aktualisiert wurde. Die Änderungen treten am ${date} in Kraft.";

  static m4(date) => "wir möchten dich darüber informieren, dass unsere Nutzungsbedingungen aktualisiert wurden. Die Änderungen treten am ${date} in Kraft.";

  static m5(email) => "wir haben kürzlich auf ein neues Anmeldesystem umgestellt. Die alten Logincodes funktionieren daher nicht mehr. Stattdessen kannst du dich jetzt mit deiner E-Mail-Adresse (${email}) und dem folgenden temporären Passwort anmelden.";

  static m6(email) => "Für dich wurde ein Konto auf Datly erstellt. Bitte verwende das folgende temporäre Passwort zusammen mit deiner E-Mail-Adresse (${email}), um dich anzumelden, und ändere es anschließend.";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(Object? _) => {
      'emailAccountDeletedPart1': MessageLookupByLibrary.simpleMessage('dein Konto wurde unwiderruflich gelöscht. Es tut uns leid, dich gehen zu sehen, aber wir respektieren deine Entscheidung.'),
    'emailAccountDeletedPart2': MessageLookupByLibrary.simpleMessage('Bitte beachte, dass Unterschriften und ihre Metadaten aus rechtlichen Gründen aufbewahrt werden. Alle anderen persönlichen Daten wurden unwiderruflich gelöscht.'),
    'emailAccountDeletedPart3': MessageLookupByLibrary.simpleMessage('Falls du Feedback oder Verbesserungsvorschläge hast, zögere bitte nicht, '),
    'emailAccountDeletedPart4': MessageLookupByLibrary.simpleMessage('unser Support-Team zu kontaktieren'),
    'emailAccountDeletedPart5': MessageLookupByLibrary.simpleMessage(' und es uns mitzuteilen. Wir wünschen dir alles Gute!'),
    'emailAccountDeletedSubject': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde gelöscht'),
    'emailAccountDeletedSummary': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde vollständig gelöscht.'),
    'emailAccountDisabledContentExtra1': m0,
    'emailAccountDisabledPart1': MessageLookupByLibrary.simpleMessage('leider müssen wir dir mitteilen, dass dein Konto aufgrund eines möglichen Verstoßes gegen unsere Nutzungsbedingungen deaktiviert wurde.'),
    'emailAccountDisabledPart2': MessageLookupByLibrary.simpleMessage('Falls du glaubst, dass es sich um einen Fehler handelt, '),
    'emailAccountDisabledPart3': MessageLookupByLibrary.simpleMessage('wende dich bitte an unser Support-Team'),
    'emailAccountDisabledPart4': MessageLookupByLibrary.simpleMessage(', um eine Überprüfung anzufordern.'),
    'emailAccountDisabledSubject': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde deaktiviert'),
    'emailAccountDisabledSummary': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde deaktiviert.'),
    'emailAccountReenabledContentExtra1': MessageLookupByLibrary.simpleMessage('Datly öffnen'),
    'emailAccountReenabledPart1': MessageLookupByLibrary.simpleMessage('gute Nachrichten — dein Konto wurde reaktiviert! Wir entschuldigen uns für die Unannehmlichkeiten und danken dir für deine Geduld während der Überprüfung.'),
    'emailAccountReenabledPart2': MessageLookupByLibrary.simpleMessage('Du kannst dich jetzt wieder anmelden und Datly wie gewohnt nutzen. Willkommen zurück!'),
    'emailAccountReenabledSubject': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde reaktiviert'),
    'emailAccountReenabledSummary': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde reaktiviert.'),
    'emailFooter': MessageLookupByLibrary.simpleMessage('Du erhältst diese E-Mail, weil du bei unserem Service registriert bist.<br>Für eine Abmeldung wende dich bitte <a href=\"mailto:me@jhubi1.com\" style=\"color: #999999;text-decoration: underline;\">an den Admin</a> zur Kontolöschung.<br><br>&copy; 2025–2026 JHubi1. Alle Rechte vorbehalten.'),
    'emailHello': m1,
    'emailLegalChangedAllContentExtra1': MessageLookupByLibrary.simpleMessage('Nutzungsbedingungen ansehen'),
    'emailLegalChangedAllContentExtra2': MessageLookupByLibrary.simpleMessage('Datenschutzerklärung ansehen'),
    'emailLegalChangedAllPart1': m2,
    'emailLegalChangedAllPart2': MessageLookupByLibrary.simpleMessage('Wir empfehlen dir, die aktualisierten Dokumente bei Gelegenheit durchzulesen. Durch die weitere Nutzung von Datly nach dem Wirksamkeitsdatum akzeptierst du die geänderten Bedingungen.'),
    'emailLegalChangedAllPart3': MessageLookupByLibrary.simpleMessage('Falls du mit den Änderungen nicht einverstanden bist, kannst du die Nutzung des Dienstes einstellen und die Löschung deines Kontos beantragen.'),
    'emailLegalChangedAllPart4': MessageLookupByLibrary.simpleMessage('Bei Fragen kannst du dich jederzeit '),
    'emailLegalChangedAllPart5': MessageLookupByLibrary.simpleMessage('an unser Support-Team wenden'),
    'emailLegalChangedAllPart6': MessageLookupByLibrary.simpleMessage('.'),
    'emailLegalChangedAllSubject': MessageLookupByLibrary.simpleMessage('Aktualisierung der Datly-Nutzungsbedingungen und Datenschutzerklärung'),
    'emailLegalChangedAllSummary': MessageLookupByLibrary.simpleMessage('Unsere Nutzungsbedingungen und Datenschutzerklärung wurden aktualisiert.'),
    'emailLegalChangedPrivacyContentExtra1': MessageLookupByLibrary.simpleMessage('Datenschutzerklärung ansehen'),
    'emailLegalChangedPrivacyPart1': m3,
    'emailLegalChangedPrivacyPart2': MessageLookupByLibrary.simpleMessage('Wir empfehlen dir, das aktualisierte Dokument bei Gelegenheit durchzulesen. Durch die weitere Nutzung von Datly nach dem Wirksamkeitsdatum akzeptierst du die geänderten Bedingungen.'),
    'emailLegalChangedPrivacyPart3': MessageLookupByLibrary.simpleMessage('Falls du mit den Änderungen nicht einverstanden bist, kannst du die Nutzung des Dienstes einstellen und die Löschung deines Kontos beantragen.'),
    'emailLegalChangedPrivacyPart4': MessageLookupByLibrary.simpleMessage('Bei Fragen kannst du dich jederzeit '),
    'emailLegalChangedPrivacyPart5': MessageLookupByLibrary.simpleMessage('an unser Support-Team wenden'),
    'emailLegalChangedPrivacyPart6': MessageLookupByLibrary.simpleMessage('.'),
    'emailLegalChangedPrivacySubject': MessageLookupByLibrary.simpleMessage('Aktualisierung der Datly-Datenschutzerklärung'),
    'emailLegalChangedPrivacySummary': MessageLookupByLibrary.simpleMessage('Unsere Datenschutzerklärung wurde aktualisiert.'),
    'emailLegalChangedTermsContentExtra1': MessageLookupByLibrary.simpleMessage('Nutzungsbedingungen ansehen'),
    'emailLegalChangedTermsPart1': m4,
    'emailLegalChangedTermsPart2': MessageLookupByLibrary.simpleMessage('Wir empfehlen dir, das aktualisierte Dokument bei Gelegenheit durchzulesen. Durch die weitere Nutzung von Datly nach dem Wirksamkeitsdatum akzeptierst du die geänderten Bedingungen.'),
    'emailLegalChangedTermsPart3': MessageLookupByLibrary.simpleMessage('Falls du mit den Änderungen nicht einverstanden bist, kannst du die Nutzung des Dienstes einstellen und die Löschung deines Kontos beantragen.'),
    'emailLegalChangedTermsPart4': MessageLookupByLibrary.simpleMessage('Bei Fragen kannst du dich jederzeit '),
    'emailLegalChangedTermsPart5': MessageLookupByLibrary.simpleMessage('an unser Support-Team wenden'),
    'emailLegalChangedTermsPart6': MessageLookupByLibrary.simpleMessage('.'),
    'emailLegalChangedTermsSubject': MessageLookupByLibrary.simpleMessage('Aktualisierung der Datly-Nutzungsbedingungen'),
    'emailLegalChangedTermsSummary': MessageLookupByLibrary.simpleMessage('Unsere Nutzungsbedingungen wurden aktualisiert.'),
    'emailPasswordResetMigrationContentExtra1': MessageLookupByLibrary.simpleMessage('Jetzt anmelden'),
    'emailPasswordResetMigrationPart1': m5,
    'emailPasswordResetMigrationPart2': MessageLookupByLibrary.simpleMessage('Diese Änderung war nötig, um die Plattform für ein breiteres Publikum zu öffnen, wodurch das alte Einladungscode-System nicht mehr praktikabel war. Wir entschuldigen uns für die Unannehmlichkeiten und danken dir für dein Verständnis.'),
    'emailPasswordResetMigrationSubject': MessageLookupByLibrary.simpleMessage('Wichtige Änderungen an deinem Datly-Login'),
    'emailPasswordResetMigrationSummary': MessageLookupByLibrary.simpleMessage('Du kannst dich jetzt mit deiner E-Mail-Adresse und einem Passwort anmelden.'),
    'emailPasswordResetTemporaryContentExtra1': MessageLookupByLibrary.simpleMessage('Jetzt anmelden'),
    'emailPasswordResetTemporaryPart1': MessageLookupByLibrary.simpleMessage('dein Passwort wurde zurückgesetzt. Bitte verwende das folgende temporäre Passwort, um dich anzumelden, und ändere es anschließend.'),
    'emailPasswordResetTemporarySubject': MessageLookupByLibrary.simpleMessage('Dein Datly-Passwort wurde zurückgesetzt'),
    'emailPasswordResetTemporarySummary': MessageLookupByLibrary.simpleMessage('Dein Datly-Passwort wurde zurückgesetzt.'),
    'emailPasswordResetWelcomeContentExtra1': MessageLookupByLibrary.simpleMessage('Jetzt anmelden'),
    'emailPasswordResetWelcomePart1': MessageLookupByLibrary.simpleMessage('du wurdest eingeladen, bei Datly mitzumachen! Wir sammeln Fotos von Müll, um ihn besser zu klassifizieren und zu verstehen — und wir freuen uns, dass du dabei bist.'),
    'emailPasswordResetWelcomePart2': m6,
    'emailPasswordResetWelcomeSubject': MessageLookupByLibrary.simpleMessage('Willkommen bei Datly'),
    'emailPasswordResetWelcomeSummary': MessageLookupByLibrary.simpleMessage('Bitte melde dich mit dem temporären Passwort an, das wir für dich erstellt haben.'),
    'emailWelcomeContentExtra1': MessageLookupByLibrary.simpleMessage('Jetzt anmelden'),
    'emailWelcomePart1': MessageLookupByLibrary.simpleMessage('wir freuen uns, dich bei Datly begrüßen zu dürfen! Dein Konto wurde erstellt und ist einsatzbereit. Bitte verwende das folgende temporäre Passwort für deine erste Anmeldung und ändere es anschließend.'),
    'emailWelcomePart2': MessageLookupByLibrary.simpleMessage('Du kannst jetzt dein erstes Foto aufnehmen und zu unseren Crowdsourcing-Bemühungen beitragen. Bei Fragen oder wenn du Hilfe brauchst, kannst du dich jederzeit '),
    'emailWelcomePart3': MessageLookupByLibrary.simpleMessage('an unser Support-Team wenden'),
    'emailWelcomePart4': MessageLookupByLibrary.simpleMessage('. Wir helfen dir gerne, das Beste aus Datly herauszuholen.'),
    'emailWelcomeSubject': MessageLookupByLibrary.simpleMessage('Willkommen bei Datly'),
    'emailWelcomeSummary': MessageLookupByLibrary.simpleMessage('Dein Konto wurde erstellt.')
  };
}

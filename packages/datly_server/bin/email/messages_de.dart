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

  static m2(email) => "wir haben kürzlich auf ein neues Anmeldesystem umgestellt. Die alten Logincodes funktionieren daher nicht mehr. Stattdessen kannst du dich jetzt mit deiner E-Mail-Adresse (${email}) und dem folgenden temporären Passwort anmelden.";

  static m3(email) => "Für dich wurde ein Konto auf Datly erstellt. Bitte verwende das folgende temporäre Passwort zusammen mit deiner E-Mail-Adresse (${email}), um dich anzumelden, und ändere es anschließend.";

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
    'emailAccountDisabledPart1': MessageLookupByLibrary.simpleMessage('leider müssen wir dir mitteilen, dass dein Konto aufgrund eines möglichen Verstoßes gegen unsere Nutzungsbedingungen gesperrt wurde.'),
    'emailAccountDisabledPart2': MessageLookupByLibrary.simpleMessage('Falls du glaubst, dass es sich um einen Fehler handelt, '),
    'emailAccountDisabledPart3': MessageLookupByLibrary.simpleMessage('wende dich bitte an unser Support-Team'),
    'emailAccountDisabledPart4': MessageLookupByLibrary.simpleMessage(', um eine Überprüfung anzufordern.'),
    'emailAccountDisabledSubject': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde gesperrt'),
    'emailAccountDisabledSummary': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde gesperrt.'),
    'emailAccountReenabledContentExtra1': MessageLookupByLibrary.simpleMessage('Datly öffnen'),
    'emailAccountReenabledPart1': MessageLookupByLibrary.simpleMessage('gute Nachrichten — dein Konto wurde reaktiviert! Wir entschuldigen uns für die Unannehmlichkeiten und danken dir für deine Geduld während der Überprüfung.'),
    'emailAccountReenabledPart2': MessageLookupByLibrary.simpleMessage('Du kannst dich jetzt wieder anmelden und Datly wie gewohnt nutzen. Willkommen zurück!'),
    'emailAccountReenabledSubject': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde reaktiviert'),
    'emailAccountReenabledSummary': MessageLookupByLibrary.simpleMessage('Dein Datly-Konto wurde reaktiviert.'),
    'emailFooter': MessageLookupByLibrary.simpleMessage('Du erhältst diese E-Mail, weil du bei unserem Service registriert bist.<br>Für eine Abmeldung wende dich bitte <a href=\"mailto:me@jhubi1.com\" style=\"color: #999999;text-decoration: underline;\">an den Admin</a> zur Kontolöschung.<br><br>&copy; 2025–2026 JHubi1. Alle Rechte vorbehalten.'),
    'emailHello': m1,
    'emailPasswordResetMigrationContentExtra1': MessageLookupByLibrary.simpleMessage('Jetzt anmelden'),
    'emailPasswordResetMigrationPart1': m2,
    'emailPasswordResetMigrationPart2': MessageLookupByLibrary.simpleMessage('Diese Änderung war nötig, um die Plattform für ein breiteres Publikum zu öffnen, wodurch das alte Einladungscode-System nicht mehr praktikabel war. Wir entschuldigen uns für die Unannehmlichkeiten und danken dir für dein Verständnis.'),
    'emailPasswordResetMigrationSubject': MessageLookupByLibrary.simpleMessage('Wichtige Änderungen an deinem Datly-Login'),
    'emailPasswordResetMigrationSummary': MessageLookupByLibrary.simpleMessage('Du kannst dich jetzt mit deiner E-Mail-Adresse und einem Passwort anmelden.'),
    'emailPasswordResetTemporaryContentExtra1': MessageLookupByLibrary.simpleMessage('Jetzt anmelden'),
    'emailPasswordResetTemporaryPart1': MessageLookupByLibrary.simpleMessage('dein Passwort wurde zurückgesetzt. Bitte verwende das folgende temporäre Passwort, um dich anzumelden, und ändere es anschließend.'),
    'emailPasswordResetTemporarySubject': MessageLookupByLibrary.simpleMessage('Dein Datly-Passwort wurde zurückgesetzt'),
    'emailPasswordResetTemporarySummary': MessageLookupByLibrary.simpleMessage('Dein Datly-Passwort wurde zurückgesetzt.'),
    'emailPasswordResetWelcomeContentExtra1': MessageLookupByLibrary.simpleMessage('Jetzt anmelden'),
    'emailPasswordResetWelcomePart1': MessageLookupByLibrary.simpleMessage('du wurdest eingeladen, bei Datly mitzumachen! Wir sammeln Fotos von Müll, um ihn besser zu klassifizieren und zu verstehen — und wir freuen uns, dass du dabei bist.'),
    'emailPasswordResetWelcomePart2': m3,
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

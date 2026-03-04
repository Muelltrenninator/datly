# Datly — Datenschutzerklärung

**Gültig ab:** 01.03.2026
**Betreiber / Verantwortlicher:** JHubi1
**Kontakt:** <me@jhubi1.com>
**Standort:** Deutschland

## Kurzübersicht

- Datly ermöglicht registrierten Nutzern, Fotos aufzunehmen und hochzuladen. Hochgeladene Fotos werden **ausschließlich** zum Trainieren, Evaluieren und Verbessern von KI/ML-Modellen verwendet.
- Konten können von Administratoren erstellt oder durch Selbstregistrierung (mit CAPTCHA-Verifizierung) angelegt werden. Benutzernamen werden von Admins zugewiesen oder bei der Registrierung gewählt und sind **nicht änderbar**.
- Wir erfassen Ihren **Benutzernamen, Ihre E-Mail-Adresse** (erforderlich zur Kontoerstellung) und Ihr **gehashtes Passwort**. E-Mail-Adressen und Benutzernamen werden **nicht** in Trainingsdatensätze aufgenommen.
- Alle hochgeladenen Bilder werden vor der Speicherung vollständig von eingebetteten Metadaten (EXIF) **befreit**, auf **224 × 224 Pixel zugeschnitten und skaliert** sowie neu kodiert (Datenminimierung).
- Bei jeder Bildeinreichung unterzeichnen Sie ein Einwilligungsformular. Wir speichern dauerhaft die **IP-Adresse**, den **Browser-User-Agent** und einen **Snapshot des Einwilligungsformulars sowie Ihrer Kontodaten** zum Zeitpunkt der Unterzeichnung als Rechtsnachweis.
- Ihre **bevorzugte Sprache** wird automatisch aus dem HTTP-Header `Accept-Language` erkannt und in Ihrem Konto gespeichert.
- Die Nutzung des Dienstes ist **kostenlos**.

---

## 1. Verantwortlicher & Kontakt

Verantwortlicher für die über Datly durchgeführte Datenverarbeitung ist:

**JHubi1**
E-Mail: **<me@jhubi1.com>**
Standort: Deutschland

Ein Datenschutzbeauftragter (DSB) wurde nicht formell bestellt. Für alle Fragen, Datenschutzanfragen oder zur Ausübung Ihrer Rechte wenden Sie sich bitte an die obige Adresse.

## 2. Kategorien der erhobenen personenbezogenen Daten

### 2.1 Kontodaten

| Datum                         | Details                                                                                                                                                               |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Benutzername**              | 3–16 alphanumerische Zeichen; durch Admin zugewiesen oder bei Selbstregistrierung gewählt; dient als primärer Identifikator                                           |
| **E-Mail-Adresse**            | Erforderlich bei Kontoerstellung; verwendet für transaktionale Benachrichtigungen (Willkommen, Passwort-Reset, Kontostatus-Änderungen)                                |
| **Passwort**                  | Wird ausschließlich als **Argon2id-Hash** gespeichert (niemals im Klartext); vor Annahme gegen Mindest-Komplexitätsregeln und die Have I Been Pwned-Datenbank geprüft |
| **Sprache / Sprachpräferenz** | Wird automatisch aus dem `Accept-Language`-Header Ihres Browsers erkannt und bei jeder authentifizierten Anfrage aktualisiert                                         |
| **Rolle**                     | Eine von `external`, `user` oder `admin`; bestimmt die Zugriffsberechtigungen                                                                                         |
| **Kontostatus**               | Ob Ihr Konto aktiviert, deaktiviert (mit Begründung) ist, und das Beitrittsdatum                                                                                      |
| **Projektzuordnungen**        | Liste der Projekt-IDs, zu denen Sie beitragen dürfen                                                                                                                  |

### 2.2 Von Ihnen hochgeladene Bilder

- Der ursprüngliche Bilddateiinhalt wird vor der Speicherung wie folgt verarbeitet:
  1. Alle eingebetteten Metadaten (EXIF, GPS, Kameramodell, Zeitstempel etc.) werden **vollständig entfernt**.
  2. Minimale neue EXIF-Daten werden geschrieben: `Software: Datly`, `Copyright: (c) <Jahr> <Benutzername>`.
  3. Das Bild wird **mittig zugeschnitten und auf 224 × 224 Pixel skaliert** (kubische Interpolation).
  4. Ein **BlurHash**-Platzhalter wird für Anzeigezwecke berechnet.
  5. Das verarbeitete Bild wird als PNG oder JPEG neu kodiert und unter einem zufälligen UUID-Dateinamen gespeichert.
- Das originale, unverarbeitete Bild wird **nicht aufbewahrt**.

### 2.3 Einreichungsmetadaten

| Datum                     | Details                                                                                            |
| ------------------------- | -------------------------------------------------------------------------------------------------- |
| **Einreichungs-ID**       | Automatisch generierte Ganzzahl                                                                    |
| **Projekt-ID**            | Das Projekt, zu dem das Bild eingereicht wurde                                                     |
| **Einreichender Nutzer**  | Ihr Benutzername                                                                                   |
| **Status**                | `pending` (ausstehend), `accepted` (akzeptiert), `rejected` (abgelehnt) oder `censored` (zensiert) |
| **Einreichungszeitpunkt** | Datum und Uhrzeit des Uploads                                                                      |
| **Asset-ID**              | Zufällige UUID, die auf die gespeicherte Bilddatei verweist                                        |
| **Asset-MIME-Typ**        | `image/png` oder `image/jpeg`                                                                      |
| **Asset-BlurHash**        | Perzeptueller Hash für UI-Platzhalter                                                              |

### 2.4 Einwilligungsunterschriften

Jede Bildeinreichung erfordert eine Einwilligungsunterschrift. Folgende Daten werden als **Rechtsnachweis** gespeichert:

| Datum                              | Details                                                                                                       |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Unterschriftstext**              | Der von Ihnen eingegebene Text zur Bestätigung der Einwilligung (max. 128 Zeichen)                            |
| **Elterliche Unterschrift**        | Falls zutreffend, eine Einwilligung eines Elternteils/Erziehungsberechtigten (max. 128 Zeichen)               |
| **Unterschriftsmethode**           | Derzeit: `typed` (eingetippt)                                                                                 |
| **Einwilligungsformular-Snapshot** | Der genaue Text des Einwilligungsformulars, dem Sie zum Zeitpunkt der Unterzeichnung zugestimmt haben         |
| **Einwilligungsversion**           | Versionsnummer des Einwilligungsformulars                                                                     |
| **IP-Adresse**                     | Die IP-Adresse des einreichenden Clients zum Zeitpunkt der Unterzeichnung                                     |
| **Browser-User-Agent**             | Der `User-Agent`-HTTP-Header des einreichenden Clients                                                        |
| **Nutzer-Snapshot**                | Ein zeitpunktbezogener JSON-Snapshot Ihres vollständigen Kontodatensatzes (einschließlich gehashtem Passwort) |
| **Einreichungs-Snapshot**          | Ein zeitpunktbezogener JSON-Snapshot des Einreichungsdatensatzes                                              |
| **Unterzeichnungszeitpunkt**       | Datum und Uhrzeit der Unterzeichnung                                                                          |
| **Widerrufsdaten**                 | Falls widerrufen: Widerrufszeitpunkt und Begründung                                                           |

### 2.5 Netzwerk- und Gerätemetadaten

| Datum                      | Verwendung                                                                                   | Aufbewahrung                                                               |
| -------------------------- | -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| **IP-Adresse**             | Einwilligungsunterschriften; Ratenbegrenzung; CAPTCHA-Verifizierung (an Cloudflare gesendet) | Dauerhaft in Unterschriften; vorübergehend im Speicher für Ratenbegrenzung |
| **Browser-User-Agent**     | Einwilligungsunterschriften                                                                  | Dauerhaft in Unterschriften                                                |
| **Accept-Language-Header** | Spracherkennung                                                                              | Als `locale` in Ihrem Konto gespeichert                                    |

### 2.6 Daten, die wir **nicht** erheben

Wir erheben nicht: Kontaktlisten, Gerätekennungen, Adressbücher, Zahlungsdaten, Standortdaten (über IP hinaus), Gesundheitsdaten, biometrische Daten, Tracking-Cookies oder Daten von Analyse- oder Werbe-SDKs. Es werden keine Cookies oder ähnliche Tracking-Technologien verwendet.

> **Wichtig:** Laden Sie keine Fotos hoch, die sensible personenbezogene Daten anderer Personen enthalten (z. B. biometrische Daten, Gesundheitsinformationen), es sei denn, Sie verfügen über eine entsprechende Rechtsgrundlage.

## 3. Zwecke und Rechtsgrundlagen der Verarbeitung

| Zweck                                                                                                                                                     | Betroffene Daten                                                                                                               | Rechtsgrundlage (Art. 6 DSGVO)                                                                                                                                                                                          |
| --------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **KI/ML-Modelltraining** — Speicherung und Verarbeitung von Bildern zum Training, zur Evaluierung, Verbesserung und zum Benchmarking von KI/ML-Modellen   | Hochgeladene Bilder, Einreichungsmetadaten                                                                                     | **Einwilligung (Art. 6 Abs. 1 lit. a)** — ausdrückliche informierte Einwilligung bei jedem Upload durch die Einwilligungsunterschrift                                                                                   |
| **Kontoverwaltung** — Erstellung, Authentifizierung und Verwaltung Ihres Kontos; Versand transaktionaler E-Mails                                          | Benutzername, E-Mail, gehashtes Passwort, Rolle, Sprache, Kontostatus                                                          | **Vertragserfüllung (Art. 6 Abs. 1 lit. b)** — erforderlich zur Bereitstellung des Dienstes, für den Sie sich registriert haben                                                                                         |
| **Sicherheit & Missbrauchsprävention** — Ratenbegrenzung, CAPTCHA-Verifizierung, Passwort-Breach-Prüfung, Zugriffskontrolle                               | IP-Adresse, User-Agent, gehashtes Passwort-Präfix (5 Zeichen des SHA-1)                                                        | **Berechtigte Interessen (Art. 6 Abs. 1 lit. f)** — unser Interesse am Schutz des Dienstes, seiner Nutzer und der Datenintegrität                                                                                       |
| **Rechtsnachweis der Einwilligung** — Aufbewahrung des Nachweises einer gültigen Einwilligung zur Bildnutzung, auch nach Konto- oder Einreichungslöschung | Einwilligungsunterschriften (IP, User-Agent, Nutzer-Snapshot, Einreichungs-Snapshot, Unterschriftstext, Einwilligungsformular) | **Rechtliche Verpflichtung (Art. 6 Abs. 1 lit. c)** und **Berechtigte Interessen (Art. 6 Abs. 1 lit. f)** — zum Nachweis der Einhaltung der Einwilligungsanforderungen (Art. 7 Abs. 1 DSGVO) und Projektverpflichtungen |
| **Transaktionale Kommunikation** — Willkommens-E-Mails, Passwort-Resets, Kontostatusbenachrichtigungen                                                    | E-Mail-Adresse, Benutzername, Sprache                                                                                          | **Vertragserfüllung (Art. 6 Abs. 1 lit. b)**                                                                                                                                                                            |

Soweit wir uns auf **berechtigte Interessen** stützen, haben wir eine Abwägung durchgeführt und festgestellt, dass die Verarbeitung verhältnismäßig ist und Ihre Rechte nicht überwiegt. Sie können Details dieser Bewertung anfordern.

Soweit wir uns auf **Einwilligung** stützen, können Sie diese jederzeit widerrufen (siehe Abschnitt 7). Der Widerruf berührt nicht die Rechtmäßigkeit der vor dem Widerruf durchgeführten Verarbeitung.

## 4. Was Sie uns einräumen (Lizenz & Modellnutzung)

Mit dem Hochladen eines Bildes und der Unterzeichnung des Einwilligungsformulars räumen Sie Datly eine **nicht-exklusive, weltweite, lizenzgebührenfreie, übertragbare und unterlizenzierbare** Lizenz ein, das Bild und alle daraus abgeleiteten Daten zu speichern, zu reproduzieren, zu analysieren, zu transformieren (einschließlich Anonymisierung und Merkmalsextraktion) und für das Training, die Validierung, Evaluierung und Verbesserung von KI/ML-Modellen sowie für zugehörige Forschung und Entwicklung zu nutzen. Dies umfasst die Verwendung in internen oder externen Veröffentlichungen oder Benchmarks in de-identifizierter oder aggregierter Form.

**Wichtig:**

- Wir entfernen alle originalen EXIF-Metadaten und skalieren Bilder vor der Speicherung; die Originaldatei wird nicht aufbewahrt.
- Wenn Sie eine Löschung beantragen, werden wir Originaldateien löschen und Maßnahmen ergreifen, um sie aus künftigem Training auszuschließen. Informationen, die bereits unwiderruflich in ein trainiertes Modell eingeflossen sind, können jedoch möglicherweise nicht vollständig entfernt werden. Wir werden angemessene Anstrengungen unternehmen, um die weitere Verwendung gelöschter Bilder in späteren Trainingsläufen zu verhindern.
- Benutzernamen und E-Mail-Adressen werden **niemals** in Trainingsdatensätze oder geteilte Modellartefakte aufgenommen.

## 5. Datenspeicherung

| Datenkategorie                                    | Aufbewahrungsdauer                                                                                                                                                                                                                     |
| ------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Hochgeladene Bilder**                           | Bis Sie eine Löschung beantragen, die Einreichung gelöscht oder zensiert wird — je nachdem, was zuerst eintritt. Kein automatischer Ablauf.                                                                                            |
| **Einreichungsdatensätze**                        | Werden gelöscht, wenn die Einreichung oder das Nutzerkonto gelöscht wird (Kaskadenlöschung). Bei zensierten Einreichungen bleibt der Datensatz erhalten, die Bilddatei wird jedoch gelöscht.                                           |
| **Kontodaten**                                    | Aufbewahrt bis das Konto auf Ihren Wunsch hin von einem Administrator gelöscht wird.                                                                                                                                                   |
| **Einwilligungsunterschriften**                   | Werden **unbefristet** aufbewahrt, auch nach Konto- oder Einreichungslöschung. Unterschriften werden als widerrufen markiert (mit Zeitstempel und Begründung), aber nicht gelöscht, da sie als Rechtsnachweis der Einwilligung dienen. |
| **IP-Adressen & User-Agents** (in Unterschriften) | Werden **unbefristet** als Teil des Einwilligungs-Unterschriftsdatensatzes aufbewahrt (siehe oben).                                                                                                                                    |
| **JWT-Authentifizierungstoken**                   | Laufen nach **180 Tagen** ab. Token sind zustandslos und werden nicht serverseitig gespeichert.                                                                                                                                        |
| **Server-Logs**                                   | HTTP-Anfragemethode, Statuscode und URL-Pfad werden auf stderr protokolliert. Logs werden über die Lebensdauer des Serverprozesses hinaus nicht persistent gespeichert, sofern sie nicht von der Hosting-Umgebung erfasst werden.      |

Wir sind uns bewusst, dass eine unbefristete Aufbewahrung gemäß dem Grundsatz der Speicherbegrenzung der DSGVO (Art. 5 Abs. 1 lit. e) gerechtfertigt sein muss. Wir bewahren Einwilligungsunterschriften unbefristet auf, da sie den Nachweis einer rechtmäßigen Einwilligung darstellen (Art. 7 Abs. 1 DSGVO) und zur Einhaltung der Verpflichtungen des übergeordneten Forschungsprojekts erforderlich sind. Wir überprüfen die Aufbewahrungsnotwendigkeit regelmäßig.

Es gibt derzeit keinen automatisierten Datenlöschmechanismus. Wenn Sie die Löschung Ihrer Daten wünschen, kontaktieren Sie uns (siehe Abschnitt 7).

## 6. Empfänger und Auftragsverarbeiter

Wir teilen personenbezogene Daten mit folgenden Kategorien von Empfängern:

| Empfänger                        | Geteilte Daten                                                  | Zweck                                                                                           | Standort                                          |
| -------------------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| **Hetzner Online GmbH**          | Alle gespeicherten Daten (Datenbank, Bilddateien)               | Hosting-Infrastruktur (privater Shared Server)                                                  | Nürnberg, Deutschland (EU)                        |
| **Konfigurierter SMTP-Anbieter** | E-Mail-Adresse, Benutzername, temporäre Passwörter, Kontostatus | Versand transaktionaler E-Mails                                                                 | Abhängig von der Konfiguration; siehe Abschnitt 8 |
| **Cloudflare, Inc.**             | CAPTCHA-Response-Token, Client-IP-Adresse                       | CAPTCHA-Verifizierung (Turnstile) bei Selbstregistrierung                                       | USA (siehe Abschnitt 8)                           |
| **Have I Been Pwned (HIBP)**     | Erste 5 Zeichen des SHA-1-Hashes Ihres Passworts                | Passwort-Breach-Prüfung (k-Anonymity-Modell; der vollständige Hash verlässt niemals den Server) | International                                     |

Auftragsverarbeiter sind vertraglich verpflichtet, Daten nur nach unseren Weisungen zu verarbeiten und angemessene Schutzmaßnahmen umzusetzen. Wir **verkaufen keine** personenbezogenen Daten. De-identifizierte oder aggregierte Forschungsergebnisse können veröffentlicht werden; Benutzernamen und E-Mail-Adressen werden niemals darin enthalten sein.

## 7. Ihre Rechte nach der DSGVO

Nach der DSGVO haben Sie folgende Rechte, die Sie jederzeit per E-Mail an **<me@jhubi1.com>** ausüben können:

| Recht                                         | Beschreibung                                                                                                                                                             |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Auskunft** (Art. 15)                        | Bestätigung, ob wir Ihre Daten verarbeiten, und Erhalt einer Kopie                                                                                                       |
| **Berichtigung** (Art. 16)                    | Berichtigung unrichtiger Daten (Hinweis: Benutzernamen können nicht geändert werden)                                                                                     |
| **Löschung** (Art. 17)                        | Löschung Ihrer Daten („Recht auf Vergessenwerden"), vorbehaltlich der nachstehenden Einschränkungen                                                                      |
| **Einschränkung** (Art. 18)                   | Einschränkung der Verarbeitung Ihrer Daten unter bestimmten Umständen                                                                                                    |
| **Datenübertragbarkeit** (Art. 20)            | Erhalt Ihrer Daten in einem strukturierten, gängigen, maschinenlesbaren Format                                                                                           |
| **Widerspruch** (Art. 21)                     | Widerspruch gegen die Verarbeitung aufgrund berechtigter Interessen; wir stellen die Verarbeitung ein, es sei denn, wir können zwingende schutzwürdige Gründe nachweisen |
| **Widerruf der Einwilligung** (Art. 7 Abs. 3) | Widerruf Ihrer Einwilligung zur Bildverarbeitung jederzeit; dies berührt nicht die Rechtmäßigkeit der vor dem Widerruf durchgeführten Verarbeitung                       |

**Einschränkungen bei der Löschung:**

- **Einwilligungsunterschriften** (einschließlich IP-Adresse, User-Agent und Konto-Snapshot) werden auch nach Kontolöschung als Rechtsnachweis der Einwilligung aufbewahrt. Sie werden als widerrufen markiert, aber nicht gelöscht.
- Informationen, die bereits unwiderruflich in ein trainiertes KI/ML-Modell eingeflossen sind, können möglicherweise nicht vollständig entfernt werden. Wir werden gelöschte Bilder aus allen künftigen Trainings ausschließen.

Wir antworten auf Ihre Anfrage innerhalb **eines Monats** (verlängerbar um zwei weitere Monate bei komplexen Anfragen, mit Benachrichtigung). Wir können einen angemessenen Identitätsnachweis verlangen, bevor wir Anfragen bearbeiten. Die Ausübung Ihrer Rechte ist kostenlos.

## 8. Internationale Datenübermittlungen

Unsere primäre Datenspeicherung erfolgt innerhalb der EU (Hetzner, Deutschland). Bestimmte Verarbeitungen umfassen jedoch Übermittlungen außerhalb des EWR:

| Übermittlung                                     | Zielort                        | Schutzmaßnahme                                                                                                           |
| ------------------------------------------------ | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| **Cloudflare Turnstile** (CAPTCHA-Verifizierung) | USA                            | EU-Standardvertragsklauseln (SCCs) und Cloudflares Auftragsverarbeitungsvertrag                                          |
| **Have I Been Pwned** (Passwort-Breach-Prüfung)  | International                  | Es wird nur ein 5-Zeichen-Hash-Präfix übertragen (praktisch keine personenbezogenen Daten); k-Anonymity-Modell verwendet |
| **SMTP-Anbieter** (E-Mail-Versand)               | Abhängig von der Konfiguration | Angemessene Schutzmaßnahmen (SCCs oder Angemessenheitsbeschluss) werden wie erforderlich angewendet                      |

Soweit wir personenbezogene Daten außerhalb des EWR übermitteln, stellen wir sicher, dass angemessene Schutzmaßnahmen gemäß Kapitel V DSGVO (Art. 44–49) vorhanden sind, einschließlich EU-Standardvertragsklauseln oder Berufung auf einen Angemessenheitsbeschluss.

## 9. Sicherheitsmaßnahmen

Wir setzen angemessene technische und organisatorische Maßnahmen (Art. 32 DSGVO) zum Schutz Ihrer Daten um:

- **Passwortsicherheit:** Argon2id-Hashing mit OWASP-empfohlenen Parametern; zeitkonstanter Hash-Vergleich zur Vermeidung von Timing-Angriffen; Mindest-Komplexitätsanforderungen; Breach-Datenbank-Prüfung
- **Authentifizierung:** RS256 (RSA 2048-Bit) JWT-Token mit 180-Tage-Ablauf; asymmetrische Schlüsselsignierung
- **Zugriffskontrolle:** Rollenbasierte Berechtigungen (external/user/admin); Durchsetzung deaktivierter Konten bei jeder Anfrage
- **Ratenbegrenzung:** Maximal 5 Anfragen pro 10 Sekunden pro IP bei fehlgeschlagenen Authentifizierungsversuchen
- **CAPTCHA:** Cloudflare Turnstile bei Selbstregistrierung zur Verhinderung automatisierten Missbrauchs
- **Datenminimierung:** EXIF-Metadaten werden vollständig aus Bildern entfernt; Bilder auf 224 × 224 px skaliert; Originaldateien nicht aufbewahrt
- **Eingabevalidierung:** Strikte Längenbegrenzungen und Formatvalidierung aller Nutzereingaben; Schutz vor Pfadmanipulation; Asset-Dateinamen-Validierung per Regex
- **Verschlüsselung bei Übertragung:** HTTPS (TLS) für alle Verbindungen
- **Datenbanksicherheit:** SQLite mit WAL-Journal-Modus, Foreign-Key-Durchsetzung, Auto-Vacuum; in privater Serverumgebung gespeichert
- **Log-Hygiene:** Einwilligungsbezogene Query-Parameter werden in Anfrage-Logs geschwärzt; Passwörter werden nie in API-Antworten zurückgegeben; `Powered-By`-Header gibt keine Versionsinformationen preis
- **Kryptografische Zufallszahlen:** `Random.secure()` für alle sicherheitsrelevanten Operationen (Token, Salts, UUIDs)
- **CORS-Richtlinie:** `Cross-Origin-Embedder-Policy: require-corp`, `Cross-Origin-Opener-Policy: same-origin`

Kein System ist absolut sicher. Im Falle einer Verletzung des Schutzes personenbezogener Daten werden wir die Meldepflichten gemäß Art. 33–34 DSGVO einhalten (Meldung an die Aufsichtsbehörde innerhalb von 72 Stunden und an betroffene Personen, wenn die Verletzung ein hohes Risiko darstellt).

## 10. Automatisierte Entscheidungsfindung

Wir verwenden **keine** automatisierte Entscheidungsfindung oder Profiling, die rechtliche Wirkung entfaltet oder Sie in ähnlicher Weise erheblich beeinträchtigt (Art. 22 DSGVO). Die Bildmoderation (Annahme/Ablehnung/Zensur) erfolgt manuell durch Administratoren.

## 11. Datenschutz-Folgenabschätzung (DSFA)

Die Verarbeitung persönlicher Bilder zum Training von KI/ML-Modellen kann eine risikoreiche Tätigkeit darstellen. Soweit nach Art. 35 DSGVO erforderlich, führen wir eine Datenschutz-Folgenabschätzung durch, bevor wir Verarbeitungsvorgänge einleiten, die voraussichtlich ein hohes Risiko für die Rechte und Freiheiten betroffener Personen mit sich bringen. Sie können zusammenfassende Informationen zu durchgeführten DSFAs unter **<me@jhubi1.com>** anfordern.

## 12. Kinder und Minderjährige

Datly ist **nicht für Kinder** unter 16 Jahren (oder dem in Ihrem Land geltenden Mindestalter für die digitale Einwilligung) bestimmt. Wenn Sie unter dem geltenden Mindestalter sind, dürfen Sie den Dienst nur mit nachweisbarer Einwilligung eines Elternteils/Erziehungsberechtigten nutzen. Soweit eine elterliche Einwilligung anwendbar ist, wird neben Ihrer eigenen eine separate elterliche Unterschrift erhoben. Laden Sie keine Bilder von Minderjährigen hoch, es sei denn, Sie haben eine rechtmäßige Erlaubnis.

## 13. Beschwerden und Aufsichtsbehörde

Wenn Sie der Ansicht sind, dass unsere Verarbeitung Ihrer personenbezogenen Daten gegen die DSGVO verstößt, haben Sie das Recht, Beschwerde bei einer Aufsichtsbehörde einzulegen (Art. 77 DSGVO), insbesondere in dem EU-Mitgliedstaat Ihres gewöhnlichen Aufenthalts, Ihres Arbeitsplatzes oder des Ortes des mutmaßlichen Verstoßes.

In Deutschland können Sie sich an die zuständige Landesdatenschutzbehörde (Landesdatenschutzbeauftragte/r) oder den Bundesbeauftragten für den Datenschutz und die Informationsfreiheit (**BfDI**) für Bundesangelegenheiten wenden. Die Einreichung einer Beschwerde ist kostenlos.

## 14. Änderungen dieser Datenschutzerklärung

Wir können diese Erklärung von Zeit zu Zeit aktualisieren. Wesentliche Änderungen werden über die App oder per E-Mail mitgeteilt. Das Wirksamkeitsdatum am Anfang dieses Dokuments spiegelt stets die aktuelle Version wider. Die fortgesetzte Nutzung des Dienstes nach Änderungen gilt als Kenntnisnahme der aktualisierten Erklärung; bei Änderungen, die eine erneute Einwilligung erfordern, werden wir diese einholen.

## 15. Kontakt

Für Fragen, Datenschutzanfragen, Betroffenenrechte oder sonstige Anliegen:

**JHubi1**
E-Mail: **<me@jhubi1.com>**

import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:retry/retry.dart';

import '../database/database.dart';
import '../server.dart';
import 'messages_all.dart';

export 'package:mailer/mailer.dart' show Message, Address, Attachment;

late final SmtpServer _emailSmtpServer;
late final String _emailFromAddress;
late final String _emailTemplateBase;
void initializeSmtpServer() {
  if (!env.isDefined("DATLY_SMTP_HOST") ||
      !env.isDefined("DATLY_SMTP_PORT") ||
      !env.isDefined("DATLY_SMTP_USERNAME") ||
      !env.isDefined("DATLY_SMTP_PASSWORD")) {
        t.fatal("SMTP server configuration is incomplete. Please set DATLY_SMTP_HOST, DATLY_SMTP_PORT, DATLY_SMTP_USERNAME, and DATLY_SMTP_PASSWORD environment variables.");
        exit(1);
      }

  _emailSmtpServer = SmtpServer(
    env["DATLY_SMTP_HOST"]!,
    port: int.parse(env["DATLY_SMTP_PORT"]!),
    ssl: bool.tryParse(env["DATLY_SMTP_SSL"] ?? "") ?? false,
    username: env["DATLY_SMTP_USERNAME"]!,
    password: env["DATLY_SMTP_PASSWORD"]!,
  );
  _emailFromAddress =
      env["DATLY_SMTP_FROM"] ??
      "Datly <${env["DATLY_SMTP_USERNAME"] ?? "noreply@localhost"}>";
  _emailTemplateBase = File("email/templates/base.html").readAsStringSync();

  initializeMessages("en");
  initializeMessages("de");
}

Message stylizedEmailMessage({
  required List<Address> recipients,
  required User user,
  List<Address>? cc,
  required String subject,
  required String summary,
  required String text,
  required List<Object> content,
  List<Attachment>? attachments,
}) => Intl.withLocale(user.locale, () {
  final payload = MessageContentPlaceholderPayload({
    "canonical": Uri.parse(env["DATLY_CANONICAL_URL"] ?? "").origin,
    "username": user.username,
    "summary": summary,
  });

  final processedText =
      "Datly (${env["DATLY_CANONICAL_URL"]})\n\n---\n\n${emailHello(user.username)}\n\n${payload.applyTo(text, null)}\n\n---\n\n${emailFooterPlain()}";
  final processedHtml = payload
      .applyTo(_emailTemplateBase)
      .replaceFirst("{%hello%}", emailHello(user.username))
      .replaceFirst("{%content%}", payload.process(content))
      .replaceFirst("{%footer%}", emailFooter());

  return Message()
    ..recipients.addAll(recipients)
    ..ccRecipients.addAll(cc ?? [])
    ..subject = subject
    ..attachments.addAll(attachments ?? [])
    ..text = processedText
    ..html = processedHtml;
});

final _emailQueue = <({Message message, int failedIterations})>[];
void queueEmail(Message message) {
  bool isLocalhost(dynamic r) =>
      r.toString().endsWith("@localhost") ||
      r.toString().endsWith("@localhost>");
  if (message.recipients.any((r) => isLocalhost(r))) {
    t.warn(
      "Tried to send email to stand in address: ${message.recipients.where((r) => isLocalhost(r)).map((r) => r.toString().replaceAll(RegExp(r"(?:^.*?<)|>$"), "")).join(", ")}; skipping",
      description:
          "Stand in email addresses are deprecated and users with them should be migrated to real email addresses as soon as possible.",
    );
    return;
  }

  _emailQueue.add((message: message, failedIterations: 0));
  _processLoop();
}

var _processLoopLock = false;
void _processLoop() async {
  if (_processLoopLock) return;
  _processLoopLock = true;

  while (true) {
    if (_emailQueue.isEmpty) {
      _processLoopLock = false;
      break;
    }

    final message = _emailQueue.removeAt(0);
    try {
      message.message.from = Address(_emailFromAddress);
      await RetryOptions(maxAttempts: 3).retry(
        () async => await send(message.message, _emailSmtpServer),
        onRetry: (e) => t.warn("Failed to send email, retrying", error: e),
      );
    } catch (e, s) {
      t.error(
        "Failed to send email after multiple attempts.",
        error: e,
        stack: s,
      );

      if (message.failedIterations < 1) {
        // add to end of the queue to try again later
        _emailQueue.add((
          message: message.message,
          failedIterations: message.failedIterations + 1,
        ));
      } else {
        // failed, [last + current = 2] * 3 attempts in total
        t.error(
          "Giving up on email after multiple failed attempts",
          description:
              "Subject: '${message.message.subject}'; recipients: '${message.message.recipients.map((r) => r.toString()).join("', '")}'",
          error: e,
          stack: s,
        );
      }
    }

    // rate limit/spam prevention: waiting a bit before sending the next email
    await Future.delayed(const Duration(seconds: 1));
  }
}

// MARK: Templating Engine

class MessageContentPlaceholderPayload {
  final Map<String, Object> placeholders;
  MessageContentPlaceholderPayload(this.placeholders);

  String applyTo(
    String input, [
    HtmlEscapeMode? mode = HtmlEscapeMode.unknown,
  ]) {
    final escape = HtmlEscape(mode ?? HtmlEscapeMode.unknown);
    return input.replaceAllMapped(RegExp(r"\{\{(\w+)\}\}"), (m) {
      final processed = placeholders[m[1]]?.toString() ?? "<unknown>";
      return mode != null ? escape.convert(processed) : processed;
    });
  }

  String process(List<Object> content) => content
      .map((c) => c is MessageContent ? c.format(this) : applyTo(c.toString()))
      .join();
}

abstract class MessageContent {
  String format(MessageContentPlaceholderPayload payload);
}

class MessageContentParagraph implements MessageContent {
  final String? _color;

  final List<Object> content;
  MessageContentParagraph(this.content) : _color = null;

  MessageContentParagraph.code(this.content) : _color = "#121212";
  MessageContentParagraph.error(this.content) : _color = "#aa0000";
  MessageContentParagraph.success(this.content) : _color = "#1b6608";
  MessageContentParagraph.warning(this.content) : _color = "#b57f05";
  MessageContentParagraph.highlight(this.content) : _color = "#1e4485";

  @override
  String format(payload) =>
      """
<tr>
  <td align="left" style="${_color != null ? "background:$_color;" : ""}font-size:0px;padding:10px 25px;word-break:break-word;">
    <div style="font-family:Helvetica, Arial, sans-serif;font-size:16px;line-height:24px;text-align:left;color:#e0e0e0;">${payload.process(content)}</div>
  </td>
</tr>
""";
}

class MessageContentLink implements MessageContent {
  final List<Object> content;
  final String href;
  MessageContentLink(this.content, {required this.href});

  @override
  String format(payload) =>
      "<a href=\"${Uri.encodeFull(payload.applyTo(href, HtmlEscapeMode.attribute))}\" style=\"color:#e0e0e0;text-decoration:underline;\" target=\"_blank\">${payload.process(content)}</a>";
}

class MessageContentButton implements MessageContent {
  final List<Object> content;
  final String href;
  MessageContentButton(this.content, {required this.href});

  @override
  String format(payload) =>
      """
<tr>
  <td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;">
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:separate;line-height:100%;">
      <tbody>
        <tr>
          <td align="center" bgcolor="#e0e0e0" role="presentation" style="border:none;border-radius:6px;cursor:auto;mso-padding-alt:10px 25px;background:#e0e0e0;" valign="middle">
            <a href="${Uri.encodeFull(payload.applyTo(href, HtmlEscapeMode.attribute))}" style="display:inline-block;background:#e0e0e0;color:#121212;font-family:Helvetica, Arial, sans-serif;font-size:16px;font-weight:bold;line-height:120%;margin:0;text-decoration:none;text-transform:none;padding:10px 25px;mso-padding-alt:0px;border-radius:6px;" target="_blank">
              ${payload.process(content)}
            </a>
          </td>
        </tr>
      </tbody>
    </table>
  </td>
</tr>
""";
}

// MARK: Localization

class EmailMessagesTemplates {
  final User user;
  final String subject;
  final String summary;
  final String text;
  final List<Object> content;

  EmailMessagesTemplates._({
    required this.user,
    required this.subject,
    required this.summary,
    required this.text,
    required this.content,
  });

  Message stylized({List<Address>? cc, List<Attachment>? attachments}) =>
      stylizedEmailMessage(
        recipients: [Address(user.email, user.username)],
        user: user,
        cc: cc,
        subject: subject,
        summary: summary,
        text: text,
        content: content,
        attachments: attachments,
      );

  // content

  factory EmailMessagesTemplates.welcome({
    required User user,
    required String newPassword,
  }) => Intl.withLocale(user.locale, () {
    String emailWelcomeSubject() =>
        Intl.message("Welcome to Datly", name: "emailWelcomeSubject");
    String emailWelcomeSummary() => Intl.message(
      "Your account has been created.",
      name: "emailWelcomeSummary",
    );

    String emailWelcomePart1() => Intl.message(
      "we're excited to have you on board! Your account has been created and is ready to go. Please use the temporary password below to log in for the first time, then change it to something of your choice.",
      name: "emailWelcomePart1",
    );
    String emailWelcomePart2() => Intl.message(
      "You can now take your first photo and start contributing to our crowdsourcing efforts. If you have any questions or need help, feel free to ",
      name: "emailWelcomePart2",
    );
    String emailWelcomePart3() => Intl.message(
      "reach out to our support team",
      name: "emailWelcomePart3",
    );
    String emailWelcomePart4() => Intl.message(
      ". We're here to help you get the most out of Datly.",
      name: "emailWelcomePart4",
    );

    String emailWelcomeContentExtra1() =>
        Intl.message("Log in now", name: "emailWelcomeContentExtra1");

    return EmailMessagesTemplates._(
      user: user,
      subject: emailWelcomeSubject(),
      summary: emailWelcomeSummary(),
      text:
          "${emailWelcomePart1()}\n\n> $newPassword\n{{canonical}}/login\n\n${emailWelcomePart2()}${emailWelcomePart3()} (support@con.bz)${emailWelcomePart4()}",
      content: [
        MessageContentParagraph([emailWelcomePart1()]),
        MessageContentParagraph.code([newPassword]),
        MessageContentButton(
          [emailWelcomeContentExtra1()],
          href: "{{canonical}}/login?email=${Uri.encodeComponent(user.email)}",
        ),
        MessageContentParagraph([
          emailWelcomePart2(),
          MessageContentLink([
            emailWelcomePart3(),
          ], href: "mailto:support@con.bz"),
          emailWelcomePart4(),
        ]),
      ],
    );
  });

  factory EmailMessagesTemplates.passwordResetWelcome({
    required User user,
    required String newPassword,
  }) => Intl.withLocale(user.locale, () {
    String emailPasswordResetWelcomeSubject() => Intl.message(
      "Welcome to Datly",
      name: "emailPasswordResetWelcomeSubject",
    );
    String emailPasswordResetWelcomeSummary() => Intl.message(
      "Please log in with the temporary password we've created for you.",
      name: "emailPasswordResetWelcomeSummary",
    );

    String emailPasswordResetWelcomePart1() => Intl.message(
      "you've been invited to join the Datly Collectors! We collect photos of trash to better classify and understand it — and we're glad to have you on board.",
      name: "emailPasswordResetWelcomePart1",
    );
    String emailPasswordResetWelcomePart2(String email) => Intl.message(
      "An account has been created for you on Datly. Please use the temporary password below along with your email address ($email) to log in, then change it to something of your choice.",
      name: "emailPasswordResetWelcomePart2",
      args: [email],
    );

    String emailPasswordResetWelcomeContentExtra1() => Intl.message(
      "Log in now",
      name: "emailPasswordResetWelcomeContentExtra1",
    );

    return EmailMessagesTemplates._(
      user: user,
      subject: emailPasswordResetWelcomeSubject(),
      summary: emailPasswordResetWelcomeSummary(),
      text:
          "${emailPasswordResetWelcomePart1()}\n\n${emailPasswordResetWelcomePart2(user.email)}\n\n> $newPassword\n{{canonical}}/login",
      content: [
        MessageContentParagraph([emailPasswordResetWelcomePart1()]),
        MessageContentParagraph([emailPasswordResetWelcomePart2(user.email)]),
        MessageContentParagraph.code([newPassword]),
        MessageContentButton(
          [emailPasswordResetWelcomeContentExtra1()],
          href: "{{canonical}}/login?email=${Uri.encodeComponent(user.email)}",
        ),
      ],
    );
  });

  factory EmailMessagesTemplates.passwordResetMigration({
    required User user,
    required String newPassword,
  }) => Intl.withLocale(user.locale, () {
    String emailPasswordResetMigrationSubject() => Intl.message(
      "Important changes to your Datly login",
      name: "emailPasswordResetMigrationSubject",
    );
    String emailPasswordResetMigrationSummary() => Intl.message(
      "You can now log in using your email address and a password.",
      name: "emailPasswordResetMigrationSummary",
    );

    String emailPasswordResetMigrationPart1(String email) => Intl.message(
      "we've recently switched to a new login system. The old login codes will no longer work. Instead, you can now log in using your email address ($email) and the temporary password below.",
      name: "emailPasswordResetMigrationPart1",
      args: [email],
    );
    String emailPasswordResetMigrationPart2() => Intl.message(
      "This change was necessary to open the platform to a wider audience, making the old invite code system no longer feasible. We apologize for any inconvenience and thank you for your understanding.",
      name: "emailPasswordResetMigrationPart2",
    );

    String emailPasswordResetMigrationContentExtra1() => Intl.message(
      "Log in now",
      name: "emailPasswordResetMigrationContentExtra1",
    );

    return EmailMessagesTemplates._(
      user: user,
      subject: emailPasswordResetMigrationSubject(),
      summary: emailPasswordResetMigrationSummary(),
      text:
          "${emailPasswordResetMigrationPart1(user.email)}\n\n> $newPassword\n{{canonical}}/login\n\n${emailPasswordResetMigrationPart2()}",
      content: [
        MessageContentParagraph([emailPasswordResetMigrationPart1(user.email)]),
        MessageContentParagraph.code([newPassword]),
        MessageContentButton(
          [emailPasswordResetMigrationContentExtra1()],
          href: "{{canonical}}/login?email=${Uri.encodeComponent(user.email)}",
        ),
        MessageContentParagraph([emailPasswordResetMigrationPart2()]),
      ],
    );
  });

  factory EmailMessagesTemplates.passwordResetTemporary({
    required User user,
    required String newPassword,
  }) => Intl.withLocale(user.locale, () {
    String emailPasswordResetTemporarySubject() => Intl.message(
      "Your Datly password has been reset",
      name: "emailPasswordResetTemporarySubject",
    );
    String emailPasswordResetTemporarySummary() => Intl.message(
      "Your Datly password has been reset.",
      name: "emailPasswordResetTemporarySummary",
    );

    String emailPasswordResetTemporaryPart1() => Intl.message(
      "your password has been reset. Please use the temporary password below to log in and then change it to something of your choice.",
      name: "emailPasswordResetTemporaryPart1",
    );

    String emailPasswordResetTemporaryContentExtra1() => Intl.message(
      "Log in now",
      name: "emailPasswordResetTemporaryContentExtra1",
    );

    return EmailMessagesTemplates._(
      user: user,
      subject: emailPasswordResetTemporarySubject(),
      summary: emailPasswordResetTemporarySummary(),
      text:
          "${emailPasswordResetTemporaryPart1()}\n\n> $newPassword\n{{canonical}}/login",
      content: [
        MessageContentParagraph([emailPasswordResetTemporaryPart1()]),
        MessageContentParagraph.code([newPassword]),
        MessageContentButton(
          [emailPasswordResetTemporaryContentExtra1()],
          href: "{{canonical}}/login?email=${Uri.encodeComponent(user.email)}",
        ),
      ],
    );
  });

  factory EmailMessagesTemplates.accountDisabled({
    required User user,
    required String reason,
  }) => Intl.withLocale(user.locale, () {
    reason = reason.trim();
    final reasonPresent = reason.isNotEmpty;

    String emailAccountDisabledSubject() => Intl.message(
      "Your Datly account has been suspended",
      name: "emailAccountDisabledSubject",
    );
    String emailAccountDisabledSummary() => Intl.message(
      "Your Datly account has been suspended.",
      name: "emailAccountDisabledSummary",
    );

    String emailAccountDisabledPart1() => Intl.message(
      "we regret to inform you that your account has been suspended due to a potential violation of our terms of service.",
      name: "emailAccountDisabledPart1",
    );
    String emailAccountDisabledPart2() => Intl.message(
      "If you believe this was a mistake, please ",
      name: "emailAccountDisabledPart2",
    );
    String emailAccountDisabledPart3() => Intl.message(
      "contact our support team",
      name: "emailAccountDisabledPart3",
    );
    String emailAccountDisabledPart4() => Intl.message(
      " to request a review.",
      name: "emailAccountDisabledPart4",
    );

    String emailAccountDisabledContentExtra1(reason) => Intl.message(
      "Reason:<br>$reason",
      name: "emailAccountDisabledContentExtra1",
      args: [reason],
    );

    return EmailMessagesTemplates._(
      user: user,
      subject: emailAccountDisabledSubject(),
      summary: emailAccountDisabledSummary(),
      text:
          "${emailAccountDisabledPart1()}${reasonPresent ? "\n\n> $reason" : ""}\n\n${emailAccountDisabledPart2()}${emailAccountDisabledPart3()} (support@con.bz)${emailAccountDisabledPart4()}",
      content: [
        MessageContentParagraph([emailAccountDisabledPart1()]),
        if (reasonPresent)
          MessageContentParagraph.warning([
            emailAccountDisabledContentExtra1(reason),
          ]),
        MessageContentParagraph([
          emailAccountDisabledPart2(),
          MessageContentLink([
            emailAccountDisabledPart3(),
          ], href: "mailto:support@con.bz"),
          emailAccountDisabledPart4(),
        ]),
      ],
    );
  });

  factory EmailMessagesTemplates.accountReenabled({
    required User user,
  }) => Intl.withLocale(user.locale, () {
    String emailAccountReenabledSubject() => Intl.message(
      "Your Datly account has been reactivated",
      name: "emailAccountReenabledSubject",
    );
    String emailAccountReenabledSummary() => Intl.message(
      "Your Datly account has been reactivated.",
      name: "emailAccountReenabledSummary",
    );

    String emailAccountReenabledPart1() => Intl.message(
      "great news — your account has been reactivated! We apologize for the inconvenience and thank you for your patience during the review process.",
      name: "emailAccountReenabledPart1",
    );
    String emailAccountReenabledPart2() => Intl.message(
      "You can now log in and continue using Datly as before. Welcome back!",
      name: "emailAccountReenabledPart2",
    );

    String emailAccountReenabledContentExtra1() =>
        Intl.message("Open Datly", name: "emailAccountReenabledContentExtra1");

    return EmailMessagesTemplates._(
      user: user,
      subject: emailAccountReenabledSubject(),
      summary: emailAccountReenabledSummary(),
      text:
          "${emailAccountReenabledPart1()}\n\n${emailAccountReenabledPart2()}",
      content: [
        MessageContentParagraph([emailAccountReenabledPart1()]),
        MessageContentParagraph([emailAccountReenabledPart2()]),
        MessageContentButton([
          emailAccountReenabledContentExtra1(),
        ], href: "{{canonical}}"),
      ],
    );
  });

  factory EmailMessagesTemplates.accountDeleted({
    required User user,
  }) => Intl.withLocale(user.locale, () {
    String emailAccountDeletedSubject() => Intl.message(
      "Your Datly account has been deleted",
      name: "emailAccountDeletedSubject",
    );
    String emailAccountDeletedSummary() => Intl.message(
      "Your Datly account has been fully deleted.",
      name: "emailAccountDeletedSummary",
    );

    String emailAccountDeletedPart1() => Intl.message(
      "your account has been permanently deleted. We're sorry to see you go, but we fully respect your decision.",
      name: "emailAccountDeletedPart1",
    );
    String emailAccountDeletedPart2() => Intl.message(
      "Please note that signatures and their metadata are retained for legal reasons. All other personal data has been permanently deleted.",
      name: "emailAccountDeletedPart2",
    );
    String emailAccountDeletedPart3() => Intl.message(
      "If you have any feedback or suggestions, please don't hesitate to ",
      name: "emailAccountDeletedPart3",
    );
    String emailAccountDeletedPart4() => Intl.message(
      "contact our support team",
      name: "emailAccountDeletedPart4",
    );
    String emailAccountDeletedPart5() => Intl.message(
      " and let us know. We wish you all the best!",
      name: "emailAccountDeletedPart5",
    );

    return EmailMessagesTemplates._(
      user: user,
      subject: emailAccountDeletedSubject(),
      summary: emailAccountDeletedSummary(),
      text:
          "${emailAccountDeletedPart1()}\n\n${emailAccountDeletedPart2()}\n\n${emailAccountDeletedPart3()}${emailAccountDeletedPart4()} (support@con.bz)${emailAccountDeletedPart5()}",
      content: [
        MessageContentParagraph([emailAccountDeletedPart1()]),
        MessageContentParagraph([emailAccountDeletedPart2()]),
        MessageContentParagraph([
          emailAccountDeletedPart3(),
          MessageContentLink([
            emailAccountDeletedPart4(),
          ], href: "mailto:support@con.bz"),
          emailAccountDeletedPart5(),
        ]),
      ],
    );
  });
}

String emailHello(String username) =>
    Intl.message("Hello $username,", name: "emailHello", args: [username]);
String emailFooter() => Intl.message(
  "You are receiving this email because you registered at our service.<br>To unsubscribe, please <a href=\"mailto:me@jhubi1.com\" style=\"color: #999999;text-decoration: underline;\">contact the admin</a> for removal from the app.<br><br>&copy; 2025–2026 JHubi1. All rights reserved.",
  name: "emailFooter",
);
String emailFooterPlain() => emailFooter()
    .replaceAll("<br>", "\n")
    .replaceAllMapped(
      RegExp(r'<a.*?href=\"(.*?)\".*?>(.*?)<\/a>'),
      (m) => "${m[2]} (${m[1]})",
    )
    .replaceAll("&copy;", "©");

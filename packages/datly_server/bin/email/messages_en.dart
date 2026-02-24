// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static m0(reason) => "Reason:<br>${reason}";

  static m1(username) => "Hello ${username},";

  static m2(email) => "we\'ve recently switched to a new login system. The old login codes will no longer work. Instead, you can now log in using your email address (${email}) and the temporary password below.";

  static m3(email) => "An account has been created for you on Datly. Please use the temporary password below along with your email address (${email}) to log in, then change it to something of your choice.";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(Object? _) => {
      'emailAccountDeletedPart1': MessageLookupByLibrary.simpleMessage('your account has been permanently deleted. We\'re sorry to see you go, but we fully respect your decision.'),
    'emailAccountDeletedPart2': MessageLookupByLibrary.simpleMessage('Please note that signatures and their metadata are retained for legal reasons. All other personal data has been permanently deleted.'),
    'emailAccountDeletedPart3': MessageLookupByLibrary.simpleMessage('If you have any feedback or suggestions, please don\'t hesitate to '),
    'emailAccountDeletedPart4': MessageLookupByLibrary.simpleMessage('contact our support team'),
    'emailAccountDeletedPart5': MessageLookupByLibrary.simpleMessage(' and let us know. We wish you all the best!'),
    'emailAccountDeletedSubject': MessageLookupByLibrary.simpleMessage('Your Datly account has been deleted'),
    'emailAccountDeletedSummary': MessageLookupByLibrary.simpleMessage('Your Datly account has been fully deleted.'),
    'emailAccountDisabledContentExtra1': m0,
    'emailAccountDisabledPart1': MessageLookupByLibrary.simpleMessage('we regret to inform you that your account has been suspended due to a potential violation of our terms of service.'),
    'emailAccountDisabledPart2': MessageLookupByLibrary.simpleMessage('If you believe this was a mistake, please '),
    'emailAccountDisabledPart3': MessageLookupByLibrary.simpleMessage('contact our support team'),
    'emailAccountDisabledPart4': MessageLookupByLibrary.simpleMessage(' to request a review.'),
    'emailAccountDisabledSubject': MessageLookupByLibrary.simpleMessage('Your Datly account has been suspended'),
    'emailAccountDisabledSummary': MessageLookupByLibrary.simpleMessage('Your Datly account has been suspended.'),
    'emailAccountReenabledContentExtra1': MessageLookupByLibrary.simpleMessage('Open Datly'),
    'emailAccountReenabledPart1': MessageLookupByLibrary.simpleMessage('great news — your account has been reactivated! We apologize for the inconvenience and thank you for your patience during the review process.'),
    'emailAccountReenabledPart2': MessageLookupByLibrary.simpleMessage('You can now log in and continue using Datly as before. Welcome back!'),
    'emailAccountReenabledSubject': MessageLookupByLibrary.simpleMessage('Your Datly account has been reactivated'),
    'emailAccountReenabledSummary': MessageLookupByLibrary.simpleMessage('Your Datly account has been reactivated.'),
    'emailFooter': MessageLookupByLibrary.simpleMessage('You are receiving this email because you registered at our service.<br>To unsubscribe, please <a href=\"mailto:me@jhubi1.com\" style=\"color: #999999;text-decoration: underline;\">contact the admin</a> for removal from the app.<br><br>&copy; 2025–2026 JHubi1. All rights reserved.'),
    'emailHello': m1,
    'emailPasswordResetMigrationContentExtra1': MessageLookupByLibrary.simpleMessage('Log in now'),
    'emailPasswordResetMigrationPart1': m2,
    'emailPasswordResetMigrationPart2': MessageLookupByLibrary.simpleMessage('This change was necessary to open the platform to a wider audience, making the old invite code system no longer feasible. We apologize for any inconvenience and thank you for your understanding.'),
    'emailPasswordResetMigrationSubject': MessageLookupByLibrary.simpleMessage('Important changes to your Datly login'),
    'emailPasswordResetMigrationSummary': MessageLookupByLibrary.simpleMessage('You can now log in using your email address and a password.'),
    'emailPasswordResetTemporaryContentExtra1': MessageLookupByLibrary.simpleMessage('Log in now'),
    'emailPasswordResetTemporaryPart1': MessageLookupByLibrary.simpleMessage('your password has been reset. Please use the temporary password below to log in and then change it to something of your choice.'),
    'emailPasswordResetTemporarySubject': MessageLookupByLibrary.simpleMessage('Your Datly password has been reset'),
    'emailPasswordResetTemporarySummary': MessageLookupByLibrary.simpleMessage('Your Datly password has been reset.'),
    'emailPasswordResetWelcomeContentExtra1': MessageLookupByLibrary.simpleMessage('Log in now'),
    'emailPasswordResetWelcomePart1': MessageLookupByLibrary.simpleMessage('you\'ve been invited to join the Datly Collectors! We collect photos of trash to better classify and understand it — and we\'re glad to have you on board.'),
    'emailPasswordResetWelcomePart2': m3,
    'emailPasswordResetWelcomeSubject': MessageLookupByLibrary.simpleMessage('Welcome to Datly'),
    'emailPasswordResetWelcomeSummary': MessageLookupByLibrary.simpleMessage('Please log in with the temporary password we\'ve created for you.'),
    'emailWelcomeContentExtra1': MessageLookupByLibrary.simpleMessage('Log in now'),
    'emailWelcomePart1': MessageLookupByLibrary.simpleMessage('we\'re excited to have you on board! Your account has been created and is ready to go. Please use the temporary password below to log in for the first time, then change it to something of your choice.'),
    'emailWelcomePart2': MessageLookupByLibrary.simpleMessage('You can now take your first photo and start contributing to our crowdsourcing efforts. If you have any questions or need help, feel free to '),
    'emailWelcomePart3': MessageLookupByLibrary.simpleMessage('reach out to our support team'),
    'emailWelcomePart4': MessageLookupByLibrary.simpleMessage('. We\'re here to help you get the most out of Datly.'),
    'emailWelcomeSubject': MessageLookupByLibrary.simpleMessage('Welcome to Datly'),
    'emailWelcomeSummary': MessageLookupByLibrary.simpleMessage('Your account has been created.')
  };
}

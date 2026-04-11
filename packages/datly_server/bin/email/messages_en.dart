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

  static m0(reason) => "${reason}";

  static m1(username) => "a submission by ${username} has been flagged for containing potentially illegal or prohibited content. The user\'s account has been suspended automatically.";

  static m2(submissionId, timestamp, categories) => "Submission ID: ${submissionId}<br>Submitted: ${timestamp}<br>Categories: ${categories}";

  static m3(username) => "[URGENT] Prohibited content detected (@${username})";

  static m4(username) => "Prohibited content has been detected in a submission by ${username}. The account has been automatically suspended. Immediate review is required.";

  static m5(username) => "Hello ${username},";

  static m6(date) => "we are writing to let you know that our Terms of Service and Privacy Policy have been updated. The changes will take effect on ${date}.";

  static m7(date) => "we are writing to let you know that our Privacy Policy has been updated. The changes will take effect on ${date}.";

  static m8(date) => "we are writing to let you know that our Terms of Service have been updated. The changes will take effect on ${date}.";

  static m9(email) => "we\'ve recently switched to a new login system. The old login codes will no longer work. Instead, you can now log in using your email address (${email}) and the temporary password below.";

  static m10(email) => "An account has been created for you on Datly. Please use the temporary password below along with your email address (${email}) to log in, then change it to something of your choice.";

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
    'emailAccountDisabledModerationAdminContentExtra1': MessageLookupByLibrary.simpleMessage('Review submission now'),
    'emailAccountDisabledModerationAdminPart1': m1,
    'emailAccountDisabledModerationAdminPart2': m2,
    'emailAccountDisabledModerationAdminPart3': MessageLookupByLibrary.simpleMessage('This requires your immediate attention. Please review the flagged content and the user\'s other submissions as soon as possible, and take the appropriate administrative action.'),
    'emailAccountDisabledModerationAdminSubject': m3,
    'emailAccountDisabledModerationAdminSummary': m4,
    'emailAccountDisabledPart1': MessageLookupByLibrary.simpleMessage('we regret to inform you that your account has been suspended due to a potential violation of our terms of service.'),
    'emailAccountDisabledPart2': MessageLookupByLibrary.simpleMessage('If you believe this was a mistake, please '),
    'emailAccountDisabledPart3': MessageLookupByLibrary.simpleMessage('contact our support team'),
    'emailAccountDisabledPart4': MessageLookupByLibrary.simpleMessage(' to request a review.'),
    'emailAccountDisabledReasonModeration': MessageLookupByLibrary.simpleMessage('Section 5 of our Terms of Service:<br>“You represent that uploaded content [...] is not illegal, and does not contain prohibited content [...]. [Such] content may result in the <b>immediate disabling or permanent deletion</b> of your account without prior notice.”'),
    'emailAccountDisabledSubject': MessageLookupByLibrary.simpleMessage('Your Datly account has been suspended'),
    'emailAccountDisabledSummary': MessageLookupByLibrary.simpleMessage('Your Datly account has been suspended.'),
    'emailAccountReenabledContentExtra1': MessageLookupByLibrary.simpleMessage('Open Datly'),
    'emailAccountReenabledPart1': MessageLookupByLibrary.simpleMessage('great news — your account has been reactivated! We apologize for the inconvenience and thank you for your patience during the review process.'),
    'emailAccountReenabledPart2': MessageLookupByLibrary.simpleMessage('You can now log in and continue using Datly as before. Welcome back!'),
    'emailAccountReenabledSubject': MessageLookupByLibrary.simpleMessage('Your Datly account has been reactivated'),
    'emailAccountReenabledSummary': MessageLookupByLibrary.simpleMessage('Your Datly account has been reactivated.'),
    'emailFooter': MessageLookupByLibrary.simpleMessage('You are receiving this email because you registered at our service.<br>To unsubscribe, please <a href=\"mailto:me@jhubi1.com\" style=\"color: #999999;text-decoration: underline;\">contact the admin</a> for removal from the app.<br><br>&copy; 2025–2026 JHubi1. All rights reserved.'),
    'emailHello': m5,
    'emailLegalChangedAllContentExtra1': MessageLookupByLibrary.simpleMessage('View Terms of Service'),
    'emailLegalChangedAllContentExtra2': MessageLookupByLibrary.simpleMessage('View Privacy Policy'),
    'emailLegalChangedAllPart1': m6,
    'emailLegalChangedAllPart2': MessageLookupByLibrary.simpleMessage('We encourage you to review the updated documents at your convenience. By continuing to use Datly after the effective date, you accept the revised terms.'),
    'emailLegalChangedAllPart3': MessageLookupByLibrary.simpleMessage('If you do not agree with the changes, you may stop using the service and request deletion of your account by contacting us.'),
    'emailLegalChangedAllPart4': MessageLookupByLibrary.simpleMessage('If you have any questions, please don\'t hesitate to '),
    'emailLegalChangedAllPart5': MessageLookupByLibrary.simpleMessage('contact our support team'),
    'emailLegalChangedAllPart6': MessageLookupByLibrary.simpleMessage('.'),
    'emailLegalChangedAllSubject': MessageLookupByLibrary.simpleMessage('Updates to the Datly Terms of Service and Privacy Policy'),
    'emailLegalChangedAllSummary': MessageLookupByLibrary.simpleMessage('Our Terms of Service and Privacy Policy have been updated.'),
    'emailLegalChangedPrivacyContentExtra1': MessageLookupByLibrary.simpleMessage('View Privacy Policy'),
    'emailLegalChangedPrivacyPart1': m7,
    'emailLegalChangedPrivacyPart2': MessageLookupByLibrary.simpleMessage('We encourage you to review the updated document at your convenience. By continuing to use Datly after the effective date, you accept the revised terms.'),
    'emailLegalChangedPrivacyPart3': MessageLookupByLibrary.simpleMessage('If you do not agree with the changes, you may stop using the service and request deletion of your account by contacting us.'),
    'emailLegalChangedPrivacyPart4': MessageLookupByLibrary.simpleMessage('If you have any questions, please don\'t hesitate to '),
    'emailLegalChangedPrivacyPart5': MessageLookupByLibrary.simpleMessage('contact our support team'),
    'emailLegalChangedPrivacyPart6': MessageLookupByLibrary.simpleMessage('.'),
    'emailLegalChangedPrivacySubject': MessageLookupByLibrary.simpleMessage('Updates to the Datly Privacy Policy'),
    'emailLegalChangedPrivacySummary': MessageLookupByLibrary.simpleMessage('Our Privacy Policy has been updated.'),
    'emailLegalChangedTermsContentExtra1': MessageLookupByLibrary.simpleMessage('View Terms of Service'),
    'emailLegalChangedTermsPart1': m8,
    'emailLegalChangedTermsPart2': MessageLookupByLibrary.simpleMessage('We encourage you to review the updated document at your convenience. By continuing to use Datly after the effective date, you accept the revised terms.'),
    'emailLegalChangedTermsPart3': MessageLookupByLibrary.simpleMessage('If you do not agree with the changes, you may stop using the service and request deletion of your account by contacting us.'),
    'emailLegalChangedTermsPart4': MessageLookupByLibrary.simpleMessage('If you have any questions, please don\'t hesitate to '),
    'emailLegalChangedTermsPart5': MessageLookupByLibrary.simpleMessage('contact our support team'),
    'emailLegalChangedTermsPart6': MessageLookupByLibrary.simpleMessage('.'),
    'emailLegalChangedTermsSubject': MessageLookupByLibrary.simpleMessage('Updates to the Datly Terms of Service'),
    'emailLegalChangedTermsSummary': MessageLookupByLibrary.simpleMessage('Our Terms of Service have been updated.'),
    'emailLoggedOutEverywhereContentExtra1': MessageLookupByLibrary.simpleMessage('Log in now'),
    'emailLoggedOutEverywherePart1': MessageLookupByLibrary.simpleMessage('for security reasons, you have been logged out of all devices. You will need to log back in to continue using Datly.'),
    'emailLoggedOutEverywherePart2': MessageLookupByLibrary.simpleMessage('We recommend changing your password if you haven\'t done so recently. This helps keep your account secure.'),
    'emailLoggedOutEverywherePart3': MessageLookupByLibrary.simpleMessage('If you did not request this action or have any concerns, please '),
    'emailLoggedOutEverywherePart4': MessageLookupByLibrary.simpleMessage('contact our support team'),
    'emailLoggedOutEverywherePart5': MessageLookupByLibrary.simpleMessage(' immediately.'),
    'emailLoggedOutEverywhereSubject': MessageLookupByLibrary.simpleMessage('You have been logged out of all devices'),
    'emailLoggedOutEverywhereSummary': MessageLookupByLibrary.simpleMessage('You have been logged out of all devices and need to log back in.'),
    'emailPasswordResetMigrationContentExtra1': MessageLookupByLibrary.simpleMessage('Log in now'),
    'emailPasswordResetMigrationPart1': m9,
    'emailPasswordResetMigrationPart2': MessageLookupByLibrary.simpleMessage('This change was necessary to open the platform to a wider audience, making the old invite code system no longer feasible. We apologize for any inconvenience and thank you for your understanding.'),
    'emailPasswordResetMigrationSubject': MessageLookupByLibrary.simpleMessage('Important changes to your Datly login'),
    'emailPasswordResetMigrationSummary': MessageLookupByLibrary.simpleMessage('You can now log in using your email address and a password.'),
    'emailPasswordResetTemporaryContentExtra1': MessageLookupByLibrary.simpleMessage('Log in now'),
    'emailPasswordResetTemporaryPart1': MessageLookupByLibrary.simpleMessage('your password has been reset. Please use the temporary password below to log in and then change it to something of your choice.'),
    'emailPasswordResetTemporarySubject': MessageLookupByLibrary.simpleMessage('Your Datly password has been reset'),
    'emailPasswordResetTemporarySummary': MessageLookupByLibrary.simpleMessage('Your Datly password has been reset.'),
    'emailPasswordResetWelcomeContentExtra1': MessageLookupByLibrary.simpleMessage('Log in now'),
    'emailPasswordResetWelcomePart1': MessageLookupByLibrary.simpleMessage('you\'ve been invited to join the Datly Collectors! We collect photos of trash to better classify and understand it — and we\'re glad to have you on board.'),
    'emailPasswordResetWelcomePart2': m10,
    'emailPasswordResetWelcomeSubject': MessageLookupByLibrary.simpleMessage('Welcome to Datly'),
    'emailPasswordResetWelcomeSummary': MessageLookupByLibrary.simpleMessage('Please log in with the temporary password we\'ve created for you.'),
    'emailValidationIntroductionContentExtra1': MessageLookupByLibrary.simpleMessage('Start Validating'),
    'emailValidationIntroductionPart1': MessageLookupByLibrary.simpleMessage('we\'re excited to introduce a new feature: image validation! You can now help improve the quality of our waste classification dataset by validating submitted photos.'),
    'emailValidationIntroductionPart2': MessageLookupByLibrary.simpleMessage('Here\'s how it works: you\'ll be shown a waste category and a 3×3 grid of images. Your task is to tap all images that match the displayed category. Each tapped image is replaced by a new one. Once no more matching images are visible, hit the submit button to finish the session.'),
    'emailValidationIntroductionPart3': MessageLookupByLibrary.simpleMessage('Every validation you submit helps ensure the accuracy of our dataset. The more accurately you validate, the more weight your future votes will carry — so precision matters!'),
    'emailValidationIntroductionPart4': MessageLookupByLibrary.simpleMessage('Give it a try and help us build a better dataset. If you have any questions, feel free to '),
    'emailValidationIntroductionPart5': MessageLookupByLibrary.simpleMessage('contact our support team'),
    'emailValidationIntroductionPart6': MessageLookupByLibrary.simpleMessage('.'),
    'emailValidationIntroductionSubject': MessageLookupByLibrary.simpleMessage('New Feature: Help validate waste images on Datly'),
    'emailValidationIntroductionSummary': MessageLookupByLibrary.simpleMessage('A new validation feature is now available on Datly.'),
    'emailWelcomeContentExtra1': MessageLookupByLibrary.simpleMessage('Log in now'),
    'emailWelcomePart1': MessageLookupByLibrary.simpleMessage('we\'re excited to have you on board! Your account has been created and is ready to go. Please use the temporary password below to log in for the first time, then change it to something of your choice.'),
    'emailWelcomePart2': MessageLookupByLibrary.simpleMessage('You can now take your first photo and start contributing to our crowdsourcing efforts. If you have any questions or need help, feel free to '),
    'emailWelcomePart3': MessageLookupByLibrary.simpleMessage('reach out to our support team'),
    'emailWelcomePart4': MessageLookupByLibrary.simpleMessage('. We\'re here to help you get the most out of Datly.'),
    'emailWelcomeSubject': MessageLookupByLibrary.simpleMessage('Welcome to Datly'),
    'emailWelcomeSummary': MessageLookupByLibrary.simpleMessage('Your account has been created.')
  };
}

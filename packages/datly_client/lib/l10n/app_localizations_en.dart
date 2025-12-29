// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get retry => 'Retry';

  @override
  String get delete => 'Delete';

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
      other: 'You\'ve been added to: $projects',
      zero: 'You\'ve not been added to any project yet',
    );
    return 'Hello $username 👋\nYou\'re invited to participate in a crowdsource! Log right in, an account has already been created for you:\n\n- $host\n- $_temp0\n- Login code: `$code` (DO NOT SHARE!)\n\nHelp us achieve our goals. See you there soon!';
  }

  @override
  String get loginUnknown => 'Unknown login code.';

  @override
  String get loginCodeLabel => 'Login code';

  @override
  String get loginNewHere => 'New here?';

  @override
  String get loginNewHereRequest => 'Request a code.';

  @override
  String get loginPrivacyPolicy => 'Privacy Policy';

  @override
  String get loginTermsOfService => 'Terms of Service';

  @override
  String get cameraNotFound => 'No camera found';

  @override
  String get cameraErrorPermission => 'Access to the camera was denied.';

  @override
  String get cameraErrorUnavailable => 'No camera available on this device.';

  @override
  String get selectCamera => 'Select camera';

  @override
  String get selectCameraDescriptionBack => 'Back Camera';

  @override
  String get selectCameraDescriptionFront => 'Front Camera';

  @override
  String get selectCameraDescriptionExternal => 'External Camera';

  @override
  String get selectProject => 'Select project';

  @override
  String get consentTitle => 'Image submission consent';

  @override
  String consentVersion(String version, String date) {
    return 'Version: $version, $date';
  }

  @override
  String get consentExplanation1 =>
      'To store, process, and eventually publish your image directly or indirectly, we need your explicit consent. Your username will be associated with the image submission and may be visible in future publications. You may withdraw your consent at any time by deleting your submission via your profile, this will only not include the image in the next data export, but already publicized images may cannot be fully deleted until the next publication. If you do not agree, please do not proceed with the submission.';

  @override
  String get consentExplanation2 =>
      'By providing your consent, you confirm that you have the necessary rights to submit this image and that it does not infringe upon the rights of any third parties. You may not submit images depicting other people, topics unrelated to the project, or content that violates legal rights in your jurisdiction or Germany. You also agree that the image may be used for research, analysis, and publication purposes related to the project you are contributing to.';

  @override
  String get consentCheckbox =>
      'I confirm that the image complies with these conditions';

  @override
  String consentPolicy(String privacyPolicy, String termsOfService) {
    return 'I have read and agree to the $privacyPolicy and $termsOfService';
  }

  @override
  String get consentSignature => 'Electronic signature';

  @override
  String get consentSignatureName => 'John Doe';

  @override
  String consentSignatureLegal(String username) {
    return 'This signature is legally binding. Entering an incorrect name makes the submission invalid and may lead to suspension of the account \'$username\'.';
  }

  @override
  String get consentAge => 'I am at least 16 years old';

  @override
  String get consentSignatureParental => 'Electronic signature of guardian';

  @override
  String get consentParental =>
      'I am the guardian of the minor, have read the above conditions and agree them';

  @override
  String get consentButton => 'Give consent and submit';

  @override
  String get noSubmissions => 'No submissions yet.';

  @override
  String get submissionStatusPending => 'Pending';

  @override
  String get submissionStatusAccepted => 'Accepted';

  @override
  String get submissionStatusRejected => 'Rejected';

  @override
  String get submissionStatusCensored => 'Censored';

  @override
  String get submissionDeleteTitle => 'Delete submission?';

  @override
  String get submissionDeleteMessage =>
      'Deleting a submission will remove the image from the next export and revoke consent. This action cannot be undone.';

  @override
  String get accountOverview => 'Account overview';

  @override
  String accountOverviewFor(String username) {
    return 'for $username';
  }

  @override
  String get aboutAppLearnMore => 'Learn more';

  @override
  String get aboutAppLogout => 'Logout';
}

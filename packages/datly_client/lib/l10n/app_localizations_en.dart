// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String quote(String content) {
    return '“$content”';
  }

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
      other: '\n- Member of: $projects',
      zero: '',
    );
    return 'Hello $username 👋\nYou\'re invited to participate in a crowdsource! Log right in, an account has already been created for you:\n\n- $host$_temp0\n- Login code: `$code` (DO NOT SHARE!)\n\nHelp us achieve our goals. See you there soon!';
  }

  @override
  String get loginInvalidEmail => 'Please enter a valid email address.';

  @override
  String get loginError =>
      'Server unreachable. Please check your internet connection.';

  @override
  String get loginAccountDisabled =>
      'Your account has been disabled. Learn about the details in the email sent to your linked email address.';

  @override
  String get loginUnknown => 'Unknown email or password.';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get loginRegister => 'Sign up';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerEmailLabel => 'Email address';

  @override
  String get registerSubmit => 'Register';

  @override
  String get registerSuccess => 'Registration successful!';

  @override
  String get registerSuccessDescription =>
      'Your account has been created successfully. Please check your email for a temporary password and further instructions to complete the registration process.';

  @override
  String get registerInvalidUsername =>
      'Usernames must be between 3 and 16 characters long and can only contain letters, numbers and underscores.';

  @override
  String get registerErrorConflictUsername =>
      'The username is already taken. Please choose a different one.';

  @override
  String get registerErrorConflictEmail =>
      'The email address is already linked to another account. Please use a different one.';

  @override
  String get registerErrorCaptcha =>
      'Captcha verification failed. Please try again.';

  @override
  String get registerLogin => 'Log in';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get navigationUpload => 'Upload';

  @override
  String get navigationValidate => 'Validate';

  @override
  String get cameraNotFound => 'No camera found';

  @override
  String get cameraErrorPermission => 'Access to the camera was denied.';

  @override
  String get cameraErrorUnavailable => 'No camera available on this device.';

  @override
  String get cameraErrorUnavailableDescription =>
      '# “No camera available on this device” Troubleshoot\n\nDatly right now is unable to access your camera. This can have a variety of causes. The most commons are listed below.\n\n- Another application is using the camera\n\n  - Please close all other applications that might be using the camera and try again.\n\n  - Sometimes other browser tabs can also block the camera, so please also try closing other tabs that might be using the camera.\n\n- Hardware issue or temporary glitch\n\n  - Please check your camera settings to ensure it is properly configured and recognized by your device.\n  - Try restarting your device, as this can often resolve temporary hardware glitches.\n  - If the problem persists, please consult your device documentation or support for further troubleshooting steps.';

  @override
  String get cameraErrorTroubleshoot => 'Troubleshoot';

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
      'To store, process, and eventually publish your image directly or indirectly, we need your explicit consent. Your username will be associated with the image submission and may be visible in future publications. You may withdraw your consent at any time by deleting your submission via your profile; this will only not include the image in the next data export, but already publicized images may cannot be fully deleted until the next publication. If you do not agree, please do not proceed with the submission.';

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
  String get passwordChangeFirstTimeLogin =>
      'Your current password is temporary and we highly recommend changing it to something only you know. Please choose a new password to secure your account.';

  @override
  String get passwordChangeTitle => 'Change password';

  @override
  String get passwordChangeCurrent => 'Current password';

  @override
  String get passwordChangeNew => 'New password';

  @override
  String get passwordChangeConfirm => 'Confirm new password';

  @override
  String get passwordChangeSubmit => 'Change password';

  @override
  String get passwordChangeErrorWrongPassword =>
      'Current password is incorrect.';

  @override
  String get passwordChangeErrorMismatch =>
      'New password and confirmation do not match.';

  @override
  String get passwordChangeErrorWeak =>
      'The password must be at least 12 characters long and include uppercase letters, lowercase letters, numbers, and special characters.';

  @override
  String passwordChangeErrorInsecure(String message) {
    return 'This password does not meet the security requirements. $message.';
  }

  @override
  String get passwordChangeErrorInsecureCodeShort =>
      'Passwords must be at least 12 characters long';

  @override
  String get passwordChangeErrorInsecureCodeLong =>
      'Passwords must be at most 128 characters long';

  @override
  String get passwordChangeErrorInsecureCodeUppercase =>
      'Passwords must contain at least one uppercase letter';

  @override
  String get passwordChangeErrorInsecureCodeLowercase =>
      'Passwords must contain at least one lowercase letter';

  @override
  String get passwordChangeErrorInsecureCodeDigit =>
      'Passwords must contain at least one digit';

  @override
  String get passwordChangeErrorInsecureCodeSpecial =>
      'Passwords must contain at least one special character';

  @override
  String get passwordChangeErrorInsecureCodeCompromised =>
      'It has appeared in a data breach is not to be considered secure';

  @override
  String get noSubmissions => 'No submissions yet.';

  @override
  String get invalidPage => 'Invalid page number.';

  @override
  String get validatePleaseSelect => 'Please select:';

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
  String get aboutAppChangePassword => 'Change password';

  @override
  String get aboutAppLogout => 'Logout';

  @override
  String get aboutAppLearnMore => 'Learn more';
}

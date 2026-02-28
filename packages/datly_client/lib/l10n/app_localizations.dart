import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
  ];

  /// A quotation format that wraps the content in quotation marks.
  ///
  /// In en, this message translates to:
  /// **'“{content}”'**
  String quote(String content);

  /// Button text to retry accessing the camera.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button text to delete an item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Invitation message sent to users to invite them to a project on Datly.
  ///
  /// In en, this message translates to:
  /// **'Hello {username} 👋\nYou\'re invited to participate in a crowdsource! Log right in, an account has already been created for you:\n\n- {host}{projectCount, plural, =0{} other{\n- Member of: {projects}}}\n- Login code: `{code}` (DO NOT SHARE!)\n\nHelp us achieve our goals. See you there soon!'**
  String invite(
    String username,
    String host,
    int projectCount,
    String projects,
    String code,
  );

  /// Error message shown when the user enters an invalid email address during login.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get loginInvalidEmail;

  /// Error message shown when the server cannot be reached during login.
  ///
  /// In en, this message translates to:
  /// **'Server unreachable. Please check your internet connection.'**
  String get loginError;

  /// Error message shown when the user's account has been disabled.
  ///
  /// In en, this message translates to:
  /// **'Your account has been disabled. Learn about the details in the email sent to your linked email address.'**
  String get loginAccountDisabled;

  /// Error message shown when the provided user data is not recognized.
  ///
  /// In en, this message translates to:
  /// **'Unknown email or password.'**
  String get loginUnknown;

  /// Label for the email address input field during login.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get loginEmailLabel;

  /// Label for the password input field during login.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Button text to submit the login form.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginSubmit;

  /// Button text to switch to the registration form.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginRegister;

  /// Label for the username input field during registration.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsernameLabel;

  /// Label for the email address input field during registration.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get registerEmailLabel;

  /// Button text to submit the registration form.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerSubmit;

  /// Message shown when the registration process is completed successfully.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registerSuccess;

  /// Additional information shown after successful registration.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully. Please check your email for a temporary password and further instructions to complete the registration process.'**
  String get registerSuccessDescription;

  /// Error message shown when the user enters an invalid username during registration.
  ///
  /// In en, this message translates to:
  /// **'Usernames must be between 3 and 16 characters long and can only contain letters, numbers and underscores.'**
  String get registerInvalidUsername;

  /// Error message shown when the chosen username is already taken during registration.
  ///
  /// In en, this message translates to:
  /// **'The username is already taken. Please choose a different one.'**
  String get registerErrorConflictUsername;

  /// Error message shown when the provided email address is already linked to another account during registration.
  ///
  /// In en, this message translates to:
  /// **'The email address is already linked to another account. Please use a different one.'**
  String get registerErrorConflictEmail;

  /// Error message shown when the captcha verification fails during registration.
  ///
  /// In en, this message translates to:
  /// **'Captcha verification failed. Please try again.'**
  String get registerErrorCaptcha;

  /// Button text to switch to the login form from the registration form.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get registerLogin;

  /// Link text for the app's privacy policy. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Link text for the app's terms of service. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Label for the upload section in the main navigation.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get navigationUpload;

  /// Label for the validate section in the main navigation.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get navigationValidate;

  /// Shown when no camera device is found on the system or the permission is denied.
  ///
  /// In en, this message translates to:
  /// **'No camera found'**
  String get cameraNotFound;

  /// Explains that access to the camera was denied by the user.
  ///
  /// In en, this message translates to:
  /// **'Access to the camera was denied.'**
  String get cameraErrorPermission;

  /// Shown when the camera is unavailable on the device, for example because it is being used by another application or there is a hardware issue.
  ///
  /// In en, this message translates to:
  /// **'No camera available on this device.'**
  String get cameraErrorUnavailable;

  /// Additional explanation for the camera unavailable error, providing possible causes and troubleshooting steps.
  ///
  /// In en, this message translates to:
  /// **'# “No camera available on this device” Troubleshoot\n\nDatly right now is unable to access your camera. This can have a variety of causes. The most commons are listed below.\n\n- Another application is using the camera\n\n  - Please close all other applications that might be using the camera and try again.\n\n  - Sometimes other browser tabs can also block the camera, so please also try closing other tabs that might be using the camera.\n\n- Hardware issue or temporary glitch\n\n  - Please check your camera settings to ensure it is properly configured and recognized by your device.\n  - Try restarting your device, as this can often resolve temporary hardware glitches.\n  - If the problem persists, please consult your device documentation or support for further troubleshooting steps.'**
  String get cameraErrorUnavailableDescription;

  /// Button text to open the troubleshooting information for camera errors.
  ///
  /// In en, this message translates to:
  /// **'Troubleshoot'**
  String get cameraErrorTroubleshoot;

  /// Title for the camera selection dialog.
  ///
  /// In en, this message translates to:
  /// **'Select camera'**
  String get selectCamera;

  /// The word 'Back' used to describe a camera facing away from the user. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Back Camera'**
  String get selectCameraDescriptionBack;

  /// The word 'Front' used to describe a camera facing towards the user. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Front Camera'**
  String get selectCameraDescriptionFront;

  /// The word 'External' used to describe an external camera. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'External Camera'**
  String get selectCameraDescriptionExternal;

  /// Title for the project selection dialog.
  ///
  /// In en, this message translates to:
  /// **'Select project'**
  String get selectProject;

  /// Title for the image submission consent dialog.
  ///
  /// In en, this message translates to:
  /// **'Image submission consent'**
  String get consentTitle;

  /// Shows the version of the consent form being presented to the user.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}, {date}'**
  String consentVersion(String version, String date);

  /// Explanation text for the image submission consent dialog.
  ///
  /// In en, this message translates to:
  /// **'To store, process, and eventually publish your image directly or indirectly, we need your explicit consent. Your username will be associated with the image submission and may be visible in future publications. You may withdraw your consent at any time by deleting your submission via your profile; this will only not include the image in the next data export, but already publicized images may cannot be fully deleted until the next publication. If you do not agree, please do not proceed with the submission.'**
  String get consentExplanation1;

  /// Additional explanation text for the image submission consent dialog.
  ///
  /// In en, this message translates to:
  /// **'By providing your consent, you confirm that you have the necessary rights to submit this image and that it does not infringe upon the rights of any third parties. You may not submit images depicting other people, topics unrelated to the project, or content that violates legal rights in your jurisdiction or Germany. You also agree that the image may be used for research, analysis, and publication purposes related to the project you are contributing to.'**
  String get consentExplanation2;

  /// Label for the consent confirmation checkbox in the consent dialog.
  ///
  /// In en, this message translates to:
  /// **'I confirm that the image complies with these conditions'**
  String get consentCheckbox;

  /// Text for the consent checkbox including links to the privacy policy and terms of service.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the {privacyPolicy} and {termsOfService}'**
  String consentPolicy(String privacyPolicy, String termsOfService);

  /// Label for the signature input field in the consent dialog.
  ///
  /// In en, this message translates to:
  /// **'Electronic signature'**
  String get consentSignature;

  /// Example name shown as placeholder in the signature input field.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get consentSignatureName;

  /// Legal disclaimer for the electronic signature input field in the consent dialog.
  ///
  /// In en, this message translates to:
  /// **'This signature is legally binding. Entering an incorrect name makes the submission invalid and may lead to suspension of the account \'{username}\'.'**
  String consentSignatureLegal(String username);

  /// Label for the age confirmation checkbox in the consent dialog.
  ///
  /// In en, this message translates to:
  /// **'I am at least 16 years old'**
  String get consentAge;

  /// Label for the signature input field for guardian in the consent dialog.
  ///
  /// In en, this message translates to:
  /// **'Electronic signature of guardian'**
  String get consentSignatureParental;

  /// Label for the guardian consent checkbox in the consent dialog.
  ///
  /// In en, this message translates to:
  /// **'I am the guardian of the minor, have read the above conditions and agree them'**
  String get consentParental;

  /// Button text to give consent and submit the image.
  ///
  /// In en, this message translates to:
  /// **'Give consent and submit'**
  String get consentButton;

  /// Message shown to users who log in for the first time with a temporary password, prompting them to change their password.
  ///
  /// In en, this message translates to:
  /// **'Your current password is temporary and we highly recommend changing it to something only you know. Please choose a new password to secure your account.'**
  String get passwordChangeFirstTimeLogin;

  /// Title for the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordChangeTitle;

  /// Label for the current password input field in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordChangeCurrent;

  /// Label for the new password input field in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordChangeNew;

  /// Label for the confirm new password input field in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get passwordChangeConfirm;

  /// Button text to submit the change password form.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordChangeSubmit;

  /// Error message shown when the user enters an incorrect current password in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get passwordChangeErrorWrongPassword;

  /// Error message shown when the new password and confirmation do not match in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation do not match.'**
  String get passwordChangeErrorMismatch;

  /// Error message shown when the new password does not meet the strength requirements in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 12 characters long and include uppercase letters, lowercase letters, numbers, and special characters.'**
  String get passwordChangeErrorWeak;

  /// Generic error message shown when the new password does not meet the security requirements in the change password dialog. The specific reason is provided in the {message} placeholder.
  ///
  /// In en, this message translates to:
  /// **'This password does not meet the security requirements. {message}.'**
  String passwordChangeErrorInsecure(String message);

  /// Error message shown when the new password is too short in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Passwords must be at least 12 characters long'**
  String get passwordChangeErrorInsecureCodeShort;

  /// Error message shown when the new password is too long in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Passwords must be at most 128 characters long'**
  String get passwordChangeErrorInsecureCodeLong;

  /// Error message shown when the new password does not contain an uppercase letter in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Passwords must contain at least one uppercase letter'**
  String get passwordChangeErrorInsecureCodeUppercase;

  /// Error message shown when the new password does not contain a lowercase letter in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Passwords must contain at least one lowercase letter'**
  String get passwordChangeErrorInsecureCodeLowercase;

  /// Error message shown when the new password does not contain a digit in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Passwords must contain at least one digit'**
  String get passwordChangeErrorInsecureCodeDigit;

  /// Error message shown when the new password does not contain a special character in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'Passwords must contain at least one special character'**
  String get passwordChangeErrorInsecureCodeSpecial;

  /// Error message shown when the new password has appeared in a data breach in the change password dialog.
  ///
  /// In en, this message translates to:
  /// **'It has appeared in a data breach is not to be considered secure'**
  String get passwordChangeErrorInsecureCodeCompromised;

  /// Shown when there are no submissions available for the selected project.
  ///
  /// In en, this message translates to:
  /// **'No submissions yet.'**
  String get noSubmissions;

  /// Shown when the user tries to access a page number that is out of range.
  ///
  /// In en, this message translates to:
  /// **'Invalid page number.'**
  String get invalidPage;

  /// Text shown above the target title. To be read as 'Please select [something]'.
  ///
  /// In en, this message translates to:
  /// **'Please select:'**
  String get validatePleaseSelect;

  /// The status 'Pending' for a submission. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get submissionStatusPending;

  /// The status 'Accepted' for a submission. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get submissionStatusAccepted;

  /// The status 'Rejected' for a submission. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get submissionStatusRejected;

  /// The status 'Censored' for a submission. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Censored'**
  String get submissionStatusCensored;

  /// Title for the dialog to confirm deletion of a submission.
  ///
  /// In en, this message translates to:
  /// **'Delete submission?'**
  String get submissionDeleteTitle;

  /// Message asking the user to confirm deletion of a submission.
  ///
  /// In en, this message translates to:
  /// **'Deleting a submission will remove the image from the next export and revoke consent. This action cannot be undone.'**
  String get submissionDeleteMessage;

  /// Accessibility label for the account overview section.
  ///
  /// In en, this message translates to:
  /// **'Account overview'**
  String get accountOverview;

  /// Accessibility label for the account overview section including the username. This must match the `accountOverview` string.
  ///
  /// In en, this message translates to:
  /// **'for {username}'**
  String accountOverviewFor(String username);

  /// Label for a button that allows the user to change their password.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get aboutAppChangePassword;

  /// Label for a button that logs the user out of the app.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get aboutAppLogout;

  /// Label for a button that leads to more information about the app.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get aboutAppLearnMore;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

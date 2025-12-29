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
  /// **'Hello {username} 👋\nYou\'re invited to participate in a crowdsource! Log right in, an account has already been created for you:\n\n- {host}\n- {projectCount, plural, =0{You\'ve not been added to any project yet} other{You\'ve been added to: {projects}}}\n- Login code: `{code}` (DO NOT SHARE!)\n\nHelp us achieve our goals. See you there soon!'**
  String invite(
    String username,
    String host,
    int projectCount,
    String projects,
    String code,
  );

  /// Error message shown when the provided login code is not recognized.
  ///
  /// In en, this message translates to:
  /// **'Unknown login code.'**
  String get loginUnknown;

  /// Label for the login code input field.
  ///
  /// In en, this message translates to:
  /// **'Login code'**
  String get loginCodeLabel;

  /// Text prompting new users to request a login code.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get loginNewHere;

  /// Link text for new users to request a login code.
  ///
  /// In en, this message translates to:
  /// **'Request a code.'**
  String get loginNewHereRequest;

  /// Link text for the app's privacy policy. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get loginPrivacyPolicy;

  /// Link text for the app's terms of service. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get loginTermsOfService;

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

  /// Explains that no camera is available on the device.
  ///
  /// In en, this message translates to:
  /// **'No camera available on this device.'**
  String get cameraErrorUnavailable;

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
  /// **'To store, process, and eventually publish your image directly or indirectly, we need your explicit consent. Your username will be associated with the image submission and may be visible in future publications. You may withdraw your consent at any time by deleting your submission via your profile, this will only not include the image in the next data export, but already publicized images may cannot be fully deleted until the next publication. If you do not agree, please do not proceed with the submission.'**
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

  /// Shown when there are no submissions available for the selected project.
  ///
  /// In en, this message translates to:
  /// **'No submissions yet.'**
  String get noSubmissions;

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

  /// Label for a button that leads to more information about the app.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get aboutAppLearnMore;

  /// Label for a button that logs the user out of the app.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get aboutAppLogout;
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

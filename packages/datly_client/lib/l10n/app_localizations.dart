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

  /// Button text to retry accessing the camera. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Button text to delete an item. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Shown when no camera device is found on the system or the permission is denied. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'No Camera Found'**
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

  /// Title for the camera selection dialog. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Select Camera'**
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
  /// **'Select Project'**
  String get selectProject;

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

  /// Title for the dialog to confirm deletion of a submission. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Delete Submission'**
  String get submissionDeleteTitle;

  /// Message asking the user to confirm deletion of a submission.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this submission? This action cannot be undone.'**
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

  /// Label for a button that leads to more information about the app. This string is formatted in MLA title case.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get aboutAppLearnMore;

  /// Label for a button that logs the user out of the app. This string is formatted in MLA title case.
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

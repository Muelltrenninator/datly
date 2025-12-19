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
  String get cameraNotFound => 'No Camera Found';

  @override
  String get cameraErrorPermission => 'Access to the camera was denied.';

  @override
  String get cameraErrorUnavailable => 'No camera available on this device.';

  @override
  String get selectCamera => 'Select Camera';

  @override
  String get selectCameraDescriptionBack => 'Back Camera';

  @override
  String get selectCameraDescriptionFront => 'Front Camera';

  @override
  String get selectCameraDescriptionExternal => 'External Camera';

  @override
  String get selectProject => 'Select Project';

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
  String get submissionDeleteTitle => 'Delete Submission';

  @override
  String get submissionDeleteMessage =>
      'Are you sure you want to delete this submission? This action cannot be undone.';

  @override
  String get accountOverview => 'Account overview';

  @override
  String accountOverviewFor(String username) {
    return 'for $username';
  }

  @override
  String get aboutAppLearnMore => 'Learn More';

  @override
  String get aboutAppLogout => 'Logout';
}

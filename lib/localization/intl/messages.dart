import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'messages_de.dart';
import 'messages_en.dart';
import 'messages_es.dart';
import 'messages_fr.dart';
import 'messages_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SupabaseAuthUILocalizations
/// returned by `SupabaseAuthUILocalizations.of(context)`.
///
/// Applications need to include `SupabaseAuthUILocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'intl/messages.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SupabaseAuthUILocalizations.localizationsDelegates,
///   supportedLocales: SupabaseAuthUILocalizations.supportedLocales,
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
/// be consistent with the languages listed in the SupabaseAuthUILocalizations.supportedLocales
/// property.
abstract class SupabaseAuthUILocalizations {
  SupabaseAuthUILocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SupabaseAuthUILocalizations of(BuildContext context) {
    return Localizations.of<SupabaseAuthUILocalizations>(
        context, SupabaseAuthUILocalizations)!;
  }

  static const LocalizationsDelegate<SupabaseAuthUILocalizations> delegate =
      _SupabaseAuthUILocalizationsDelegate();

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email inbox!'**
  String get checkYourEmail;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get confirmPasswordError;

  /// No description provided for @continueWithMagicLink.
  ///
  /// In en, this message translates to:
  /// **'Continue with magic Link'**
  String get continueWithMagicLink;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent'**
  String get enterCodeSent;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @enterOneTimeCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the one time code sent'**
  String get enterOneTimeCode;

  /// No description provided for @enterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP code'**
  String get enterOtpCode;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @otpCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get otpCodeError;

  /// No description provided for @otpDisabledError.
  ///
  /// In en, this message translates to:
  /// **'OTP disabled'**
  String get otpDisabledError;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password successfully updated'**
  String get passwordChangedSuccess;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password that is at least 6 characters long'**
  String get passwordLengthError;

  /// No description provided for @passwordResetSentEmail.
  ///
  /// In en, this message translates to:
  /// **'Password reset email has been sent'**
  String get passwordResetSentEmail;

  /// No description provided for @passwordResetSentPhone.
  ///
  /// In en, this message translates to:
  /// **'Password reset code has been sent'**
  String get passwordResetSentPhone;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @requiredFieldError.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredFieldError;

  /// No description provided for @sendPasswordResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send password reset email'**
  String get sendPasswordResetEmail;

  /// No description provided for @sendPasswordResetPhone.
  ///
  /// In en, this message translates to:
  /// **'Send password reset code'**
  String get sendPasswordResetPhone;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @successSignInMessage.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed in!'**
  String get successSignInMessage;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @unexpectedErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error has occurred'**
  String get unexpectedErrorOccurred;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @validEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validEmailError;

  /// No description provided for @validPhoneNumberError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validPhoneNumberError;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify phone'**
  String get verifyPhone;
}

class _SupabaseAuthUILocalizationsDelegate
    extends LocalizationsDelegate<SupabaseAuthUILocalizations> {
  const _SupabaseAuthUILocalizationsDelegate();

  @override
  Future<SupabaseAuthUILocalizations> load(Locale locale) {
    return SynchronousFuture<SupabaseAuthUILocalizations>(
        lookupSupabaseAuthUILocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_SupabaseAuthUILocalizationsDelegate old) => false;
}

SupabaseAuthUILocalizations lookupSupabaseAuthUILocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return SupabaseAuthUILocalizationsDe();
    case 'en':
      return SupabaseAuthUILocalizationsEn();
    case 'es':
      return SupabaseAuthUILocalizationsEs();
    case 'fr':
      return SupabaseAuthUILocalizationsFr();
    case 'it':
      return SupabaseAuthUILocalizationsIt();
  }

  throw FlutterError(
      'SupabaseAuthUILocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

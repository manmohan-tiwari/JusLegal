import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'JusLegal'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myCases.
  ///
  /// In en, this message translates to:
  /// **'My Cases'**
  String get myCases;

  /// No description provided for @authorities.
  ///
  /// In en, this message translates to:
  /// **'Authorities'**
  String get authorities;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @appNameLabel.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get appNameLabel;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account, all saved cases, and your Firebase authentication record. This action CANNOT be undone.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'To confirm, type DELETE in the field below. You may also be asked to re-authenticate for security.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @typeDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get typeDeleteHint;

  /// No description provided for @deleteButtonDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE exactly to enable'**
  String get deleteButtonDisabledHint;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account...'**
  String get deletingAccount;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account and all data have been permanently deleted.'**
  String get accountDeletedSuccess;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @unableToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete account. Please try again.'**
  String get unableToDeleteAccount;

  /// No description provided for @reauthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication failed. Please try again.'**
  String get reauthenticationFailed;

  /// No description provided for @reauthenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'For security, please sign in again before deleting your account.'**
  String get reauthenticationRequired;

  /// No description provided for @requiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Your session is too old. Please sign in again to delete your account.'**
  String get requiresRecentLogin;

  /// No description provided for @accountDataDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account & Data Deletion'**
  String get accountDataDeletionTitle;

  /// No description provided for @accountDataDeletionDesc.
  ///
  /// In en, this message translates to:
  /// **'You can permanently delete your account and all associated data at any time.'**
  String get accountDataDeletionDesc;

  /// No description provided for @accountDataDeletionInApp.
  ///
  /// In en, this message translates to:
  /// **'In the app: go to Settings > Account > Delete Account. Follow the confirmation steps to remove your account, saved cases, and authentication record.'**
  String get accountDataDeletionInApp;

  /// No description provided for @accountDataDeletionEmail.
  ///
  /// In en, this message translates to:
  /// **'By email: send a deletion request to support@juslegal.app from your registered email address. We will process your request within a reasonable timeframe.'**
  String get accountDataDeletionEmail;

  /// No description provided for @legalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Legal Disclaimer'**
  String get legalDisclaimer;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @languageSubtitleEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageSubtitleEnglish;

  /// No description provided for @languageSubtitleHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageSubtitleHindi;

  /// No description provided for @languageTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between English and Hindi'**
  String get languageTileSubtitle;

  /// No description provided for @homeHeroHeadline1.
  ///
  /// In en, this message translates to:
  /// **'Know Your Rights.'**
  String get homeHeroHeadline1;

  /// No description provided for @homeHeroHeadline2.
  ///
  /// In en, this message translates to:
  /// **'Take Action.'**
  String get homeHeroHeadline2;

  /// No description provided for @homeHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Get instant AI-powered legal guidance for your consumer issues.'**
  String get homeHeroBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @exploreLegalCategories.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE LEGAL CATEGORIES'**
  String get exploreLegalCategories;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @pleaseCheckBackLaterForLegalTopics.
  ///
  /// In en, this message translates to:
  /// **'Please check back later for legal topics.'**
  String get pleaseCheckBackLaterForLegalTopics;

  /// No description provided for @showAllCategories.
  ///
  /// In en, this message translates to:
  /// **'Show All Categories'**
  String get showAllCategories;

  /// No description provided for @aiChatLegalQueriesAndAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI CHAT, LEGAL QUERIES AND ANALYSIS'**
  String get aiChatLegalQueriesAndAnalysis;

  /// No description provided for @instantAIPoweredLegalGuidanceAtYourFingertips.
  ///
  /// In en, this message translates to:
  /// **'Instant AI-powered legal guidance at your fingertips'**
  String get instantAIPoweredLegalGuidanceAtYourFingertips;

  /// No description provided for @documentsAndContracts.
  ///
  /// In en, this message translates to:
  /// **'DOCUMENTS AND CONTRACTS'**
  String get documentsAndContracts;

  /// No description provided for @generateReviewAndNegotiateLegalDocumentsWithAI.
  ///
  /// In en, this message translates to:
  /// **'Generate, review and negotiate legal documents with AI'**
  String get generateReviewAndNegotiateLegalDocumentsWithAI;

  /// No description provided for @whyChooseJuslegal.
  ///
  /// In en, this message translates to:
  /// **'WHY CHOOSE JUSLEGAL'**
  String get whyChooseJuslegal;

  /// No description provided for @aiPoweredAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Analysis'**
  String get aiPoweredAnalysis;

  /// No description provided for @aiPoweredAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Get instant legal analysis based on your situation'**
  String get aiPoweredAnalysisDesc;

  /// No description provided for @legalCategoriesCount.
  ///
  /// In en, this message translates to:
  /// **'10+ Legal Categories'**
  String get legalCategoriesCount;

  /// No description provided for @legalCategoriesCountDesc.
  ///
  /// In en, this message translates to:
  /// **'Covers all major consumer issues'**
  String get legalCategoriesCountDesc;

  /// No description provided for @expertAuthorities.
  ///
  /// In en, this message translates to:
  /// **'Expert Authorities'**
  String get expertAuthorities;

  /// No description provided for @expertAuthoritiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Direct access to official regulatory bodies'**
  String get expertAuthoritiesDesc;

  /// No description provided for @documentGeneration.
  ///
  /// In en, this message translates to:
  /// **'Document Generation'**
  String get documentGeneration;

  /// No description provided for @documentGenerationDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional complaint letters and notices'**
  String get documentGenerationDesc;

  /// No description provided for @aiGuidanceOnlyNotLegalAdvice.
  ///
  /// In en, this message translates to:
  /// **'AI-generated guidance only. Not legal advice. '**
  String get aiGuidanceOnlyNotLegalAdvice;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @there.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get there;

  /// No description provided for @toolAiLawyerChatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Lawyer Chat'**
  String get toolAiLawyerChatTitle;

  /// No description provided for @toolAiLawyerChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask legal questions in natural conversation'**
  String get toolAiLawyerChatDesc;

  /// No description provided for @toolLegalAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Advice Q&A'**
  String get toolLegalAdviceTitle;

  /// No description provided for @toolLegalAdviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Pre-built questions with AI-generated answers'**
  String get toolLegalAdviceDesc;

  /// No description provided for @toolCaseAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Case Analysis'**
  String get toolCaseAnalysisTitle;

  /// No description provided for @toolCaseAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Strengths, weaknesses & next steps for your case'**
  String get toolCaseAnalysisDesc;

  /// No description provided for @toolLegalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Terms'**
  String get toolLegalTermsTitle;

  /// No description provided for @toolLegalTermsDesc.
  ///
  /// In en, this message translates to:
  /// **'Plain-language dictionary of legal terminology'**
  String get toolLegalTermsDesc;

  /// No description provided for @toolLegalWritingTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Writing'**
  String get toolLegalWritingTitle;

  /// No description provided for @toolLegalWritingDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate complaint letters, notices & agreements'**
  String get toolLegalWritingDesc;

  /// No description provided for @toolDocumentCreationTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Creation'**
  String get toolDocumentCreationTitle;

  /// No description provided for @toolDocumentCreationDesc.
  ///
  /// In en, this message translates to:
  /// **'Fill AI-assisted templates as PDF or text'**
  String get toolDocumentCreationDesc;

  /// No description provided for @toolDocumentReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Review'**
  String get toolDocumentReviewTitle;

  /// No description provided for @toolDocumentReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload a doc - AI finds red flags & key clauses'**
  String get toolDocumentReviewDesc;

  /// No description provided for @toolContractNegotiationTitle.
  ///
  /// In en, this message translates to:
  /// **'Contract Negotiation'**
  String get toolContractNegotiationTitle;

  /// No description provided for @toolContractNegotiationDesc.
  ///
  /// In en, this message translates to:
  /// **'AI flags unfair clauses & suggests amendments'**
  String get toolContractNegotiationDesc;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @yourLegalRightsProtected.
  ///
  /// In en, this message translates to:
  /// **'Your legal rights, protected'**
  String get yourLegalRightsProtected;

  /// No description provided for @secureAccessPortal.
  ///
  /// In en, this message translates to:
  /// **'Secure Access Portal'**
  String get secureAccessPortal;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with'**
  String get continueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @signInInstantlyWithPhoneOtp.
  ///
  /// In en, this message translates to:
  /// **'Sign in instantly with Phone (OTP)'**
  String get signInInstantlyWithPhoneOtp;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get continueWithEmail;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @byContinuingYouAgreeToOur.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our '**
  String get byContinuingYouAgreeToOur;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @authenticating.
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get authenticating;

  /// No description provided for @validPhoneNumberError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit phone number'**
  String get validPhoneNumberError;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSentSuccessfully;

  /// No description provided for @phoneNumberVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified successfully'**
  String get phoneNumberVerifiedSuccessfully;

  /// No description provided for @appleSignInSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in will be available soon.'**
  String get appleSignInSoon;

  /// No description provided for @reachUsAt.
  ///
  /// In en, this message translates to:
  /// **'Reach us at {email}'**
  String reachUsAt(String email);

  /// No description provided for @verifyYourNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyYourNumber;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to +91 {phoneNumber}'**
  String otpSentTo(String phoneNumber);

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @didntReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive OTP? '**
  String get didntReceiveOtp;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String resendIn(String time);

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @verifyingOtp.
  ///
  /// In en, this message translates to:
  /// **'Verifying OTP...'**
  String get verifyingOtp;

  /// No description provided for @enterOtpDigits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 6 digits of the OTP'**
  String get enterOtpDigits;

  /// No description provided for @otpResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get otpResentSuccessfully;

  /// No description provided for @verifyYourNumberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your phone.'**
  String get verifyYourNumberSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @backToLoginOptions.
  ///
  /// In en, this message translates to:
  /// **'Back to Login Options'**
  String get backToLoginOptions;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @pleaseConfirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccessfully;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}'**
  String passwordResetEmailSent(String email);

  /// No description provided for @yourLegalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Your Legal Analysis'**
  String get yourLegalAnalysis;

  /// No description provided for @noAnalysisAvailable.
  ///
  /// In en, this message translates to:
  /// **'No analysis available'**
  String get noAnalysisAvailable;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @analysisIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis incomplete'**
  String get analysisIncomplete;

  /// No description provided for @updatingAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Updating analysis...'**
  String get updatingAnalysis;

  /// No description provided for @confidenceScore.
  ///
  /// In en, this message translates to:
  /// **'Confidence Score'**
  String get confidenceScore;

  /// No description provided for @strongCase.
  ///
  /// In en, this message translates to:
  /// **'Strong case'**
  String get strongCase;

  /// No description provided for @moderateCase.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderateCase;

  /// No description provided for @weakCase.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weakCase;

  /// No description provided for @yourRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get yourRights;

  /// No description provided for @recommendedSteps.
  ///
  /// In en, this message translates to:
  /// **'Recommended Steps'**
  String get recommendedSteps;

  /// No description provided for @relevantLaws.
  ///
  /// In en, this message translates to:
  /// **'Relevant Laws'**
  String get relevantLaws;

  /// No description provided for @authoritiesToContact.
  ///
  /// In en, this message translates to:
  /// **'Authorities to Contact'**
  String get authoritiesToContact;

  /// No description provided for @generateComplaint.
  ///
  /// In en, this message translates to:
  /// **'Generate Complaint'**
  String get generateComplaint;

  /// No description provided for @saveCase.
  ///
  /// In en, this message translates to:
  /// **'Save Case'**
  String get saveCase;

  /// No description provided for @caseSavedToMyCases.
  ///
  /// In en, this message translates to:
  /// **'Case saved to My Cases'**
  String get caseSavedToMyCases;

  /// No description provided for @unableToSaveCase.
  ///
  /// In en, this message translates to:
  /// **'Unable to save case. Please try again.'**
  String get unableToSaveCase;

  /// No description provided for @noAuthoritiesListedForThisCase.
  ///
  /// In en, this message translates to:
  /// **'No authorities listed for this case.'**
  String get noAuthoritiesListedForThisCase;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visitWebsite;

  /// No description provided for @learnMoreAction.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMoreAction;

  /// No description provided for @updatingAnalysisStatus.
  ///
  /// In en, this message translates to:
  /// **'Updating analysis...'**
  String get updatingAnalysisStatus;

  /// No description provided for @complaintLetter.
  ///
  /// In en, this message translates to:
  /// **'Complaint Letter'**
  String get complaintLetter;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @selectTone.
  ///
  /// In en, this message translates to:
  /// **'Select Tone'**
  String get selectTone;

  /// No description provided for @letterPreview.
  ///
  /// In en, this message translates to:
  /// **'Letter Preview'**
  String get letterPreview;

  /// No description provided for @lockLetter.
  ///
  /// In en, this message translates to:
  /// **'Lock Letter'**
  String get lockLetter;

  /// No description provided for @editLetter.
  ///
  /// In en, this message translates to:
  /// **'Edit Letter'**
  String get editLetter;

  /// No description provided for @notSatisfied.
  ///
  /// In en, this message translates to:
  /// **'Not satisfied?'**
  String get notSatisfied;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get copyText;

  /// No description provided for @downloadPrintPdf.
  ///
  /// In en, this message translates to:
  /// **'Download / Print PDF'**
  String get downloadPrintPdf;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @pdfDownloadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PDF Downloaded successfully'**
  String get pdfDownloadedSuccessfully;

  /// No description provided for @failedToDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to download PDF: {error}'**
  String failedToDownloadPdf(String error);

  /// No description provided for @pleaseAnalyzeYourProblemFirst.
  ///
  /// In en, this message translates to:
  /// **'Please analyze your problem first.'**
  String get pleaseAnalyzeYourProblemFirst;

  /// No description provided for @concernedAuthority.
  ///
  /// In en, this message translates to:
  /// **'Concerned Authority'**
  String get concernedAuthority;

  /// No description provided for @formal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get formal;

  /// No description provided for @assertive.
  ///
  /// In en, this message translates to:
  /// **'Assertive'**
  String get assertive;

  /// No description provided for @concise.
  ///
  /// In en, this message translates to:
  /// **'Concise'**
  String get concise;

  /// No description provided for @documentCreation.
  ///
  /// In en, this message translates to:
  /// **'Document Creation'**
  String get documentCreation;

  /// No description provided for @availableForms.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE FORMS'**
  String get availableForms;

  /// No description provided for @browseAndSelectFrom10OfficialIndianLegalForms.
  ///
  /// In en, this message translates to:
  /// **'Browse and select from 10 official Indian legal forms'**
  String get browseAndSelectFrom10OfficialIndianLegalForms;

  /// No description provided for @aiEnhancement.
  ///
  /// In en, this message translates to:
  /// **'AI Enhancement'**
  String get aiEnhancement;

  /// No description provided for @letAiImproveLanguageAndFormatting.
  ///
  /// In en, this message translates to:
  /// **'Let AI improve language and formatting'**
  String get letAiImproveLanguageAndFormatting;

  /// No description provided for @fillDetails.
  ///
  /// In en, this message translates to:
  /// **'FILL DETAILS'**
  String get fillDetails;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @generateForm.
  ///
  /// In en, this message translates to:
  /// **'Generate Form'**
  String get generateForm;

  /// No description provided for @generationFailed.
  ///
  /// In en, this message translates to:
  /// **'Generation failed'**
  String get generationFailed;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseTryAgain;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @generatingYourForm.
  ///
  /// In en, this message translates to:
  /// **'Generating your {formTitle}...'**
  String generatingYourForm(String formTitle);

  /// No description provided for @legalNotice.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get legalNotice;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @informationWeCollect.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get informationWeCollect;

  /// No description provided for @howWeUseData.
  ///
  /// In en, this message translates to:
  /// **'How We Use Data'**
  String get howWeUseData;

  /// No description provided for @thirdPartyServices.
  ///
  /// In en, this message translates to:
  /// **'Third Party Services'**
  String get thirdPartyServices;

  /// No description provided for @aiProcessingNotice.
  ///
  /// In en, this message translates to:
  /// **'AI Processing Notice'**
  String get aiProcessingNotice;

  /// No description provided for @userRightsPolicy.
  ///
  /// In en, this message translates to:
  /// **'User Rights'**
  String get userRightsPolicy;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: 2 June 2026'**
  String get lastUpdated;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable'**
  String get serviceUnavailable;

  /// No description provided for @signInFeaturesTemporarilyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in features are temporarily unavailable. Please try again later.'**
  String get signInFeaturesTemporarilyUnavailable;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'This page explains how JusLegal handles your information when you use the app for legal guidance.'**
  String get privacyPolicyBody;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

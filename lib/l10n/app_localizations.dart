import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('bn'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('ta'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('zh', 'CN'),
    Locale('zh')
  ];

  /// No description provided for @tdRender.
  ///
  /// In en, this message translates to:
  /// **'3D Render'**
  String get tdRender;

  /// No description provided for @aiImageGenerator.
  ///
  /// In en, this message translates to:
  /// **'AI Image Generator'**
  String get aiImageGenerator;

  /// No description provided for @aboard.
  ///
  /// In en, this message translates to:
  /// **'Aboard'**
  String get aboard;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutLine2.
  ///
  /// In en, this message translates to:
  /// **'If you liked my work\nshow some ♥ and ⭐ the repo'**
  String get aboutLine2;

  /// No description provided for @accent.
  ///
  /// In en, this message translates to:
  /// **'Accent Color & Hue'**
  String get accent;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @addedTo.
  ///
  /// In en, this message translates to:
  /// **'Added to'**
  String get addedTo;

  /// No description provided for @addedToFav.
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get addedToFav;

  /// No description provided for @alvazovskyPainter.
  ///
  /// In en, this message translates to:
  /// **'Alvazovsky Painter'**
  String get alvazovskyPainter;

  /// No description provided for @anime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get anime;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Imagen'**
  String get appTitle;

  /// No description provided for @appFont.
  ///
  /// In en, this message translates to:
  /// **'App Font'**
  String get appFont;

  /// No description provided for @autoBack.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBack;

  /// No description provided for @autoBackLocation.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup Location'**
  String get autoBackLocation;

  /// No description provided for @autoBackSub.
  ///
  /// In en, this message translates to:
  /// **'Automatically backup data'**
  String get autoBackSub;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backNRest.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backNRest;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup Successful'**
  String get backupSuccess;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @canvasColor.
  ///
  /// In en, this message translates to:
  /// **'Canvas Color'**
  String get canvasColor;

  /// No description provided for @cardColor.
  ///
  /// In en, this message translates to:
  /// **'Card Color'**
  String get cardColor;

  /// No description provided for @cartoon.
  ///
  /// In en, this message translates to:
  /// **'Cartoon'**
  String get cartoon;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @checkingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Checking for Updates…'**
  String get checkingUpdate;

  /// No description provided for @checkUpdate.
  ///
  /// In en, this message translates to:
  /// **'Auto check for Updates'**
  String get checkUpdate;

  /// No description provided for @christmasStyle.
  ///
  /// In en, this message translates to:
  /// **'Christmas Style'**
  String get christmasStyle;

  /// No description provided for @classicism.
  ///
  /// In en, this message translates to:
  /// **'Classicism'**
  String get classicism;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @completeDetails.
  ///
  /// In en, this message translates to:
  /// **'Complete your details'**
  String get completeDetails;

  /// No description provided for @confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sign out ?'**
  String get confirmSignOut;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @continuationAgreement.
  ///
  /// In en, this message translates to:
  /// **'By continuing your confirm that you agree \nwith our Terms and Conditions'**
  String get continuationAgreement;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'continue with:'**
  String get continueWithSocialMedia;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to Clipboard!'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @couldNotLaunchBinance.
  ///
  /// In en, this message translates to:
  /// **'Could not launch Binance Pay order'**
  String get couldNotLaunchBinance;

  /// No description provided for @creatingBinanceOrder.
  ///
  /// In en, this message translates to:
  /// **'Creating Binance Pay order...'**
  String get creatingBinanceOrder;

  /// No description provided for @creatingNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating new account'**
  String get creatingNewAccount;

  /// No description provided for @creatingProcess.
  ///
  /// In en, this message translates to:
  /// **'Creating Process'**
  String get creatingProcess;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createBack.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBack;

  /// No description provided for @createBackSub.
  ///
  /// In en, this message translates to:
  /// **'Create backup of your data'**
  String get createBackSub;

  /// No description provided for @customizeTheme.
  ///
  /// In en, this message translates to:
  /// **'Customize themes'**
  String get customizeTheme;

  /// No description provided for @currentTheme.
  ///
  /// In en, this message translates to:
  /// **'Current Theme'**
  String get currentTheme;

  /// No description provided for @cyberPunk.
  ///
  /// In en, this message translates to:
  /// **'Cyber Punk'**
  String get cyberPunk;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @deleteTheme.
  ///
  /// In en, this message translates to:
  /// **'Delete Theme'**
  String get deleteTheme;

  /// No description provided for @deleteThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get deleteThemeSubtitle;

  /// No description provided for @digitalPainting.
  ///
  /// In en, this message translates to:
  /// **'Digital Painting'**
  String get digitalPainting;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer :'**
  String get disclaimer;

  /// No description provided for @downQualitySub.
  ///
  /// In en, this message translates to:
  /// **'Higher quality uses more disk space'**
  String get downQualitySub;

  /// No description provided for @downed.
  ///
  /// In en, this message translates to:
  /// **'has been downloaded'**
  String get downed;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @enterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter prompt:'**
  String get enterPrompt;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get error;

  /// No description provided for @errorCreatingBinanceOrder.
  ///
  /// In en, this message translates to:
  /// **'Error creating Binance Pay order'**
  String get errorCreatingBinanceOrder;

  /// No description provided for @enterPromptExample.
  ///
  /// In en, this message translates to:
  /// **'Enter prompt, e.g: cyberpunk anatomical heart model'**
  String get enterPromptExample;

  /// No description provided for @enterText.
  ///
  /// In en, this message translates to:
  /// **'Enter Text'**
  String get enterText;

  /// No description provided for @enterThemeName.
  ///
  /// In en, this message translates to:
  /// **'Enter theme name'**
  String get enterThemeName;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Press Back Again to Exit App'**
  String get exitConfirm;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exported.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get exported;

  /// No description provided for @errorImageGeneration.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during image generation.'**
  String get errorImageGeneration;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @failedGeneration.
  ///
  /// In en, this message translates to:
  /// **'Image generation failed. Credits not deducted.'**
  String get failedGeneration;

  /// No description provided for @sendingVerificationEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email.'**
  String get sendingVerificationEmailFailed;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @failedGenerationTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Image generation failed, try again.'**
  String get failedGenerationTryAgain;

  /// No description provided for @generatingImage.
  ///
  /// In en, this message translates to:
  /// **'Generating image'**
  String get generatingImage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @gmail.
  ///
  /// In en, this message translates to:
  /// **'Gmail'**
  String get gmail;

  /// No description provided for @goncharovaPainter.
  ///
  /// In en, this message translates to:
  /// **'Goncharova Painter'**
  String get goncharovaPainter;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image successfully saved to gallery'**
  String get imageSaved;

  /// No description provided for @imageSavedFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image to gallery'**
  String get imageSavedFailed;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get importFile;

  /// No description provided for @imageStyle.
  ///
  /// In en, this message translates to:
  /// **'Image Style'**
  String get imageStyle;

  /// No description provided for @inputSomeText.
  ///
  /// In en, this message translates to:
  /// **'Input Some Texts...'**
  String get inputSomeText;

  /// No description provided for @insufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'Insufficient credits. Deduction failed.'**
  String get insufficientCredits;

  /// No description provided for @lang.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lang;

  /// No description provided for @leaveARating.
  ///
  /// In en, this message translates to:
  /// **'Leave A five star Rating...'**
  String get leaveARating;

  /// No description provided for @khokhlomaPainter.
  ///
  /// In en, this message translates to:
  /// **'Khokhloma Painter'**
  String get khokhlomaPainter;

  /// No description provided for @malevichPainter.
  ///
  /// In en, this message translates to:
  /// **'Malevich Painter'**
  String get malevichPainter;

  /// No description provided for @medievalStyle.
  ///
  /// In en, this message translates to:
  /// **'Medival Style'**
  String get medievalStyle;

  /// No description provided for @moreDetailed.
  ///
  /// In en, this message translates to:
  /// **'More Detailed'**
  String get moreDetailed;

  /// No description provided for @moreInfo.
  ///
  /// In en, this message translates to:
  /// **'More Info'**
  String get moreInfo;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noPlansFound.
  ///
  /// In en, this message translates to:
  /// **'No Plans Found'**
  String get noPlansFound;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @noFolderSelected.
  ///
  /// In en, this message translates to:
  /// **'No Folder selected'**
  String get noFolderSelected;

  /// No description provided for @noStyle.
  ///
  /// In en, this message translates to:
  /// **'No Style'**
  String get noStyle;

  /// No description provided for @nullUserData.
  ///
  /// In en, this message translates to:
  /// **'User data is null'**
  String get nullUserData;

  /// No description provided for @oilPainting.
  ///
  /// In en, this message translates to:
  /// **'Oil Painting'**
  String get oilPainting;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @picassoPainter.
  ///
  /// In en, this message translates to:
  /// **'Picasso Painter'**
  String get picassoPainter;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pencilDrawing.
  ///
  /// In en, this message translates to:
  /// **'Pencil Drawing'**
  String get pencilDrawing;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please Enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Valid Email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please Enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordShort.
  ///
  /// In en, this message translates to:
  /// **'Password is too short'**
  String get passwordShort;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordNotMatch;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @pleaseEnterMailForReturnLink.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and we will send \nyou a link to return to your account'**
  String get pleaseEnterMailForReturnLink;

  /// No description provided for @passwordResetLink.
  ///
  /// In en, this message translates to:
  /// **'Password Reset Link sent to your email'**
  String get passwordResetLink;

  /// No description provided for @portraitPhoto.
  ///
  /// In en, this message translates to:
  /// **'Portrait Photo'**
  String get portraitPhoto;

  /// No description provided for @prefReq.
  ///
  /// In en, this message translates to:
  /// **'Mind telling us a few things?'**
  String get prefReq;

  /// No description provided for @processCanceled.
  ///
  /// In en, this message translates to:
  /// **'Process Canceled...'**
  String get processCanceled;

  /// No description provided for @rateImagen.
  ///
  /// In en, this message translates to:
  /// **'Rate Imagen'**
  String get rateImagen;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @registerAccount.
  ///
  /// In en, this message translates to:
  /// **'Register Account'**
  String get registerAccount;

  /// No description provided for @renaissance.
  ///
  /// In en, this message translates to:
  /// **'Renaissance'**
  String get renaissance;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetOnSkip.
  ///
  /// In en, this message translates to:
  /// **'Replay on Skip Previous'**
  String get resetOnSkip;

  /// No description provided for @resetOnSkipSub.
  ///
  /// In en, this message translates to:
  /// **'Replay from start instead of skipping to previous song'**
  String get resetOnSkipSub;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @restoreSub.
  ///
  /// In en, this message translates to:
  /// **'Restore your data from Backup.\nYou might need to restart app\n'**
  String get restoreSub;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @resultsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Results Not Found'**
  String get resultsNotFound;

  /// No description provided for @reenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// No description provided for @selectAmount.
  ///
  /// In en, this message translates to:
  /// **'Select Amount'**
  String get selectAmount;

  /// No description provided for @sendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Send verification email'**
  String get sendVerificationEmail;

  /// No description provided for @sendingVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Sending verification email'**
  String get sendingVerificationEmail;

  /// No description provided for @sorryRequestProcess.
  ///
  /// In en, this message translates to:
  /// **'Sorry, could not process your request now, try again later'**
  String get sorryRequestProcess;

  /// No description provided for @savePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Save Playlist'**
  String get savePlaylist;

  /// No description provided for @saveTheme.
  ///
  /// In en, this message translates to:
  /// **'Save Theme'**
  String get saveTheme;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @selectPayment.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPayment;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInProcess.
  ///
  /// In en, this message translates to:
  /// **'Signing in to account'**
  String get signInProcess;

  /// No description provided for @signInSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Signed In Successfully'**
  String get signInSuccessful;

  /// No description provided for @signInWIthPasswordAndEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email and password'**
  String get signInWIthPasswordAndEmail;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @showHere.
  ///
  /// In en, this message translates to:
  /// **'Show Here'**
  String get showHere;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get share;

  /// No description provided for @showHistory.
  ///
  /// In en, this message translates to:
  /// **'Show Search History'**
  String get showHistory;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @studioPhoto.
  ///
  /// In en, this message translates to:
  /// **'Studio Photo'**
  String get studioPhoto;

  /// No description provided for @successfulRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registered successfully, Please verify your email id'**
  String get successfulRegistration;

  /// No description provided for @thanksFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get thanksFeedback;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Theme deleted!'**
  String get themeDeleted;

  /// No description provided for @themeSaved.
  ///
  /// In en, this message translates to:
  /// **'Theme saved!'**
  String get themeSaved;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @ui.
  ///
  /// In en, this message translates to:
  /// **'App UI'**
  String get ui;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @useSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Use System Theme'**
  String get useSystemTheme;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available!'**
  String get updateAvailable;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @emailVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t verified your email address. This action is only allowed for verified users.'**
  String get emailVerificationMessage;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign In Failed'**
  String get signInFailed;

  /// No description provided for @verificationEmailSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent successfully'**
  String get verificationEmailSuccessful;

  /// No description provided for @verificationEmailError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during email verification'**
  String get verificationEmailError;

  /// No description provided for @userNotFoundException.
  ///
  /// In en, this message translates to:
  /// **'user not found'**
  String get userNotFoundException;

  /// No description provided for @wrongPasswordException.
  ///
  /// In en, this message translates to:
  /// **'wrong-password'**
  String get wrongPasswordException;

  /// No description provided for @tooManyRequestException.
  ///
  /// In en, this message translates to:
  /// **'too many requests'**
  String get tooManyRequestException;

  /// No description provided for @emailAlreadyInUseException.
  ///
  /// In en, this message translates to:
  /// **'email already in use'**
  String get emailAlreadyInUseException;

  /// No description provided for @operationNotAllowException.
  ///
  /// In en, this message translates to:
  /// **'operation not allowed'**
  String get operationNotAllowException;

  /// No description provided for @weakPasswordException.
  ///
  /// In en, this message translates to:
  /// **'weak password'**
  String get weakPasswordException;

  /// No description provided for @userMismatchException.
  ///
  /// In en, this message translates to:
  /// **'user mismatch'**
  String get userMismatchException;

  /// No description provided for @invalidCredentialException.
  ///
  /// In en, this message translates to:
  /// **'invalid credential'**
  String get invalidCredentialException;

  /// No description provided for @invalidEmailException.
  ///
  /// In en, this message translates to:
  /// **'invalid email'**
  String get invalidEmailException;

  /// No description provided for @userDisabledException.
  ///
  /// In en, this message translates to:
  /// **'user disabled'**
  String get userDisabledException;

  /// No description provided for @invalidVerificationCodeException.
  ///
  /// In en, this message translates to:
  /// **'invalid verification-code'**
  String get invalidVerificationCodeException;

  /// No description provided for @invalidVerificationIdException.
  ///
  /// In en, this message translates to:
  /// **'invalid verification-id'**
  String get invalidVerificationIdException;

  /// No description provided for @requiredRecentLoginException.
  ///
  /// In en, this message translates to:
  /// **'requires recent login'**
  String get requiredRecentLoginException;

  /// No description provided for @rechargeNow.
  ///
  /// In en, this message translates to:
  /// **'Recharge Now'**
  String get rechargeNow;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfitmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your Imagen account'**
  String get deleteAccountConfitmation;

  /// No description provided for @deleteAccountNote.
  ///
  /// In en, this message translates to:
  /// **'Note: If you delete your account all your data would be lost including your Imagen credits!'**
  String get deleteAccountNote;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @imageHistory.
  ///
  /// In en, this message translates to:
  /// **'Image History'**
  String get imageHistory;

  /// No description provided for @importSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Import Successful'**
  String get importSuccessful;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import Failed'**
  String get importFailed;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'shareImage'**
  String get shareImage;

  /// No description provided for @selectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select Backup File'**
  String get selectBackupFile;

  /// No description provided for @selectBackupLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Backup Location'**
  String get selectBackupLocation;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup Failed'**
  String get backupFailed;

  /// No description provided for @creditBalance.
  ///
  /// In en, this message translates to:
  /// **'Your credit balance is:'**
  String get creditBalance;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'bn',
        'cs',
        'de',
        'en',
        'es',
        'fr',
        'he',
        'hi',
        'id',
        'it',
        'ja',
        'nl',
        'pt',
        'ru',
        'ta',
        'tr',
        'uk',
        'ur',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'ta':
      return AppLocalizationsTa();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

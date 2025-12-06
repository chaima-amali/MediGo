import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MediGo'**
  String get appTitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @findNearbyPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Find Nearby Pharmacies'**
  String get findNearbyPharmacies;

  /// No description provided for @discoverPharmaciesDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover pharmacies near you with real-time distance tracking and easy navigation.'**
  String get discoverPharmaciesDescription;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @searchMedicines.
  ///
  /// In en, this message translates to:
  /// **'Search for Medicines'**
  String get searchMedicines;

  /// No description provided for @searchMedicinesDescription.
  ///
  /// In en, this message translates to:
  /// **'Quickly find the medicines you need with our smart search feature.'**
  String get searchMedicinesDescription;

  /// No description provided for @medicineReminders.
  ///
  /// In en, this message translates to:
  /// **'Medicine Reminders'**
  String get medicineReminders;

  /// No description provided for @medicineRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Never miss your medication with personalized reminders and treatment tracking.'**
  String get medicineRemindersDescription;

  /// No description provided for @contactDirections.
  ///
  /// In en, this message translates to:
  /// **'Contact & Directions'**
  String get contactDirections;

  /// No description provided for @contactDirectionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get detailed pharmacy information, directions, and contact them directly from the app.'**
  String get contactDirectionsDescription;

  /// No description provided for @noAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for that email'**
  String get noAccountFound;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome To '**
  String get welcomeTo;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Password?'**
  String get forgetPassword;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or Log in with'**
  String get orLoginWith;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your Full Name'**
  String get enterFullName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your Email'**
  String get enterEmail;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign up with'**
  String get orSignUpWith;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'You already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @selectGenderPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get selectGenderPrompt;

  /// No description provided for @selectDOBPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get selectDOBPrompt;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'select'**
  String get select;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date Of Birth'**
  String get dateOfBirth;

  /// No description provided for @dobFormat.
  ///
  /// In en, this message translates to:
  /// **'jj/dd/yyyy'**
  String get dobFormat;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create your password'**
  String get createPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi '**
  String get hi;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **' ,How are you\nfeeling Today?'**
  String get howAreYouFeeling;

  /// No description provided for @searchMedicinePrompt.
  ///
  /// In en, this message translates to:
  /// **'Search for your medicine ...'**
  String get searchMedicinePrompt;

  /// No description provided for @medicineReminder.
  ///
  /// In en, this message translates to:
  /// **'Medicine Remainder'**
  String get medicineReminder;

  /// No description provided for @reminderDescription.
  ///
  /// In en, this message translates to:
  /// **'You want a Remainder to track\nyour treatment'**
  String get reminderDescription;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @nearbyPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Nearby Pharmacy'**
  String get nearbyPharmacy;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating: \$rating'**
  String rating(Object rating);

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'(\$reviews)'**
  String reviews(Object reviews);

  /// No description provided for @findYourMedicine.
  ///
  /// In en, this message translates to:
  /// **'Find your medicine'**
  String get findYourMedicine;

  /// No description provided for @searchYourMedicine.
  ///
  /// In en, this message translates to:
  /// **'Search your medicine'**
  String get searchYourMedicine;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @preOrder.
  ///
  /// In en, this message translates to:
  /// **'Pre Order'**
  String get preOrder;

  /// No description provided for @pharmacyIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy id missing'**
  String get pharmacyIdMissing;

  /// No description provided for @profileScreen.
  ///
  /// In en, this message translates to:
  /// **'Profile Screen'**
  String get profileScreen;

  /// No description provided for @calendarScreen.
  ///
  /// In en, this message translates to:
  /// **'Calendar Screen'**
  String get calendarScreen;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Get add-free experience, priority\nreservations and instant restock alerts'**
  String get premiumDescription;

  /// No description provided for @upgradeNowPrice.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now - 3000DA/year'**
  String get upgradeNowPrice;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myReservations.
  ///
  /// In en, this message translates to:
  /// **'My Reservations'**
  String get myReservations;

  /// No description provided for @activeReservations.
  ///
  /// In en, this message translates to:
  /// **'\$activeReservationsCount active\nreservations'**
  String activeReservations(Object activeReservationsCount);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @receiveMedicineReminders.
  ///
  /// In en, this message translates to:
  /// **'Receive medicine reminders'**
  String get receiveMedicineReminders;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get darkModeDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacySecurityPage.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security Page'**
  String get privacySecurityPage;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacySecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your data Privacy & Security Page'**
  String get privacySecurityDescription;

  /// No description provided for @aboutMedigo.
  ///
  /// In en, this message translates to:
  /// **'About MediGo'**
  String get aboutMedigo;

  /// No description provided for @aboutMedigoPage.
  ///
  /// In en, this message translates to:
  /// **'About MediGo Page'**
  String get aboutMedigoPage;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @enterConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get enterConfirmNewPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// No description provided for @subscriptionAgreement.
  ///
  /// In en, this message translates to:
  /// **'By subscribing, you agree to our Terms of Service\nand Privacy Policy.\nSubscription auto-renews unless cancelled.'**
  String get subscriptionAgreement;

  /// No description provided for @subscribeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Monthly'**
  String get subscribeMonthly;

  /// No description provided for @billedAnnually.
  ///
  /// In en, this message translates to:
  /// **'Billed annually'**
  String get billedAnnually;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @billedMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get billedMonthly;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get perYear;

  /// No description provided for @subscribeYearly.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Yearly (Best Value)'**
  String get subscribeYearly;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @subscriptionSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You’ve successfully subscribed to the \$planName plan!'**
  String subscriptionSuccessMessage(Object planName);

  /// No description provided for @medicinePreOrderReservation.
  ///
  /// In en, this message translates to:
  /// **'Medicine pre-order & reservation'**
  String get medicinePreOrderReservation;

  /// No description provided for @medicinePreOrderDescription.
  ///
  /// In en, this message translates to:
  /// **'pre-order your medicine and reserve it then go for pick up when you are free'**
  String get medicinePreOrderDescription;

  /// No description provided for @instantRestockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Instant Restock Alerts'**
  String get instantRestockAlerts;

  /// No description provided for @instantRestockDescription.
  ///
  /// In en, this message translates to:
  /// **'Get notified immediately when out-of-stock medicines are available'**
  String get instantRestockDescription;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free Experience'**
  String get adFreeExperience;

  /// No description provided for @adFreeDescription.
  ///
  /// In en, this message translates to:
  /// **'Enjoy a clean, distraction-free interface without any ads'**
  String get adFreeDescription;

  /// No description provided for @yourCurrentMedicines.
  ///
  /// In en, this message translates to:
  /// **'Your current medicines'**
  String get yourCurrentMedicines;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'tracking'**
  String get tracking;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'statistics'**
  String get statistics;

  /// No description provided for @haveYouTakentYourMedicineToday.
  ///
  /// In en, this message translates to:
  /// **' Have you taken your medicine today ?'**
  String get haveYouTakentYourMedicineToday;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **' Add Medicine'**
  String get addMedicine;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineName;

  /// No description provided for @enterMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Enter medicine name'**
  String get enterMedicineName;

  /// No description provided for @medicineType.
  ///
  /// In en, this message translates to:
  /// **'Medicine Type'**
  String get medicineType;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @enterDoseExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 500'**
  String get enterDoseExample;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @timesPerDay.
  ///
  /// In en, this message translates to:
  /// **'How many times per day'**
  String get timesPerDay;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @importance.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get importance;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @enterNotes.
  ///
  /// In en, this message translates to:
  /// **'Write a note (optional)'**
  String get enterNotes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'Per day'**
  String get perDay;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'Per week'**
  String get perWeek;

  /// No description provided for @eachNDays.
  ///
  /// In en, this message translates to:
  /// **'Each N days'**
  String get eachNDays;

  /// No description provided for @customized.
  ///
  /// In en, this message translates to:
  /// **'Customized'**
  String get customized;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get yourProgress;

  /// No description provided for @medProgress.
  ///
  /// In en, this message translates to:
  /// **'Med Progress'**
  String get medProgress;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @no_medicines_for_day.
  ///
  /// In en, this message translates to:
  /// **'No medicines for this day'**
  String get no_medicines_for_day;

  /// No description provided for @cannot_update_item.
  ///
  /// In en, this message translates to:
  /// **'Cannot update this item'**
  String get cannot_update_item;

  /// No description provided for @marked_as_done.
  ///
  /// In en, this message translates to:
  /// **'Marked as done'**
  String get marked_as_done;

  /// No description provided for @unmarked.
  ///
  /// In en, this message translates to:
  /// **'Unmarked'**
  String get unmarked;

  /// No description provided for @failed_to_mark.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark as done'**
  String get failed_to_mark;

  /// No description provided for @failed_to_unmark.
  ///
  /// In en, this message translates to:
  /// **'Failed to unmark'**
  String get failed_to_unmark;

  /// No description provided for @cannot_edit_item.
  ///
  /// In en, this message translates to:
  /// **'Cannot edit this item'**
  String get cannot_edit_item;

  /// No description provided for @could_not_find_plan_for_occurrence.
  ///
  /// In en, this message translates to:
  /// **'Could not find plan for this occurrence'**
  String get could_not_find_plan_for_occurrence;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @delete_occurrence_title.
  ///
  /// In en, this message translates to:
  /// **'Delete occurrence'**
  String get delete_occurrence_title;

  /// No description provided for @delete_occurrence_text.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this occurrence?'**
  String get delete_occurrence_text;

  /// No description provided for @how_many_times_on_day.
  ///
  /// In en, this message translates to:
  /// **'How many times on {day}'**
  String how_many_times_on_day(Object day);

  /// No description provided for @select_start_date.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get select_start_date;

  /// No description provided for @select_end_date.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get select_end_date;

  /// No description provided for @start_end_dates_required.
  ///
  /// In en, this message translates to:
  /// **'Start and end dates are required'**
  String get start_end_dates_required;

  /// No description provided for @start_date_before_or_equal_end_date.
  ///
  /// In en, this message translates to:
  /// **'Start date must be before or equal to end date'**
  String get start_date_before_or_equal_end_date;

  /// No description provided for @medicine_added.
  ///
  /// In en, this message translates to:
  /// **'Medicine added'**
  String get medicine_added;

  /// No description provided for @failed_to_add_medicine.
  ///
  /// In en, this message translates to:
  /// **'Failed to add medicine'**
  String get failed_to_add_medicine;

  /// No description provided for @nothing_to_save.
  ///
  /// In en, this message translates to:
  /// **'Nothing to save'**
  String get nothing_to_save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @name_is_required.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get name_is_required;

  /// No description provided for @dose_must_be_greater_than_zero.
  ///
  /// In en, this message translates to:
  /// **'Dose must be greater than 0'**
  String get dose_must_be_greater_than_zero;

  /// No description provided for @times_per_day_required.
  ///
  /// In en, this message translates to:
  /// **'Times per day required'**
  String get times_per_day_required;

  /// No description provided for @start_date_must_before_end_date.
  ///
  /// In en, this message translates to:
  /// **'Start date must be before end date'**
  String get start_date_must_before_end_date;

  /// No description provided for @today_taken.
  ///
  /// In en, this message translates to:
  /// **'Today taken'**
  String get today_taken;

  /// No description provided for @medicines_progress.
  ///
  /// In en, this message translates to:
  /// **'Medicines Progress'**
  String get medicines_progress;

  /// No description provided for @unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get unnamed;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// No description provided for @failed_to_remove.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove'**
  String get failed_to_remove;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

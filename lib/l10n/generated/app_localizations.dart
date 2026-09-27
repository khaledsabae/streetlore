import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// Translation key: about_app
  ///
  /// In en, this message translates to:
  /// **'About Streetlore'**
  String get about_app;

  /// Translation key: about_place
  ///
  /// In en, this message translates to:
  /// **'About this place'**
  String get about_place;

  /// Translation key: add
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Translation key: add_photo_btn
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get add_photo_btn;

  /// Translation key: add_photo_title
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get add_photo_title;

  /// Translation key: ai_add_all
  ///
  /// In en, this message translates to:
  /// **'Add all to Trip Planner'**
  String get ai_add_all;

  /// Translation key: ai_added_to_planner
  ///
  /// In en, this message translates to:
  /// **'Added {n} places to your Trip Planner'**
  String ai_added_to_planner(String n);

  /// Translation key: ai_budget
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get ai_budget;

  /// Translation key: ai_days
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get ai_days;

  /// Translation key: ai_days_count
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String ai_days_count(String n);

  /// Translation key: ai_err_empty
  ///
  /// In en, this message translates to:
  /// **'Please describe what kind of trip you want.'**
  String get ai_err_empty;

  /// Translation key: ai_err_failed
  ///
  /// In en, this message translates to:
  /// **'Failed to generate: {e}'**
  String ai_err_failed(String e);

  /// Translation key: ai_generate
  ///
  /// In en, this message translates to:
  /// **'Generate Itinerary'**
  String get ai_generate;

  /// Translation key: ai_generating
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get ai_generating;

  /// Translation key: ai_local_tips
  ///
  /// In en, this message translates to:
  /// **'Local tips'**
  String get ai_local_tips;

  /// Translation key: ai_planner_title
  ///
  /// In en, this message translates to:
  /// **'Smart Trip Planner'**
  String get ai_planner_title;

  /// Translation key: ai_prompt_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. two days in Alexandria, mid-budget, love history'**
  String get ai_prompt_hint;

  /// Translation key: ai_prompt_title
  ///
  /// In en, this message translates to:
  /// **'Tell us about your trip'**
  String get ai_prompt_title;

  /// Translation key: ai_sugg_1
  ///
  /// In en, this message translates to:
  /// **'Two days in Alexandria, mid-budget, love history and seafood'**
  String get ai_sugg_1;

  /// Translation key: ai_sugg_2
  ///
  /// In en, this message translates to:
  /// **'One relaxed day focused on cafés and the corniche'**
  String get ai_sugg_2;

  /// Translation key: ai_sugg_3
  ///
  /// In en, this message translates to:
  /// **'Three days off the beaten path, hidden gems only'**
  String get ai_sugg_3;

  /// Translation key: ai_sugg_4
  ///
  /// In en, this message translates to:
  /// **'A family day with kid-friendly museums and a beach'**
  String get ai_sugg_4;

  /// Translation key: all_places
  ///
  /// In en, this message translates to:
  /// **'All Places'**
  String get all_places;

  /// Translation key: badge_streak_10
  ///
  /// In en, this message translates to:
  /// **'10 Visits'**
  String get badge_streak_10;

  /// Translation key: badge_streak_25
  ///
  /// In en, this message translates to:
  /// **'25 Visits'**
  String get badge_streak_25;

  /// Translation key: badge_streak_5
  ///
  /// In en, this message translates to:
  /// **'5 Visits'**
  String get badge_streak_5;

  /// Translation key: badge_streak_50
  ///
  /// In en, this message translates to:
  /// **'50 Visits'**
  String get badge_streak_50;

  /// Translation key: badge_unlocked
  ///
  /// In en, this message translates to:
  /// **'Badge unlocked: {name} 🏅'**
  String badge_unlocked(String name);

  /// Translation key: badges_title
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges_title;

  /// Translation key: browse_tours
  ///
  /// In en, this message translates to:
  /// **'Browse Tours'**
  String get browse_tours;

  /// Translation key: bt_daylight
  ///
  /// In en, this message translates to:
  /// **'Daylight'**
  String get bt_daylight;

  /// Translation key: bt_label_decent_now
  ///
  /// In en, this message translates to:
  /// **'Decent now'**
  String get bt_label_decent_now;

  /// Translation key: bt_label_go_now
  ///
  /// In en, this message translates to:
  /// **'Go now'**
  String get bt_label_go_now;

  /// Translation key: bt_label_wait
  ///
  /// In en, this message translates to:
  /// **'Wait for a better window'**
  String get bt_label_wait;

  /// Translation key: bt_ranked_now
  ///
  /// In en, this message translates to:
  /// **'Ranked for right now'**
  String get bt_ranked_now;

  /// Translation key: bt_reason_best_photos
  ///
  /// In en, this message translates to:
  /// **'Best for photos'**
  String get bt_reason_best_photos;

  /// Translation key: bt_reason_breakfast
  ///
  /// In en, this message translates to:
  /// **'Breakfast spots'**
  String get bt_reason_breakfast;

  /// Translation key: bt_reason_brunch
  ///
  /// In en, this message translates to:
  /// **'Brunch time'**
  String get bt_reason_brunch;

  /// Translation key: bt_reason_closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get bt_reason_closed;

  /// Translation key: bt_reason_closed_unsafe
  ///
  /// In en, this message translates to:
  /// **'Closed, unsafe'**
  String get bt_reason_closed_unsafe;

  /// Translation key: bt_reason_cool_empty
  ///
  /// In en, this message translates to:
  /// **'Cool & empty'**
  String get bt_reason_cool_empty;

  /// Translation key: bt_reason_cool_photo
  ///
  /// In en, this message translates to:
  /// **'Cool, photogenic'**
  String get bt_reason_cool_photo;

  /// Translation key: bt_reason_dinner
  ///
  /// In en, this message translates to:
  /// **'Dinner vibes'**
  String get bt_reason_dinner;

  /// Translation key: bt_reason_golden_hour
  ///
  /// In en, this message translates to:
  /// **'Golden hour magic'**
  String get bt_reason_golden_hour;

  /// Translation key: bt_reason_hot_crowd
  ///
  /// In en, this message translates to:
  /// **'Hot & crowded'**
  String get bt_reason_hot_crowd;

  /// Translation key: bt_reason_hot_shaded
  ///
  /// In en, this message translates to:
  /// **'Hot but shaded'**
  String get bt_reason_hot_shaded;

  /// Translation key: bt_reason_lunch
  ///
  /// In en, this message translates to:
  /// **'Lunch rush'**
  String get bt_reason_lunch;

  /// Translation key: bt_reason_often_closing
  ///
  /// In en, this message translates to:
  /// **'Often closing'**
  String get bt_reason_often_closing;

  /// Translation key: bt_reason_quietest
  ///
  /// In en, this message translates to:
  /// **'Quietest, best light'**
  String get bt_reason_quietest;

  /// Translation key: bt_reason_admin_set
  ///
  /// In en, this message translates to:
  /// **'Set by admin'**
  String get bt_reason_admin_set;

  /// Translation key: bt_reason_soft_light
  ///
  /// In en, this message translates to:
  /// **'Soft light'**
  String get bt_reason_soft_light;

  /// Translation key: bt_reason_too_early
  ///
  /// In en, this message translates to:
  /// **'Too early'**
  String get bt_reason_too_early;

  /// Translation key: bt_reason_too_late
  ///
  /// In en, this message translates to:
  /// **'Too late'**
  String get bt_reason_too_late;

  /// Translation key: bt_reason_warm_ok
  ///
  /// In en, this message translates to:
  /// **'Warm but ok'**
  String get bt_reason_warm_ok;

  /// Translation key: bt_sub_great
  ///
  /// In en, this message translates to:
  /// **'{day} — {n} place{s} glowing right now'**
  String bt_sub_great(String day, String n, String s);

  /// Translation key: bt_sub_okay
  ///
  /// In en, this message translates to:
  /// **'{day} — {n} decent pick{s} if you hurry'**
  String bt_sub_okay(String day, String n, String s);

  /// Translation key: bt_sub_quiet
  ///
  /// In en, this message translates to:
  /// **'{day} — quiet time, plan for later'**
  String bt_sub_quiet(String day);

  /// Translation key: bt_sunrise
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get bt_sunrise;

  /// Translation key: bt_sunset
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get bt_sunset;

  /// Translation key: bt_title
  ///
  /// In en, this message translates to:
  /// **'Best Time to Visit'**
  String get bt_title;

  /// Translation key: budget_friendly
  ///
  /// In en, this message translates to:
  /// **'Budget-friendly'**
  String get budget_friendly;

  /// Translation key: cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Translation key: cat_all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get cat_all;

  /// Translation key: cat_churches
  ///
  /// In en, this message translates to:
  /// **'Churches'**
  String get cat_churches;

  /// Translation key: cat_culture
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get cat_culture;

  /// Translation key: cat_food
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get cat_food;

  /// Translation key: cat_historical
  ///
  /// In en, this message translates to:
  /// **'Historical'**
  String get cat_historical;

  /// Translation key: cat_hotels
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get cat_hotels;

  /// Translation key: cat_mosques
  ///
  /// In en, this message translates to:
  /// **'Mosques'**
  String get cat_mosques;

  /// Translation key: cat_nature
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get cat_nature;

  /// Translation key: cat_shopping
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get cat_shopping;

  /// Translation key: chat_empty
  ///
  /// In en, this message translates to:
  /// **'Be the first to say hi'**
  String get chat_empty;

  /// Translation key: chat_hint
  ///
  /// In en, this message translates to:
  /// **'Say something to fellow travellers...'**
  String get chat_hint;

  /// Translation key: chat_live
  ///
  /// In en, this message translates to:
  /// **'Live chat'**
  String get chat_live;

  /// Translation key: chat_now
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get chat_now;

  /// Translation key: checked_in_streak
  ///
  /// In en, this message translates to:
  /// **'Checked in! Streak: {n}'**
  String checked_in_streak(String n);

  /// Translation key: checkin
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get checkin;

  /// Translation key: checkin_removed
  ///
  /// In en, this message translates to:
  /// **'Check-in removed'**
  String get checkin_removed;

  /// Translation key: choose_gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get choose_gallery;

  /// Translation key: clear
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Translation key: clear_all_title
  ///
  /// In en, this message translates to:
  /// **'Clear All Saved Places?'**
  String get clear_all_title;

  /// Translation key: clear_all_warning
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove all saved places. This cannot be undone.'**
  String get clear_all_warning;

  /// Translation key: closed
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// Translation key: community_chat
  ///
  /// In en, this message translates to:
  /// **'Community Chat'**
  String get community_chat;

  /// Translation key: community_chat_sub
  ///
  /// In en, this message translates to:
  /// **'Ask travelers about this place'**
  String get community_chat_sub;

  /// Translation key: community_reviews
  ///
  /// In en, this message translates to:
  /// **'Community Reviews'**
  String get community_reviews;

  /// Translation key: compass_sub
  ///
  /// In en, this message translates to:
  /// **'Discover the city with a sweeping animated compass that grows into place.'**
  String get compass_sub;

  /// Translation key: compass_title
  ///
  /// In en, this message translates to:
  /// **'Compass direction'**
  String get compass_title;

  /// Translation key: copy_link
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copy_link;

  /// Translation key: cur_amount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get cur_amount;

  /// Translation key: cur_disclaimer
  ///
  /// In en, this message translates to:
  /// **'Rates are approximate and based on mid-market averages. Check with your bank or exchange for actual rates.'**
  String get cur_disclaimer;

  /// Translation key: cur_enter_amount
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get cur_enter_amount;

  /// Translation key: cur_from
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get cur_from;

  /// Translation key: cur_to
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get cur_to;

  /// Translation key: currency_converter
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get currency_converter;

  /// Translation key: currency_converter_sub
  ///
  /// In en, this message translates to:
  /// **'EGP ↔ USD, EUR, GBP, SAR + more'**
  String get currency_converter_sub;

  /// Translation key: dark_mode
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// Translation key: dark_theme_on
  ///
  /// In en, this message translates to:
  /// **'Dark theme enabled'**
  String get dark_theme_on;

  /// Translation key: day_fri
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get day_fri;

  /// Translation key: day_mon
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get day_mon;

  /// Translation key: day_sat
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get day_sat;

  /// Translation key: day_sun
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get day_sun;

  /// Translation key: day_thu
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get day_thu;

  /// Translation key: day_tue
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get day_tue;

  /// Translation key: day_wed
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get day_wed;

  /// Translation key: delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Translation key: delete_photo_q
  ///
  /// In en, this message translates to:
  /// **'Delete this photo?'**
  String get delete_photo_q;

  /// Translation key: delete_review_q
  ///
  /// In en, this message translates to:
  /// **'Delete this review?'**
  String get delete_review_q;

  /// Translation key: discover
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// Translation key: discover_places
  ///
  /// In en, this message translates to:
  /// **'Discover Places'**
  String get discover_places;

  /// Translation key: edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Translation key: edit_name
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get edit_name;

  /// Translation key: edit_name_dialog_title
  ///
  /// In en, this message translates to:
  /// **'Change your display name'**
  String get edit_name_dialog_title;

  /// Translation key: egyptians
  ///
  /// In en, this message translates to:
  /// **'Egyptians'**
  String get egyptians;

  /// Translation key: email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Translation key: emergency_info
  ///
  /// In en, this message translates to:
  /// **'Emergency Info'**
  String get emergency_info;

  /// Translation key: emergency_info_sub
  ///
  /// In en, this message translates to:
  /// **'Hospitals, embassies, hotlines'**
  String get emergency_info_sub;

  /// Translation key: emg_call_failed
  ///
  /// In en, this message translates to:
  /// **'Cannot place call to {n}'**
  String emg_call_failed(String n);

  /// Translation key: emg_embassies
  ///
  /// In en, this message translates to:
  /// **'Embassies & Consulates'**
  String get emg_embassies;

  /// Translation key: emg_hero_sub
  ///
  /// In en, this message translates to:
  /// **'Tap any number to call. Save this page for quick access.'**
  String get emg_hero_sub;

  /// Translation key: emg_hero_title
  ///
  /// In en, this message translates to:
  /// **'Stay safe in Alexandria'**
  String get emg_hero_title;

  /// Translation key: emg_hospitals
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get emg_hospitals;

  /// Translation key: emg_numbers
  ///
  /// In en, this message translates to:
  /// **'Emergency Numbers'**
  String get emg_numbers;

  /// Translation key: emg_pharmacies
  ///
  /// In en, this message translates to:
  /// **'24h Pharmacies'**
  String get emg_pharmacies;

  /// Translation key: emg_title
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emg_title;

  /// Translation key: admin_title
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get admin_title;

  /// Translation key: admin_forbidden
  ///
  /// In en, this message translates to:
  /// **'Admin only'**
  String get admin_forbidden;

  /// Translation key: admin_forbidden_sub
  ///
  /// In en, this message translates to:
  /// **'Your account is not authorised to add places.'**
  String get admin_forbidden_sub;

  /// Translation key: admin_add_new
  ///
  /// In en, this message translates to:
  /// **'Add new place'**
  String get admin_add_new;

  /// Translation key: admin_view_list
  ///
  /// In en, this message translates to:
  /// **'View places list'**
  String get admin_view_list;

  /// Translation key: admin_field_name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get admin_field_name;

  /// Translation key: admin_field_category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get admin_field_category;

  /// Translation key: admin_field_address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get admin_field_address;

  /// Translation key: admin_field_description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get admin_field_description;

  /// Translation key: admin_field_image
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get admin_field_image;

  /// Translation key: admin_field_hours
  ///
  /// In en, this message translates to:
  /// **'Open hours'**
  String get admin_field_hours;

  /// Translation key: admin_field_rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get admin_field_rating;

  /// Translation key: admin_err_name
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get admin_err_name;

  /// Translation key: admin_err_category
  ///
  /// In en, this message translates to:
  /// **'Category is required (e.g. ATM, Hotel, Cafe)'**
  String get admin_err_category;

  /// Translation key: admin_err_address
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get admin_err_address;

  /// Translation key: admin_submit
  ///
  /// In en, this message translates to:
  /// **'Add to map'**
  String get admin_submit;

  /// Translation key: admin_added
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get admin_added;

  /// Translation key: admin_failed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get admin_failed;

  /// Translation key: emg_transport
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get emg_transport;

  /// Translation key: empty_saved_places_sub
  ///
  /// In en, this message translates to:
  /// **'Start exploring and tap the bookmark icon on any place to save it here for easy access.'**
  String get empty_saved_places_sub;

  /// Translation key: empty_saved_tours_sub
  ///
  /// In en, this message translates to:
  /// **'Tap the download icon on any tour to save it here for offline access.'**
  String get empty_saved_tours_sub;

  /// Translation key: featured
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// Translation key: filter_cheapest
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get filter_cheapest;

  /// Translation key: filter_free
  ///
  /// In en, this message translates to:
  /// **'Free only'**
  String get filter_free;

  /// Translation key: filter_hidden_gems
  ///
  /// In en, this message translates to:
  /// **'Hidden Gems'**
  String get filter_hidden_gems;

  /// Translation key: filter_nearest
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get filter_nearest;

  /// Translation key: filter_open_now
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get filter_open_now;

  /// Translation key: first_photo
  ///
  /// In en, this message translates to:
  /// **'Be the first to share a photo'**
  String get first_photo;

  /// Translation key: foreigners
  ///
  /// In en, this message translates to:
  /// **'Foreigners'**
  String get foreigners;

  /// Translation key: free_banner_sub
  ///
  /// In en, this message translates to:
  /// **'All tours, places & guides are unlocked for everyone.'**
  String get free_banner_sub;

  /// Translation key: free_banner_title
  ///
  /// In en, this message translates to:
  /// **'Everything is free'**
  String get free_banner_title;

  /// Translation key: passion_banner_title
  ///
  /// In en, this message translates to:
  /// **'A non-profit passion project'**
  String get passion_banner_title;

  /// Translation key: passion_banner_sub
  ///
  /// In en, this message translates to:
  /// **'Built out of love for Alexandria — and for you. Free, ad-free, and made for fun. Every recommendation is hand-curated by someone who actually lives here.'**
  String get passion_banner_sub;

  /// Translation key: free_entry
  ///
  /// In en, this message translates to:
  /// **'Free entry'**
  String get free_entry;

  /// Translation key: geo_choose_places
  ///
  /// In en, this message translates to:
  /// **'Choose places'**
  String get geo_choose_places;

  /// Translation key: geo_distance
  ///
  /// In en, this message translates to:
  /// **'{d} m from city center'**
  String geo_distance(String d);

  /// Translation key: geo_hero_sub
  ///
  /// In en, this message translates to:
  /// **'Choose the places you want alerts for - within 500m by default.'**
  String get geo_hero_sub;

  /// Translation key: geo_hero_title
  ///
  /// In en, this message translates to:
  /// **'Get notified nearby'**
  String get geo_hero_title;

  /// Translation key: geo_monitoring_off
  ///
  /// In en, this message translates to:
  /// **'Monitoring paused'**
  String get geo_monitoring_off;

  /// Translation key: geo_monitoring_on
  ///
  /// In en, this message translates to:
  /// **'Monitoring your location for nearby places'**
  String get geo_monitoring_on;

  /// Translation key: geo_title
  ///
  /// In en, this message translates to:
  /// **'Geofencing Alerts'**
  String get geo_title;

  /// Translation key: go
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// Translation key: got_it
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get got_it;

  /// Translation key: greet_afternoon
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greet_afternoon;

  /// Translation key: greet_evening
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greet_evening;

  /// Translation key: greet_morning
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greet_morning;

  /// Translation key: greet_night
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greet_night;

  /// Translation key: guest_dialog_sub
  ///
  /// In en, this message translates to:
  /// **'Other travellers will see this name on the leaderboard. You can change it later.'**
  String get guest_dialog_sub;

  /// Translation key: guest_dialog_title
  ///
  /// In en, this message translates to:
  /// **'Pick a display name'**
  String get guest_dialog_title;

  /// Translation key: help_center
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get help_center;

  /// Translation key: help_center_sub
  ///
  /// In en, this message translates to:
  /// **'FAQs and support'**
  String get help_center_sub;

  /// Translation key: help_contact
  ///
  /// In en, this message translates to:
  /// **'For support, contact us at:\\nmohamedsabe50@gmail.com\\n\\nWe reply within 24 hours.'**
  String get help_contact;

  /// Translation key: journal_add_first
  ///
  /// In en, this message translates to:
  /// **'Add first memory'**
  String get journal_add_first;

  /// Translation key: journal_add_memory
  ///
  /// In en, this message translates to:
  /// **'Add memory'**
  String get journal_add_memory;

  /// Translation key: journal_days_ago
  ///
  /// In en, this message translates to:
  /// **'{n} days ago'**
  String journal_days_ago(String n);

  /// Translation key: journal_edit_memory
  ///
  /// In en, this message translates to:
  /// **'Edit memory'**
  String get journal_edit_memory;

  /// Translation key: journal_empty_sub
  ///
  /// In en, this message translates to:
  /// **'Save memories, photos, and notes for every place you visit.'**
  String get journal_empty_sub;

  /// Translation key: journal_empty_title
  ///
  /// In en, this message translates to:
  /// **'Your travel journal is empty'**
  String get journal_empty_title;

  /// Translation key: journal_new_memory
  ///
  /// In en, this message translates to:
  /// **'New memory'**
  String get journal_new_memory;

  /// Translation key: journal_note_hint
  ///
  /// In en, this message translates to:
  /// **'What did you think? What did you do? Tips for other travelers?'**
  String get journal_note_hint;

  /// Translation key: journal_notes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get journal_notes;

  /// Translation key: journal_pick_place
  ///
  /// In en, this message translates to:
  /// **'Pick a place'**
  String get journal_pick_place;

  /// Translation key: journal_save_memory
  ///
  /// In en, this message translates to:
  /// **'Save memory'**
  String get journal_save_memory;

  /// Translation key: journal_search_hint
  ///
  /// In en, this message translates to:
  /// **'Search places...'**
  String get journal_search_hint;

  /// Translation key: journal_today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get journal_today;

  /// Translation key: journal_update_memory
  ///
  /// In en, this message translates to:
  /// **'Update memory'**
  String get journal_update_memory;

  /// Translation key: journal_yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get journal_yesterday;

  /// Translation key: language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Translation key: lb_empty
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data yet'**
  String get lb_empty;

  /// Translation key: lb_points_level
  ///
  /// In en, this message translates to:
  /// **'{p} points · {l}'**
  String lb_points_level(String p, String l);

  /// Translation key: lb_row_sub
  ///
  /// In en, this message translates to:
  /// **'{v} visited · {r} reviews'**
  String lb_row_sub(String v, String r);

  /// Translation key: lb_subtitle
  ///
  /// In en, this message translates to:
  /// **'Most travelled around the world'**
  String get lb_subtitle;

  /// Translation key: lb_title
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get lb_title;

  /// Translation key: lb_your_rank
  ///
  /// In en, this message translates to:
  /// **'YOUR RANK'**
  String get lb_your_rank;

  /// Translation key: level_cartographer
  ///
  /// In en, this message translates to:
  /// **'Cartographer'**
  String get level_cartographer;

  /// Translation key: level_explorer
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get level_explorer;

  /// Translation key: level_lorekeeper
  ///
  /// In en, this message translates to:
  /// **'Lorekeeper'**
  String get level_lorekeeper;

  /// Translation key: level_wanderer
  ///
  /// In en, this message translates to:
  /// **'Wanderer'**
  String get level_wanderer;

  /// Translation key: light_theme_on
  ///
  /// In en, this message translates to:
  /// **'Light theme active'**
  String get light_theme_on;

  /// Translation key: loading_tours
  ///
  /// In en, this message translates to:
  /// **'Loading tours...'**
  String get loading_tours;

  /// Translation key: loc_perm_blocked
  ///
  /// In en, this message translates to:
  /// **'Location is blocked. Enable it in Settings to get nearby alerts.'**
  String get loc_perm_blocked;

  /// Translation key: loc_service_off
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Turn them on to see what is around you.'**
  String get loc_service_off;

  /// Translation key: location_denied
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Enable it to see local weather.'**
  String get location_denied;

  /// Translation key: location_services
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get location_services;

  /// Translation key: location_services_sub
  ///
  /// In en, this message translates to:
  /// **'Used for nearby recommendations'**
  String get location_services_sub;

  /// Translation key: login_continue_guest
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get login_continue_guest;

  /// Translation key: login_email
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get login_email;

  /// Translation key: login_email_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. ahmed@example.com'**
  String get login_email_hint;

  /// Translation key: login_err_email
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get login_err_email;

  /// Translation key: login_err_email_invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get login_err_email_invalid;

  /// Translation key: login_err_name
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get login_err_name;

  /// Translation key: login_err_password_short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get login_err_password_short;

  /// Translation key: login_err_account_exists
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in.'**
  String get login_err_account_exists;

  /// Translation key: login_err_no_account
  ///
  /// In en, this message translates to:
  /// **'No account found with this email. Tap Sign Up to create one.'**
  String get login_err_no_account;

  /// Translation key: login_err_wrong_password
  ///
  /// In en, this message translates to:
  /// **'Wrong password. Please try again.'**
  String get login_err_wrong_password;

  /// Translation key: login_err_unknown
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get login_err_unknown;

  /// Translation key: login_password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password;

  /// Translation key: login_password_hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get login_password_hint;

  /// Translation key: login_password_hint_signup
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get login_password_hint_signup;

  /// Translation key: login_full_name
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get login_full_name;

  /// Translation key: login_google
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get login_google;

  /// Translation key: login_google_signed_in
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google (local).'**
  String get login_google_signed_in;

  /// Translation key: login_google_unavailable
  ///
  /// In en, this message translates to:
  /// **'Google sign-in unavailable. Use email or continue as guest.'**
  String get login_google_unavailable;

  /// Translation key: login_google_timeout
  ///
  /// In en, this message translates to:
  /// **'Google sign-in took too long. Try again or use email.'**
  String get login_google_timeout;

  /// Translation key: login_google_failed
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Check your Supabase redirect URL settings.'**
  String get login_google_failed;

  /// Translation key: login_have_account
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get login_have_account;

  /// Translation key: login_username
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get login_username;

  /// Translation key: login_username_hint
  ///
  /// In en, this message translates to:
  /// **'3-20 chars: letters, digits, . _ -'**
  String get login_username_hint;

  /// Translation key: login_err_username_empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get login_err_username_empty;

  /// Translation key: login_err_username_length
  ///
  /// In en, this message translates to:
  /// **'Username must be 3-20 characters'**
  String get login_err_username_length;

  /// Translation key: login_err_username_chars
  ///
  /// In en, this message translates to:
  /// **'Only letters, digits, dot, underscore and dash'**
  String get login_err_username_chars;

  /// Translation key: username_invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid username (3-20 chars, letters/digits/._-)'**
  String get username_invalid;

  /// Translation key: login_no_account
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get login_no_account;

  /// Translation key: login_sign_up
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get login_sign_up;

  /// Translation key: login_guest_name
  ///
  /// In en, this message translates to:
  /// **'Guest Explorer'**
  String get login_guest_name;

  /// Translation key: login_just_exploring
  ///
  /// In en, this message translates to:
  /// **'Just exploring? '**
  String get login_just_exploring;

  /// Translation key: login_name_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Ahmed Hassan'**
  String get login_name_hint;

  /// Translation key: login_or
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get login_or;

  /// Translation key: login_sign_in
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login_sign_in;

  /// Translation key: login_subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to save your favorite places and access exclusive tours.'**
  String get login_subtitle;

  /// Translation key: login_welcome
  ///
  /// In en, this message translates to:
  /// **'Welcome to\\nStreetlore'**
  String get login_welcome;

  /// Translation key: map_close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get map_close;

  /// Translation key: map_err_location
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while locating you.'**
  String get map_err_location;

  /// Translation key: map_err_location_denied
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show the route.'**
  String get map_err_location_denied;

  /// Translation key: map_err_location_denied_forever
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please enable it in Settings.'**
  String get map_err_location_denied_forever;

  /// Translation key: map_err_offline
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection.'**
  String get map_err_offline;

  /// Translation key: map_err_route
  ///
  /// In en, this message translates to:
  /// **'Failed to load the road route.'**
  String get map_err_route;

  /// Translation key: map_my_location
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get map_my_location;

  /// Translation key: map_open_details
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get map_open_details;

  /// Translation key: map_title
  ///
  /// In en, this message translates to:
  /// **'Map · {n} places'**
  String map_title(String n);

  /// Translation key: map_view
  ///
  /// In en, this message translates to:
  /// **'Map View'**
  String get map_view;

  /// Translation key: map_view_sub
  ///
  /// In en, this message translates to:
  /// **'All places on interactive map'**
  String get map_view_sub;

  /// Translation key: message
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Translation key: nav_explore
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get nav_explore;

  /// Translation key: nav_profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// Translation key: nav_saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get nav_saved;

  /// Translation key: nav_tours
  ///
  /// In en, this message translates to:
  /// **'Tours'**
  String get nav_tours;

  /// Translation key: nearby_gems
  ///
  /// In en, this message translates to:
  /// **'Nearby Hidden Gems'**
  String get nearby_gems;

  /// Translation key: no_badges
  ///
  /// In en, this message translates to:
  /// **'Check in at places to earn badges'**
  String get no_badges;

  /// Translation key: no_places
  ///
  /// In en, this message translates to:
  /// **'No places found'**
  String get no_places;

  /// Translation key: no_results_for
  ///
  /// In en, this message translates to:
  /// **'No results for \"{q}\"'**
  String no_results_for(String q);

  /// Translation key: no_reviews
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Be the first to share your story!'**
  String get no_reviews;

  /// Translation key: no_saved_places
  ///
  /// In en, this message translates to:
  /// **'No Saved Places'**
  String get no_saved_places;

  /// Translation key: no_saved_tours
  ///
  /// In en, this message translates to:
  /// **'No Saved Tours'**
  String get no_saved_tours;

  /// Translation key: no_tours
  ///
  /// In en, this message translates to:
  /// **'No tours yet'**
  String get no_tours;

  /// Translation key: ob_get_started
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get ob_get_started;

  /// Translation key: ob_next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get ob_next;

  /// Translation key: ob_skip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get ob_skip;

  /// Translation key: ob_sub_1
  ///
  /// In en, this message translates to:
  /// **'Uncover 30+ hidden gems and landmarks of Alexandria that most tourists never find.'**
  String get ob_sub_1;

  /// Translation key: ob_sub_2
  ///
  /// In en, this message translates to:
  /// **'Choose from expertly curated tours. Navigate with ease and explore at your own pace.'**
  String get ob_sub_2;

  /// Translation key: ob_sub_3
  ///
  /// In en, this message translates to:
  /// **'Build your personal travel collection. Save your favorite places and access them anytime.'**
  String get ob_sub_3;

  /// Translation key: ob_title_1
  ///
  /// In en, this message translates to:
  /// **'Discover the Unseen'**
  String get ob_title_1;

  /// Translation key: ob_title_2
  ///
  /// In en, this message translates to:
  /// **'Plan Your Journey'**
  String get ob_title_2;

  /// Translation key: ob_title_3
  ///
  /// In en, this message translates to:
  /// **'Save & Revisit'**
  String get ob_title_3;

  /// Translation key: offline_available
  ///
  /// In en, this message translates to:
  /// **'Available to download'**
  String get offline_available;

  /// Translation key: offline_download
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get offline_download;

  /// Translation key: offline_downloaded
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get offline_downloaded;

  /// Translation key: offline_hero_title
  ///
  /// In en, this message translates to:
  /// **'Travel without signal'**
  String get offline_hero_title;

  /// Translation key: offline_mb_downloaded
  ///
  /// In en, this message translates to:
  /// **'{n} MB downloaded'**
  String offline_mb_downloaded(String n);

  /// Translation key: offline_pack_size
  ///
  /// In en, this message translates to:
  /// **'{mb} MB · {n} places'**
  String offline_pack_size(String mb, String n);

  /// Translation key: offline_title
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offline_title;

  /// Translation key: open_now
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get open_now;

  /// Translation key: open_settings
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get open_settings;

  /// Translation key: photos
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// Translation key: places_count
  ///
  /// In en, this message translates to:
  /// **'{n} places'**
  String places_count(String n);

  /// Translation key: post_review
  ///
  /// In en, this message translates to:
  /// **'Post Review'**
  String get post_review;

  /// Translation key: prayer_asr
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayer_asr;

  /// Translation key: prayer_dhuhr
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayer_dhuhr;

  /// Translation key: prayer_fajr
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayer_fajr;

  /// Translation key: prayer_isha
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayer_isha;

  /// Translation key: prayer_load_failed
  ///
  /// In en, this message translates to:
  /// **'Failed to load prayer times'**
  String get prayer_load_failed;

  /// Translation key: prayer_maghrib
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayer_maghrib;

  /// Translation key: prayer_sunrise
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayer_sunrise;

  /// Translation key: prayer_times
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayer_times;

  /// Translation key: prayer_times_sub
  ///
  /// In en, this message translates to:
  /// **'Daily prayer schedule for Alexandria'**
  String get prayer_times_sub;

  /// Translation key: premium_experience
  ///
  /// In en, this message translates to:
  /// **'Premium experience'**
  String get premium_experience;

  /// Translation key: prof_explored
  ///
  /// In en, this message translates to:
  /// **'Explored'**
  String get prof_explored;

  /// Translation key: prof_saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get prof_saved;

  /// Translation key: prof_tours
  ///
  /// In en, this message translates to:
  /// **'Tours'**
  String get prof_tours;

  /// Translation key: push_notif
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get push_notif;

  /// Translation key: push_notif_sub
  ///
  /// In en, this message translates to:
  /// **'Get tips and discoveries'**
  String get push_notif_sub;

  /// Translation key: quick_ai_trip
  ///
  /// In en, this message translates to:
  /// **'AI Trip'**
  String get quick_ai_trip;

  /// Translation key: quick_badges
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get quick_badges;

  /// Translation key: quick_best_time
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get quick_best_time;

  /// Translation key: best_time_admin_hint
  ///
  /// In en, this message translates to:
  /// **'Set by the editorial team'**
  String get best_time_admin_hint;

  /// Translation key: quick_chat
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get quick_chat;

  /// Translation key: quick_journal
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get quick_journal;

  /// Translation key: quick_map
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get quick_map;

  /// Translation key: quick_offline
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get quick_offline;

  /// Translation key: quick_prayer
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get quick_prayer;

  /// Translation key: quick_ranking
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get quick_ranking;

  /// Translation key: quick_routes
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get quick_routes;

  /// Translation key: quick_transport
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get quick_transport;

  /// Translation key: rate_app
  ///
  /// In en, this message translates to:
  /// **'Rate Streetlore'**
  String get rate_app;

  /// Translation key: rate_app_sub
  ///
  /// In en, this message translates to:
  /// **'Share your experience'**
  String get rate_app_sub;

  /// Translation key: rate_thanks
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support! '**
  String get rate_thanks;

  /// Translation key: rating_label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating_label;

  /// Translation key: refresh
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Translation key: remove
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Translation key: removed_from_saved
  ///
  /// In en, this message translates to:
  /// **'{name} removed from saved places'**
  String removed_from_saved(String name);

  /// Translation key: results_for
  ///
  /// In en, this message translates to:
  /// **'{n} results for \"{q}\"'**
  String results_for(String n, String q);

  /// Translation key: review_empty_warn
  ///
  /// In en, this message translates to:
  /// **'Please write a comment first'**
  String get review_empty_warn;

  /// Translation key: review_failed
  ///
  /// In en, this message translates to:
  /// **'Could not post review'**
  String get review_failed;

  /// Translation key: review_hint
  ///
  /// In en, this message translates to:
  /// **'Share your experience...'**
  String get review_hint;

  /// Translation key: save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Translation key: saved
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Translation key: saved_cleared
  ///
  /// In en, this message translates to:
  /// **'All saved places cleared.'**
  String get saved_cleared;

  /// Translation key: saved_collection
  ///
  /// In en, this message translates to:
  /// **'Your collection'**
  String get saved_collection;

  /// Translation key: saved_count
  ///
  /// In en, this message translates to:
  /// **'{n} saved'**
  String saved_count(String n);

  /// Translation key: saved_title
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved_title;

  /// Translation key: search_hint
  ///
  /// In en, this message translates to:
  /// **'Search places, landmarks...'**
  String get search_hint;

  /// Translation key: section_about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get section_about;

  /// Translation key: section_app_settings
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get section_app_settings;

  /// Translation key: see_all
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// Translation key: share_app
  ///
  /// In en, this message translates to:
  /// **'Share Streetlore'**
  String get share_app;

  /// Translation key: sign_in_continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sign_in_continue;

  /// Translation key: sign_out
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sign_out;

  /// Translation key: sign_out_q
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get sign_out_q;

  /// Translation key: sign_out_sub
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out? Your saved places will be preserved.'**
  String get sign_out_sub;

  /// Translation key: standard_ticket
  ///
  /// In en, this message translates to:
  /// **'Standard ticket'**
  String get standard_ticket;

  /// Translation key: stat_reviews
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get stat_reviews;

  /// Translation key: stat_visited
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get stat_visited;

  /// Translation key: streak_begin
  ///
  /// In en, this message translates to:
  /// **'Check in at any place to begin'**
  String get streak_begin;

  /// Translation key: streak_best
  ///
  /// In en, this message translates to:
  /// **'Best: {b} · {t} day{s} total'**
  String streak_best(String b, String t, String s);

  /// Translation key: streak_days
  ///
  /// In en, this message translates to:
  /// **'{n} visits streak'**
  String streak_days(String n);

  /// Translation key: streak_start
  ///
  /// In en, this message translates to:
  /// **'Start your streak'**
  String get streak_start;

  /// Translation key: swipe_remove_hint
  ///
  /// In en, this message translates to:
  /// **'<- Swipe left to remove'**
  String get swipe_remove_hint;

  /// Translation key: switch_explore
  ///
  /// In en, this message translates to:
  /// **'Switch to the Explore tab to discover places!'**
  String get switch_explore;

  /// Translation key: switch_tours
  ///
  /// In en, this message translates to:
  /// **'Switch to the Tours tab to discover tours!'**
  String get switch_tours;

  /// Translation key: tab_places
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get tab_places;

  /// Translation key: tab_tours
  ///
  /// In en, this message translates to:
  /// **'Tours'**
  String get tab_tours;

  /// Translation key: take_photo
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get take_photo;

  /// Translation key: tour_about
  ///
  /// In en, this message translates to:
  /// **'About this Tour'**
  String get tour_about;

  /// Translation key: tour_access
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get tour_access;

  /// Translation key: tour_duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get tour_duration;

  /// Translation key: tour_filter_all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tour_filter_all;

  /// Translation key: tour_filter_full
  ///
  /// In en, this message translates to:
  /// **'Full day'**
  String get tour_filter_full;

  /// Translation key: tour_filter_half
  ///
  /// In en, this message translates to:
  /// **'Half day'**
  String get tour_filter_half;

  /// Translation key: tour_filter_short
  ///
  /// In en, this message translates to:
  /// **'Up to 3h'**
  String get tour_filter_short;

  /// Translation key: tour_free
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get tour_free;

  /// Translation key: tour_guide_hint
  ///
  /// In en, this message translates to:
  /// **'Ask about {name}...'**
  String tour_guide_hint(String name);

  /// Translation key: tour_itinerary
  ///
  /// In en, this message translates to:
  /// **'Tour Itinerary'**
  String get tour_itinerary;

  /// Translation key: tour_locations_count
  ///
  /// In en, this message translates to:
  /// **'{n} locations'**
  String tour_locations_count(String n);

  /// Translation key: tour_no_locations
  ///
  /// In en, this message translates to:
  /// **'No locations available for this tour.'**
  String get tour_no_locations;

  /// Translation key: tour_none_in_filter
  ///
  /// In en, this message translates to:
  /// **'No tours in this category'**
  String get tour_none_in_filter;

  /// Translation key: tour_removed_offline
  ///
  /// In en, this message translates to:
  /// **'Tour removed from offline access'**
  String get tour_removed_offline;

  /// Translation key: download_offline
  ///
  /// In en, this message translates to:
  /// **'Download for Offline'**
  String get download_offline;

  /// Translation key: removed_offline
  ///
  /// In en, this message translates to:
  /// **'Removed from offline'**
  String get removed_offline;

  /// Translation key: tour_saved_offline
  ///
  /// In en, this message translates to:
  /// **'Tour saved for offline access!'**
  String get tour_saved_offline;

  /// Translation key: tour_start_nav
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get tour_start_nav;

  /// Translation key: tour_stops
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get tour_stops;

  /// Translation key: tour_stops_along
  ///
  /// In en, this message translates to:
  /// **'{n} stops along the way'**
  String tour_stops_along(String n);

  /// Translation key: tour_stops_count
  ///
  /// In en, this message translates to:
  /// **'{n} stops'**
  String tour_stops_count(String n);

  /// Translation key: tours_available
  ///
  /// In en, this message translates to:
  /// **'{n} tours available - all free'**
  String tours_available(String n);

  /// Translation key: tours_subtitle
  ///
  /// In en, this message translates to:
  /// **'Curated for you'**
  String get tours_subtitle;

  /// Translation key: tours_title
  ///
  /// In en, this message translates to:
  /// **'Guided Tours'**
  String get tours_title;

  /// Translation key: transport_bus_routes
  ///
  /// In en, this message translates to:
  /// **'Bus Routes'**
  String get transport_bus_routes;

  /// Translation key: transport_hero
  ///
  /// In en, this message translates to:
  /// **'Get around Alexandria with microbuses, buses, and taxis'**
  String get transport_hero;

  /// Translation key: transport_micro_desc
  ///
  /// In en, this message translates to:
  /// **'Shared 14-seater vans. Fixed routes, cheap.'**
  String get transport_micro_desc;

  /// Translation key: transport_micro_s1
  ///
  /// In en, this message translates to:
  /// **'Set routes'**
  String get transport_micro_s1;

  /// Translation key: transport_micro_s2
  ///
  /// In en, this message translates to:
  /// **'Wave to board'**
  String get transport_micro_s2;

  /// Translation key: transport_micro_title
  ///
  /// In en, this message translates to:
  /// **'Microbus (Servis)'**
  String get transport_micro_title;

  /// Translation key: transport_pro_tip
  ///
  /// In en, this message translates to:
  /// **'Pro tip: Microbuses (servis) are the cheapest way along the Corniche — wave to board, and pay the driver directly when you get off.'**
  String get transport_pro_tip;

  /// Translation key: transport_stops
  ///
  /// In en, this message translates to:
  /// **'Stops:'**
  String get transport_stops;

  /// Translation key: transport_taxi
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get transport_taxi;

  /// Translation key: transport_taxi_desc
  ///
  /// In en, this message translates to:
  /// **'Hail on the street or order by phone. Ask for the meter or agree the fare before you ride.'**
  String get transport_taxi_desc;

  /// Translation key: transport_taxi_price
  ///
  /// In en, this message translates to:
  /// **'Meter: EGP 7-10 base + EGP 3/km'**
  String get transport_taxi_price;

  /// Translation key: transport_taxi_s1
  ///
  /// In en, this message translates to:
  /// **'Available citywide'**
  String get transport_taxi_s1;

  /// Translation key: transport_taxi_s2
  ///
  /// In en, this message translates to:
  /// **'Black & yellow cabs'**
  String get transport_taxi_s2;

  /// Translation key: transport_taxi_section
  ///
  /// In en, this message translates to:
  /// **'Taxis & Microbuses'**
  String get transport_taxi_section;

  /// Translation key: transport_uber_desc
  ///
  /// In en, this message translates to:
  /// **'App-based. Cash or card. Surge pricing at peak hours.'**
  String get transport_uber_desc;

  /// Translation key: transport_uber_price
  ///
  /// In en, this message translates to:
  /// **'EGP 30-100+ depending on distance'**
  String get transport_uber_price;

  /// Translation key: transport_uber_s1
  ///
  /// In en, this message translates to:
  /// **'Download app'**
  String get transport_uber_s1;

  /// Translation key: transport_uber_s2
  ///
  /// In en, this message translates to:
  /// **'Set pickup & drop-off'**
  String get transport_uber_s2;

  /// Translation key: travel_journal
  ///
  /// In en, this message translates to:
  /// **'Travel Journal'**
  String get travel_journal;

  /// Translation key: travel_journal_sub
  ///
  /// In en, this message translates to:
  /// **'Save memories, notes & photos'**
  String get travel_journal_sub;

  /// Translation key: trip_clear_all
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get trip_clear_all;

  /// Translation key: trip_empty
  ///
  /// In en, this message translates to:
  /// **'Your trip is empty.\\nAdd places from the explore screen!'**
  String get trip_empty;

  /// Translation key: trip_places_planned
  ///
  /// In en, this message translates to:
  /// **'{n} Places Planned'**
  String trip_places_planned(String n);

  /// Translation key: trip_title
  ///
  /// In en, this message translates to:
  /// **'My Trip Planner'**
  String get trip_title;

  /// Translation key: try_different
  ///
  /// In en, this message translates to:
  /// **'Try a different name or category'**
  String get try_different;

  /// Translation key: undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Translation key: version
  ///
  /// In en, this message translates to:
  /// **'Version 2.0.0'**
  String get version;

  /// Translation key: visited
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visited;

  /// Translation key: weather_feels
  ///
  /// In en, this message translates to:
  /// **'feels {t}  · {h}% humidity'**
  String weather_feels(String t, String h);

  /// Translation key: weather_my_location
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get weather_my_location;

  /// Translation key: write_review
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get write_review;

  /// Translation key: ach_first_steps_name
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get ach_first_steps_name;

  /// Translation key: ach_first_steps_desc
  ///
  /// In en, this message translates to:
  /// **'Check in at your first place'**
  String get ach_first_steps_desc;

  /// Translation key: ach_explorer_5_name
  ///
  /// In en, this message translates to:
  /// **'Curious'**
  String get ach_explorer_5_name;

  /// Translation key: ach_explorer_5_desc
  ///
  /// In en, this message translates to:
  /// **'Visit 5 different places'**
  String get ach_explorer_5_desc;

  /// Translation key: ach_explorer_10_name
  ///
  /// In en, this message translates to:
  /// **'Adventurer'**
  String get ach_explorer_10_name;

  /// Translation key: ach_explorer_10_desc
  ///
  /// In en, this message translates to:
  /// **'Visit 10 different places'**
  String get ach_explorer_10_desc;

  /// Translation key: ach_explorer_25_name
  ///
  /// In en, this message translates to:
  /// **'Pathfinder'**
  String get ach_explorer_25_name;

  /// Translation key: ach_explorer_25_desc
  ///
  /// In en, this message translates to:
  /// **'Visit 25 different places'**
  String get ach_explorer_25_desc;

  /// Translation key: ach_lorekeeper_name
  ///
  /// In en, this message translates to:
  /// **'Lorekeeper'**
  String get ach_lorekeeper_name;

  /// Translation key: ach_lorekeeper_desc
  ///
  /// In en, this message translates to:
  /// **'Visit 42 places — the answer to everything'**
  String get ach_lorekeeper_desc;

  /// Translation key: ach_culture_buff_name
  ///
  /// In en, this message translates to:
  /// **'Culture Buff'**
  String get ach_culture_buff_name;

  /// Translation key: ach_culture_buff_desc
  ///
  /// In en, this message translates to:
  /// **'Visit 5 cultural spots'**
  String get ach_culture_buff_desc;

  /// Translation key: ach_history_nerd_name
  ///
  /// In en, this message translates to:
  /// **'History Nerd'**
  String get ach_history_nerd_name;

  /// Translation key: ach_history_nerd_desc
  ///
  /// In en, this message translates to:
  /// **'Visit 10 historical spots'**
  String get ach_history_nerd_desc;

  /// Translation key: ach_foodie_name
  ///
  /// In en, this message translates to:
  /// **'Foodie'**
  String get ach_foodie_name;

  /// Translation key: ach_foodie_desc
  ///
  /// In en, this message translates to:
  /// **'Check in at 3 food spots'**
  String get ach_foodie_desc;

  /// Translation key: ach_gourmet_name
  ///
  /// In en, this message translates to:
  /// **'Gourmet'**
  String get ach_gourmet_name;

  /// Translation key: ach_gourmet_desc
  ///
  /// In en, this message translates to:
  /// **'Check in at 8 food spots'**
  String get ach_gourmet_desc;

  /// Translation key: ach_shopaholic_name
  ///
  /// In en, this message translates to:
  /// **'Shopaholic'**
  String get ach_shopaholic_name;

  /// Translation key: ach_shopaholic_desc
  ///
  /// In en, this message translates to:
  /// **'Visit 3 shopping spots'**
  String get ach_shopaholic_desc;

  /// Translation key: ach_spiritual_seeker_name
  ///
  /// In en, this message translates to:
  /// **'Spiritual Seeker'**
  String get ach_spiritual_seeker_name;

  /// Translation key: ach_spiritual_seeker_desc
  ///
  /// In en, this message translates to:
  /// **'Visit 2 mosques'**
  String get ach_spiritual_seeker_desc;

  /// Translation key: ach_pilgrim_name
  ///
  /// In en, this message translates to:
  /// **'Pilgrim'**
  String get ach_pilgrim_name;

  /// Translation key: ach_pilgrim_desc
  ///
  /// In en, this message translates to:
  /// **'Visit 2 churches or holy sites'**
  String get ach_pilgrim_desc;

  /// Translation key: ach_streak_3_name
  ///
  /// In en, this message translates to:
  /// **'Warming Up'**
  String get ach_streak_3_name;

  /// Translation key: ach_streak_3_desc
  ///
  /// In en, this message translates to:
  /// **'3-day check-in streak'**
  String get ach_streak_3_desc;

  /// Translation key: ach_streak_7_name
  ///
  /// In en, this message translates to:
  /// **'On a Roll'**
  String get ach_streak_7_name;

  /// Translation key: ach_streak_7_desc
  ///
  /// In en, this message translates to:
  /// **'7-day check-in streak'**
  String get ach_streak_7_desc;

  /// Translation key: ach_streak_30_name
  ///
  /// In en, this message translates to:
  /// **'Devoted'**
  String get ach_streak_30_name;

  /// Translation key: ach_streak_30_desc
  ///
  /// In en, this message translates to:
  /// **'30-day check-in streak'**
  String get ach_streak_30_desc;

  /// Translation key: ach_streak_100_name
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get ach_streak_100_name;

  /// Translation key: ach_streak_100_desc
  ///
  /// In en, this message translates to:
  /// **'100-day check-in streak'**
  String get ach_streak_100_desc;

  /// Translation key: ach_hidden_gem_hunter_name
  ///
  /// In en, this message translates to:
  /// **'Hidden Gem Hunter'**
  String get ach_hidden_gem_hunter_name;

  /// Translation key: ach_hidden_gem_hunter_desc
  ///
  /// In en, this message translates to:
  /// **'Discover 3 hidden gems'**
  String get ach_hidden_gem_hunter_desc;

  /// Translation key: ach_reviewer_name
  ///
  /// In en, this message translates to:
  /// **'Reviewer'**
  String get ach_reviewer_name;

  /// Translation key: ach_reviewer_desc
  ///
  /// In en, this message translates to:
  /// **'Post 3 reviews'**
  String get ach_reviewer_desc;

  /// Translation key: ach_critic_name
  ///
  /// In en, this message translates to:
  /// **'Critic'**
  String get ach_critic_name;

  /// Translation key: ach_critic_desc
  ///
  /// In en, this message translates to:
  /// **'Post 10 reviews'**
  String get ach_critic_desc;

  /// Translation key: ach_photographer_name
  ///
  /// In en, this message translates to:
  /// **'Photographer'**
  String get ach_photographer_name;

  /// Translation key: ach_photographer_desc
  ///
  /// In en, this message translates to:
  /// **'Upload 5 photos'**
  String get ach_photographer_desc;

  /// Translation key: ach_influencer_name
  ///
  /// In en, this message translates to:
  /// **'Influencer'**
  String get ach_influencer_name;

  /// Translation key: ach_influencer_desc
  ///
  /// In en, this message translates to:
  /// **'Upload 20 photos'**
  String get ach_influencer_desc;

  /// Translation key: ach_early_bird_name
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get ach_early_bird_name;

  /// Translation key: ach_early_bird_desc
  ///
  /// In en, this message translates to:
  /// **'Check in at 5 places before 9 AM'**
  String get ach_early_bird_desc;

  /// Translation key: ach_night_owl_name
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get ach_night_owl_name;

  /// Translation key: ach_night_owl_desc
  ///
  /// In en, this message translates to:
  /// **'Check in at 5 places after 9 PM'**
  String get ach_night_owl_desc;

  /// Translation key: ach_completionist_name
  ///
  /// In en, this message translates to:
  /// **'Completionist'**
  String get ach_completionist_name;

  /// Translation key: ach_completionist_desc
  ///
  /// In en, this message translates to:
  /// **'Unlock 20 different achievements'**
  String get ach_completionist_desc;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

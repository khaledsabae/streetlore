// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about_app => 'About Streetlore';

  @override
  String get about_place => 'About this place';

  @override
  String get add => 'Add';

  @override
  String get add_photo_btn => 'Add Photo';

  @override
  String get add_photo_title => 'Add a photo';

  @override
  String get ai_add_all => 'Add all to Trip Planner';

  @override
  String ai_added_to_planner(String n) {
    return 'Added $n places to your Trip Planner';
  }

  @override
  String get ai_budget => 'Budget';

  @override
  String get ai_days => 'Days';

  @override
  String ai_days_count(String n) {
    return '$n days';
  }

  @override
  String get ai_err_empty => 'Please describe what kind of trip you want.';

  @override
  String ai_err_failed(String e) {
    return 'Failed to generate: $e';
  }

  @override
  String get ai_generate => 'Generate Itinerary';

  @override
  String get ai_generating => 'Generating...';

  @override
  String get ai_local_tips => 'Local tips';

  @override
  String get ai_planner_title => 'Smart Trip Planner';

  @override
  String get ai_prompt_hint =>
      'e.g. two days in Alexandria, mid-budget, love history';

  @override
  String get ai_prompt_title => 'Tell us about your trip';

  @override
  String get ai_sugg_1 =>
      'Two days in Alexandria, mid-budget, love history and seafood';

  @override
  String get ai_sugg_2 => 'One relaxed day focused on cafés and the corniche';

  @override
  String get ai_sugg_3 => 'Three days off the beaten path, hidden gems only';

  @override
  String get ai_sugg_4 => 'A family day with kid-friendly museums and a beach';

  @override
  String get all_places => 'All Places';

  @override
  String get badge_streak_10 => '10 Visits';

  @override
  String get badge_streak_25 => '25 Visits';

  @override
  String get badge_streak_5 => '5 Visits';

  @override
  String get badge_streak_50 => '50 Visits';

  @override
  String badge_unlocked(String name) {
    return 'Badge unlocked: $name 🏅';
  }

  @override
  String get badges_title => 'Badges';

  @override
  String get browse_tours => 'Browse Tours';

  @override
  String get bt_daylight => 'Daylight';

  @override
  String get bt_label_decent_now => 'Decent now';

  @override
  String get bt_label_go_now => 'Go now';

  @override
  String get bt_label_wait => 'Wait for a better window';

  @override
  String get bt_ranked_now => 'Ranked for right now';

  @override
  String get bt_reason_best_photos => 'Best for photos';

  @override
  String get bt_reason_breakfast => 'Breakfast spots';

  @override
  String get bt_reason_brunch => 'Brunch time';

  @override
  String get bt_reason_closed => 'Closed';

  @override
  String get bt_reason_closed_unsafe => 'Closed, unsafe';

  @override
  String get bt_reason_cool_empty => 'Cool & empty';

  @override
  String get bt_reason_cool_photo => 'Cool, photogenic';

  @override
  String get bt_reason_dinner => 'Dinner vibes';

  @override
  String get bt_reason_golden_hour => 'Golden hour magic';

  @override
  String get bt_reason_hot_crowd => 'Hot & crowded';

  @override
  String get bt_reason_hot_shaded => 'Hot but shaded';

  @override
  String get bt_reason_lunch => 'Lunch rush';

  @override
  String get bt_reason_often_closing => 'Often closing';

  @override
  String get bt_reason_quietest => 'Quietest, best light';

  @override
  String get bt_reason_admin_set => 'Set by admin';

  @override
  String get bt_reason_soft_light => 'Soft light';

  @override
  String get bt_reason_too_early => 'Too early';

  @override
  String get bt_reason_too_late => 'Too late';

  @override
  String get bt_reason_warm_ok => 'Warm but ok';

  @override
  String bt_sub_great(String day, String n, String s) {
    return '$day — $n place$s glowing right now';
  }

  @override
  String bt_sub_okay(String day, String n, String s) {
    return '$day — $n decent pick$s if you hurry';
  }

  @override
  String bt_sub_quiet(String day) {
    return '$day — quiet time, plan for later';
  }

  @override
  String get bt_sunrise => 'Sunrise';

  @override
  String get bt_sunset => 'Sunset';

  @override
  String get bt_title => 'Best Time to Visit';

  @override
  String get budget_friendly => 'Budget-friendly';

  @override
  String get cancel => 'Cancel';

  @override
  String get cat_all => 'All';

  @override
  String get cat_churches => 'Churches';

  @override
  String get cat_culture => 'Culture';

  @override
  String get cat_food => 'Food';

  @override
  String get cat_historical => 'Historical';

  @override
  String get cat_hotels => 'Hotels';

  @override
  String get cat_mosques => 'Mosques';

  @override
  String get cat_nature => 'Nature';

  @override
  String get cat_shopping => 'Shopping';

  @override
  String get chat_empty => 'Be the first to say hi';

  @override
  String get chat_hint => 'Say something to fellow travellers...';

  @override
  String get chat_live => 'Live chat';

  @override
  String get chat_now => 'now';

  @override
  String checked_in_streak(String n) {
    return 'Checked in! Streak: $n';
  }

  @override
  String get checkin => 'Check-in';

  @override
  String get checkin_removed => 'Check-in removed';

  @override
  String get choose_gallery => 'Choose from gallery';

  @override
  String get clear => 'Clear';

  @override
  String get clear_all_title => 'Clear All Saved Places?';

  @override
  String get clear_all_warning =>
      'This will permanently remove all saved places. This cannot be undone.';

  @override
  String get closed => 'Closed';

  @override
  String get community_chat => 'Community Chat';

  @override
  String get community_chat_sub => 'Ask travelers about this place';

  @override
  String get community_reviews => 'Community Reviews';

  @override
  String get compass_sub =>
      'Discover the city with a sweeping animated compass that grows into place.';

  @override
  String get compass_title => 'Compass direction';

  @override
  String get copy_link => 'Copy Link';

  @override
  String get cur_amount => 'Amount';

  @override
  String get cur_disclaimer =>
      'Rates are approximate and based on mid-market averages. Check with your bank or exchange for actual rates.';

  @override
  String get cur_enter_amount => 'Enter amount';

  @override
  String get cur_from => 'From';

  @override
  String get cur_to => 'To';

  @override
  String get currency_converter => 'Currency Converter';

  @override
  String get currency_converter_sub => 'EGP ↔ USD, EUR, GBP, SAR + more';

  @override
  String get dark_mode => 'Dark Mode';

  @override
  String get dark_theme_on => 'Dark theme enabled';

  @override
  String get day_fri => 'Fri';

  @override
  String get day_mon => 'Mon';

  @override
  String get day_sat => 'Sat';

  @override
  String get day_sun => 'Sun';

  @override
  String get day_thu => 'Thu';

  @override
  String get day_tue => 'Tue';

  @override
  String get day_wed => 'Wed';

  @override
  String get delete => 'Delete';

  @override
  String get delete_photo_q => 'Delete this photo?';

  @override
  String get delete_review_q => 'Delete this review?';

  @override
  String get discover => 'Discover';

  @override
  String get discover_places => 'Discover Places';

  @override
  String get edit => 'Edit';

  @override
  String get edit_name => 'Edit name';

  @override
  String get edit_name_dialog_title => 'Change your display name';

  @override
  String get egyptians => 'Egyptians';

  @override
  String get email => 'Email';

  @override
  String get emergency_info => 'Emergency Info';

  @override
  String get emergency_info_sub => 'Hospitals, embassies, hotlines';

  @override
  String emg_call_failed(String n) {
    return 'Cannot place call to $n';
  }

  @override
  String get emg_embassies => 'Embassies & Consulates';

  @override
  String get emg_hero_sub =>
      'Tap any number to call. Save this page for quick access.';

  @override
  String get emg_hero_title => 'Stay safe in Alexandria';

  @override
  String get emg_hospitals => 'Hospitals';

  @override
  String get emg_numbers => 'Emergency Numbers';

  @override
  String get emg_pharmacies => '24h Pharmacies';

  @override
  String get emg_title => 'Emergency';

  @override
  String get admin_title => 'Admin Panel';

  @override
  String get admin_forbidden => 'Admin only';

  @override
  String get admin_forbidden_sub =>
      'Your account is not authorised to add places.';

  @override
  String get admin_add_new => 'Add new place';

  @override
  String get admin_view_list => 'View places list';

  @override
  String get admin_field_name => 'Name';

  @override
  String get admin_field_category => 'Category';

  @override
  String get admin_field_address => 'Address';

  @override
  String get admin_field_description => 'Description';

  @override
  String get admin_field_image => 'Image';

  @override
  String get admin_field_hours => 'Open hours';

  @override
  String get admin_field_rating => 'Rating';

  @override
  String get admin_err_name => 'Name is required';

  @override
  String get admin_err_category =>
      'Category is required (e.g. ATM, Hotel, Cafe)';

  @override
  String get admin_err_address => 'Address is required';

  @override
  String get admin_submit => 'Add to map';

  @override
  String get admin_added => 'Added';

  @override
  String get admin_failed => 'Failed';

  @override
  String get admin_location_search =>
      'Location search (Nominatim / OpenStreetMap)';

  @override
  String get admin_location_search_hint =>
      'Type a place name or address (e.g. \"Bibliotheca Alexandrina\")';

  @override
  String get admin_location_no_results =>
      'No results. Try a more specific query.';

  @override
  String get admin_err_location =>
      'Pick a location from the search results first.';

  @override
  String get emg_transport => 'Transport';

  @override
  String get empty_saved_places_sub =>
      'Start exploring and tap the bookmark icon on any place to save it here for easy access.';

  @override
  String get empty_saved_tours_sub =>
      'Tap the download icon on any tour to save it here for offline access.';

  @override
  String get featured => 'Featured';

  @override
  String get filter_cheapest => 'Cheapest';

  @override
  String get filter_free => 'Free only';

  @override
  String get filter_hidden_gems => 'Hidden Gems';

  @override
  String get filter_nearest => 'Nearest';

  @override
  String get filter_open_now => 'Open Now';

  @override
  String get first_photo => 'Be the first to share a photo';

  @override
  String get foreigners => 'Foreigners';

  @override
  String get free_banner_sub =>
      'All tours, places & guides are unlocked for everyone.';

  @override
  String get free_banner_title => 'Everything is free';

  @override
  String get passion_banner_title => 'A compass for every story worth telling';

  @override
  String get passion_banner_sub =>
      'Your guide to the deepest stories behind every city. Free, ad-free, '
      'and made with care. Every recommendation here is written by someone '
      'who knows the place up close.';

  @override
  String get free_entry => 'Free entry';

  @override
  String get geo_choose_places => 'Choose places';

  @override
  String geo_distance(String d) {
    return '$d m from city center';
  }

  @override
  String get geo_hero_sub =>
      'Choose the places you want alerts for - within 500m by default.';

  @override
  String get geo_hero_title => 'Get notified nearby';

  @override
  String get geo_monitoring_off => 'Monitoring paused';

  @override
  String get geo_monitoring_on => 'Monitoring your location for nearby places';

  @override
  String get geo_title => 'Geofencing Alerts';

  @override
  String get go => 'Go';

  @override
  String get got_it => 'Got it';

  @override
  String get greet_afternoon => 'Good Afternoon';

  @override
  String get greet_evening => 'Good Evening';

  @override
  String get greet_morning => 'Good Morning';

  @override
  String get greet_night => 'Good night';

  @override
  String get guest_dialog_sub =>
      'Other travellers will see this name on the leaderboard. You can change it later.';

  @override
  String get guest_dialog_title => 'Pick a display name';

  @override
  String get help_center => 'Help Center';

  @override
  String get help_center_sub => 'FAQs and support';

  @override
  String get help_contact =>
      'For support, contact us at:\\nmohamedsabe50@gmail.com\\n\\nWe reply within 24 hours.';

  @override
  String get journal_add_first => 'Add first memory';

  @override
  String get journal_add_memory => 'Add memory';

  @override
  String journal_days_ago(String n) {
    return '$n days ago';
  }

  @override
  String get journal_edit_memory => 'Edit memory';

  @override
  String get journal_empty_sub =>
      'Save memories, photos, and notes for every place you visit.';

  @override
  String get journal_empty_title => 'Your travel journal is empty';

  @override
  String get journal_new_memory => 'New memory';

  @override
  String get journal_note_hint =>
      'What did you think? What did you do? Tips for other travelers?';

  @override
  String get journal_notes => 'Notes';

  @override
  String get journal_pick_place => 'Pick a place';

  @override
  String get journal_save_memory => 'Save memory';

  @override
  String get journal_search_hint => 'Search places...';

  @override
  String get journal_today => 'Today';

  @override
  String get journal_update_memory => 'Update memory';

  @override
  String get journal_yesterday => 'Yesterday';

  @override
  String get language => 'Language';

  @override
  String get lb_empty => 'No leaderboard data yet';

  @override
  String lb_points_level(String p, String l) {
    return '$p points · $l';
  }

  @override
  String lb_row_sub(String v, String r) {
    return '$v visited · $r reviews';
  }

  @override
  String get lb_subtitle => 'Most travelled around the world';

  @override
  String get lb_title => 'Leaderboard';

  @override
  String get lb_your_rank => 'YOUR RANK';

  @override
  String get level_cartographer => 'Cartographer';

  @override
  String get level_explorer => 'Explorer';

  @override
  String get level_lorekeeper => 'Lorekeeper';

  @override
  String get level_wanderer => 'Wanderer';

  @override
  String get light_theme_on => 'Light theme active';

  @override
  String get loading_tours => 'Loading tours...';

  @override
  String get loc_perm_blocked =>
      'Location is blocked. Enable it in Settings to get nearby alerts.';

  @override
  String get loc_service_off =>
      'Location services are off. Turn them on to see what is around you.';

  @override
  String get location_denied =>
      'Location permission denied. Enable it to see local weather.';

  @override
  String get location_services => 'Location Services';

  @override
  String get location_services_sub => 'Used for nearby recommendations';

  @override
  String get login_continue_guest => 'Continue as Guest';

  @override
  String get login_email => 'Email Address';

  @override
  String get login_email_hint => 'e.g. ahmed@example.com';

  @override
  String get login_err_email => 'Please enter your email';

  @override
  String get login_err_email_invalid => 'Please enter a valid email';

  @override
  String get login_err_name => 'Please enter your name';

  @override
  String get login_err_password_short =>
      'Password must be at least 6 characters';

  @override
  String get login_err_account_exists =>
      'An account with this email already exists. Try signing in.';

  @override
  String get login_err_no_account =>
      'No account found with this email. Tap Sign Up to create one.';

  @override
  String get login_err_wrong_password => 'Wrong password. Please try again.';

  @override
  String get login_err_unknown => 'Something went wrong. Please try again.';

  @override
  String get login_password => 'Password';

  @override
  String get login_password_hint => 'Enter your password';

  @override
  String get login_password_hint_signup => 'At least 6 characters';

  @override
  String get login_full_name => 'Full Name';

  @override
  String get login_google => 'Google';

  @override
  String get login_google_signed_in => 'Signed in with Google (local).';

  @override
  String get login_google_unavailable =>
      'Google sign-in unavailable. Use email or continue as guest.';

  @override
  String get login_google_timeout =>
      'Google sign-in took too long. Try again or use email.';

  @override
  String get login_google_failed =>
      'Google sign-in failed. Check your Supabase redirect URL settings.';

  @override
  String get login_have_account => 'Already have an account?';

  @override
  String get login_username => 'Username';

  @override
  String get login_username_hint => '3-20 chars: letters, digits, . _ -';

  @override
  String get login_err_username_empty => 'Please enter a username';

  @override
  String get login_err_username_length => 'Username must be 3-20 characters';

  @override
  String get login_err_username_chars =>
      'Only letters, digits, dot, underscore and dash';

  @override
  String get username_invalid =>
      'Invalid username (3-20 chars, letters/digits/._-)';

  @override
  String get login_no_account => 'No account yet?';

  @override
  String get login_sign_up => 'Sign Up';

  @override
  String get login_guest_name => 'Guest Explorer';

  @override
  String get login_just_exploring => 'Just exploring? ';

  @override
  String get login_name_hint => 'e.g. Ahmed Hassan';

  @override
  String get login_or => 'or';

  @override
  String get login_sign_in => 'Sign In';

  @override
  String get login_subtitle =>
      'Sign in to save your favorite places and access exclusive tours.';

  @override
  String get login_welcome => 'Welcome to\\nStreetlore';

  @override
  String get map_close => 'Close';

  @override
  String get map_err_location => 'Something went wrong while locating you.';

  @override
  String get map_err_location_denied =>
      'Location permission is required to show the route.';

  @override
  String get map_err_location_denied_forever =>
      'Location permission is permanently denied. Please enable it in Settings.';

  @override
  String get map_err_offline => 'Check your internet connection.';

  @override
  String get map_err_route => 'Failed to load the road route.';

  @override
  String get map_my_location => 'My location';

  @override
  String get map_open_details => 'Open details';

  @override
  String map_title(String n) {
    return 'Map · $n places';
  }

  @override
  String get map_view => 'Map View';

  @override
  String get map_view_sub => 'All places on interactive map';

  @override
  String get message => 'Message';

  @override
  String get nav_explore => 'Explore';

  @override
  String get nav_profile => 'Profile';

  @override
  String get nav_saved => 'Saved';

  @override
  String get nav_tours => 'Tours';

  @override
  String get nearby_gems => 'Nearby Hidden Gems';

  @override
  String get no_badges => 'Check in at places to earn badges';

  @override
  String get no_places => 'No places found';

  @override
  String no_results_for(String q) {
    return 'No results for \"$q\"';
  }

  @override
  String get no_reviews => 'No reviews yet. Be the first to share your story!';

  @override
  String get no_saved_places => 'No Saved Places';

  @override
  String get no_saved_tours => 'No Saved Tours';

  @override
  String get no_tours => 'No tours yet';

  @override
  String get ob_get_started => 'Get Started';

  @override
  String get ob_next => 'Next';

  @override
  String get ob_skip => 'Skip';

  @override
  String get ob_sub_1 =>
      'Uncover 30+ hidden gems and landmarks of Alexandria that most tourists never find.';

  @override
  String get ob_sub_2 =>
      'Choose from expertly curated tours. Navigate with ease and explore at your own pace.';

  @override
  String get ob_sub_3 =>
      'Build your personal travel collection. Save your favorite places and access them anytime.';

  @override
  String get ob_title_1 => 'Discover the Unseen';

  @override
  String get ob_title_2 => 'Plan Your Journey';

  @override
  String get ob_title_3 => 'Save & Revisit';

  @override
  String get offline_available => 'Available to download';

  @override
  String get offline_download => 'Download';

  @override
  String get offline_downloaded => 'Downloaded';

  @override
  String get offline_hero_title => 'Travel without signal';

  @override
  String offline_mb_downloaded(String n) {
    return '$n MB downloaded';
  }

  @override
  String offline_pack_size(String mb, String n) {
    return '$mb MB · $n places';
  }

  @override
  String get offline_title => 'Offline Mode';

  @override
  String get open_now => 'Open Now';

  @override
  String get open_settings => 'Open settings';

  @override
  String get photos => 'Photos';

  @override
  String places_count(String n) {
    return '$n places';
  }

  @override
  String get post_review => 'Post Review';

  @override
  String get prayer_asr => 'Asr';

  @override
  String get prayer_dhuhr => 'Dhuhr';

  @override
  String get prayer_fajr => 'Fajr';

  @override
  String get prayer_isha => 'Isha';

  @override
  String get prayer_load_failed => 'Failed to load prayer times';

  @override
  String get prayer_maghrib => 'Maghrib';

  @override
  String get prayer_sunrise => 'Sunrise';

  @override
  String get prayer_times => 'Prayer Times';

  @override
  String get prayer_times_sub => 'Daily prayer schedule for Alexandria';

  @override
  String get premium_experience => 'Premium experience';

  @override
  String get prof_explored => 'Explored';

  @override
  String get prof_saved => 'Saved';

  @override
  String get prof_tours => 'Tours';

  @override
  String get push_notif => 'Push Notifications';

  @override
  String get push_notif_sub => 'Get tips and discoveries';

  @override
  String get quick_ai_trip => 'AI Trip';

  @override
  String get quick_badges => 'Badges';

  @override
  String get quick_best_time => 'Best Time';

  @override
  String get best_time_admin_hint => 'Set by the editorial team';

  @override
  String get quick_chat => 'Live Chat';

  @override
  String get quick_journal => 'Journal';

  @override
  String get quick_map => 'Map';

  @override
  String get quick_offline => 'Offline';

  @override
  String get quick_prayer => 'Prayer';

  @override
  String get quick_ranking => 'Ranking';

  @override
  String get quick_routes => 'Routes';

  @override
  String get quick_transport => 'Transport';

  @override
  String get rate_app => 'Rate Streetlore';

  @override
  String get rate_app_sub => 'Share your experience';

  @override
  String get rate_thanks => 'Thank you for your support! ';

  @override
  String get rating_label => 'Rating';

  @override
  String get refresh => 'Refresh';

  @override
  String get remove => 'Remove';

  @override
  String removed_from_saved(String name) {
    return '$name removed from saved places';
  }

  @override
  String results_for(String n, String q) {
    return '$n results for \"$q\"';
  }

  @override
  String get review_empty_warn => 'Please write a comment first';

  @override
  String get review_failed => 'Could not post review';

  @override
  String get review_hint => 'Share your experience...';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get saved_cleared => 'All saved places cleared.';

  @override
  String get saved_collection => 'Your collection';

  @override
  String saved_count(String n) {
    return '$n saved';
  }

  @override
  String get saved_title => 'Saved';

  @override
  String get search_hint => 'Search places, landmarks...';

  @override
  String get section_about => 'About';

  @override
  String get section_app_settings => 'App Settings';

  @override
  String get see_all => 'See all';

  @override
  String get share_app => 'Share Streetlore';

  @override
  String get sign_in_continue => 'Continue';

  @override
  String get sign_out => 'Sign Out';

  @override
  String get sign_out_q => 'Sign Out?';

  @override
  String get sign_out_sub =>
      'Are you sure you want to sign out? Your saved places will be preserved.';

  @override
  String get standard_ticket => 'Standard ticket';

  @override
  String get stat_reviews => 'Reviews';

  @override
  String get stat_visited => 'Visited';

  @override
  String get streak_begin => 'Check in at any place to begin';

  @override
  String streak_best(String b, String t, String s) {
    return 'Best: $b · $t day$s total';
  }

  @override
  String streak_days(String n) {
    return '$n visits streak';
  }

  @override
  String get streak_start => 'Start your streak';

  @override
  String get swipe_remove_hint => '<- Swipe left to remove';

  @override
  String get switch_explore => 'Switch to the Explore tab to discover places!';

  @override
  String get switch_tours => 'Switch to the Tours tab to discover tours!';

  @override
  String get tab_places => 'Places';

  @override
  String get tab_tours => 'Tours';

  @override
  String get take_photo => 'Take photo';

  @override
  String get tour_about => 'About this Tour';

  @override
  String get tour_access => 'Access';

  @override
  String get tour_duration => 'Duration';

  @override
  String get tour_filter_all => 'All';

  @override
  String get tour_filter_full => 'Full day';

  @override
  String get tour_filter_half => 'Half day';

  @override
  String get tour_filter_short => 'Up to 3h';

  @override
  String get tour_free => 'Free';

  @override
  String tour_guide_hint(String name) {
    return 'Ask about $name...';
  }

  @override
  String get tour_itinerary => 'Tour Itinerary';

  @override
  String tour_locations_count(String n) {
    return '$n locations';
  }

  @override
  String get tour_no_locations => 'No locations available for this tour.';

  @override
  String get tour_none_in_filter => 'No tours in this category';

  @override
  String get tour_removed_offline => 'Tour removed from offline access';

  @override
  String get download_offline => 'Download for Offline';

  @override
  String get removed_offline => 'Removed from offline';

  @override
  String get tour_saved_offline => 'Tour saved for offline access!';

  @override
  String get tour_start_nav => 'Start Navigation';

  @override
  String get tour_stops => 'Stops';

  @override
  String tour_stops_along(String n) {
    return '$n stops along the way';
  }

  @override
  String tour_stops_count(String n) {
    return '$n stops';
  }

  @override
  String tours_available(String n) {
    return '$n tours available - all free';
  }

  @override
  String get tours_subtitle => 'Curated for you';

  @override
  String get tours_title => 'Guided Tours';

  @override
  String get transport_bus_routes => 'Bus Routes';

  @override
  String get transport_hero =>
      'Get around Alexandria with microbuses, buses, and taxis';

  @override
  String get transport_micro_desc =>
      'Shared 14-seater vans. Fixed routes, cheap.';

  @override
  String get transport_micro_s1 => 'Set routes';

  @override
  String get transport_micro_s2 => 'Wave to board';

  @override
  String get transport_micro_title => 'Microbus (Servis)';

  @override
  String get transport_pro_tip =>
      'Pro tip: Microbuses (servis) are the cheapest way along the Corniche — wave to board, and pay the driver directly when you get off.';

  @override
  String get transport_stops => 'Stops:';

  @override
  String get transport_taxi => 'Taxi';

  @override
  String get transport_taxi_desc =>
      'Hail on the street or order by phone. Ask for the meter or agree the fare before you ride.';

  @override
  String get transport_taxi_price => 'Meter: EGP 7-10 base + EGP 3/km';

  @override
  String get transport_taxi_s1 => 'Available citywide';

  @override
  String get transport_taxi_s2 => 'Black & yellow cabs';

  @override
  String get transport_taxi_section => 'Taxis & Microbuses';

  @override
  String get transport_uber_desc =>
      'App-based. Cash or card. Surge pricing at peak hours.';

  @override
  String get transport_uber_price => 'EGP 30-100+ depending on distance';

  @override
  String get transport_uber_s1 => 'Download app';

  @override
  String get transport_uber_s2 => 'Set pickup & drop-off';

  @override
  String get travel_journal => 'Travel Journal';

  @override
  String get travel_journal_sub => 'Save memories, notes & photos';

  @override
  String get trip_clear_all => 'Clear All';

  @override
  String get trip_empty =>
      'Your trip is empty.\\nAdd places from the explore screen!';

  @override
  String trip_places_planned(String n) {
    return '$n Places Planned';
  }

  @override
  String get trip_title => 'My Trip Planner';

  @override
  String get try_different => 'Try a different name or category';

  @override
  String get undo => 'Undo';

  @override
  String get version => 'Version 2.0.0';

  @override
  String get visited => 'Visited';

  @override
  String weather_feels(String t, String h) {
    return 'feels $t  · $h% humidity';
  }

  @override
  String get weather_my_location => 'Use my location';

  @override
  String get write_review => 'Write Review';

  @override
  String get ach_first_steps_name => 'First Steps';

  @override
  String get ach_first_steps_desc => 'Check in at your first place';

  @override
  String get ach_explorer_5_name => 'Curious';

  @override
  String get ach_explorer_5_desc => 'Visit 5 different places';

  @override
  String get ach_explorer_10_name => 'Adventurer';

  @override
  String get ach_explorer_10_desc => 'Visit 10 different places';

  @override
  String get ach_explorer_25_name => 'Pathfinder';

  @override
  String get ach_explorer_25_desc => 'Visit 25 different places';

  @override
  String get ach_lorekeeper_name => 'Lorekeeper';

  @override
  String get ach_lorekeeper_desc =>
      'Visit 42 places — the answer to everything';

  @override
  String get ach_culture_buff_name => 'Culture Buff';

  @override
  String get ach_culture_buff_desc => 'Visit 5 cultural spots';

  @override
  String get ach_history_nerd_name => 'History Nerd';

  @override
  String get ach_history_nerd_desc => 'Visit 10 historical spots';

  @override
  String get ach_foodie_name => 'Foodie';

  @override
  String get ach_foodie_desc => 'Check in at 3 food spots';

  @override
  String get ach_gourmet_name => 'Gourmet';

  @override
  String get ach_gourmet_desc => 'Check in at 8 food spots';

  @override
  String get ach_shopaholic_name => 'Shopaholic';

  @override
  String get ach_shopaholic_desc => 'Visit 3 shopping spots';

  @override
  String get ach_spiritual_seeker_name => 'Spiritual Seeker';

  @override
  String get ach_spiritual_seeker_desc => 'Visit 2 mosques';

  @override
  String get ach_pilgrim_name => 'Pilgrim';

  @override
  String get ach_pilgrim_desc => 'Visit 2 churches or holy sites';

  @override
  String get ach_streak_3_name => 'Warming Up';

  @override
  String get ach_streak_3_desc => '3-day check-in streak';

  @override
  String get ach_streak_7_name => 'On a Roll';

  @override
  String get ach_streak_7_desc => '7-day check-in streak';

  @override
  String get ach_streak_30_name => 'Devoted';

  @override
  String get ach_streak_30_desc => '30-day check-in streak';

  @override
  String get ach_streak_100_name => 'Legend';

  @override
  String get ach_streak_100_desc => '100-day check-in streak';

  @override
  String get ach_hidden_gem_hunter_name => 'Hidden Gem Hunter';

  @override
  String get ach_hidden_gem_hunter_desc => 'Discover 3 hidden gems';

  @override
  String get ach_reviewer_name => 'Reviewer';

  @override
  String get ach_reviewer_desc => 'Post 3 reviews';

  @override
  String get ach_critic_name => 'Critic';

  @override
  String get ach_critic_desc => 'Post 10 reviews';

  @override
  String get ach_photographer_name => 'Photographer';

  @override
  String get ach_photographer_desc => 'Upload 5 photos';

  @override
  String get ach_influencer_name => 'Influencer';

  @override
  String get ach_influencer_desc => 'Upload 20 photos';

  @override
  String get ach_early_bird_name => 'Early Bird';

  @override
  String get ach_early_bird_desc => 'Check in at 5 places before 9 AM';

  @override
  String get ach_night_owl_name => 'Night Owl';

  @override
  String get ach_night_owl_desc => 'Check in at 5 places after 9 PM';

  @override
  String get ach_completionist_name => 'Completionist';

  @override
  String get ach_completionist_desc => 'Unlock 20 different achievements';
}

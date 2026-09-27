// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get about_app => 'عن ستريت لور';

  @override
  String get about_place => 'عن هذا المكان';

  @override
  String get add => 'أضف';

  @override
  String get add_photo_btn => 'أضف صورة';

  @override
  String get add_photo_title => 'أضف صورة';

  @override
  String get ai_add_all => 'ضيف الكل لمخطط الرحلة';

  @override
  String ai_added_to_planner(String n) {
    return 'اتضاف $n مكان لمخطط رحلتك';
  }

  @override
  String get ai_budget => 'الميزانية';

  @override
  String get ai_days => 'الأيام';

  @override
  String ai_days_count(String n) {
    return '$n يوم';
  }

  @override
  String get ai_err_empty => 'من فضلك صف نوع الرحلة اللي عايزها.';

  @override
  String ai_err_failed(String e) {
    return 'فشل التوليد: $e';
  }

  @override
  String get ai_generate => 'خطّط رحلتي';

  @override
  String get ai_generating => 'جارٍ التخطيط...';

  @override
  String get ai_local_tips => 'نصايح من أهل البلد';

  @override
  String get ai_planner_title => 'مخطط الرحلات الذكي';

  @override
  String get ai_prompt_hint =>
      'مثال: يومين في إسكندرية، ميزانية متوسطة، بحب التاريخ';

  @override
  String get ai_prompt_title => 'قولنا عن رحلتك';

  @override
  String get ai_sugg_1 =>
      'يومين في إسكندرية، ميزانية متوسطة، بحب التاريخ والسي فود';

  @override
  String get ai_sugg_2 => 'يوم واحد هادي على القهاوي والكورنيش';

  @override
  String get ai_sugg_3 => 'تلات أيام بعيد عن الزحمة، جواهر مخفية بس';

  @override
  String get ai_sugg_4 => 'يوم عائلي مع متاحف مناسبة للأطفال وشاطئ';

  @override
  String get all_places => 'كل الأماكن';

  @override
  String get badge_streak_10 => '10 زيارات';

  @override
  String get badge_streak_25 => '25 زيارة';

  @override
  String get badge_streak_5 => '5 زيارات';

  @override
  String get badge_streak_50 => '50 زيارة';

  @override
  String badge_unlocked(String name) {
    return 'شارة جديدة: $name 🏅';
  }

  @override
  String get badges_title => 'الشارات';

  @override
  String get browse_tours => 'تصفح الجولات';

  @override
  String get bt_daylight => 'النهار';

  @override
  String get bt_label_decent_now => 'كويس دلوقتي';

  @override
  String get bt_label_go_now => 'روح دلوقتي';

  @override
  String get bt_label_wait => 'استنى وقت أحسن';

  @override
  String get bt_ranked_now => 'مرتبة حسب الوقت الحالي';

  @override
  String get bt_reason_best_photos => 'أفضل وقت للصور';

  @override
  String get bt_reason_breakfast => 'وقت الفطار';

  @override
  String get bt_reason_brunch => 'وقت البرانش';

  @override
  String get bt_reason_closed => 'مقفول';

  @override
  String get bt_reason_closed_unsafe => 'مقفول ومش آمن';

  @override
  String get bt_reason_cool_empty => 'مناخس وفاضي';

  @override
  String get bt_reason_cool_photo => 'مناخس، وقت التصوير';

  @override
  String get bt_reason_dinner => 'وقت العشا';

  @override
  String get bt_reason_golden_hour => 'سحر الساعة الذهبية';

  @override
  String get bt_reason_hot_crowd => 'حر وزحمة';

  @override
  String get bt_reason_hot_shaded => 'حر بس في ضل';

  @override
  String get bt_reason_lunch => 'وقت الغدا';

  @override
  String get bt_reason_often_closing => 'بيقفل غالباً';

  @override
  String get bt_reason_quietest => 'أهدأ وقت وأفضل إضاءة';

  @override
  String get bt_reason_admin_set => 'محدد من الأدمن';

  @override
  String get bt_reason_soft_light => 'إضاءة هادية';

  @override
  String get bt_reason_too_early => 'بدري أوي';

  @override
  String get bt_reason_too_late => 'متأخر أوي';

  @override
  String get bt_reason_warm_ok => 'دافي بس مقبول';

  @override
  String bt_sub_great(String day, String n, String s) {
    return '$day — $n مكان متألق دلوقتي';
  }

  @override
  String bt_sub_okay(String day, String n, String s) {
    return '$day — $n اختيار كويس لو لحقت';
  }

  @override
  String bt_sub_quiet(String day) {
    return '$day — وقت هادي، خطط لبعدين';
  }

  @override
  String get bt_sunrise => 'الشروق';

  @override
  String get bt_sunset => 'الغروب';

  @override
  String get bt_title => 'أفضل وقت للزيارة';

  @override
  String get budget_friendly => 'مناسب للميزانية';

  @override
  String get cancel => 'إلغاء';

  @override
  String get cat_all => 'الكل';

  @override
  String get cat_churches => 'كنائس';

  @override
  String get cat_culture => 'ثقافة';

  @override
  String get cat_food => 'أكل';

  @override
  String get cat_historical => 'تاريخي';

  @override
  String get cat_hotels => 'الفنادق';

  @override
  String get cat_mosques => 'مساجد';

  @override
  String get cat_nature => 'طبيعة';

  @override
  String get cat_shopping => 'تسوق';

  @override
  String get chat_empty => 'كن أول واحد يقول أهلًا';

  @override
  String get chat_hint => 'قول حاجة للمسافرين اللي معاك...';

  @override
  String get chat_live => 'دردشة مباشرة';

  @override
  String get chat_now => 'الآن';

  @override
  String checked_in_streak(String n) {
    return 'تم تسجيل الزيارة! ستريك $n';
  }

  @override
  String get checkin => 'تسجيل زيارة';

  @override
  String get checkin_removed => 'تم إلغاء تسجيل الزيارة';

  @override
  String get choose_gallery => 'اختر من المعرض';

  @override
  String get clear => 'مسح';

  @override
  String get clear_all_title => 'مسح كل الأماكن المحفوظة؟';

  @override
  String get clear_all_warning =>
      'سيتم حذف كل الأماكن المحفوظة نهائيًا. لا يمكن التراجع عن هذا.';

  @override
  String get closed => 'مغلق';

  @override
  String get community_chat => 'دردشة المجتمع';

  @override
  String get community_chat_sub => 'اسأل المسافرين عن هذا المكان';

  @override
  String get community_reviews => 'تقييمات المجتمع';

  @override
  String get compass_sub => 'اكتشف المدينة ببوصلة متحركة تنساب إلى مكانها.';

  @override
  String get compass_title => 'اتجاه البوصلة';

  @override
  String get copy_link => 'نسخ الرابط';

  @override
  String get cur_amount => 'المبلغ';

  @override
  String get cur_disclaimer =>
      'الأسعار تقريبية ومبنية على متوسطات السوق. راجع البنك أو الصرافة للأسعار الفعلية.';

  @override
  String get cur_enter_amount => 'أدخل المبلغ';

  @override
  String get cur_from => 'من';

  @override
  String get cur_to => 'إلى';

  @override
  String get currency_converter => 'محوّل العملات';

  @override
  String get currency_converter_sub =>
      'جنيه ↔ دولار، يورو، إسترليني، ريال وأكثر';

  @override
  String get dark_mode => 'الوضع الداكن';

  @override
  String get dark_theme_on => 'الوضع الداكن مفعّل';

  @override
  String get day_fri => 'الجمعة';

  @override
  String get day_mon => 'الاتنين';

  @override
  String get day_sat => 'السبت';

  @override
  String get day_sun => 'الحد';

  @override
  String get day_thu => 'الخميس';

  @override
  String get day_tue => 'التلات';

  @override
  String get day_wed => 'الأربع';

  @override
  String get delete => 'حذف';

  @override
  String get delete_photo_q => 'حذف هذه الصورة؟';

  @override
  String get delete_review_q => 'حذف هذا التقييم؟';

  @override
  String get discover => 'اكتشف';

  @override
  String get discover_places => 'اكتشف الأماكن';

  @override
  String get edit => 'تعديل';

  @override
  String get edit_name => 'غيّر الاسم';

  @override
  String get edit_name_dialog_title => 'غيّر اسم العرض';

  @override
  String get egyptians => 'مصريون';

  @override
  String get email => 'بريد';

  @override
  String get emergency_info => 'معلومات الطوارئ';

  @override
  String get emergency_info_sub => 'مستشفيات وسفارات وخطوط ساخنة';

  @override
  String emg_call_failed(String n) {
    return 'تعذر الاتصال بـ $n';
  }

  @override
  String get emg_embassies => 'السفارات والقنصليات';

  @override
  String get emg_hero_sub =>
      'اضغط على أي رقم للاتصال. احفظ الصفحة دي للوصول السريع.';

  @override
  String get emg_hero_title => 'خلي بالك في إسكندرية';

  @override
  String get emg_hospitals => 'المستشفيات';

  @override
  String get emg_numbers => 'أرقام الطوارئ';

  @override
  String get emg_pharmacies => 'صيدليات ٢٤ ساعة';

  @override
  String get emg_title => 'الطوارئ';

  @override
  String get admin_title => 'لوحة الإدارة';

  @override
  String get admin_forbidden => 'للمشرفين فقط';

  @override
  String get admin_forbidden_sub => 'حسابك مش مخوّل بإضافة أماكن.';

  @override
  String get admin_add_new => 'إضافة مكان';

  @override
  String get admin_view_list => 'قائمة الأماكن';

  @override
  String get admin_field_name => 'الاسم';

  @override
  String get admin_field_category => 'الفئة';

  @override
  String get admin_field_address => 'العنوان';

  @override
  String get admin_field_description => 'الوصف';

  @override
  String get admin_field_image => 'الصورة';

  @override
  String get admin_field_hours => 'ساعات العمل';

  @override
  String get admin_field_rating => 'التقييم';

  @override
  String get admin_err_name => 'الاسم مطلوب';

  @override
  String get admin_err_category => 'الفئة مطلوبة (مثلاً ATM, Hotel, Cafe)';

  @override
  String get admin_err_address => 'العنوان مطلوب';

  @override
  String get admin_submit => 'أضف للخريطة';

  @override
  String get admin_added => 'اتضاف';

  @override
  String get admin_failed => 'فشل';

  @override
  String get emg_transport => 'المواصلات';

  @override
  String get empty_saved_places_sub =>
      'ابدأ الاستكشاف واضغط على أيقونة الحفظ في أي مكان لحفظه هنا للوصول السريع.';

  @override
  String get empty_saved_tours_sub =>
      'اضغط على أيقونة التحميل في أي جولة لحفظها هنا للوصول بدون إنترنت.';

  @override
  String get featured => 'مميز';

  @override
  String get filter_cheapest => 'الأرخص';

  @override
  String get filter_free => 'المجاني فقط';

  @override
  String get filter_hidden_gems => 'جواهر مخفية';

  @override
  String get filter_nearest => 'الأقرب';

  @override
  String get filter_open_now => 'مفتوح الآن';

  @override
  String get first_photo => 'كن أول من يشارك صورة';

  @override
  String get foreigners => 'أجانب';

  @override
  String get free_banner_sub => 'كل الجولات والأماكن والمرشدين متاحين للجميع.';

  @override
  String get free_banner_title => 'كل حاجة مجانية';

  @override
  String get passion_banner_title => 'مشروع شغف غير ربحي';

  @override
  String get passion_banner_sub =>
      'مبني بحب الإسكندرية — ولأجلك. ببلاش، بدون إعلانات، ومتعة بحتة. كل توصية مجمّعة يدويًا من حد فعلاً عايش هنا.';

  @override
  String get free_entry => 'دخول مجاني';

  @override
  String get geo_choose_places => 'اختار الأماكن';

  @override
  String geo_distance(String d) {
    return '$d م من وسط المدينة';
  }

  @override
  String get geo_hero_sub =>
      'اختار الأماكن اللي عايز تنبيهات لها - في نطاق ٥٠٠ متر افتراضيًا.';

  @override
  String get geo_hero_title => 'تنبيهات عند الاقتراب';

  @override
  String get geo_monitoring_off => 'المراقبة متوقفة';

  @override
  String get geo_monitoring_on => 'بنراقب موقعك للأماكن القريبة';

  @override
  String get geo_title => 'تنبيهات الموقع';

  @override
  String get go => 'اذهب';

  @override
  String get got_it => 'فهمت';

  @override
  String get greet_afternoon => 'مساء الخير';

  @override
  String get greet_evening => 'مساء الخير';

  @override
  String get greet_morning => 'صباح الخير';

  @override
  String get greet_night => 'ليلة سعيدة';

  @override
  String get guest_dialog_sub =>
      'المسافرين التانيين هيشوفوا الاسم ده في الترتيب. ممكن تغيّره بعدين.';

  @override
  String get guest_dialog_title => 'اختار اسم للعرض';

  @override
  String get help_center => 'مركز المساعدة';

  @override
  String get help_center_sub => 'أسئلة شائعة ودعم';

  @override
  String get help_contact =>
      'للدعم، تواصل معنا على:\\nmohamedsabe50@gmail.com\\n\\nنرد خلال 24 ساعة.';

  @override
  String get journal_add_first => 'أضف أول ذكرى';

  @override
  String get journal_add_memory => 'أضف ذكرى';

  @override
  String journal_days_ago(String n) {
    return 'منذ $n يوم';
  }

  @override
  String get journal_edit_memory => 'تعديل الذكرى';

  @override
  String get journal_empty_sub =>
      'احفظ الذكريات والصور والملاحظات لكل مكان تزوره.';

  @override
  String get journal_empty_title => 'يوميات سفرك فاضية';

  @override
  String get journal_new_memory => 'ذكرى جديدة';

  @override
  String get journal_note_hint =>
      'إيه رأيك؟ إيه اللي عملته؟ نصايح للمسافرين التانيين؟';

  @override
  String get journal_notes => 'ملاحظات';

  @override
  String get journal_pick_place => 'اختار مكانًا';

  @override
  String get journal_save_memory => 'احفظ الذكرى';

  @override
  String get journal_search_hint => 'ابحث عن أماكن...';

  @override
  String get journal_today => 'اليوم';

  @override
  String get journal_update_memory => 'حدّث الذكرى';

  @override
  String get journal_yesterday => 'أمس';

  @override
  String get language => 'اللغة';

  @override
  String get lb_empty => 'لا توجد بيانات للترتيب بعد';

  @override
  String lb_points_level(String p, String l) {
    return '$p نقطة · $l';
  }

  @override
  String lb_row_sub(String v, String r) {
    return '$v زيارة · $r تقييم';
  }

  @override
  String get lb_subtitle => 'الأكثر تنقلًا حول العالم';

  @override
  String get lb_title => 'الترتيب';

  @override
  String get lb_your_rank => 'ترتيبك';

  @override
  String get level_cartographer => 'رسّام خرائط';

  @override
  String get level_explorer => 'مستكشف';

  @override
  String get level_lorekeeper => 'حافظ الحكايات';

  @override
  String get level_wanderer => 'متجوّل';

  @override
  String get light_theme_on => 'الوضع الفاتح مفعّل';

  @override
  String get loading_tours => 'جارٍ تحميل الجولات...';

  @override
  String get loc_perm_blocked =>
      'تم رفض إذن الموقع. فعّله من الإعدادات عشان توصلك التنبيهات.';

  @override
  String get loc_service_off =>
      'خدمات الموقع مقفولة. شغّلها عشان تشوف اللي حواليك.';

  @override
  String get location_denied => 'تم رفض إذن الموقع. فعّله لعرض طقس منطقتك.';

  @override
  String get location_services => 'خدمات الموقع';

  @override
  String get location_services_sub => 'تُستخدم لاقتراح أماكن قريبة';

  @override
  String get login_continue_guest => 'ادخل كضيف';

  @override
  String get login_email => 'البريد الإلكتروني';

  @override
  String get login_email_hint => 'مثال: ahmed@example.com';

  @override
  String get login_err_email => 'من فضلك أدخل بريدك الإلكتروني';

  @override
  String get login_err_email_invalid => 'من فضلك أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get login_err_name => 'من فضلك أدخل اسمك';

  @override
  String get login_err_password_short =>
      'كلمة المرور لازم تكون 6 حروف على الأقل';

  @override
  String get login_err_account_exists =>
      'في حساب بالفعل بالإيميل ده. جرّب تسجّل دخول.';

  @override
  String get login_err_no_account =>
      'مفيش حساب بالإيميل ده. اعمل حساب جديد من تسجيل.';

  @override
  String get login_err_wrong_password => 'كلمة المرور غلط. حاول تاني.';

  @override
  String get login_err_unknown => 'حصل حاجة غلط. حاول تاني.';

  @override
  String get login_password => 'كلمة المرور';

  @override
  String get login_password_hint => 'اكتب كلمة مرورك';

  @override
  String get login_password_hint_signup => '6 حروف على الأقل';

  @override
  String get login_full_name => 'الاسم الكامل';

  @override
  String get login_google => 'جوجل';

  @override
  String get login_google_signed_in => 'تم تسجيل الدخول بجوجل (محلي).';

  @override
  String get login_google_unavailable =>
      'جوجل مش متاح دلوقتي. استخدم الإيميل أو كمّل كضيف.';

  @override
  String get login_google_timeout =>
      'تسجيل الدخول بجوجل استغرق وقت طويل. حاول تاني أو استخدم الإيميل.';

  @override
  String get login_google_failed =>
      'فشل تسجيل الدخول بجوجل. تأكد من إعدادات الـ redirect URL في Supabase.';

  @override
  String get login_have_account => 'عندك حساب بالفعل؟';

  @override
  String get login_username => 'اسم المستخدم';

  @override
  String get login_username_hint => '3-20 حرف: حروف وأرقام و . _ -';

  @override
  String get login_err_username_empty => 'من فضلك ادخل اسم المستخدم';

  @override
  String get login_err_username_length => 'اسم المستخدم لازم يكون 3 لـ 20 حرف';

  @override
  String get login_err_username_chars => 'حروف وأرقام و . _ - فقط';

  @override
  String get username_invalid =>
      'اسم المستخدم غير صالح (3-20 حرف، حروف/أرقام/._-)';

  @override
  String get login_no_account => 'مفيش حساب لسه؟';

  @override
  String get login_sign_up => 'إنشاء حساب';

  @override
  String get login_guest_name => 'مستكشف زائر';

  @override
  String get login_just_exploring => 'بتستكشف بس؟ ';

  @override
  String get login_name_hint => 'مثال: أحمد حسن';

  @override
  String get login_or => 'أو';

  @override
  String get login_sign_in => 'تسجيل الدخول';

  @override
  String get login_subtitle =>
      'سجّل دخولك لحفظ أماكنك المفضلة والوصول لجولات حصرية.';

  @override
  String get login_welcome => 'أهلًا بك في\\nستريت لور';

  @override
  String get map_close => 'إغلاق';

  @override
  String get map_err_location => 'حدث خطأ أثناء تحديد الموقع.';

  @override
  String get map_err_location_denied =>
      'يجب الموافقة على صلاحية الموقع لعرض المسار.';

  @override
  String get map_err_location_denied_forever =>
      'صلاحية الموقع مرفوضة دائماً، يرجى تفعيلها من الإعدادات.';

  @override
  String get map_err_offline => 'تأكد من اتصالك بالإنترنت.';

  @override
  String get map_err_route => 'فشل في تحميل مسار الطريق.';

  @override
  String get map_my_location => 'موقعي';

  @override
  String get map_open_details => 'افتح التفاصيل';

  @override
  String map_title(String n) {
    return 'الخريطة · $n مكان';
  }

  @override
  String get map_view => 'عرض الخريطة';

  @override
  String get map_view_sub => 'كل الأماكن على خريطة تفاعلية';

  @override
  String get message => 'رسالة';

  @override
  String get nav_explore => 'استكشاف';

  @override
  String get nav_profile => 'حسابي';

  @override
  String get nav_saved => 'المحفوظات';

  @override
  String get nav_tours => 'الجولات';

  @override
  String get nearby_gems => 'جواهر مخفية قريبة';

  @override
  String get no_badges => 'سجّل زياراتك للأماكن لتكسب الشارات';

  @override
  String get no_places => 'لا توجد أماكن';

  @override
  String no_results_for(String q) {
    return 'لا نتائج عن \"$q\"';
  }

  @override
  String get no_reviews => 'لا توجد تقييمات بعد. كن أول من يشارك قصته!';

  @override
  String get no_saved_places => 'لا توجد أماكن محفوظة';

  @override
  String get no_saved_tours => 'لا توجد جولات محفوظة';

  @override
  String get no_tours => 'لا توجد جولات بعد';

  @override
  String get ob_get_started => 'يلا نبدأ';

  @override
  String get ob_next => 'التالي';

  @override
  String get ob_skip => 'تخطَّ';

  @override
  String get ob_sub_1 =>
      'اكتشف أكتر من ٣٠ جوهرة مخفية ومعلم في إسكندرية معظم السياح مبيعرفوهاش.';

  @override
  String get ob_sub_2 =>
      'اختار من جولات مختارة بعناية. اتنقل بسهولة واستكشف على مزاجك.';

  @override
  String get ob_sub_3 =>
      'اعمل مجموعتك الخاصة. احفظ أماكنك المفضلة ووصلها في أي وقت.';

  @override
  String get ob_title_1 => 'اكتشف المخفي';

  @override
  String get ob_title_2 => 'خطط رحلتك';

  @override
  String get ob_title_3 => 'احفظ وارجع تاني';

  @override
  String get offline_available => 'متاحة للتحميل';

  @override
  String get offline_download => 'تحميل';

  @override
  String get offline_downloaded => 'المحمّلة';

  @override
  String get offline_hero_title => 'سافر من غير شبكة';

  @override
  String offline_mb_downloaded(String n) {
    return '$n ميجابايت محمّلة';
  }

  @override
  String offline_pack_size(String mb, String n) {
    return '$mb ميجابايت · $n مكان';
  }

  @override
  String get offline_title => 'الوضع دون اتصال';

  @override
  String get open_now => 'مفتوح الآن';

  @override
  String get open_settings => 'افتح الإعدادات';

  @override
  String get photos => 'الصور';

  @override
  String places_count(String n) {
    return '$n مكان';
  }

  @override
  String get post_review => 'انشر التقييم';

  @override
  String get prayer_asr => 'العصر';

  @override
  String get prayer_dhuhr => 'الظهر';

  @override
  String get prayer_fajr => 'الفجر';

  @override
  String get prayer_isha => 'العشاء';

  @override
  String get prayer_load_failed => 'فشل تحميل مواقيت الصلاة';

  @override
  String get prayer_maghrib => 'المغرب';

  @override
  String get prayer_sunrise => 'الشروق';

  @override
  String get prayer_times => 'مواقيت الصلاة';

  @override
  String get prayer_times_sub => 'مواعيد الصلاة اليومية للإسكندرية';

  @override
  String get premium_experience => 'تجربة مميزة';

  @override
  String get prof_explored => 'تم استكشافه';

  @override
  String get prof_saved => 'محفوظ';

  @override
  String get prof_tours => 'جولات';

  @override
  String get push_notif => 'الإشعارات';

  @override
  String get push_notif_sub => 'نصائح واكتشافات جديدة';

  @override
  String get quick_ai_trip => 'رحلة ذكية';

  @override
  String get quick_badges => 'إنجازات';

  @override
  String get quick_best_time => 'أفضل وقت';

  @override
  String get best_time_admin_hint => 'حددها فريق التحرير';

  @override
  String get quick_chat => 'دردشة مباشرة';

  @override
  String get quick_journal => 'اليوميات';

  @override
  String get quick_map => 'الخريطة';

  @override
  String get quick_offline => 'أوفلاين';

  @override
  String get quick_prayer => 'الصلاة';

  @override
  String get quick_ranking => 'الترتيب';

  @override
  String get quick_routes => 'مسارات';

  @override
  String get quick_transport => 'المواصلات';

  @override
  String get rate_app => 'قيّم ستريت لور';

  @override
  String get rate_app_sub => 'شاركنا تجربتك';

  @override
  String get rate_thanks => 'شكرًا لدعمك! ';

  @override
  String get rating_label => 'التقييم';

  @override
  String get refresh => 'تحديث';

  @override
  String get remove => 'إزالة';

  @override
  String removed_from_saved(String name) {
    return 'تمت إزالة $name من المحفوظات';
  }

  @override
  String results_for(String n, String q) {
    return '$n نتيجة عن \"$q\"';
  }

  @override
  String get review_empty_warn => 'من فضلك اكتب تعليقًا أولًا';

  @override
  String get review_failed => 'تعذر نشر التقييم';

  @override
  String get review_hint => 'شاركنا تجربتك...';

  @override
  String get save => 'حفظ';

  @override
  String get saved => 'محفوظ';

  @override
  String get saved_cleared => 'تم مسح كل الأماكن المحفوظة.';

  @override
  String get saved_collection => 'مجموعتك';

  @override
  String saved_count(String n) {
    return '$n محفوظ';
  }

  @override
  String get saved_title => 'المحفوظات';

  @override
  String get search_hint => 'ابحث عن أماكن أو معالم...';

  @override
  String get section_about => 'حول';

  @override
  String get section_app_settings => 'إعدادات التطبيق';

  @override
  String get see_all => 'عرض الكل';

  @override
  String get share_app => 'شارك ستريت لور';

  @override
  String get sign_in_continue => 'كمّل';

  @override
  String get sign_out => 'تسجيل الخروج';

  @override
  String get sign_out_q => 'تسجيل الخروج؟';

  @override
  String get sign_out_sub => 'هل أنت متأكد؟ أماكنك المحفوظة ستبقى كما هي.';

  @override
  String get standard_ticket => 'تذكرة عادية';

  @override
  String get stat_reviews => 'تقييمات';

  @override
  String get stat_visited => 'زيارات';

  @override
  String get streak_begin => 'سجّل زيارتك في أي مكان للبدء';

  @override
  String streak_best(String b, String t, String s) {
    return 'الأفضل: $b · إجمالي $t يوم';
  }

  @override
  String streak_days(String n) {
    return 'ستريك $n زيارة';
  }

  @override
  String get streak_start => 'ابدأ سلسلتك';

  @override
  String get swipe_remove_hint => '<- اسحب لليسار للإزالة';

  @override
  String get switch_explore => 'انتقل إلى تبويب استكشاف لاكتشاف الأماكن!';

  @override
  String get switch_tours => 'انتقل إلى تبويب الجولات لاكتشافها!';

  @override
  String get tab_places => 'أماكن';

  @override
  String get tab_tours => 'جولات';

  @override
  String get take_photo => 'التقط صورة';

  @override
  String get tour_about => 'عن هذه الجولة';

  @override
  String get tour_access => 'الدخول';

  @override
  String get tour_duration => 'المدة';

  @override
  String get tour_filter_all => 'الكل';

  @override
  String get tour_filter_full => 'يوم كامل';

  @override
  String get tour_filter_half => 'نصف يوم';

  @override
  String get tour_filter_short => 'حتى 3 ساعات';

  @override
  String get tour_free => 'مجاني';

  @override
  String tour_guide_hint(String name) {
    return 'اسأل عن $name...';
  }

  @override
  String get tour_itinerary => 'خط سير الجولة';

  @override
  String tour_locations_count(String n) {
    return '$n موقع';
  }

  @override
  String get tour_no_locations => 'لا توجد مواقع متاحة لهذه الجولة.';

  @override
  String get tour_none_in_filter => 'لا توجد جولات في هذه الفئة';

  @override
  String get tour_removed_offline => 'تمت إزالة الجولة من الوصول دون اتصال';

  @override
  String get download_offline => 'حمّل للوضع دون اتصال';

  @override
  String get removed_offline => 'تمت الإزالة من الوضع دون اتصال';

  @override
  String get tour_saved_offline => 'تم حفظ الجولة للوصول دون اتصال!';

  @override
  String get tour_start_nav => 'ابدأ التنقل';

  @override
  String get tour_stops => 'محطات';

  @override
  String tour_stops_along(String n) {
    return '$n محطة على الطريق';
  }

  @override
  String tour_stops_count(String n) {
    return '$n محطة';
  }

  @override
  String tours_available(String n) {
    return '$n جولة متاحة - كلها مجانية';
  }

  @override
  String get tours_subtitle => 'مختارة لك';

  @override
  String get tours_title => 'جولات إرشادية';

  @override
  String get transport_bus_routes => 'خطوط الأتوبيس';

  @override
  String get transport_hero =>
      'اتنقل في إسكندرية بالميكروباص والأتوبيس والتاكسي';

  @override
  String get transport_micro_desc =>
      'ميكروباص ١٤ راكب مشترك. خطوط ثابتة ورخيصة.';

  @override
  String get transport_micro_s1 => 'خطوط ثابتة';

  @override
  String get transport_micro_s2 => 'لوّح عشان تركب';

  @override
  String get transport_micro_title => 'ميكروباص (سيرفيس)';

  @override
  String get transport_pro_tip =>
      'نصيحة: الميكروباص (السيرفيس) أرخص وسيلة على الكورنيش — لوّح عشان تركب، وادفع للسواق مباشرة لما تنزل.';

  @override
  String get transport_stops => 'المحطات:';

  @override
  String get transport_taxi => 'تاكسي';

  @override
  String get transport_taxi_desc =>
      'اطلبه من الشارع أو بالتليفون. اطلب العداد أو اتفق على الأجرة قبل ما تركب.';

  @override
  String get transport_taxi_price => 'العداد: ٧-١٠ جنيه أساسي + ٣ جنيه لكل كم';

  @override
  String get transport_taxi_s1 => 'متاح في كل المدينة';

  @override
  String get transport_taxi_s2 => 'تاكسي أسود وأصفر';

  @override
  String get transport_taxi_section => 'التاكسي والميكروباص';

  @override
  String get transport_uber_desc =>
      'بالتطبيق. كاش أو كارت. أسعار أعلى في أوقات الذروة.';

  @override
  String get transport_uber_price => '٣٠-١٠٠+ جنيه حسب المسافة';

  @override
  String get transport_uber_s1 => 'حمّل التطبيق';

  @override
  String get transport_uber_s2 => 'حدد مكان الركوب والنزول';

  @override
  String get travel_journal => 'يوميات السفر';

  @override
  String get travel_journal_sub => 'احفظ الذكريات والملاحظات والصور';

  @override
  String get trip_clear_all => 'مسح الكل';

  @override
  String get trip_empty => 'رحلتك فاضية.\\nضيف أماكن من شاشة الاستكشاف!';

  @override
  String trip_places_planned(String n) {
    return '$n مكان مخطط';
  }

  @override
  String get trip_title => 'مخطط رحلتي';

  @override
  String get try_different => 'جرّب اسمًا أو فئة مختلفة';

  @override
  String get undo => 'تراجع';

  @override
  String get version => 'الإصدار 2.0.0';

  @override
  String get visited => 'تمت الزيارة';

  @override
  String weather_feels(String t, String h) {
    return 'الإحساس $t  · رطوبة $h%';
  }

  @override
  String get weather_my_location => 'استخدم موقعي';

  @override
  String get write_review => 'اكتب تقييمًا';

  @override
  String get ach_first_steps_name => 'الخطوات الأولى';

  @override
  String get ach_first_steps_desc => 'سجّل دخولك في أول مكان';

  @override
  String get ach_explorer_5_name => 'فضولي';

  @override
  String get ach_explorer_5_desc => 'زُر 5 أماكن مختلفة';

  @override
  String get ach_explorer_10_name => 'مغامر';

  @override
  String get ach_explorer_10_desc => 'زُر 10 أماكن مختلفة';

  @override
  String get ach_explorer_25_name => 'مستكشف';

  @override
  String get ach_explorer_25_desc => 'زُر 25 مكانًا مختلفًا';

  @override
  String get ach_lorekeeper_name => 'حارس التراث';

  @override
  String get ach_lorekeeper_desc => 'زُر 42 مكانًا — إجابة كل شيء';

  @override
  String get ach_culture_buff_name => 'ثقافة عالية';

  @override
  String get ach_culture_buff_desc => 'زُر 5 أماكن ثقافية';

  @override
  String get ach_history_nerd_name => 'مهووس بالتاريخ';

  @override
  String get ach_history_nerd_desc => 'زُر 10 أماكن تاريخية';

  @override
  String get ach_foodie_name => 'ذوّاق';

  @override
  String get ach_foodie_desc => 'سجّل دخولك في 3 أماكن أكل';

  @override
  String get ach_gourmet_name => 'خبير أكل';

  @override
  String get ach_gourmet_desc => 'سجّل دخولك في 8 أماكن أكل';

  @override
  String get ach_shopaholic_name => 'مدمن تسوق';

  @override
  String get ach_shopaholic_desc => 'زُر 3 أماكن تسوق';

  @override
  String get ach_spiritual_seeker_name => 'باحث روحي';

  @override
  String get ach_spiritual_seeker_desc => 'زُر مسجدين';

  @override
  String get ach_pilgrim_name => 'حاج';

  @override
  String get ach_pilgrim_desc => 'زُر كنيستين أو موقعين مقدسين';

  @override
  String get ach_streak_3_name => 'بداية دافئة';

  @override
  String get ach_streak_3_desc => 'سلسلة 3 أيام من تسجيل الدخول';

  @override
  String get ach_streak_7_name => 'على مَوجة';

  @override
  String get ach_streak_7_desc => 'سلسلة 7 أيام من تسجيل الدخول';

  @override
  String get ach_streak_30_name => 'مُخلِص';

  @override
  String get ach_streak_30_desc => 'سلسلة 30 يومًا من تسجيل الدخول';

  @override
  String get ach_streak_100_name => 'أسطورة';

  @override
  String get ach_streak_100_desc => 'سلسلة 100 يوم من تسجيل الدخول';

  @override
  String get ach_hidden_gem_hunter_name => 'صيّاد الجواهر المخفية';

  @override
  String get ach_hidden_gem_hunter_desc => 'اكتشف 3 جواهر مخفية';

  @override
  String get ach_reviewer_name => 'مُراجِع';

  @override
  String get ach_reviewer_desc => 'انشر 3 تقييمات';

  @override
  String get ach_critic_name => 'ناقد';

  @override
  String get ach_critic_desc => 'انشر 10 تقييمات';

  @override
  String get ach_photographer_name => 'مُصوِّر';

  @override
  String get ach_photographer_desc => 'ارفع 5 صور';

  @override
  String get ach_influencer_name => 'مؤثر';

  @override
  String get ach_influencer_desc => 'ارفع 20 صورة';

  @override
  String get ach_early_bird_name => 'طائر الفجر';

  @override
  String get ach_early_bird_desc => 'سجّل دخولك في 5 أماكن قبل 9 صباحًا';

  @override
  String get ach_night_owl_name => 'بومة الليل';

  @override
  String get ach_night_owl_desc => 'سجّل دخولك في 5 أماكن بعد 9 مساءً';

  @override
  String get ach_completionist_name => 'مُكتمِل';

  @override
  String get ach_completionist_desc => 'افتح 20 إنجازات مختلفة';
}

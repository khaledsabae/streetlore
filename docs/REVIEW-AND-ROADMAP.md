# StreetLore — مراجعة شاملة وخطة تطوير (حتى الإطلاق على Google Play)

> **تاريخ المراجعة:** 2026-10-04 · **النسخة المراجَعة:** `v1.0.63` (commit `6347156`)
> **المنهج:** قراءة كود فقط (الريبو + ريبو `streetlore-web-app`). **لم يُرسل أي طلب** لمشروع Supabase أو Gemini الحيين — كل نتايج قاعدة البيانات مأخوذة من ملفات SQL في الريبو، وممكن الحي يكون مختلف. قبل أي إصلاح على القاعدة قارِن بـ`select * from pg_policies;`.
> **الهدف المتفق عليه:** إطلاق عام على Google Play خلال 12 أسبوع.

---

## ⚡ افعل دي النهارده (قبل أي حاجة تانية)

1. **ألغِ (revoke) مفاتيح Gemini الخمسة** من Google AI Studio / Cloud Console. المفاتيح جوه كل APK منشور، وجوه `main.dart.js` في ريبو `streetlore-web-app` العام (base64 مش تشفير)، وفي تاريخ git بتاعه (commit `5b5749a`). أي حد يقدر يستخدمها على حسابك.
2. **اقفل الكتابة على `places` / `tours` / `tour_places` / bucket `place-images`** للأدمن بس (تفاصيل في PR-A). حاليًا **أي مستخدم عامل حساب** يقدر يعدّل أو يمسح أي مكان أو صورة.
3. **ماتنشرش APK جديد** بالـworkflow الحالي لحد ما المفاتيح تتشال من البيلد (PR-B).

---

## الملخص التنفيذي

التطبيق غني بالمزايا (خريطة، جولات، مرشد AI، إنجازات، أوقات صلاة، قبلة، أوفلاين، شات، لوحة صدارة) وشكله متشطّب، **لكن مش جاهز للنشر العام** لأربع أسباب:

| المحور | الحالة | ليه |
|---|---|---|
| الأمن | 🔴 | قاعدة البيانات مفتوحة للكتابة لأي مستخدم، مفاتيح AI منشورة، صلاحية الأدمن بتتحدد في التطبيق نفسه |
| سياسات Google Play | 🔴 | `com.example`، مافيش حذف حساب ولا سياسة خصوصية، شات عام بلا إبلاغ/حظر، APK مش AAB |
| صحة البيانات | 🟠 | طقس وهمي، مستخدمين وهميين في اللوحة، مراجعات "مجتمعية" محلية بس، حساب مسافة غلط |
| قابلية الصيانة | 🟠 | صفر تستات، CI من غير analyze/test، شاشات 800+ سطر، نظامين ترجمة، ~3 إصدارات في اليوم |

**الحاجات الكويسة:** dark mode، onboarding، guest mode، `allowBackup=false`، حسابات القبلة وأوقات الشروق/الغروب سليمة، وGemini **مابيستلمش** موقع المستخدم ولا إيميله.

---

## 1. النتايج التفصيلية

### 🔴 حرج

**C1 — أي مستخدم مسجّل يقدر يعدّل/يمسح الأماكن والجولات**
- `supabase_setup.sql:76-78` — سياسة `for all using (auth.role() = 'authenticated')` على `places` و`tours` و`tour_places`.
- التسجيل بيدخل المستخدم فورًا (`auth_provider.dart:246-256`)، ومفتاح anon عام بطبيعته.
- لوحة الأدمن (في التطبيق وفي `/admin` على GitHub Pages) بتكتب بنفس مفتاح anon — يعني الحماية الوحيدة هي إن الزرار مستخبي.
- تعليق `migrations/2026_09_30_place_image_urls.sql:28-32` إن "الأدمن بيكتب بـservice_role" **مش صحيح**.
- **الإصلاح:** جدول `admins(user_id)` + دالة `is_admin()` + سياسات الكتابة `using (public.is_admin())`.

**C2 — أي مستخدم مسجّل يرفع/يستبدل/يمسح أي ملف في bucket `place-images`**
- `supabase_setup.sql:90-92` — بلا تحقق مالك ولا حجم ولا نوع.
- **الإصلاح:** الكتابة للأدمن بس + `file_size_limit` و`allowed_mime_types` على الـbucket.

**C3 — مفاتيح Gemini منشورة**
- `release.yml` بيحط المفاتيح كـ`--dart-define` → بتتحرق جوه الـAPK. الـbase64 (`app_config.dart:10-33`) اتعمل صراحةً عشان يعدّي GitHub Push Protection، يعني مش حماية.
- نفس البيلد منشور كويب في `streetlore-web-app` (عام + تاريخه فيه نسخ قديمة).
- التدوير بين 5 مفاتيح عند 429/403 (`gemini_rest_client.dart:146-155, 184-208, 267-274`) = التفاف على حصة Google، وغالبًا مخالف لشروط الاستخدام.
- **الإصلاح:** Edge Function وسيط (PR-B) — مفتاح واحد على السيرفر، مافيش أي مفتاح في العميل.

**C4 — بيانات التوقيع**
- باسورد الـkeystore مكتوب نص في `android/app/build.gradle.kts:36-38` وفي `release.yml`.
- ملف `keystore_base64_for_github_secret.txt` اتكومت في `7a8a4f1` واتمسح في `6143303` (اتوصف إنه placeholder — **ماتحققتش من محتواه**؛ حجمه أصغر من keystore الإصدار الحالي، لكن عامله كأنه حقيقي).
- **الإصلاح:** keystore جديد للرفع على Play (upload key) + **Play App Signing**، والباسوردات من `key.properties`/secrets بس.

### 🟠 عالي

| # | المشكلة | الدليل | الإصلاح |
|---|---|---|---|
| H1 | الأدمن بيتحدد في العميل بـ`email.contains('mohamedsabae50')` — أي إيميل فيه الكلمة دي يبقى أدمن في الواجهة | `auth_provider.dart:44-57` | التحقق على السيرفر (`is_admin()`)، والواجهة تسأل السيرفر |
| H2 | **باسوردات نص صريح في SharedPreferences** — fallback محلي للتسجيل/الدخول بيشتغل مع أي خطأ غير متوقع (حتى انقطاع النت) | `auth_provider.dart:293-317` | يتشال بالكامل؛ لو مافيش نت → رسالة "تحقق من الاتصال" |
| H3 | النقاط واللوحة قابلة للغش: المستخدم بيكتب `total_points/badges/level` بنفسه، check-in بلا تحقق مسافة ولا قيد تفرّد، والدمج بياخد القيمة الأعلى | `supabase_setup.sql:163-166`، `gamification_provider.dart:86-88, 141-197`، `place_details_screen.dart:573` | اللوحة قراءة فقط؛ النقاط تتحسب في دالة `SECURITY DEFINER` على check-in بتحقق مسافة + `unique(user_id, place_id)` |
| H4 | مافيش حذف حساب (شرط Play) ولا سياسة خصوصية | `profile_screen.dart` (تسجيل خروج بس) | PR-E |
| H5 | الشات العام غالبًا **مابيوصلش للسيرفر أصلًا**: التطبيق بيبعت `text` و`id` نصي، والجدول متوقع `message` و`id` تلقائي؛ والخطأ متبلع | `chat_message.dart:30-38` ↔ `supabase_setup.sql:127-140`، `supabase_service.dart:61-64` | توحيد الحقول + `user_id`/`user_name` من السيرفر + حد طول + إبلاغ/حظر (شرط سياسة UGC في Play) |
| H6 | تكلفة AI بلا سقف: حتى 5 محاولات مدفوعة لكل طلب، الضيوف يستخدموه، مخطط الرحلات بيبعت الكتالوج مرتين، "سلسلة الـfallback" هي نفس الموديل | `gemini_rest_client.dart:13-15`، `ai_service.dart:177,185`، `general_ai_tour_guide_screen.dart:52` | الوسيط بحصة يومية لكل مستخدم + login إلزامي + نسخة واحدة من الكتالوج |

### 🟡 متوسط

- **M1 Prompt injection:** الـsystem prompt بيتلزق في نص المستخدم (`gemini_rest_client.dart:54,81`)، وأوصاف الأماكن (اللي أي حد يعدّلها حاليًا — C1) بتدخل البرومبت مباشرة. → `systemInstruction` منفصل.
- **M2 Deep link:** أي رابط داخل بيتسلّم لمعالج تسجيل الدخول (`main.dart:129-138`، `auth_provider.dart:200-208`)، ومافيش nonce في Google Sign-In (`auth_provider.dart:573`). → تحقق scheme/host + nonce.
- **M3 الجلسة:** التوكنات بتتنسخ في SharedPreferences (`auth_provider.dart:368-388`)، و`setSession` بياخد access token بدل refresh token (`:401`).
- **M4 تسريب في اللوج:** طباعة أول/آخر 4 حروف من المفاتيح في الإصدار (`gemini_rest_client.dart:61-63, 301-303`)، وعرض أخطاء الـAPI الخام للمستخدم (`ai_tour_guide_service.dart:204`).
- **M5 SQL:** view `tours_with_places` بصلاحيات المالك؛ `drop policy "Public read places"` في `2026_09_30_...sql:29` اسمه مش مطابق فمابيعملش حاجة؛ أعمدة الـstreak اللي التطبيق بيكتبها (`gamification_stats.dart:104-107`) مش موجودة في أي ميجريشن.
- **M6:** حد أدنى للباسورد 6 حروف (`auth_provider.dart:233`).

### 🐞 أخطاء وظيفية

| # | الخطأ | الدليل |
|---|---|---|
| B1 | **«مفتوح الآن» غلط لمعظم الأماكن:** `MockData.isOpenNow` بيتجاهل مواعيد المكان وبيفترض 9ص–6م للكل (مكان بيقفل 10م بيظهر مقفول 7م) | `mock_data.dart:105`، `place_details_screen.dart:156` |
| B1b | معادلة المسافة مكتوبة غلط (`(sin(dLat)/2)*sin(dLat/2)` بدل `sin(dLat/2)²`) — **لكن أثرها على مستوى المدينة مهمل** (2.315 كم في الحالتين)؛ بيظهر بس في المسافات الطويلة | `place_details_screen.dart:141,143` |
| B2 | الـoffline fallback عمره ما بيشتغل في الإقلاع البارد: `OfflineProvider.cachedFallback` بيتملى بس لما تفتح شاشة الأوفلاين، فالتطبيق بيرجع لبيانات mock بدل كاش المستخدم | `place_provider.dart:121,152,162`، `offline_mode_screen.dart:24` |
| B3 | 3 مصادر للأماكن بتندمج كل تحميل: Supabase + `mock_data` + 12 فندق hardcoded (بلا عربي)؛ وأي مكان برا مربع إسكندرية بيتشال بصمت؛ وفلتر «الأقرب» بيقيس من نقطة ثابتة مش GPS | `place_provider.dart:171,198-215,235-238,428`، `map_seed.dart:345-381` |
| B4 | تسريبات: حساس البوصلة + timer كل 2ث مابيقفوش (`compass_card.dart:80,116-122`)؛ قناة realtime لكل شات بتتفتح ومابتتقفلش (`chat_provider.dart:22-30`)؛ اشتراك `onAuthStateChange` مش متلغي (`auth_provider.dart:69`) | |
| B5 | الطقس **وهمي دايمًا** في الإصدار (24° صحو) لأن `OPENWEATHER_API_KEY` مش متمرر في `release.yml` | `weather_service.dart:58-64` |
| B6 | اللوحة بتعرض **مستخدمين وهميين** لو فاضية أو فشلت | `leaderboard_provider.dart:18-20` |
| B7 | المراجعات وصور المستخدمين "المجتمعية" محفوظة على الجهاز بس — ومع ذلك بتدي نقاط | `review_provider.dart:14-39`، `place_photos_provider.dart:32-54` |
| B8 | تنبيهات Android 13+ بتتبلع: `POST_NOTIFICATIONS` مش متعرّف؛ والـgeofencing شغال والتطبيق مفتوح بس؛ والتنبيه المكرر بيتكرر لو مكانين متداخلين | `AndroidManifest.xml:3-5`، `geofencing_service.dart:35,55-59,87-98` |
| B9 | مسارات «المشي» بتتحسب بملف `driving` | `routing_service.dart:21` |
| B10 | **أرقام الطوارئ:** "خفر السواحل" = 122 (ده رقم الشرطة)؛ وأرقام Careem/Uber تحتاج تأكيد | `emergency_screen.dart:452-477` |
| B11 | زاوية الفجر/العشاء في الـfallback المحلي 18°/17° بينما الهيئة المصرية 19.5°/17.5° | `prayer_times_service.dart:176-177` |
| B12 | `setState` بعد `await` من غير `mounted` | `place_details_screen.dart:587` |

### 🔵 سياسات الطرف التالت

- **بلاطات الخريطة:** `tile.openstreetmap.org` مش مخصص لاستخدام التطبيقات الكثيف، وUser-Agent مختلف بين الشاشات (`map_screen.dart:247` vs `map_view_screen.dart:192`)، و**مافيش attribution لـOSM** (إلزامي). → `RichAttributionWidget` + مزوّد tiles (MapTiler / Stadia / إلخ).
- **التوجيه:** خادم OSRM التجريبي العام (`router.project-osrm.org`) مش للإنتاج.
- **صور Wikimedia:** CC BY-SA تشترط ذكر المؤلف والرخصة — مش موجود؛ ومحمّل الصور بيتنكر كـChrome (`robust_image.dart:72-74`)؛ وبيسحب الأصل بالحجم الكامل (صورة 14MB). → حقلي `author/license` + سطر نسب + `/thumb/…/800px-`.
- **Nominatim** (`geocoding_service.dart:45`): User-Agent قديم وإيميل لازم يكون حقيقي. **أسعار العملة**: الـAPI المجاني بيطلب ذكر المصدر.

### ⚪ الجودة والصيانة

- **صفر تستات** و`release.yml` مابيشغّلش `flutter analyze` ولا `flutter test`، و`analysis_options.yaml` افتراضي.
- **نظامين ترجمة:** ملفات ARB + الكود المولّد (~270KB) **مش مستخدمين نهائي** (`AppLocalizations.of` = صفر استخدام خارج الملف المولّد)؛ اللي شغال `AppStrings` يدوي ~1000 سطر + نصوص hardcoded.
- **شاشات عملاقة:** `place_details_screen` (‏build() ≈ 845 سطر)، `profile_screen`، `login_screen`، `home_screen` — وفيها استدعاءات Supabase وSharedPreferences مباشرة.
- **مافيش طبقة repositories ولا DI:** singletons `.instance` في كل حتة، وتوصيل يدوي في `main.dart`.
- **أخطاء متبلعة:** `catch (_) {}` في 8+ أماكن، ومافيش crash reporting.
- **Hive:** صناديق بلا schema/version، و`jsonDecode` بلا try (`offline_storage_service.dart:66-72`) — قيد واحد فاسد يكسر القراءة كلها.
- **حزم متأخرة/مهجورة:** `google_generative_ai` (deprecated)، `hive` 2، `google_sign_in` 6، `geolocator` 10، `flutter_map` 6، `intl: any`، و`supabase` مكرر مع `supabase_flutter`. (اتأكد بـ`flutter pub outdated`.)
- **نظافة الريبو:** `downloads/` ~30MB صور مش مستخدمة؛ 17 ملف `.ps1` متكومت رغم إن `*.ps1` في `.gitignore`؛ نسخ مكررة `create_release_v1.0.3x.ps1`؛ سكربتات بتمسح سطور بأرقامها من مسار `D:/`؛ `strip_comments.ps1` مسح التعليقات وساب سطور فاضية؛ BOM في بعض الملفات؛ README قالب Flutter الافتراضي.
- **إقلاع بطيء:** awaits متسلسلة قبل `runApp` + سبلاش ثابت 5ث + تأخيرات مصطنعة (`home_screen.dart:79` 1.4ث، `login_screen.dart:89`).
- **إيقاع الإصدارات:** 63 إصدار في ~2.5 شهر (أحيانًا 3 في اليوم) من غير تستات = كل إصدار مقامرة.

---

## 2. خارطة الطريق (12 أسبوع)

### المرحلة 0 — وقف النزيف (الأيام 1-3)
| المهمة | المسؤول | معيار القبول |
|---|---|---|
| إلغاء مفاتيح Gemini الخمسة + مفتاح واحد جديد في secrets الفنكشن | محمد | المفاتيح القديمة بترجع 4xx من Google |
| PR-A (RLS) يتطبّق على الحي بعد مقارنة `pg_policies` وإضافة user_id الأدمن | كلود يكتب / محمد يطبّق | حساب تجريبي عادي **يفشل** في تعديل مكان أو رفع صورة؛ الأدمن ينجح |
| PR-B (وسيط AI) + إعادة بناء ريبو الويب بلا مفاتيح وتنضيف تاريخه | كلود / محمد | البحث في `main.dart.js` الجديد مايلاقيش المفاتيح؛ المرشد بيرد عبر الفنكشن |
| keystore جديد (upload key) — بلا باسورد في الكود | محمد | `build.gradle.kts` مافيهوش أي باسورد |

### المرحلة 1 — حواجز Google Play (الأسابيع 1-3)
| المهمة | المسؤول |
|---|---|
| PR-C: `applicationId` نهائي (مقترح `com.streetlore.app`) + AAB + Play App Signing + R8 بـkeep rules + `POST_NOTIFICATIONS` + target SDK المطلوب حاليًا | كلود + محمد (تسجيل الـpackage وSHA-1 الجديد في Google Cloud OAuth وredirect في Supabase) |
| PR-D: حذف fallback الباسورد، تقوية deep link وnonce والجلسة | كلود |
| PR-E: حذف الحساب (داخل التطبيق + صفحة ويب) + سياسة خصوصية | كلود + محمد (deploy + مراجعة النص) |
| الشات: إبلاغ + حظر + فلتر كلمات + حذف من الأدمن | محمد |
| attribution لـOSM وWikimedia + User-Agent صادق + thumbnails | محمد |
| مزود tiles + توجيه `foot` على خدمة مستضافة | محمد |
| الطقس بمفتاح حقيقي أو إخفاء الويدجت؛ حذف المستخدمين الوهميين | محمد |
| تصحيح أرقام الطوارئ + "آخر تحقق: تاريخ" | محمد |

### المرحلة 2 — أساس الجودة (الأسابيع 3-6)
- PR-F: إصلاح B1/B1b/B2/B4/B6/B8 + **أول تستات**:
  1. المسافة (`core/geo`) مقابل مسافات معروفة.
  2. ترتيب وفلترة الأماكن (`display_order`، الأرخص، المجاني، أقصى سعر).
  3. `OpeningHours.isOpenAt` (parsing مواعيد العمل الحقيقية).
  4. النقاط ومستويات الإنجازات (`GamificationStats.levelForPoints`، `AchievementCatalog`).
  5. `SunTimesService.compute` و`BestTimeService.recommend`.
- CI: `flutter analyze` + `flutter test` على كل PR، والبناء مايكملش لو فشلوا.
- Lints صارمة (`very_good_analysis` أو: `strict-casts`, `strict-inference`, `unawaited_futures`, `cancel_subscriptions`, `close_sinks`, `use_build_context_synchronously`).
- Crash reporting (Sentry أو Crashlytics).
- مصدر حقيقة واحد للأماكن (Supabase + كاش Hive) وحذف mock/الفنادق الثابتة من مسار الإنتاج.
- الترحيل لـARB وحذف `AppStrings` (والكود المولّد مايتكومتش).
- تنضيف الريبو: `downloads/`، السكربتات، BOM، README حقيقي.
- **انضباط الإصدارات:** إصدار أسبوعي على Internal Testing بدل إصدارات يومية.

### المرحلة 3 — المعمارية والأداء (الأسابيع 6-9)
- **الإبقاء على Provider** (الترحيل لـRiverpod مع غياب التستات مخاطرة كبيرة لمطوّر واحد).
- طبقة repositories + تمرير الاعتماديات بالـconstructor بدل `.instance`.
- تقسيم الشاشات العملاقة:

| الملف | التقسيم المقترح |
|---|---|
| `place_details_screen` | `PlaceDetailsController` (الزيارة/check-in) + `geo_utils` + ملف لكل قسم (مراجعات، قريب، سعر، أفضل وقت، مشاركة) |
| `profile_screen` | `SettingsProvider` + ويدجتس header/stats/settings/account |
| `login_screen` | form + social sign-in + painter الخلفية |
| `home_screen` | منطق الفلترة يطلع لدالة pure أو للـprovider |
| `admin_panel_screen` | يطلع من تطبيق المستخدمين لأداة منفصلة |

- الهيكل المستهدف:
```
lib/
  app/        bootstrap.dart (كل التوصيل في مكان واحد), theme/, router/
  core/       geo/, clock/, errors/, logging/, widgets/
  data/       sources/{remote,local}/, repositories/, models/
  features/<name>/{state,domain,ui}/
  l10n/       ARB فقط
test/         نفس شكل lib/
```
- Hive بـschema version واستعادة من الفساد (أو `hive_ce`).
- إقلاع متوازي، والسبلاش يخلص أول ما التهيئة تخلص، وإلغاء التأخيرات المصطنعة؛ احترام إعداد "تقليل الحركة"؛ تصغير صور الشعار (~1.9MB).
- تحديث الحزم المتأخرة واحدة واحدة مع التستات.

### المرحلة 4 — الإطلاق (الأسابيع 9-12)
- Closed testing: حسابات المطورين الشخصية الجديدة محتاجة عدد معين من المختبرين لمدة 14 يوم متصلة — **اتأكد من الرقم الحالي في Play Console**.
- Store listing عربي وإنجليزي + لقطات.
- Data Safety: الموقع، الصور، الشات، المحادثة مع AI، الحساب.
- تصنيف المحتوى، ثم production بإطلاق تدريجي (staged rollout).

### بعد الإطلاق — فرص المنتج
1. **خرائط أوفلاين + ملاحة مشي** — السائح غالبًا من غير باقة.
2. **قصص صوتية بتشتغل لما توصل المكان** (geofencing في الخلفية) — ده جوهر «القصص الخفية للمدينة».
3. **مجتمع حقيقي:** مراجعات وصور متزامنة بإشراف بدل المحلية.
4. **مدن أكتر:** `city_id` في البيانات → القاهرة، الأقصر، أسوان.
5. **بيانات حية:** مواعيد عمل وأسعار تذاكر حقيقية، وروابط حجز.
6. **تذكيرات** صلاة ومواعيد الرحلة.
7. **مشاركة خطط الرحلات** بروابط.

---

## 3. تقسيم الشغل

| الطرف | المسؤولية |
|---|---|
| **كلود** (عبر fork + PRs) | PR-A (RLS)، PR-B (وسيط AI)، PR-C (إصدار Android)، PR-D (Auth)، PR-E (حذف الحساب + الخصوصية)، PR-F (الأخطاء + التستات). ترتيب الدفع: A → B → D → C → E → F |
| **محمد** | أي تغيير على الأنظمة الحية (Supabase، Google Cloud، Play Console، ريبو الويب)، المفاتيح والـkeystore، مراجعة ودمج الـPRs، المحتوى والمزايا (الشات، الـattribution، الخرائط، الطقس، الطوارئ، الترجمة، تقسيم الشاشات) |

### حالة الـPRs (2026-10-04)
| PR | البند | يتدمج امتى |
|---|---|---|
| #2 | PR-A — RLS | أولًا، **بعد** تطبيق الميجريشن + إضافة نفسك في `admins` |
| #3 | PR-B — وسيط AI | بعد إلغاء المفاتيح + deploy الفنكشن |
| #4 | PR-D — Auth | في أي وقت |
| #5 | PR-C — Android/AAB | بعد #3 (مبني فوقه)، وبعد تجهيز الـsecrets وOAuth |
| #6 | PR-E — حذف الحساب + الخصوصية | بعد deploy الفنكشن وتعبئة `[CONTACT_EMAIL]` |
| #7 | PR-F — أخطاء + تستات | في أي وقت |

### ✅ قائمة أفعال محمد اليدوية
- [ ] إلغاء مفاتيح Gemini الخمسة وعمل مفتاح واحد جديد (يتحط في secrets الفنكشن بس)
- [ ] `select * from pg_policies;` على الحي ومقارنته بـPR-A قبل التطبيق
- [ ] إضافة الـuser_id بتاعك في جدول `admins`
- [ ] تطبيق ميجريشن PR-A في SQL Editor
- [ ] deploy لـEdge Functions (`ai-proxy`، `delete-account`) + `supabase secrets set`
- [ ] إعادة بناء `streetlore-web-app` بلا مفاتيح وتنضيف تاريخه
- [ ] keystore رفع جديد + تفعيل Play App Signing
- [ ] تسجيل الـpackage الجديد وSHA-1 في Google Cloud OAuth + redirect في Supabase
- [ ] تفعيل تأكيد الإيميل في Supabase Auth (مستحسن)
- [ ] الموافقة على تشغيل CI لـPRs الجاية من fork

---

*المراجعة اتعملت بمساعدة Claude Code. أي بند مكتوب عليه "ماتحققتش" أو "غالبًا" محتاج تأكيد على الحي قبل التصرف.*

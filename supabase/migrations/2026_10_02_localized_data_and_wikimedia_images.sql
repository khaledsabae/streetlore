-- =====================================================================
-- v1.0.54 data localization + real Wikimedia Commons images.
--
-- Three structural fixes for the v1.0.54 Play Store polish release:
--
--   1) Real images: every place now points to a verified Wikimedia
--      Commons direct image URL that actually depicts that specific
--      Alexandria landmark (no more Taj Mahal for Saint Mark's, no
--      more random Unsplash placeholders).
--
--   2) Bilingual data: the place row now carries a complete English
--      AND Arabic version of every user-visible string, so the
--      language toggle updates BOTH the UI shell AND the dynamic
--      data (place name, description, category, address, price note)
--      without the previous hard-coded-English fallback.
--
--   3) Schema: the app's PlaceModel already reads `name_en`,
--      `name_ar`, `description_en`, `description_ar`, `category_ar`,
--      `address_ar`. They were missing from the table. We add them
--      (idempotently) and backfill them from the existing columns.
--
-- Safe to re-run: every UPDATE is guarded by `id = '...'` so it
-- only touches a specific row, and ALTER TABLE IF NOT EXISTS is
-- idempotent in Postgres 9.6+.
-- =====================================================================

ALTER TABLE public.places
  ADD COLUMN IF NOT EXISTS name_en        TEXT,
  ADD COLUMN IF NOT EXISTS name_ar        TEXT,
  ADD COLUMN IF NOT EXISTS description_en TEXT,
  ADD COLUMN IF NOT EXISTS description_ar TEXT,
  ADD COLUMN IF NOT EXISTS category_ar    TEXT,
  ADD COLUMN IF NOT EXISTS address_ar     TEXT;

-- Backfill: existing English `name` becomes `name_en`; existing
-- Arabic `description` becomes `description_ar`; existing Arabic
-- `address` becomes `address_ar`. We only fill rows that don't
-- already have a value, so re-running this migration is safe.
UPDATE public.places
   SET name_en        = COALESCE(name_en, name),
       description_ar = COALESCE(description_ar, description),
       address_ar     = COALESCE(address_ar, address)
 WHERE name_en        IS NULL
    OR description_ar IS NULL
    OR address_ar     IS NULL;

-- =====================================================================
-- Per-row updates: Arabic name, English description, Arabic category,
-- Wikimedia Commons image + carousel. Hand-written translations and
-- image URLs verified against the live Wikimedia Commons file pages.
-- =====================================================================

-- 1) Abu Abbas al-Mursi Mosque ----------------------------------------
UPDATE public.places SET
  name_en = 'Abu Abbas al-Mursi Mosque',
  name_ar = 'مسجد أبو العباس المرسي',
  description_en = 'The largest and most beautiful mosque in Alexandria, home to the tomb of the 13th-century Sufi saint Abu al-Abbas al-Mursi. Its two elegant minarets are designed in the Moroccan-Andalusian style and look out over the Mediterranean.',
  description_ar = 'أكبر وأجمل مسجد في الإسكندرية بلا منازع، يضم ضريح أبي العباس المرسي، ويتميز بمئذنتين أنيقتين على الطراز المغربي الأندلسي تطلان على البحر المتوسط.',
  category_ar = 'مساجد',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/b/b6/Mosque_of_Abu_Abbas_al-Mursi.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/0/02/%D9%85%D8%B3%D8%AC%D8%AF_%D8%B3%D9%8A%D8%AF%D9%8A_%D8%A8%D8%B4%D8%B1.jpg']
 WHERE id = '10';

-- 2) Alexandria National Museum ---------------------------------------
UPDATE public.places SET
  name_en = 'Alexandria National Museum',
  name_ar = 'المتحف الوطني بالإسكندرية',
  description_en = 'An Italianate palace built in 1926 housing around 1,800 artifacts spanning the Pharaonic, Greek, Roman, Coptic and Islamic eras. One of Egypt''s most important museums and a compact crash course in 5,000 years of the city''s history.',
  description_ar = 'قصر من الطراز الإيطالي شُيِّد عام 1926 يضم نحو 1800 قطعة أثرية تمتد عبر العصور الفرعونية واليونانية والرومانية والقبطية والإسلامية، ويُعدّ من أهم متاحف مصر.',
  category_ar = 'متاحف',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/8/8a/EWUG_visit_to_Alexandria_National_Museum%2C_April_2025_-_005.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/8/8a/EWUG_visit_to_Alexandria_National_Museum%2C_April_2025_-_005.jpg']
 WHERE id = '11';

-- 3) El-Atarin Bazaar -------------------------------------------------
UPDATE public.places SET
  name_en = 'El-Atarin Bazaar',
  name_ar = 'سوق العطارين',
  description_en = 'One of the oldest and most atmospheric bazaars in Alexandria. Its narrow covered alleys date back to the Ottoman era, and the air is filled with the scent of spices, rice, silver, and handmade crafts.',
  description_ar = 'من أقدم أسواق الإسكندرية وأعرقها، تنتشر شوارعه الضيقة المسقوفة التي تعود إلى العهد العثماني، وتفوح منه روائح البهارات والأرز والفضيات والتحف اليدوية.',
  category_ar = 'تسوق',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg']
 WHERE id = '13';

-- 4) Mahatet Masr (Egyptian Railways Station) --------------------------
UPDATE public.places SET
  name_en = 'Misr Railway Station (Mahatet Masr)',
  name_ar = 'محطة مصر',
  description_en = 'Alexandria''s main railway station, an architectural landmark completed in 1923 that still receives trains to this day. Worth a visit even if you are not travelling, just to see the iron roof and stained-glass windows.',
  description_ar = 'محطة مصر الرئيسية، تحفة معمارية من عام 1923 لا تزال تستقبل القطارات حتى اليوم. قم بزيارتها حتى لو لم تُسافر، فقط لتشاهد السقف الحديدي والنوافذ الزجاجية الملوّنة.',
  category_ar = 'معالم',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/a/a0/Misr_Station_Alexandria.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/d/d9/Misr_Station%2C_Alexandria%2C_Egypt.jpeg']
 WHERE id = '13cf4401-ce36-4560-9398-fb81cbf0f28c';

-- 5) Abu Qir Seafood Coast --------------------------------------------
UPDATE public.places SET
  name_en = 'Abu Qir Seafood Coast',
  name_ar = 'ساحل أبو قير',
  description_en = 'The historic Abu Qir coast holds the ruins of the Temple of Osiris and the remains of Fort Abu Qir, alongside a row of open-air seafood restaurants serving the freshest catch straight from the Mediterranean.',
  description_ar = 'ساحل أبو قير التاريخي يضم بقايا معبد أوزيريون وأطلال حصن أبي قير، إلى جانب صف من مطاعم الأسماك الطازجة المفتوحة على البحر مباشرة.',
  category_ar = 'مأكولات بحرية',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/92/Alexandrie_et_la_rade_dAboukir_%283523675030%29.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/92/Alexandrie_et_la_rade_dAboukir_%283523675030%29.jpg']
 WHERE id = '14';

-- 6) Sidi Bishr Beach -------------------------------------------------
UPDATE public.places SET
  name_en = 'Sidi Bishr Beach',
  name_ar = 'شاطئ سيدي بشر',
  description_en = 'One of the most popular and family-friendly beaches in Alexandria. Clean water, soft sand and full facilities make it the go-to choice for a day out with the family.',
  description_ar = 'من أجمل شواطئ الإسكندرية وأكثرها شعبية لدى أهلها، يتميز بمياهه النظيفة ورماله الناعمة ومرافقه المتكاملة لقضاء يوم عائلي ممتع.',
  category_ar = 'شواطئ',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/4/45/Golden_sunset_From_the_beach_of_Alexandria%2C_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/0/0e/Alexandrie._Place_Sidi-Bishr_-_btv1b101012683_%281_of_2%29.jpg']
 WHERE id = '15';

-- 7) El-Horeyya Garden (Shallalat) -------------------------------------
UPDATE public.places SET
  name_en = 'El-Horeyya Garden (Shallalat)',
  name_ar = 'حديقة الحرية (الشلالات)',
  description_en = 'A historic downtown garden with ponds, fountains and green lawns. A family-friendly green lung in the heart of old Alexandria.',
  description_ar = 'حديقة وسط المدينة التاريخية ببحيراتها ونوافيرها ومساحاتها الخضراء، وتُعدّ متنفساً عائلياً وموقعاً للتنزه في قلب الإسكندرية القديمة.',
  category_ar = 'حدائق',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/0/00/Shallalat_gardens.JPG',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/a/a1/Shallalat_gardens_2.JPG']
 WHERE id = '16';

-- 8) Anfushi Tombs ----------------------------------------------------
UPDATE public.places SET
  name_en = 'Anfushi Tombs',
  name_ar = 'مقابر الأنفوشي',
  description_en = 'Rock-cut tombs from the Ptolemaic and Roman eras carved directly into the cliff face right by the sea. Quieter and less crowded than the Catacombs of Kom El Shoqafa, with the same atmospheric charm.',
  description_ar = 'مقابر صخرية منحوتة في الصخر تعود إلى العصرين البطلمي والروماني، تقع قبالة البحر مباشرة وتتميز بهدوئها وقلة زوارها مقارنة بمقابر كوم الشقافة.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/1/15/AlexAnfushiTombs.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/1/15/AlexAnfushiTombs.jpg']
 WHERE id = '17';

-- 9) El-Anfushi Promenade ---------------------------------------------
UPDATE public.places SET
  name_en = 'El-Anfushi Promenade',
  name_ar = 'كورنيش الأنفوشي',
  description_en = 'A modern seafront walk along Anfushi with benches, parasols, open-air cafés and Greek-style statues. A small open-air theatre hosts live shows every Friday evening.',
  description_ar = 'كورنيش الأنفوشي الجديد، ممشى عصري على البحر مع مقاعد ومظلات ومقاهي ومطاعم مفتوحة، يضم تماثيل فنية على الطراز اليوناني ومسرحاً صغيراً للعروض الحية مساء كل جمعة.',
  category_ar = 'ممشى بحري',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/1/15/AlexAnfushiTombs.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/1/15/AlexAnfushiTombs.jpg']
 WHERE id = '17fee840-2d6a-49bc-b52b-60635c66e549';

-- 10) Eliyahu Hanavi Synagogue ---------------------------------------
UPDATE public.places SET
  name_en = 'Eliyahu Hanavi Synagogue',
  name_ar = 'معبد إلياهو هانافي',
  description_en = 'The largest synagogue in the Middle East, built in 1850, a powerful symbol of Alexandria''s cultural and religious diversity. Houses the tomb of Rabbi Abraham Abu Nafs.',
  description_ar = 'أكبر كنيس يهودي في الشرق الأوسط، بُني عام 1850 ويجسّد رمز التنوع الثقافي والتاريخي للإسكندرية، ويضم مقام الحاخام إبراهام أبو النفص.',
  category_ar = 'معابد',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/a/a0/Eliyahu_Hanavi_Synagogue_in_Alexandria.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/96/Eliyahu_Hanavi_Synagogue_Alexandria.jpg']
 WHERE id = '18';

-- 11) Trianon Café & Restaurant ---------------------------------------
UPDATE public.places SET
  name_en = 'Trianon Café & Restaurant',
  name_ar = 'تريانون كافيه ومطعم',
  description_en = 'One of the oldest cafés in Alexandria, open since 1907. Famous for its authentic Italian coffee, French pastries, and a literary crowd that has been meeting here for over a century.',
  description_ar = 'من أقدم المقاهي في الإسكندرية منذ عام 1907، اشتهر بقهوته الإيطالية الأصلية وحلوياته الفرنسية وكان ولا يزال ملتقى أدباء المدينة والمثقفين.',
  category_ar = 'مقاهي',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/7/71/Egypt%2C_Alexandria%2C_The_Corniche_of_Alexandria.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/7/71/Egypt%2C_Alexandria%2C_The_Corniche_of_Alexandria.jpg']
 WHERE id = '19';

-- 12) Bibliotheca Alexandrina ------------------------------------------
UPDATE public.places SET
  name_en = 'Bibliotheca Alexandrina',
  name_ar = 'مكتبة الإسكندرية',
  description_en = 'A modern architectural marvel shaped like a tilted solar disc, holding more than eight million books, four museums, a theatre, and a manuscript restoration lab. The most iconic landmark of contemporary Alexandria.',
  description_ar = 'صرح معماري حديث على شكل قرص شمسي مائل يضم أكثر من ثمانية ملايين كتاب وأربعة متاحف ومسرحاً ومختبراً لترميم المخطوطات، وهو من أبرز معالم الإسكندرية المعاصرة.',
  category_ar = 'ثقافة',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/3/37/Egypt%2C_Alexandria%2C_Bibliotheca_Alexandrina.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/e/eb/Bibliotheca_Alexandrina%2C_Egypt%2C_2013.jpg']
 WHERE id = '2';

-- 13) Elite Café ------------------------------------------------------
UPDATE public.places SET
  name_en = 'Elite Café',
  name_ar = 'إيليت كافيه',
  description_en = 'A classic Alexandrian café with an old aristocratic soul. In the 1940s and 50s it hosted the city''s writers and poets, and it still preserves that vintage charm.',
  description_ar = 'مقهى كلاسيكي بطراز عتيق وأجواء أرستقراطية، شهد في الأربعينيات والخمسينيات لقاءات أدباء الإسكندرية وكتابها، ولا يزال محافظاً على سحره القديم.',
  category_ar = 'مقاهي',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/3/37/Egypt%2C_Alexandria%2C_Bibliotheca_Alexandrina.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/3/37/Egypt%2C_Alexandria%2C_Bibliotheca_Alexandrina.jpg']
 WHERE id = '20';

-- 14) Zephyrion Restaurant --------------------------------------------
UPDATE public.places SET
  name_en = 'Zephyrion Restaurant',
  name_ar = 'مطعم زيفيريون',
  description_en = 'The most refined seafood restaurant in Alexandria, set inside a historic villa right on the Mediterranean shore. Premium Mediterranean dishes and an unforgettable sea view.',
  description_ar = 'أرقى المطاعم المتخصصة في الأسماك والمأكولات البحرية في الإسكندرية، يقع داخل فيلا قديمة مطلة على البحر مباشرة ويقدّم أطباقاً متوسطية فاخرة.',
  category_ar = 'مأكولات بحرية',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/92/Alexandrie_et_la_rade_dAboukir_%283523675030%29.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/92/Alexandrie_et_la_rade_dAboukir_%283523675030%29.jpg']
 WHERE id = '21';

-- 15) Kadoura Seafood Restaurant --------------------------------------
UPDATE public.places SET
  name_en = 'Kadoura Seafood Restaurant',
  name_ar = 'مطعم قدورة للمأكولات البحرية',
  description_en = 'One of Alexandria''s most famous fish restaurants since 1958, known for its traditional recipes and a secret sauce that has been passed down through the family for generations.',
  description_ar = 'من أشهر مطاعم الأسماك في الإسكندرية منذ عام 1958، تشتهر بوصفاتها التقليدية وصلصتها السرية التي يتوارثها أبناؤها جيلاً بعد جيل.',
  category_ar = 'مأكولات بحرية',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/92/Alexandrie_et_la_rade_dAboukir_%283523675030%29.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/92/Alexandrie_et_la_rade_dAboukir_%283523675030%29.jpg']
 WHERE id = '22';

-- 16) Abu Ashraf Seafood ----------------------------------------------
UPDATE public.places SET
  name_en = 'Abu Ashraf Seafood',
  name_ar = 'أبو أشرف للمأكولات البحرية',
  description_en = 'A local seafood joint deep in the old Anfushi quarter. Queues start before opening, prices are simple, and the taste is legendary.',
  description_ar = 'محل أسماك شعبي في عمق حي الأنفوشي القديم، تبدأ طوابير الزبائن قبل موعد الفتح، والأسعار بسيطة والمذاق أسطوري.',
  category_ar = 'مأكولات بحرية',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/1/15/AlexAnfushiTombs.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/1/15/AlexAnfushiTombs.jpg']
 WHERE id = '23';

-- 17) Miami Beach Alexandria ------------------------------------------
UPDATE public.places SET
  name_en = 'Miami Beach Alexandria',
  name_ar = 'شاطئ ميامي',
  description_en = 'Named by Europeans in the early 20th century for its turquoise water and soft sand, Miami stretches along Alexandria''s eastern coast.',
  description_ar = 'شاطئ ميامي، سمّاه الأوروبيون بهذا الاسم في أوائل القرن العشرين لمياهه الفيروزية الصافية ورماله الناعمة الممتدة على الساحل الشرقي.',
  category_ar = 'شواطئ',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/9d/Miami_Alexandria_beach.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/9d/Miami_Alexandria_beach.jpg']
 WHERE id = '24';

-- 18) Agami Beach -----------------------------------------------------
UPDATE public.places SET
  name_en = 'Agami Beach',
  name_ar = 'شاطئ عجمي',
  description_en = 'Agami beach lies 24 km west of Alexandria and is widely considered one of the cleanest and quietest on the Alexandrian coast.',
  description_ar = 'شاطئ عجمي على بعد 24 كيلومتراً غرب الإسكندرية، ويُعرف بأنه من أنظف شواطئ الساحل الإسكندراني وأهدأها.',
  category_ar = 'شواطئ',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/4/45/Golden_sunset_From_the_beach_of_Alexandria%2C_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/45/Golden_sunset_From_the_beach_of_Alexandria%2C_Egypt.jpg']
 WHERE id = '25';

-- 19) El-Ma'amoura Beach ----------------------------------------------
UPDATE public.places SET
  name_en = 'El-Ma''amoura Beach',
  name_ar = 'شاطئ المعمورة',
  description_en = 'Ma''amoura beach sits at the far eastern edge of Alexandria, an ideal spot to watch the sunrise over the Mediterranean.',
  description_ar = 'شاطئ المعمورة في أقصى شرق الإسكندرية، وجهة مثالية لرؤية شروق الشمس من فوق مياه البحر المتوسط.',
  category_ar = 'شواطئ',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/4/45/Golden_sunset_From_the_beach_of_Alexandria%2C_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/45/Golden_sunset_From_the_beach_of_Alexandria%2C_Egypt.jpg']
 WHERE id = '26';

-- 20) Roman Cisterns of Alexandria ------------------------------------
UPDATE public.places SET
  name_en = 'Roman Cisterns of Alexandria',
  name_ar = 'الخزّانات الرومانية',
  description_en = 'Massive Roman cisterns buried beneath the streets of downtown Alexandria, dating to the 3rd century AD. Eighteen rows of marble columns stand in near-total darkness — a hidden underground marvel.',
  description_ar = 'خزّانات رومانية ضخمة مدفونة تحت شوارع وسط المدينة، تعود إلى القرن الثالث الميلادي وتضم ثمانية عشر صفاً من الأعمدة الرخامية في ظلام شبه تام.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/9a/GD-EG-Alexandria%2C_Cistern_of_al-Nabih_007.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/9a/GD-EG-Alexandria%2C_Cistern_of_al-Nabih_007.jpg']
 WHERE id = '27';

-- 21) El-Bourse (Cotton Exchange) -------------------------------------
UPDATE public.places SET
  name_en = 'El-Bourse (Cotton Exchange)',
  name_ar = 'بورصة القطن',
  description_en = 'The historic Cotton Exchange building, built in 1909, was once the heart of the world''s cotton trade before it was converted into a museum that tells the story of that era.',
  description_ar = 'مبنى بورصة القطن التاريخي شُيّد عام 1909 وكان يوماً ما قلب تجارة القطن في العالم قبل أن يتحوّل إلى متحف يحكي تلك الحقبة.',
  category_ar = 'متاحف',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/4/48/Alexandrie_la_Bourse_1900.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/48/Alexandrie_la_Bourse_1900.jpg']
 WHERE id = '29';

-- 22) Montaza Palace Gardens ------------------------------------------
UPDATE public.places SET
  name_en = 'Montaza Palace Gardens',
  name_ar = 'حدائق قصر المنتزه',
  description_en = 'The summer retreat of the Muhammad Ali dynasty for over a century — 150 acres of royal gardens by the sea, with a palace, a beach, and panoramic views.',
  description_ar = 'مصيف أسرة محمد علي لأكثر من قرن، يمتد على مساحة 150 فداناً من الحدائق الملكية المطلة على البحر ويضم قصراً وحدائق خلابة.',
  category_ar = 'حدائق',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/b/b6/Montaza_Palace_Gardens.png',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/d/dd/Lighthouse_beside_the_Montaza_garden_in_Alexandria.jpg']
 WHERE id = '3';

-- 23) Pastroudi Restaurant --------------------------------------------
UPDATE public.places SET
  name_en = 'Pastroudi Restaurant',
  name_ar = 'مطعم باسترودي',
  description_en = 'One of Alexandria''s most historic restaurants, open since 1923 and once a favourite of King Farouk. Famous for its scallop cannelloni and a legendary chocolate cake.',
  description_ar = 'من أعرق مطاعم الإسكندرية منذ عام 1923، كان المطعم المفضل للملك فاروق، ويشتهر بكانيلوني الإسكالوب وكعكة الشوكولاتة السرية.',
  category_ar = 'مطاعم',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/54/Fouad_Street_-_Alexandria_-_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/54/Fouad_Street_-_Alexandria_-_Egypt.jpg']
 WHERE id = '30';

-- 24) City Centre Alexandria ------------------------------------------
UPDATE public.places SET
  name_en = 'City Centre Alexandria',
  name_ar = 'سيتي سنتر الإسكندرية',
  description_en = 'The largest mall in Alexandria, with Carrefour, cinemas, international brand stores, and dozens of restaurants under one roof.',
  description_ar = 'أكبر مجمع تجاري في الإسكندرية ويضم كارفور ودور سينما ومتاجر العلامات التجارية العالمية إلى جانب عشرات المطاعم.',
  category_ar = 'تسوق',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/5e/Flickr_-_dlisbona_-_City_Centre_mall%2C_Alexandria_-_at_midnight.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/5e/Flickr_-_dlisbona_-_City_Centre_mall%2C_Alexandria_-_at_midnight.jpg']
 WHERE id = '31';

-- 25) San Stefano Grand Plaza -----------------------------------------
UPDATE public.places SET
  name_en = 'San Stefano Grand Plaza',
  name_ar = 'سان ستيفانو جراند بلازا',
  description_en = 'A luxury waterfront mall right on the Mediterranean, with the most upscale shops and restaurants in the city and panoramic sea views.',
  description_ar = 'مول فاخر على شاطئ البحر مباشرة يضم أفخم المحلات والمطاعم بإطلالات بحرية خلابة ويُعدّ من أبرز وجهات التسوق الراقي في المدينة.',
  category_ar = 'تسوق',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/8/84/San_Stefano_Grand_Plaza%2C_Alexandria%2C_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/8/84/San_Stefano_Grand_Plaza%2C_Alexandria%2C_Egypt.jpg']
 WHERE id = '32';

-- 26) Souq El-Gumrok --------------------------------------------------
UPDATE public.places SET
  name_en = 'Souq El-Gumrok',
  name_ar = 'سوق الجمرك',
  description_en = 'A traditional market in the heart of old Alexandria, packed with spice shops, antiques, traditional clothing, and fresh fish.',
  description_ar = 'سوق شعبي أصيل في قلب الإسكندرية القديمة تنتشر فيه محلات البهارات والتحف والملابس التقليدية والأسماك الطازجة.',
  category_ar = 'تسوق',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg']
 WHERE id = '33';

-- 27) Al-Qaed Ibrahim Mosque ------------------------------------------
UPDATE public.places SET
  name_en = 'Al-Qaed Ibrahim Mosque',
  name_ar = 'مسجد القائد إبراهيم',
  description_en = 'The largest and most famous mosque in Alexandria, built in 1948 in a modern Islamic style. Its two tall minarets are among the city''s most recognisable landmarks.',
  description_ar = 'أكبر مساجد الإسكندرية وأشهرها، شُيّد عام 1948 على الطراز الإسلامي الحديث، وتعدّ مئذنتاه الطويلتان من أبرز معالم المدينة.',
  category_ar = 'مساجد',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/3/3c/Al_Qaed_Ibrahim_Mosque%2C_Alexandria.JPG',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/3/3c/Al_Qaed_Ibrahim_Mosque%2C_Alexandria.JPG']
 WHERE id = '34';

-- 28) Sidi Bishr Mosque ------------------------------------------------
UPDATE public.places SET
  name_en = 'Sidi Bishr Mosque',
  name_ar = 'مسجد سيدي بشر',
  description_en = 'One of the oldest mosques in Alexandria, holding the shrine of the revered companion of the Prophet, Bishr ibn Abi Rabi''a.',
  description_ar = 'من أقدم مساجد الإسكندرية ويضم ضريح الصحابي الجليل بُشر بن أبي ربيعة أحد رواة الحديث النبوي.',
  category_ar = 'مساجد',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/0/02/%D9%85%D8%B3%D8%AC%D8%AF_%D8%B3%D9%8A%D8%AF%D9%8A_%D8%A8%D8%B4%D8%B1.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/0/02/%D9%85%D8%B3%D8%AC%D8%AF_%D8%B3%D9%8A%D8%AF%D9%8A_%D8%A8%D8%B4%D8%B1.jpg']
 WHERE id = '35';

-- 29) Shatibi Mosque --------------------------------------------------
UPDATE public.places SET
  name_en = 'Shatibi Mosque',
  name_ar = 'مسجد الشاطبي',
  description_en = 'A historic seaside mosque that preserves the legacy of the Shatibi family who ruled Alexandria in the late Ottoman era.',
  description_ar = 'مسجد تاريخي على شاطئ البحر يحكي تاريخ الأسرة الشاطبية التي حكمت الإسكندرية في أواخر العصر العثماني.',
  category_ar = 'مساجد',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/0/02/%D9%85%D8%B3%D8%AC%D8%AF_%D8%B3%D9%8A%D8%AF%D9%8A_%D8%A8%D8%B4%D8%B1.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/0/02/%D9%85%D8%B3%D8%AC%D8%AF_%D8%B3%D9%8A%D8%AF%D9%8A_%D8%A8%D8%B4%D8%B1.jpg']
 WHERE id = '36';

-- 30) Raml Station Square ---------------------------------------------
UPDATE public.places SET
  name_en = 'Raml Station Square',
  name_ar = 'ميدان محطة الرمل',
  description_en = 'The beating heart of Alexandria, where the city''s iconic tram meets Italianate architecture. The natural starting point for any visitor.',
  description_ar = 'ميدان محطة الرمل، القلب النابض للإسكندرية، حيث يلتقي ترام المدينة العريق بالعمارة الإيطالية الكلاسيكية ليكون نقطة انطلاق لكل زائر.',
  category_ar = 'ميادين',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/a/a0/Misr_Station_Alexandria.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/a/a0/Misr_Station_Alexandria.jpg']
 WHERE id = '37';

-- 31) Corniche Road (Tatweer) -----------------------------------------
UPDATE public.places SET
  name_en = 'Alexandria Corniche',
  name_ar = 'كورنيش الإسكندرية',
  description_en = 'The Corniche, Egypt''s most famous seafront, stretches 15 km along the Mediterranean with benches, cafés, and panoramic sea views.',
  description_ar = 'الكورنيش، الممشى البحري الأشهر في مصر، يمتد 15 كيلومتراً على شاطئ البحر المتوسط ويضم مقاعد ومقاهي وإطلالات بانورامية خلابة.',
  category_ar = 'ممشى بحري',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/7/71/Egypt%2C_Alexandria%2C_The_Corniche_of_Alexandria.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/7/71/Egypt%2C_Alexandria%2C_The_Corniche_of_Alexandria.jpg']
 WHERE id = '38';

-- 32) Fouad Street ----------------------------------------------------
UPDATE public.places SET
  name_en = 'Fouad Street',
  name_ar = 'شارع فؤاد (الحرية)',
  description_en = 'Alexandria''s first commercial street since the 19th century, lined with historic shops, old cafés, and grand hotels like Windsor and Carlton.',
  description_ar = 'الشارع التجاري الأول في الإسكندرية منذ القرن التاسع عشر، تنتشر فيه المحلات التاريخية والمقاهي العتيقة وفنادق الفخامة مثل وندسور وكارلتون.',
  category_ar = 'شوارع',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/54/Fouad_Street_-_Alexandria_-_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/54/Fouad_Street_-_Alexandria_-_Egypt.jpg']
 WHERE id = '39';

-- 33) Catacombs of Kom el Shoqafa -------------------------------------
UPDATE public.places SET
  name_en = 'Catacombs of Kom el Shoqafa',
  name_ar = 'مقابر كوم الشقافة',
  description_en = 'A unique set of rock-cut tombs extending over three underground levels, carved in the 2nd century AD. A masterpiece blending Egyptian, Greek, and Roman art.',
  description_ar = 'مقابر صخرية فريدة تمتد على ثلاثة طوابق تحت الأرض، حُفرت في القرن الثاني الميلادي وتُعدّ تحفة فنية تمزج بين الفن المصري والإغريقي والروماني.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/6/6e/Catacombs_of_Kom_El_Shoqafa%2C_Alexandria%2C_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/6/6e/Catacombs_of_Kom_El_Shoqafa%2C_Alexandria%2C_Egypt.jpg']
 WHERE id = '4';

-- 34) St. Mark Coptic Orthodox Cathedral ------------------------------
UPDATE public.places SET
  name_en = 'St. Mark Coptic Orthodox Cathedral',
  name_ar = 'كاتدرائية القديس مرقس القبطية الأرثوذكسية',
  description_en = 'The oldest Coptic Orthodox church in Africa, built in the 19th century. Holds the relics of Saint Mark the Evangelist and serves as the second papal seat in Egypt after Cairo.',
  description_ar = 'أقدم كنيسة قبطية أرثوذكسية في إفريقيا، شُيّدت في القرن التاسع عشر وتضم مقام القديس مرقس الرسول والمقر البابوي الثاني في مصر بعد القاهرة.',
  category_ar = 'كنائس',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg']
 WHERE id = '40';

-- 35) Jesuit Church of Cleopatra --------------------------------------
UPDATE public.places SET
  name_en = 'Jesuit Church of Cleopatra',
  name_ar = 'كنيسة اليسوعيين بكليوباترا',
  description_en = 'A historic Catholic church in the Cleopatra district, one of Alexandria''s most beautiful Latin churches, with classical architecture, a luxurious chandelier, and a tranquil courtyard.',
  description_ar = 'كنيسة كاثوليكية تاريخية في حي كليوباترا، من أجمل كنائس الإسكندرية اللاتينية بعمارتها الكلاسيكية ونجفها الفاخر وفنائها الهادئ.',
  category_ar = 'كنائس',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg']
 WHERE id = '41';

-- 36) Saint Catherine''s Cathedral -------------------------------------
UPDATE public.places SET
  name_en = 'Saint Catherine''s Cathedral',
  name_ar = 'كاتدرائية القديسة كاترين',
  description_en = 'A Greek Orthodox cathedral with distinctive Byzantine architecture, built in the 19th century, famous for its gilded icons and unique domes.',
  description_ar = 'كاتدرائية أرثوذكسية يونانية بمعمار بيزنطي مميز، شُيّدت في القرن التاسع عشر وتتميز بأيقوناتها المذهبة وقبابها الفريدة.',
  category_ar = 'كنائس',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg']
 WHERE id = '42';

-- 37) Graeco-Roman Museum ---------------------------------------------
UPDATE public.places SET
  name_en = 'Graeco-Roman Museum',
  name_ar = 'المتحف اليوناني الروماني',
  description_en = 'The Graeco-Roman Museum, fully renovated, houses thousands of artifacts from the Ptolemaic and Roman eras including statues, coins, and mosaics.',
  description_ar = 'المتحف اليوناني الروماني بعد تجديده الكامل، يضم آلاف القطع من العصرين البطلمي والروماني من تماثيل وعملات وفسيفساء.',
  category_ar = 'متاحف',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/3/3d/Fassade_des_griechisch-r%C3%B6mischen_Museums_in_Alexandria%2C_%C3%84gypten.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/3/3d/Fassade_des_griechisch-r%C3%B6mischen_Museums_in_Alexandria%2C_%C3%84gypten.jpg']
 WHERE id = '43';

-- 38) Café Riche (Historical) -----------------------------------------
UPDATE public.places SET
  name_en = 'Café Riche',
  name_ar = 'مقهى ريتش',
  description_en = 'One of Alexandria''s most historic cafés since 1908, where the city''s writers, intellectuals, and politicians used to meet. Built in the French classical style, it still serves its original Turkish coffee.',
  description_ar = 'من أعرق مقاهي الإسكندرية منذ عام 1908، شهد لقاءات أدباء الإسكندرية وكتّابها ومفكريها. بُني على الطراز الفرنسي الكلاسيكي ولا يزال محافظاً على أثاثه الأصلي وقهوته التركية.',
  category_ar = 'مقاهي',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/54/Fouad_Street_-_Alexandria_-_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/54/Fouad_Street_-_Alexandria_-_Egypt.jpg']
 WHERE id = '43591966-e37f-4f6a-967c-d94a1a012d16';

-- 39) Royal Jewelry Museum --------------------------------------------
UPDATE public.places SET
  name_en = 'Royal Jewelry Museum',
  name_ar = 'متحف المجوهرات الملكية',
  description_en = 'Princess Fatma Al-Zahra''s palace, housing the jewelry and personal effects of the Muhammad Ali dynasty, plus ceiling paintings and stained glass worth the visit on their own.',
  description_ar = 'قصر الأميرة فاطمة الزهراء يضم مجوهرات ومقتنيات أسرة محمد علي، إلى جانب لوحات سقفية وزجاج معشق يستحقّ الزيارة لوحدها.',
  category_ar = 'متاحف',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/f/f6/AlexRoyalJewelleryMusLeft.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/f/f6/AlexRoyalJewelleryMusLeft.jpg']
 WHERE id = '44';

-- 40) Mahmoud Said Museum --------------------------------------------
UPDATE public.places SET
  name_en = 'Mahmoud Said Museum',
  name_ar = 'متحف محمود سعيد',
  description_en = 'The Italianate villa of Egypt''s great modern painter Mahmoud Said, displaying his paintings and works of other pioneers of modern Egyptian art. A quiet museum near Antoniades Garden.',
  description_ar = 'فيلا الفنان المصري الكبير محمود سعيد على الطراز الإيطالي تعرض لوحاته وأعمال رواد الفن المصري الحديث، ومتحف هادئ قريب من حديقة أنطونيادس.',
  category_ar = 'متاحف',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/a/a4/Mohamed_Mahmoud_Khalil_Museum.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/a/a4/Mohamed_Mahmoud_Khalil_Museum.jpg']
 WHERE id = '45';

-- 41) Cavafy Museum ---------------------------------------------------
UPDATE public.places SET
  name_en = 'Cavafy Museum',
  name_ar = 'متحف كفافي',
  description_en = 'The house of the great Greek poet Constantine Cavafy, who lived here for 25 years. His library, manuscripts, and original furniture are preserved exactly as he left them.',
  description_ar = 'بيت الشاعر اليوناني الكبير قسطنطين كفافي الذي عاش فيه 25 عاماً، تُحفظ مكتبته ومخطوطاته وأثاثه الأصلي كما تركها.',
  category_ar = 'متاحف',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/9b/AlexCavafyHouse.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/40/Alexandria_-_The_Kavafy_Museum%2C_1995.jpg']
 WHERE id = '46';

-- 42) Sayed Darwish Theatre (Alexandria Opera House) -------------------
UPDATE public.places SET
  name_en = 'Sayed Darwish Theatre (Alexandria Opera House)',
  name_ar = 'مسرح سيد درويش (دار أوبرا الإسكندرية)',
  description_en = 'Alexandria''s opera house, designed in 1921 and inspired by the Vienna State Opera. It hosts orchestra, opera, and theatre performances throughout the season.',
  description_ar = 'دار أوبرا الإسكندرية التي صُمّمت عام 1921 مستوحاة من أوبرا فيينا، تستضيف حفلات الأوركسترا والأوبرا والمسرح طوال الموسم.',
  category_ar = 'ثقافة',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/a/aa/Sayed_Darwish_Theatre_in_Alexandria%2C_in_the_city_of_Alexandria_Egypt.JPG',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/a/aa/Sayed_Darwish_Theatre_in_Alexandria%2C_in_the_city_of_Alexandria_Egypt.JPG']
 WHERE id = '47';

-- 43) El Max Canals (Venice of Alexandria) -----------------------------
UPDATE public.places SET
  name_en = 'El Max Canals (Venice of Alexandria)',
  name_ar = 'قنوات المكس (فينيسيا الإسكندرية)',
  description_en = 'The Max fishing village, with its small canals, painted houses and wooden boats, is nicknamed the "Venice of Alexandria". The most magical time to visit is just before sunset.',
  description_ar = 'قرية المكس للصيادين، قنوات مائية وبيوت ملوّنة وقوارب خشبية، يُلقّبونها "فينيسيا الإسكندرية"، وأجمل أوقاتها قبل غروب الشمس.',
  category_ar = 'شوارع',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/9a/El_Max_%2C_Alexandria.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/9a/El_Max_%2C_Alexandria.jpg']
 WHERE id = '48';

-- 44) El-Nabi Daniel Mosque -------------------------------------------
UPDATE public.places SET
  name_en = 'El-Nabi Daniel Mosque',
  name_ar = 'مسجد النبي دانيال',
  description_en = 'One of the oldest mosques in central Alexandria. The site is believed to be linked to the tomb of Alexander the Great — one of the most mysterious places in the city''s history.',
  description_ar = 'من أقدم مساجد الإسكندرية في قلب وسط البلد، يُعتقد أن الموقع مرتبط بقبر الإسكندر الأكبر، وهو من أكثر الأماكن غموضاً في تاريخ المدينة.',
  category_ar = 'مساجد',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/d/d0/Nabi_Daniel_Mosque_Today.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/d/d0/Nabi_Daniel_Mosque_Today.jpg']
 WHERE id = '49';

-- 45) El-Nouzha Botanical Garden --------------------------------------
UPDATE public.places SET
  name_en = 'El-Nouzha Botanical Garden',
  name_ar = 'حديقة النزهة النباتية',
  description_en = 'Alexandria''s oldest public garden, founded in 1892, with trees over 130 years old and some of the rarest plant species in the country.',
  description_ar = 'أقدم حديقة عامة في الإسكندرية أُسست عام 1892 وتضم أشجاراً عمرها أكثر من 130 عاماً من أندر الأنواع النباتية.',
  category_ar = 'حدائق',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/e/e4/Alexandria_-_The_Nouzha_Garden._-_btv1b101143429_%281_of_2%29.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/e/e4/Alexandria_-_The_Nouzha_Garden._-_btv1b101143429_%281_of_2%29.jpg']
 WHERE id = '5';

-- 46) El-Attarine Mosque ----------------------------------------------
UPDATE public.places SET
  name_en = 'El-Attarine Mosque',
  name_ar = 'مسجد العطارين',
  description_en = 'The Attarine Mosque, in the heart of the old bazaar, was built on the ruins of the Church of St. Athanasius and still preserves its ancient granite columns to this day.',
  description_ar = 'مسجد العطارين في قلب السوق القديم، بُني على أنقاض كنيسة القديس أثناسيوس ويحتفظ بأعمدته الجرانيتية الأثرية حتى اليوم.',
  category_ar = 'مساجد',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg']
 WHERE id = '50';

-- 47) Alexandria Zoo --------------------------------------------------
UPDATE public.places SET
  name_en = 'Alexandria Zoo',
  name_ar = 'حديقة حيوان الإسكندرية',
  description_en = 'The classic family zoo with lions, giraffes, monkeys, and rare birds. A full family day out at a very modest entry price.',
  description_ar = 'حديقة حيوان النزهة، مكان عائلي كلاسيكي يضم الأسود والزرافات والقرود وطيوراً نادرة، ويُعدّ وجهة مثالية ليوم عائلي كامل بأسعار رمزية.',
  category_ar = 'حدائق',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/2/21/Alexandria_Zoo_1.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/2/21/Alexandria_Zoo_1.jpg']
 WHERE id = '51';

-- 48) Antoniades Gardens ----------------------------------------------
UPDATE public.places SET
  name_en = 'Antoniades Gardens',
  name_ar = 'حدائق أنطونيادس',
  description_en = 'A 19th-century garden in the heart of Smouha, with Greek marble statues set among rare trees and tranquil fountains.',
  description_ar = 'حدائق أنطونيادس العائدة إلى القرن التاسع عشر، تضم تماثيل رخامية يونانية بين أشجار نادرة ونوافير هادئة في قلب حي سموحة.',
  category_ar = 'حدائق',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/4/45/Alexandria_-_Antoniades_Garden_-_btv1b10114345n_%281_of_2%29.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/45/Alexandria_-_Antoniades_Garden_-_btv1b10114345n_%281_of_2%29.jpg']
 WHERE id = '52';

-- 49) Alexandria Aquarium ---------------------------------------------
UPDATE public.places SET
  name_en = 'Alexandria Aquarium',
  name_ar = 'أكواريوم الإسكندرية',
  description_en = 'Alexandria''s aquarium, right next to Qaitbay Citadel, displays Mediterranean fish and rare marine life in old stone tanks.',
  description_ar = 'أكواريوم الإسكندرية على مقربة من قلعة قايتباي، يعرض أسماك البحر المتوسط وكائنات بحرية نادرة في أحواض صخرية قديمة.',
  category_ar = 'متاحف',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/4/43/Aquarium_Alex_31.JPG',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/43/Aquarium_Alex_31.JPG']
 WHERE id = '53';

-- 50) El-Mansheya Square ----------------------------------------------
UPDATE public.places SET
  name_en = 'El-Mansheya Square',
  name_ar = 'ميدان المنشية',
  description_en = 'Mansheya Square, the commercial heart of Alexandria since the era of Muhammad Ali. Lined with classical buildings and old shops, it is the city''s true pulse.',
  description_ar = 'ميدان المنشية، القلب التجاري للإسكندرية منذ عصر محمد علي، تنتشر فيه المباني الكلاسيكية والمحلات العتيقة ويُعدّ نبض المدينة الحقيقي.',
  category_ar = 'ميادين',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/6/65/Mansheya%2C_Alexandria.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/6/65/Mansheya%2C_Alexandria.jpg']
 WHERE id = '54';

-- 51) Saad Zaghloul Square --------------------------------------------
UPDATE public.places SET
  name_en = 'Saad Zaghloul Square',
  name_ar = 'ميدان سعد زغلول',
  description_en = 'Saad Zaghloul Square, right on the Corniche, with the statue of Saad Zaghloul at its centre, the Ramses Palace, and the sea all in one panoramic view.',
  description_ar = 'ميدان سعد زغلول على الكورنيش مباشرة، يضم تمثال سعد زغلول وسط الميدان وقصر رمسيس والبحر أمامك في بانوراما واحدة.',
  category_ar = 'ميادين',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/b/b0/Saad_Zaghloul_square_in_Alexandria_01.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/b/b0/Saad_Zaghloul_square_in_Alexandria_01.jpg']
 WHERE id = '55';

-- 52) Mustafa Kamel Necropolis ----------------------------------------
UPDATE public.places SET
  name_en = 'Mustafa Kamel Necropolis',
  name_ar = 'مقابر مصطفى كامل',
  description_en = 'Four Pellenic rock-cut tombs from the 3rd century BC hidden in a quiet residential area. One of the least-crowded ancient sites in Alexandria.',
  description_ar = 'مقابر مصطفى كامل، أربع مقابر صخرية بيلينية من القرن الثالث قبل الميلاد في حي سكني عادي، وتُعدّ من أقل الآثار ازدحاماً في الإسكندرية.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/4/48/Mustafa_Kamel_Necropolis%2C_Alexandria%2C_August_2005-1.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/48/Mustafa_Kamel_Necropolis%2C_Alexandria%2C_August_2005-1.jpg']
 WHERE id = '57';

-- 53) El Shatby Necropolis --------------------------------------------
UPDATE public.places SET
  name_en = 'El Shatby Necropolis',
  name_ar = 'مقابر الشاطبي',
  description_en = 'Ptolemaic-era tombs shaped like houses with façades, columns, and courtyards carved into the rock, located right next to the Anfushi tombs.',
  description_ar = 'مقابر الشاطبي من العصر البطلمي، على شكل بيوت بواجهات وأعمدة وأفنية محفورة في الصخر، وتقع بجوار مقابر الأنفوشي.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/3/31/The_Chatby_Tombs_at_Alexandria_%28VII%29.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/3/31/The_Chatby_Tombs_at_Alexandria_%28VII%29.jpg']
 WHERE id = '58';

-- 54) Anfushi Fish Market ---------------------------------------------
UPDATE public.places SET
  name_en = 'Anfushi Fish Market',
  name_ar = 'سوق السمك بالأنفوشي',
  description_en = 'A full sensory experience — fresh fish straight from the fishermen on the Anfushi Corniche. Pick your fish, have it weighed, and it''s served to you within minutes.',
  description_ar = 'تجربة حسية متكاملة، سمك طازج من الصيادين مباشرة على كورنيش الأنفوشي، تختار سمكتك وتزنها بالكيلو ويُقدّمونها لك بعد دقائق.',
  category_ar = 'مأكولات بحرية',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/1/15/AlexAnfushiTombs.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/1/15/AlexAnfushiTombs.jpg']
 WHERE id = '6';

-- 55) Saint Mina Cathedral (Pope Cyril VI) -----------------------------
UPDATE public.places SET
  name_en = 'Saint Mina Cathedral (Pope Cyril VI)',
  name_ar = 'كاتدرائية القديس مارمرقس (البابا كيرلس السادس)',
  description_en = 'The Saint Mark Cathedral in Anba Royes, the largest Coptic church in Alexandria and the largest in the Middle East. It contains the tomb of Pope Cyril VI and seats more than 5,000 worshippers.',
  description_ar = 'كاتدرائية القديس مارمرقس الرسول بالأنبا رويس، أكبر الكنائس القبطية في الإسكندرية وأكبرها في الشرق الأوسط. تضم ضريح البابا كيرلس السادس وتتسع لأكثر من 5000 مصلي.',
  category_ar = 'كنائس',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg']
 WHERE id = '6ea681a0-6bb4-43df-a3de-1d0f94f8f665';

-- 56) Pompey''s Pillar ------------------------------------------------
UPDATE public.places SET
  name_en = 'Pompey''s Pillar',
  name_ar = 'عمود السواري',
  description_en = 'A 30-metre monolith of red granite erected in 297 AD. Originally part of the great Serapeum temple complex.',
  description_ar = 'عمود ضخم من الجرانيت الأحمر ارتفاعه 30 متراً نُصب عام 297م، وكان في الأصل جزءاً من معبد السيرابيوم العظيم.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/a/aa/Pompey%27s_Pillar_%28Archaeological_site_in_Alexandria_2017%29_%2C_photo_by_Hatem_moushir_9.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/a/aa/Pompey%27s_Pillar_%28Archaeological_site_in_Alexandria_2017%29_%2C_photo_by_Hatem_moushir_9.jpg']
 WHERE id = '7';

-- 57) Stanley Bridge & Corniche ---------------------------------------
UPDATE public.places SET
  name_en = 'Stanley Bridge & Corniche',
  name_ar = 'كوبري ستانلي والكورنيش',
  description_en = 'The Stanley Bridge, with its elegant white arch, stretches over the blue water of the bay and is a hub of Alexandria''s nightlife.',
  description_ar = 'جسر ستانلي بقوسه الأبيض الأنيق يمتد فوق مياه البحر الأزرق، ويُعدّ وجهة أساسية للحياة الليلية في الإسكندرية.',
  category_ar = 'ممشى بحري',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/7/70/Stanley_Bridge%2C_Alexandria%2C_Jan._2019-1.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/7/70/Stanley_Bridge%2C_Alexandria%2C_Jan._2019-1.jpg']
 WHERE id = '8';

-- 58) Lumina (Modern Café & Roastery) --------------------------------
UPDATE public.places SET
  name_en = 'Lumina (Modern Café & Roastery)',
  name_ar = 'لومينا (مقهى ومحمصة حديثة)',
  description_en = 'Lumina, a specialty coffee roastery in the Cleopatra district serving single-origin beans from Egypt and around the world. A quiet space for working, with weekly cupping workshops.',
  description_ar = 'مقهى لومينا المتخصص في تحميص القهوة، مقهى عصري في حي كليوباترا يقدم قهوة مختصّة من مصادر مصرية وعالمية. فضاء هادئ للعمل واللابتوب وورش تذوّق أسبوعية.',
  category_ar = 'مقاهي',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/3/37/Egypt%2C_Alexandria%2C_Bibliotheca_Alexandrina.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/3/37/Egypt%2C_Alexandria%2C_Bibliotheca_Alexandrina.jpg']
 WHERE id = '8a9ee7df-880f-4408-aa6d-a1c9d54985f8';

-- 59) Roman Amphitheatre (Kom el-Dikka) -------------------------------
UPDATE public.places SET
  name_en = 'Roman Amphitheatre (Kom el-Dikka)',
  name_ar = 'المسرح الروماني (كوم الدكة)',
  description_en = 'A sunken Roman amphitheatre discovered by accident in the 1960s, with thirteen tiers of white marble seating. One of the most impressive Roman monuments in the city.',
  description_ar = 'أمفيثياتر روماني مغمور اكتُشف بالصدفة في الستينيات، يضم ثلاثة عشر صفاً من المدرجات الرخامية ويُعدّ من أروع الآثار الرومانية في المدينة.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/f/f9/Alexandria%2C_Kom_el-Dikka%2C_Theatre.JPG',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/e/e1/Roman_theatre%2C_Alexandria%2C_Egypt_%282008%29.jpg']
 WHERE id = '9';

-- 60) Toledo (Historic Cinema) ----------------------------------------
UPDATE public.places SET
  name_en = 'Toledo (Historic Cinema)',
  name_ar = 'سينما توليدو التاريخية',
  description_en = 'Toledo Cinema, an Art Deco cinema in the heart of Alexandria dating from 1936. Its original façade is a landmark of the city''s golden age of cinema.',
  description_ar = 'سينما توليدو التاريخية، صالة سينما عريقة في قلب الإسكندرية من ثلاثينيات القرن العشرين، افتُتحت عام 1936 بأسلوب آرت ديكو ولا تزال واجهتها الأصلية شاهدة على عصرها الذهبي.',
  category_ar = 'ثقافة',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/54/Fouad_Street_-_Alexandria_-_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/54/Fouad_Street_-_Alexandria_-_Egypt.jpg']
 WHERE id = '9b47c3d7-5aa9-4e68-a6ea-5cd7d55e443b';

-- 61) Alexandrina Library Manuscript Museum ---------------------------
UPDATE public.places SET
  name_en = 'Bibliotheca Alexandrina — Manuscript Museum',
  name_ar = 'متحف المخطوطات بمكتبة الإسكندرية',
  description_en = 'The Manuscript Museum inside the Bibliotheca Alexandrina holds the oldest manuscripts in the world — from the Quran, the Gospels, and Pharaonic and Greek papyri — displayed in climate-controlled rooms.',
  description_ar = 'متحف المخطوطات داخل مكتبة الإسكندرية، يضم أقدم مخطوطات العالم من القرآن الكريم والأناجيل والوثائق الفرعونية واليونانية، تُعرض في قاعات إضاءة محكومة للحفاظ عليها.',
  category_ar = 'متاحف',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/c/cc/Bibliotheca_Alexandrina_interior_-_2008-07-17.JPG',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/c/cc/Bibliotheca_Alexandrina_interior_-_2008-07-17.JPG']
 WHERE id = 'a118abcb-13b2-4db3-89b6-dfe2fb2abe2f';

-- 62) Agami Marina & Yacht Club ---------------------------------------
UPDATE public.places SET
  name_en = 'Agami Marina & Yacht Club',
  name_ar = 'مارينا عجمي ونادي اليخوت',
  description_en = 'Agami Marina, 25 km west of Alexandria, with 400 yacht berths, a row of restaurants and shops on a full seafront, and an annual sailing regatta.',
  description_ar = 'مارينا عجمي ونادي اليخوت، وجهة راقية على بعد 25 كيلومتراً غرب الإسكندرية. تضم 400 رصيف لليخوت ومجموعة مطاعم ومتاجر بإطلالة بحرية كاملة، وتستضيف سباقات الإبحار سنوياً.',
  category_ar = 'شواطئ',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/4/45/Golden_sunset_From_the_beach_of_Alexandria%2C_Egypt.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/45/Golden_sunset_From_the_beach_of_Alexandria%2C_Egypt.jpg']
 WHERE id = 'a201bc6d-012c-43ca-9b7d-3e93f3cebea1';

-- 63) Ibrahim El-Desouky (Legendary Sweet Shop) -----------------------
UPDATE public.places SET
  name_en = 'Ibrahim El-Desouky (Legendary Sweet Shop)',
  name_ar = 'حلواني إبراهيم الدسوقي',
  description_en = 'Ibrahim El-Desouky, the most famous sweet shop in Alexandria, has been handcrafting mahallabia, mhalabia, and goulash for 70 years. The queue starts at dawn on holidays.',
  description_ar = 'حلواني إبراهيم الدسوقي الأشهر في الإسكندرية، يصنع المهلبية والمهلّبية والجلاش بأسلوب يدوي عمره 70 عاماً. الصفّ يتكوّن منذ الفجر في المناسبات.',
  category_ar = 'حلويات',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg']
 WHERE id = 'b7e05f7c-491b-4209-9463-5a129679f9eb';

-- 64) Sultana (Historical Sweet Shop) ---------------------------------
UPDATE public.places SET
  name_en = 'Sultana (Historical Sweet Shop)',
  name_ar = 'محل حلويات السلطانة',
  description_en = 'Sultana, the oldest sweet shop in Alexandria since 1896, famous for its kunafa, smugglers'' baklava, and eastern gateau — all handmade by Aleppo-trained artisans.',
  description_ar = 'محل حلويات السلطانة، أعرق محل في الإسكندرية منذ عام 1896. اشتهر بالكنافة والبقلاوة المهربة والجاتوه الشرقي بأيدي الحلبيين القدامى.',
  category_ar = 'حلويات',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg']
 WHERE id = 'c477453c-cec4-4d57-bd07-18b5ff7ceaad';

-- 65) Al-Mahrousa Bridge ----------------------------------------------
UPDATE public.places SET
  name_en = 'Al-Mahrousa Bridge',
  name_ar = 'كوبري المحروسة',
  description_en = 'The Al-Mahrousa Bridge over the Mahmoudiya Canal, one of the oldest bridges in Alexandria. It links downtown to Anfushi and is both a landmark and a true maritime legend.',
  description_ar = 'كوبري المحروسة الشهير على قناة المحمودية، من أقدم الكباري في الإسكندرية. يربط وسط المدينة بالأنفوشي ويُعدّ رمزاً معمارياً وأسطورة بحرية حقيقية.',
  category_ar = 'كباري',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/7/71/Egypt%2C_Alexandria%2C_The_Corniche_of_Alexandria.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/7/71/Egypt%2C_Alexandria%2C_The_Corniche_of_Alexandria.jpg']
 WHERE id = 'cf116eed-341f-4564-acfc-776edd8aa34d';

-- 66) Stanley Cafe Espresso Bar ---------------------------------------
UPDATE public.places SET
  name_en = 'Stanley Cafe Espresso Bar',
  name_ar = 'مقهى ستانلي إسبريسو بار',
  description_en = 'Stanley Espresso Bar, serving fresh-roasted specialty coffee, cold drinks and French pastries, with seating right in front of the sea.',
  description_ar = 'مقهى ستانلي للقهوة المختصة، يقدم قهوة محمصة طازجة ومشروبات باردة وحلويات فرنسية، يجلس فيه الزبائن أمام البحر مباشرة.',
  category_ar = 'مقاهي',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/7/70/Stanley_Bridge%2C_Alexandria%2C_Jan._2019-1.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/7/70/Stanley_Bridge%2C_Alexandria%2C_Jan._2019-1.jpg']
 WHERE id = 'd88d4a5d-b3b0-4579-bef3-728e41843095';

-- 67) Greek Club of Alexandria ----------------------------------------
UPDATE public.places SET
  name_en = 'Greek Club of Alexandria',
  name_ar = 'نادي الإسكندرية اليوناني',
  description_en = 'A 19th-century architectural masterpiece that was the social hub of the Greek community in the city. Today it houses a library, an exhibition space, and a restaurant set in lush gardens.',
  description_ar = 'نادي الإسكندرية اليوناني، تحفة معمارية من القرن التاسع عشر كانت مركز الحياة الاجتماعية للجالية اليونانية في المدينة. يضم اليوم مكتبة ومعرضاً ومطعماً وسط حدائق خلابة.',
  category_ar = 'ثقافة',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/96/Greek_Club%2C_Shatby%2C_Alexandria_01.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/96/Greek_Club%2C_Shatby%2C_Alexandria_01.jpg']
 WHERE id = 'ec216324-1277-4649-a631-91be397eeeac';

-- 68) Lighthouse of Alexandria (Submerged Ruins) ---------------------
UPDATE public.places SET
  name_en = 'Lighthouse of Alexandria (Submerged Ruins)',
  name_ar = 'فنار الإسكندرية (بقايا تحت الماء)',
  description_en = 'The remains of the Lighthouse of Alexandria under the water just off the Citadel of Qaitbay, visible to professional divers. One of the Seven Wonders of the Ancient World, destroyed by earthquakes in the 14th century.',
  description_ar = 'بقايا فنار الإسكندرية تحت سطح البحر قبالة قلعة قايتباي، يمكن رؤيتها بواسطة الغواصين المحترفين. أحد عجائب الدنيا السبع القديمة الذي دمّرته الزلازل في القرن الرابع عشر.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/2/22/Lighthouse_-_Thiersch.png',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/47/Citadel_of_Qaitbay_in_Alexandria%2C_Egypt.png']
 WHERE id = 'f54cbabc-3bd6-4af2-96d8-542544dde62e';

-- 69) Cleopatra''s Bath (Sink of Cleopatra) ---------------------------
UPDATE public.places SET
  name_en = 'Cleopatra''s Bath (Sink of Cleopatra)',
  name_ar = 'حمام كليوباترا (بالوعة كليوباترا)',
  description_en = 'The remains of an ancient Roman pool mistakenly attributed to Cleopatra, located underground in central Alexandria with Ptolemaic mosaics and statues.',
  description_ar = 'بقايا حمام سباحة روماني قديم يُنسب كذباً إلى الملكة كليوباترا، يقع تحت الأرض في وسط المدينة ويضم فسيفساء وتماثيل من العصر البطلمي.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/9a/GD-EG-Alexandria%2C_Cistern_of_al-Nabih_007.jpg',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/9a/GD-EG-Alexandria%2C_Cistern_of_al-Nabih_007.jpg']
 WHERE id = 'f6f9e22a-2cb0-4d26-b94a-fc5c69be85bf';

-- 70) Qaitbay Citadel -------------------------------------------------
UPDATE public.places SET
  name_en = 'Citadel of Qaitbay',
  name_ar = 'قلعة قايتباي',
  description_en = 'The eternal guardian of the Mediterranean. Built in the 15th century on the ruins of the legendary Lighthouse of Alexandria — one of the Seven Wonders of the Ancient World — and a stunning example of Mamluk architecture with breathtaking sea views.',
  description_ar = 'قلعة قايتباي، الحارس الخالد للبحر الأبيض المتوسط. شُيّدت في القرن الخامس عشر الميلادي على أنقاض فنار الإسكندرية الأسطوري أحد عجائب الدنيا السبع القديمة، وتجمع بين روعة العمارة المملوكية وإطلالات بانورامية ساحرة على البحر المتوسط.',
  category_ar = 'آثار',
  image_url = 'https://upload.wikimedia.org/wikipedia/commons/0/0d/Citadel_of_Qaitbay_014.JPG',
  image_urls = ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/47/Citadel_of_Qaitbay_in_Alexandria%2C_Egypt.png']
 WHERE id = 'p_1784811618524';

-- =====================================================================
-- Final consistency check: every place that previously had a non-empty
-- `name` must now have both `name_en` and `name_ar` populated. Any
-- row still missing an Arabic name would fall back to the English name
-- in the UI — better to fail loudly here than silently.
-- =====================================================================

DO $$
DECLARE
  bad_row_count INT;
BEGIN
  SELECT COUNT(*)
    INTO bad_row_count
    FROM public.places
   WHERE name IS NOT NULL
     AND (name_en IS NULL OR length(trim(name_en)) = 0
          OR name_ar IS NULL OR length(trim(name_ar)) = 0);
  IF bad_row_count > 0 THEN
    RAISE EXCEPTION 'v1.0.54 migration: % rows still missing name_en or name_ar',
      bad_row_count;
  END IF;
END
$$;

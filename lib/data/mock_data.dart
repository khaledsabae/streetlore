import 'models/place_model.dart';
import 'models/itinerary_model.dart';

class MockData {
  MockData._();

  static const List<MockReview> _reviewPool = [
    MockReview(
      name: 'Sarah Mitchell',
      rating: 5.0,
      comment:
          'Absolutely breathtaking! The view of the Mediterranean from the top is unlike anything I have ever seen. A true hidden gem of history.',
      date: '2 days ago',
      avatarColor: 0xFFE11D48,
    ),
    MockReview(
      name: 'Ahmed Khalil',
      rating: 4.5,
      comment:
          'A must-visit landmark in Alexandria. Rich history and beautiful architecture. I recommend visiting early morning to avoid crowds.',
      date: '1 week ago',
      avatarColor: 0xFF0F172A,
    ),
    MockReview(
      name: 'Emma Rossi',
      rating: 4.0,
      comment:
          'Beautiful place with a lot of character. Slightly crowded on weekends. The sunset view is absolutely magical.',
      date: '2 weeks ago',
      avatarColor: 0xFF10B981,
    ),
    MockReview(
      name: 'Omar Hassan',
      rating: 5.0,
      comment:
          'One of Alexandria finest gems. Every Egyptian and tourist should visit. The history here is incredible!',
      date: '1 month ago',
      avatarColor: 0xFFF59E0B,
    ),
    MockReview(
      name: 'Layla Nour',
      rating: 4.5,
      comment:
          'Stunning architecture and amazing stories to discover. The guide was very knowledgeable and passionate.',
      date: '3 weeks ago',
      avatarColor: 0xFF6366F1,
    ),
    MockReview(
      name: 'James Wilson',
      rating: 3.5,
      comment:
          'Great experience overall. Could use better signage in English but the place itself is magnificent.',
      date: '2 months ago',
      avatarColor: 0xFF0EA5E9,
    ),
    MockReview(
      name: 'Nadia Farouk',
      rating: 5.0,
      comment:
          'Truly one of those places that stays with you forever. The atmosphere is unique and unlike anywhere else in Egypt.',
      date: '5 days ago',
      avatarColor: 0xFF7C3AED,
    ),
    MockReview(
      name: 'Carlos Martinez',
      rating: 4.5,
      comment:
          'I traveled all the way from Spain to see this. Worth every bit of it. Alexandria keeps surprising me.',
      date: '10 days ago',
      avatarColor: 0xFFEA580C,
    ),
  ];

  static List<MockReview> getReviews(String placeId) {
    final seed = placeId.hashCode.abs() % _reviewPool.length;
    final List<MockReview> result = [];
    for (var i = 0; i < 5; i++) {
      result.add(_reviewPool[(seed + i) % _reviewPool.length]);
    }
    return result;
  }

  static List<PlaceModel> getFeatured() => fallbackPlaces.take(5).toList();

  static List<PlaceModel> getNearby(PlaceModel current) {
    return fallbackPlaces
        .where(
          (p) =>
              p.id != current.id &&
              (p.lat - current.lat).abs() < 0.05 &&
              (p.lng - current.lng).abs() < 0.05,
        )
        .take(4)
        .toList();
  }

  static List<PlaceModel> getByCategory(
    String category,
    List<PlaceModel> source,
  ) {
    if (category == 'All') return source;
    return source.where((p) => p.category == category).toList();
  }

  static bool isOpenNow(String openHours) {
    if (openHours.trim() == 'Open 24 hours') return true;
    final now = DateTime.now();
    final hour = now.hour;
    return hour >= 9 && hour < 18;
  }

  static List<PlaceModel> get places => fallbackPlaces;

  static List<ItineraryModel> get tours => _seedTours;
}

class MockReview {
  final String name;
  final double rating;
  final String comment;
  final String date;
  final int avatarColor;
  const MockReview({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
    required this.avatarColor,
  });
}

const List<PlaceModel> fallbackPlaces = [
  PlaceModel(
    id: 'fallback_qaitbay',
    nameEn: 'Citadel of Qaitbay',
    nameAr: 'قلعة قايتباي',
    descriptionEn:
        'A 15th-century defensive fortress on the Mediterranean sea coast. Built upon the ruins of the ancient Lighthouse of Alexandria — one of the Seven Wonders of the ancient world.',
    descriptionAr:
        'قلعة قايتباي هي حصن دفاعي يعود للقرن الخامس عشر الميلادي، مبني على أنقاض منارة الإسكندرية القديمة، إحدى عجائب الدنيا السبع. تقع على شاطئ البحر المتوسط وتتميز بمعمارها الأيوبي الرائع.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/0/0d/Citadel_of_Qaitbay_014.JPG',
    imageUrls: [
      'https://upload.wikimedia.org/wikipedia/commons/4/47/Citadel_of_Qaitbay_in_Alexandria%2C_Egypt.png',
    ],
    rating: 4.7,
    category: 'Historical',
    categoryAr: 'تاريخي',
    lat: 31.2141,
    lng: 29.8856,
    address: 'Eastern Harbor, Anfushi, Alexandria',
    addressAr: 'الميناء الشرقي، الأنفوشي، الإسكندرية',
    openHours: '9:00 AM - 5:00 PM',
    reviewCount: 1240,
    priceLevel: PriceLevel.cheap,
    priceNote: 'Adults',
    priceNoteAr: 'للكبار',
    priceLocalEgp: 20,
    priceForeignerEgp: 80,
    isHiddenGem: false,
  ),
  PlaceModel(
    id: 'fallback_biblio',
    nameEn: 'Bibliotheca Alexandrina',
    nameAr: 'مكتبة الإسكندرية',
    descriptionEn:
        'A modern library and cultural center opened in 2002 on the Mediterranean shore. Inspired by the ancient Library of Alexandria, it holds over 2 million books and hosts museums, exhibitions, and a planetarium.',
    descriptionAr:
        'مكتبة الإسكندرية الجديدة صرح ثقافي ضخم على شاطئ البحر المتوسط، تجسيد معاصر للمكتبة الأسطورية التي كانت مركزاً للعلوم والمعرفة في العالم القديم. تضم مليوني كتاب ومتاحف وقاعات عروض.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/3/37/Egypt%2C_Alexandria%2C_Bibliotheca_Alexandrina.jpg',
    imageUrls: [
      'https://upload.wikimedia.org/wikipedia/commons/e/eb/Bibliotheca_Alexandrina%2C_Egypt%2C_2013.jpg',
    ],
    rating: 4.8,
    category: 'Culture',
    categoryAr: 'ثقافة',
    lat: 31.2092,
    lng: 29.9085,
    address: 'El Shatby, Alexandria',
    addressAr: 'الشاطبي، الإسكندرية',
    openHours: '10:00 AM - 7:00 PM',
    reviewCount: 2890,
    priceLevel: PriceLevel.free,
    priceNote: 'Free entry',
    priceNoteAr: 'دخول مجاني',
    priceLocalEgp: 0,
    priceForeignerEgp: 0,
    isHiddenGem: false,
  ),
  PlaceModel(
    id: 'fallback_pompey',
    nameEn: "Pompey's Pillar",
    nameAr: 'عمود السواري',
    descriptionEn:
        'A 30-meter Roman triumphal column in Alexandria, erected in 297 AD in honor of Emperor Diocletian. The largest of its kind constructed outside of Rome and the imperial capitals.',
    descriptionAr:
        'عمود بومبي عمود ضخم من الجرانيت يعود للعصر الروماني، يبلغ ارتفاعه 30 متراً، وهو أعلى عمود انتصار خارج روما. أُقيم عام 297 م تكريماً للإمبراطور دقلديانوس.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/a/aa/Pompey%27s_Pillar_%28Archaeological_site_in_Alexandria_2017%29_%2C_photo_by_Hatem_moushir_9.jpg',
    rating: 4.5,
    category: 'Historical',
    categoryAr: 'تاريخي',
    lat: 31.1825,
    lng: 29.8967,
    address: 'Carmous, Alexandria',
    addressAr: 'كرموز، الإسكندرية',
    openHours: '9:00 AM - 5:00 PM',
    reviewCount: 980,
    priceLevel: PriceLevel.cheap,
    priceNote: 'Adults',
    priceNoteAr: 'للكبار',
    priceLocalEgp: 20,
    priceForeignerEgp: 80,
    isHiddenGem: false,
  ),
  PlaceModel(
    id: 'fallback_catacombs',
    nameEn: 'Catacombs of Kom El Shoqafa',
    nameAr: 'مقابر كوم الشقافة',
    descriptionEn:
        'A historical archaeological site considered one of the Seven Wonders of the Middle Ages. A multi-level labyrinth with chambers blending Roman, Greek, and ancient Egyptian art.',
    descriptionAr:
        'مقابر كوم الشقافة من أبرز المواقع الأثرية في الإسكندرية، تُعد إحدى عجائب الدنيا السبع في العصر الوسيط. متاهة متعددة الطوابق تمزج بين الفن الروماني والمصري القديم.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/6/6e/Catacombs_of_Kom_El_Shoqafa%2C_Alexandria%2C_Egypt.jpg',
    rating: 4.6,
    category: 'Historical',
    categoryAr: 'تاريخي',
    lat: 31.1789,
    lng: 29.8922,
    address: 'Carmous, Alexandria',
    addressAr: 'كرموز، الإسكندرية',
    openHours: '9:00 AM - 4:00 PM',
    reviewCount: 1450,
    priceLevel: PriceLevel.cheap,
    priceNote: 'Adults',
    priceNoteAr: 'للكبار',
    priceLocalEgp: 20,
    priceForeignerEgp: 80,
    isHiddenGem: false,
  ),
  PlaceModel(
    id: 'fallback_corniche',
    nameEn: 'Alexandria Corniche',
    nameAr: 'كورنيش الإسكندرية',
    descriptionEn:
        'A scenic waterfront promenade along the Mediterranean Sea stretching about 15 km. Perfect for sunset walks with stunning views.',
    descriptionAr:
        'كورنيش الإسكندرية ممشى ساحلي خلاب يمتد على طول البحر المتوسط. من أجمل الكورنيشات في مصر، مثالي لجلسات الغروب والتنزه مع الأسرة.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/7/71/Egypt%2C_Alexandria%2C_The_Corniche_of_Alexandria.jpg',
    rating: 4.7,
    category: 'Streets',
    categoryAr: 'شوارع',
    lat: 31.2460,
    lng: 29.9660,
    address: 'Corniche, Alexandria',
    addressAr: 'الكورنيش، الإسكندرية',
    openHours: 'Open 24 hours',
    reviewCount: 3200,
    priceLevel: PriceLevel.free,
    priceNote: 'Free',
    priceNoteAr: 'مجاني',
    priceLocalEgp: 0,
    priceForeignerEgp: 0,
    isHiddenGem: false,
  ),
  PlaceModel(
    id: 'fallback_montaza',
    nameEn: 'Montaza Palace Gardens',
    nameAr: 'حدائق المنتزه',
    descriptionEn:
        'Royal gardens surrounding the Khedive Abbas palace — a 150-acre green oasis by the Mediterranean. One of Egypt\'s favourite summer retreats for over a century.',
    descriptionAr:
        'حدائق المنتزه الملكية خضراء غناء تحيط بقصر المنتزه التاريخي الذي بناه الخديوي عباس. واحة طبيعية خلابة تطل على البحر المتوسط وتجمع بين الجمال والتاريخ.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/b/b6/Montaza_Palace_Gardens.png',
    imageUrls: [
      'https://upload.wikimedia.org/wikipedia/commons/d/dd/Lighthouse_beside_the_Montaza_garden_in_Alexandria.jpg',
    ],
    rating: 4.5,
    category: 'Nature',
    categoryAr: 'طبيعة',
    lat: 31.2890,
    lng: 30.0160,
    address: 'Montaza, Alexandria',
    addressAr: 'المنتزه، الإسكندرية',
    openHours: '8:00 AM - 10:00 PM',
    reviewCount: 1850,
    priceLevel: PriceLevel.free,
    priceNote: 'Garden free, palace 25 EGP',
    priceNoteAr: 'الحديقة مجانية، القصر 25 جنيه',
    priceLocalEgp: 0,
    priceForeignerEgp: 25,
    isHiddenGem: false,
  ),
  PlaceModel(
    id: 'fallback_attarine',
    nameEn: 'El-Attarine Mosque',
    nameAr: 'مسجد العطارين',
    descriptionEn:
        'A historic mosque in the old heart of Alexandria. Built on the ruins of the Church of St. Athanasius and still preserving its ancient granite columns.',
    descriptionAr:
        'مسجد العطارين أحد المساجد التاريخية العريقة في قلب الإسكندرية القديمة. يعود تاريخه للعصر المملوكي ويتميز بزخارفه الإسلامية الرائعة وروحانيته العالية.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg',
    rating: 4.3,
    category: 'Mosques',
    categoryAr: 'مساجد',
    lat: 31.1990,
    lng: 29.8970,
    address: 'Attarine, Alexandria',
    addressAr: 'العطارين، الإسكندرية',
    openHours: '9:00 AM - 9:00 PM',
    reviewCount: 420,
    priceLevel: PriceLevel.free,
    priceNote: 'Free',
    priceNoteAr: 'مجاني',
    priceLocalEgp: 0,
    priceForeignerEgp: 0,
    isHiddenGem: true,
  ),
  PlaceModel(
    id: 'fallback_stmark',
    nameEn: 'St. Mark Coptic Orthodox Cathedral',
    nameAr: 'كاتدرائية القديس مرقس القبطية',
    descriptionEn:
        'The historic seat of the Coptic Pope in Alexandria — the oldest Coptic Orthodox church in Africa and the second papal residence in Egypt after Cairo.',
    descriptionAr:
        'كاتدرائية القديس مرقس الأرثوذكسية مقر البابا الكوبي التاريخي في الإسكندرية. تجمع بين الإرث الكنسي الأصيل والعمارة الحديثة في قلب مدينة الإسكندرية.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg',
    rating: 4.6,
    category: 'Churches',
    categoryAr: 'كنائس',
    lat: 31.2056,
    lng: 29.9110,
    address: 'Raml Station, Alexandria',
    addressAr: 'محطة الرمل، الإسكندرية',
    openHours: '8:00 AM - 8:00 PM',
    reviewCount: 380,
    priceLevel: PriceLevel.free,
    priceNote: 'Free',
    priceNoteAr: 'مجاني',
    priceLocalEgp: 0,
    priceForeignerEgp: 0,
    isHiddenGem: false,
  ),
];

const List<ItineraryModel> _seedTours = fallbackTours;

const List<ItineraryModel> fallbackTours = [
  ItineraryModel(
    id: 'tour_historical',
    title: 'Historical Alexandria',
    titleAr: 'الإسكندرية التاريخية',
    description:
        'Walk through the ancient glories of Alexandria — from Roman columns to Ptolemaic tombs and the iconic Qaitbay Citadel.',
    descriptionAr:
        'تجوّل في أمجاد الإسكندرية القديمة — من الأعمدة الرومانية إلى مقابر البطالمة وقلعة قايتباي الأيقونية.',
    duration: 'Full Day',
    durationAr: 'يوم كامل',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/0/0d/Citadel_of_Qaitbay_014.JPG',
    places: [
      PlaceModel(
        id: 'fallback_qaitbay',
        nameEn: 'Citadel of Qaitbay',
        nameAr: 'قلعة قايتباي',
        descriptionEn:
            'A 15th-century fortress built on the ruins of the ancient Lighthouse of Alexandria.',
        descriptionAr:
            'قلعة قايتباي هي حصن دفاعي يعود للقرن الخامس عشر الميلادي، مبني على أنقاض منارة الإسكندرية القديمة، إحدى عجائب الدنيا السبع. تقع على شاطئ البحر المتوسط وتتميز بمعمارها الأيوبي الرائع.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/0/0d/Citadel_of_Qaitbay_014.JPG',
        rating: 4.7,
        category: 'Historical',
        categoryAr: 'تاريخي',
        lat: 31.2141,
        lng: 29.8856,
        address: 'Eastern Harbor, Alexandria',
        addressAr: 'الميناء الشرقي، الإسكندرية',
        openHours: '9:00 AM - 5:00 PM',
        reviewCount: 1240,
        priceLevel: PriceLevel.cheap,
        priceNote: 'Adults',
        priceNoteAr: 'للكبار',
        priceLocalEgp: 20,
        priceForeignerEgp: 80,
      ),
      PlaceModel(
        id: 'fallback_pompey',
        nameEn: "Pompey's Pillar",
        nameAr: 'عمود السواري',
        descriptionEn:
            'The tallest ancient monument in Alexandria, a Roman triumphal column from 297 AD.',
        descriptionAr:
            'عمود بومبي عمود ضخم من الجرانيت يعود للعصر الروماني، يبلغ ارتفاعه 30 متراً، وهو أعلى عمود انتصار خارج روما. أُقيم عام 297 م تكريماً للإمبراطور دقلديانوس.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/a/aa/Pompey%27s_Pillar_%28Archaeological_site_in_Alexandria_2017%29_%2C_photo_by_Hatem_moushir_9.jpg',
        rating: 4.5,
        category: 'Historical',
        categoryAr: 'تاريخي',
        lat: 31.1825,
        lng: 29.8967,
        address: 'Carmous, Alexandria',
        addressAr: 'كرموز، الإسكندرية',
        openHours: '9:00 AM - 5:00 PM',
        reviewCount: 980,
        priceLevel: PriceLevel.cheap,
        priceNote: 'Adults',
        priceNoteAr: 'للكبار',
        priceLocalEgp: 20,
        priceForeignerEgp: 80,
      ),
      PlaceModel(
        id: 'fallback_catacombs',
        nameEn: 'Catacombs of Kom El Shoqafa',
        nameAr: 'مقابر كوم الشقافة',
        descriptionEn:
            'A multi-level labyrinth considered one of the Seven Wonders of the Middle Ages.',
        descriptionAr:
            'مقابر كوم الشقافة من أبرز المواقع الأثرية في الإسكندرية، تُعد إحدى عجائب الدنيا السبع في العصر الوسيط. متاهة متعددة الطوابق تمزج بين الفن الروماني والمصري القديم.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/6/6e/Catacombs_of_Kom_El_Shoqafa%2C_Alexandria%2C_Egypt.jpg',
        rating: 4.6,
        category: 'Historical',
        categoryAr: 'تاريخي',
        lat: 31.1789,
        lng: 29.8922,
        address: 'Carmous, Alexandria',
        addressAr: 'كرموز، الإسكندرية',
        openHours: '9:00 AM - 4:00 PM',
        reviewCount: 1450,
        priceLevel: PriceLevel.cheap,
        priceNote: 'Adults',
        priceNoteAr: 'للكبار',
        priceLocalEgp: 20,
        priceForeignerEgp: 80,
      ),
      PlaceModel(
        id: 'fallback_biblio',
        nameEn: 'Bibliotheca Alexandrina',
        nameAr: 'مكتبة الإسكندرية',
        descriptionEn:
            'A modern library opened in 2002, inspired by the ancient Library of Alexandria.',
        descriptionAr:
            'مكتبة الإسكندرية الجديدة صرح ثقافي ضخم على شاطئ البحر المتوسط، تجسيد معاصر للمكتبة الأسطورية التي كانت مركزاً للعلوم والمعرفة في العالم القديم. تضم مليوني كتاب ومتاحف وقاعات عروض.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/3/37/Egypt%2C_Alexandria%2C_Bibliotheca_Alexandrina.jpg',
        rating: 4.8,
        category: 'Culture',
        categoryAr: 'ثقافة',
        lat: 31.2092,
        lng: 29.9085,
        address: 'El Shatby, Alexandria',
        addressAr: 'الشاطبي، الإسكندرية',
        openHours: '10:00 AM - 7:00 PM',
        reviewCount: 2890,
        priceLevel: PriceLevel.free,
        priceNote: 'Free entry',
        priceNoteAr: 'دخول مجاني',
        priceLocalEgp: 0,
        priceForeignerEgp: 0,
      ),
    ],
  ),
  ItineraryModel(
    id: 'tour_coastal',
    title: 'Coastal Alexandria',
    titleAr: 'إسكندرية الساحل',
    description:
        'Experience the beauty of the Mediterranean — sandy beaches, the stunning Corniche, and the lush Montaza gardens.',
    descriptionAr:
        'استمتع بجمال البحر المتوسط — الشواطئ الرملية والكورنيش الخلاب وحدائق المنتزه الوارفة.',
    duration: '4 Hours',
    durationAr: '4 ساعات',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/7/71/Egypt%2C_Alexandria%2C_The_Corniche_of_Alexandria.jpg',
    places: [
      PlaceModel(
        id: 'fallback_corniche',
        nameEn: 'Alexandria Corniche',
        nameAr: 'كورنيش الإسكندرية',
        descriptionEn:
            'A scenic 15 km waterfront promenade along the Mediterranean — perfect for sunset walks.',
        descriptionAr:
            'كورنيش الإسكندرية ممشى ساحلي خلاب يمتد على طول البحر المتوسط. من أجمل الكورنيشات في مصر، مثالي لجلسات الغروب والتنزه مع الأسرة.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/7/71/Egypt%2C_Alexandria%2C_The_Corniche_of_Alexandria.jpg',
        rating: 4.7,
        category: 'Streets',
        categoryAr: 'شوارع',
        lat: 31.2460,
        lng: 29.9660,
        address: 'Corniche, Alexandria',
        addressAr: 'الكورنيش، الإسكندرية',
        openHours: 'Open 24 hours',
        reviewCount: 3200,
        priceLevel: PriceLevel.free,
        priceNote: 'Free',
        priceNoteAr: 'مجاني',
        priceLocalEgp: 0,
        priceForeignerEgp: 0,
      ),
      PlaceModel(
        id: 'fallback_montaza',
        nameEn: 'Montaza Palace Gardens',
        nameAr: 'حدائق المنتزه',
        descriptionEn:
            'Beautiful royal gardens surrounding the Khedive Abbas palace — a green oasis by the sea.',
        descriptionAr:
            'حدائق المنتزه الملكية خضراء غناء تحيط بقصر المنتزه التاريخي الذي بناه الخديوي عباس. واحة طبيعية خلابة تطل على البحر المتوسط وتجمع بين الجمال والتاريخ.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/b/b6/Montaza_Palace_Gardens.png',
        rating: 4.5,
        category: 'Nature',
        categoryAr: 'طبيعة',
        lat: 31.2890,
        lng: 30.0160,
        address: 'Montaza, Alexandria',
        addressAr: 'المنتزه، الإسكندرية',
        openHours: '8:00 AM - 10:00 PM',
        reviewCount: 1850,
        priceLevel: PriceLevel.free,
        priceNote: 'Garden free, palace 25 EGP',
        priceNoteAr: 'الحديقة مجانية، القصر 25 جنيه',
        priceLocalEgp: 0,
        priceForeignerEgp: 25,
      ),
    ],
  ),
  ItineraryModel(
    id: 'tour_spiritual',
    title: 'Sacred Landmarks',
    titleAr: 'الأماكن المقدسة',
    description:
        'Explore the spiritual heart of Alexandria — historic mosques and ancient Coptic cathedrals side by side.',
    descriptionAr:
        'استكشف قلب الإسكندرية الروحي — مساجد تاريخية وكنائس قبطية عريقة جنباً إلى جنب.',
    duration: '3 Hours',
    durationAr: '3 ساعات',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg',
    places: [
      PlaceModel(
        id: 'fallback_attarine',
        nameEn: 'El-Attarine Mosque',
        nameAr: 'مسجد العطارين',
        descriptionEn:
            'A historic Mamluk-era mosque in the old heart of Alexandria with intricate architectural details.',
        descriptionAr:
            'مسجد العطارين أحد المساجد التاريخية العريقة في قلب الإسكندرية القديمة. يعود تاريخه للعصر المملوكي ويتميز بزخارفه الإسلامية الرائعة وروحانيته العالية.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/5/5c/AlexAttarinOutside.jpg',
        rating: 4.3,
        category: 'Mosques',
        categoryAr: 'مساجد',
        lat: 31.1990,
        lng: 29.8970,
        address: 'Attarine, Alexandria',
        addressAr: 'العطارين، الإسكندرية',
        openHours: '9:00 AM - 9:00 PM',
        reviewCount: 420,
        priceLevel: PriceLevel.free,
        priceNote: 'Free',
        priceNoteAr: 'مجاني',
        priceLocalEgp: 0,
        priceForeignerEgp: 0,
        isHiddenGem: true,
      ),
      PlaceModel(
        id: 'fallback_stmark',
        nameEn: 'St. Mark Coptic Orthodox Cathedral',
        nameAr: 'كاتدرائية القديس مرقس القبطية',
        descriptionEn:
            'The historic seat of the Coptic Pope in Alexandria — blending ancient heritage and modern architecture.',
        descriptionAr:
            'كاتدرائية القديس مرقس الأرثوذكسية مقر البابا الكوبي التاريخي في الإسكندرية. تجمع بين الإرث الكنسي الأصيل والعمارة الحديثة في قلب مدينة الإسكندرية.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/8/81/AlexMarkCathedralFront.jpg',
        rating: 4.6,
        category: 'Churches',
        categoryAr: 'كنائس',
        lat: 31.2056,
        lng: 29.9110,
        address: 'Raml Station, Alexandria',
        addressAr: 'محطة الرمل، الإسكندرية',
        openHours: '8:00 AM - 8:00 PM',
        reviewCount: 380,
        priceLevel: PriceLevel.free,
        priceNote: 'Free',
        priceNoteAr: 'مجاني',
        priceLocalEgp: 0,
        priceForeignerEgp: 0,
      ),
    ],
  ),
];

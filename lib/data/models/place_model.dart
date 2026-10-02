enum PriceLevel {
  free,
  cheap,
  moderate,
  expensive;

  String get label {
    switch (this) {
      case PriceLevel.free:
        return 'Free';
      case PriceLevel.cheap:
        return 'EGP 25-50';
      case PriceLevel.moderate:
        return 'EGP 50-150';
      case PriceLevel.expensive:
        return 'EGP 150+';
    }
  }

  static PriceLevel fromName(String? name) {
    switch (name) {
      case 'cheap':
        return PriceLevel.cheap;
      case 'moderate':
        return PriceLevel.moderate;
      case 'expensive':
        return PriceLevel.expensive;
      case 'free':
      default:
        return PriceLevel.free;
    }
  }
}

class PlaceModel {
  final String id;
  final String nameEn;
  final String? nameAr;
  final String descriptionEn;
  final String? descriptionAr;
  final String imageUrl;
  final List<String> imageUrls;
  final double rating;
  final String category;
  final String? categoryAr;
  final double lat;
  final double lng;
  final String address;
  final String? addressAr;
  final String openHours;
  final int reviewCount;
  final PriceLevel priceLevel;
  final String priceNote;
  final String? priceNoteAr;
  final bool isHiddenGem;
  final int? priceLocalEgp;
  final int? priceForeignerEgp;

  final Map<String, int>? bestTimeOverride;

  final String? bestTimeNote;

  final String? bestTimeToVisit;

  final bool isIndoor;

  const PlaceModel({
    required this.id,
    required this.nameEn,
    this.nameAr,
    required this.descriptionEn,
    this.descriptionAr,
    required this.imageUrl,
    this.imageUrls = const <String>[],
    required this.rating,
    this.category = 'General',
    this.categoryAr,
    required this.lat,
    required this.lng,
    this.address = 'Alexandria, Egypt',
    this.addressAr,
    this.openHours = '9:00 AM - 6:00 PM',
    this.reviewCount = 0,
    this.priceLevel = PriceLevel.free,
    this.priceNote = '',
    this.priceNoteAr,
    this.isHiddenGem = false,
    this.priceLocalEgp,
    this.priceForeignerEgp,
    this.bestTimeOverride,
    this.bestTimeNote,
    this.bestTimeToVisit,
    this.isIndoor = false,
  });

  String _pick(String en, String? ar, String locale) {
    if (locale == 'ar' && ar != null && ar.isNotEmpty) return ar;
    return en;
  }

  String localizedName(String locale) => _pick(nameEn, nameAr, locale);
  String localizedDescription(String locale) =>
      _pick(descriptionEn, descriptionAr, locale);
  String localizedCategory(String locale) => _pick(category, categoryAr, locale);
  String localizedAddress(String locale) => _pick(address, addressAr, locale);
  String localizedPriceNote(String locale) =>
      _pick(priceNote, priceNoteAr, locale);

  bool get isFree => priceLevel == PriceLevel.free;

  bool get hasDualPrice => priceLocalEgp != null && priceForeignerEgp != null;

  /// All official images for this place, in display order.
  /// Falls back to [imageUrl] when [imageUrls] is empty (so older rows
  /// or pre-migration places still render correctly).
  List<String> get officialImages {
    final list = <String>[];
    for (final u in imageUrls) {
      if (u.isNotEmpty) list.add(u);
    }
    if (list.isEmpty && imageUrl.isNotEmpty) list.add(imageUrl);
    return list;
  }

  String get primaryImage => officialImages.isNotEmpty
      ? officialImages.first
      : imageUrl;

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    Map<String, int>? bestTimeOverride;
    final raw = json['best_time_override'];
    if (raw is Map) {
      bestTimeOverride = raw.map(
        (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      );
    }
    final urlsRaw = json['image_urls'] ?? json['imageUrls'];
    List<String> urls = const <String>[];
    if (urlsRaw is List) {
      urls = urlsRaw
          .where((e) => e != null)
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList(growable: false);
    }
    return PlaceModel(
      id: json['id'] as String,
      nameEn: (json['name_en'] as String?) ??
          (json['name'] as String?) ??
          (json['nameEn'] as String?) ??
          '',
      nameAr:
          json['name_ar'] as String? ??
          json['nameAr'] as String?,
      descriptionEn: (json['description_en'] as String?) ??
          (json['description'] as String?) ??
          (json['descriptionEn'] as String?) ??
          '',
      descriptionAr:
          json['description_ar'] as String? ?? json['descriptionAr'] as String?,
      imageUrl: json['imageUrl'] as String,
      imageUrls: urls,
      rating: (json['rating'] as num).toDouble(),
      category: json['category'] as String? ?? 'General',
      categoryAr: json['category_ar'] as String? ?? json['categoryAr'] as String?,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? 'Alexandria, Egypt',
      addressAr: json['address_ar'] as String? ?? json['addressAr'] as String?,
      openHours: json['openHours'] as String? ?? '9:00 AM - 6:00 PM',
      reviewCount: json['reviewCount'] as int? ?? 0,
      priceLevel: PriceLevel.fromName(json['priceLevel'] as String?),
      priceNote: json['priceNote'] as String? ?? '',
      priceNoteAr: json['price_note_ar'] as String? ?? json['priceNoteAr'] as String?,
      isHiddenGem: json['isHiddenGem'] as bool? ?? false,
      priceLocalEgp: json['priceLocalEgp'] as int?,
      priceForeignerEgp: json['priceForeignerEgp'] as int?,
      bestTimeOverride: bestTimeOverride,
      bestTimeNote: json['best_time_note'] as String?,
      bestTimeToVisit: json['best_time_to_visit'] as String?,
      isIndoor: json['is_indoor'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'imageUrl': imageUrl,
      'rating': rating,
      'category': category,
      'category_ar': categoryAr,
      'lat': lat,
      'lng': lng,
      'address': address,
      'address_ar': addressAr,
      'openHours': openHours,
      'reviewCount': reviewCount,
      'priceLevel': priceLevel.name,
      'priceNote': priceNote,
      'price_note_ar': priceNoteAr,
      'isHiddenGem': isHiddenGem,
      'priceLocalEgp': priceLocalEgp,
      'priceForeignerEgp': priceForeignerEgp,
      'best_time_override': bestTimeOverride,
      'best_time_note': bestTimeNote,
      'best_time_to_visit': bestTimeToVisit,
      'is_indoor': isIndoor,
    };
  }

  PlaceModel copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? imageUrl,
    double? rating,
    String? category,
    String? categoryAr,
    double? lat,
    double? lng,
    String? address,
    String? addressAr,
    String? openHours,
    int? reviewCount,
    PriceLevel? priceLevel,
    String? priceNote,
    String? priceNoteAr,
    bool? isHiddenGem,
    int? priceLocalEgp,
    int? priceForeignerEgp,
    Map<String, int>? bestTimeOverride,
    String? bestTimeNote,
    String? bestTimeToVisit,
    bool? isIndoor,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      categoryAr: categoryAr ?? this.categoryAr,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      addressAr: addressAr ?? this.addressAr,
      openHours: openHours ?? this.openHours,
      reviewCount: reviewCount ?? this.reviewCount,
      priceLevel: priceLevel ?? this.priceLevel,
      priceNote: priceNote ?? this.priceNote,
      priceNoteAr: priceNoteAr ?? this.priceNoteAr,
      isHiddenGem: isHiddenGem ?? this.isHiddenGem,
      priceLocalEgp: priceLocalEgp ?? this.priceLocalEgp,
      priceForeignerEgp: priceForeignerEgp ?? this.priceForeignerEgp,
      bestTimeOverride: bestTimeOverride ?? this.bestTimeOverride,
      bestTimeNote: bestTimeNote ?? this.bestTimeNote,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      isIndoor: isIndoor ?? this.isIndoor,
    );
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String tier;
  final DateTime? earnedAt;
  final int pointsAwarded;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.tier,
    this.earnedAt,
    this.pointsAwarded = 0,
  });
}

class GamificationStats {
  final String userId;
  final String userName;
  final String? avatarColorHex;
  final int totalPoints;
  final int placesVisited;
  final int reviewsPosted;
  final int photosUploaded;
  final List<Badge> badges;
  final String level;

  // v1.0.56: streak snapshot reflected into the stats object so
  // the UI never reads a value out of sync with the StreakProvider.
  final int currentStreak;
  final int longestStreak;
  final int totalVisitDays;
  final DateTime? lastVisitDate;

  const GamificationStats({
    required this.userId,
    required this.userName,
    this.avatarColorHex,
    this.totalPoints = 0,
    this.placesVisited = 0,
    this.reviewsPosted = 0,
    this.photosUploaded = 0,
    this.badges = const [],
    this.level = 'Explorer',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalVisitDays = 0,
    this.lastVisitDate,
  });

  GamificationStats copyWith({
    int? totalPoints,
    int? placesVisited,
    int? reviewsPosted,
    int? photosUploaded,
    List<Badge>? badges,
    String? level,
    int? currentStreak,
    int? longestStreak,
    int? totalVisitDays,
    DateTime? lastVisitDate,
  }) => GamificationStats(
        userId: userId,
        userName: userName,
        avatarColorHex: avatarColorHex,
        totalPoints: totalPoints ?? this.totalPoints,
        placesVisited: placesVisited ?? this.placesVisited,
        reviewsPosted: reviewsPosted ?? this.reviewsPosted,
        photosUploaded: photosUploaded ?? this.photosUploaded,
        badges: badges ?? this.badges,
        level: level ?? this.level,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        totalVisitDays: totalVisitDays ?? this.totalVisitDays,
        lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_name': userName,
        'avatar_color_hex': avatarColorHex,
        'total_points': totalPoints,
        'places_visited': placesVisited,
        'reviews_posted': reviewsPosted,
        'photos_uploaded': photosUploaded,
        'badges': badges
            .map(
              (b) => {
                'id': b.id,
                'name': b.name,
                'description': b.description,
                'icon_name': b.iconName,
                'tier': b.tier,
                'earned_at': b.earnedAt?.toIso8601String(),
                'points_awarded': b.pointsAwarded,
              },
            )
            .toList(),
        'level': level,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'total_visit_days': totalVisitDays,
        'last_visit_date': lastVisitDate?.toIso8601String(),
      };

  factory GamificationStats.fromJson(Map<String, dynamic> json) =>
      GamificationStats(
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        avatarColorHex: json['avatar_color_hex'] as String?,
        totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
        placesVisited: (json['places_visited'] as num?)?.toInt() ?? 0,
        reviewsPosted: (json['reviews_posted'] as num?)?.toInt() ?? 0,
        photosUploaded: (json['photos_uploaded'] as num?)?.toInt() ?? 0,
        badges: ((json['badges'] as List<dynamic>?) ?? const [])
            .map(
              (b) => Badge(
                id: b['id'] as String,
                name: b['name'] as String,
                description: b['description'] as String,
                iconName: b['icon_name'] as String,
                tier: b['tier'] as String,
                earnedAt: b['earned_at'] == null
                    ? null
                    : DateTime.parse(b['earned_at'] as String),
                pointsAwarded: (b['points_awarded'] as num?)?.toInt() ?? 0,
              ),
            )
            .toList(),
        level: json['level'] as String? ?? 'Explorer',
        currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
        longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
        totalVisitDays: (json['total_visit_days'] as num?)?.toInt() ?? 0,
        lastVisitDate: json['last_visit_date'] == null
            ? null
            : DateTime.parse(json['last_visit_date'] as String),
      );

  static String levelForPoints(int points) {
    if (points >= 5000) return 'Lorekeeper';
    if (points >= 2000) return 'Cartographer';
    if (points >= 500) return 'Wanderer';
    return 'Explorer';
  }

  static int pointsFor(String action) {
    switch (action) {
      case 'check_in':
        return 50;
      case 'review':
        return 20;
      case 'photo':
        return 30;
      case 'chat_message':
        return 2;
      default:
        return 0;
    }
  }
}
class OfflinePack {
  final String id;
  final String name;
  final String description;
  
  
  final List<String> placeIds;
  
  
  final List<String> categories;
  final int sizeMb;
  final DateTime? downloadedAt;
  final String coverEmoji;

  const OfflinePack({
    required this.id,
    required this.name,
    required this.description,
    this.placeIds = const [],
    this.categories = const [],
    this.sizeMb = 0,
    this.downloadedAt,
    this.coverEmoji = '',
  });

  bool get isDownloaded => downloadedAt != null;

  OfflinePack copyWith({DateTime? downloadedAt}) => OfflinePack(
    id: id,
    name: name,
    description: description,
    placeIds: placeIds,
    categories: categories,
    sizeMb: sizeMb,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    coverEmoji: coverEmoji,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'place_ids': placeIds,
    'categories': categories,
    'size_mb': sizeMb,
    'downloaded_at': downloadedAt?.toIso8601String(),
    'cover_emoji': coverEmoji,
  };

  factory OfflinePack.fromJson(Map<String, dynamic> json) => OfflinePack(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    placeIds: ((json['place_ids'] as List<dynamic>?) ?? const [])
        .cast<String>(),
    categories: ((json['categories'] as List<dynamic>?) ?? const [])
        .cast<String>(),
    sizeMb: (json['size_mb'] as num?)?.toInt() ?? 0,
    downloadedAt: json['downloaded_at'] == null
        ? null
        : DateTime.parse(json['downloaded_at'] as String),
    coverEmoji: json['cover_emoji'] as String? ?? '',
  );
}

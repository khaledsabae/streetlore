import 'place_model.dart';

class ItineraryModel {
  final String id;
  final String title;
  final String? titleAr;
  final String description;
  final String? descriptionAr;
  final String duration;
  final String imageUrl;
  final List<PlaceModel> places;
  const ItineraryModel({
    required this.id,
    required this.title,
    this.titleAr,
    required this.description,
    this.descriptionAr,
    required this.duration,
    required this.imageUrl,
    required this.places,
  });

  
  String localizedTitle(String locale) {
    if (locale == 'ar' && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return title;
  }

  
  String localizedDescription(String locale) {
    if (locale == 'ar' && descriptionAr != null && descriptionAr!.isNotEmpty) {
      return descriptionAr!;
    }
    return description;
  }

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String? ?? json['titleAr'] as String?,
      description: json['description'] as String,
      descriptionAr:
          json['description_ar'] as String? ?? json['descriptionAr'] as String?,
      duration: json['duration'] as String,
      imageUrl: json['imageUrl'] as String,
      places:
          (json['places'] as List<dynamic>?)
              ?.map((e) => PlaceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleAr': titleAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'duration': duration,
      'imageUrl': imageUrl,
      'places': places.map((e) => e.toJson()).toList(),
    };
  }
}

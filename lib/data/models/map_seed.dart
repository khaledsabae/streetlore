import 'package:flutter/material.dart';

import '../models/place_model.dart';
import 'map_poi.dart';












List<MapPoi> getSeedAtms() => _atms;

List<MapPoi> getSeedHotels() => _hotels;





List<PlaceModel> getSeedHotelPlaces() => _hotelPlaces;

const Map<String, Color> _bankColors = {
  'CIB': Color(0xFFED1C24),
  'NBE': Color(0xFF0033A0),
  'QNB': Color(0xFF8B1A1A),
  'Banque Misr': Color(0xFF1F4E79),
  'Alex Bank': Color(0xFFB22222),
  'HSBC': Color(0xFFDB0011),
  'Cairo Bank': Color(0xFF2E7D32),
  'Faisal Bank': Color(0xFF6A1B9A),
  'Arab Bank': Color(0xFF00695C),
  'AAIB': Color(0xFF8E24AA),
};

List<MapPoi> _atms = const [
  
  MapPoi(
    id: 'atm-cib-qaid-bay',
    name: 'CIB ATM - Qaitbay Citadel',
    address: 'Qaitbay Citadel entrance, Anfushi',
    lat: 31.2133,
    lng: 29.8858,
    category: 'atm',
    brand: 'CIB',
    icon: Icons.atm_rounded,
    color: Color(0xFFED1C24),
  ),
  MapPoi(
    id: 'atm-nbe-sidi-gaber',
    name: 'NBE ATM - Sidi Gaber Station',
    address: 'Sidi Gaber Station square',
    lat: 31.2137,
    lng: 29.9487,
    category: 'atm',
    brand: 'NBE',
    icon: Icons.atm_rounded,
    color: Color(0xFF0033A0),
  ),
  MapPoi(
    id: 'atm-banque-misr-raml',
    name: 'Banque Misr ATM - Raml Station',
    address: 'Raml Station forecourt',
    lat: 31.1971,
    lng: 29.9172,
    category: 'atm',
    brand: 'Banque Misr',
    icon: Icons.atm_rounded,
    color: Color(0xFF1F4E79),
  ),
  MapPoi(
    id: 'atm-alex-bank-manshia',
    name: 'Alex Bank ATM - Manshia',
    address: 'Saad Zaghloul Square area',
    lat: 31.1967,
    lng: 29.9126,
    category: 'atm',
    brand: 'Alex Bank',
    icon: Icons.atm_rounded,
    color: Color(0xFFB22222),
  ),
  MapPoi(
    id: 'atm-qnb-moharam-bek',
    name: 'QNB ATM - Moharam Bek',
    address: 'Abou El Fath St.',
    lat: 31.1922,
    lng: 29.9157,
    category: 'atm',
    brand: 'QNB',
    icon: Icons.atm_rounded,
    color: Color(0xFF8B1A1A),
  ),
  MapPoi(
    id: 'atm-faisal-stanley',
    name: 'Faisal Islamic Bank ATM - Stanley',
    address: 'Stanley Bay promenade',
    lat: 31.2312,
    lng: 29.9336,
    category: 'atm',
    brand: 'Faisal Bank',
    icon: Icons.atm_rounded,
    color: Color(0xFF6A1B9A),
  ),
  MapPoi(
    id: 'atm-hsbc-roshdy',
    name: 'HSBC ATM - Roushdy',
    address: 'Roushdy junction, Abu Qir St.',
    lat: 31.2372,
    lng: 29.9635,
    category: 'atm',
    brand: 'HSBC',
    icon: Icons.atm_rounded,
    color: Color(0xFFDB0011),
  ),
  MapPoi(
    id: 'atm-cairo-bank-attarine',
    name: 'Cairo Bank ATM - Attarine',
    address: 'Attarine district',
    lat: 31.1989,
    lng: 29.8989,
    category: 'atm',
    brand: 'Cairo Bank',
    icon: Icons.atm_rounded,
    color: Color(0xFF2E7D32),
  ),
  MapPoi(
    id: 'atm-aaib-miami',
    name: 'AAIB ATM - Miami',
    address: 'Miami (Abu Qir) main road',
    lat: 31.2651,
    lng: 30.0012,
    category: 'atm',
    brand: 'AAIB',
    icon: Icons.atm_rounded,
    color: Color(0xFF8E24AA),
  ),
  MapPoi(
    id: 'atm-arab-bank-smouha',
    name: 'Arab Bank ATM - Smouha',
    address: 'Smouha main square',
    lat: 31.2158,
    lng: 29.9628,
    category: 'atm',
    brand: 'Arab Bank',
    icon: Icons.atm_rounded,
    color: Color(0xFF00695C),
  ),
  MapPoi(
    id: 'atm-cib-bibliotheca',
    name: 'CIB ATM - Bibliotheca Alexandrina',
    address: 'Bibliotheca plaza, Al Cornish',
    lat: 31.2092,
    lng: 29.9093,
    category: 'atm',
    brand: 'CIB',
    icon: Icons.atm_rounded,
    color: Color(0xFFED1C24),
  ),
  MapPoi(
    id: 'atm-cib-montaza',
    name: 'CIB ATM - Montaza Palace',
    address: 'Montaza Palace gates',
    lat: 31.2882,
    lng: 29.9812,
    category: 'atm',
    brand: 'CIB',
    icon: Icons.atm_rounded,
    color: Color(0xFFED1C24),
  ),
];

List<MapPoi> _hotels = const [
  MapPoi(
    id: 'hotel-four-seasons',
    name: 'Four Seasons Hotel Alexandria',
    address: '399 El Geish Rd, San Stefano',
    lat: 31.2452,
    lng: 29.9659,
    category: 'hotel',
    brand: 'Four Seasons',
    stars: 5,
    icon: Icons.hotel_class_rounded,
    color: Color(0xFFC8A24B),
  ),
  MapPoi(
    id: 'hotel-sofitel-alex',
    name: 'Sofitel Alexandria Cecil',
    address: '16 Kaied Abdul Latif, Manshia',
    lat: 31.1989,
    lng: 29.9089,
    category: 'hotel',
    brand: 'Sofitel',
    stars: 4,
    icon: Icons.hotel_rounded,
    color: Color(0xFFB7003F),
  ),
  MapPoi(
    id: 'hotel-steigenberger-cerine',
    name: 'Steigenberger Cecil - Cerine',
    address: 'El Geish Rd, San Stefano',
    lat: 31.2441,
    lng: 29.9667,
    category: 'hotel',
    brand: 'Steigenberger',
    stars: 5,
    icon: Icons.hotel_class_rounded,
    color: Color(0xFF8A6E2F),
  ),
  MapPoi(
    id: 'hotel-tolip-alex',
    name: 'Tolip Alexandria',
    address: 'Moustafa Kamel, Corniche Rd',
    lat: 31.1998,
    lng: 29.9321,
    category: 'hotel',
    brand: 'Tolip',
    stars: 4,
    icon: Icons.hotel_rounded,
    color: Color(0xFF1E5A8A),
  ),
  MapPoi(
    id: 'hotel-paradise',
    name: 'Paradise Inn Hotel',
    address: '221 Sultan Hussein St, Anfushi',
    lat: 31.2130,
    lng: 29.8912,
    category: 'hotel',
    brand: 'Paradise',
    stars: 3,
    icon: Icons.hotel_rounded,
    color: Color(0xFFE91E63),
  ),
  MapPoi(
    id: 'hotel-romance-alex',
    name: 'Romance Alexandria Hotel',
    address: '303 El Geish Rd, Roushdy',
    lat: 31.2395,
    lng: 29.9592,
    category: 'hotel',
    brand: 'Romance',
    stars: 4,
    icon: Icons.hotel_rounded,
    color: Color(0xFF673AB7),
  ),
  MapPoi(
    id: 'hotel-cherry',
    name: 'Cherry Maryski Hotel',
    address: '9 El Borsa El Kadeem St, Manshia',
    lat: 31.2001,
    lng: 29.9119,
    category: 'hotel',
    brand: 'Cherry',
    stars: 3,
    icon: Icons.hotel_rounded,
    color: Color(0xFFD81B60),
  ),
  MapPoi(
    id: 'hotel-plaza-alex',
    name: 'Plaza Hotel Alexandria',
    address: 'El Geish Rd, Sporting',
    lat: 31.2472,
    lng: 29.9588,
    category: 'hotel',
    brand: 'Plaza',
    stars: 3,
    icon: Icons.hotel_rounded,
    color: Color(0xFF00897B),
  ),
  MapPoi(
    id: 'hotel-king-mariout',
    name: 'King Mariout Hotel',
    address: 'Km 14, Alexandria-Cairo Desert Rd',
    lat: 31.0268,
    lng: 29.7701,
    category: 'hotel',
    brand: 'King Mariout',
    stars: 4,
    icon: Icons.hotel_rounded,
    color: Color(0xFF5D4037),
  ),
  MapPoi(
    id: 'hotel-san-stefano',
    name: 'San Stefano Grand Plaza',
    address: 'El Geish Rd, San Stefano',
    lat: 31.2449,
    lng: 29.9655,
    category: 'hotel',
    brand: 'San Stefano',
    stars: 5,
    icon: Icons.hotel_class_rounded,
    color: Color(0xFF455A64),
  ),
  MapPoi(
    id: 'hotel-downtown',
    name: 'Downtown Hotel Alexandria',
    address: '5 Mesaha Sq, Roushdy',
    lat: 31.2388,
    lng: 29.9618,
    category: 'hotel',
    brand: 'Downtown',
    stars: 3,
    icon: Icons.hotel_rounded,
    color: Color(0xFF2E7D32),
  ),
  MapPoi(
    id: 'hotel-borg-al-arab',
    name: 'Borg El Arab Airport Hotel',
    address: 'Borg El Arab International Airport',
    lat: 30.9187,
    lng: 29.6946,
    category: 'hotel',
    brand: 'Borg',
    stars: 3,
    icon: Icons.hotel_rounded,
    color: Color(0xFF3F51B5),
  ),
];



// Per-hotel image URL. Empty string means "use the placeholder icon" —
// each hotel MUST NOT share an image with another hotel or any other row.
// We have no verified unique Wikimedia Commons image for any individual
// Alexandria hotel, so every hotel currently falls back to the placeholder
// icon. Add a per-id entry ONLY with a verified unique Wikimedia URL.
const Map<String, String> _hotelImageById = {
  'hotel-four-seasons':       '',
  'hotel-sofitel-alex':       '',
  'hotel-steigenberger-cecil':'',
  'hotel-tolip':              '',
  'hotel-paradise-inn':       '',
  'hotel-romance':            '',
  'hotel-cherry-maryski':     '',
  'hotel-plaza':              '',
  'hotel-king-mariout':       '',
  'hotel-san-stefano':        '',
  'hotel-downtown':           '',
  'hotel-borg-arab':          '',
};

List<PlaceModel> _hotelPlaces = _hotels
    .map(
      (poi) => PlaceModel(
        id: poi.id,
        nameEn: poi.name,
        nameAr: null,
        descriptionEn:
            '${poi.brand ?? "Hotel"} is one of Alexandria\'s well-known '
            'stays, located at ${poi.address}. ${poi.stars != null ? "${poi.stars}-star rating. " : ""}'
            'Tap Save to bookmark, or tap Check-in when you arrive.',
        descriptionAr: null,
        imageUrl: _hotelImageById[poi.id] ?? '',
        rating: (poi.stars ?? 3).toDouble(),
        category: 'Hotels',
        categoryAr: 'فنادق',
        lat: poi.lat,
        lng: poi.lng,
        address: poi.address,
        addressAr: null,
        openHours: '24 hours',
        reviewCount: 0,
        priceLevel: poi.stars != null && poi.stars! >= 4
            ? PriceLevel.expensive
            : PriceLevel.moderate,
        priceNote: poi.stars != null && poi.stars! >= 4
            ? 'EGP ${3000 + (poi.stars ?? 3) * 1500}+ / night'
            : 'EGP ${800 + (poi.stars ?? 3) * 500}+ / night',
        priceNoteAr: null,
        priceLocalEgp: 1500,
        priceForeignerEgp: 4500,
        isHiddenGem: false,
        bestTimeNote: null,
        bestTimeToVisit: null,
        isIndoor: true,
      ),
    )
    .toList(growable: false);


Map<String, Color> get bankColors => _bankColors;

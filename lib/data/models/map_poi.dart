import 'package:flutter/material.dart';




class MapPoi {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String category; 
  
  
  final String? brand;
  final int? stars;
  final IconData icon;
  final Color color;

  const MapPoi({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.category,
    this.brand,
    this.stars,
    required this.icon,
    required this.color,
  });
}

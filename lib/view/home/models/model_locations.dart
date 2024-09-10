import 'package:google_maps_flutter/google_maps_flutter.dart';

class TempleModel {
  final String name;
  final String address;
  final LatLng latLng;
  final String imageUrl;
  final String placesId;
  final List<String> types;
  late bool _isFavorite = false;

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
  }

  get isFavorite => _isFavorite;

  TempleModel({
    required this.name,
    required this.address,
    required this.latLng,
    required this.imageUrl,
    required this.placesId,
    required this.types,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'types': types,
      'imageUrl': imageUrl,
      'placesId': placesId,
      'lat': latLng.latitude,
      'lng': latLng.longitude,
    };
  }
}

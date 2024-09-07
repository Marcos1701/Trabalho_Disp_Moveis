import 'package:google_maps_flutter/google_maps_flutter.dart';

class TempleModel {
  final String name;
  final String address;
  final LatLng latLng;
  final String imageUrl;
  final String placesId;
  final List<String> types;

  const TempleModel({
    required this.name,
    required this.address,
    required this.latLng,
    required this.imageUrl,
    required this.placesId,
    required this.types,
  });
}

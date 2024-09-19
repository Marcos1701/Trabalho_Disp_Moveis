import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trabalho_loc_ai/view/home/services/fechdata.dart';

class EstablishmentModel {
  final String name;
  final String address;
  final LatLng latLng;
  final String icon;
  final String placesId;
  final String type;
  late bool _isFavorite = false;
  final List<String> photosUrl = [];

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
  }

  get isFavorite => _isFavorite;

  EstablishmentModel({
    required this.name,
    required this.address,
    required this.latLng,
    required this.icon,
    required this.placesId,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'types': type,
      'icon': icon,
      'placesId': placesId,
      'lat': latLng.latitude,
      'lng': latLng.longitude,
      'isFavorite': _isFavorite
    };
  }

  factory EstablishmentModel.fromMap(Map<String, dynamic> map,
      {bool? isFavorite}) {
    EstablishmentModel temple = EstablishmentModel(
      name: map['name'],
      address: map['address'],
      type: map['type'],
      icon: map['icon'],
      placesId: map['placesId'],
      latLng: LatLng(map['lat'], map['lng']),
    );

    if (isFavorite != null && isFavorite) {
      temple.toggleFavorite();
    }

    return temple;
  }

  Marker toMarker(
    void Function()? onTap,
  ) {
    return Marker(
      markerId: MarkerId(placesId),
      position: latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _isFavorite ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueRed,
      ),
      onTap: onTap,
    );
  }

  InfoWindow buildInfoWindow(EstablishmentModel establishment) {
    return InfoWindow(
      title: establishment.name,
      snippet: establishment.address,
    );
  }

  Future<void> loadPhotos() async {
    if (photosUrl.isNotEmpty) {
      return;
    }
    List<String> photosLoaded = [];
    photosLoaded = await getUrlPhotos(placesId);
    photosUrl.addAll(photosLoaded);
  }
}

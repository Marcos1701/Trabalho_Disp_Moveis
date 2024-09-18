import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:trabalho_loc_ai/view/home/database/firebaseutils.dart';
import 'package:trabalho_loc_ai/models/establishment_model.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
//usando dotenv
import 'package:flutter_config/flutter_config.dart';

Future<List<EstablishmentModel>> getFavorites() async {
  final FirebaseUtils firebaseUtils = FirebaseUtils();
  List<EstablishmentModel> favoriteEstablishments =
      await firebaseUtils.getAllFavorites();

  return favoriteEstablishments;
}

Future<List<EstablishmentModel>> getTempleList(LatLng latLng) async {
  var logger = Logger();
  List<String> types = [
    "bakery",
    "bar",
    "cafe",
    "convenience_store",
    "meal_delivery",
    "meal_takeaway",
    "restaurant",
    "shopping_mall",
    "supermarket",
  ];
  String apiKey = await FlutterConfig.get('ApiKey');

  if (apiKey.isEmpty) {
    logger.e(
        'API KEY não encontrada, resumindo a situação: A aplicação foi de arrasta para cima!!!');
    throw Exception('API KEY não encontrada');
  }

  List<Future<http.Response>> futures = [];

  for (int i = 0; i < types.length; i++) {
    futures.add(http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&radius=5000&type=${types[i]}&key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  List<EstablishmentModel> establishmentList = [];

  for (var response in await Future.wait(futures)) {
    Map<String, dynamic> json = jsonDecode(response.body);

    if (json['status'] != 'OK') {
      logger.e(json['error_message']);
      continue;
    }

    var result = json['results'] as List;

    for (var element in result) {
      element['types'] = element['types'].toString().toLowerCase().split(',');

      establishmentList.add(
        EstablishmentModel(
          name: element['name'],
          address: element['vicinity'], //endereço
          latLng: LatLng(
            element['geometry']['location']['lat'], //latitude e longitude
            element['geometry']['location']['lng'],
          ),
          imageUrl: element['icon'],
          placesId: element['place_id'],
          types: element['types'],
        ),
      );
    }
  }

  List<EstablishmentModel> favorites = await getFavorites();
  print(favorites);
  for (var favorite in favorites) {
    establishmentList.removeWhere(
        (establishment) => establishment.placesId == favorite.placesId);

    establishmentList.add(favorite);
  }

  return establishmentList;
}

Future<List<EstablishmentModel>> getPlaces(LatLng latLng) async {
  var logger = Logger();
  List<String> types = [
    "bakery",
    "bar",
    "cafe",
    "convenience_store",
    "meal_delivery",
    "meal_takeaway",
    "restaurant",
    "shopping_mall",
    "supermarket",
  ];
  String apiKey = await FlutterConfig.get('ApiKey');

  if (apiKey.isEmpty) {
    logger.e(
        'API KEY não encontrada, resumindo a situação: A aplicação foi de arrasta para cima!!!');
    throw Exception('API KEY não encontrada');
  }

  List<Future<http.Response>> futures = [];

  for (int i = 0; i < types.length; i++) {
    futures.add(http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&radius=5000&type=${types[i]}&key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  List<EstablishmentModel> establishmentList = [];

  for (var response in await Future.wait(futures)) {
    Map<String, dynamic> json = jsonDecode(response.body);

    if (json['status'] != 'OK') {
      logger.e(json['error_message']);
      continue;
    }

    var result = json['results'] as List;

    for (var element in result) {
      element['types'] = element['types'].toString().toLowerCase().split(',');

      establishmentList.add(
        EstablishmentModel(
          name: element['name'],
          address: element['vicinity'], //endereço
          latLng: LatLng(
            element['geometry']['location']['lat'], //latitude e longitude
            element['geometry']['location']['lng'],
          ),
          imageUrl: element['icon'],
          placesId: element['place_id'],
          types: element['types'],
        ),
      );
    }
  }

  return establishmentList;
}

import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:trabalho_loc_ai/view/home/models/model_locations.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List<TempleModel>> getTempleList(LatLng latLng, context) async {
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

  List<TempleModel> templeList = [];

  for (int i = 0; i < types.length; i++) {
    try {
      http.Response response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&type=${types[i]}&rankby=distance&key=AIzaSyAM2EiZO_F6fh4JiNXwov-aC1LaLvBSimM&language=pt-BR'));

      Map<String, dynamic> json = {};
      json = jsonDecode(response.body);
      if (json['status'] != 'OK') {
        // throw Exception(json['error_message']);
        logger.e(json['error_message']);
        return [];
      }
      json = jsonDecode(json['results']);
      // List<TempleModel> templeList = [];
      // logger.d(json);R

      for (var element in json['results']) {
        logger.d(element);
        templeList.add(TempleModel(
            name: element['name'],
            address: element['vicinity'], //endereço
            latLng: LatLng(
                element['geometry']['location']['lat'], //latitude e longitude
                element['geometry']['location']['lng']),
            imageUrl: element['icon'],
            placesId: element['place_id']));
      }
    } catch (e) {
      //exibe uma mensagem de erro na tela
      // throw Exception(e);
      logger.e(e);
      continue;
    }
  }
  return templeList;
}

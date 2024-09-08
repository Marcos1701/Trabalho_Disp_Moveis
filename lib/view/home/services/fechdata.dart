import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:trabalho_loc_ai/view/home/models/model_locations.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
//usando dotenv
import 'package:flutter_config/flutter_config.dart';

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
  String apiKey = await FlutterConfig.get('ApiKey');

  if (apiKey.isEmpty) {
    logger.e(
        'API KEY não encontrada, resumindo a situação: A aplicação foi de arrasta para cima!!!');
    throw Exception('API KEY não encontrada');
  }

  List<TempleModel> templeList = [];

  for (int i = 0; i < types.length; i++) {
    // try {

    http.Response response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&type=${types[i]}&rankby=distance&key=$apiKey&language=pt-BR'));

    Map<String, dynamic> json = {};
    json = jsonDecode(response.body);
    if (json['status'] != 'OK') {
      // throw Exception(json['error_message']);
      logger.e(json['error_message']);
      return [];
    }
    var result = json['results'];
    // List<TempleModel> templeList = [];
    // logger.d(json);R

    for (var element in result) {
      // logger.d(element);

      element['types'] = element['types'].toString().toLowerCase().split(',');

      templeList.add(TempleModel(
          name: element['name'],
          address: element['vicinity'], //endereço
          latLng: LatLng(
              element['geometry']['location']['lat'], //latitude e longitude
              element['geometry']['location']['lng']),
          imageUrl: element['icon'],
          placesId: element['place_id'],
          types: element['types']));
    }
    // } catch (e) {
    //   logger.e(
    //     e,
    //     error: e.toString(),
    //     time: DateTime.now(),
    //   ); //exibe uma mensagem de erro na tela, como se fosse um log
    //   continue;
    // }
  }
  return templeList;
}

import 'package:trabalho_loc_ai/view/home/models/model_locations.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

List<TempleModel> getTempleList(LatLng latLng) async {
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
    http.Response response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude}%2C${latLng.longitude}&radius=2000&type=${types[i]}&rankby=distance&key=AIzaSyBRutXItH61yVACsJ-LMeN3UAdd7OsKeqk&language=pt-BR'));

    // templeList.add(const TempleModel(
    //     name: 'name',
    //     address: 'address',
    //     latLng: LatLng(0, 0),
    //     imageUrl: 'url',
    //     placesId: 'id'));

    templeList.add(TempleModel.fromJson(response.body));
  }
  return templeList;
}

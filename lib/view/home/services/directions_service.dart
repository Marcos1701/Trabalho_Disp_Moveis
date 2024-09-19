import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;
  DirectionsRepository({required Dio dio}) : _dio = dio;

  Future<Directions?> getRouteBetweenCoordinates({
    required LatLng origin,
    required LatLng destination,
  }) async {
    debugPrint('getting direction');

    String apikey = await FlutterConfig.get('ApiKey');
    if (apikey.isEmpty) {
      throw Exception('API KEY não encontrada');
    }

    debugPrint('origin => $origin');
    debugPrint('destination => $destination');

    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': apikey,
      },
    );

    if (response.statusCode == 200) {
      if (response.data['routes'].length < 1) {
        return null;
      }
      return Directions.fromMap(response.data);
    } else {
      debugPrint('response => $response');
    }
    return null;
  }
}

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    final data = Map<String, dynamic>.from(map['routes'][0]);

// Bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

// Distance & Duration
    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    String points = data['overview_polyline']['points'];

    return Directions(
      bounds: bounds,
      polylinePoints: PolylinePoints().decodePolyline(points),
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}

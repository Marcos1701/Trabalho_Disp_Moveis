import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  late LatLng _center = const LatLng(-5.088337, -42.810645);

  // adicionando a busca de endereço
  final TextEditingController _controller = TextEditingController();
  late String _searchAddress;

  // adicionando a busca de endereço
  void _onSearch() {}

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getCurrentLocation() async {
    final Position position = await _determinePosition();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 11.0,
        ),
      ),
    );

    setState(() {
      _center = LatLng(position.latitude, position.longitude);
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Google Maps'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearch,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              // para habilitar a localização atual
              myLocationEnabled: true,
              // para habilitar o botão de localização atual
              myLocationButtonEnabled: true,
              // para habilitar o controle de zoom
              zoomControlsEnabled: true,
              // para habilitar o controle de zoom
              zoomGesturesEnabled: true,
              // para habilitar o controle de rotação
              rotateGesturesEnabled: true,
              // para habilitar o controle de inclinação
              tiltGesturesEnabled: true,
              // melhorando a performance
              // gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              //   Factory<OneSequenceGestureRecognizer>(
              //     () => EagerGestureRecognizer(),
              //   ),
              // },
              // cacheando o mapa
              mapType: MapType.normal,

              // para habilitar o tráfego
              // trafficEnabled: true,
              // habilitando busca

              // para adicionar o marcador na localização atual
              // markers: <Marker>{
              //   Marker(
              //     markerId: const MarkerId('current-location'),
              //     position: _center,
              //     infoWindow: const InfoWindow(title: 'Localização Atual'),
              //   ),
              // },
              // teste
            ),
          ),
        ],
      ),
    );
  }
}

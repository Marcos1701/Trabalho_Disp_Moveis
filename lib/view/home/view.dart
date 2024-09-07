import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:trabalho_loc_ai/view/home/models/model_locations.dart';
import 'package:trabalho_loc_ai/view/home/services/fechdata.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({super.key});

  @override
  State<LocationMap> createState() => LocationMapState();
}

class LocationMapState extends State<LocationMap>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Set<Marker> _markers = {};

  String _mapStyle = '';

  LatLng? _lastMapPosition;

  // metodo para inicializar o mapa
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _getData() async {
    if (_lastMapPosition != null) {
      List<TempleModel> templeList =
          await getTempleList(_lastMapPosition!, context);

      for (int i = 0; i < templeList.length; i++) {
        print(templeList[i].name);
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(templeList[i].name),
              position: templeList[i].latLng,
              infoWindow: InfoWindow(
                title: templeList[i].name,
                snippet: templeList[i].address,
              ),
            ),
          );
        });
      }
    }
  }

  // metodo para pedir permissão de localização, é utilizado apenas para exibir a localização no mapa
  void requestPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }

    var permission = await Geolocator.isLocationServiceEnabled();

    if (permission) {
      // verifica se a permissão foi aceita
      Position locAtual = await Geolocator.getCurrentPosition();

      setState(() {
        _controller.future.then((GoogleMapController controller) {
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(locAtual.latitude, locAtual.longitude),
              zoom: 18,
            ),
          ));
        });

        _lastMapPosition = LatLng(locAtual.latitude, locAtual.longitude);
      });
      _getData();
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    requestPermission();

    // carrega o arquivo de estilo do mapa
    setState(() {
      rootBundle.loadString('assets/map_style.txt').then((string) {
        _mapStyle = string;
      });
    });
  }

  // Metodo responsável por carregar as localizações e os marcadores dos restaurantes
  loadData() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(-20.508, -54.617),
        zoom: 18,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      style: _mapStyle,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      markers: Set<Marker>.of(_markers),
      onLongPress: _onMapLongPressed,
    ));
  }

  // Metodo para adicionar o marcador no click
  void _onMapLongPressed(LatLng latLng) {
    // evento disparado quando o mapa é pressionado e segurado por alguns segundos
    Future.delayed(const Duration(seconds: 1), () {
      // adiciona um novo marcador no click
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(_markers.length.toString()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: latLng,
          infoWindow: const InfoWindow(
            title: "Novo Marcador",
          ),
        ));

        _controller.future.then((GoogleMapController controller) {
          controller
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: latLng,
            zoom: 18,
          )));
        });
      });
    });
  }
}

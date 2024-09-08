import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:trabalho_loc_ai/view/home/models/model_locations.dart';
import 'package:trabalho_loc_ai/view/home/services/fechdata.dart';
import 'package:trabalho_loc_ai/view/home/services/bitmaphelper.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:custom_info_window/custom_info_window.dart';

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
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  // Json com os icones para cada tipo de local
  final iconsFromJson = {
    'bakery': BitmapDescriptor.defaultMarker,
    'bar': BitmapDescriptor.defaultMarker,
    'cafe': BitmapDescriptor.defaultMarker,
    'convenience_store': BitmapDescriptor.defaultMarker,
    'meal_delivery': BitmapDescriptor.defaultMarker,
    'meal_takeaway': BitmapDescriptor.defaultMarker,
    'restaurant': BitmapDescriptor.defaultMarker,
    'shopping_mall': BitmapDescriptor.defaultMarker,
    'supermarket': BitmapDescriptor.defaultMarker,
  };

  String _mapStyle = '';

  LatLng? _lastMapPosition;

  TempleModel? _selectedTemple;

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  // metodo para inicializar o mapa
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _customInfoWindowController.googleMapController = controller;
  }

  Widget buildInfoWindow(TempleModel temple) {
    return Column(children: [
      Text(temple.name),
      Text(temple.address),
      //botão para favoritar o local, com icone de estrela e fundo amarelo
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.star),
        color: Colors.amber,
        iconSize: 30,
        tooltip: 'Favoritar',
        splashRadius: 20,
        splashColor: Colors.amber,
        highlightColor: Colors.amber,
      )
    ]);
  }

  void _getData() async {
    if (_lastMapPosition != null) {
      List<TempleModel> templeList =
          await getTempleList(_lastMapPosition!, context);

      for (int i = 0; i < templeList.length; i++) {
        //verifica se o local já existe no mapa
        if (_markers
            .any((marker) => marker.markerId == MarkerId(templeList[i].name))) {
          continue;
        }

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(templeList[i].placesId),
              position: templeList[i].latLng,
              // infoWindow: InfoWindow(
              //     title: templeList[i].name,
              //     snippet: templeList[i].address,

              //     //     arguments: templeList[i]),
              //     ),
              onTap: () {
                print("Apertou, ein? Abestado");
                setState(() {
                  _selectedTemple = templeList[i];
                });
                _customInfoWindowController.addInfoWindow!(
                  buildInfoWindow(templeList[i]),
                  templeList[i].latLng,
                );
              },
              icon: iconsFromJson[templeList[i].types.first] ??
                  BitmapDescriptor.defaultMarker,
              // icon:
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

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: _selectedTemple != null
              ? Column(
                  children: [
                    // Image.network(_selectedTemple!.imageUrl),
                    Text(_selectedTemple!.name),
                    Text(_selectedTemple!.address),
                    TextButton(
                      onPressed: () {
                        // favoritar o local
                      },
                      child: const Text('Favoritar'),
                    ),
                  ],
                )
              : const Text('Nenhum local selecionado'),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // carrega o arquivo de estilo do mapa
    setState(() {
      rootBundle.loadString('assets/map_style.txt').then((string) {
        _mapStyle = string;
      });

      requestPermission();
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    _customInfoWindowController.onCameraMove!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _lastMapPosition ?? const LatLng(0, 0),
            zoom: 18,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          style: _mapStyle,
          mapType: MapType.normal,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          indoorViewEnabled: false,
          markers: Set<Marker>.of(_markers),
          // onLongPress: _onMapLongPressed,
          onCameraMove: _onCameraMove,
          onTap: (LatLng latLng) {
            _customInfoWindowController.hideInfoWindow!();
            _selectedTemple = null;
          },
        ),
        CustomInfoWindow(
          controller: _customInfoWindowController,
          height: 200,
          width: 200,
          offset: 50,
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          requestPermission();
        },
        tooltip: 'Localização',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              //verifica se já está na home, se não estiver, navega para a home
              onPressed: () => Navigator.pushNamed(context, 'home'),
              icon: const Icon(Icons.home),
              tooltip: 'Home',
            ),
            //aba para visualizar os estabelecimentos próximos, em forma de lista
            const IconButton(
                onPressed: null,
                icon: Icon(Icons.list),
                tooltip: 'Lista de estabelecimentos'),
            const IconButton(
              onPressed: null,
              icon: Icon(Icons.favorite),
              tooltip: 'Favoritos',
            ),
            const IconButton(
              onPressed: null,
              icon: Icon(Icons.account_circle),
              tooltip: 'Minha conta',
            ),
          ],
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}

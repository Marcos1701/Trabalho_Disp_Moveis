import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:trabalho_loc_ai/view/auth/sign_in/view.dart';
import 'package:trabalho_loc_ai/view/home/database/firebaseutils.dart';
import 'package:trabalho_loc_ai/view/home/models/model_locations.dart';
import 'package:trabalho_loc_ai/view/home/services/fechdata.dart';
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

  final FirebaseUtils _firebaseUtils = FirebaseUtils();

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
    // Widget para mostrar o nome e o endereço do local

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 8.0,
                ),
                Text(temple.name,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 10.0)),
                const SizedBox(
                  width: 8.0,
                ),
                Text(temple.address,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 10.0)),
                //botão para favoritar o local, com icone de estrela e fundo amarelo
                IconButton(
                  onPressed: () {
                    setState(() {
                      temple.isFavorite
                          ? _firebaseUtils.addFavorite(temple)
                          : _firebaseUtils.removeFavorite(temple);
                      temple.toggleFavorite();
                    });
                  },
                  icon: const Icon(Icons.star),
                  color: temple.isFavorite ? Colors.amber : Colors.white,
                  iconSize: 30,
                  tooltip: 'Favoritar',
                  splashRadius: 20,
                  splashColor: temple.isFavorite ? Colors.amber : Colors.white,
                  highlightColor:
                      temple.isFavorite ? Colors.amber : Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
      Container(
        color: Colors.blue,
        width: 20.0,
        height: 10.0,
      )
    ]);
  }

  Future<void> _getData() async {
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
              onTap: () {
                //ao clicar no local, o mesmo torna-se selecionado
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

  Future<void> _getFavorites() async {
    if (_lastMapPosition != null) {
      List<TempleModel> templeList = await _firebaseUtils.getAllFavorites();

      for (int i = 0; i < templeList.length; i++) {
        //verifica se o local já existe no mapa
        if (_markers
            .any((marker) => marker.markerId == MarkerId(templeList[i].name))) {
          // altera o status do local para favoritado
          setState(() {
            _markers.map(
              (marker) => marker.markerId == MarkerId(templeList[i].name)
                  ? marker.copyWith(
                      iconParam: BitmapDescriptor.defaultMarkerWithHue(
                          templeList[i].isFavorite
                              ? BitmapDescriptor.hueRed
                              : BitmapDescriptor.hueYellow))
                  : marker,
            );
          });
          continue;
        }

        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(templeList[i].placesId),
            position: templeList[i].latLng,
            onTap: () {
              //ao clicar no local, o mesmo torna-se selecionado
              _customInfoWindowController.addInfoWindow!(
                buildInfoWindow(templeList[i]),
                templeList[i].latLng,
              );
            },
            icon: iconsFromJson[templeList[i].types.first] ??
                BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow),
          ));
        });
      }
    }
  }

  // metodo para pedir permissão de localização, é utilizado apenas para exibir a localização no mapa
  Future<void> requestPermission() async {
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
      await _getData();
      await _getFavorites();
    }
    return;
  }

  @override
  void initState() {
    super.initState();

    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SingInPage()),
      );
    }

    // carrega o arquivo de estilo do mapa
    setState(() {
      rootBundle.loadString('assets/map_style.txt').then((string) {
        _mapStyle = string;
      });
    });
    requestPermission().then((_) => {});
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
          // markers: _markers,
          // onLongPress: _onMapLongPressed,
          onCameraMove: _onCameraMove,
          onTap: (LatLng latLng) {
            _customInfoWindowController.hideInfoWindow!();
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
        onPressed: () async {
          await requestPermission();
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

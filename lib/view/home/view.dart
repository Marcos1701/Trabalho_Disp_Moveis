import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:trabalho_loc_ai/view/auth/services/autenticacao_servico.dart';
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

  late bool _isLoading = true;

  String _mapStyle = '';

  LatLng? _lastMapPosition;

  @override
  void dispose() {
    _controller.future.then((controller) => controller.dispose());
    super.dispose();
  }

  // metodo para inicializar o mapa
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _customInfoWindowController.googleMapController = controller;
  }

  Widget buildInfoWindow(TempleModel temple) {
    // Widget para mostrar o nome e o endereço do local

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.indigoAccent,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 2.0,
                ),
              ],
              border: Border.all(color: Colors.white, width: 2.0),
              image: DecorationImage(
                image: Image.network(temple.imageUrl).image,
                fit: BoxFit.cover,
              ),
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
                  Text(
                    temple.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 2.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                      overflow: TextOverflow.ellipsis,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    width: 10.0,
                    height: 8.0,
                  ),
                  Text(
                    temple.address,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 2.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                      overflow: TextOverflow.ellipsis,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 16.0),
                  //botão para favoritar o local, com icone de estrela e fundo amarelo
                  Container(
                    width: 160.0,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        width: 1.0,
                        color: temple.isFavorite ? Colors.yellow : Colors.white,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        temple.isFavorite ? 'Favorito' : 'Favoritar',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: Icon(
                        temple.isFavorite
                            ? Icons.star
                            : Icons.star_border_outlined,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      onTap: () {
                        setState(() {
                          temple.isFavorite
                              ? _firebaseUtils
                                  .removeFavorite(temple)
                                  .then((_) {})
                              : _firebaseUtils.addFavorite(temple).then((_) {});
                          temple.toggleFavorite();
                          Marker updatedMarker = temple.toMarker(
                            () => _customInfoWindowController.addInfoWindow!(
                              buildInfoWindow(temple),
                              temple.latLng,
                            ),
                          );
                          _markers.removeWhere((marker) =>
                              temple.placesId == marker.markerId.value);
                          _markers.add(updatedMarker);

                          _customInfoWindowController.hideInfoWindow!();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        //triangulo, para parecer um balão
        Container(
          width: 8.0,
          height: 8.0,
          decoration: const BoxDecoration(
            color: Colors.indigoAccent,
            shape: BoxShape.circle,
          ),
          transform: Matrix4.translationValues(0.0, -16.0, 0.0),
          alignment: Alignment.center,
          child: Container(
            width: 4.0,
            height: 4.0,
            decoration: const BoxDecoration(
              color: Colors.indigoAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _getData() async {
    if (_lastMapPosition != null) {
      setState(() {
        _isLoading = true;
      });
      List<TempleModel> templeList = await getTempleList(_lastMapPosition!);

      for (int i = 0; i < templeList.length; i++) {
        //verifica se o local já existe no mapa
        if (_markers
            .any((marker) => marker.markerId == MarkerId(templeList[i].name))) {
          continue;
        }

        setState(() {
          _markers.add(
            templeList[i].toMarker(
              () => _customInfoWindowController.addInfoWindow!(
                buildInfoWindow(templeList[i]),
                templeList[i].latLng,
              ),
            ),
          );
        });
      }
      setState(() {
        _isLoading = false;
      });
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
    }
    return;
  }

  void carregarEstilo() {
    Future.delayed(Duration.zero, () {
      setState(() {
        rootBundle.loadString('assets/map_style.txt').then((string) {
          _mapStyle = string;
        });
      });
    }); // para evitar erros durante o build
  }

  @override
  void initState() {
    carregarEstilo();
    requestPermission();
    super.initState();
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
    _customInfoWindowController.onCameraMove!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
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
          // tela de carregamento
          Visibility(
            visible: _isLoading,
            maintainState: true,
            maintainAnimation: true,
            child: Container(
              color: Colors.transparent.withOpacity(0.1),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ],
      ),
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
              onPressed: () => Navigator.pushNamed(context, '/home'),
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
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Column(
                        children: [
                          Icon(Icons.person, size: 48),
                          SizedBox(height: 8),
                          Text('Perfil'),
                        ],
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nome: ${FirebaseAuth.instance.currentUser?.displayName ?? 'Desconhecido'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Email: ${FirebaseAuth.instance.currentUser?.email ?? 'Desconhecido'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Deslogar'),
                            onTap: () async {
                              await AutenticacaoServico().deslogarUsuario();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.account_circle),
              tooltip: 'Minha conta',
            ),
          ],
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:trabalho_loc_ai/view/auth/services/autenticacao_servico.dart';
import 'package:trabalho_loc_ai/view/details/establishment_details.dart';
import 'package:trabalho_loc_ai/view/home/database/firebaseutils.dart';
import 'package:trabalho_loc_ai/models/establishment_model.dart';
import 'package:trabalho_loc_ai/view/home/services/directions_service.dart';
import 'package:trabalho_loc_ai/view/home/services/fechdata.dart';
import 'package:custom_info_window/custom_info_window.dart';

class LocationMap extends StatefulWidget {
  // adicionando variável para caso deseje iniciar de uma localização
  final LatLng? initialLocation;
  const LocationMap({super.key, this.initialLocation});

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
  Directions? _info;

  LatLng? _lastMapPosition;

  //polylines
  final Set<Polyline> _polylines = {};

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

  void moveToLocation(LatLng latLng) {
    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  Widget buildInfoWindow(EstablishmentModel establishment) {
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
                image: Image.network(establishment.icon).image,
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
                  TextButton(
                    onPressed: () {
                      final BuildContext buildContext = context;
                      setState(() {
                        _isLoading = true;
                      });
                      establishment.loadPhotos().then((_) {
                        setState(() {
                          _isLoading = false;
                        });
                        if (!buildContext.mounted) return;
                        Navigator.of(buildContext).push(
                          MaterialPageRoute(
                            builder: (context) => EstablishmentDetails(
                              establishment: establishment,
                            ),
                          ),
                        );
                      });
                    },
                    child: Text(
                      establishment.name,
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
                  ),
                  const SizedBox(
                    width: 10.0,
                    height: 8.0,
                  ),
                  TextButton(
                    onPressed: () {
                      final BuildContext buildContext = context;
                      setState(() {
                        _isLoading = true;
                      });
                      establishment.loadPhotos().then((_) {
                        setState(() {
                          _isLoading = false;
                        });
                        if (!buildContext.mounted) return;
                        Navigator.of(buildContext).push(
                          MaterialPageRoute(
                              builder: (context) => EstablishmentDetails(
                                    establishment: establishment,
                                  )),
                        );
                      });
                    },
                    child: Text(
                      establishment.address,
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
                  ),
                  const SizedBox(height: 16.0),
                  //botão para favoritar o local, com icone de estrela e fundo amarelo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            width: 1.0,
                            color: establishment.isFavorite
                                ? Colors.yellow
                                : Colors.white,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 5.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: establishment.isFavorite
                              ? const Icon(Icons.star)
                              : const Icon(Icons.star_border_outlined),
                          color: Colors.white,
                          iconSize: 24.0,
                          onPressed: () {
                            setState(
                              () {
                                establishment.isFavorite
                                    ? _firebaseUtils
                                        .removeFavorite(establishment)
                                        .then((_) {})
                                    : _firebaseUtils
                                        .addFavorite(establishment)
                                        .then((_) {});
                                establishment.toggleFavorite();
                                Marker updatedMarker = establishment.toMarker(
                                  () => _customInfoWindowController
                                      .addInfoWindow!(
                                    buildInfoWindow(establishment),
                                    establishment.latLng,
                                  ),
                                );
                                _markers.removeWhere((marker) =>
                                    establishment.placesId ==
                                    marker.markerId.value);
                                _markers.add(updatedMarker);

                                _customInfoWindowController.hideInfoWindow!();
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      //botão para calcular a rota
                      Container(
                        width: 70.0,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(width: 1.0, color: Colors.white),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 5.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.directions),
                          color: Colors.white,
                          iconSize: 24.0,
                          onPressed: () async {
                            // print('clicked');
                            String apiKey = await FlutterConfig.get('ApiKey');

                            if (apiKey.isEmpty) {
                              print(
                                  'API KEY não encontrada, resumindo a situação: A aplicação foi de arrasta para cima!!!');
                              throw Exception('API KEY não encontrada');
                            }

                            _getPolyline(
                              establishment.latLng,
                            );

                            _customInfoWindowController.hideInfoWindow!();
                          },
                        ),
                      ),
                    ],
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

  _getPolyline(
    LatLng destination,
  ) async {
    if (_lastMapPosition == null) {
      return;
    }

    _controller.future.then(
      (GoogleMapController controler) {
        controler.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: destination,
          zoom: 18.0,
        )));
      },
    );

    final Directions? directions = await DirectionsRepository(dio: Dio())
        .getRouteBetweenCoordinates(
            origin: _lastMapPosition!, destination: destination);
    debugPrint('directions => $directions');
    if (directions == null) return;

    setState(() {
      _info = directions;
      debugPrint('directions => ${_info!.polylinePoints}');
      // _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('direction_polyline'),
          color: Colors.indigoAccent,
          width: 5,
          points: _info!.polylinePoints
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
        ),
      );

      _controller.future.then((GoogleMapController controler) {
        controler.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: _lastMapPosition!,
          zoom: 18.0,
        )));
      });
    });
  }

  Future<void> _getData() async {
    if (_lastMapPosition != null) {
      setState(() {
        _isLoading = true;
      });
      List<EstablishmentModel> templeList =
          await getTempleList(_lastMapPosition!);

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
    if (widget.initialLocation != null) {
      _lastMapPosition = widget.initialLocation;
      moveToLocation(_lastMapPosition!);
    }
    //teste
    _getPolyline(
      const LatLng(-5.088753152055176, -42.81098924326597),
    );
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
            polylines: Set<Polyline>.of(_polylines),
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
              onPressed: () => {},
              icon: const Icon(Icons.home),
              tooltip: 'Home',
            ),
            //aba para visualizar os estabelecimentos próximos, em forma de lista
            IconButton(
              onPressed: () {
                // Verifique se _lastMapPosition está definido
                if (_lastMapPosition == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Localização não disponível.')),
                  );
                  return;
                }

                LatLng currentLocation =
                    _lastMapPosition!; // Use o valor de _lastMapPosition

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Column(
                        children: [
                          Icon(Icons.list, size: 48),
                          SizedBox(height: 8),
                          Text('Lista de Estabelecimentos'),
                        ],
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      content: SizedBox(
                        width: double.maxFinite, // Para ocupar a largura total
                        child: FutureBuilder<List<EstablishmentModel>>(
                          future: getPlaces(
                              currentLocation), // Chama a função da API
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child:
                                    Text('Nenhum estabelecimento encontrado.'),
                              );
                            }

                            final establishments = snapshot.data!;

                            return ListView.builder(
                              shrinkWrap:
                                  true, // Permite que a lista tenha uma altura mínima
                              physics:
                                  const AlwaysScrollableScrollPhysics(), // Permite rolagem
                              itemCount: establishments.length,
                              itemBuilder: (context, index) {
                                final establishment = establishments[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ), // Espaçamento entre os cards
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(8.0),
                                    title: Row(
                                      children: [
                                        // Ícone do estabelecimento com borda arredondada
                                        // Verifica se a URL da imagem existe
                                        Container(
                                          padding: const EdgeInsets.all(
                                            4.0,
                                          ), // Espaçamento interno
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            ), // Borda
                                            borderRadius: BorderRadius.circular(
                                                20.0), // Bordas arredondadas
                                          ),
                                          child: ClipOval(
                                            // Faz o ícone ser circular
                                            child: Image.network(
                                              establishment.icon,
                                              width: 40, // Largura do ícone
                                              height: 40, // Altura do ícone
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        // Espaçamento entre o ícone e as informações
                                        const SizedBox(
                                            width: 8.0), // Espaçamento fixo
                                        // Nome e endereço do estabelecimento
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                establishment.name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(establishment.address),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    onLongPress: () {
                                      moveToLocation(establishment.latLng);
                                      Navigator.of(context)
                                          .pop(); // Fecha o diálogo
                                    },
                                    onTap: () {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      establishment.loadPhotos().then((_) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                        if (!context.mounted) return;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EstablishmentDetails(
                                                    establishment:
                                                        establishment,
                                                  )),
                                        );
                                      });
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.list),
              tooltip: 'Lista de estabelecimentos',
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Column(
                        children: [
                          Icon(Icons.favorite, size: 48),
                          SizedBox(height: 8),
                          Text('Favoritos'),
                        ],
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: FutureBuilder<List<EstablishmentModel>>(
                          future: getTempleList(
                              _lastMapPosition!), // Chama a função que busca estabelecimentos
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('Nenhum favorito encontrado.'));
                            }

                            final establishments = snapshot.data!;
                            final favorites = establishments
                                .where((temple) => temple.isFavorite)
                                .toList(); // Filtra os favoritos

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                final temple = favorites[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical:
                                          8.0), // Espaçamento entre os cards
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(
                                        8.0), // Espaçamento interno
                                    title: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          child: ClipOval(
                                            child: Image.network(
                                              temple.icon,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 8.0), // Espaçamento fixo
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                temple.name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(temple.address),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      moveToLocation(temple
                                          .latLng); // Move o mapa para o favorito
                                      Navigator.of(context)
                                          .pop(); // Fecha o diálogo
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.favorite),
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

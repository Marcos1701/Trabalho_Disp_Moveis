import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import 'package:trabalho_loc_ai/models/establishment_model.dart';
import 'package:trabalho_loc_ai/view/home/database/firebaseutils.dart';
import 'package:trabalho_loc_ai/view/home/services/fechdata.dart';

class EstablishmentDetails extends StatefulWidget {
  final EstablishmentModel establishment;

  const EstablishmentDetails({super.key, required this.establishment});

  @override
  State<EstablishmentDetails> createState() => _EstablishmentDetailsState();
}

class _EstablishmentDetailsState extends State<EstablishmentDetails> {
  final FirebaseUtils _firebaseUtils = FirebaseUtils();
  // final Logger _logger = Logger();
  final List<String> _imageUrls = [];
  // bool _isLoading = true;

  void getPhotos() async {
    List<String> photos = await getUrlPhotos(widget.establishment.placesId);
    setState(() {
      _imageUrls.addAll(photos);
      // _isLoading = false;
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () => getPhotos()); // para evitar erro
    super.initState();
  }

  List<Image> getImagesList() {
    List<Image> imagesList = [];

    for (var url in _imageUrls) {
      imagesList.add(
        Image.network(
          url,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error);
          },
        ),
      );
    }
    // print(imagesList.length);
    return imagesList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: CarouselView(
                  itemExtent: 300.0,
                  scrollDirection: Axis.horizontal,
                  itemSnapping: true,
                  onTap: (value) => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            content: Image.network(
                              _imageUrls[value],
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                              height: 300,
                              width: 300,
                              alignment: Alignment.center,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Fechar'),
                              ),
                            ],
                          )),
                  children: getImagesList(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.establishment.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.establishment.address,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        'Categorias do estabelecimento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          decorationThickness: 2,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(width: 16),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget.establishment.types.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) => Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.establishment.types[index],
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ])
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
              heroTag: 'Back to home - ${widget.establishment.name}',
              onPressed: () {
                Navigator.of(context).pop();
              },
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.black),
              ),
              child: const Icon(Icons.arrow_back),
            ),
            FloatingActionButton(
              heroTag: 'Favorite - ${widget.establishment.name}',
              onPressed: () {
                widget.establishment.isFavorite
                    ? _firebaseUtils
                        .removeFavorite(widget.establishment)
                        .then((_) {})
                    : _firebaseUtils
                        .addFavorite(widget.establishment)
                        .then((_) {});
                widget.establishment.toggleFavorite();
              },
              backgroundColor: widget.establishment.isFavorite
                  ? Colors.white
                  : Colors.yellow.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: widget.establishment.isFavorite
                    ? const BorderSide(color: Colors.black)
                    : const BorderSide(color: Colors.white),
              ),
              child: Icon(
                widget.establishment.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

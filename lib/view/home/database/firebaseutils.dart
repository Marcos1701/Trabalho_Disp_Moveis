import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trabalho_loc_ai/view/home/models/model_locations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class FirebaseUtils {
  final List<TempleModel> _favoritelist = [];
  late final FirebaseFirestore _firestore;
  final Logger _logger = Logger();
  late final String _user;

  FirebaseUtils() {
    _firestore = FirebaseFirestore.instance;

    FirebaseAuth auth = FirebaseAuth.instance;
    _user = auth.currentUser!.uid;

    _logger.i('user: $_user');

    // _logger.i(_user);
    _user = 'marco';
  }

  Future<List<TempleModel>> getAllFavorites() async {
    _logger.i('getAllFavorites');

    _favoritelist.clear();
    var querySnapshot = await _firestore
        .collection('favorites')
        .where('user', isEqualTo: 'marco')
        .get();

    for (var doc in querySnapshot.docs) {
      TempleModel temple = TempleModel(
          name: doc['name'],
          address: doc['address'],
          types: List<String>.from(doc['types']),
          imageUrl: doc['imageUrl'],
          placesId: doc['placesId'],
          latLng: LatLng(doc['lat'], doc['lng']));
      _favoritelist.add(temple);
    }

    return _favoritelist;
  }

  Future<void> addFavorite(TempleModel temple) async {
    _logger.i('addFavorite');
    try {
      await _firestore
          .collection('favorites')
          .doc(temple.placesId)
          .set(temple.toMap());

      _favoritelist.add(temple);
    } on FirebaseException catch (e) {
      _logger.e(e);
    }
  }

  Future<void> removeFavorite(TempleModel temple) async {
    _logger.i('removeFavorite');
    try {
      await _firestore.collection('favorites').doc(temple.placesId).delete();
      _favoritelist.remove(temple);
    } on FirebaseException catch (e) {
      _logger.e(e);
    }
  }

  List<TempleModel> getFavoriteList() {
    _logger.i('getFavoriteList');
    return _favoritelist;
  }
}

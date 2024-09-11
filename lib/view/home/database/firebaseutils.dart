import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trabalho_loc_ai/view/home/models/model_locations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class FirebaseUtils {
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  Future<List<TempleModel>> getAllFavorites() async {
    _logger.i('getAllFavorites');

    var userId = auth.currentUser!.uid;

    var querySnapshot = await _firestore
        .collection(userId)
        .doc('favorites')
        .collection('temple')
        .orderBy('name', descending: false)
        .get();

    return querySnapshot.docs
        .map((temple) => TempleModel.fromMap(temple.data()))
        .toList();
  }

  Future<void> addFavorite(TempleModel temple) async {
    _logger.i('addFavorite');

    var userId = auth.currentUser!.uid;

    try {
      await _firestore
          .collection(userId)
          .doc('favorites')
          .collection('temple')
          .doc(temple.placesId)
          .set(temple.toMap());
    } on FirebaseException catch (e) {
      _logger.e(e);
    }
  }

  Future<void> removeFavorite(TempleModel temple) async {
    _logger.i('removeFavorite');

    var userId = auth.currentUser!.uid;

    try {
      await _firestore
          .collection(userId)
          .doc('favorites')
          .collection('temple')
          .doc(temple.placesId)
          .delete();
    } on FirebaseException catch (e) {
      _logger.e(e);
    }
  }

  //stream builder, para que o firebase sempre atualize os favoritos
  Stream<List<TempleModel>> getAllFavoritesStream() {
    return _firestore
        .collection(auth.currentUser!.uid)
        .doc('favorites')
        .collection('temple')
        .snapshots()
        .map((event) {
      return event.docs.map((temple) {
        return TempleModel.fromMap(temple.data());
      }).toList();
    });
  }
}

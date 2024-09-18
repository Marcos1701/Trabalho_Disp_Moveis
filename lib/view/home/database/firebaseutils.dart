import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabalho_loc_ai/models/comments_model.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trabalho_loc_ai/models/establishment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class FirebaseUtils {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  Future<List<EstablishmentModel>> getAllFavorites() async {
    _logger.i('getAllFavorites');

    var userId = auth.currentUser!.uid;

    var querySnapshot = await _firestore
        .collection(userId)
        .doc('favorites')
        .collection('establishment')
        .orderBy('name', descending: false)
        .get();

    return querySnapshot.docs
        .map((temple) =>
            EstablishmentModel.fromMap(temple.data(), isFavorite: true))
        .toList();
  }

  Future<void> addFavorite(EstablishmentModel favPlace) async {
    _logger.i('addFavorite');

    var userId = auth.currentUser!.uid;
    try {
      await _firestore
          .collection(userId)
          .doc('favorites')
          .collection('establishment')
          .doc(favPlace.placesId)
          .set(favPlace.toMap());
    } on FirebaseException catch (e) {
      _logger.e(e);
    }
  }

  Future<void> removeFavorite(EstablishmentModel establishment) async {
    _logger.i('removeFavorite');

    var userId = auth.currentUser!.uid;

    try {
      await _firestore
          .collection(userId)
          .doc('favorites')
          .collection('establishment')
          .doc(establishment.placesId)
          .delete();
    } on FirebaseException catch (e) {
      _logger.e(e);
    }
  }

  Future<void> addComment(CommentModel comment) async {
    _logger.i('addComment');

    try {
      await _firestore
          .collection('establishment')
          .doc(comment.placeId)
          .collection('comments')
          .doc(comment.commentId)
          .set(comment.toMap()); // set => adiciona (se não existir)
    } on FirebaseException catch (e) {
      _logger.e(e);
    }
  }

  Future<List<CommentModel>> getComments(String placeId) async {
    _logger.i('getComments');

    var querySnapshot = await _firestore
        .collection('establishment')
        .doc(placeId)
        .collection('comments')
        .orderBy('comment', descending: false)
        .get();

    return querySnapshot.docs
        .map((comment) => CommentModel.fromMap(comment.data()))
        .toList();
  }

  Future<void> removeComment(CommentModel comment) async {
    _logger.i('removeComment');

    try {
      await _firestore
          .collection('establishment')
          .doc(comment.placeId)
          .collection('comments')
          .doc(comment.commentId)
          .delete();
    } on FirebaseException catch (e) {
      _logger.e(e);
    }
  }
}

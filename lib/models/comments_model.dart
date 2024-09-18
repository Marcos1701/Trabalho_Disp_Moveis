import 'package:uuid/uuid.dart';

class CommentModel {
  String commentId = const Uuid().v4();
  final String placeId;
  final String comment;
  final String userId;

  CommentModel({
    required this.placeId,
    required this.comment,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'comment': comment,
      'userId': userId,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      placeId: map['placeId'],
      comment: map['comment'],
      userId: map['userId'],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String spotId;
  final String userId;
  final String userName;
  final String userProfilePic;
  final double rating;
  final String comment;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.spotId,
    required this.userId,
    required this.userName,
    required this.userProfilePic,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spotId': spotId,
      'userId': userId,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      spotId: map['spotId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

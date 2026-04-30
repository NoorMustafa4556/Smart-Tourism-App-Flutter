import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryModel {
  final String id;
  final String userId;
  final String title;
  final List<String> spotIds;
  final DateTime createdAt;

  ItineraryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.spotIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'spotIds': spotIds,
      'createdAt': createdAt,
    };
  }

  factory ItineraryModel.fromMap(Map<String, dynamic> map) {
    return ItineraryModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      spotIds: List<String>.from(map['spotIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

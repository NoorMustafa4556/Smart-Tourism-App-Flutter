class HotelModel {
  final String id;
  final String name;
  final String image;
  final double pricePerNight;
  final String spotId; // Linked to a tourist spot

  HotelModel({
    required this.id,
    required this.name,
    required this.image,
    required this.pricePerNight,
    required this.spotId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'pricePerNight': pricePerNight,
      'spotId': spotId,
    };
  }

  factory HotelModel.fromMap(Map<String, dynamic> map) {
    return HotelModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      pricePerNight: (map['pricePerNight'] ?? 0.0).toDouble(),
      spotId: map['spotId'] ?? '',
    );
  }
}

class PlaceModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String location;
  final double price;

  PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.location,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'location': location,
      'price': price,
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map, String docId) {
    return PlaceModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      location: map['location'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}

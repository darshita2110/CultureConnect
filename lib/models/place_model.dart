class Place {
  final String name;
  final String history;
  final String clothing;
  final String dishes;
  final double latitude;
  final double longitude;
  final String image;

  Place({
    required this.name,
    required this.history,
    required this.clothing,
    required this.dishes,
    required this.latitude,
    required this.longitude,
    required this.image,
  });

  // Convert Firestore/JSON data into a Place object
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] ?? '',
      history: json['history'] ?? '',
      clothing: json['clothing'] ?? '',
      dishes: json['dishes'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      image: json['image'] ?? '',
    );
  }

  // (Optional) Convert Place back to JSON for saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'history': history,
      'clothing': clothing,
      'dishes': dishes,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
    };
  }
}

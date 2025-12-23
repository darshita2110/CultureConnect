class City {
  final String id;
  final String name;
  final String state;
  final double latitude;
  final double longitude;
  final String image;
  final String description;
  final List<String> famousFor;
  final String bestTime;

  City({
    required this.id,
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.description,
    required this.famousFor,
    required this.bestTime,
  });

  // Factory constructor to create a City from JSON
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      famousFor: List<String>.from(json['famous_for'] ?? []),
      bestTime: json['best_time'] ?? '',
    );
  }

  // Convert City to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
      'description': description,
      'famous_for': famousFor,
      'best_time': bestTime,
    };
  }
}
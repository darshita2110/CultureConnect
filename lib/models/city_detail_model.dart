import 'city_model.dart';

class CityDetail extends City {
  final FoodInfo? food;
  final TraditionalDress? traditionalDress;
  final CultureInfo? culture;
  final List<TouristPlace> touristPlaces;
  final HistoryInfo? history;

  CityDetail({
    required String id,
    required String name,
    required String state,
    required double latitude,
    required double longitude,
    required String image,
    required String description,
    required List<String> famousFor,
    required String bestTime,
    this.food,
    this.traditionalDress,
    this.culture,
    this.touristPlaces = const [],
    this.history,
  }) : super(
    id: id,
    name: name,
    state: state,
    latitude: latitude,
    longitude: longitude,
    image: image,
    description: description,
    famousFor: famousFor,
    bestTime: bestTime,
  );

  factory CityDetail.fromJson(Map<String, dynamic> json) {
    return CityDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      famousFor: List<String>.from(json['famous_for'] ?? []),
      bestTime: json['best_time'] ?? '',
      food: json['food'] != null ? FoodInfo.fromJson(json['food']) : null,
      traditionalDress: json['traditional_dress'] != null
          ? TraditionalDress.fromJson(json['traditional_dress'])
          : null,
      culture: json['culture'] != null ? CultureInfo.fromJson(json['culture']) : null,
      touristPlaces: json['tourist_places'] != null
          ? (json['tourist_places'] as List).map((e) => TouristPlace.fromJson(e)).toList()
          : [],
      history: json['history'] != null ? HistoryInfo.fromJson(json['history']) : null,
    );
  }
}

class FoodInfo {
  final String description;
  final List<Dish> dishes;

  FoodInfo({required this.description, required this.dishes});

  factory FoodInfo.fromJson(Map<String, dynamic> json) {
    return FoodInfo(
      description: json['description'] ?? '',
      dishes: json['dishes'] != null
          ? (json['dishes'] as List).map((e) => Dish.fromJson(e)).toList()
          : [],
    );
  }
}

class Dish {
  final String name;
  final String description;
  final String type;

  Dish({required this.name, required this.description, required this.type});

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'Vegetarian',
    );
  }
}

class TraditionalDress {
  final String description;
  final GenderDress male;
  final GenderDress female;

  TraditionalDress({
    required this.description,
    required this.male,
    required this.female,
  });

  factory TraditionalDress.fromJson(Map<String, dynamic> json) {
    return TraditionalDress(
      description: json['description'] ?? '',
      male: GenderDress.fromJson(json['male'] ?? {}),
      female: GenderDress.fromJson(json['female'] ?? {}),
    );
  }
}

class GenderDress {
  final String name;
  final String description;
  final List<String> occasions;

  GenderDress({
    required this.name,
    required this.description,
    required this.occasions,
  });

  factory GenderDress.fromJson(Map<String, dynamic> json) {
    return GenderDress(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      occasions: List<String>.from(json['occasions'] ?? []),
    );
  }
}

class CultureInfo {
  final String description;
  final List<Festival> festivals;
  final List<String> languages;
  final List<String> artForms;

  CultureInfo({
    required this.description,
    required this.festivals,
    required this.languages,
    required this.artForms,
  });

  factory CultureInfo.fromJson(Map<String, dynamic> json) {
    return CultureInfo(
      description: json['description'] ?? '',
      festivals: json['festivals'] != null
          ? (json['festivals'] as List).map((e) => Festival.fromJson(e)).toList()
          : [],
      languages: List<String>.from(json['languages'] ?? []),
      artForms: List<String>.from(json['art_forms'] ?? []),
    );
  }
}

class Festival {
  final String name;
  final String description;
  final String month;

  Festival({required this.name, required this.description, required this.month});

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      month: json['month'] ?? '',
    );
  }
}

class TouristPlace {
  final String name;
  final String description;
  final String timings;
  final String entryFee;

  TouristPlace({
    required this.name,
    required this.description,
    required this.timings,
    required this.entryFee,
  });

  factory TouristPlace.fromJson(Map<String, dynamic> json) {
    return TouristPlace(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      timings: json['timings'] ?? 'N/A',
      entryFee: json['entry_fee'] ?? 'N/A',
    );
  }
}

class HistoryInfo {
  final String overview;
  final List<Timeline> timeline;

  HistoryInfo({required this.overview, required this.timeline});

  factory HistoryInfo.fromJson(Map<String, dynamic> json) {
    return HistoryInfo(
      overview: json['overview'] ?? '',
      timeline: json['timeline'] != null
          ? (json['timeline'] as List).map((e) => Timeline.fromJson(e)).toList()
          : [],
    );
  }
}

class Timeline {
  final String period;
  final String description;

  Timeline({required this.period, required this.description});

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(
      period: json['period'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
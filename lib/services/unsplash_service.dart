import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

  class UnsplashService {
    static String get _accessKey => dotenv.env['UNSPLASH_ACCESS_KEY'] ?? '';
    static const String _baseUrl = 'https://api.unsplash.com';

    static Future<String?> searchImage(String query, {List<String>? fallbackQueries}) async {
      // A safer check to see if the key is missing
      if (_accessKey.isEmpty) {
        return null;
      }

    try {
      // Try main query first
      var imageUrl = await _fetchImage(query);

      // If not found, try fallback queries
      if (imageUrl == null && fallbackQueries != null) {
        for (var fallbackQuery in fallbackQueries) {
          imageUrl = await _fetchImage(fallbackQuery);
          if (imageUrl != null) break;
        }
      }

      return imageUrl;
    } catch (e) {
      print('Error in searchImage: $e');
      return null;
    }
  }

  // Internal fetch method
  static Future<String?> _fetchImage(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/search/photos?query=$query&per_page=1&orientation=landscape');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Client-ID $_accessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        if (results.isNotEmpty) {
          return results[0]['urls']['regular'] as String;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching image: $e');
      return null;
    }
  }

  // Get food image with smart fallbacks
  static Future<String?> getFoodImage(String dishName, String cityName) async {
    return await searchImage(
      '$dishName $cityName Indian food',
      fallbackQueries: [
        '$dishName Indian cuisine',
        '$dishName sweet food India',
        'Indian traditional $dishName',
      ],
    );
  }

  // Get dress/clothing image
  static Future<String?> getDressImage(String dressName, String region) async {
    return await searchImage(
      '$dressName traditional dress $region',
      fallbackQueries: [
        '$dressName Indian clothing',
        'traditional $dressName outfit India',
        '$region traditional attire',
      ],
    );
  }

  // Get festival image
  static Future<String?> getFestivalImage(String festivalName, String cityName) async {
    return await searchImage(
      '$festivalName festival $cityName India',
      fallbackQueries: [
        '$festivalName celebration India',
        'Indian festival $festivalName',
        '$cityName festival celebration',
      ],
    );
  }

  // Get tourist place image
  static Future<String?> getTouristPlaceImage(String placeName, String cityName) async {
    return await searchImage(
      '$placeName $cityName India monument',
      fallbackQueries: [
        '$placeName $cityName',
        '$placeName India heritage',
        '$cityName $placeName architecture',
      ],
    );
  }

  // Get cultural art form image
  static Future<String?> getArtFormImage(String artName, String region) async {
    return await searchImage(
      '$artName art $region India',
      fallbackQueries: [
        '$artName traditional craft India',
        'Indian $artName handicraft',
        '$region traditional $artName',
      ],
    );
  }

  // Get historical period image
  static Future<String?> getHistoricalImage(String period, String cityName) async {
    return await searchImage(
      '$period $cityName India history',
      fallbackQueries: [
        '$period architecture $cityName',
        '$cityName historical $period',
        'Indian $period monuments',
      ],
    );
  }

  // Get random quality image for category
  static Future<String?> getRandomImage(String topic) async {
    if (_accessKey == 'YOUR_UNSPLASH_ACCESS_KEY_HERE') {
      return null;
    }

    try {
      final url = Uri.parse('$_baseUrl/photos/random?query=$topic&orientation=landscape');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Client-ID $_accessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['urls']['regular'] as String;
      }

      return null;
    } catch (e) {
      print('Error fetching random image: $e');
      return null;
    }
  }

  // Batch fetch multiple images (useful for loading multiple dishes/places at once)
  static Future<Map<String, String?>> batchFetchImages(
      Map<String, String> items, // key: item name, value: search query
      ) async {
    Map<String, String?> results = {};

    for (var entry in items.entries) {
      results[entry.key] = await searchImage(entry.value);
      // Small delay to respect rate limits
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return results;
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Pexels Image Service - More accurate images than Unsplash
class PexelsImageService {
  // Free Pexels API Key - 200 requests/hour
  static const String _apiKey = 'xGuOcarxC5UAsPUGQnjh8PQ3kZGLr42qUSiMnTuiEfbHDV7vWXdXU7R9';
  static const String _baseUrl = 'https://api.pexels.com/v1';

  /// Search for images with better accuracy
  static Future<String?> searchImage(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/search?query=$query&per_page=1&orientation=landscape');

      final response = await http.get(
        url,
        headers: {
          'Authorization': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photos = data['photos'] as List;

        if (photos.isNotEmpty) {
          return photos[0]['src']['large'] as String;
        }
      }

      return null;
    } catch (e) {
      print('Pexels error: $e');
      return null;
    }
  }

  /// Get food dish image - very specific
  static Future<String?> getFoodImage(String dishName, String cityName) async {
    // Try multiple specific queries
    final queries = [
      '$dishName $cityName food dish',
      '$dishName Indian food',
      '$dishName sweet dessert' // for sweets
    ];

    for (var query in queries) {
      final image = await searchImage(query);
      if (image != null) return image;
      await Future.delayed(Duration(milliseconds: 300));
    }

    // Fallback to generic Indian food
    return await searchImage('Indian traditional food');
  }

  /// Get traditional dress image
  static Future<String?> getDressImage(String dressName, String region) async {
    final queries = [
      '$dressName traditional Indian dress',
      '$region traditional clothing India',
      'Indian ethnic wear $dressName'
    ];

    for (var query in queries) {
      final image = await searchImage(query);
      if (image != null) return image;
      await Future.delayed(Duration(milliseconds: 300));
    }

    return await searchImage('Indian traditional dress');
  }

  /// Get monument/tourist place image
  static Future<String?> getMonumentImage(String placeName, String cityName) async {
    final queries = [
      '$placeName $cityName India',
      '$placeName monument India',
      '$cityName $placeName architecture'
    ];

    for (var query in queries) {
      final image = await searchImage(query);
      if (image != null) return image;
      await Future.delayed(Duration(milliseconds: 300));
    }

    return null;
  }

  /// Get festival image
  static Future<String?> getFestivalImage(String festivalName, String cityName) async {
    final queries = [
      '$festivalName festival India celebration',
      '$festivalName $cityName India',
      'Indian festival $festivalName'
    ];

    for (var query in queries) {
      final image = await searchImage(query);
      if (image != null) return image;
      await Future.delayed(Duration(milliseconds: 300));
    }

    return await searchImage('Indian festival celebration');
  }

  /// Get historical period image
  static Future<String?> getHistoricalImage(String periodName, String cityName) async {
    final queries = [
      '$periodName $cityName India history',
      '$periodName architecture India',
      '$cityName historical monument'
    ];

    for (var query in queries) {
      final image = await searchImage(query);
      if (image != null) return image;
      await Future.delayed(Duration(milliseconds: 300));
    }

    return null;
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String _accessKey = '-uvLy2ppQ9EaqHvrgiWsUCJqwDUU7dspx3Pcbx6PxKU';
  static const String _baseUrl = 'https://api.unsplash.com';

  // Search for images
  static Future<String?> searchImage(String query) async {
    if (_accessKey == 'YOUR_UNSPLASH_ACCESS_KEY_HERE') {
      // Return null if no key provided
      return null;
    }

    try {
      final url = Uri.parse('$_baseUrl/search/photos?query=$query&per_page=1');
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
      print('Error fetching image from Unsplash: $e');
      return null;
    }
  }

  // Get random image for a topic
  static Future<String?> getRandomImage(String topic) async {
    if (_accessKey == 'YOUR_UNSPLASH_ACCESS_KEY_HERE') {
      return null;
    }

    try {
      final url = Uri.parse('$_baseUrl/photos/random?query=$topic');
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

  // Get food image
  static Future<String?> getFoodImage(String cityName, String dishName) async {
    return await searchImage('$dishName Indian food $cityName');
  }

  // Get city image
  static Future<String?> getCityImage(String cityName) async {
    return await searchImage('$cityName India cityscape');
  }

  // Get festival image
  static Future<String?> getFestivalImage(String festivalName) async {
    return await searchImage('$festivalName festival India');
  }

  // Get tourist place image
  static Future<String?> getTouristPlaceImage(String placeName, String cityName) async {
    return await searchImage('$placeName $cityName India');
  }
}
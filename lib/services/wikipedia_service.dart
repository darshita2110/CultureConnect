import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  static const String _baseUrl = 'https://en.wikipedia.org/w/api.php';

  // Get city description from Wikipedia
  static Future<String> getCityDescription(String cityName) async {
    try {
      final url = Uri.parse(
          '$_baseUrl?action=query&format=json&prop=extracts&exintro=true&explaintext=true&titles=$cityName'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'] as Map<String, dynamic>;
        final pageId = pages.keys.first;
        final extract = pages[pageId]['extract'] as String?;

        if (extract != null && extract.isNotEmpty) {
          // Return first 3 sentences
          final sentences = extract.split('. ');
          return sentences.take(3).join('. ') + '.';
        }
      }

      return _getDefaultDescription(cityName);
    } catch (e) {
      print('Error fetching from Wikipedia: $e');
      return _getDefaultDescription(cityName);
    }
  }

  // Get city image URL from Wikipedia
  static Future<String?> getCityImageUrl(String cityName) async {
    try {
      final url = Uri.parse(
          '$_baseUrl?action=query&format=json&prop=pageimages&piprop=original&titles=$cityName'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'] as Map<String, dynamic>;
        final pageId = pages.keys.first;
        final imageUrl = pages[pageId]['original']?['source'] as String?;

        return imageUrl;
      }

      return null;
    } catch (e) {
      print('Error fetching image from Wikipedia: $e');
      return null;
    }
  }

  static String _getDefaultDescription(String cityName) {
    return '$cityName is a major city in India known for its rich cultural heritage, historical significance, and vibrant traditions.';
  }
}
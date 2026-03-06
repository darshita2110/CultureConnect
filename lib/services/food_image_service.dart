import 'dart:convert';
import 'package:http/http.dart' as http;

/// Unified Food Image Service with multiple API fallbacks
/// Priority: Pexels → Unsplash → Static fallback URLs
class FoodImageService {
  // Pexels API (200 requests/hour)
  static const String _pexelsApiKey = 'xGuOcarxC5UAsPUGQnjh8PQ3kZGLr42qUSiMnTuiEfbHDV7vWXdXU7R9';
  static const String _pexelsBaseUrl = 'https://api.pexels.com/v1';
  
  // Unsplash API (50 requests/hour for free tier)
  static const String _unsplashAccessKey = '-uvLy2ppQ9EaqHvrgiWsUCJqwDUU7dspx3Pcbx6PxKU';
  static const String _unsplashBaseUrl = 'https://api.unsplash.com';

  // In-memory cache to avoid repeated API calls
  static final Map<String, String> _imageCache = {};

  // Static fallback images for common Indian foods (when API fails)
  static const Map<String, String> _staticFoodImages = {
    // Agra
    'Petha': 'https://images.unsplash.com/photo-1666190020249-ae15c52b12dd?w=800',
    'Bedai': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800',
    'Dalmoth': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=800',
    
    // Delhi
    'Chole Bhature': 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=800',
    'Paranthe': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800',
    'Butter Chicken': 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=800',
    'Chaat': 'https://images.unsplash.com/photo-1601050690117-94f5f6fa8bd7?w=800',
    
    // Mumbai
    'Vada Pav': 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=800',
    'Pav Bhaji': 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=800',
    'Bombay Sandwich': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=800',
    
    // Jaipur
    'Dal Baati Churma': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
    'Ghewar': 'https://images.unsplash.com/photo-1666190020249-ae15c52b12dd?w=800',
    'Pyaaz Kachori': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800',
    
    // Lucknow
    'Galouti Kebab': 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=800',
    'Lucknowi Biryani': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800',
    'Basket Chaat': 'https://images.unsplash.com/photo-1601050690117-94f5f6fa8bd7?w=800',
    
    // Kolkata
    'Rosogulla': 'https://images.unsplash.com/photo-1666190020249-ae15c52b12dd?w=800',
    'Kathi Roll': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800',
    'Mishti Doi': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=800',
    
    // Hyderabad
    'Hyderabadi Biryani': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800',
    'Haleem': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
    'Double Ka Meetha': 'https://images.unsplash.com/photo-1666190020249-ae15c52b12dd?w=800',
    
    // Generic fallbacks by category
    'dessert': 'https://images.unsplash.com/photo-1666190020249-ae15c52b12dd?w=800',
    'biryani': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800',
    'street_food': 'https://images.unsplash.com/photo-1601050690117-94f5f6fa8bd7?w=800',
    'indian_food': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
  };

  /// Get food image with multi-API fallback
  static Future<String?> getFoodImage(String dishName, String cityName) async {
    // Check cache first
    final cacheKey = '${dishName}_$cityName';
    if (_imageCache.containsKey(cacheKey)) {
      print('📸 [CACHE] Image for $dishName');
      return _imageCache[cacheKey];
    }

    String? imageUrl;

    // 1. Try Pexels first (more accurate for food)
    imageUrl = await _tryPexels(dishName, cityName);
    if (imageUrl != null) {
      _imageCache[cacheKey] = imageUrl;
      print('📸 [PEXELS] Image for $dishName');
      return imageUrl;
    }

    // 2. Try Unsplash as backup
    imageUrl = await _tryUnsplash(dishName, cityName);
    if (imageUrl != null) {
      _imageCache[cacheKey] = imageUrl;
      print('📸 [UNSPLASH] Image for $dishName');
      return imageUrl;
    }

    // 3. Use static fallback
    imageUrl = _getStaticFallback(dishName);
    if (imageUrl != null) {
      _imageCache[cacheKey] = imageUrl;
      print('📸 [STATIC] Image for $dishName');
      return imageUrl;
    }

    print('⚠️ No image found for $dishName');
    return null;
  }

  /// Try Pexels API with multiple search queries
  static Future<String?> _tryPexels(String dishName, String cityName) async {
    // Search queries in order of specificity
    final queries = [
      '$dishName Indian food',
      '$dishName food dish',
      '$dishName traditional',
      'Indian $dishName',
    ];

    for (final query in queries) {
      try {
        final url = Uri.parse('$_pexelsBaseUrl/search?query=${Uri.encodeComponent(query)}&per_page=3&orientation=landscape');
        
        final response = await http.get(url, headers: {
          'Authorization': _pexelsApiKey,
        }).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final photos = data['photos'] as List;

          if (photos.isNotEmpty) {
            // Return the medium size for faster loading
            return photos[0]['src']['medium'] as String;
          }
        } else if (response.statusCode == 429) {
          print('⚠️ Pexels rate limit reached');
          break; // Stop trying Pexels if rate limited
        }
      } catch (e) {
        print('Pexels error for "$query": $e');
      }
      
      // Small delay between queries
      await Future.delayed(Duration(milliseconds: 200));
    }

    return null;
  }

  /// Try Unsplash API with multiple search queries
  static Future<String?> _tryUnsplash(String dishName, String cityName) async {
    final queries = [
      '$dishName Indian cuisine',
      '$dishName food',
      'Indian $dishName dish',
    ];

    for (final query in queries) {
      try {
        final url = Uri.parse('$_unsplashBaseUrl/search/photos?query=${Uri.encodeComponent(query)}&per_page=3&orientation=landscape');
        
        final response = await http.get(url, headers: {
          'Authorization': 'Client-ID $_unsplashAccessKey',
        }).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          if (results.isNotEmpty) {
            // Return small size for faster loading
            return results[0]['urls']['small'] as String;
          }
        } else if (response.statusCode == 403) {
          print('⚠️ Unsplash rate limit reached');
          break;
        }
      } catch (e) {
        print('Unsplash error for "$query": $e');
      }
      
      await Future.delayed(Duration(milliseconds: 200));
    }

    return null;
  }

  /// Get static fallback image based on dish name or category
  static String? _getStaticFallback(String dishName) {
    // Check exact match first
    if (_staticFoodImages.containsKey(dishName)) {
      return _staticFoodImages[dishName];
    }

    // Check partial matches
    final lowerName = dishName.toLowerCase();
    
    if (lowerName.contains('biryani')) {
      return _staticFoodImages['biryani'];
    } else if (lowerName.contains('sweet') || 
               lowerName.contains('kheer') || 
               lowerName.contains('halwa') ||
               lowerName.contains('ladoo') ||
               lowerName.contains('petha') ||
               lowerName.contains('rasgulla') ||
               lowerName.contains('gulab')) {
      return _staticFoodImages['dessert'];
    } else if (lowerName.contains('chaat') || 
               lowerName.contains('pav') ||
               lowerName.contains('samosa') ||
               lowerName.contains('golgappa')) {
      return _staticFoodImages['street_food'];
    }

    // Generic Indian food fallback
    return _staticFoodImages['indian_food'];
  }

  /// Clear the image cache (useful for refresh)
  static void clearCache() {
    _imageCache.clear();
    print('📸 Image cache cleared');
  }
}

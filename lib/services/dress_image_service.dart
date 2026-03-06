import 'dart:convert';
import 'package:http/http.dart' as http;

/// Unified Dress Image Service with multiple API fallbacks
/// Priority: Static URLs → Pexels → Unsplash → Generic fallback
class DressImageService {
  // Pexels API (200 requests/hour)
  static const String _pexelsApiKey = 'xGuOcarxC5UAsPUGQnjh8PQ3kZGLr42qUSiMnTuiEfbHDV7vWXdXU7R9';
  static const String _pexelsBaseUrl = 'https://api.pexels.com/v1';
  
  // Unsplash API (50 requests/hour for free tier)
  static const String _unsplashAccessKey = '-uvLy2ppQ9EaqHvrgiWsUCJqwDUU7dspx3Pcbx6PxKU';
  static const String _unsplashBaseUrl = 'https://api.unsplash.com';

  // In-memory cache
  static final Map<String, String> _imageCache = {};

  // Static fallback images for traditional Indian attire
  static const Map<String, Map<String, String>> _staticDressImages = {
    // Uttar Pradesh
    'Sherwani': {
      'male': 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800',
      'search': 'Indian sherwani groom wedding',
    },
    'Anarkali': {
      'female': 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800',
      'search': 'Indian anarkali dress chikankari',
    },
    'Chikankari': {
      'female': 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800',
      'search': 'Lucknow chikankari kurta',
    },
    // Rajasthan
    'Ghagra Choli': {
      'female': 'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=800',
      'search': 'Rajasthani ghagra choli traditional',
    },
    'Angrakha': {
      'male': 'https://images.unsplash.com/photo-1604607053857-8a8d6f7b1a4e?w=800',
      'search': 'Rajasthani traditional dress men turban',
    },
    // Maharashtra
    'Nauvari': {
      'female': 'https://images.unsplash.com/photo-1610189019599-0b1fae7b4b53?w=800',
      'search': 'Nauvari saree Marathi traditional',
    },
    'Paithani': {
      'female': 'https://images.unsplash.com/photo-1610189019599-0b1fae7b4b53?w=800',
      'search': 'Paithani saree Maharashtra',
    },
    // Gujarat
    'Chaniya Choli': {
      'female': 'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=800',
      'search': 'Navratri chaniya choli garba',
    },
    'Kediyu': {
      'male': 'https://images.unsplash.com/photo-1604607053857-8a8d6f7b1a4e?w=800',
      'search': 'Gujarati kediyu traditional garba men',
    },
    // Punjab
    'Patiala': {
      'female': 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800',
      'search': 'Punjabi patiala salwar phulkari',
    },
    'Phulkari': {
      'female': 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800',
      'search': 'Phulkari dupatta Punjab traditional',
    },
    // South India
    'Kanchipuram': {
      'female': 'https://images.unsplash.com/photo-1610189019599-0b1fae7b4b53?w=800',
      'search': 'Kanchipuram silk saree bride',
    },
    'Kasavu': {
      'female': 'https://images.unsplash.com/photo-1610189019599-0b1fae7b4b53?w=800',
      'search': 'Kerala kasavu saree onam',
    },
    'Mundu': {
      'male': 'https://images.unsplash.com/photo-1604607053857-8a8d6f7b1a4e?w=800',
      'search': 'Kerala mundu traditional men',
    },
    // Bengal
    'Tant': {
      'female': 'https://images.unsplash.com/photo-1610189019599-0b1fae7b4b53?w=800',
      'search': 'Bengali tant saree red white',
    },
    'Baluchari': {
      'female': 'https://images.unsplash.com/photo-1610189019599-0b1fae7b4b53?w=800',
      'search': 'Baluchari silk saree Bengal',
    },
    // Generic fallbacks
    'male_generic': {
      'male': 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800',
      'search': 'Indian traditional men kurta',
    },
    'female_generic': {
      'female': 'https://images.unsplash.com/photo-1610189019599-0b1fae7b4b53?w=800',
      'search': 'Indian traditional saree woman',
    },
  };

  /// Get dress image with multi-API fallback
  static Future<String?> getDressImage(String dressName, String state, String gender) async {
    // Check cache first
    final cacheKey = '${dressName}_${state}_$gender';
    if (_imageCache.containsKey(cacheKey)) {
      print('📸 [CACHE] Image for $dressName');
      return _imageCache[cacheKey];
    }

    String? imageUrl;

    // 1. Try static URL first
    imageUrl = _getStaticImage(dressName, gender);
    if (imageUrl != null) {
      _imageCache[cacheKey] = imageUrl;
      print('📸 [STATIC] Image for $dressName');
      return imageUrl;
    }

    // 2. Try Pexels
    imageUrl = await _tryPexels(dressName, state, gender);
    if (imageUrl != null) {
      _imageCache[cacheKey] = imageUrl;
      print('📸 [PEXELS] Image for $dressName');
      return imageUrl;
    }

    // 3. Try Unsplash
    imageUrl = await _tryUnsplash(dressName, state, gender);
    if (imageUrl != null) {
      _imageCache[cacheKey] = imageUrl;
      print('📸 [UNSPLASH] Image for $dressName');
      return imageUrl;
    }

    // 4. Return generic fallback
    imageUrl = _getGenericFallback(gender);
    if (imageUrl != null) {
      _imageCache[cacheKey] = imageUrl;
      print('📸 [GENERIC] Image for $dressName');
    }
    
    return imageUrl;
  }

  static String? _getStaticImage(String dressName, String gender) {
    // Check for exact match
    for (final entry in _staticDressImages.entries) {
      if (dressName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value[gender] ?? entry.value['female'] ?? entry.value['male'];
      }
    }
    return null;
  }

  static String? _getGenericFallback(String gender) {
    final key = '${gender}_generic';
    return _staticDressImages[key]?[gender];
  }

  static Future<String?> _tryPexels(String dressName, String state, String gender) async {
    final queries = [
      '$dressName traditional Indian ${gender == 'male' ? 'men' : 'women'}',
      '$state traditional dress India',
      'Indian ${gender == 'male' ? 'kurta sherwani' : 'saree lehenga'} traditional',
    ];

    for (final query in queries) {
      try {
        final url = Uri.parse('$_pexelsBaseUrl/search?query=${Uri.encodeComponent(query)}&per_page=3&orientation=portrait');
        
        final response = await http.get(url, headers: {
          'Authorization': _pexelsApiKey,
        }).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final photos = data['photos'] as List;

          if (photos.isNotEmpty) {
            return photos[0]['src']['medium'] as String;
          }
        } else if (response.statusCode == 429) {
          print('⚠️ Pexels rate limit');
          break;
        }
      } catch (e) {
        print('Pexels error: $e');
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
    return null;
  }

  static Future<String?> _tryUnsplash(String dressName, String state, String gender) async {
    final queries = [
      '$dressName Indian traditional',
      '$state traditional clothing',
      'Indian ${gender == 'male' ? 'ethnic wear men' : 'saree traditional'}',
    ];

    for (final query in queries) {
      try {
        final url = Uri.parse('$_unsplashBaseUrl/search/photos?query=${Uri.encodeComponent(query)}&per_page=3&orientation=portrait');
        
        final response = await http.get(url, headers: {
          'Authorization': 'Client-ID $_unsplashAccessKey',
        }).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          if (results.isNotEmpty) {
            return results[0]['urls']['small'] as String;
          }
        } else if (response.statusCode == 403) {
          print('⚠️ Unsplash rate limit');
          break;
        }
      } catch (e) {
        print('Unsplash error: $e');
      }
      await Future.delayed(Duration(milliseconds: 200));
    }
    return null;
  }

  static void clearCache() {
    _imageCache.clear();
  }
}

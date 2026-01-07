import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiService {
  // 🔑 ADD YOUR GEMINI API KEY HERE
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  static late GenerativeModel _model;

  // Initialize Gemini
  static void init() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  // Get city tagline (e.g., "City of Taj" for Agra)
  static Future<String> getCityTagline(String cityName) async {
    try {
      final prompt = '''
Generate a short, famous tagline for $cityName, India (3-5 words).
Examples:
- Agra: "City of Taj"
- Delhi: "Heart of India"
- Jaipur: "Pink City"
- Mumbai: "City of Dreams"

Return ONLY the tagline, nothing else.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'Historic City';
    } catch (e) {
      print('Error generating tagline: $e');
      return 'Historic City';
    }
  }

  // Generate DETAILED food data with ingredients and cooking info
  static Future<Map<String, dynamic>> generateFoodData(String cityName) async {
    try {
      final prompt = '''
You are an expert on Indian cuisine. Generate DETAILED and SPECIFIC food information for $cityName, India.

RULES:
1. Use REAL dish names that $cityName is ACTUALLY famous for
2. Include ingredients, preparation method, and taste
3. Provide rich, detailed descriptions (3-4 sentences per dish)
4. Categorize dishes (Main Course, Dessert, Snack, Beverage)
5. Be historically accurate

Return ONLY valid JSON:

{
  "description": "Detailed 4-5 sentence description of $cityName's cuisine, its history, influences, and what makes it unique",
  "dishes": [
    {
      "name": "Exact dish name (e.g., Petha for Agra)",
      "category": "Main Course/Dessert/Snack/Beverage/Breakfast",
      "description": "Detailed description: what it is, main ingredients, how it's made, taste profile, history/significance (3-4 sentences)",
      "ingredients": "Main ingredients used",
      "type": "Vegetarian/Non-Vegetarian/Vegan",
      "specialty": "Why this dish is special to $cityName (1 sentence)"
    }
  ]
}

For $cityName, include 6-8 REAL famous dishes. Be very specific and accurate.
Examples for different cities:
- Agra: Petha (dessert), Bedai (breakfast), Dalmoth (snack)
- Delhi: Chole Bhature, Butter Chicken, Paranthe
- Jaipur: Dal Baati Churma, Ghewar, Laal Maas
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();

      return json.decode(cleanText);
    } catch (e) {
      print('Error generating food data: $e');
      return _getDefaultFoodData();
    }
  }

  // Generate DETAILED traditional dress information
  static Future<Map<String, dynamic>> generateDressData(String cityName, String state) async {
    try {
      final prompt = '''
You are an expert on Indian traditional clothing. Generate DETAILED information about traditional dress for $cityName, $state.

RULES:
1. Use REAL traditional dress names from this region
2. Include fabric details, colors, patterns, embroidery styles
3. Explain cultural significance and history
4. Mention when and how they're worn

Return ONLY valid JSON:

{
  "description": "Detailed 4-5 sentence description of traditional attire in $cityName/$state region, its cultural significance, history, and evolution",
  "male": {
    "name": "Actual traditional dress name for men in this region",
    "description": "Very detailed description: fabric, colors, style, how it's worn, components (3-4 sentences)",
    "components": ["List of clothing pieces: e.g., Kurta, Churidar, Turban"],
    "fabric": "Traditional fabrics used",
    "colors": "Traditional colors and their significance",
    "occasions": ["When worn"],
    "cultural_significance": "Why this dress is important to the region (2 sentences)"
  },
  "female": {
    "name": "Actual traditional dress name for women",
    "description": "Very detailed description: fabric, colors, draping style, embroidery, jewelry (3-4 sentences)",
    "components": ["List of clothing pieces"],
    "fabric": "Traditional fabrics used",
    "embroidery": "Traditional embroidery styles",
    "jewelry": "Traditional jewelry worn with this dress",
    "occasions": ["When worn"],
    "cultural_significance": "Why this dress is important (2 sentences)"
  }
}

Be specific to $cityName/$state region. For example:
- Rajasthan: Ghagra Choli with Bandhani, mirror work
- Punjab: Salwar Kameez with Phulkari embroidery
- UP (Agra): Anarkali suits, Chikankari work
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();

      return json.decode(cleanText);
    } catch (e) {
      print('Error generating dress data: $e');
      return _getDefaultDressData();
    }
  }

  // Generate DETAILED culture information
  static Future<Map<String, dynamic>> generateCultureData(String cityName) async {
    try {
      final prompt = '''
You are an expert on Indian culture and traditions. Generate DETAILED cultural information for $cityName, India.

RULES:
1. Focus on UNIQUE cultural aspects of $cityName
2. Include historical context and modern practices
3. Explain significance and how traditions are practiced
4. Be specific to this city, not general India info

Return ONLY valid JSON:

{
  "description": "Detailed 5-6 sentence description of $cityName's unique cultural identity, traditions, lifestyle, and what makes it culturally distinct",
  "festivals": [
    {
      "name": "Real festival name celebrated in $cityName",
      "description": "Detailed description: history, how it's celebrated, rituals, significance, dates (3-4 sentences)",
      "celebrations": "Specific ways this city celebrates (processions, decorations, special foods)",
      "month": "When celebrated",
      "significance": "Why important to $cityName (1-2 sentences)"
    }
  ],
  "traditions": [
    {
      "name": "Specific cultural tradition",
      "description": "Detailed explanation of this tradition (2-3 sentences)"
    }
  ],
  "languages": ["Languages spoken with dialect info"],
  "art_forms": [
    {
      "name": "Traditional art/craft form",
      "description": "What it is and its significance (1-2 sentences)"
    }
  ],
  "cuisine_culture": "How food and eating are part of cultural identity (2 sentences)",
  "lifestyle": "Daily life, values, social customs in $cityName (2-3 sentences)"
}

Include 4-5 major festivals and 3-4 art forms specific to $cityName.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();

      return json.decode(cleanText);
    } catch (e) {
      print('Error generating culture data: $e');
      return _getDefaultCultureData();
    }
  }

  // Generate DETAILED tourist places with practical info
  static Future<List<Map<String, dynamic>>> generateTouristPlaces(String cityName) async {
    try {
      final prompt = '''
You are a tourism expert on $cityName, India. Generate DETAILED information about must-visit places.

RULES:
1. Use REAL, famous places in $cityName (not generic names)
2. Include complete practical information
3. Add historical context and significance
4. Provide visitor tips and rules

Return ONLY valid JSON array:

[
  {
    "name": "Exact name of famous place in $cityName",
    "description": "Detailed description: what it is, historical background, architecture, significance, what visitors can see/do (4-5 sentences)",
    "history": "Historical background and who built it (2-3 sentences)",
    "architecture": "Architectural style and unique features (if applicable)",
    "timings": "Exact opening hours (e.g., 'Sunrise to Sunset' or '9:00 AM - 5:00 PM')",
    "entry_fee": "Exact fees (e.g., 'INR 50 for Indians, INR 1100 for foreigners' or 'Free')",
    "closed_on": "Days closed (e.g., 'Friday' or 'No weekly off')",
    "best_time": "Best time to visit (e.g., 'Early morning or sunset')",
    "rules": ["Visitor rules: e.g., 'No photography inside', 'Remove shoes', 'Dress modestly'"],
    "tips": ["Visitor tips: e.g., 'Arrive early to avoid crowds', 'Hire official guide'"],
    "duration": "Suggested visit duration",
    "category": "Monument/Temple/Museum/Fort/Palace/Garden/Market"
  }
]

For $cityName, include 6-8 REAL famous places. Examples:
- Agra: Taj Mahal, Agra Fort, Fatehpur Sikri, Mehtab Bagh, Itmad-ud-Daulah, Akbar's Tomb
- Delhi: Red Fort, Qutub Minar, India Gate, Humayun's Tomb, Lotus Temple
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '[]';
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final data = json.decode(cleanText);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error generating tourist places: $e');
      return _getDefaultTouristPlaces();
    }
  }

  // Generate DETAILED historical information with timeline
  static Future<Map<String, dynamic>> generateHistoryData(String cityName) async {
    try {
      final prompt = '''
You are a history expert on Indian cities. Generate DETAILED historical information for $cityName, India.

RULES:
1. Include REAL historical events, rulers, dynasties
2. Explain significance and impact on the city
3. Mention important monuments built during each period
4. Connect history to present-day city

Return ONLY valid JSON:

{
  "overview": "Comprehensive historical overview of $cityName: ancient origins, rise to prominence, major events, and its place in Indian history (5-6 sentences)",
  "significance": "Why $cityName is historically important to India (2-3 sentences)",
  "timeline": [
    {
      "period": "Specific time period with dates (e.g., 'Mughal Era (1526-1857)')",
      "title": "Short title for this period",
      "description": "Detailed description: major events, rulers, developments, monuments built, impact on city (4-5 sentences)",
      "key_events": ["Important events during this period"],
      "rulers": ["Important rulers/leaders"],
      "monuments": ["Monuments/buildings from this period still visible today"],
      "legacy": "How this period shaped modern $cityName (1-2 sentences)"
    }
  ],
  "modern_era": "Brief description of $cityName from independence to present (2-3 sentences)",
  "heritage": "UNESCO sites or protected monuments in $cityName"
}

For $cityName, include 5-7 major historical periods chronologically. Examples:
- Agra: Ancient period, Lodi Dynasty, Mughal Empire (Akbar, Jahangir, Shah Jahan), Decline, British Raj, Modern India
- Delhi: Indraprastha, Delhi Sultanate, Mughal Empire, British Raj, Capital of India
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '{}';
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();

      return json.decode(cleanText);
    } catch (e) {
      print('Error generating history data: $e');
      return _getDefaultHistoryData();
    }
  }

  // Default fallback data
  static Map<String, dynamic> _getDefaultFoodData() {
    return {
      "description": "This city has a rich culinary tradition with diverse flavors and traditional recipes passed down through generations.",
      "dishes": [
        {
          "name": "Traditional Dish",
          "category": "Main Course",
          "description": "A beloved local specialty that represents the culinary heritage of the region.",
          "ingredients": "Local spices and fresh ingredients",
          "type": "Vegetarian",
          "specialty": "A must-try for visitors"
        }
      ]
    };
  }

  static Map<String, dynamic> _getDefaultDressData() {
    return {
      "description": "Traditional attire in this region reflects centuries of cultural heritage and craftsmanship.",
      "male": {
        "name": "Traditional Attire",
        "description": "Traditional clothing worn on special occasions and festivals.",
        "components": ["Traditional garments"],
        "fabric": "Cotton and silk",
        "colors": "Various traditional colors",
        "occasions": ["Festivals", "Weddings"],
        "cultural_significance": "Represents cultural identity"
      },
      "female": {
        "name": "Traditional Attire",
        "description": "Elegant traditional dress with intricate work.",
        "components": ["Traditional garments"],
        "fabric": "Silk and cotton",
        "embroidery": "Traditional embroidery",
        "jewelry": "Traditional jewelry",
        "occasions": ["Festivals", "Weddings"],
        "cultural_significance": "Symbol of cultural pride"
      }
    };
  }

  static Map<String, dynamic> _getDefaultCultureData() {
    return {
      "description": "Rich cultural traditions and a vibrant heritage define this city's identity.",
      "festivals": [
        {
          "name": "Local Festival",
          "description": "Celebrated with great enthusiasm and traditional rituals.",
          "celebrations": "Traditional celebrations",
          "month": "Various",
          "significance": "Important cultural event"
        }
      ],
      "traditions": [],
      "languages": ["Hindi", "English"],
      "art_forms": [],
      "cuisine_culture": "Food plays an important role in cultural celebrations.",
      "lifestyle": "Traditional values blend with modern living."
    };
  }

  static List<Map<String, dynamic>> _getDefaultTouristPlaces() {
    return [
      {
        "name": "Historic Site",
        "description": "An important landmark showcasing the city's rich heritage.",
        "history": "Built in ancient times",
        "timings": "9:00 AM - 5:00 PM",
        "entry_fee": "Varies",
        "closed_on": "Check locally",
        "best_time": "Morning or evening",
        "rules": ["Follow visitor guidelines"],
        "tips": ["Plan your visit in advance"],
        "duration": "2-3 hours",
        "category": "Monument"
      }
    ];
  }

  static Map<String, dynamic> _getDefaultHistoryData() {
    return {
      "overview": "This city has a rich historical background spanning several centuries.",
      "significance": "Played an important role in regional history.",
      "timeline": [
        {
          "period": "Ancient Times",
          "title": "Early History",
          "description": "Early settlements and development of the city.",
          "key_events": ["Early development"],
          "rulers": ["Ancient rulers"],
          "monuments": ["Ancient structures"],
          "legacy": "Foundation of the city"
        }
      ],
      "modern_era": "Continues to grow as an important city.",
      "heritage": "Protected historical sites"
    };
  }
}
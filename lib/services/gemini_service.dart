import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'groq_service.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static late GenerativeModel _model;

  static void init() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );
  }

  // Static map of famous Indian city taglines
  static const Map<String, String> _cityTaglines = {
    // Major Metro Cities
    'Mumbai': 'City of Dreams',
    'Delhi': 'Heart of India',
    'Bangalore': 'Silicon Valley of India',
    'Bengaluru': 'Silicon Valley of India',
    'Chennai': 'Gateway to South India',
    'Kolkata': 'City of Joy',
    'Hyderabad': 'City of Pearls',

    // Tourist & Heritage Cities
    'Agra': 'City of Taj',
    'Jaipur': 'Pink City',
    'Jodhpur': 'Blue City',
    'Udaipur': 'City of Lakes',
    'Jaisalmer': 'Golden City',
    'Varanasi': 'Spiritual Capital of India',
    'Banaras': 'Spiritual Capital of India',
    'Kashi': 'City of Temples',
    'Amritsar': 'Holy City of Sikhs',
    'Haridwar': 'Gateway to Gods',
    'Rishikesh': 'Yoga Capital of the World',
    'Mysore': 'City of Palaces',
    'Mysuru': 'City of Palaces',

    // Western India
    'Pune': 'Deccan Queen',
    'Ahmedabad': 'Manchester of India',
    'Surat': 'Diamond City',
    'Vadodara': 'Cultural Capital of Gujarat',
    'Goa': 'Pearl of the Orient',
    'Nashik': 'Wine Capital of India',

    // Southern India
    'Kochi': 'Queen of the Arabian Sea',
    'Thiruvananthapuram': 'Evergreen City of India',
    'Madurai': 'Athens of the East',
    'Coimbatore': 'Manchester of South India',
    'Thanjavur': 'Rice Bowl of Tamil Nadu',
    'Pondicherry': 'French Riviera of the East',
    'Puducherry': 'French Riviera of the East',
    'Ooty': 'Queen of Hill Stations',
    'Hampi': 'City of Ruins',

    // Northern India
    'Lucknow': 'City of Nawabs',
    'Allahabad': 'Sangam City',
    'Prayagraj': 'Sangam City',
    'Kanpur': 'Leather City of India',
    'Chandigarh': 'City Beautiful',
    'Shimla': 'Queen of Hills',
    'Dehradun': 'Abode of Drona',
    'Mussoorie': 'Queen of the Hills',
    'Nainital': 'Lake District of India',
    'Mathura': 'Birthplace of Lord Krishna',
    'Vrindavan': 'Land of Krishna',
    'Ayodhya': 'Birthplace of Lord Rama',

    // Eastern India
    'Darjeeling': 'Queen of the Himalayas',
    'Gangtok': 'Land of Monasteries',
    'Bhubaneswar': 'Temple City of India',
    'Puri': 'Holy City of Lord Jagannath',
    'Guwahati': 'Gateway to Northeast',
    'Shillong': 'Scotland of the East',
    'Patna': 'City of Knowledge',

    // Central India
    'Bhopal': 'City of Lakes',
    'Indore': 'Food Capital of India',
    'Gwalior': 'City of Music',
    'Khajuraho': 'City of Temples',
    'Raipur': 'Rice Bowl of India',
    'Nagpur': 'Orange City',

    // Other Notable Cities
    'Aurangabad': 'City of Gates',
    'Ajmer': 'Heart of Rajasthan',
    'Pushkar': 'Rose Garden of Rajasthan',
    'Bikaner': 'Camel Country',
    'Mount Abu': 'Oasis in the Desert',
    'Kodaikanal': 'Princess of Hill Stations',
    'Munnar': 'Kashmir of South India',
    'Visakhapatnam': 'City of Destiny',
    'Vijayawada': 'Place of Victory',
    'Mangalore': 'Gateway to Karnataka',
    'Tirupati': 'Spiritual Capital of Andhra',
  };

  // In-memory cache for dynamically fetched taglines
  static final Map<String, String> _taglineCache = {};

  /// Get city tagline - Multi-layer fallback system
  /// Priority: Static Map → Cache → Gemini API → Groq API → Default
  static Future<String> getCityTagline(String cityName) async {
    // 1. Check static map first (instant, no API needed)
    final staticTagline = _cityTaglines[cityName];
    if (staticTagline != null) {
      print('✅ [STATIC] $cityName: $staticTagline');
      return staticTagline;
    }

    // 2. Check in-memory cache (previously fetched)
    final cachedTagline = _taglineCache[cityName];
    if (cachedTagline != null) {
      print('✅ [CACHE] $cityName: $cachedTagline');
      return cachedTagline;
    }

    // 3. Try Gemini API
    String? tagline = await _tryGeminiApi(cityName);
    if (tagline != null) {
      _taglineCache[cityName] = tagline; // Cache for future
      return tagline;
    }

    // 4. Try Groq API as backup (uses GroqService)
    tagline = await GroqService.getCityTagline(cityName);
    if (tagline != null) {
      _taglineCache[cityName] = tagline; // Cache for future
      return tagline;
    }

    // 5. Return default
    print('⚠️ [DEFAULT] $cityName: Historic City');
    return 'Historic City';
  }

  /// Try Gemini API for tagline
  static Future<String?> _tryGeminiApi(String cityName) async {
    try {
      print('🔍 [GEMINI] Trying for $cityName...');
      final prompt = 'What is the famous nickname for $cityName, India? Reply with ONLY 2-4 words.';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      final cleaned = text.replaceAll(RegExp(r'[\n\r]'), '').trim();

      if (cleaned.isNotEmpty && cleaned.length < 50) {
        print('✅ [GEMINI] $cityName: $cleaned');
        return cleaned;
      }
    } catch (e) {
      print('⚠️ [GEMINI] Error: $e');
    }
    return null;
  }

  // Static food data for major cities (instant, no API needed)
  static const Map<String, List<Map<String, dynamic>>> _cityFoodData = {
    'Agra': [
      {
        'name': 'Petha',
        'category': 'Dessert',
        'description': 'A translucent soft candy made from ash gourd (white pumpkin). Known for its melt-in-mouth texture and comes in various flavors like Angoori, Paan, and Kesar.',
        'main_ingredients': 'Ash gourd, Sugar, Cardamom, Rose water',
        'type': 'Vegetarian',
        'famous_place': 'Panchi Petha, Sadar Bazaar'
      },
      {
        'name': 'Bedai',
        'category': 'Breakfast',
        'description': 'Deep-fried puffed bread stuffed with spiced urad dal. Served hot with spicy aloo sabzi and tangy pickle, it\'s Agra\'s favorite breakfast.',
        'main_ingredients': 'Wheat flour, Urad dal, Spices, Oil',
        'type': 'Vegetarian',
        'famous_place': 'Deviram Sweets, Belanganj'
      },
      {
        'name': 'Dalmoth',
        'category': 'Snack',
        'description': 'A crispy namkeen made with fried lentils, nuts, and spices. A perfect tea-time snack with a unique tangy-spicy taste that Agra is famous for.',
        'main_ingredients': 'Moong dal, Peanuts, Spices, Oil',
        'type': 'Vegetarian',
        'famous_place': 'Bikanervala, Sadar Bazaar'
      },
      {
        'name': 'Mughlai Paratha',
        'category': 'Main Course',
        'description': 'A rich, flaky paratha stuffed with spiced minced meat or paneer. Reflects the Mughal culinary heritage of Agra.',
        'main_ingredients': 'Flour, Eggs, Meat/Paneer, Spices',
        'type': 'Non-Vegetarian',
        'famous_place': 'Pinch of Spice, Fatehabad Road'
      },
    ],
    'Delhi': [
      {
        'name': 'Chole Bhature',
        'category': 'Breakfast',
        'description': 'Spicy chickpea curry served with deep-fried fluffy bread. A quintessential Delhi breakfast that\'s hearty and flavorful.',
        'main_ingredients': 'Chickpeas, Flour, Spices, Oil',
        'type': 'Vegetarian',
        'famous_place': 'Sita Ram Diwan Chand, Paharganj'
      },
      {
        'name': 'Paranthe',
        'category': 'Breakfast',
        'description': 'Stuffed flatbreads fried in ghee, served with pickle, curd, and chutney. Legendary Paranthewali Gali has been serving these since 1872.',
        'main_ingredients': 'Wheat flour, Potato/Paneer, Ghee, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Paranthewali Gali, Chandni Chowk'
      },
      {
        'name': 'Butter Chicken',
        'category': 'Main Course',
        'description': 'Tender chicken pieces in rich, creamy tomato-based gravy. Invented in Delhi, it\'s now famous worldwide.',
        'main_ingredients': 'Chicken, Butter, Cream, Tomatoes, Spices',
        'type': 'Non-Vegetarian',
        'famous_place': 'Moti Mahal, Daryaganj'
      },
      {
        'name': 'Chaat',
        'category': 'Street Food',
        'description': 'Crispy papdi topped with yogurt, chutneys, and spices. The perfect blend of sweet, sour, and spicy flavors.',
        'main_ingredients': 'Papdi, Curd, Chutneys, Sev, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Natraj Dahi Bhalle, Chandni Chowk'
      },
    ],
    'Mumbai': [
      {
        'name': 'Vada Pav',
        'category': 'Street Food',
        'description': 'Mumbai\'s iconic burger - spicy potato fritter in a bun with chutneys. The ultimate quick meal that defines Mumbai\'s street food culture.',
        'main_ingredients': 'Potato, Gram flour, Pav bread, Chutneys',
        'type': 'Vegetarian',
        'famous_place': 'Ashok Vada Pav, Kirti College'
      },
      {
        'name': 'Pav Bhaji',
        'category': 'Street Food',
        'description': 'Spiced mashed vegetable curry served with buttered bread rolls. Originally a mill workers\' meal, now Mumbai\'s beloved street food.',
        'main_ingredients': 'Mixed vegetables, Butter, Pav, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Sardar Pav Bhaji, Tardeo'
      },
      {
        'name': 'Bombay Sandwich',
        'category': 'Snack',
        'description': 'Layered sandwich with vegetables, chutney, and cheese, grilled to perfection. A Mumbai street food staple.',
        'main_ingredients': 'Bread, Vegetables, Cheese, Chutney',
        'type': 'Vegetarian',
        'famous_place': 'Amar Sandwich, Marine Lines'
      },
    ],
    'Jaipur': [
      {
        'name': 'Dal Baati Churma',
        'category': 'Main Course',
        'description': 'Baked wheat balls served with dal and sweet churma. The signature Rajasthani dish representing royal cuisine.',
        'main_ingredients': 'Wheat flour, Ghee, Lentils, Jaggery',
        'type': 'Vegetarian',
        'famous_place': 'Chokhi Dhani, Tonk Road'
      },
      {
        'name': 'Ghewar',
        'category': 'Dessert',
        'description': 'Disc-shaped sweet made from flour and soaked in sugar syrup. A Rajasthani festive delicacy, especially during Teej.',
        'main_ingredients': 'Flour, Ghee, Sugar syrup, Saffron',
        'type': 'Vegetarian',
        'famous_place': 'Laxmi Mishthan Bhandar (LMB)'
      },
      {
        'name': 'Pyaaz Kachori',
        'category': 'Breakfast',
        'description': 'Deep-fried pastry stuffed with spiced onion filling. Crispy outside, flavorful inside - Jaipur\'s popular breakfast.',
        'main_ingredients': 'Flour, Onions, Spices, Oil',
        'type': 'Vegetarian',
        'famous_place': 'Rawat Mishthan Bhandar'
      },
    ],
    'Varanasi': [
      {
        'name': 'Banarasi Paan',
        'category': 'Digestive',
        'description': 'Betel leaf filled with gulkand, supari, and special ingredients. A refreshing mouth freshener and cultural symbol of Banaras.',
        'main_ingredients': 'Betel leaf, Gulkand, Supari, Lime',
        'type': 'Vegetarian',
        'famous_place': 'Keshav Tambul Bhandar, Godowlia'
      },
      {
        'name': 'Kachori Sabzi',
        'category': 'Breakfast',
        'description': 'Crispy kachori served with spicy potato curry. The authentic Banarasi breakfast enjoyed by locals and tourists alike.',
        'main_ingredients': 'Flour, Lentils, Potatoes, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Ram Bhandar, Thatheri Bazaar'
      },
      {
        'name': 'Malaiyo',
        'category': 'Dessert',
        'description': 'Airy milk froth dessert available only in winters. Made by churning milk overnight in the cold, it\'s a seasonal delicacy.',
        'main_ingredients': 'Milk, Saffron, Sugar, Cardamom',
        'type': 'Vegetarian',
        'famous_place': 'Godowlia Chowk (Winter only)'
      },
    ],
    'Lucknow': [
      {
        'name': 'Galouti Kebab',
        'category': 'Appetizer',
        'description': 'Melt-in-mouth minced meat kebabs made with 160 spices. Created for a toothless Nawab, these are Lucknow\'s culinary pride.',
        'main_ingredients': 'Minced meat, Papaya, 160 spices',
        'type': 'Non-Vegetarian',
        'famous_place': 'Tunday Kababi, Aminabad'
      },
      {
        'name': 'Lucknowi Biryani',
        'category': 'Main Course',
        'description': 'Aromatic rice and meat dish cooked in dum style. Subtle flavors distinguish it from Hyderabadi biryani.',
        'main_ingredients': 'Basmati rice, Meat, Saffron, Spices',
        'type': 'Non-Vegetarian',
        'famous_place': 'Idris Biryani, Chowk'
      },
      {
        'name': 'Basket Chaat',
        'category': 'Street Food',
        'description': 'Crispy potato basket filled with chickpeas, chutneys, and curd. Lucknow\'s innovative take on traditional chaat.',
        'main_ingredients': 'Potato, Chickpeas, Curd, Chutneys',
        'type': 'Vegetarian',
        'famous_place': 'Royal Cafe, Hazratganj'
      },
    ],
    'Kolkata': [
      {
        'name': 'Rosogulla',
        'category': 'Dessert',
        'description': 'Soft, spongy cheese balls soaked in sugar syrup. Bengal\'s most famous sweet that melts in your mouth.',
        'main_ingredients': 'Chhena, Sugar, Rose water',
        'type': 'Vegetarian',
        'famous_place': 'K.C. Das, Esplanade'
      },
      {
        'name': 'Kathi Roll',
        'category': 'Street Food',
        'description': 'Paratha wrapped around spiced kebab or vegetables. Invented in Kolkata, now a worldwide street food sensation.',
        'main_ingredients': 'Paratha, Egg, Meat/Paneer, Onions',
        'type': 'Non-Vegetarian',
        'famous_place': 'Nizam\'s, New Market'
      },
      {
        'name': 'Mishti Doi',
        'category': 'Dessert',
        'description': 'Sweetened yogurt set in earthen pots. The caramelized sugar gives it a unique flavor that Bengal is famous for.',
        'main_ingredients': 'Milk, Sugar, Yogurt culture',
        'type': 'Vegetarian',
        'famous_place': 'Balaram Mullick & Radharaman Mullick'
      },
    ],
    'Hyderabad': [
      {
        'name': 'Hyderabadi Biryani',
        'category': 'Main Course',
        'description': 'Fragrant basmati rice layered with spiced meat, cooked on dum. The crown jewel of Hyderabadi cuisine.',
        'main_ingredients': 'Basmati rice, Meat, Saffron, Spices',
        'type': 'Non-Vegetarian',
        'famous_place': 'Paradise Restaurant, Secunderabad'
      },
      {
        'name': 'Haleem',
        'category': 'Main Course',
        'description': 'Slow-cooked stew of meat, lentils, and wheat. A Ramadan special that takes hours to prepare.',
        'main_ingredients': 'Meat, Wheat, Lentils, Ghee, Spices',
        'type': 'Non-Vegetarian',
        'famous_place': 'Pista House, Various locations'
      },
      {
        'name': 'Double Ka Meetha',
        'category': 'Dessert',
        'description': 'Bread slices fried and soaked in saffron milk. A royal Hyderabadi dessert from the Nizam\'s kitchen.',
        'main_ingredients': 'Bread, Milk, Saffron, Sugar, Nuts',
        'type': 'Vegetarian',
        'famous_place': 'Shah Ghouse, Tolichowki'
      },
    ],
    'Pune': [
      {
        'name': 'Misal Pav',
        'category': 'Breakfast',
        'description': 'Spicy sprouted moth beans curry topped with farsan, served with pav. Maharashtra\'s fiery breakfast champion.',
        'main_ingredients': 'Moth beans, Farsan, Pav, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Bedekar Misal, Narayan Peth'
      },
      {
        'name': 'Mastani',
        'category': 'Beverage',
        'description': 'Thick milkshake topped with ice cream, dry fruits, and nuts. Pune\'s signature drink named after Bajirao\'s beloved.',
        'main_ingredients': 'Milk, Ice cream, Fruits, Dry fruits',
        'type': 'Vegetarian',
        'famous_place': 'Sujata Mastani, FC Road'
      },
      {
        'name': 'Bhakarwadi',
        'category': 'Snack',
        'description': 'Crispy spiral snack with spicy filling. A Pune specialty that\'s both sweet and spicy.',
        'main_ingredients': 'Flour, Coconut, Spices, Sugar',
        'type': 'Vegetarian',
        'famous_place': 'Chitale Bandhu, Various locations'
      },
    ],
    'Amritsar': [
      {
        'name': 'Amritsari Kulcha',
        'category': 'Breakfast',
        'description': 'Stuffed bread baked in tandoor, served with chole. The authentic Amritsari breakfast that\'s crispy and flavorful.',
        'main_ingredients': 'Flour, Potato/Paneer, Butter, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Kulcha Land, Lawrence Road'
      },
      {
        'name': 'Lassi',
        'category': 'Beverage',
        'description': 'Thick, creamy yogurt drink topped with cream. Amritsari lassi is famous for its rich, buttery taste.',
        'main_ingredients': 'Yogurt, Cream, Sugar, Cardamom',
        'type': 'Vegetarian',
        'famous_place': 'Giani Tea Stall, Town Hall'
      },
      {
        'name': 'Amritsari Fish',
        'category': 'Appetizer',
        'description': 'Crispy fried fish in gram flour batter. The signature non-veg dish of Amritsar, served with chutney.',
        'main_ingredients': 'Fish, Gram flour, Spices, Ajwain',
        'type': 'Non-Vegetarian',
        'famous_place': 'Makhan Fish Corner, Majitha Road'
      },
    ],
    'Chennai': [
      {
        'name': 'Idli Sambar',
        'category': 'Breakfast',
        'description': 'Soft steamed rice cakes served with flavorful lentil soup and coconut chutney. The quintessential South Indian breakfast.',
        'main_ingredients': 'Rice, Urad dal, Lentils, Vegetables',
        'type': 'Vegetarian',
        'famous_place': 'Murugan Idli Shop, T. Nagar'
      },
      {
        'name': 'Dosa',
        'category': 'Breakfast',
        'description': 'Crispy fermented rice crepe served with sambar and chutneys. Chennai is famous for paper-thin Masala Dosa.',
        'main_ingredients': 'Rice, Urad dal, Potato masala',
        'type': 'Vegetarian',
        'famous_place': 'Saravana Bhavan, Multiple locations'
      },
      {
        'name': 'Filter Coffee',
        'category': 'Beverage',
        'description': 'Strong, aromatic coffee made with freshly ground beans and served in a traditional tumbler and dabara.',
        'main_ingredients': 'Coffee powder, Chicory, Milk, Sugar',
        'type': 'Vegetarian',
        'famous_place': 'Indian Coffee House, Mount Road'
      },
      {
        'name': 'Chettinad Chicken',
        'category': 'Main Course',
        'description': 'Spicy chicken curry with a complex blend of freshly ground spices from Chettinad region.',
        'main_ingredients': 'Chicken, Chettinad spices, Coconut, Curry leaves',
        'type': 'Non-Vegetarian',
        'famous_place': 'Ponnusamy Hotel, Egmore'
      },
    ],
    'Goa': [
      {
        'name': 'Fish Curry Rice',
        'category': 'Main Course',
        'description': 'Goan staple of tangy fish curry made with kokum and coconut, served with fluffy rice. A must-try coastal delicacy.',
        'main_ingredients': 'Fish, Coconut, Kokum, Spices, Rice',
        'type': 'Non-Vegetarian',
        'famous_place': 'Ritz Classic, Panjim'
      },
      {
        'name': 'Bebinca',
        'category': 'Dessert',
        'description': 'Traditional 7-16 layered Goan dessert made with coconut milk and eggs. A Portuguese-influenced sweet masterpiece.',
        'main_ingredients': 'Coconut milk, Eggs, Sugar, Ghee, Flour',
        'type': 'Vegetarian',
        'famous_place': 'Hospedaria Venite, Panjim'
      },
      {
        'name': 'Pork Vindaloo',
        'category': 'Main Course',
        'description': 'Fiery pork curry marinated in vinegar and spices. The famous Portuguese-Goan fusion dish.',
        'main_ingredients': 'Pork, Vinegar, Dried chilies, Garlic, Spices',
        'type': 'Non-Vegetarian',
        'famous_place': 'Martins Corner, Betalbatim'
      },
    ],
    'Mysore': [
      {
        'name': 'Mysore Pak',
        'category': 'Dessert',
        'description': 'Rich, melt-in-mouth sweet made with gram flour, ghee, and sugar. Invented in Mysore Palace kitchen.',
        'main_ingredients': 'Gram flour, Ghee, Sugar, Cardamom',
        'type': 'Vegetarian',
        'famous_place': 'Guru Sweets, Sayyaji Rao Road'
      },
      {
        'name': 'Mysore Masala Dosa',
        'category': 'Breakfast',
        'description': 'Crispy dosa with spicy red chutney spread inside and potato masala. Spicier than regular masala dosa.',
        'main_ingredients': 'Rice, Urad dal, Red chutney, Potato',
        'type': 'Vegetarian',
        'famous_place': 'Mylari Hotel, Nazarbad'
      },
      {
        'name': 'Bisi Bele Bath',
        'category': 'Main Course',
        'description': 'Karnataka\'s signature spicy rice dish with lentils, vegetables, and aromatic spices.',
        'main_ingredients': 'Rice, Lentils, Vegetables, Bisi Bele powder',
        'type': 'Vegetarian',
        'famous_place': 'RRR Restaurant, Devaraja Market'
      },
    ],
    'Kochi': [
      {
        'name': 'Appam with Stew',
        'category': 'Breakfast',
        'description': 'Lacy rice pancakes with crispy edges and soft center, served with creamy vegetable or chicken stew.',
        'main_ingredients': 'Rice flour, Coconut milk, Vegetables',
        'type': 'Vegetarian',
        'famous_place': 'Kayees Rahmathulla Cafe, Mattancherry'
      },
      {
        'name': 'Kerala Fish Curry',
        'category': 'Main Course',
        'description': 'Tangy fish curry made with raw mango and coconut in earthen pot. The signature taste of Kerala coast.',
        'main_ingredients': 'Fish, Coconut, Raw mango, Curry leaves',
        'type': 'Non-Vegetarian',
        'famous_place': 'Fort House Restaurant, Fort Kochi'
      },
      {
        'name': 'Puttu and Kadala Curry',
        'category': 'Breakfast',
        'description': 'Steamed rice cylinders layered with coconut, served with spicy black chickpea curry.',
        'main_ingredients': 'Rice flour, Coconut, Black chickpeas',
        'type': 'Vegetarian',
        'famous_place': 'Pai Brothers, MG Road'
      },
    ],
    'Udaipur': [
      {
        'name': 'Dal Baati Churma',
        'category': 'Main Course',
        'description': 'Traditional Rajasthani meal of baked wheat balls, five-lentil dal, and sweet crushed wheat.',
        'main_ingredients': 'Wheat flour, Ghee, Lentils, Jaggery',
        'type': 'Vegetarian',
        'famous_place': 'Natraj Dining Hall, City Station Road'
      },
      {
        'name': 'Laal Maas',
        'category': 'Main Course',
        'description': 'Fiery red mutton curry made with mathania chilies. Royal Rajasthani non-veg delicacy.',
        'main_ingredients': 'Mutton, Mathania chilies, Yogurt, Garlic',
        'type': 'Non-Vegetarian',
        'famous_place': 'Ambrai Restaurant, Amet Haveli'
      },
      {
        'name': 'Mawa Kachori',
        'category': 'Dessert',
        'description': 'Sweet deep-fried pastry filled with khoya and dry fruits, dipped in sugar syrup.',
        'main_ingredients': 'Flour, Khoya, Dry fruits, Sugar syrup',
        'type': 'Vegetarian',
        'famous_place': 'Jodhpur Sweets, Hathi Pol'
      },
    ],
    'Bangalore': [
      {
        'name': 'Masala Dosa',
        'category': 'Breakfast',
        'description': 'Bangalore-style crispy dosa with spiced potato filling. Thinner and crispier than other variants.',
        'main_ingredients': 'Rice, Urad dal, Potato masala, Ghee',
        'type': 'Vegetarian',
        'famous_place': 'Vidyarthi Bhavan, Gandhi Bazaar'
      },
      {
        'name': 'Benne Dosa',
        'category': 'Breakfast',
        'description': 'Small, thick, butter-laden dosas served in sets. Davangere specialty famous in Bangalore.',
        'main_ingredients': 'Rice, Urad dal, Butter',
        'type': 'Vegetarian',
        'famous_place': 'CTR (Central Tiffin Room), Malleshwaram'
      },
      {
        'name': 'Mangalorean Fish Curry',
        'category': 'Main Course',
        'description': 'Coconut-based tangy fish curry with distinct coastal Karnataka flavors.',
        'main_ingredients': 'Fish, Coconut, Tamarind, Spices',
        'type': 'Non-Vegetarian',
        'famous_place': 'Nagarjuna, Various locations'
      },
    ],
    'Rishikesh': [
      {
        'name': 'Aloo Puri',
        'category': 'Breakfast',
        'description': 'Hot puffy fried bread served with spicy potato curry. Simple yet soul-satisfying ashram breakfast.',
        'main_ingredients': 'Wheat flour, Potatoes, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Chotiwala Restaurant, Ram Jhula'
      },
      {
        'name': 'Thali',
        'category': 'Main Course',
        'description': 'Complete vegetarian meal with dal, sabzi, roti, rice, and dessert. Pure sattvic food.',
        'main_ingredients': 'Lentils, Vegetables, Wheat, Rice',
        'type': 'Vegetarian',
        'famous_place': 'Pure Soul Cafe, Laxman Jhula'
      },
      {
        'name': 'Fresh Fruit Smoothie',
        'category': 'Beverage',
        'description': 'Healthy smoothies popular among yoga practitioners. Made with seasonal fruits and honey.',
        'main_ingredients': 'Seasonal fruits, Yogurt, Honey',
        'type': 'Vegetarian',
        'famous_place': 'Little Buddha Cafe, Laxman Jhula'
      },
    ],
    'Haridwar': [
      {
        'name': 'Kachori Sabzi',
        'category': 'Breakfast',
        'description': 'Crispy fried pastries filled with lentils, served with spicy potato curry. Popular pilgrim breakfast.',
        'main_ingredients': 'Flour, Lentils, Potatoes, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Mohan Ji Puri Wale, Har Ki Pauri'
      },
      {
        'name': 'Peda',
        'category': 'Dessert',
        'description': 'Sweet milk fudge offered as prasad at temples. Haridwar\'s famous religious sweet.',
        'main_ingredients': 'Milk, Sugar, Cardamom, Saffron',
        'type': 'Vegetarian',
        'famous_place': 'Mathura Walo ki Dukan, Moti Bazaar'
      },
      {
        'name': 'Lassi',
        'category': 'Beverage',
        'description': 'Thick, creamy yogurt drink perfect for hot pilgrimage days.',
        'main_ingredients': 'Yogurt, Sugar, Rose water',
        'type': 'Vegetarian',
        'famous_place': 'Prakash Lok, Near Har Ki Pauri'
      },
    ],
    'Mathura': [
      {
        'name': 'Mathura Peda',
        'category': 'Dessert',
        'description': 'Famous brown-colored milk sweet with distinct caramelized flavor. Krishna\'s favorite sweet.',
        'main_ingredients': 'Khoya, Sugar, Cardamom',
        'type': 'Vegetarian',
        'famous_place': 'Brijwasi Sweets, Chowk'
      },
      {
        'name': 'Khurchan',
        'category': 'Dessert',
        'description': 'Dried cream flakes with saffron. Rare delicacy found only in Mathura-Vrindavan.',
        'main_ingredients': 'Cream, Sugar, Saffron',
        'type': 'Vegetarian',
        'famous_place': 'Gopi Krishna Sweets, Vishram Ghat'
      },
      {
        'name': 'Dubki Wale Aloo',
        'category': 'Main Course',
        'description': 'Spicy baby potatoes in tangy gravy. A local specialty served with puri.',
        'main_ingredients': 'Baby potatoes, Tomatoes, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Shankar Misthan Bhandar, Chowk'
      },
    ],
    'Ahmedabad': [
      {
        'name': 'Khaman Dhokla',
        'category': 'Snack',
        'description': 'Soft, spongy steamed gram flour cakes tempered with mustard seeds. Gujarat\'s beloved snack.',
        'main_ingredients': 'Gram flour, Curd, Eno, Mustard seeds',
        'type': 'Vegetarian',
        'famous_place': 'Das Khaman, Manek Chowk'
      },
      {
        'name': 'Fafda Jalebi',
        'category': 'Breakfast',
        'description': 'Crispy chickpea flour strips served with sweet jalebi. Traditional Sunday breakfast.',
        'main_ingredients': 'Gram flour, Sugar syrup, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Jagdish Farsan, Law Garden'
      },
      {
        'name': 'Undhiyu',
        'category': 'Main Course',
        'description': 'Winter specialty with mixed vegetables and fenugreek dumplings. Cooked upside down in earthen pot.',
        'main_ingredients': 'Mixed vegetables, Methi muthiya, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Vishalla, Sarkhej Road'
      },
    ],
    'Pushkar': [
      {
        'name': 'Dal Baati Churma',
        'category': 'Main Course',
        'description': 'Authentic Rajasthani meal served in traditional style during Pushkar Fair.',
        'main_ingredients': 'Wheat flour, Ghee, Lentils, Jaggery',
        'type': 'Vegetarian',
        'famous_place': 'Om Shiva Garden Restaurant'
      },
      {
        'name': 'Malpua',
        'category': 'Dessert',
        'description': 'Sweet pancakes soaked in sugar syrup, often offered at temples.',
        'main_ingredients': 'Flour, Milk, Sugar syrup, Cardamom',
        'type': 'Vegetarian',
        'famous_place': 'Shri Ganesh Restaurant, Main Bazaar'
      },
      {
        'name': 'Lassi',
        'category': 'Beverage',
        'description': 'Creamy yogurt drink available in sweet, salty, and rose flavors.',
        'main_ingredients': 'Yogurt, Sugar, Rose water',
        'type': 'Vegetarian',
        'famous_place': 'Halwai ki Gali'
      },
    ],
    'Ayodhya': [
      {
        'name': 'Ram Ladoo',
        'category': 'Snack',
        'description': 'Crispy moong dal fritters served with radish and green chutney. Named after Lord Ram.',
        'main_ingredients': 'Moong dal, Spices, Radish, Chutney',
        'type': 'Vegetarian',
        'famous_place': 'Near Ram Janmabhoomi'
      },
      {
        'name': 'Kheer',
        'category': 'Dessert',
        'description': 'Sweet rice pudding made with milk, offered as temple prasad.',
        'main_ingredients': 'Rice, Milk, Sugar, Cardamom, Nuts',
        'type': 'Vegetarian',
        'famous_place': 'Hanuman Garhi Temple Prasad'
      },
      {
        'name': 'Aloo Puri',
        'category': 'Breakfast',
        'description': 'Crispy puris with spicy potato curry. Popular pilgrim meal.',
        'main_ingredients': 'Wheat flour, Potatoes, Spices',
        'type': 'Vegetarian',
        'famous_place': 'Local eateries near ghats'
      },
    ],
  };

  /// Generate food data - Uses static data first, then API
  static Future<List<Map<String, dynamic>>> generateFoodData(String cityName) async {
    // Check static data first (instant, reliable)
    final staticData = _cityFoodData[cityName];
    if (staticData != null && staticData.isNotEmpty) {
      print('✅ [STATIC] Food data for $cityName loaded');
      return staticData;
    }

    // Try API for cities not in static data
    try {
      print('🔍 [API] Fetching food data for $cityName...');
      final prompt = '''
List 4 REAL famous food items from $cityName, India. Return ONLY valid JSON array.

JSON format:
[
  {
    "name": "Exact dish name",
    "category": "Breakfast/Main Course/Dessert/Snack/Street Food",
    "description": "What it is, how it tastes, why it's famous (2-3 sentences)",
    "main_ingredients": "Main ingredients used",
    "type": "Vegetarian/Non-Vegetarian",
    "famous_place": "Famous shop/restaurant name and area where this is best"
  }
]

Return ONLY the JSON array for $cityName:''';

      final response = await _model.generateContent([Content.text(prompt)]);
      String text = response.text ?? '[]';

      // Clean markdown
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> data = json.decode(text);
      print('✅ [API] Food data for $cityName loaded');
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('⚠️ Food API error: $e');
      return _getDefaultFood(cityName);
    }
  }

  // Static traditional dress data for major states/cities
  static const Map<String, Map<String, dynamic>> _stateDressData = {
    'Uttar Pradesh': {
      'description': 'Uttar Pradesh\'s traditional attire reflects the rich Mughal heritage and Awadhi culture, known for exquisite Chikankari embroidery from Lucknow.',
      'regional_specialty': 'Famous for Chikankari embroidery, Banarasi silk weaves, and Zardozi work',
      'male': {
        'name': 'Sherwani with Churidar',
        'description': 'A long coat-like garment worn over kurta with fitted churidar pants. The sherwani features intricate embroidery and is often adorned with gold or silver buttons. It represents elegance and is synonymous with North Indian groom\'s attire.',
        'fabric': 'Silk, Brocade, Velvet',
        'embroidery': 'Chikankari, Zardozi, Gota Patti',
        'colors': 'Ivory, Gold, Maroon, Royal Blue',
        'occasions': ['Weddings', 'Eid', 'Formal ceremonies'],
        'accessories': ['Mojari shoes', 'Safa/Pagri (turban)', 'Dupatta'],
        'cultural_significance': 'The Sherwani evolved during the Mughal era and became a symbol of nobility. It represents the Indo-Islamic cultural synthesis of the region.',
      },
      'female': {
        'name': 'Anarkali Suit with Chikankari',
        'description': 'A flowing, floor-length dress with fitted bodice that flares out dramatically. The white-on-white Chikankari embroidery is Lucknow\'s signature, featuring delicate hand-embroidered floral patterns that take months to complete.',
        'fabric': 'Cotton, Georgette, Silk',
        'embroidery': 'Chikankari with shadow work, Mukaish',
        'colors': 'White, Pastels, Soft Pink, Sky Blue',
        'draping_style': 'Worn with churidar or palazzo, paired with matching dupatta',
        'occasions': ['Daily wear', 'Festivals', 'Weddings'],
        'jewelry': 'Kundan sets, Pearl necklaces, Jhumkas',
        'cultural_significance': 'Chikankari dates back to Mughal empress Nur Jahan. It\'s a symbol of Lucknowi tehzeeb (refinement) and is now a GI-tagged craft.',
      },
    },
    'Rajasthan': {
      'description': 'Rajasthan\'s vibrant traditional attire is known for its bright colors, mirror work, and intricate tie-dye patterns reflecting the desert state\'s rich royal heritage.',
      'regional_specialty': 'Famous for Bandhani (tie-dye), Gota Patti, and Leheriya patterns',
      'male': {
        'name': 'Angrakha with Dhoti and Safa',
        'description': 'A traditional cross-over kurta tied at the side, worn with dhoti and the iconic Rajasthani turban (Safa). The turban style varies by region and can indicate the wearer\'s community and status.',
        'fabric': 'Cotton, Khadi, Silk',
        'embroidery': 'Mirror work, Gota Patti, Block printing',
        'colors': 'Saffron, Red, Yellow, White',
        'occasions': ['Festivals', 'Weddings', 'Traditional ceremonies'],
        'accessories': ['Safa (turban)', 'Juttis', 'Kamarband (waist belt)'],
        'cultural_significance': 'The Safa colors denote occasions - saffron for valor, pink for welcoming guests. Each region has distinct turban styles.',
      },
      'female': {
        'name': 'Ghagra Choli with Odhni',
        'description': 'A heavily flared skirt (Ghagra) paired with a short blouse (Choli) and a long veil (Odhni). The outfit features stunning mirror work, Gota Patti embroidery, and vibrant Bandhani patterns.',
        'fabric': 'Cotton, Silk, Georgette',
        'embroidery': 'Mirror work, Gota Patti, Bandhani',
        'colors': 'Red, Orange, Yellow, Pink, Royal Blue',
        'draping_style': 'Odhni draped over head, tucked at waist with pallu flowing',
        'occasions': ['Weddings', 'Teej', 'Gangaur', 'Daily wear'],
        'jewelry': 'Borla (maang tikka), Bajuband, Kadaa, Payal',
        'cultural_significance': 'Colors hold meaning - yellow for spring festivals, red for weddings. The Odhni covering the head shows respect.',
      },
    },
    'Maharashtra': {
      'description': 'Maharashtra\'s traditional attire reflects both Maratha warrior heritage and the state\'s diverse regional cultures, from Paithani sarees to Kolhapuri traditions.',
      'regional_specialty': 'Famous for Paithani sarees, Kolhapuri Saaj jewelry, and Nauvari draping',
      'male': {
        'name': 'Dhoti-Kurta with Pheta',
        'description': 'Traditional white or cream dhoti paired with kurta and the distinctive Maratha turban (Pheta). The dhoti is worn in a specific Maharashtrian style that allows easy movement.',
        'fabric': 'Cotton, Silk',
        'embroidery': 'Minimal, focus on fabric quality',
        'colors': 'White, Cream, Saffron for Pheta',
        'occasions': ['Weddings', 'Ganesh Chaturthi', 'Traditional functions'],
        'accessories': ['Pheta (turban)', 'Kolhapuri chappals', 'Uparne (shoulder cloth)'],
        'cultural_significance': 'The Pheta style varies - Puneri Pagdi is compact, while Kolhapuri Pheta is larger. It represents Maratha pride and identity.',
      },
      'female': {
        'name': 'Nauvari Saree (9-yard)',
        'description': 'A distinctive 9-yard saree draped in dhoti style between legs, allowing freedom of movement. Paithani silk with peacock and lotus motifs is the most prized variant.',
        'fabric': 'Paithani silk, Cotton, Chanderi',
        'embroidery': 'Peacock motifs, Lotus patterns in Zari',
        'colors': 'Purple, Green, Red with golden border',
        'draping_style': 'Draped like dhoti, pallu goes over right shoulder',
        'occasions': ['Weddings', 'Lavani dance', 'Ganesh Chaturthi'],
        'jewelry': 'Kolhapuri Saaj, Nath (nose ring), Thushi, Chinchpeti',
        'cultural_significance': 'The Nauvari style has Peshwa-era origins, allowing women to work freely. Paithani weaving is a 2000-year-old craft from Paithan.',
      },
    },
    'Gujarat': {
      'description': 'Gujarat\'s traditional attire is known for vibrant colors, intricate embroidery, and mirror work reflecting the state\'s rich textile heritage.',
      'regional_specialty': 'Famous for Bandhani, Patola silk, and Kutchi embroidery with mirror work',
      'male': {
        'name': 'Kediyu with Chorno',
        'description': 'A short, gathered frock-like top (Kediyu) worn with pleated pants (Chorno). Often paired with a colorful Bandhani turban. This is the traditional Gujarati garb seen during Navratri Garba.',
        'fabric': 'Cotton, Silk',
        'embroidery': 'Mirror work, Kutchi embroidery',
        'colors': 'Red, Yellow, White, Multi-colored',
        'occasions': ['Navratri', 'Weddings', 'Folk festivals'],
        'accessories': ['Pagdi (turban)', 'Mojari'],
        'cultural_significance': 'The Kediyu-Chorno combination is essential for Garba dancing, allowing free movement during the energetic folk dance.',
      },
      'female': {
        'name': 'Chaniya Choli with Dupatta',
        'description': 'A colorful flared skirt (Chaniya) with a fitted blouse (Choli) and matching dupatta. Features extensive mirror work and embroidery, especially famous during Navratri.',
        'fabric': 'Cotton, Silk, Georgette',
        'embroidery': 'Kutchi mirror work, Bandhani, Patola motifs',
        'colors': 'Vibrant multi-colors, Red, Orange, Pink',
        'draping_style': 'Dupatta draped over head or across shoulder',
        'occasions': ['Navratri', 'Weddings', 'Festivals'],
        'jewelry': 'Silver jewelry, Hasli, Bangdi, Kamarbandh',
        'cultural_significance': 'The Chaniya Choli transforms during Navratri into elaborate designer pieces. Kutchi embroidery tells stories of the region\'s nomadic heritage.',
      },
    },
    'Punjab': {
      'description': 'Punjab\'s traditional attire is characterized by vibrant colors, Phulkari embroidery, and comfortable yet elegant designs reflecting the state\'s joyful culture.',
      'regional_specialty': 'Famous for Phulkari embroidery, Patiala salwar, and colorful Paranda',
      'male': {
        'name': 'Kurta Pajama with Turban',
        'description': 'A comfortable cotton or silk kurta paired with loose pajama pants and the traditional Punjabi turban (Pagg). The kurta often features subtle embroidery or buttonwork.',
        'fabric': 'Cotton, Silk, Khadi',
        'embroidery': 'Subtle thread work, Gota',
        'colors': 'White, Cream, Bright colors for festivals',
        'occasions': ['Daily wear', 'Weddings', 'Lohri', 'Baisakhi'],
        'accessories': ['Pagg/Turban', 'Juttis', 'Chadar'],
        'cultural_significance': 'The Pagg (turban) is a symbol of honor and self-respect. Different styles indicate regions - Patiala Shahi, Amritsari, etc.',
      },
      'female': {
        'name': 'Patiala Salwar Kameez with Phulkari Dupatta',
        'description': 'A kameez (tunic) paired with the distinctive heavily pleated Patiala salwar and a gorgeous Phulkari embroidered dupatta. The Phulkari features geometric floral patterns in vibrant silk thread.',
        'fabric': 'Cotton, Silk, Georgette',
        'embroidery': 'Phulkari (flower work) in silk thread',
        'colors': 'Red, Pink, Orange, Parrot Green',
        'draping_style': 'Dupatta across both shoulders or as head covering',
        'occasions': ['Weddings', 'Karva Chauth', 'Lohri', 'Daily wear'],
        'jewelry': 'Gold sets, Tikka, Jhumkas, Kadaa',
        'cultural_significance': 'Phulkari was traditionally made by women for their daughters\' weddings. Each stitch is a mother\'s blessing for her daughter.',
      },
    },
    'West Bengal': {
      'description': 'West Bengal\'s traditional attire is elegant and sophisticated, reflecting Bengali love for art, literature, and refined aesthetics.',
      'regional_specialty': 'Famous for Tant, Baluchari, and Jamdani sarees with distinctive red-white combination',
      'male': {
        'name': 'Dhuti-Punjabi',
        'description': 'A traditional white dhoti paired with a Punjabi (kurta) - the quintessential Bengali formal attire. Often worn with a shawl (chadar) during winters or ceremonies.',
        'fabric': 'Cotton, Silk',
        'embroidery': 'Minimal, focus on fabric drape',
        'colors': 'White with red/gold border, Cream',
        'occasions': ['Durga Puja', 'Weddings', 'Poila Boishakh'],
        'accessories': ['Chadar (shawl)', 'Kolhapuri sandals'],
        'cultural_significance': 'The white dhuti with red border is iconic during Durga Puja, representing Bengali cultural identity and devotion.',
      },
      'female': {
        'name': 'Bengali Saree (Tant/Baluchari)',
        'description': 'Elegant cotton Tant saree with distinctive red-white or the luxurious silk Baluchari with mythological motifs woven into the pallu. The saree is draped in the traditional Bengali style with keys tucked at the waist.',
        'fabric': 'Tant cotton, Baluchari silk, Jamdani',
        'embroidery': 'Woven patterns, not embroidered',
        'colors': 'Red and White (Lal-Sada), Gold, Maroon',
        'draping_style': 'Bengali style with pallu over left shoulder, no pleats at waist',
        'occasions': ['Durga Puja', 'Weddings', 'Poila Boishakh'],
        'jewelry': 'Shakha-Pola (bangles), Sitahar, Mukutmani',
        'cultural_significance': 'The red-white combination is auspicious in Bengali culture. Shakha-Pola bangles are worn by married women as a symbol of marriage.',
      },
    },
    'Tamil Nadu': {
      'description': 'Tamil Nadu\'s traditional attire is known for elegant silk sarees, temple jewelry, and classical Dravidian aesthetics.',
      'regional_specialty': 'Famous for Kanchipuram silk sarees, temple jewelry, and classical dance costumes',
      'male': {
        'name': 'Veshti with Angavastram',
        'description': 'A white cotton or silk dhoti (Veshti) worn with a cotton shirt or bare-chested with an Angavastram (upper cloth). The double-fold draping style is distinctive to Tamil tradition.',
        'fabric': 'Cotton, Silk (Pattu)',
        'embroidery': 'Zari border',
        'colors': 'White with gold/maroon border',
        'occasions': ['Temple visits', 'Weddings', 'Pongal'],
        'accessories': ['Angavastram', 'Kolhapuri sandals'],
        'cultural_significance': 'White veshti with gold border is essential for temple visits and traditional ceremonies, representing purity.',
      },
      'female': {
        'name': 'Kanchipuram Silk Saree',
        'description': 'The queen of Indian silk sarees, featuring heavy pure mulberry silk with contrasting borders and pallu. Known for temple border patterns, checks, and traditional motifs like peacocks and elephants.',
        'fabric': 'Pure mulberry silk with real zari',
        'embroidery': 'Woven zari work, no embroidery',
        'colors': 'Bright colors - Red, Green, Blue with gold zari',
        'draping_style': 'Madisar style for Brahmin women, regular Nivi otherwise',
        'occasions': ['Weddings', 'Temple visits', 'Pongal', 'Bharatanatyam'],
        'jewelry': 'Temple jewelry, Jimikki, Oddiyanam (waist belt), Mango Mala',
        'cultural_significance': 'Kanchipuram sarees take 15-20 days to weave and are passed down as family heirlooms. The weaving tradition dates back 400 years.',
      },
    },
    'Kerala': {
      'description': 'Kerala\'s traditional attire is distinctively minimalist yet elegant, featuring off-white and gold combinations reflecting the state\'s serene backwater beauty.',
      'regional_specialty': 'Famous for Kasavu saree with golden border, Mundu, and temple jewelry',
      'male': {
        'name': 'Mundu with Neriyathu/Jubba',
        'description': 'The traditional off-white mundu (dhoti) with golden kasavu border, worn with an upper cloth (Neriyathu) or a short kurta (Jubba). Essential attire for Onam celebrations.',
        'fabric': 'Cotton, Kasavu (gold-bordered cotton)',
        'embroidery': 'Gold Kasavu border, no embroidery',
        'colors': 'Off-white (Settu) with golden border',
        'occasions': ['Onam', 'Vishu', 'Weddings', 'Temple visits'],
        'accessories': ['Neriyathu (upper cloth)', 'Kolhapuri sandals'],
        'cultural_significance': 'The double mundu (Mundum-Neriyathum) is the most traditional form, representing Kerala\'s elegant simplicity.',
      },
      'female': {
        'name': 'Kasavu Saree (Settu Mundu)',
        'description': 'The iconic cream/off-white saree with broad golden kasavu border. The two-piece version (Settu Mundu) with separate mundu and neriyathu represents the most traditional form.',
        'fabric': 'Cotton with real gold/imitation kasavu',
        'embroidery': 'Pure woven gold/silver kasavu, no embroidery',
        'colors': 'Off-white with golden/cream border',
        'draping_style': 'Nivi style or traditional Settu Mundu (two-piece)',
        'occasions': ['Onam', 'Vishu', 'Weddings', 'Temple visits', 'Kathakali'],
        'jewelry': 'Nagapadam, Palakka Mala, Jasmine flowers in hair',
        'cultural_significance': 'The simplicity of Kasavu reflects Kerala\'s cultural emphasis on understated elegance. It\'s mandatory for Onam festivities.',
      },
    },
    'Karnataka': {
      'description': 'Karnataka\'s traditional attire blends South Indian elegance with unique regional elements like Ilkal sarees and Mysore silk.',
      'regional_specialty': 'Famous for Mysore silk sarees, Ilkal sarees, and Coorg traditional dress',
      'male': {
        'name': 'Panche (Dhoti) with Angavastram',
        'description': 'Traditional silk or cotton dhoti worn with an upper cloth or kurta. The Mysore Peta (turban) is worn during ceremonial occasions, especially famous during Dasara.',
        'fabric': 'Mysore silk, Cotton',
        'embroidery': 'Zari border',
        'colors': 'White, Cream with colored borders',
        'occasions': ['Dasara', 'Weddings', 'Temple visits'],
        'accessories': ['Mysore Peta (turban)', 'Angavastram'],
        'cultural_significance': 'The Mysore Peta is a symbol of honor and is officially presented to dignitaries during Mysore Dasara.',
      },
      'female': {
        'name': 'Mysore Silk / Ilkal Saree',
        'description': 'Mysore silk sarees are known for their pure silk, zari work, and traditional motifs. Ilkal sarees from North Karnataka feature unique Kasuti embroidery and distinctive pallus.',
        'fabric': 'Pure Mysore silk, Ilkal cotton-silk',
        'embroidery': 'Kasuti embroidery (for Ilkal), Zari weaving',
        'colors': 'Mysore: Deep colors with gold; Ilkal: Red, Green with Chikki border',
        'draping_style': 'Standard Nivi style with pleats',
        'occasions': ['Weddings', 'Dasara', 'Ugadi', 'Temple visits'],
        'jewelry': 'Temple jewelry, Addige, Jadebilya',
        'cultural_significance': 'Mysore silk has GI tag and is woven in government-run facilities. Ilkal weaving is a 8th-century craft.',
      },
    },
    'Madhya Pradesh': {
      'description': 'Madhya Pradesh\'s traditional attire showcases the state\'s rich Bundelkhand and Malwa heritage with distinctive weaving traditions.',
      'regional_specialty': 'Famous for Chanderi and Maheshwari sarees, tribal textiles',
      'male': {
        'name': 'Dhoti-Kurta with Gamcha',
        'description': 'Traditional cotton or silk dhoti paired with kurta and a gamcha (cotton scarf) on the shoulder. Simple yet dignified attire worn across the state.',
        'fabric': 'Cotton, Chanderi silk',
        'embroidery': 'Minimal, woven patterns',
        'colors': 'White, Cream',
        'occasions': ['Festivals', 'Weddings', 'Daily wear'],
        'accessories': ['Gamcha', 'Mojari'],
        'cultural_significance': 'The gamcha is a multipurpose cloth used as towel, head cover, and shoulder cloth - representing practicality.',
      },
      'female': {
        'name': 'Chanderi / Maheshwari Saree',
        'description': 'Lightweight, sheer Chanderi sarees with gold/silver zari work, or the distinctive Maheshwari sarees with reversible borders. Both are known for their translucent texture and elegant drape.',
        'fabric': 'Chanderi silk-cotton, Maheshwari cotton-silk',
        'embroidery': 'Woven zari, Coin-shaped buttis',
        'colors': 'Soft pastels, Pink, Peach, Mint with gold',
        'draping_style': 'Standard Nivi drape',
        'occasions': ['Weddings', 'Festivals', 'Formal events'],
        'jewelry': 'Gold jewelry, Tribal silver ornaments',
        'cultural_significance': 'Chanderi weaving dates back to Vedic times and has GI protection. The fabric was favored by Mughal royalty.',
      },
    },
    'Goa': {
      'description': 'Goa\'s traditional attire reflects its unique Portuguese-Indian fusion, with distinct Catholic and Hindu influences.',
      'regional_specialty': 'Famous for Kunbi saree, Pano Bhaju, and Portuguese-influenced clothing',
      'male': {
        'name': 'Cashio (Shirt) with Trousers',
        'description': 'A simple cotton shirt with trousers, influenced by Portuguese colonial style. Traditional Konkani men wore a dhoti called Kashtam.',
        'fabric': 'Cotton, Linen',
        'embroidery': 'Minimal, simple patterns',
        'colors': 'White, Cream, Light colors',
        'occasions': ['Daily wear', 'Church visits', 'Festivals'],
        'accessories': ['Cap or Hat', 'Cross pendant'],
        'cultural_significance': 'Goan men\'s wear reflects the Portuguese influence, while Hindu communities maintain traditional dhoti styles.',
      },
      'female': {
        'name': 'Kunbi Saree / Pano Bhaju',
        'description': 'The Kunbi saree is a distinctive red-checkered saree worn by the Kunbi tribe. Pano Bhaju is a blouse-skirt combination worn by Hindu Goan women.',
        'fabric': 'Cotton, Silk',
        'embroidery': 'Traditional checkered patterns',
        'colors': 'Red and White checks (Kunbi), Bright colors',
        'draping_style': 'Kunbi style or standard Nivi drape',
        'occasions': ['Festivals', 'Weddings', 'Shigmo', 'Church celebrations'],
        'jewelry': 'Gold Caste jewelry, Cross pendants for Catholics',
        'cultural_significance': 'The Kunbi saree is a GI-protected tribal heritage. Catholic women wear Western-style dresses for church.',
      },
    },
    'Uttarakhand': {
      'description': 'Uttarakhand\'s traditional attire reflects its Himalayan heritage with distinct Garhwali and Kumaoni variations.',
      'regional_specialty': 'Famous for Rangwali Pichhora, Pichoda, and traditional hill jewelry',
      'male': {
        'name': 'Churidar Kurta with Sadri/Mirzai',
        'description': 'A kurta pajama paired with a sleeveless jacket called Sadri or Mirzai. The cap (topi) is essential for traditional occasions.',
        'fabric': 'Wool, Cotton, Silk for occasions',
        'embroidery': 'Subtle embroidery, focus on warmth',
        'colors': 'White, Cream, Earth tones',
        'occasions': ['Weddings', 'Religious ceremonies', 'Festivals'],
        'accessories': ['Pahadi Topi (cap)', 'Shawl', 'Angochha (shoulder cloth)'],
        'cultural_significance': 'The Pahadi topi is a symbol of hill identity. Different regions have distinct cap styles.',
      },
      'female': {
        'name': 'Ghagra with Angra and Pichhora',
        'description': 'A traditional ghagra (skirt) with angra (blouse) and the iconic Rangwali Pichhora - a bright saffron-yellow dupatta worn by married women.',
        'fabric': 'Silk, Cotton, Wool for winters',
        'embroidery': 'Aipan motifs, Mirror work in Kumaon region',
        'colors': 'Saffron-Yellow (Pichhora), Red, Pink, Bright colors',
        'draping_style': 'Pichhora draped over head to cover forehead',
        'occasions': ['Weddings', 'Religious ceremonies', 'Chhath Puja'],
        'jewelry': 'Nath (nose ring), Galobandh, Payal, Hansuli',
        'cultural_significance': 'The Rangwali Pichhora is worn only by married women and is essential for bride\'s trousseau. It symbolizes marital bliss.',
      },
    },
    'Telangana': {
      'description': 'Telangana\'s traditional attire blends Deccan heritage with distinctive handloom traditions like Pochampally Ikat.',
      'regional_specialty': 'Famous for Pochampally Ikat, Gadwal sarees, and Nizami influence in men\'s wear',
      'male': {
        'name': 'Pancha (Dhoti) with Kurta and Angavastram',
        'description': 'Traditional dhoti-kurta with a distinction - the Hyderabadi Sherwani with Khara Dupatta for formal occasions reflects Nizam-era elegance.',
        'fabric': 'Cotton, Silk, Brocade for Sherwani',
        'embroidery': 'Zardozi for Sherwani, minimal for daily wear',
        'colors': 'White for daily, Cream and pastels for Sherwani',
        'occasions': ['Weddings', 'Bathukamma', 'Bonalu festival'],
        'accessories': ['Rumal (kerchief)', 'Mojari', 'Khara Dupatta'],
        'cultural_significance': 'The Sherwani style here is influenced by Nizam courts. Hyderabadi men\'s formal wear is known for understated elegance.',
      },
      'female': {
        'name': 'Pochampally Ikat / Gadwal Saree',
        'description': 'Pochampally Ikat sarees feature unique geometric patterns created through resist-dyeing before weaving. Gadwal sarees are known for their rich zari borders.',
        'fabric': 'Silk, Cotton-Silk blend',
        'embroidery': 'Tie-dye Ikat patterns, Zari weaving',
        'colors': 'Vibrant contrasts - Red, Blue, Yellow with intricate patterns',
        'draping_style': 'Standard Nivi style with a unique pallu display',
        'occasions': ['Bathukamma', 'Weddings', 'Bonalu', 'Daily wear (cotton)'],
        'jewelry': 'Chandbali, Choker sets, Vanki (armlet)',
        'cultural_significance': 'Pochampally Ikat is a UNESCO-recognized heritage craft. The double-ikat technique requires exceptional skill.',
      },
    },
    'Delhi': {
      'description': 'Delhi\'s traditional attire reflects its cosmopolitan nature, blending North Indian styles with Mughal elegance.',
      'regional_specialty': 'Famous for Mughlai-style clothing, intricate embroidery, and designer fusion wear',
      'male': {
        'name': 'Sherwani / Kurta Pajama',
        'description': 'The elegant Sherwani for formal occasions or comfortable Kurta Pajama for daily wear. Delhi\'s men\'s fashion blends traditional with contemporary.',
        'fabric': 'Silk, Brocade, Cotton, Linen',
        'embroidery': 'Zardozi, Chikankari, Thread work',
        'colors': 'Ivory, Pastels, Royal Blue, Maroon',
        'occasions': ['Weddings', 'Diwali', 'Eid', 'Formal events'],
        'accessories': ['Safa/Pagri', 'Mojari', 'Brooch', 'Dupatta'],
        'cultural_significance': 'Delhi\'s clothing style reflects its status as a historical capital, blending Mughal grandeur with Punjabi influence.',
      },
      'female': {
        'name': 'Salwar Kameez / Lehenga / Saree',
        'description': 'Delhi women wear diverse attire - elegant sarees, stylish salwar suits, or glamorous lehengas. The city is known for setting fashion trends.',
        'fabric': 'Silk, Georgette, Chiffon, Cotton',
        'embroidery': 'Zardozi, Gota Patti, Sequins, Contemporary designs',
        'colors': 'All colors - from pastels to vibrant shades',
        'draping_style': 'Modern draping styles, designer adaptations',
        'occasions': ['Weddings', 'Karva Chauth', 'Diwali', 'All occasions'],
        'jewelry': 'Kundan, Polki, Diamond sets, Statement pieces',
        'cultural_significance': 'Delhi is India\'s fashion capital, where traditional wear gets contemporary makeovers while respecting heritage.',
      },
    },
  };

  /// Generate dress data - Uses static data first, then API
  static Future<Map<String, dynamic>> generateDressData(String cityName, String state) async {
    // Check static data first by state
    final staticData = _stateDressData[state];
    if (staticData != null) {
      print('✅ [STATIC] Dress data for $state loaded');
      return staticData;
    }

    // Try to match by city to state mapping
    final cityStateMap = {
      // Uttar Pradesh
      'Agra': 'Uttar Pradesh', 'Lucknow': 'Uttar Pradesh', 'Varanasi': 'Uttar Pradesh',
      'Mathura': 'Uttar Pradesh', 'Ayodhya': 'Uttar Pradesh',
      // Rajasthan
      'Jaipur': 'Rajasthan', 'Jodhpur': 'Rajasthan', 'Udaipur': 'Rajasthan', 'Pushkar': 'Rajasthan',
      // Maharashtra
      'Mumbai': 'Maharashtra', 'Pune': 'Maharashtra', 'Nagpur': 'Maharashtra',
      // Gujarat
      'Ahmedabad': 'Gujarat', 'Surat': 'Gujarat', 'Vadodara': 'Gujarat',
      // Delhi
      'Delhi': 'Delhi',
      // Punjab
      'Amritsar': 'Punjab', 'Chandigarh': 'Punjab', 'Ludhiana': 'Punjab',
      // West Bengal
      'Kolkata': 'West Bengal', 'Darjeeling': 'West Bengal',
      // Tamil Nadu
      'Chennai': 'Tamil Nadu', 'Madurai': 'Tamil Nadu', 'Coimbatore': 'Tamil Nadu',
      // Kerala
      'Kochi': 'Kerala', 'Thiruvananthapuram': 'Kerala',
      // Karnataka
      'Bangalore': 'Karnataka', 'Mysore': 'Karnataka', 'Mangalore': 'Karnataka',
      // Madhya Pradesh
      'Bhopal': 'Madhya Pradesh', 'Indore': 'Madhya Pradesh',
      // Telangana
      'Hyderabad': 'Telangana',
      // Goa
      'Goa': 'Goa',
      // Uttarakhand
      'Rishikesh': 'Uttarakhand', 'Haridwar': 'Uttarakhand', 'Dehradun': 'Uttarakhand',
    };

    final mappedState = cityStateMap[cityName];
    if (mappedState != null && _stateDressData.containsKey(mappedState)) {
      print('✅ [STATIC] Dress data for $cityName (mapped to $mappedState) loaded');
      return _stateDressData[mappedState]!;
    }

    // Try API for cities/states not in static data
    try {
      print('🔍 [API] Fetching dress data for $cityName, $state...');
      final prompt = '''
What are the traditional dresses for men and women in $state, India? Return ONLY valid JSON.

JSON format:
{
  "description": "Overview of the state's traditional attire (2 sentences)",
  "regional_specialty": "Famous textile/embroidery from this region",
  "male": {
    "name": "Traditional dress name",
    "description": "Detailed description of the attire (3-4 sentences)",
    "fabric": "Common fabrics used",
    "embroidery": "Type of embroidery if any",
    "colors": "Traditional colors",
    "occasions": ["List of occasions when worn"],
    "accessories": ["Accessories worn with it"],
    "cultural_significance": "Cultural meaning (2 sentences)"
  },
  "female": {
    "name": "Traditional dress name",
    "description": "Detailed description of the attire (3-4 sentences)",
    "fabric": "Common fabrics used",
    "embroidery": "Type of embroidery if any",
    "colors": "Traditional colors",
    "draping_style": "How it is worn/draped",
    "occasions": ["List of occasions when worn"],
    "jewelry": "Traditional jewelry worn with it",
    "cultural_significance": "Cultural meaning (2 sentences)"
  }
}

Return ONLY JSON for $state:''';

      final response = await _model.generateContent([Content.text(prompt)]);
      String text = response.text ?? '{}';
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      print('✅ [API] Dress data for $state loaded');
      return json.decode(text);
    } catch (e) {
      print('⚠️ Dress API error: $e');
      return _getDefaultDress();
    }
  }

  /// Generate culture data - DETAILED
  static Future<Map<String, dynamic>> generateCultureData(String cityName) async {
    try {
      final prompt = '''
Describe the culture of $cityName, India. Return ONLY valid JSON.

For AGRA: Include Taj Mahal's influence on love culture, Mughal heritage, Braj culture
For DELHI: Diverse cultures, Mughlai influence, modern cosmopolitan

JSON format:
{
  "overview": "Main cultural characteristics of $cityName (3-4 sentences)",
  "festivals": [
    {
      "name": "Festival name",
      "description": "When and how celebrated (2 sentences)",
      "month": "Month"
    }
  ],
  "specialties": ["Unique cultural aspect 1", "Unique cultural aspect 2"]
}

Return ONLY JSON for $cityName with 3-4 festivals:''';

      final response = await _model.generateContent([Content.text(prompt)]);
      String text = response.text ?? '{}';
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      return json.decode(text);
    } catch (e) {
      print('Culture error: $e');
      return _getDefaultCulture();
    }
  }

  /// Generate tourist places - WITH TIMINGS & FEES
  static Future<List<Map<String, dynamic>>> generateTouristPlaces(String cityName) async {
    try {
      final prompt = '''
List 5 REAL famous tourist places in $cityName, India. Return ONLY valid JSON array.

For AGRA must include: Taj Mahal, Agra Fort, Fatehpur Sikri, Mehtab Bagh
For DELHI: Red Fort, Qutub Minar, India Gate, Humayun's Tomb

JSON format:
[
  {
    "name": "Exact place name",
    "description": "What it is, why visit (2-3 sentences)",
    "timings": "Opening hours (e.g., 6:00 AM - 6:00 PM)",
    "entry_fee": "Fee (e.g., Indians: ₹50, Foreigners: ₹1100)",
    "closed_on": "Day closed (e.g., Friday or Open all days)",
    "rules": ["Photography not allowed inside", "Remove shoes", etc]
  }
]

Return ONLY JSON array for $cityName:''';

      final response = await _model.generateContent([Content.text(prompt)]);
      String text = response.text ?? '[]';
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> data = json.decode(text);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Tourist places error: $e');
      return _getDefaultPlaces(cityName);
    }
  }

  /// Generate history - CHRONOLOGICAL
  static Future<Map<String, dynamic>> generateHistoryData(String cityName) async {
    try {
      final prompt = '''
Write a brief history of $cityName, India. Return ONLY valid JSON.

For AGRA: Ancient times, Lodi Dynasty (1504), Mughal Era (Akbar 1556, Shah Jahan built Taj 1632-1653), British period
For DELHI: Indraprastha, Delhi Sultanate, Mughal capital, British capital, Independent India's capital

JSON format:
{
  "overview": "Overall historical significance (3-4 sentences)",
  "timeline": [
    {
      "period": "Time period (e.g., Mughal Era 1526-1857)",
      "description": "Major events, rulers, developments (3 sentences)",
      "monuments": ["Monument built in this period"]
    }
  ]
}

Return ONLY JSON for $cityName with 4-5 periods:''';

      final response = await _model.generateContent([Content.text(prompt)]);
      String text = response.text ?? '{}';
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();

      return json.decode(text);
    } catch (e) {
      print('History error: $e');
      return _getDefaultHistory();
    }
  }

  // Default fallbacks
  static List<Map<String, dynamic>> _getDefaultFood(String cityName) {
    return [
      {
        "name": "Traditional Dish",
        "category": "Main Course",
        "description": "A famous local specialty of $cityName",
        "main_ingredients": "Local ingredients",
        "type": "Vegetarian"
      }
    ];
  }

  static Map<String, dynamic> _getDefaultDress() {
    return {
      "male": {
        "name": "Traditional Attire",
        "description": "Traditional clothing worn on special occasions",
        "fabric": "Cotton, Silk"
      },
      "female": {
        "name": "Traditional Attire",
        "description": "Traditional dress with regional embroidery",
        "fabric": "Silk, Cotton"
      }
    };
  }

  static Map<String, dynamic> _getDefaultCulture() {
    return {
      "overview": "Rich cultural heritage",
      "festivals": [],
      "specialties": []
    };
  }

  static List<Map<String, dynamic>> _getDefaultPlaces(String cityName) {
    return [
      {
        "name": "Historic Site",
        "description": "Famous landmark in $cityName",
        "timings": "9:00 AM - 5:00 PM",
        "entry_fee": "Varies",
        "closed_on": "Check locally",
        "rules": ["Follow visitor guidelines"]
      }
    ];
  }

  static Map<String, dynamic> _getDefaultHistory() {
    return {
      "overview": "Ancient city with rich history",
      "timeline": []
    };
  }
}
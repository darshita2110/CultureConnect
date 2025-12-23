import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/city_model.dart';
import '../models/city_detail_model.dart';

class FirestoreCityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load all cities from Firestore
  static Future<List<City>> loadCities() async {
    try {
      print('🔍 Loading cities from Firestore...');

      final QuerySnapshot snapshot = await _firestore
          .collection('cities')
          .orderBy('name')
          .get();

      final List<City> cities = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return City.fromJson({...data, 'id': doc.id});
      }).toList();

      print('✅ Loaded ${cities.length} cities from Firestore');
      return cities;
    } catch (e) {
      print('❌ Error loading cities from Firestore: $e');
      return [];
    }
  }

  // Get city by ID with all details
  static Future<CityDetail?> getCityDetail(String cityId) async {
    try {
      print('🔍 Loading details for city: $cityId');

      final DocumentSnapshot doc = await _firestore
          .collection('cities')
          .doc(cityId)
          .get();

      if (!doc.exists) {
        print('⚠️ City not found: $cityId');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      final cityDetail = CityDetail.fromJson({...data, 'id': doc.id});

      print('✅ Loaded details for ${cityDetail.name}');
      return cityDetail;
    } catch (e) {
      print('❌ Error loading city details: $e');
      return null;
    }
  }

  // Stream cities for real-time updates
  static Stream<List<City>> streamCities() {
    return _firestore
        .collection('cities')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return City.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Search cities by name
  static Future<List<City>> searchCities(String query) async {
    try {
      if (query.isEmpty) return await loadCities();

      final QuerySnapshot snapshot = await _firestore
          .collection('cities')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return City.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('❌ Error searching cities: $e');
      return [];
    }
  }
}
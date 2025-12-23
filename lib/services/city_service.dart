import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/city_model.dart';


class CityService {
  static Future<List<City>> loadCities() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/cities.json');

      // Parse the JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Extract the cities array and convert to City objects
      final List<dynamic> citiesJson = jsonData['cities'];
      final List<City> cities = citiesJson.map((json) => City.fromJson(json)).toList();

      return cities;
    } catch (e) {
      print('Error loading cities: $e');
      return [];
    }
  }

  // Get city by ID
  static Future<City?> getCityById(String cityId) async {
    final cities = await loadCities();
    try {
      return cities.firstWhere((city) => city.id == cityId);
    } catch (e) {
      return null;
    }
  }

  // Search cities by name
  static Future<List<City>> searchCities(String query) async {
    final cities = await loadCities();
    if (query.isEmpty) return cities;

    return cities.where((city) =>
    city.name.toLowerCase().contains(query.toLowerCase()) ||
        city.state.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
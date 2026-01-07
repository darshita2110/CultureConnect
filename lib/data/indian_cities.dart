// Simple list of Indian cities - no complex data needed!
class IndianCities {
  static final List<Map<String, dynamic>> cities = [
    {
      "id": "delhi",
      "name": "Delhi",
      "state": "Delhi",
      "latitude": 28.6139,
      "longitude": 77.2090,
      "wikiPageId": "Delhi", // For Wikipedia API
    },
    {
      "id": "mumbai",
      "name": "Mumbai",
      "state": "Maharashtra",
      "latitude": 19.0760,
      "longitude": 72.8777,
      "wikiPageId": "Mumbai",
    },
    {
      "id": "jaipur",
      "name": "Jaipur",
      "state": "Rajasthan",
      "latitude": 26.9124,
      "longitude": 75.7873,
      "wikiPageId": "Jaipur",
    },
    {
      "id": "varanasi",
      "name": "Varanasi",
      "state": "Uttar Pradesh",
      "latitude": 25.3176,
      "longitude": 82.9739,
      "wikiPageId": "Varanasi",
    },
    {
      "id": "agra",
      "name": "Agra",
      "state": "Uttar Pradesh",
      "latitude": 27.1767,
      "longitude": 78.0081,
      "wikiPageId": "Agra",
    },
    {
      "id": "kolkata",
      "name": "Kolkata",
      "state": "West Bengal",
      "latitude": 22.5726,
      "longitude": 88.3639,
      "wikiPageId": "Kolkata",
    },
    {
      "id": "bangalore",
      "name": "Bangalore",
      "state": "Karnataka",
      "latitude": 12.9716,
      "longitude": 77.5946,
      "wikiPageId": "Bangalore",
    },
    {
      "id": "chennai",
      "name": "Chennai",
      "state": "Tamil Nadu",
      "latitude": 13.0827,
      "longitude": 80.2707,
      "wikiPageId": "Chennai",
    },
    {
      "id": "hyderabad",
      "name": "Hyderabad",
      "state": "Telangana",
      "latitude": 17.3850,
      "longitude": 78.4867,
      "wikiPageId": "Hyderabad,_India",
    },
    {
      "id": "ahmedabad",
      "name": "Ahmedabad",
      "state": "Gujarat",
      "latitude": 23.0225,
      "longitude": 72.5714,
      "wikiPageId": "Ahmedabad",
    },
    {
      "id": "pune",
      "name": "Pune",
      "state": "Maharashtra",
      "latitude": 18.5204,
      "longitude": 73.8567,
      "wikiPageId": "Pune",
    },
    {
      "id": "surat",
      "name": "Surat",
      "state": "Gujarat",
      "latitude": 21.1702,
      "longitude": 72.8311,
      "wikiPageId": "Surat",
    },
    {
      "id": "lucknow",
      "name": "Lucknow",
      "state": "Uttar Pradesh",
      "latitude": 26.8467,
      "longitude": 80.9462,
      "wikiPageId": "Lucknow",
    },
    {
      "id": "kanpur",
      "name": "Kanpur",
      "state": "Uttar Pradesh",
      "latitude": 26.4499,
      "longitude": 80.3319,
      "wikiPageId": "Kanpur",
    },
    {
      "id": "nagpur",
      "name": "Nagpur",
      "state": "Maharashtra",
      "latitude": 21.1458,
      "longitude": 79.0882,
      "wikiPageId": "Nagpur",
    },
    {
      "id": "indore",
      "name": "Indore",
      "state": "Madhya Pradesh",
      "latitude": 22.7196,
      "longitude": 75.8577,
      "wikiPageId": "Indore",
    },
    {
      "id": "bhopal",
      "name": "Bhopal",
      "state": "Madhya Pradesh",
      "latitude": 23.2599,
      "longitude": 77.4126,
      "wikiPageId": "Bhopal",
    },
    {
      "id": "visakhapatnam",
      "name": "Visakhapatnam",
      "state": "Andhra Pradesh",
      "latitude": 17.6868,
      "longitude": 83.2185,
      "wikiPageId": "Visakhapatnam",
    },
    {
      "id": "patna",
      "name": "Patna",
      "state": "Bihar",
      "latitude": 25.5941,
      "longitude": 85.1376,
      "wikiPageId": "Patna",
    },
    {
      "id": "ludhiana",
      "name": "Ludhiana",
      "state": "Punjab",
      "latitude": 30.9010,
      "longitude": 75.8573,
      "wikiPageId": "Ludhiana",
    },
    {
      "id": "amritsar",
      "name": "Amritsar",
      "state": "Punjab",
      "latitude": 31.6340,
      "longitude": 74.8723,
      "wikiPageId": "Amritsar",
    },
    {
      "id": "udaipur",
      "name": "Udaipur",
      "state": "Rajasthan",
      "latitude": 24.5854,
      "longitude": 73.7125,
      "wikiPageId": "Udaipur",
    },
    {
      "id": "mysore",
      "name": "Mysore",
      "state": "Karnataka",
      "latitude": 12.2958,
      "longitude": 76.6394,
      "wikiPageId": "Mysore",
    },
    {
      "id": "kochi",
      "name": "Kochi",
      "state": "Kerala",
      "latitude": 9.9312,
      "longitude": 76.2673,
      "wikiPageId": "Kochi",
    },
    {
      "id": "goa",
      "name": "Goa",
      "state": "Goa",
      "latitude": 15.2993,
      "longitude": 74.1240,
      "wikiPageId": "Goa",
    },
  ];

  // Get all cities
  static List<Map<String, dynamic>> getAllCities() {
    return cities;
  }

  // Get city by ID
  static Map<String, dynamic>? getCityById(String id) {
    try {
      return cities.firstWhere((city) => city['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Search cities
  static List<Map<String, dynamic>> searchCities(String query) {
    if (query.isEmpty) return cities;

    return cities.where((city) {
      final name = city['name'].toString().toLowerCase();
      final state = city['state'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || state.contains(searchQuery);
    }).toList();
  }
}
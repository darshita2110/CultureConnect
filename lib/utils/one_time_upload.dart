import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Run this ONCE to upload data to Firestore
class FirestoreDataUploader extends StatefulWidget {
  const FirestoreDataUploader({super.key});

  @override
  State<FirestoreDataUploader> createState() => _FirestoreDataUploaderState();
}

class _FirestoreDataUploaderState extends State<FirestoreDataUploader> {
  bool isUploading = false;
  String status = 'Ready to upload';
  int uploadedCount = 0;

  Future<void> uploadCitiesData() async {
    setState(() {
      isUploading = true;
      status = 'Starting upload...';
      uploadedCount = 0;
    });

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Sample data for 3 cities (you can expand this)
    final List<Map<String, dynamic>> cities = [
      {
        "name": "Delhi",
        "state": "Delhi",
        "latitude": 28.6139,
        "longitude": 77.2090,
        "image": "assets/images/cities/delhi.jpg",
        "description": "The capital city of India, Delhi is a vibrant metropolis blending ancient heritage with modern progress.",
        "famous_for": ["Red Fort", "Qutub Minar", "India Gate", "Lotus Temple"],
        "best_time": "October to March",
        "food": {
          "description": "Delhi is famous for its street food and Mughlai cuisine.",
          "dishes": [
            {"name": "Chole Bhature", "description": "Spicy chickpea curry with fried bread", "type": "Vegetarian"},
            {"name": "Butter Chicken", "description": "Creamy tomato-based chicken curry", "type": "Non-Vegetarian"},
            {"name": "Paranthe", "description": "Stuffed flatbreads with various fillings", "type": "Vegetarian"},
          ]
        },
        "traditional_dress": {
          "description": "Delhi showcases diverse traditional attire.",
          "male": {"name": "Kurta Pajama", "description": "Cotton or silk kurta with churidar", "occasions": ["Festivals", "Weddings"]},
          "female": {"name": "Salwar Kameez", "description": "Elegant salwar kameez and sarees", "occasions": ["Daily wear", "Festivals"]}
        },
        "culture": {
          "description": "Delhi represents a beautiful amalgamation of various cultures.",
          "festivals": [
            {"name": "Diwali", "description": "Festival of lights", "month": "October/November"},
            {"name": "Holi", "description": "Festival of colors", "month": "March"},
          ],
          "languages": ["Hindi", "Punjabi", "Urdu", "English"],
          "art_forms": ["Kathak Dance", "Hindustani Music"]
        },
        "tourist_places": [
          {"name": "Red Fort", "description": "Historic Mughal fort", "timings": "9:30 AM - 4:30 PM", "entry_fee": "INR 35"},
          {"name": "Qutub Minar", "description": "Tallest brick minaret", "timings": "7:00 AM - 5:00 PM", "entry_fee": "INR 30"},
          {"name": "India Gate", "description": "War memorial", "timings": "Open 24 hours", "entry_fee": "Free"},
        ],
        "history": {
          "overview": "Delhi has been continuously inhabited since the 6th century BCE.",
          "timeline": [
            {"period": "Ancient Era", "description": "Known as Indraprastha during Mahabharata"},
            {"period": "Mughal Empire", "description": "Shah Jahan built the Red Fort"},
            {"period": "Modern Era", "description": "Capital of independent India since 1947"},
          ]
        }
      },
      {
        "name": "Jaipur",
        "state": "Rajasthan",
        "latitude": 26.9124,
        "longitude": 75.7873,
        "image": "assets/images/cities/jaipur.jpg",
        "description": "The Pink City of India, famous for royal palaces.",
        "famous_for": ["Amber Fort", "Hawa Mahal", "City Palace"],
        "best_time": "November to February",
        "food": {
          "description": "Authentic Rajasthani cuisine with rich flavors.",
          "dishes": [
            {"name": "Dal Baati Churma", "description": "Traditional Rajasthani dish", "type": "Vegetarian"},
            {"name": "Laal Maas", "description": "Spicy red meat curry", "type": "Non-Vegetarian"},
            {"name": "Ghewar", "description": "Sweet disc-shaped dessert", "type": "Vegetarian"},
          ]
        },
        "traditional_dress": {
          "description": "Vibrant Rajasthani traditional attire with mirror work.",
          "male": {"name": "Dhoti-Kurta with Pagdi", "description": "Traditional with colorful turban", "occasions": ["Festivals", "Weddings"]},
          "female": {"name": "Ghagra Choli", "description": "Colorful long skirt with blouse", "occasions": ["Weddings", "Festivals"]}
        },
        "culture": {
          "description": "Royal heritage with vibrant folk arts.",
          "festivals": [
            {"name": "Teej", "description": "Monsoon festival", "month": "July/August"},
            {"name": "Gangaur", "description": "Festival honoring Goddess Gauri", "month": "March/April"},
          ],
          "languages": ["Hindi", "Rajasthani", "English"],
          "art_forms": ["Ghoomar Dance", "Block Printing", "Puppet Shows"]
        },
        "tourist_places": [
          {"name": "Amber Fort", "description": "Hilltop fort with mirror palace", "timings": "8:00 AM - 5:30 PM", "entry_fee": "INR 25"},
          {"name": "Hawa Mahal", "description": "Palace with 953 windows", "timings": "9:00 AM - 5:00 PM", "entry_fee": "INR 50"},
          {"name": "City Palace", "description": "Royal residence", "timings": "9:30 AM - 5:00 PM", "entry_fee": "INR 200"},
        ],
        "history": {
          "overview": "Founded in 1727 by Maharaja Sawai Jai Singh II.",
          "timeline": [
            {"period": "Foundation (1727)", "description": "Planned city per Vastu Shastra"},
            {"period": "The Pink City (1876)", "description": "Painted pink for Prince of Wales"},
            {"period": "UNESCO (2019)", "description": "Designated World Heritage Site"},
          ]
        }
      },
      {
        "name": "Varanasi",
        "state": "Uttar Pradesh",
        "latitude": 25.3176,
        "longitude": 82.9739,
        "image": "assets/images/cities/varanasi.jpg",
        "description": "Spiritual capital of India, one of oldest living cities.",
        "famous_for": ["Ganges Ghats", "Kashi Vishwanath Temple", "Sarnath"],
        "best_time": "October to March",
        "food": {
          "description": "Famous for street food and Banarasi cuisine.",
          "dishes": [
            {"name": "Banarasi Paan", "description": "Traditional betel leaf", "type": "Vegetarian"},
            {"name": "Kachori Sabzi", "description": "Crispy with potato curry", "type": "Vegetarian"},
            {"name": "Malaiyo", "description": "Winter dessert from milk foam", "type": "Vegetarian"},
          ]
        },
        "traditional_dress": {
          "description": "Spiritual and cultural heritage reflected in attire.",
          "male": {"name": "Dhoti-Kurta", "description": "Simple white or cream", "occasions": ["Religious ceremonies", "Daily wear"]},
          "female": {"name": "Banarasi Saree", "description": "Silk with gold brocade", "occasions": ["Weddings", "Festivals"]}
        },
        "culture": {
          "description": "Cultural and spiritual heart of India.",
          "festivals": [
            {"name": "Dev Deepawali", "description": "Festival on Ganges ghats", "month": "November"},
            {"name": "Mahashivratri", "description": "Festival for Lord Shiva", "month": "February/March"},
          ],
          "languages": ["Hindi", "Bhojpuri", "Sanskrit"],
          "art_forms": ["Classical Music", "Kathak Dance", "Silk Weaving"]
        },
        "tourist_places": [
          {"name": "Kashi Vishwanath Temple", "description": "Sacred Shiva temple", "timings": "3:00 AM - 11:00 PM", "entry_fee": "Free"},
          {"name": "Dashashwamedh Ghat", "description": "Famous ghat with Aarti", "timings": "Open 24 hours", "entry_fee": "Free"},
          {"name": "Sarnath", "description": "Buddhist pilgrimage site", "timings": "Sunrise to Sunset", "entry_fee": "INR 20"},
        ],
        "history": {
          "overview": "Over 3000 years old, one of oldest inhabited cities.",
          "timeline": [
            {"period": "Ancient Period", "description": "Mentioned in Rigveda"},
            {"period": "Buddhist Era", "description": "Buddha's first sermon at Sarnath"},
            {"period": "Medieval Period", "description": "Remained religious center despite invasions"},
          ]
        }
      },
    ];

    try {
      for (int i = 0; i < cities.length; i++) {
        final cityData = cities[i];
        final cityName = cityData['name'];

        setState(() {
          status = 'Uploading $cityName...';
        });

        // Upload to Firestore with city name as document ID
        await firestore
            .collection('cities')
            .doc(cityName.toLowerCase())
            .set(cityData);

        setState(() {
          uploadedCount = i + 1;
          status = 'Uploaded $cityName ✅';
        });

        // Small delay to show progress
        await Future.delayed(const Duration(milliseconds: 500));
      }

      setState(() {
        status = '✅ Upload Complete! Uploaded $uploadedCount cities.';
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully uploaded $uploadedCount cities to Firestore!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      setState(() {
        status = '❌ Error: $e';
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Data Uploader'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                size: 100,
                color: Colors.orange,
              ),
              const SizedBox(height: 30),
              Text(
                'Upload Cities Data to Firestore',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      status,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (uploadedCount > 0) ...[
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: uploadedCount / 3,
                        backgroundColor: Colors.grey[300],
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 5),
                      Text('$uploadedCount / 3 cities uploaded'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: isUploading ? null : uploadCitiesData,
                icon: Icon(isUploading ? Icons.hourglass_bottom : Icons.upload),
                label: Text(isUploading ? 'Uploading...' : 'Upload Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '⚠️ Run this only ONCE to populate Firestore',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:ui';
import 'package:culture_connect/pages/category_pages/tourist_places_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../models/city_model.dart';
import 'category_pages/food_page.dart';
import 'category_pages/traditional_dress_page.dart';
import 'category_pages/culture_info_page.dart';
import 'category_pages/history_page.dart';

class CityDetailPage extends StatelessWidget {
  final City city;

  const CityDetailPage({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          city.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.isDarkMode
                      ? [Colors.black, Colors.deepPurple.shade900]
                      : [Colors.orange.shade50, Colors.white],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Map Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(city.latitude, city.longitude),
                              initialZoom: 13.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c'],
                                userAgentPackageName: 'com.example.culture_connect',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(city.latitude, city.longitude),
                                    width: 80,
                                    height: 80,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Border overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // City Info Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [Colors.deepPurple.withOpacity(0.3), Colors.purple.withOpacity(0.2)]
                              : [Colors.white, Colors.orange.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_city,
                                color: Colors.orange,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  city.name,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.place,
                                color: Colors.orange.shade300,
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                city.state,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            city.description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  "Best Time: ${city.bestTime}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Section Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "🎭 Explore Culture",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category Buttons Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 1.1,
                      children: [
                        _buildCategoryCard(
                          context,
                          icon: Icons.restaurant,
                          title: "Food",
                          gradient: [Colors.red.shade400, Colors.orange.shade400],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FoodPage(
                                  cityId: city.id,
                                  cityName: city.name,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryCard(
                          context,
                          icon: Icons.checkroom,
                          title: "Traditional Dress",
                          gradient: [Colors.purple.shade400, Colors.pink.shade400],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TraditionalDressPage(
                                  cityId: city.id,
                                  cityName: city.name,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryCard(
                          context,
                          icon: Icons.festival,
                          title: "Culture Info",
                          gradient: [Colors.blue.shade400, Colors.cyan.shade400],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CultureInfoPage(
                                  cityId: city.id,
                                  cityName: city.name,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryCard(
                          context,
                          icon: Icons.tour,
                          title: "Tourist Places",
                          gradient: [Colors.green.shade400, Colors.teal.shade400],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TouristPlacesPage(
                                  cityId: city.id,
                                  cityName: city.name,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryCard(
                          context,
                          icon: Icons.history_edu,
                          title: "History",
                          gradient: [Colors.amber.shade400, Colors.orange.shade600],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryPage(
                                  cityId: city.id,
                                  cityName: city.name,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Famous For Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeProvider.isDarkMode
                              ? [Colors.orange.shade900.withOpacity(0.3), Colors.deepOrange.withOpacity(0.2)]
                              : [Colors.orange.shade50, Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                "Famous For",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: city.famousFor.map((item) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                                ),
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required List<Color> gradient,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
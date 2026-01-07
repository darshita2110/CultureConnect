import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme_provider.dart';
import '../services/gemini_service.dart';
import 'category_pages/culture_info_page.dart';
import 'category_pages/food_page.dart';
import 'category_pages/history_page.dart';
import 'category_pages/tourist_places_page.dart';
import 'category_pages/traditional_dress_page.dart';

class CityDetailPageSimple extends StatefulWidget {
  final Map<String, dynamic> city;

  const CityDetailPageSimple({super.key, required this.city});

  @override
  State<CityDetailPageSimple> createState() => _CityDetailPageSimpleState();
}

class _CityDetailPageSimpleState extends State<CityDetailPageSimple> {
  String? cityTagline;
  bool isLoadingTagline = true;

  @override
  void initState() {
    super.initState();
    _loadTagline();
  }

  Future<void> _loadTagline() async {
    final tagline = await GeminiService.getCityTagline(widget.city['name']);
    setState(() {
      cityTagline = tagline;
      isLoadingTagline = false;
    });
  }

  Future<void> _openInGoogleMaps() async {
    final lat = widget.city['latitude'];
    final lng = widget.city['longitude'];
    final cityName = widget.city['name'];

    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

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
          city['name'],
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

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Map with tap to open Google Maps
                  GestureDetector(
                    onTap: _openInGoogleMaps,
                    child: Container(
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
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(widget.city['latitude'], widget.city['longitude']),
                                initialZoom: 13.0,
                                interactiveFlags: InteractiveFlag.none, // Disable map interaction
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
                                      point: LatLng(widget.city['latitude'], widget.city['longitude']),
                                      width: 80,
                                      height: 80,
                                      child:  const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Overlay to show it's clickable
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.map, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Open in Maps',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // City Info with Tagline
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
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.city['name'],
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.place, color: Colors.orange, size: 18),
                              const SizedBox(width: 5),
                              Text(
                                widget.city['state'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isLoadingTagline)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (cityTagline != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.deepOrange],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cityTagline!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "🎭 Explore Culture",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category Buttons
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodPageSimple(city: city),
                            ),
                          ),
                        ),
                        _buildCategoryCard(
                          context,
                          icon: Icons.checkroom,
                          title: "Traditional Dress",
                          gradient: [Colors.purple.shade400, Colors.pink.shade400],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TraditionalDressPageSimple(city: city),
                            ),
                          ),
                        ),
                        _buildCategoryCard(
                          context,
                          icon: Icons.festival,
                          title: "Culture Info",
                          gradient: [Colors.blue.shade400, Colors.cyan.shade400],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CultureInfoPageSimple(city: city),
                            ),
                          ),
                        ),
                        _buildCategoryCard(
                          context,
                          icon: Icons.tour,
                          title: "Tourist Places",
                          gradient: [Colors.green.shade400, Colors.teal.shade400],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TouristPlacesPageSimple(city: city),
                            ),
                          ),
                        ),
                        _buildCategoryCard(
                          context,
                          icon: Icons.history_edu,
                          title: "History",
                          gradient: [Colors.amber.shade400, Colors.orange.shade600],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryPageSimple(city: city),
                            ),
                          ),
                        ),
                      ],
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
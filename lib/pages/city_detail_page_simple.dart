import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme_provider.dart';
import '../services/gemini_service.dart';
import 'category_pages/food_page.dart';
import 'category_pages/traditional_dress_page.dart';
import 'category_pages/culture_info_page.dart';
import 'category_pages/tourist_places_page.dart';
import 'category_pages/history_page.dart';

class CityDetailPage extends StatefulWidget {
  final Map<String, dynamic> city;

  const CityDetailPage({super.key, required this.city});

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  String cityTagline = '';
  bool isLoadingTagline = true;

  @override
  void initState() {
    super.initState();
    _loadTagline();
  }

  Future<void> _loadTagline() async {
    try {
      final tagline = await GeminiService.getCityTagline(widget.city['name']);
      if (mounted) {
        setState(() {
          cityTagline = tagline;
          isLoadingTagline = false;
        });
      }
    } catch (e) {
      print('Tagline error: $e');
      if (mounted) {
        setState(() {
          cityTagline = 'Historic City';
          isLoadingTagline = false;
        });
      }
    }
  }

  Future<void> _openInGoogleMaps() async {
    try {
      final lat = widget.city['latitude'];
      final lng = widget.city['longitude'];
      final cityName = Uri.encodeComponent(widget.city['name']);

      // Google Maps web URL (works on all platforms)
      final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      
      // Google Maps app URL for Android
      final androidUrl = Uri.parse('google.navigation:q=$lat,$lng');
      
      // Google Maps app URL for iOS
      final iosUrl = Uri.parse('comgooglemaps://?q=$lat,$lng&center=$lat,$lng');
      
      // geo: URL scheme
      final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($cityName)');

      print('🗺️ Trying to open maps for: $lat, $lng');

      // Try different URL schemes
      bool launched = false;
      
      // Try geo: first (Android)
      if (!launched && await canLaunchUrl(geoUrl)) {
        print('🗺️ Launching geo URL...');
        launched = await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
      }
      
      // Try Google Maps app URL (Android)
      if (!launched && await canLaunchUrl(androidUrl)) {
        print('🗺️ Launching Android Google Maps URL...');
        launched = await launchUrl(androidUrl, mode: LaunchMode.externalApplication);
      }
      
      // Try Google Maps app URL (iOS)
      if (!launched && await canLaunchUrl(iosUrl)) {
        print('🗺️ Launching iOS Google Maps URL...');
        launched = await launchUrl(iosUrl, mode: LaunchMode.externalApplication);
      }
      
      // Fallback: Web URL (works everywhere)
      if (!launched) {
        print('🗺️ Launching web URL...');
        launched = await launchUrl(
          webUrl, 
          mode: LaunchMode.externalApplication,
        );
      }
      
      // If still not launched, try with platformDefault
      if (!launched) {
        print('🗺️ Trying platformDefault mode...');
        launched = await launchUrl(
          webUrl,
          mode: LaunchMode.platformDefault,
        );
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open maps. Please check if you have a browser installed.')),
        );
      }
    } catch (e) {
      print('❌ Maps error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening maps: $e')),
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
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.city['name'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background
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
                  SizedBox(height: 10),

                  // Map - Clickable
                  GestureDetector(
                    onTap: _openInGoogleMaps,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  widget.city['latitude'],
                                  widget.city['longitude'],
                                ),
                                initialZoom: 13.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c'],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                        widget.city['latitude'],
                                        widget.city['longitude'],
                                      ),
                                      width: 80,
                                      height: 80,
                                      child: Icon(
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
                          // Tap hint
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                children: [
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

                  SizedBox(height: 25),

                  // City Info Card with Tagline
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.all(20),
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
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
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
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.place, color: Colors.orange, size: 18),
                              SizedBox(width: 5),
                              Text(
                                widget.city['state'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          // Tagline
                          if (isLoadingTagline)
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                            )
                          else if (cityTagline.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.deepOrange],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cityTagline,
                                style: TextStyle(
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

                  SizedBox(height: 30),

                  // Section Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
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

                  SizedBox(height: 20),

                  // Category Grid
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
                              builder: (context) => FoodPage(city: widget.city),
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
                              builder: (context) => TraditionalDressPageEnhanced(city: widget.city),
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
                              builder: (context) => CultureInfoPageEnhanced(city: widget.city),
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
                              builder: (context) => TouristPlacesPage(city: widget.city),
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
                              builder: (context) => HistoryPageEnhanced(city: widget.city),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),
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
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
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
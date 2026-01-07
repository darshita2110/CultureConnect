import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../data/indian_cities.dart';
import 'city_detail_page_simple.dart';
import 'journal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> cities = [];
  Map<String, dynamic>? selectedCity;

  final List<Map<String, String>> festivalCards = [
    {
      "name": "Diwali",
      "place": "Ayodhya",
      "image": "assets/images/diwali_ayodhya.png",
    },
    {
      "name": "Holi",
      "place": "Mathura",
      "image": "assets/images/goverdhan_mathura.png",
    },
    {
      "name": "Pushkar Fair",
      "place": "Pushkar",
      "image": "assets/images/chattpuja_bihar.png",
    },
  ];

  AnimationController? _animController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animController!, curve: Curves.easeIn);
    _animController!.forward();

    // Load cities from simple list (no API call needed!)
    cities = IndianCities.getAllCities();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  void _navigateToCityDetail(Map<String, dynamic> city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailPageSimple(city: city),
      ),
    ).then((_) {
      setState(() {
        selectedCity = null;
      });
    });
  }

  void _navigateToJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JournalPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.orange, Colors.deepOrange, Colors.pink],
              ).createShader(bounds),
              child: const Text(
                "Culture Connect",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: themeProvider.isDarkMode ? Colors.yellow : Colors.orange,
                size: 28,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_home.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(
                color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.isDarkMode
                      ? [
                    Colors.black.withOpacity(0.6),
                    Colors.deepPurple.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ]
                      : [
                    Colors.white.withOpacity(0.3),
                    Colors.orange.withOpacity(0.2),
                    Colors.white.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: _fadeAnimation == null
                ? const SizedBox.shrink()
                : FadeTransition(
              opacity: _fadeAnimation!,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Welcome Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: themeProvider.isDarkMode
                                ? [Colors.deepPurple.withOpacity(0.3), Colors.purple.withOpacity(0.2)]
                                : [Colors.white.withOpacity(0.4), Colors.orange.withOpacity(0.2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Discover India's Rich Heritage",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Powered by AI - Real-time cultural insights",
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Festival Carousel
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "✨ Featured Festivals",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    CarouselSlider(
                      options: CarouselOptions(
                        height: 240,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.85,
                        autoPlayInterval: const Duration(seconds: 4),
                      ),
                      items: festivalCards.map((festival) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    festival['image']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.festival, size: 80, color: Colors.white54),
                                        ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          festival['place']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        festival['name']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 40),

                    // City Selection
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "🏛️ Explore by City",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${cities.length} cities',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? Colors.deepPurple.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
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
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Map<String, dynamic>>(
                                value: selectedCity,
                                hint: Text(
                                  "Select Your City",
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                dropdownColor: themeProvider.isDarkMode
                                    ? Colors.deepPurple[900]
                                    : Colors.white,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                ),
                                isExpanded: true,
                                style: TextStyle(
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: cities.map((city) {
                                  return DropdownMenuItem<Map<String, dynamic>>(
                                    value: city,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_city, size: 20, color: Colors.orange),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            city['name'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (Map<String, dynamic>? value) {
                                  if (value != null) {
                                    _navigateToCityDetail(value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Journal Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: InkWell(
                        onTap: _navigateToJournal,
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: themeProvider.isDarkMode
                                  ? [Colors.deepPurple, Colors.purple.shade700]
                                  : [Colors.pinkAccent, Colors.orangeAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (themeProvider.isDarkMode ? Colors.purple : Colors.orange)
                                    .withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.auto_stories, size: 40, color: Colors.white),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "My Culture Journal",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Save your trip memories",
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
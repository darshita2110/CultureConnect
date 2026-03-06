import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gemini_service.dart';
import '../../services/unsplash_service.dart';
import '../../theme_provider.dart';

class CultureInfoPageEnhanced extends StatefulWidget {
  final Map<String, dynamic> city;

  const CultureInfoPageEnhanced({super.key, required this.city});

  @override
  State<CultureInfoPageEnhanced> createState() => _CultureInfoPageEnhancedState();
}

class _CultureInfoPageEnhancedState extends State<CultureInfoPageEnhanced> {
  Map<String, dynamic>? cultureData;
  Map<String, String?> festivalImages = {};
  Map<String, String?> artFormImages = {};
  Map<String, String?> uniqueAspectImages = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCultureData();
  }

  Future<void> _loadCultureData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await GeminiService.generateCultureData(widget.city['name']);

      setState(() {
        cultureData = data;
        isLoading = false;
      });

      _loadImages();
    } catch (e) {
      setState(() {
        error = 'Failed to load culture data';
        isLoading = false;
      });
    }
  }

  Future<void> _loadImages() async {
    if (cultureData == null) return;

    // Load festival images
    final festivals = (cultureData!['festivals'] as List?) ?? [];
    for (var festival in festivals) {
      final keywords = festival['image_keywords'] ??
          '${festival['name']} festival ${widget.city['name']}';
      final imageUrl = await UnsplashService.searchImage(keywords);
      if (mounted) {
        setState(() {
          festivalImages[festival['name']] = imageUrl;
        });
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // Load art form images
    final artForms = (cultureData!['art_forms'] as List?) ?? [];
    for (var art in artForms) {
      final keywords = art['image_keywords'] ??
          '${art['name']} Indian art';
      final imageUrl = await UnsplashService.searchImage(keywords);
      if (mounted) {
        setState(() {
          artFormImages[art['name']] = imageUrl;
        });
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // Load unique aspects images
    final uniqueAspects = (cultureData!['unique_aspects'] as List?) ?? [];
    for (var aspect in uniqueAspects) {
      final keywords = aspect['image_keywords'] ??
          '${aspect['title']} ${widget.city['name']}';
      final imageUrl = await UnsplashService.searchImage(keywords);
      if (mounted) {
        setState(() {
          uniqueAspectImages[aspect['title']] = imageUrl;
        });
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.blue[50],
      appBar: AppBar(
        title: Text('${widget.city['name']} Culture'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCultureData,
            tooltip: 'Regenerate',
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : error != null
          ? _buildErrorState()
          : _buildContent(themeProvider),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 20),
          Text(
            'Exploring cultural heritage...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 20),
          Text(error!, style: TextStyle(fontSize: 16)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadCultureData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeProvider themeProvider) {
    final description = cultureData!['description'] ?? '';
    final culturalIdentity = cultureData!['cultural_identity'] ?? '';
    final uniqueAspects = (cultureData!['unique_aspects'] as List?) ?? [];
    final festivals = (cultureData!['festivals'] as List?) ?? [];
    final artForms = (cultureData!['art_forms'] as List?) ?? [];
    final legends = (cultureData!['legends_stories'] as List?) ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.cyan],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.festival, color: Colors.white, size: 32),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Cultural Heritage',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                ),
                if (culturalIdentity.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            culturalIdentity,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 24),

          // Unique Cultural Aspects
          if (uniqueAspects.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.purple, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'What Makes It Unique',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ...uniqueAspects.map((aspect) => _buildUniqueAspectCard(aspect, themeProvider)).toList(),
          ],

          // Festivals Section
          if (festivals.isNotEmpty) ...[
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.orange, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Festivals & Celebrations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ...festivals.map((festival) => _buildFestivalCard(festival, themeProvider)).toList(),
          ],

          // Art Forms Section
          if (artForms.isNotEmpty) ...[
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.palette, color: Colors.teal, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Traditional Arts & Crafts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ...artForms.map((art) => _buildArtFormCard(art, themeProvider)).toList(),
          ],

          // Legends & Stories
          if (legends.isNotEmpty) ...[
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.menu_book, color: Colors.brown, size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Legends & Stories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ...legends.map((legend) => _buildLegendCard(legend, themeProvider)).toList(),
          ],

          // Additional Info Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (cultureData!['cuisine_culture'] != null)
                  _buildInfoCard(
                    'Food Culture',
                    cultureData!['cuisine_culture'],
                    Icons.restaurant,
                    Colors.red,
                    themeProvider,
                  ),
                SizedBox(height: 16),
                if (cultureData!['daily_life'] != null)
                  _buildInfoCard(
                    'Daily Life & Values',
                    cultureData!['daily_life'],
                    Icons.home,
                    Colors.green,
                    themeProvider,
                  ),
              ],
            ),
          ),

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildUniqueAspectCard(Map<String, dynamic> aspect, ThemeProvider themeProvider) {
    final title = aspect['title'] ?? '';
    final description = aspect['description'] ?? '';
    final imageUrl = uniqueAspectImages[title];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(Icons.auto_awesome, Colors.purple),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalCard(Map<String, dynamic> festival, ThemeProvider themeProvider) {
    final name = festival['name'] ?? '';
    final description = festival['description'] ?? '';
    final celebrations = festival['celebrations'] ?? '';
    final month = festival['month'] ?? '';
    final significance = festival['significance'] ?? '';
    final rituals = (festival['rituals'] as List?) ?? [];
    final imageUrl = festivalImages[name];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Month Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(Icons.celebration, Colors.orange),
                )
                    : _buildPlaceholder(Icons.celebration, Colors.orange),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
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
                      Icon(Icons.calendar_today, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        month,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                if (celebrations.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.celebration, color: Colors.blue, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            celebrations,
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (rituals.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Rituals:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...rituals.map((ritual) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ritual.toString(),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
                if (significance.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_stories, color: Colors.purple, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            significance,
                            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtFormCard(Map<String, dynamic> art, ThemeProvider themeProvider) {
    final name = art['name'] ?? '';
    final description = art['description'] ?? '';
    final history = art['history'] ?? '';
    final currentStatus = art['current_status'] ?? '';
    final whereToSee = art['where_to_see'] ?? '';
    final imageUrl = artFormImages[name];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(Icons.palette, Colors.teal),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
                if (history.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    history,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (currentStatus.isNotEmpty || whereToSee.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (currentStatus.isNotEmpty)
                        Chip(
                          label: Text(currentStatus, style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.teal.withOpacity(0.2),
                          avatar: Icon(Icons.trending_up, size: 16, color: Colors.teal),
                        ),
                      if (whereToSee.isNotEmpty)
                        Chip(
                          label: Text(whereToSee, style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          avatar: Icon(Icons.place, size: 16, color: Colors.blue),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard(Map<String, dynamic> legend, ThemeProvider themeProvider) {
    final title = legend['title'] ?? '';
    final story = legend['story'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: Colors.brown, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            story,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon, Color color) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 60, color: color.withOpacity(0.5)),
      ),
    );
  }
}
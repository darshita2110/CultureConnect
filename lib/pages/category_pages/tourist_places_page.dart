import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gemini_service.dart';
import '../../services/pexels_image_service.dart';
import '../../theme_provider.dart';

class TouristPlacesPage extends StatefulWidget {
  final Map<String, dynamic> city;

  const TouristPlacesPage({super.key, required this.city});

  @override
  State<TouristPlacesPage> createState() => _TouristPlacesPageState();
}

class _TouristPlacesPageState extends State<TouristPlacesPage> {
  List<Map<String, dynamic>> places = [];
  Map<String, String?> images = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final placesData = await GeminiService.generateTouristPlaces(widget.city['name']);

      setState(() {
        places = placesData;
        isLoading = false;
      });

      _loadImages();
    } catch (e) {
      setState(() {
        error = 'Failed to load places: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadImages() async {
    for (var place in places) {
      final placeName = place['name'] ?? '';
      if (placeName.isNotEmpty) {
        try {
          final imageUrl = await PexelsImageService.getMonumentImage(
            placeName,
            widget.city['name'],
          );

          if (mounted) {
            setState(() {
              images[placeName] = imageUrl;
            });
          }
        } catch (e) {
          print('Image error: $e');
        }
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.green[50],
      appBar: AppBar(
        title: Text('${widget.city['name']} Tourist Places'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text('Finding amazing places...'),
          ],
        ),
      )
          : error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(error!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : places.isEmpty
          ? Center(child: Text('No places available'))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Must-Visit Places',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            ...places.asMap().entries.map((entry) {
              return _buildPlaceCard(entry.value, entry.key + 1, themeProvider);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place, int number, ThemeProvider themeProvider) {
    final placeName = place['name'] ?? 'Unknown Place';
    final description = place['description'] ?? '';
    final timings = place['timings'] ?? '';
    final entryFee = place['entry_fee'] ?? '';
    final closedOn = place['closed_on'] ?? '';
    final rules = place['rules'] as List? ?? [];
    final imageUrl = images[placeName];

    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with number
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: imageUrl != null
                    ? Image.network(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                )
                    : _buildPlaceholder(),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
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
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 5),
                      Text(
                        '#$number',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  placeName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),

                if (description.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ],

                SizedBox(height: 16),

                // Visitor Info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Visitor Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      if (timings.isNotEmpty)
                        _buildInfoRow(Icons.access_time, 'Timings', timings, Colors.green),

                      if (entryFee.isNotEmpty) ...[
                        SizedBox(height: 8),
                        _buildInfoRow(Icons.currency_rupee, 'Entry Fee', entryFee, Colors.orange),
                      ],

                      if (closedOn.isNotEmpty) ...[
                        SizedBox(height: 8),
                        _buildInfoRow(Icons.event_busy, 'Closed On', closedOn, Colors.red),
                      ],
                    ],
                  ),
                ),

                // Rules
                if (rules.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.rule, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Rules',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ...rules.map((rule) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rule.toString(),
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
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

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[300]!, Colors.teal[400]!],
        ),
      ),
      child: Center(
        child: Icon(Icons.place, size: 60, color: Colors.white.withOpacity(0.5)),
      ),
    );
  }
}
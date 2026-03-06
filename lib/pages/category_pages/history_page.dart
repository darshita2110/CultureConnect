import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gemini_service.dart';
import '../../services/unsplash_service.dart';
import '../../theme_provider.dart';

class HistoryPageEnhanced extends StatefulWidget {
  final Map<String, dynamic> city;

  const HistoryPageEnhanced({super.key, required this.city});

  @override
  State<HistoryPageEnhanced> createState() => _HistoryPageEnhancedState();
}

class _HistoryPageEnhancedState extends State<HistoryPageEnhanced> {
  Map<String, dynamic>? historyData;
  Map<String, String?> periodImages = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await GeminiService.generateHistoryData(widget.city['name']);

      setState(() {
        historyData = data;
        isLoading = false;
      });

      _loadImages();
    } catch (e) {
      setState(() {
        error = 'Failed to load history data';
        isLoading = false;
      });
    }
  }

  Future<void> _loadImages() async {
    if (historyData == null) return;

    final timeline = (historyData!['timeline'] as List?) ?? [];
    for (var period in timeline) {
      final periodName = period['period'] ?? '';
      final keywords = period['image_keywords'] ??
          '${period['era_name']} ${widget.city['name']} history';
      final imageUrl = await UnsplashService.searchImage(keywords);

      if (mounted) {
        setState(() {
          periodImages[periodName] = imageUrl;
        });
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.amber[50],
      appBar: AppBar(
        title: Text('${widget.city['name']} History'),
        backgroundColor: Colors.amber[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistoryData,
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
          CircularProgressIndicator(color: Colors.amber),
          SizedBox(height: 20),
          Text(
            'Traveling through time...',
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
            onPressed: _loadHistoryData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeProvider themeProvider) {
    final overview = historyData!['overview'] ?? '';
    final significance = historyData!['significance'] ?? '';
    final timeline = (historyData!['timeline'] as List?) ?? [];
    final modernEra = historyData!['modern_era'] ?? '';
    final heritageSites = (historyData!['heritage_sites'] as List?) ?? [];

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
                colors: [Colors.amber[700]!, Colors.orange[600]!],
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
                      child: Icon(Icons.history_edu, color: Colors.white, size: 32),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Historical Journey',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (historyData!['ancient_name'] != null) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Ancient Name: ${historyData!['ancient_name']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 24),

          // Overview Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
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
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[700], size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Historical Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    overview,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.7,
                      color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                  if (significance.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Significance',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  significance,
                                  style: TextStyle(fontSize: 14, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 32),

          // Timeline Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.timeline, color: Colors.blue, size: 28),
                SizedBox(width: 10),
                Text(
                  'Historical Timeline',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Timeline
          ...timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final period = entry.value;
            final isLast = index == timeline.length - 1;
            return _buildTimelineItem(period, index, isLast, themeProvider);
          }).toList(),

          // Modern Era
          if (modernEra.isNotEmpty) ...[
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.withOpacity(0.2), Colors.teal.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.green, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Modern Era',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      modernEra,
                      style: TextStyle(fontSize: 15, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Heritage Sites
          if (heritageSites.isNotEmpty) ...[
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.museum, color: Colors.red, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Heritage Sites',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...heritageSites.map((site) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.verified, color: Colors.red, size: 20),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  site['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${site['status']} (${site['year_inscribed']})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> period, int index, bool isLast, ThemeProvider themeProvider) {
    final periodName = period['period'] ?? '';
    final eraName = period['era_name'] ?? '';
    final description = period['description'] ?? '';
    final keyEvents = (period['key_events'] as List?) ?? [];
    final rulers = (period['rulers'] as List?) ?? [];
    final monuments = (period['monuments_built'] as List?) ?? [];
    final culturalImpact = period['cultural_impact'] ?? '';
    final legacy = period['legacy'] ?? '';
    final imageUrl = periodImages[periodName];

    final colors = [
      [Colors.blue[400]!, Colors.cyan[400]!],
      [Colors.purple[400]!, Colors.pink[400]!],
      [Colors.green[400]!, Colors.teal[400]!],
      [Colors.orange[400]!, Colors.red[400]!],
      [Colors.amber[400]!, Colors.orange[600]!],
      [Colors.indigo[400]!, Colors.blue[400]!],
    ];
    final gradient = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 16, bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 3,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient[0].withOpacity(0.6),
                        gradient[1].withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 16),

          // Content Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gradient[0].withOpacity(0.3), width: 2),
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
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          periodName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (eraName.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            eraName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Image if available
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: TextStyle(fontSize: 14, height: 1.6),
                        ),

                        // Key Events
                        if (keyEvents.isNotEmpty) ...[
                          SizedBox(height: 16),
                          _buildSubSection(
                            'Key Events',
                            Icons.event,
                            gradient[0],
                            keyEvents.map((event) {
                              if (event is Map) {
                                return '${event['date']}: ${event['event']} - ${event['significance']}';
                              }
                              return event.toString();
                            }).toList(),
                          ),
                        ],

                        // Rulers
                        if (rulers.isNotEmpty) ...[
                          SizedBox(height: 16),
                          _buildSubSection(
                            'Notable Rulers',
                            Icons.person,
                            gradient[1],
                            rulers.map((ruler) {
                              if (ruler is Map) {
                                return '${ruler['name']} (${ruler['reign']}): ${ruler['contribution']}';
                              }
                              return ruler.toString();
                            }).toList(),
                          ),
                        ],

                        // Monuments
                        if (monuments.isNotEmpty) ...[
                          SizedBox(height: 16),
                          _buildSubSection(
                            'Monuments Built',
                            Icons.account_balance,
                            Colors.brown,
                            monuments.map((monument) {
                              if (monument is Map) {
                                final stillExists = monument['still_exists'] == true ? '✓' : '✗';
                                return '$stillExists ${monument['name']} (${monument['year']}) - by ${monument['builder']}';
                              }
                              return monument.toString();
                            }).toList(),
                          ),
                        ],

                        // Cultural Impact
                        if (culturalImpact.isNotEmpty) ...[
                          SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.palette, color: Colors.purple, size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    culturalImpact,
                                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Legacy
                        if (legacy.isNotEmpty) ...[
                          SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: gradient[0].withOpacity(0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.star, color: gradient[0], size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Legacy',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: gradient[0],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        legacy,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, IconData icon, Color color, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}
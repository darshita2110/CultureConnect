import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gemini_service.dart';
import '../../services/dress_image_service.dart';
import '../../theme_provider.dart';

class TraditionalDressPageEnhanced extends StatefulWidget {
  final Map<String, dynamic> city;

  const TraditionalDressPageEnhanced({super.key, required this.city});

  @override
  State<TraditionalDressPageEnhanced> createState() => _TraditionalDressPageEnhancedState();
}

class _TraditionalDressPageEnhancedState extends State<TraditionalDressPageEnhanced> {
  Map<String, dynamic>? dressData;
  String? maleImage;
  String? femaleImage;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDressData();
  }

  Future<void> _loadDressData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await GeminiService.generateDressData(
        widget.city['name'],
        widget.city['state'],
      );

      setState(() {
        dressData = data;
        isLoading = false;
      });

      _loadImages();
    } catch (e) {
      setState(() {
        error = 'Failed to load dress data';
        isLoading = false;
      });
    }
  }

  Future<void> _loadImages() async {
    if (dressData == null) return;

    // Load male dress image
    final maleName = dressData!['male']?['name'] ?? 'Traditional male dress';
    final maleUrl = await DressImageService.getDressImage(
      maleName,
      widget.city['state'],
      'male',
    );

    // Load female dress image
    final femaleName = dressData!['female']?['name'] ?? 'Traditional female dress';
    final femaleUrl = await DressImageService.getDressImage(
      femaleName,
      widget.city['state'],
      'female',
    );

    if (mounted) {
      setState(() {
        maleImage = maleUrl;
        femaleImage = femaleUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.purple[50],
      appBar: AppBar(
        title: Text('${widget.city['name']} Traditional Dress'),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDressData,
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
          CircularProgressIndicator(color: Colors.purple),
          SizedBox(height: 20),
          Text(
            'Discovering traditional attire...',
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
            onPressed: _loadDressData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeProvider themeProvider) {
    final description = dressData!['description'] ?? '';
    final regionalSpecialty = dressData!['regional_specialty'] ?? '';

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
                colors: [Colors.purple, Colors.pink],
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
                      child: Icon(Icons.checkroom, color: Colors.white, size: 32),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Traditional Attire',
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
                if (regionalSpecialty.isNotEmpty) ...[
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
                            regionalSpecialty,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
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

          // Male Dress
          _buildGenderSection(
            context,
            gender: 'Male',
            icon: Icons.man,
            data: dressData!['male'] ?? {},
            image: maleImage,
            gradient: [Colors.blue, Colors.cyan],
            themeProvider: themeProvider,
          ),

          SizedBox(height: 24),

          // Female Dress
          _buildGenderSection(
            context,
            gender: 'Female',
            icon: Icons.woman,
            data: dressData!['female'] ?? {},
            image: femaleImage,
            gradient: [Colors.pink, Colors.purple],
            themeProvider: themeProvider,
          ),

          // Famous Weavers/Artisans
          if (dressData!['famous_weavers'] != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.2), Colors.orange.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette, color: Colors.amber[700], size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Craftsmanship',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      dressData!['famous_weavers'],
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildGenderSection(
      BuildContext context, {
        required String gender,
        required IconData icon,
        required Map<String, dynamic> data,
        required String? image,
        required List<Color> gradient,
        required ThemeProvider themeProvider,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
            // Header with Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      '$gender Traditional Dress',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image
            if (image != null)
              ClipRRect(
                child: Image.network(
                  image,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 280,
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(icon, gradient),
                ),
              )
            else
              _buildPlaceholderImage(icon, gradient),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    data['name'] ?? '',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),

                  SizedBox(height: 12),

                  // Description
                  Text(
                    data['description'] ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),

                  // Components
                  if (data['components'] != null && (data['components'] as List).isNotEmpty) ...[
                    SizedBox(height: 20),
                    _buildSectionTitle('Components', Icons.inventory_2, gradient[0]),
                    SizedBox(height: 10),
                    ...(data['components'] as List).map((component) {
                      if (component is Map) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: gradient[0],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${component['item']}: ',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: component['details']),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.fiber_manual_record, size: 8, color: gradient[0]),
                            SizedBox(width: 10),
                            Text(component.toString(), style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  // Info Grid
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (data['fabric'] != null)
                        _buildInfoCard('Fabric', data['fabric'], Icons.texture, gradient[0]),
                      if (data['colors'] != null)
                        _buildInfoCard('Colors', data['colors'], Icons.palette, gradient[1]),
                      if (data['embroidery'] != null)
                        _buildInfoCard('Embroidery', data['embroidery'], Icons.auto_fix_high, gradient[0]),
                      if (data['patterns'] != null)
                        _buildInfoCard('Patterns', data['patterns'], Icons.grid_on, gradient[1]),
                      if (data['jewelry'] != null)
                        _buildInfoCard('Jewelry', data['jewelry'], Icons.diamond, gradient[0]),
                      if (data['draping_style'] != null)
                        _buildInfoCard('Draping', data['draping_style'], Icons.style, gradient[1]),
                      if (data['accessories'] != null && (data['accessories'] as List).isNotEmpty)
                        _buildInfoCard('Accessories', (data['accessories'] as List).join(', '), Icons.shopping_bag, gradient[0]),
                    ],
                  ),

                  // Occasions
                  if (data['occasions'] != null && (data['occasions'] as List).isNotEmpty) ...[
                    SizedBox(height: 20),
                    _buildSectionTitle('Worn On', Icons.event, gradient[0]),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (data['occasions'] as List).map((occasion) {
                        return Chip(
                          label: Text(occasion.toString()),
                          backgroundColor: gradient[0].withOpacity(0.2),
                          side: BorderSide(color: gradient[0].withOpacity(0.5)),
                          avatar: Icon(Icons.celebration, size: 18, color: gradient[0]),
                        );
                      }).toList(),
                    ),
                  ],

                  // Cultural Significance
                  if (data['cultural_significance'] != null) ...[
                    SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gradient[0].withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_stories, color: gradient[0], size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Cultural Significance',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: gradient[0],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            data['cultural_significance'],
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Evolution
                  if (data['evolution'] != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.history, color: Colors.amber[700], size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              data['evolution'],
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
      ),
    );
  }

  Widget _buildPlaceholderImage(IconData icon, List<Color> gradient) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient.map((c) => c.withOpacity(0.3)).toList(),
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 80,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
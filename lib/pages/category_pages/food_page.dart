import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/gemini_service.dart';
import '../../services/unsplash_service.dart';
import '../../theme_provider.dart';

class FoodPageSimple extends StatefulWidget {
  final Map<String, dynamic> city;

  const FoodPageSimple({super.key, required this.city});

  @override
  State<FoodPageSimple> createState() => _FoodPageSimpleState();
}

class _FoodPageSimpleState extends State<FoodPageSimple> {
  Map<String, dynamic>? foodData;
  Map<String, String?> dishImages = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFoodData();
  }

  Future<void> _loadFoodData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // AI generates food data in real-time!
      final data = await GeminiService.generateFoodData(widget.city['name']);

      setState(() {
        foodData = data;
        isLoading = false;
      });

      // Load images in background
      _loadImages();
    } catch (e) {
      setState(() {
        error = 'Failed to load data';
        isLoading = false;
      });
    }
  }

  Future<void> _loadImages() async {
    if (foodData == null) return;

    final dishes = (foodData!['dishes'] as List?) ?? [];
    for (var dish in dishes) {
      final dishName = dish['name'] ?? '';
      if (dishName.isNotEmpty) {
        final imageUrl = await UnsplashService.getFoodImage(
          widget.city['name'],
          dishName,
        );
        if (mounted) {
          setState(() {
            dishImages[dishName] = imageUrl;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.city['name']} Food'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFoodData,
            tooltip: 'Regenerate with AI',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 20),
            Text('AI is generating food data...'),
          ],
        ),
      )
          : error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(error!),
            ElevatedButton(
              onPressed: _loadFoodData,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Generated Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'AI Generated Content',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Description
            Text(
              foodData!['description'] ?? '',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),

            // Dishes Title
            const Text(
              'Popular Dishes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Dishes List
            ...((foodData!['dishes'] as List?) ?? []).map((dish) {
              final dishName = dish['name'] ?? '';
              final imageUrl = dishImages[dishName];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image (if available)
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  dishName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: (dish['type'] ?? '').toLowerCase().contains('veg')
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  dish['type'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dish['description'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
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
    );
  }
}
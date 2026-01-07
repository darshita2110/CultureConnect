import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../services/gemini_service.dart';

class CultureInfoPageSimple extends StatefulWidget {
  final Map<String, dynamic> city;

  const CultureInfoPageSimple({super.key, required this.city});

  @override
  State<CultureInfoPageSimple> createState() => _CultureInfoPageSimpleState();
}

class _CultureInfoPageSimpleState extends State<CultureInfoPageSimple> {
  Map<String, dynamic>? cultureData;
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
    } catch (e) {
      setState(() {
        error = 'Failed to load data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.city['name']} Culture'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCultureData,
            tooltip: 'Regenerate with AI',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 20),
            Text('AI is generating culture data...'),
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
              onPressed: _loadCultureData,
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
              cultureData!['description'] ?? '',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),

            // Festivals
            const Text(
              '🎉 Major Festivals',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...((cultureData!['festivals'] as List?) ?? []).map((festival) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              festival['name'] ?? '',
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
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              festival['month'] ?? '',
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
                        festival['description'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            // Languages
            const Text(
              '🗣️ Languages',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ((cultureData!['languages'] as List?) ?? []).map((lang) {
                return Chip(
                  label: Text(lang.toString()),
                  backgroundColor: Colors.blue.shade100,
                  avatar: const Icon(Icons.language, size: 18, color: Colors.blue),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // Art Forms
            const Text(
              '🎨 Art Forms',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ((cultureData!['art_forms'] as List?) ?? []).map((art) {
                return Chip(
                  label: Text(art.toString()),
                  backgroundColor: Colors.purple.shade100,
                  avatar: const Icon(Icons.palette, size: 18, color: Colors.purple),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
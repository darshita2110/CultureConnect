import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../services/gemini_service.dart';

class TraditionalDressPageSimple extends StatefulWidget {
  final Map<String, dynamic> city;

  const TraditionalDressPageSimple({super.key, required this.city});

  @override
  State<TraditionalDressPageSimple> createState() => _TraditionalDressPageSimpleState();
}

class _TraditionalDressPageSimpleState extends State<TraditionalDressPageSimple> {
  Map<String, dynamic>? dressData;
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
        title: Text('${widget.city['name']} Traditional Dress'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDressData,
            tooltip: 'Regenerate with AI',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(height: 20),
            Text('AI is generating dress data...'),
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
              onPressed: _loadDressData,
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
              dressData!['description'] ?? '',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),

            // Male Dress
            _buildGenderCard(
              context,
              gender: 'Male',
              icon: Icons.man,
              data: dressData!['male'] ?? {},
              gradient: [Colors.blue.shade400, Colors.cyan.shade400],
              themeProvider: themeProvider,
            ),

            const SizedBox(height: 20),

            // Female Dress
            _buildGenderCard(
              context,
              gender: 'Female',
              icon: Icons.woman,
              data: dressData!['female'] ?? {},
              gradient: [Colors.pink.shade400, Colors.purple.shade400],
              themeProvider: themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(
      BuildContext context, {
        required String gender,
        required IconData icon,
        required Map<String, dynamic> data,
        required List<Color> gradient,
        required ThemeProvider themeProvider,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 32, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  '$gender Traditional Dress',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  data['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  data['description'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Occasions
                const Text(
                  'Worn On:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ((data['occasions'] as List?) ?? []).map((occasion) {
                    return Chip(
                      label: Text(occasion.toString()),
                      backgroundColor: gradient[0].withOpacity(0.2),
                      avatar: Icon(Icons.event, size: 16, color: gradient[0]),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../services/gemini_service.dart';

class HistoryPageSimple extends StatefulWidget {
  final Map<String, dynamic> city;

  const HistoryPageSimple({super.key, required this.city});

  @override
  State<HistoryPageSimple> createState() => _HistoryPageSimpleState();
}

class _HistoryPageSimpleState extends State<HistoryPageSimple> {
  Map<String, dynamic>? historyData;
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
        title: Text('${widget.city['name']} History'),
        backgroundColor: Colors.amber.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistoryData,
            tooltip: 'Regenerate with AI',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.amber),
            SizedBox(height: 20),
            Text('AI is generating history data...'),
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
              onPressed: _loadHistoryData,
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

            // Overview
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700),
                        const SizedBox(width: 10),
                        const Text(
                          'Historical Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      historyData!['overview'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Timeline Title
            const Text(
              '📜 Historical Timeline',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Timeline
            ...((historyData!['timeline'] as List?) ?? []).asMap().entries.map((entry) {
              final index = entry.key;
              final period = entry.value;
              final isLast = index == ((historyData!['timeline'] as List).length - 1);

              final colors = [
                [Colors.blue.shade300, Colors.cyan.shade300],
                [Colors.purple.shade300, Colors.pink.shade300],
                [Colors.green.shade300, Colors.teal.shade300],
                [Colors.orange.shade300, Colors.red.shade300],
                [Colors.amber.shade300, Colors.orange.shade400],
              ];

              final gradient = colors[index % colors.length];

              return _buildTimelineItem(
                index: index,
                period: period['period'] ?? '',
                description: period['description'] ?? '',
                gradient: gradient,
                isLast: isLast,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required int index,
    required String period,
    required String description,
    required List<Color> gradient,
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 3,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient[0].withOpacity(0.5),
                        gradient[1].withOpacity(0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: gradient[0].withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        period,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.grey[700],
                      ),
                    ),
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
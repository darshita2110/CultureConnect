import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final List<JournalEntry> entries = [];

  void _addNewEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddJournalEntrySheet(
        onSave: (entry) {
          setState(() {
            entries.insert(0, entry);
          });
        },
      ),
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
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Culture Journal",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.isDarkMode
                      ? [Colors.deepPurple.shade900, Colors.black]
                      : [Colors.pink.shade50, Colors.orange.shade50],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: entries.isEmpty
                ? _buildEmptyState(themeProvider)
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return _buildJournalCard(entries[index], themeProvider, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewEntry,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text("Add Entry"),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.withOpacity(0.2), Colors.pink.withOpacity(0.2)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.book_outlined,
              size: 80,
              color: themeProvider.isDarkMode ? Colors.white : Colors.orange,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "No Entries Yet",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              "Start documenting your cultural journey by adding your first entry!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry entry, ThemeProvider themeProvider, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeProvider.isDarkMode
              ? [Colors.deepPurple.withOpacity(0.3), Colors.purple.withOpacity(0.2)]
              : [Colors.white, Colors.orange.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            entry.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade300,
                      ),
                      onPressed: () {
                        setState(() {
                          entries.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  entry.description,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      entry.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: themeProvider.isDarkMode ? Colors.white60 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddJournalEntrySheet extends StatefulWidget {
  final Function(JournalEntry) onSave;

  const AddJournalEntrySheet({super.key, required this.onSave});

  @override
  State<AddJournalEntrySheet> createState() => _AddJournalEntrySheetState();
}

class _AddJournalEntrySheetState extends State<AddJournalEntrySheet> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final entry = JournalEntry(
      title: _titleController.text,
      location: _locationController.text,
      description: _descriptionController.text,
      date: DateTime.now().toString().split(' ')[0],
    );

    widget.onSave(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Journal Entry",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title",
                prefixIcon: const Icon(Icons.title, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Location",
                prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                prefixIcon: const Icon(Icons.description, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Save Entry",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalEntry {
  final String title;
  final String location;
  final String description;
  final String date;

  JournalEntry({
    required this.title,
    required this.location,
    required this.description,
    required this.date,
  });
}
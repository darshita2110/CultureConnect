import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:culture_connect/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> items = ["Ayodhya", "Mathura", "Bihar"];
  String? selectedValue;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final String bgImage = themeProvider.isDarkMode
        ? 'assets/images/bg_home_dark.png'
        : 'assets/images/bg_home.png';

    final Color textColor =
    themeProvider.isDarkMode ? Colors.white : Colors.black;
    final Color buttonBg =
    themeProvider.isDarkMode ? Colors.white : Colors.black;
    final Color buttonText =
    themeProvider.isDarkMode ? Colors.black : Colors.white;

    final Map<String, Widget> pages = {
      "Ayodhya": const Option1Page(),
      "Mathura": const Option2Page(),
      "Bihar": const Option3Page(),
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "HomePage",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeProvider.isDarkMode
            ? Colors.black.withOpacity(0.6)
            : Colors.white.withOpacity(0.6),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: textColor,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Stack(
        children: [
          /// 🖼 Background Image
          Positioned.fill(
            child: Image.asset(
              bgImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          /// 🌫 Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          /// 📜 Foreground Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: themeProvider.isDarkMode
                          ? Colors.grey[800]
                          : Colors.white70,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      labelText: "Select the Place",
                      labelStyle: TextStyle(color: textColor),
                    ),
                    dropdownColor: themeProvider.isDarkMode
                        ? Colors.grey[900]
                        : Colors.white,
                    value: selectedValue,
                    items: items.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// Go Button
                  ElevatedButton(
                    onPressed: selectedValue == null
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => pages[selectedValue]!,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBg,
                      foregroundColor: buttonText,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      selectedValue == null
                          ? "Go to ___"
                          : "Go to $selectedValue",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Sliding Cards with Page Indicator
                  SizedBox(
                    height: 230,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            children: [
                              clickableCard("assets/images/diwali_ayodhya.png",
                                  const Option1Page()),
                              clickableCard(
                                  "assets/images/goverdhan_mathura.png",
                                  const Option2Page()),
                              clickableCard("assets/images/chattpuja_bihar.png",
                                  const Option3Page()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                                (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 12 : 8,
                              height: _currentPage == index ? 12 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.white
                                    : Colors.white54,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Bottom container (logo box)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SpecialPage()),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/logo.jpg"),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
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

  Widget clickableCard(String path, Widget page) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Card(
          elevation: 4,
          shadowColor: Colors.black45,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(path, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

// Example Pages
class Option1Page extends StatelessWidget {
  const Option1Page({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ayodhya")),
      body: const Center(child: Text("Welcome to Ayodhya")),
    );
  }
}

class Option2Page extends StatelessWidget {
  const Option2Page({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mathura")),
      body: const Center(child: Text("Welcome to Mathura")),
    );
  }
}

class Option3Page extends StatelessWidget {
  const Option3Page({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bihar")),
      body: const Center(child: Text("Welcome to Bihar")),
    );
  }
}

class SpecialPage extends StatelessWidget {
  const SpecialPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Special Page")),
      body: const Center(child: Text("Welcome to Special Page!")),
    );
  }
}

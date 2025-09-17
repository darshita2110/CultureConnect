import 'package:flutter/material.dart';
import 'login/login.dart';
import 'login/signup.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Auth UI",
      home: const AuthWrapper(),
    );
  }
}

// 🔹 Wrapper to handle login/signup & dark/light mode
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool showLogin = true;      // toggle login/signup
  bool isDarkMode = false;    // toggle dark/light

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void toggleAuthPage() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? LoginPage(
      isDarkMode: isDarkMode,
      onToggle: toggleDarkMode,   // dark/light toggle
      switchPage: toggleAuthPage, // go to signup
    )
        : SignupPage(
      isDarkMode: isDarkMode,
      onToggle: toggleDarkMode,   // dark/light toggle
      switchPage: toggleAuthPage, // go to login
    );
  }
}

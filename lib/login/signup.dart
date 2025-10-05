// Corrected SignupPage.dart
import 'package:culture_connect/login/login.dart';
import 'package:flutter/material.dart';
import 'package:culture_connect/theme_provider.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    // 1. Validate the form fields first
    if (!_formKey.currentState!.validate()) return;

    // 1a. Add check for password matching
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Instantiate the AuthService (assuming the class is the same)
    final auth = AuthService();

    // 3. Call the dedicated sign-up method in your AuthService
    // NOTE: You must ensure AuthService has a method called 'signup'
    final result = await auth.signup(
        _emailController.text,
        _passwordController.text
    );

    if (mounted) {
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful! You can now log in.")),
        );

        // 4. On successful registration, navigate to the Login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );

      } else {
        // 5. Show Firebase error message (e.g., 'weak-password')
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign Up failed ❌: $result")),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final String bgImage = themeProvider.isDarkMode
        ? 'assets/images/bg_dark.png'
        : 'assets/images/background.png';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Background
          Image.asset(bgImage, fit: BoxFit.cover),

          // Layer 2: Overlay
          IgnorePointer(
            child: Container(
              color: themeProvider.isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.3),
            ),
          ),

          // Layer 3: Form
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // ... All your TextFormFields and Buttons for signup
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                          validator: (value) => value!.isEmpty ? "Enter your email" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()),
                          validator: (value) => value!.isEmpty ? "Enter your password" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "Confirm Password", prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                          validator: (value) => value!.isEmpty ? "Confirm your password" : null,
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                          child: const Text("Sign Up"),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                          },
                          child: const Text("Already have an account? Login"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Layer 4: Button (now on top)
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: themeProvider.isDarkMode ? Colors.yellow : Colors.black,
              ),
              onPressed: () {
                print('--- SIGNUP PAGE BUTTON WAS PRESSED ---');
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
              iconSize: 30,
            ),
          ),
        ],
      ),
    );
  }
}
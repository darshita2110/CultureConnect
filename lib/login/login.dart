import 'package:culture_connect/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:culture_connect/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:culture_connect/theme_provider.dart';
import '../forgot_password.dart';
import 'package:culture_connect/login/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = AuthService();
    final result = await auth.login(_emailController.text, _passwordController.text);

    if (mounted) {
      if (result == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()),
        );
        // TODO: Navigate to Home page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed ❌: $result")),
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
          // Layer 1: Background Image
          Image.asset(bgImage, fit: BoxFit.cover),

          // Layer 2: Transparent Overlay (set to ignore taps)
          IgnorePointer(
            child: Container(
              color: themeProvider.isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.3),
            ),
          ),

          // Layer 3: The scrollable login form
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),
                  Text(
                    "Login",
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
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "Enter your email" : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "Enter your password" : null,
                        ),
                        const SizedBox(height: 10),

                        // 🔹 Forgot Password button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage()),
                              );
                            },
                            child: const Text("Forgot Password?"),
                          ),
                        ),

                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            minimumSize:
                            const Size(double.infinity, 50),
                          ),
                          child: const Text("Login"),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignupPage()),
                            );
                          },
                          child: const Text("Don't have an account? Sign up"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Layer 4: The Theme Toggle Button (now on top and clickable)
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
                color: themeProvider.isDarkMode ? Colors.yellow : Colors.black,
              ),
              // In login.dart, inside the final Positioned widget
              onPressed: () {
                print('--- LOGIN PAGE BUTTON WAS PRESSED ---');
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
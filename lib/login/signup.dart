import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;
  final VoidCallback switchPage;

  const SignupPage({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
    required this.switchPage,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match ❌")),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Signup successful 🎉")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Signup failed ❌: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String bgImage = widget.isDarkMode
        ? 'assets/images/bg_dark.png'
        : 'assets/images/background.png';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(bgImage, fit: BoxFit.cover),
          Container(
            color: widget.isDarkMode
                ? Colors.black.withOpacity(0.5)
                : Colors.white.withOpacity(0.3),
          ),
          Positioned(
            top: 40,   // adjust for safe area
            right: 16,
            child: IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: widget.isDarkMode ? Colors.yellow : Colors.black,
              ),
              onPressed: widget.onToggle,
              iconSize: 30,
            ),
          ),
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
                      color: widget.isDarkMode ? Colors.white : Colors.black,
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
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "Confirm your password" : null,
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text("Sign Up"),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: widget.switchPage,
                          child:
                          const Text("Already have an account? Login"),
                        ),
                      ],
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
}

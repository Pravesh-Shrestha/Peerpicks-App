import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Signing in with Email: ${_emailController.text} and Password: ${_passwordController.text}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Title + Logo Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 98, 113, 43),
                        ),
                      ),
                      Image.asset(
                        "assets/images/logos/logo.png", // Replace with your image
                        height: 60,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // EMAIL
                  const Text("EMAIL", style: TextStyle(fontSize: 12)),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.check),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD
                  const Text("PASSWORD", style: TextStyle(fontSize: 12)),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.visibility_off),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sign In Button
                  GestureDetector(
                    onTap: _submitForm,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "SIGN IN",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Don’t have an account? Sign up.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Social buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Using standard Flutter Icons that closely represent the brands
                      socialCircle(
                        Icons.facebook,
                      ), // Still the standard icon, but clear
                      const SizedBox(width: 20),
                      socialCircle(
                        Icons.code,
                      ), // Using 'code' for a generic programming/dev icon
                      const SizedBox(width: 20),
                      socialCircle(Icons.g_mobiledata), // Google icon
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget socialCircle(IconData icon) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Icon(icon, size: 28),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:peerpicks/screens/auth/sign_up_screen.dart';
import 'package:peerpicks/screens/home/home_screen.dart';

// Define the common color for consistency
const Color peerPicksGreen = Color(0xFF75A638);
const Color darkTextColor = Color(0xFF333333);

// --- Start of SignInScreen with Validation, Larger Logo, and High Visibility Design ---
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

  // Validation Logic (Email and Password)
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value))
      return 'Please enter a valid email address.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  // UPDATED: Function to handle form submission and navigate to Dashboard
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, perform sign-in logic (simulated delay)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signing in...'),
          backgroundColor: peerPicksGreen,
          duration: Duration(seconds: 1),
        ),
      );

      // Navigate to DashboardScreen upon successful sign-in
      Future.delayed(const Duration(milliseconds: 1200), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  const SizedBox(height: 30),

                  // Title + Logo Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: peerPicksGreen,
                        ),
                      ),
                      Image.asset("assets/images/logos/logo.png", height: 80),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // EMAIL
                  const Text(
                    "EMAIL",
                    style: TextStyle(
                      fontSize: 12,
                      color: darkTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    style: const TextStyle(color: darkTextColor),
                    cursorColor: peerPicksGreen,
                    decoration: InputDecoration(
                      hintText: "Enter your email address",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      suffixIcon: const Icon(
                        Icons.check,
                        color: peerPicksGreen,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: peerPicksGreen,
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // PASSWORD
                  const Text(
                    "PASSWORD",
                    style: TextStyle(
                      fontSize: 12,
                      color: darkTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: _validatePassword,
                    style: const TextStyle(color: darkTextColor),
                    cursorColor: peerPicksGreen,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      suffixIcon: const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: peerPicksGreen,
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Sign In Button
                  GestureDetector(
                    onTap: _submitForm,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: peerPicksGreen,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: peerPicksGreen.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "SIGN IN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Sign Up Navigation Link
                  Center(
                    child: GestureDetector(
                      onTap: _navigateToSignUp,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          children: [
                            TextSpan(text: "Don’t have an account? "),
                            TextSpan(
                              text: "Sign up.",
                              style: TextStyle(
                                color: peerPicksGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Social buttons row (using FontAwesome icons with brand colors)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Facebook (Blue)
                      socialCircle(
                        FontAwesomeIcons.facebookF,
                        const Color(0xFF1877F2),
                      ),
                      const SizedBox(width: 20),
                      // GitHub (Dark Text Color)
                      socialCircle(FontAwesomeIcons.github, darkTextColor),
                      const SizedBox(width: 20),
                      // Google (Red/Brand Color)
                      socialCircle(
                        FontAwesomeIcons.google,
                        const Color(0xFFDB4437),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for social icons (Updated to accept color)
  Widget socialCircle(IconData icon, Color iconColor) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: FaIcon(icon, size: 22, color: iconColor), // Use FaIcon
      ),
    );
  }
}

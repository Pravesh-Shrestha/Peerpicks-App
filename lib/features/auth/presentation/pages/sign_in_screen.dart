import 'package:flutter/material.dart';
import 'package:peerpicks/common/mysnackbar.dart';
import 'package:peerpicks/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/home_screen.dart';
import 'package:peerpicks/features/auth/presentation/widgets/auth_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Note: The visibility logic from the original code was removed in a previous step,
  // but the widget uses a visible icon. I will fix this in the widget definitions above
  // but keep the state variable for completeness if you decide to re-implement it.
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showMySnackBar(
        context: context,
        message: 'Signing In...',
        color: peerPicksGreen,
      );

      // Simulate network delay and successful login
      Future.delayed(const Duration(seconds: 1), () {
        // Navigate to the Home Screen and replace the current route
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    } else {
      showMySnackBar(
        context: context,
        message: 'Invalid credentials or missing fields.',
        color: Colors.red,
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
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

                buildAuthTextFormField(
                  controller: _emailController,
                  validator: _validateEmail,
                  labelText: "EMAIL",
                  hintText: "Enter your email address",
                  keyboardType: TextInputType.emailAddress,
                  suffixIcon: const Icon(
                    Icons.check,
                    size: 20,
                    color: peerPicksGreen,
                  ),
                ),
                const SizedBox(height: 24),

                buildAuthTextFormField(
                  controller: _passwordController,
                  validator: _validatePassword,
                  labelText: "PASSWORD",
                  hintText: "Enter your password",
                  obscureText: !_isPasswordVisible,
                  suffixIcon: buildVisibilityToggle(
                    isVisible: _isPasswordVisible,
                    toggleFunction: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

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

                buildActionButton(
                  text: "SIGN IN",
                  onTap: _submitForm,
                  color: Colors.black,
                ),
                const SizedBox(height: 18),

                Center(
                  child: GestureDetector(
                    onTap: _navigateToSignUp,
                    child: const Text.rich(
                      TextSpan(
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
                buildSocialRow(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

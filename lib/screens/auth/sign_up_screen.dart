import 'package:flutter/material.dart';
import 'package:peerpicks/common/mysnackbar.dart';
import 'package:peerpicks/screens/auth/sign_in_screen.dart';
import 'package:peerpicks/widgets/auth_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToSignIn() {
    // Navigate back to Sign In screen
    Navigator.pop(context);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showMySnackBar(
        context: context,
        message: 'Account Registered Successfully! Please Sign In.',
        color: peerPicksGreen,
      );

      // Navigate to the Sign In screen after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } else {
      showMySnackBar(
        context: context,
        message: 'Please fill out all fields correctly.',
        color: Colors.red,
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required.';
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm password is required.';
    if (value != _passwordController.text) return 'Passwords do not match.';
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
                      "Sign Up",
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
                  controller: _nameController,
                  validator: _validateName,
                  labelText: "NAME",
                  hintText: "Enter your full name",
                  keyboardType: TextInputType.name,
                  suffixIcon: const Icon(
                    Icons.check,
                    size: 20,
                    color: peerPicksGreen,
                  ),
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

                buildAuthTextFormField(
                  controller: _passwordController,
                  validator: _validatePassword,
                  labelText: "PASSWORD",
                  hintText: "Create a password (min 6 chars)",
                  obscureText: !_isPasswordVisible,
                  suffixIcon: buildVisibilityToggle(
                    isVisible: _isPasswordVisible,
                    toggleFunction: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                buildAuthTextFormField(
                  controller: _confirmPasswordController,
                  validator: _validateConfirmPassword,
                  labelText: "CONFIRM PASSWORD",
                  hintText: "Re-enter your password",
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: buildVisibilityToggle(
                    isVisible: _isConfirmPasswordVisible,
                    toggleFunction: () => setState(
                      () => _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                buildActionButton(
                  text: "SIGN UP",
                  onTap: _submitForm,
                  color: Colors.black,
                ),
                const SizedBox(height: 18),

                Center(
                  child: GestureDetector(
                    onTap: _navigateToSignIn,
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        children: [
                          const TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Sign in.",
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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Note: Assuming SignInScreen is correctly located

// Define the common colors
const Color peerPicksGreen = Color(0xFF75A638);
const Color darkTextColor = Color(0xFF333333);

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

  void _navigateToSignIn() {
    Navigator.pop(context); // Go back to the previous screen (SignInScreen)
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registering Account...'),
          backgroundColor: peerPicksGreen,
        ),
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
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm Password is required.';
    if (value != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Helper Widgets defined locally ---

  Widget _buildSocialRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialCircle(
          FontAwesomeIcons.facebook,
          iconColor: Colors.white,
          circleColor: Color(0xFF1877F2),
        ),
        SizedBox(width: 20),
        _SocialCircle(
          FontAwesomeIcons.twitter,
          iconColor: Colors.white,
          circleColor: Color(0xFF1DA1F2),
        ),
        SizedBox(width: 20),
        _SocialCircle(
          FontAwesomeIcons.google,
          iconColor: darkTextColor,
          circleColor: Colors.white,
          borderColor: Colors.grey,
        ),
      ],
    );
  }

  // Updated _buildAuthTextFormField for High Visibility
  Widget _buildAuthTextFormField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String labelText,
    required String hintText, // New required parameter for placeholder
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 12,
            color: darkTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: darkTextColor),
          cursorColor: peerPicksGreen,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    size: 20,
                    color: obscureText ? Colors.grey : peerPicksGreen,
                  )
                : null,
            // High visibility design
            filled: true,
            fillColor: Colors.grey.shade100,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: peerPicksGreen, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            isDense: false,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "SIGN UP",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light theme background
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
                        "Sign up",
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

                  // NAME
                  _buildAuthTextFormField(
                    controller: _nameController,
                    validator: _validateName,
                    labelText: "NAME",
                    hintText: "Enter your full name",
                    keyboardType: TextInputType.name,
                    suffixIcon: Icons.check,
                  ),

                  const SizedBox(height: 16),

                  // EMAIL
                  _buildAuthTextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    labelText: "EMAIL",
                    hintText: "Enter your email address",
                    keyboardType: TextInputType.emailAddress,
                    suffixIcon: Icons.check,
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD
                  _buildAuthTextFormField(
                    controller: _passwordController,
                    validator: _validatePassword,
                    labelText: "PASSWORD",
                    hintText: "Create a password (min 6 chars)",
                    obscureText: true,
                    suffixIcon: Icons.remove_red_eye_outlined,
                  ),

                  const SizedBox(height: 16),

                  // CONFIRM PASSWORD
                  _buildAuthTextFormField(
                    controller: _confirmPasswordController,
                    validator: _validateConfirmPassword,
                    labelText: "CONFIRM PASSWORD",
                    hintText: "Re-enter your password",
                    obscureText: true,
                    suffixIcon: Icons.remove_red_eye_outlined,
                  ),

                  const SizedBox(height: 40),

                  // Sign Up Button
                  _buildActionButton(
                    text: "SIGN UP",
                    onTap: _submitForm,
                    color: peerPicksGreen,
                  ), // Sign Up button uses the Green color

                  const SizedBox(height: 18),

                  // Back to Sign In Link
                  Center(
                    child: GestureDetector(
                      onTap: _navigateToSignIn,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          children: [
                            TextSpan(text: "Already have an account? "),
                            // Highlight link using primary color
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

                  // Social buttons row
                  _buildSocialRow(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget for the social media circles (kept outside state for simplicity)
class _SocialCircle extends StatelessWidget {
  const _SocialCircle(
    this.icon, {
    required this.iconColor,
    required this.circleColor,
    this.borderColor = Colors.transparent,
  });

  final IconData icon;
  final Color iconColor;
  final Color circleColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: Icon(icon, size: 22, color: iconColor)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/core/utils/mysnackbar.dart';
import 'package:peerpicks/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:peerpicks/features/auth/presentation/state/auth_state.dart';
import 'package:peerpicks/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:peerpicks/features/auth/presentation/widgets/auth_widget.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/home_screen.dart';

// Change to ConsumerStatefulWidget to access "ref"
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Call the ViewModel login logic
      ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
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
    // Listen for state changes (Success or Error)
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        showMySnackBar(
          context: context,
          message: 'Login Successful!',
          color: peerPicksGreen,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (next.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? 'Login Failed',
          color: Colors.red,
        );
      }
    });

    final authState = ref.watch(authViewModelProvider);

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
                    // Ensure you have this asset in pubspec.yaml
                    Image.asset(
                      "assets/images/logos/logo.png",
                      height: 80,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.star,
                        size: 80,
                        color: peerPicksGreen,
                      ),
                    ),
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

                // Show loading indicator if state is loading
                buildActionButton(
                  text: authState.status == AuthStatus.loading
                      ? "PLEASE WAIT..."
                      : "SIGN IN",
                  onTap: authState.status == AuthStatus.loading
                      ? () {}
                      : _submitForm,
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

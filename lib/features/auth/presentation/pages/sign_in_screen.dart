import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerpicks/app/routes/app_routes.dart';
import 'package:peerpicks/common/app_colors.dart';
import 'package:peerpicks/core/services/auth/biometric_auth_service.dart';
import 'package:peerpicks/core/services/storage/user_session_service.dart';
import 'package:peerpicks/core/utils/mysnackbar.dart';
import 'package:peerpicks/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:peerpicks/features/auth/presentation/pages/sign_up_screen.dart';
import 'package:peerpicks/features/auth/presentation/state/auth_state.dart';
import 'package:peerpicks/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:peerpicks/features/auth/presentation/widgets/auth_widget.dart';
import 'package:peerpicks/features/dashboard/presentation/pages/home_screen.dart';

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
  bool _showBiometricLogin = false;
  bool _hasSavedBiometricCredentials = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_prepareBiometricLogin);
  }

  Future<void> _prepareBiometricLogin() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final sessionService = ref.read(userSessionServiceProvider);

    final canUseBiometrics = await biometricService.canUseBiometrics();
    final isEnabled = sessionService.isBiometricLoginEnabled();
    final creds = await sessionService.getBiometricCredentials();
    if (!mounted) return;

    setState(() {
      _showBiometricLogin = canUseBiometrics && isEnabled;
      _hasSavedBiometricCredentials = creds != null;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToSignUp() {
    AppRoutes.push(context, const SignupPage());
  }

  // Consolidated submission logic
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  Future<void> _signInWithBiometric() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final sessionService = ref.read(userSessionServiceProvider);

    final authenticated = await biometricService.authenticate();
    if (!authenticated) return;

    final creds = await sessionService.getBiometricCredentials();
    if (creds == null) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: 'No saved credentials found for biometric sign-in.',
        color: Colors.red,
      );
      return;
    }

    final (email, password) = creds;
    _emailController.text = email;
    _passwordController.text = password;

    ref
        .read(authViewModelProvider.notifier)
        .login(email: email, password: password);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
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
        if (context.mounted) {
          final sessionService = ref.read(userSessionServiceProvider);
          if (sessionService.isBiometricLoginEnabled()) {
            sessionService.saveBiometricCredentials(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
          }
          showMySnackBar(
            context: context,
            message: 'Login Successful!',
            color: Colors.green, // Ensure peerPicksGreen is defined globally
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else if (next.status == AuthStatus.error) {
        if (context.mounted) {
          showMySnackBar(
            context: context,
            message: next.errorMessage ?? 'Login Failed',
            color: Colors.red,
          );
        }
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final bool isLoading = authState.status == AuthStatus.loading;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
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
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Image.asset(
                      "assets/images/logos/logo.png",
                      height: 80,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.star, size: 80, color: Colors.green),
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
                    color: Colors.green,
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
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                buildActionButton(
                  context: context,
                  text: isLoading ? "PLEASE WAIT..." : "SIGN IN",
                  onTap: isLoading ? () {} : _submitForm,
                  color: cs.onSurface,
                ),
                if (_showBiometricLogin) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _signInWithBiometric,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: Text(
                      _hasSavedBiometricCredentials
                          ? 'Use Face ID / Fingerprint'
                          : 'Enable Face ID / Fingerprint (after first login)',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: BorderSide(color: cs.outline),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Center(
                  child: GestureDetector(
                    onTap: isLoading ? null : _navigateToSignUp,
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Sign up.",
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                buildSocialRow(context: context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

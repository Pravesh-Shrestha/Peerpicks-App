import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title + Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Image.asset("assets/logo.png", height: 45),
                ],
              ),

              const SizedBox(height: 30),

              // NAME FIELD
              const Text("NAME", style: TextStyle(fontSize: 12)),
              SizedBox(
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.check),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // EMAIL
              const Text("EMAIL", style: TextStyle(fontSize: 12)),
              SizedBox(
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.check),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // PASSWORD
              const Text("PASSWORD", style: TextStyle(fontSize: 12)),
              SizedBox(
                height: 50,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.visibility_off),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CONFIRM PASSWORD
              const Text("CONFIRM PASSWORD", style: TextStyle(fontSize: 12)),
              SizedBox(
                height: 50,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.visibility_off),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign Up Button
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text("SIGN UP", style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Already have an account? Sign in.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  socialCircle(Icons.facebook),
                  const SizedBox(width: 20),
                  socialCircle(Icons.flutter_dash),
                  const SizedBox(width: 20),
                  socialCircle(Icons.g_mobiledata),
                ],
              ),
            ],
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
